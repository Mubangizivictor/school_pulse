/**
 * Exam Factory operations: sitting schedule, room/invigilator assignment,
 * attendance, incidents, and marking through to result approval. Result
 * approval is the one place this module writes outside schools/{schoolId}/
 * exam_factory_* - it also writes schools/{schoolId}/subject_assessments and
 * student_marks in the exact shape report_card_engine.js expects, so
 * approved exam results feed Performance and Report Cards with no engine
 * changes. See subject_teacher_remote_data_source.dart's saveMarks for the
 * Dart-side contract this mirrors.
 */
const { windowsOverlap, sittingEndTime } = require('./exam_factory_scheduling');

module.exports = ({ admin, onCall, HttpsError }) => {
  const db = admin.firestore();
  const FieldValue = admin.firestore.FieldValue;
  const { enqueueNotification } = require('./notification_helpers')({ admin });
  const LEAD_ROLES = new Set(['director', 'headTeacher', 'deputyHead', 'deanOfStudies', 'hod', 'moderator', 'schoolAdmin']);
  const MARKER_ROLES = new Set([...LEAD_ROLES, 'classTeacher', 'subjectTeacher']);

  async function notifyExamUser(institutionId, uid, { type, title, shortBody, entityId, entityType, idempotencyKey }) {
    await enqueueNotification({
      schoolId: institutionId,
      recipientUid: uid,
      type,
      title,
      shortBody,
      idempotencyKey,
      sourceEntityId: entityId,
      sourceModule: 'examFactory',
      senderRoleSnapshot: 'Exam Factory',
      metadata: { examEntityId: entityId, examEntityType: entityType },
    });
  }

  async function notifyExamLeads(institutionId, { type, title, shortBody, entityId, entityType, idempotencyKey }) {
    await enqueueNotification({
      schoolId: institutionId,
      recipientRoles: [...LEAD_ROLES],
      type,
      title,
      shortBody,
      idempotencyKey,
      sourceEntityId: entityId,
      sourceModule: 'examFactory',
      senderRoleSnapshot: 'Exam Factory',
      metadata: { examEntityId: entityId, examEntityType: entityType },
    });
  }

  const clean = (value, max = 160) => String(value ?? '').trim().slice(0, max);
  const requireId = (value, label) => {
    const id = clean(value, 128);
    if (!id) throw new HttpsError('invalid-argument', `${label} is required.`);
    return id;
  };
  const asRoles = (user) => [...new Set([user.role, ...(Array.isArray(user.roles) ? user.roles : [])].filter(Boolean))];
  const isLead = (user) => asRoles(user).some((role) => LEAD_ROLES.has(role));
  const canMark = (user) => asRoles(user).some((role) => MARKER_ROLES.has(role));

  async function actor(request, institutionId) {
    if (!request.auth) throw new HttpsError('unauthenticated', 'You must be signed in.');
    const snapshot = await db.collection('users').doc(request.auth.uid).get();
    const user = snapshot.exists ? snapshot.data() : null;
    if (!user || !user.schoolId || user.schoolId !== institutionId) {
      throw new HttpsError('permission-denied', 'Your active institution does not match this examination.');
    }
    return { uid: request.auth.uid, user, roles: asRoles(user) };
  }

  const schoolRef = (institutionId) => db.collection('schools').doc(institutionId);
  const paperRef = (institutionId, paperId) => schoolRef(institutionId).collection('exam_factory_papers').doc(paperId);
  const sittingRef = (institutionId, sittingId) => schoolRef(institutionId).collection('exam_factory_sittings').doc(sittingId);
  const invigilatorRef = (institutionId, assignmentId) => schoolRef(institutionId).collection('exam_factory_invigilators').doc(assignmentId);
  const attendanceRef = (institutionId, recordId) => schoolRef(institutionId).collection('exam_factory_attendance').doc(recordId);
  const incidentRef = (institutionId, incidentId) => schoolRef(institutionId).collection('exam_factory_incidents').doc(incidentId);
  const markRef = (institutionId, entryId) => schoolRef(institutionId).collection('exam_factory_marks').doc(entryId);
  const seatRef = (institutionId, seatId) => schoolRef(institutionId).collection('exam_factory_seating').doc(seatId);
  const scriptRef = (institutionId, scriptId) => schoolRef(institutionId).collection('exam_factory_scripts').doc(scriptId);
  const auditRef = (institutionId, id) => schoolRef(institutionId).collection('exam_factory_audit').doc(id);
  async function audit(institutionId, id, data) {
    await auditRef(institutionId, id).set({ institutionId, ...data, at: FieldValue.serverTimestamp() }, { merge: true });
  }

  const api = {};

  /**
   * Schedules one paper into a dated sitting at a venue. Rejects a venue
   * double-booking (same venue, overlapping time window) the same way
   * timetable_conflict_resolver.dart flags room conflicts for the weekly
   * class timetable - the exam version just compares absolute datetimes
   * instead of day+slot.
   */
  api.saveExamSitting = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const paperId = requireId(data.paperId, 'Paper');
    const venueId = requireId(data.venueId, 'Venue');
    const source = await actor(request, institutionId);
    if (!isLead(source.user)) throw new HttpsError('permission-denied', 'Scheduling permission is required.');

    const paperSnap = await paperRef(institutionId, paperId).get();
    if (!paperSnap.exists) throw new HttpsError('not-found', 'Paper not found.');
    const paper = paperSnap.data();

    const startTime = new Date(clean(data.startTime, 40));
    const durationMinutes = Number(data.durationMinutes) || Number(paper.durationMinutes) || 60;
    if (Number.isNaN(startTime.getTime())) throw new HttpsError('invalid-argument', 'A valid start time is required.');
    const endTime = new Date(startTime.getTime() + durationMinutes * 60000);

    const sittingId = clean(data.sittingId, 128) || db.collection('_ids').doc().id;
    const priorSittingSnap = await sittingRef(institutionId, sittingId).get();

    // Overlap check: any other sitting at the same venue whose window
    // intersects [startTime, endTime).
    const venueSittings = await schoolRef(institutionId).collection('exam_factory_sittings')
      .where('venueId', '==', venueId).get();
    const conflict = venueSittings.docs.find((doc) => {
      if (doc.id === sittingId) return false;
      const other = doc.data();
      const otherStart = other.startTime.toDate();
      const otherEnd = sittingEndTime(otherStart, other.durationMinutes);
      return windowsOverlap(startTime, endTime, otherStart, otherEnd);
    });
    if (conflict) throw new HttpsError('failed-precondition', 'This venue is already booked for an overlapping time.');

    await sittingRef(institutionId, sittingId).set({
      institutionId,
      seriesId: paper.seriesId,
      paperId,
      venueId,
      venueName: clean(data.venueName, 120),
      startTime: admin.firestore.Timestamp.fromDate(startTime),
      durationMinutes,
      updatedAt: FieldValue.serverTimestamp(),
      createdAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    await audit(institutionId, `sitting-save-${sittingId}`, { action: 'sitting_saved', actorId: source.uid, sittingId, paperId, venueId });

    if (priorSittingSnap.exists) {
      const invigilators = await schoolRef(institutionId).collection('exam_factory_invigilators')
        .where('sittingId', '==', sittingId).get();
      await Promise.all(invigilators.docs.map((doc) => notifyExamUser(institutionId, doc.data().staffId, {
        type: 'examPaperWorkflow',
        title: 'Exam timetable changed',
        shortBody: 'A sitting you are invigilating has been rescheduled.',
        entityId: sittingId,
        entityType: 'sitting',
        idempotencyKey: `sitting-changed-${sittingId}-${startTime.getTime()}`,
      })));
    }
    return { sittingId };
  });

  /**
   * Assigns a staff member to invigilate a sitting. Rejects a teacher
   * conflict: the same staff member already invigilating another sitting
   * whose time window overlaps this one.
   */
  api.assignExamInvigilator = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const sittingId = requireId(data.sittingId, 'Sitting');
    const staffId = requireId(data.staffId, 'Staff member');
    const source = await actor(request, institutionId);
    if (!isLead(source.user)) throw new HttpsError('permission-denied', 'Invigilator assignment permission is required.');

    const sittingSnap = await sittingRef(institutionId, sittingId).get();
    if (!sittingSnap.exists) throw new HttpsError('not-found', 'Sitting not found.');
    const sitting = sittingSnap.data();
    const start = sitting.startTime.toDate();
    const end = sittingEndTime(start, sitting.durationMinutes);

    const existing = await schoolRef(institutionId).collection('exam_factory_invigilators')
      .where('staffId', '==', staffId).get();
    for (const doc of existing.docs) {
      const other = doc.data();
      if (other.sittingId === sittingId) continue;
      const otherSittingSnap = await sittingRef(institutionId, other.sittingId).get();
      if (!otherSittingSnap.exists) continue;
      const otherSitting = otherSittingSnap.data();
      const otherStart = otherSitting.startTime.toDate();
      const otherEnd = sittingEndTime(otherStart, otherSitting.durationMinutes);
      if (windowsOverlap(start, end, otherStart, otherEnd)) {
        throw new HttpsError('failed-precondition', 'This staff member is already invigilating an overlapping sitting.');
      }
    }

    const role = data.role === 'chief' ? 'chief' : 'assistant';
    const assignmentId = clean(data.assignmentId, 128) || db.collection('_ids').doc().id;
    await invigilatorRef(institutionId, assignmentId).set({
      institutionId,
      sittingId,
      staffId,
      staffName: clean(data.staffName, 120),
      role,
      assignedBy: source.uid,
      assignedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    await audit(institutionId, `invigilator-assign-${assignmentId}`, { action: 'invigilator_assigned', actorId: source.uid, sittingId, staffId, role });
    await notifyExamUser(institutionId, staffId, {
      type: 'examPaperWorkflow',
      title: 'Invigilation assignment',
      shortBody: `You have been assigned as ${role === 'chief' ? 'chief' : 'an assistant'} invigilator for an exam sitting.`,
      entityId: sittingId,
      entityType: 'sitting',
      idempotencyKey: `invigilator-assign-${assignmentId}`,
    });
    return { assignmentId };
  });

  api.removeExamInvigilator = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const assignmentId = requireId(data.assignmentId, 'Assignment');
    const source = await actor(request, institutionId);
    if (!isLead(source.user)) throw new HttpsError('permission-denied', 'Invigilator assignment permission is required.');
    await invigilatorRef(institutionId, assignmentId).delete();
    await audit(institutionId, `invigilator-remove-${assignmentId}`, { action: 'invigilator_removed', actorId: source.uid, assignmentId });
    return { assignmentId };
  });

  const ATTENDANCE_STATUSES = new Set(['present', 'absent', 'late', 'extraTime']);

  /**
   * Records exam attendance for one candidate at one sitting. Idempotent
   * per (sittingId, studentId) via a deterministic doc id, so a retried
   * offline-queued write corrects the same row instead of duplicating it -
   * the same idempotency shape as saveMarks' deterministic mark doc id.
   */
  api.recordExamAttendance = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const sittingId = requireId(data.sittingId, 'Sitting');
    const studentId = requireId(data.studentId, 'Student');
    const status = clean(data.status, 20);
    if (!ATTENDANCE_STATUSES.has(status)) throw new HttpsError('invalid-argument', 'Invalid attendance status.');
    const source = await actor(request, institutionId);
    if (!canMarkOrInvigilate(source.user)) throw new HttpsError('permission-denied', 'Attendance permission is required.');

    const recordId = `${sittingId}_${studentId}`;
    await attendanceRef(institutionId, recordId).set({
      institutionId,
      sittingId,
      studentId,
      studentName: clean(data.studentName, 120),
      status,
      note: clean(data.note, 500),
      recordedBy: source.uid,
      recordedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    await audit(institutionId, `attendance-${recordId}-${clean(data.operationId, status)}`, { action: 'attendance_recorded', actorId: source.uid, sittingId, studentId, status });
    return { recordId };
  });

  /**
   * Assigns one candidate to one seat number at a sitting. Idempotent per
   * (sittingId, studentId) - re-assigning the same candidate updates their
   * seat rather than creating a second row.
   */
  api.assignExamSeat = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const sittingId = requireId(data.sittingId, 'Sitting');
    const studentId = requireId(data.studentId, 'Student');
    const seatNumber = clean(data.seatNumber, 20);
    if (!seatNumber) throw new HttpsError('invalid-argument', 'A seat number is required.');
    const source = await actor(request, institutionId);
    if (!isLead(source.user)) throw new HttpsError('permission-denied', 'Seating permission is required.');

    const seatId = `${sittingId}_${studentId}`;
    await seatRef(institutionId, seatId).set({
      institutionId,
      sittingId,
      studentId,
      studentName: clean(data.studentName, 120),
      seatNumber,
      assignedBy: source.uid,
      assignedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    await audit(institutionId, `seat-assign-${seatId}`, { action: 'seat_assigned', actorId: source.uid, sittingId, studentId, seatNumber });
    return { seatId };
  });

  api.removeExamSeat = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const seatId = requireId(data.seatId, 'Seat');
    const source = await actor(request, institutionId);
    if (!isLead(source.user)) throw new HttpsError('permission-denied', 'Seating permission is required.');
    await seatRef(institutionId, seatId).delete();
    await audit(institutionId, `seat-remove-${seatId}`, { action: 'seat_removed', actorId: source.uid, seatId });
    return { seatId };
  });

  const SCRIPT_STATUSES = new Set(['distributed', 'collected', 'missing']);

  /**
   * Tracks one candidate's script through distribution/collection at a
   * sitting. `missing` is a distinct status (not just "not collected") so a
   * script genuinely unaccounted for is visible separately from one simply
   * not yet processed.
   */
  api.recordExamScript = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const sittingId = requireId(data.sittingId, 'Sitting');
    const studentId = requireId(data.studentId, 'Student');
    const status = clean(data.status, 20);
    if (!SCRIPT_STATUSES.has(status)) throw new HttpsError('invalid-argument', 'Invalid script status.');
    const source = await actor(request, institutionId);
    if (!canMarkOrInvigilate(source.user)) throw new HttpsError('permission-denied', 'Script tracking permission is required.');

    const scriptId = `${sittingId}_${studentId}`;
    await scriptRef(institutionId, scriptId).set({
      institutionId,
      sittingId,
      studentId,
      studentName: clean(data.studentName, 120),
      status,
      note: clean(data.note, 500),
      recordedBy: source.uid,
      recordedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    await audit(institutionId, `script-${scriptId}-${clean(data.operationId, status)}`, { action: 'script_recorded', actorId: source.uid, sittingId, studentId, status });

    if (status === 'missing') {
      await notifyExamLeads(institutionId, {
        type: 'examPaperWorkflow',
        title: 'Missing script alert',
        shortBody: 'A candidate’s script is unaccounted for at an exam sitting.',
        entityId: sittingId,
        entityType: 'sitting',
        idempotencyKey: `script-missing-${scriptId}`,
      });
    }
    return { scriptId };
  });

  function canMarkOrInvigilate(user) {
    return isLead(user) || asRoles(user).some((role) => MARKER_ROLES.has(role));
  }

  const INCIDENT_TYPES = new Set(['lateArrival', 'malpractice', 'illness', 'materialsIssue', 'disturbance', 'other']);

  api.reportExamIncident = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const sittingId = requireId(data.sittingId, 'Sitting');
    const type = clean(data.type, 40);
    if (!INCIDENT_TYPES.has(type)) throw new HttpsError('invalid-argument', 'Invalid incident type.');
    const description = clean(data.description, 2000);
    if (!description) throw new HttpsError('invalid-argument', 'A description is required.');
    const source = await actor(request, institutionId);
    if (!canMarkOrInvigilate(source.user)) throw new HttpsError('permission-denied', 'Incident reporting permission is required.');

    const incidentId = clean(data.incidentId, 128) || db.collection('_ids').doc().id;
    const studentIds = Array.isArray(data.studentIds) ? data.studentIds.map((id) => clean(id, 128)).filter(Boolean) : [];
    await incidentRef(institutionId, incidentId).set({
      institutionId,
      sittingId,
      type,
      description,
      studentIds,
      status: 'open',
      reportedBy: source.uid,
      reportedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    await audit(institutionId, `incident-report-${incidentId}`, { action: 'incident_reported', actorId: source.uid, sittingId, type });
    return { incidentId };
  });

  api.resolveExamIncident = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const incidentId = requireId(data.incidentId, 'Incident');
    const resolution = clean(data.resolution, 2000);
    if (!resolution) throw new HttpsError('invalid-argument', 'A resolution note is required.');
    const source = await actor(request, institutionId);
    if (!isLead(source.user)) throw new HttpsError('permission-denied', 'Incident resolution permission is required.');
    const ref = incidentRef(institutionId, incidentId);
    const snap = await ref.get();
    if (!snap.exists) throw new HttpsError('not-found', 'Incident not found.');
    await ref.update({ status: 'resolved', resolution, resolvedBy: source.uid, resolvedAt: FieldValue.serverTimestamp() });
    await audit(institutionId, `incident-resolve-${incidentId}`, { action: 'incident_resolved', actorId: source.uid, incidentId });
    return { incidentId, status: 'resolved' };
  });

  /**
   * Saves a marker's draft/submitted mark for one candidate on one exam
   * paper. This is the Exam Factory-internal working copy
   * (exam_factory_marks) - it is NOT yet visible to Performance or Report
   * Cards. Only approveExamResults (below) publishes settled marks into the
   * canonical student_marks/subject_assessments collections the report
   * engine reads.
   */
  api.saveExamMarkEntry = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const paperId = requireId(data.paperId, 'Paper');
    const studentId = requireId(data.studentId, 'Student');
    const source = await actor(request, institutionId);
    if (!canMark(source.user)) throw new HttpsError('permission-denied', 'Marking permission is required.');

    const paperSnap = await paperRef(institutionId, paperId).get();
    if (!paperSnap.exists) throw new HttpsError('not-found', 'Paper not found.');
    const paper = paperSnap.data();
    const maximumMark = Number(paper.totalMarks) || 0;

    const isAbsent = Boolean(data.isAbsent);
    let score = null;
    if (!isAbsent) {
      score = Number(data.score);
      if (!Number.isFinite(score) || score < 0 || score > maximumMark) {
        throw new HttpsError('invalid-argument', `Score must be between 0 and ${maximumMark}.`);
      }
    }

    const entryId = `${paperId}_${studentId}`;
    const ref = markRef(institutionId, entryId);
    const prior = await ref.get();
    if (prior.exists && ['approved', 'published'].includes(prior.data().status)) {
      throw new HttpsError('failed-precondition', 'This mark is already approved and cannot be edited here.');
    }
    await ref.set({
      institutionId,
      paperId,
      seriesId: paper.seriesId,
      studentId,
      studentName: clean(data.studentName, 120),
      score,
      isAbsent,
      maximumMark,
      remark: clean(data.remark, 500),
      status: 'draft',
      enteredBy: source.uid,
      enteredAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    await audit(institutionId, `mark-save-${entryId}-${clean(data.operationId, 'latest')}`, { action: 'mark_saved', actorId: source.uid, paperId, studentId });
    return { entryId };
  });

  api.submitExamMarks = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const paperId = requireId(data.paperId, 'Paper');
    const source = await actor(request, institutionId);
    if (!canMark(source.user)) throw new HttpsError('permission-denied', 'Marking permission is required.');
    const entries = await schoolRef(institutionId).collection('exam_factory_marks').where('paperId', '==', paperId).get();
    const batch = db.batch();
    let count = 0;
    for (const doc of entries.docs) {
      if (doc.data().status !== 'draft') continue;
      batch.update(doc.ref, { status: 'submitted', updatedAt: FieldValue.serverTimestamp() });
      count += 1;
    }
    await batch.commit();
    await audit(institutionId, `marks-submit-${paperId}-${clean(data.operationId, 'latest')}`, { action: 'marks_submitted', actorId: source.uid, paperId, count });
    return { paperId, submitted: count };
  });

  /**
   * DOS verification + approval of a paper's marks. This is the single
   * point where Exam Factory results become visible outside the module:
   * it creates/updates one subject_assessments document (one component,
   * whose id and weight/maximumMark match what report_card_engine.js joins
   * against) and one student_marks row per candidate, both with the exact
   * field shapes and markStatus/entryStatus values the engine requires -
   * see subject_teacher_remote_data_source.dart's saveMarks for the
   * contract this mirrors. Historical rows already 'approved' or
   * 'published' are left untouched so a later grading-settings change
   * cannot silently rewrite a settled result.
   */
  api.approveExamResults = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const paperId = requireId(data.paperId, 'Paper');
    const source = await actor(request, institutionId);
    if (!isLead(source.user)) throw new HttpsError('permission-denied', 'Result approval permission is required.');

    const paperSnap = await paperRef(institutionId, paperId).get();
    if (!paperSnap.exists) throw new HttpsError('not-found', 'Paper not found.');
    const paper = paperSnap.data();

    const seriesSnap = await schoolRef(institutionId).collection('exam_factory_series').doc(paper.seriesId).get();
    if (!seriesSnap.exists) throw new HttpsError('failed-precondition', 'The paper\'s exam series could not be found.');
    const series = seriesSnap.data();

    const entriesSnap = await schoolRef(institutionId).collection('exam_factory_marks').where('paperId', '==', paperId).get();
    const entries = entriesSnap.docs.map((d) => d.data());
    if (entries.length === 0) throw new HttpsError('failed-precondition', 'No marks have been entered for this paper.');
    const notSubmitted = entries.filter((e) => e.status === 'draft');
    if (notSubmitted.length > 0) throw new HttpsError('failed-precondition', `${notSubmitted.length} mark(s) are still draft and have not been submitted.`);

    const assessmentId = `exam_factory_${paperId}`;
    const componentId = `exam_factory_${paperId}_component`;
    const assessmentRef = schoolRef(institutionId).collection('subject_assessments').doc(assessmentId);
    const priorAssessment = await assessmentRef.get();
    const component = {
      id: componentId,
      name: paper.title,
      maximumMark: Number(paper.totalMarks) || 0,
      weight: 100,
      isRequired: true,
      entryStatus: 'closed',
    };
    await assessmentRef.set({
      schoolId: institutionId,
      subjectId: paper.subjectId,
      classId: paper.classId,
      academicYearId: series.academicYear,
      termId: series.term,
      assessmentTypeId: 'exam_factory',
      assessmentTypeName: 'Examination',
      title: paper.title,
      maximumMark: component.maximumMark,
      status: 'approved',
      requiresApproval: false,
      components: [component],
      examFactoryPaperId: paperId,
      createdAt: priorAssessment.exists ? priorAssessment.data().createdAt : FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });

    const batch = db.batch();
    let approvedCount = 0;
    for (const entry of entries) {
      const markDocId = `${assessmentId}_${componentId}_${entry.studentId}`;
      const markDocRef = schoolRef(institutionId).collection('student_marks').doc(markDocId);
      const existing = await markDocRef.get();
      if (existing.exists && ['approved', 'published'].includes(existing.data().markStatus)) {
        // Never overwrite a settled historical result - a later re-approval
        // of the same paper (e.g. after a correction round) must go through
        // a new paper version, not silently mutate a published mark.
        continue;
      }
      batch.set(markDocRef, {
        schoolId: institutionId,
        assessmentId,
        componentId,
        studentId: entry.studentId,
        subjectId: paper.subjectId,
        classId: paper.classId,
        academicYearId: series.academicYear,
        termId: series.term,
        score: entry.isAbsent ? null : entry.score,
        entryStatus: entry.isAbsent ? 'absent' : 'scored',
        remark: entry.remark || '',
        maximumMark: component.maximumMark,
        markStatus: 'approved',
        roleAssignmentId: '',
        staffId: entry.enteredBy || '',
        enteredAt: entry.enteredAt || FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      }, { merge: true });
      approvedCount += 1;
    }
    await batch.commit();

    const markUpdates = db.batch();
    for (const doc of entriesSnap.docs) {
      markUpdates.update(doc.ref, { status: 'approved', approvedBy: source.uid, approvedAt: FieldValue.serverTimestamp() });
    }
    await markUpdates.commit();

    await audit(institutionId, `results-approve-${paperId}-${clean(data.operationId, 'latest')}`, {
      action: 'results_approved',
      actorId: source.uid,
      role: source.roles[0] || '',
      paperId,
      approvedCount,
      totalEntries: entries.length,
    });

    const markerUids = [...new Set(entries.map((e) => e.enteredBy).filter(Boolean))];
    await Promise.all(markerUids.map((uid) => notifyExamUser(institutionId, uid, {
      type: 'examPaperWorkflow',
      title: 'Results approved',
      shortBody: 'The results you entered have been approved and published.',
      entityId: paperId,
      entityType: 'paper',
      idempotencyKey: `results-approved-${paperId}-${uid}-${clean(data.operationId, 'latest')}`,
    })));

    return { paperId, approvedCount, totalEntries: entries.length };
  });

  return api;
};
