/**
 * Exam Factory's confidential state transitions.  No question, marking-guide
 * or learner-mark content is written to logs.  Each callable re-checks the
 * caller, institution and current state because Admin SDK bypasses rules.
 */
const { createHash } = require('crypto');
const { renderExamPaperPdf } = require('./exam_factory_pdf');

module.exports = ({ admin, onCall, HttpsError }) => {
  const db = admin.firestore();
  const FieldValue = admin.firestore.FieldValue;
  const { enqueueNotification } = require('./notification_helpers')({ admin });
  const LEAD_ROLES = new Set(['director', 'headTeacher', 'deputyHead', 'deanOfStudies', 'hod', 'moderator', 'schoolAdmin']);
  const PRINT_ROLES = new Set([...LEAD_ROLES, 'printOfficer']);
  const EDITABLE = new Set(['draft', 'changesRequested']);
  const MODERATION_DECISIONS = new Set(['approved', 'rejected', 'changesRequested']);

  /**
   * Notifies every staff member holding a lead exam role, generically -
   * question/paper content never appears in title/shortBody, only in
   * metadata.examEntityId + examEntityType for the deep-link router to
   * resolve after its own tenancy/role checks pass.
   */
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

  const clean = (value, max = 160) => String(value ?? '').trim().slice(0, max);
  const requireId = (value, label) => {
    const id = clean(value, 128);
    if (!id) throw new HttpsError('invalid-argument', `${label} is required.`);
    return id;
  };
  const asRoles = (user) => [...new Set([user.role, ...(Array.isArray(user.roles) ? user.roles : [])].filter(Boolean))];
  const isLead = (user) => asRoles(user).some((role) => LEAD_ROLES.has(role));
  const canPrint = (user) => asRoles(user).some((role) => PRINT_ROLES.has(role));

  async function actor(request, institutionId) {
    if (!request.auth) throw new HttpsError('unauthenticated', 'You must be signed in.');
    const userRef = db.collection('users').doc(request.auth.uid);
    const snapshot = await userRef.get();
    const user = snapshot.exists ? snapshot.data() : null;
    if (!user || !user.schoolId || user.schoolId !== institutionId) {
      throw new HttpsError('permission-denied', 'Your active institution does not match this examination.');
    }
    return { uid: request.auth.uid, user, roles: asRoles(user) };
  }

  async function requireTeachingAssignment({ uid, institutionId, classId, subjectId, academicYearId }) {
    const assignments = await db.collection('schools').doc(institutionId)
      .collection('staff_role_assignments')
      .where('userId', '==', uid).where('classId', '==', classId)
      .where('subjectId', '==', subjectId).where('status', '==', 'active').limit(10).get();
    const valid = assignments.docs.some((doc) => !academicYearId || doc.data().academicYearId === academicYearId);
    if (!valid) throw new HttpsError('permission-denied', 'You are not assigned to this class and subject.');
  }

  // Tenant root is schools/{schoolId} - the same root as staff assignments,
  // rooms, marks and the report-card engine - so exam operations, marking
  // and results can read/write those collections directly instead of
  // bridging across two parallel tenant trees. `institutionId` here and
  // `schoolId` elsewhere in the codebase are the same value.
  const seriesRef = (institutionId, seriesId) => db.collection('schools').doc(institutionId).collection('exam_factory_series').doc(seriesId);
  const questionRef = (institutionId, questionId) => db.collection('schools').doc(institutionId).collection('exam_factory_questions').doc(questionId);
  const paperRef = (institutionId, paperId) => db.collection('schools').doc(institutionId).collection('exam_factory_papers').doc(paperId);
  const printJobRef = (institutionId, jobId) => db.collection('schools').doc(institutionId).collection('exam_factory_print_jobs').doc(jobId);
  const auditRef = (institutionId, id) => db.collection('schools').doc(institutionId).collection('exam_factory_audit').doc(id);
  async function audit(institutionId, id, data) {
    await auditRef(institutionId, id).set({ institutionId, ...data, at: FieldValue.serverTimestamp() }, { merge: true });
  }

  async function loadBranding(institutionId) {
    const doc = await db.collection('schools').doc(institutionId).collection('config').doc('institution_profile').get();
    const data = doc.exists ? doc.data() : {};
    return { schoolName: data.name || data.displayName || '' };
  }

  const asDate = (value) => {
    const date = new Date(clean(value, 40));
    return Number.isNaN(date.getTime()) ? null : date;
  };

  const api = {};

  api.saveExamSeries = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const seriesId = requireId(data.seriesId, 'Series');
    const source = await actor(request, institutionId);
    if (!isLead(source.user)) throw new HttpsError('permission-denied', 'Exam series permission is required.');
    const startDate = asDate(data.startDate);
    const endDate = asDate(data.endDate);
    if (!startDate || !endDate || endDate < startDate) throw new HttpsError('invalid-argument', 'A valid start and end date are required.');
    const name = clean(data.name, 160);
    if (!name) throw new HttpsError('invalid-argument', 'Series name is required.');
    const ref = seriesRef(institutionId, seriesId);
    const prior = await ref.get();
    const deadlineFields = ['questionDeadline', 'moderationDeadline', 'paperApprovalDeadline', 'printingDeadline', 'markingDeadline', 'resultPublicationDate'];
    const deadlines = {};
    for (const field of deadlineFields) {
      if (data[field] !== undefined && data[field] !== null) {
        const parsed = asDate(data[field]);
        if (!parsed) throw new HttpsError('invalid-argument', `${field} is not a valid date.`);
        deadlines[field] = admin.firestore.Timestamp.fromDate(parsed);
      }
    }
    const classIds = Array.isArray(data.classIds) ? data.classIds.map((id) => clean(id, 128)).filter(Boolean) : [];
    const subjectIds = Array.isArray(data.subjectIds) ? data.subjectIds.map((id) => clean(id, 128)).filter(Boolean) : [];
    await ref.set({
      institutionId,
      name,
      academicYear: clean(data.academicYear, 20),
      term: clean(data.term, 40),
      type: clean(data.type, 40) || 'midterm',
      startDate: admin.firestore.Timestamp.fromDate(startDate),
      endDate: admin.firestore.Timestamp.fromDate(endDate),
      classIds,
      subjectIds,
      gradingScaleId: clean(data.gradingScaleId, 128),
      paperTemplateId: clean(data.paperTemplateId, 128),
      status: prior.exists ? prior.data().status : 'draft',
      ...deadlines,
      createdBy: prior.exists ? prior.data().createdBy : source.uid,
      createdAt: prior.exists ? prior.data().createdAt : FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    await audit(institutionId, `series-save-${seriesId}-${clean(data.operationId, 'latest')}`, { action: 'series_saved', actorId: source.uid, seriesId });
    return { seriesId };
  });

  api.saveExamQuestionDraft = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const questionId = requireId(data.questionId, 'Question');
    const classId = requireId(data.classId, 'Class');
    const subjectId = requireId(data.subjectId, 'Subject');
    const source = await actor(request, institutionId);
    if (!isLead(source.user)) await requireTeachingAssignment({ uid: source.uid, institutionId, classId, subjectId, academicYearId: clean(data.academicYearId) });
    const ref = questionRef(institutionId, questionId);
    const prior = await ref.get();
    if (prior.exists && prior.data().creatorId !== source.uid && !isLead(source.user)) throw new HttpsError('permission-denied', 'Only the question creator may edit this draft.');
    if (prior.exists && !EDITABLE.has(prior.data().status)) throw new HttpsError('failed-precondition', 'Approved or used questions require a new version.');
    const marks = Number(data.marks);
    if (!Number.isFinite(marks) || marks <= 0 || marks > 100) throw new HttpsError('invalid-argument', 'Marks must be between 1 and 100.');
    const difficulty = ['easy', 'medium', 'hard'].includes(data.difficulty) ? data.difficulty : 'medium';
    await ref.set({
      institutionId,
      seriesId: requireId(data.seriesId, 'Exam series'),
      classId,
      subjectId,
      topic: clean(data.topic),
      type: clean(data.type, 40),
      text: clean(data.text, 12000),
      marks,
      difficulty,
      suggestedAnswer: clean(data.suggestedAnswer, 4000),
      markingGuide: clean(data.markingGuide, 4000),
      teacherNotes: clean(data.teacherNotes, 2000),
      attachmentUrls: Array.isArray(data.attachmentUrls) ? data.attachmentUrls.map((url) => clean(url, 1024)).filter(Boolean).slice(0, 10) : [],
      creatorId: prior.exists ? prior.data().creatorId : source.uid,
      status: 'draft',
      version: prior.exists ? Number(prior.data().version || 1) : 1,
      updatedAt: FieldValue.serverTimestamp(),
      createdAt: prior.exists ? prior.data().createdAt : FieldValue.serverTimestamp(),
    }, { merge: true });
    await audit(institutionId, `question-draft-${questionId}-${clean(data.operationId, 'latest')}`, { action: 'question_draft_saved', actorId: source.uid, questionId });
    return { questionId, status: 'draft' };
  });

  api.submitExamQuestion = onCall(async (request) => {
    const data = request.data || {}; const institutionId = requireId(data.institutionId, 'Institution'); const questionId = requireId(data.questionId, 'Question');
    const source = await actor(request, institutionId); const ref = questionRef(institutionId, questionId); const snap = await ref.get();
    if (!snap.exists) throw new HttpsError('not-found', 'Question not found.');
    const question = snap.data();
    if (question.creatorId !== source.uid) throw new HttpsError('permission-denied', 'Only the question creator may submit it.');
    await requireTeachingAssignment({ uid: source.uid, institutionId, classId: question.classId, subjectId: question.subjectId, academicYearId: clean(data.academicYearId) });
    if (!EDITABLE.has(question.status)) throw new HttpsError('failed-precondition', 'This question cannot be submitted from its current state.');
    const status = question.status === 'changesRequested' ? 'resubmitted' : 'submitted';
    await ref.update({ status, submittedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    await audit(institutionId, `question-submit-${questionId}-${clean(data.operationId, status)}`, { action: 'question_submitted', actorId: source.uid, questionId, status });
    await notifyExamLeads(institutionId, {
      type: 'examQuestionModeration',
      title: 'New question awaiting moderation',
      shortBody: 'A submitted exam question is ready for your review.',
      entityId: questionId,
      entityType: 'question',
      idempotencyKey: `q-submit-${questionId}-${status}`,
    });
    return { questionId, status };
  });

  api.moderateExamQuestion = onCall(async (request) => {
    const data = request.data || {}; const institutionId = requireId(data.institutionId, 'Institution'); const questionId = requireId(data.questionId, 'Question'); const decision = clean(data.decision, 40);
    const source = await actor(request, institutionId); if (!isLead(source.user)) throw new HttpsError('permission-denied', 'Moderation permission is required.');
    if (!MODERATION_DECISIONS.has(decision)) throw new HttpsError('invalid-argument', 'Invalid moderation decision.');
    const ref = questionRef(institutionId, questionId); const snap = await ref.get(); if (!snap.exists) throw new HttpsError('not-found', 'Question not found.');
    if (!['submitted', 'resubmitted', 'underReview'].includes(snap.data().status)) throw new HttpsError('failed-precondition', 'Question is not ready for moderation.');
    await ref.update({ status: decision, moderationComment: clean(data.comment, 2000), moderatedBy: source.uid, moderatedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    await audit(institutionId, `question-moderate-${questionId}-${clean(data.operationId, decision)}`, { action: 'question_moderated', actorId: source.uid, questionId, decision });
    const decisionCopy = {
      approved: 'Your submitted question was approved.',
      rejected: 'Your submitted question was rejected. See the moderation comment for details.',
      changesRequested: 'Changes were requested on your submitted question.',
    };
    await notifyExamUser(institutionId, snap.data().creatorId, {
      type: 'examQuestionModeration',
      title: decision === 'approved' ? 'Question approved' : decision === 'rejected' ? 'Question rejected' : 'Changes requested',
      shortBody: decisionCopy[decision] || 'Your question moderation status has changed.',
      entityId: questionId,
      entityType: 'question',
      idempotencyKey: `q-moderate-${questionId}-${decision}`,
    });
    return { questionId, status: decision };
  });

  api.saveExamPaper = onCall(async (request) => {
    const data = request.data || {}; const institutionId = requireId(data.institutionId, 'Institution'); const paperId = requireId(data.paperId, 'Paper'); const source = await actor(request, institutionId);
    if (!isLead(source.user)) throw new HttpsError('permission-denied', 'Paper-builder permission is required.');
    const questionIds = [...new Set(Array.isArray(data.questionIds) ? data.questionIds.map((id) => clean(id, 128)).filter(Boolean) : [])];
    const targetMarks = Number(data.targetMarks), totalMarks = Number(data.totalMarks);
    if (!Number.isFinite(targetMarks) || targetMarks <= 0 || !Number.isFinite(totalMarks)) throw new HttpsError('invalid-argument', 'Paper marks are invalid.');
    const refs = questionIds.map((id) => questionRef(institutionId, id)); const questions = refs.length ? await db.getAll(...refs) : [];
    if (questions.some((snap) => !snap.exists || !['approved', 'usedInPaper'].includes(snap.data().status))) throw new HttpsError('failed-precondition', 'Papers may contain approved questions only.');
    const ref = paperRef(institutionId, paperId); const prior = await ref.get();
    if (prior.exists && ['locked', 'printReady', 'printed', 'administered'].includes(prior.data().status)) throw new HttpsError('failed-precondition', 'Locked papers require an authorized new version.');
    const durationMinutes = Number(data.durationMinutes); const duration = Number.isFinite(durationMinutes) && durationMinutes > 0 ? durationMinutes : (prior.exists ? Number(prior.data().durationMinutes || 60) : 60);
    const priorQuestionIds = prior.exists ? Array.from(prior.data().questionIds || []) : [];
    const isEdit = prior.exists && JSON.stringify([...priorQuestionIds].sort()) !== JSON.stringify([...questionIds].sort());
    const batch = db.batch();
    batch.set(ref, { institutionId, seriesId: requireId(data.seriesId, 'Exam series'), classId: requireId(data.classId, 'Class'), subjectId: requireId(data.subjectId, 'Subject'), title: clean(data.title, 200), targetMarks, totalMarks, durationMinutes: duration, questionIds, status: prior.exists ? prior.data().status : 'draft', version: prior.exists && isEdit ? Number(prior.data().version || 1) + 1 : (prior.exists ? Number(prior.data().version || 1) : 1), updatedAt: FieldValue.serverTimestamp(), createdAt: prior.exists ? prior.data().createdAt : FieldValue.serverTimestamp() }, { merge: true });
    for (const id of questionIds) batch.update(questionRef(institutionId, id), { status: 'usedInPaper', updatedAt: FieldValue.serverTimestamp() });
    await batch.commit();
    await audit(institutionId, `paper-save-${paperId}-${clean(data.operationId, 'latest')}`, { action: 'paper_saved', actorId: source.uid, paperId });
    return { paperId };
  });

  api.requestExamPaperApproval = onCall(async (request) => {
    const data = request.data || {}; const institutionId = requireId(data.institutionId, 'Institution'); const paperId = requireId(data.paperId, 'Paper'); const source = await actor(request, institutionId);
    if (!isLead(source.user)) throw new HttpsError('permission-denied', 'Paper approval permission is required.');
    const ref = paperRef(institutionId, paperId); const snap = await ref.get(); if (!snap.exists) throw new HttpsError('not-found', 'Paper not found.'); const paper = snap.data();
    if (Number(paper.targetMarks) !== Number(paper.totalMarks)) throw new HttpsError('failed-precondition', 'Paper total must equal target marks.');
    await ref.update({ status: 'readyForApproval', requestedApprovalBy: source.uid, requestedApprovalAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    await audit(institutionId, `paper-approval-${paperId}-${clean(data.operationId, 'latest')}`, { action: 'paper_approval_requested', actorId: source.uid, paperId, role: source.roles[0] || '' });
    await notifyExamLeads(institutionId, {
      type: 'examPaperWorkflow',
      title: 'Paper awaiting approval',
      shortBody: 'An exam paper is ready for your approval.',
      entityId: paperId,
      entityType: 'paper',
      idempotencyKey: `paper-approval-request-${paperId}-${clean(data.operationId, 'latest')}`,
    });
    return { paperId, status: 'readyForApproval' };
  });

  api.approveExamPaper = onCall(async (request) => {
    const data = request.data || {}; const institutionId = requireId(data.institutionId, 'Institution'); const paperId = requireId(data.paperId, 'Paper'); const source = await actor(request, institutionId);
    if (!isLead(source.user)) throw new HttpsError('permission-denied', 'Paper approval permission is required.');
    const ref = paperRef(institutionId, paperId); const snap = await ref.get(); if (!snap.exists) throw new HttpsError('not-found', 'Paper not found.'); const paper = snap.data();
    if (paper.status !== 'readyForApproval') throw new HttpsError('failed-precondition', 'Paper must be submitted for approval first.');
    if (Number(paper.targetMarks) !== Number(paper.totalMarks)) throw new HttpsError('failed-precondition', 'Paper total must equal target marks.');
    await ref.update({ status: 'approved', approvedBy: source.uid, approvedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    await audit(institutionId, `paper-decision-${paperId}-${clean(data.operationId, 'latest')}`, { action: 'paper_approved', actorId: source.uid, role: source.roles[0] || '', paperId, version: paper.version, comment: clean(data.comment, 2000) });
    if (paper.requestedApprovalBy) {
      await notifyExamUser(institutionId, paper.requestedApprovalBy, {
        type: 'examPaperWorkflow',
        title: 'Paper approval completed',
        shortBody: 'The exam paper you submitted has been approved.',
        entityId: paperId,
        entityType: 'paper',
        idempotencyKey: `paper-approved-${paperId}-v${paper.version}`,
      });
    }
    return { paperId, status: 'approved' };
  });

  api.lockExamPaper = onCall(async (request) => {
    const data = request.data || {}; const institutionId = requireId(data.institutionId, 'Institution'); const paperId = requireId(data.paperId, 'Paper'); const source = await actor(request, institutionId);
    if (!isLead(source.user)) throw new HttpsError('permission-denied', 'Paper-lock permission is required.');
    const ref = paperRef(institutionId, paperId); const snap = await ref.get(); if (!snap.exists) throw new HttpsError('not-found', 'Paper not found.');
    if (snap.data().status !== 'approved') throw new HttpsError('failed-precondition', 'Only approved papers may be locked.');
    await ref.update({ status: 'locked', lockedBy: source.uid, lockedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    await audit(institutionId, `paper-lock-${paperId}-${clean(data.operationId, 'latest')}`, { action: 'paper_locked', actorId: source.uid, role: source.roles[0] || '', paperId, version: snap.data().version });
    return { paperId, status: 'locked' };
  });

  /**
   * Renders the controlled question-paper and marking-guide PDFs for a
   * locked paper and stores them under the protected Storage path. Only
   * approved+locked papers may be rendered - printing an unapproved draft
   * is never possible even for a lead role. Idempotent per paper version:
   * re-generating the same locked version returns the existing files
   * instead of re-rendering, so repeated clicks never multiply audit noise
   * or invalidate a download link already handed to the print officer.
   */
  api.generateExamPaperFiles = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const paperId = requireId(data.paperId, 'Paper');
    const source = await actor(request, institutionId);
    if (!canPrint(source.user)) throw new HttpsError('permission-denied', 'Print permission is required.');
    const ref = paperRef(institutionId, paperId);
    const snap = await ref.get();
    if (!snap.exists) throw new HttpsError('not-found', 'Paper not found.');
    const paper = { id: paperId, ...snap.data() };
    if (!['locked', 'printReady', 'printed', 'administered'].includes(paper.status)) {
      throw new HttpsError('failed-precondition', 'Only a locked, approved paper may be prepared for printing.');
    }
    const version = Number(paper.version || 1);
    if (paper.generatedFilesVersion === version && paper.questionPaperPath && paper.markingGuidePath) {
      return { paperId, questionPaperPath: paper.questionPaperPath, markingGuidePath: paper.markingGuidePath, version };
    }

    const seriesSnap = await seriesRef(institutionId, paper.seriesId).get();
    if (!seriesSnap.exists) throw new HttpsError('failed-precondition', 'The paper\'s exam series could not be found.');
    const series = seriesSnap.data();

    const questionIds = Array.isArray(paper.questionIds) ? paper.questionIds : [];
    const refs = questionIds.map((id) => questionRef(institutionId, id));
    const questionDocs = refs.length ? await db.getAll(...refs) : [];
    const questions = questionDocs.filter((d) => d.exists).map((d) => d.data());
    if (questions.length !== questionIds.length) {
      throw new HttpsError('failed-precondition', 'One or more questions on this paper could not be found.');
    }

    const branding = await loadBranding(institutionId);
    const confidential = clean(data.watermark, 40) || 'CONFIDENTIAL';

    const questionPdf = await renderExamPaperPdf({ paper, series, questions, branding, mode: 'question', watermarkLabel: confidential });
    const guidePdf = await renderExamPaperPdf({ paper, series, questions, branding, mode: 'guide', watermarkLabel: 'MARKING GUIDE — CONFIDENTIAL' });

    const questionPaperPath = `schools/${institutionId}/exam_factory/${paper.seriesId}/${paperId}/question-paper-v${version}.pdf`;
    const markingGuidePath = `schools/${institutionId}/exam_factory/${paper.seriesId}/${paperId}/marking-guide-v${version}.pdf`;
    const bucket = admin.storage().bucket();
    await bucket.file(questionPaperPath).save(questionPdf, { resumable: false, contentType: 'application/pdf', metadata: { cacheControl: 'private, max-age=0' } });
    await bucket.file(markingGuidePath).save(guidePdf, { resumable: false, contentType: 'application/pdf', metadata: { cacheControl: 'private, max-age=0' } });
    const questionPaperChecksum = createHash('sha256').update(questionPdf).digest('hex');
    const markingGuideChecksum = createHash('sha256').update(guidePdf).digest('hex');

    await ref.update({
      questionPaperPath,
      markingGuidePath,
      generatedFilesVersion: version,
      generatedFilesBy: source.uid,
      generatedFilesAt: FieldValue.serverTimestamp(),
      status: paper.status === 'locked' ? 'printReady' : paper.status,
      updatedAt: FieldValue.serverTimestamp(),
    });
    await audit(institutionId, `paper-files-${paperId}-v${version}`, {
      action: 'paper_files_generated',
      actorId: source.uid,
      role: source.roles[0] || '',
      paperId,
      version,
      questionPaperChecksum,
      markingGuideChecksum,
    });
    return { paperId, questionPaperPath, markingGuidePath, version };
  });

  /**
   * Returns a short-lived signed URL for a generated file and records the
   * download in the audit trail. Never hands back a URL for a file that has
   * not actually been generated for the paper's *current* version, so a
   * stale link from a prior version can never leak the wrong marking guide.
   */
  api.getExamPaperDownloadUrl = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const paperId = requireId(data.paperId, 'Paper');
    const fileType = clean(data.fileType, 20);
    if (!['questionPaper', 'markingGuide'].includes(fileType)) throw new HttpsError('invalid-argument', 'fileType must be questionPaper or markingGuide.');
    const source = await actor(request, institutionId);
    if (!canPrint(source.user)) throw new HttpsError('permission-denied', 'Print permission is required.');
    const snap = await paperRef(institutionId, paperId).get();
    if (!snap.exists) throw new HttpsError('not-found', 'Paper not found.');
    const paper = snap.data();
    const path = fileType === 'questionPaper' ? paper.questionPaperPath : paper.markingGuidePath;
    if (!path || paper.generatedFilesVersion !== Number(paper.version || 1)) {
      throw new HttpsError('failed-precondition', 'This file has not been generated for the current paper version.');
    }
    const [url] = await admin.storage().bucket().file(path).getSignedUrl({ action: 'read', expires: Date.now() + 10 * 60 * 1000 });
    await audit(institutionId, `paper-download-${paperId}-${clean(data.operationId, `${fileType}-${Date.now()}`)}`, {
      action: 'paper_file_downloaded',
      actorId: source.uid,
      role: source.roles[0] || '',
      paperId,
      fileType,
      version: paper.generatedFilesVersion,
    });
    return { url };
  });

  /**
   * Starts a controlled print job. Only locked+print-ready papers with
   * files already generated for their current version may be printed.
   */
  api.recordExamPrintJob = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const paperId = requireId(data.paperId, 'Paper');
    const source = await actor(request, institutionId);
    if (!canPrint(source.user)) throw new HttpsError('permission-denied', 'Print permission is required.');
    const paperSnap = await paperRef(institutionId, paperId).get();
    if (!paperSnap.exists) throw new HttpsError('not-found', 'Paper not found.');
    const paper = paperSnap.data();
    if (!['printReady', 'printed', 'administered'].includes(paper.status)) {
      throw new HttpsError('failed-precondition', 'Controlled files must be generated before a print job can start.');
    }
    if (paper.generatedFilesVersion !== Number(paper.version || 1)) {
      throw new HttpsError('failed-precondition', 'Generated files are stale for the current paper version.');
    }
    const copies = Number(data.copies);
    if (!Number.isFinite(copies) || copies <= 0 || copies > 2000) throw new HttpsError('invalid-argument', 'Copy count must be between 1 and 2000.');
    const extraCopies = Number.isFinite(Number(data.extraCopies)) ? Math.max(0, Number(data.extraCopies)) : 0;
    const isReprint = Boolean(data.isReprint);
    if (isReprint && !clean(data.reprintReason)) throw new HttpsError('invalid-argument', 'A reprint reason is required.');

    const jobId = clean(data.jobId, 128) || db.collection('_ids').doc().id;
    const jobRef = printJobRef(institutionId, jobId);
    await jobRef.set({
      institutionId,
      paperId,
      seriesId: paper.seriesId,
      version: paper.generatedFilesVersion,
      copies,
      extraCopies,
      printer: clean(data.printer, 200),
      paperSize: clean(data.paperSize, 20) || 'A4',
      duplex: Boolean(data.duplex),
      includeQuestionPaper: data.includeQuestionPaper !== false,
      includeMarkingGuide: Boolean(data.includeMarkingGuide),
      watermark: clean(data.watermark, 40) || 'CONFIDENTIAL',
      isReprint,
      reprintReason: clean(data.reprintReason, 500),
      status: 'started',
      initiatedBy: source.uid,
      initiatedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    await paperRef(institutionId, paperId).update({ status: 'printed', updatedAt: FieldValue.serverTimestamp() });
    await audit(institutionId, `print-start-${jobId}`, {
      action: 'print_job_started',
      actorId: source.uid,
      role: source.roles[0] || '',
      paperId,
      jobId,
      copies,
      extraCopies,
      isReprint,
      reprintReason: clean(data.reprintReason, 500),
    });
    return { jobId, status: 'started' };
  });

  api.completeExamPrintJob = onCall(async (request) => {
    const data = request.data || {};
    const institutionId = requireId(data.institutionId, 'Institution');
    const jobId = requireId(data.jobId, 'Print job');
    const source = await actor(request, institutionId);
    if (!canPrint(source.user)) throw new HttpsError('permission-denied', 'Print permission is required.');
    const ref = printJobRef(institutionId, jobId);
    const snap = await ref.get();
    if (!snap.exists) throw new HttpsError('not-found', 'Print job not found.');
    if (snap.data().status !== 'started') throw new HttpsError('failed-precondition', 'Print job is not in progress.');
    await ref.update({ status: 'completed', completedBy: source.uid, completedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    await audit(institutionId, `print-complete-${jobId}`, { action: 'print_job_completed', actorId: source.uid, role: source.roles[0] || '', jobId, paperId: snap.data().paperId });
    return { jobId, status: 'completed' };
  });

  return api;
};
