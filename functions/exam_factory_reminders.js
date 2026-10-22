/**
 * Deadline-based Exam Factory reminders: question-submission deadline,
 * printing deadline, and marking overdue / missing marks. Event-triggered
 * notifications (submission, moderation decisions, approvals, invigilation,
 * results) live in exam_factory.js/exam_factory_operations.js; this module
 * is only for the ones that fire because time passed, not because someone
 * acted - so it runs on a schedule and sweeps every school, the same shape
 * as report_card_release.js's expireLapsedReportCardExceptions.
 */
module.exports = ({ admin, onSchedule }) => {
  if (!onSchedule) return {};

  const db = admin.firestore();
  const FieldValue = admin.firestore.FieldValue;
  const { enqueueNotification } = require('./notification_helpers')({ admin });
  const { recordJobRun } = require('./platform_health_instrumentation')({ admin });
  const LEAD_ROLES = ['director', 'headTeacher', 'deputyHead', 'deanOfStudies', 'hod', 'moderator', 'schoolAdmin'];

  const auditRef = (schoolId, id) => db.collection('schools').doc(schoolId).collection('exam_factory_audit').doc(id);
  async function audit(schoolId, id, data) {
    await auditRef(schoolId, id).set({ schoolId, ...data, at: FieldValue.serverTimestamp() }, { merge: true });
  }

  // A reminder fires at most once per (series/paper, reminder kind) - the
  // audit doc id itself is the dedupe key, since audit() is a merge-set on
  // a deterministic id, matching every other exam_factory idempotency check.
  async function alreadySent(schoolId, key) {
    const snap = await auditRef(schoolId, key).get();
    return snap.exists;
  }

  const api = {};

  api.sendExamFactoryDeadlineReminders = onSchedule('every 6 hours', async () => {
    await recordJobRun('sendExamFactoryDeadlineReminders', 360, async () => {
    const now = admin.firestore.Timestamp.now();
    const soon = admin.firestore.Timestamp.fromMillis(now.toMillis() + 48 * 60 * 60 * 1000);

    const schoolRefs = await db.collection('schools').listDocuments();
    for (const schoolRef of schoolRefs) {
      const schoolId = schoolRef.id;

      // Question-submission deadline within 48 hours, series still
      // collecting questions.
      // eslint-disable-next-line no-await-in-loop
      const seriesSnap = await schoolRef.collection('exam_factory_series')
        .where('status', '==', 'collectingQuestions')
        .where('questionDeadline', '<=', soon)
        .where('questionDeadline', '>', now)
        .get();
      for (const doc of seriesSnap.docs) {
        const key = `reminder-submission-${doc.id}`;
        // eslint-disable-next-line no-await-in-loop
        if (await alreadySent(schoolId, key)) continue;
        // eslint-disable-next-line no-await-in-loop
        await enqueueNotification({
          schoolId,
          recipientRoles: LEAD_ROLES,
          type: 'examPaperWorkflow',
          title: 'Question submission deadline approaching',
          shortBody: 'An exam series’ question-submission deadline is within 48 hours.',
          idempotencyKey: key,
          sourceEntityId: doc.id,
          sourceModule: 'examFactory',
          senderRoleSnapshot: 'Exam Factory',
          metadata: { examEntityId: doc.id, examEntityType: 'series' },
        });
        // eslint-disable-next-line no-await-in-loop
        await audit(schoolId, key, { action: 'reminder_sent', kind: 'submissionDeadline', seriesId: doc.id });
      }

      // Printing deadline within 48 hours, series still printing.
      // eslint-disable-next-line no-await-in-loop
      const printingSnap = await schoolRef.collection('exam_factory_series')
        .where('status', '==', 'printing')
        .where('printingDeadline', '<=', soon)
        .where('printingDeadline', '>', now)
        .get();
      for (const doc of printingSnap.docs) {
        const key = `reminder-printing-${doc.id}`;
        // eslint-disable-next-line no-await-in-loop
        if (await alreadySent(schoolId, key)) continue;
        // eslint-disable-next-line no-await-in-loop
        await enqueueNotification({
          schoolId,
          recipientRoles: [...LEAD_ROLES, 'printOfficer'],
          type: 'examPaperWorkflow',
          title: 'Printing deadline approaching',
          shortBody: 'An exam series’ printing deadline is within 48 hours.',
          idempotencyKey: key,
          sourceEntityId: doc.id,
          sourceModule: 'examFactory',
          senderRoleSnapshot: 'Exam Factory',
          metadata: { examEntityId: doc.id, examEntityType: 'series' },
        });
        // eslint-disable-next-line no-await-in-loop
        await audit(schoolId, key, { action: 'reminder_sent', kind: 'printingDeadline', seriesId: doc.id });
      }

      // Marking overdue / missing marks: series past its markingDeadline
      // with a locked+printed paper that still has draft (unsubmitted)
      // marks. One reminder per paper, sent to the markers who have
      // entries on it plus leads, so both know marking is behind.
      // eslint-disable-next-line no-await-in-loop
      const overdueSeriesSnap = await schoolRef.collection('exam_factory_series')
        .where('markingDeadline', '<=', now)
        .get();
      for (const seriesDoc of overdueSeriesSnap.docs) {
        // eslint-disable-next-line no-await-in-loop
        const papersSnap = await schoolRef.collection('exam_factory_papers')
          .where('seriesId', '==', seriesDoc.id)
          .where('status', 'in', ['printed', 'administered'])
          .get();
        for (const paperDoc of papersSnap.docs) {
          const key = `reminder-marking-overdue-${paperDoc.id}`;
          // eslint-disable-next-line no-await-in-loop
          if (await alreadySent(schoolId, key)) continue;
          // eslint-disable-next-line no-await-in-loop
          const draftMarks = await schoolRef.collection('exam_factory_marks')
            .where('paperId', '==', paperDoc.id)
            .where('status', '==', 'draft')
            .limit(1)
            .get();
          if (draftMarks.empty) continue;
          // eslint-disable-next-line no-await-in-loop
          await enqueueNotification({
            schoolId,
            recipientRoles: LEAD_ROLES,
            type: 'examPaperWorkflow',
            title: 'Marking overdue',
            shortBody: 'Marking for an exam paper is overdue and has unsubmitted marks.',
            idempotencyKey: key,
            sourceEntityId: paperDoc.id,
            sourceModule: 'examFactory',
            senderRoleSnapshot: 'Exam Factory',
            metadata: { examEntityId: paperDoc.id, examEntityType: 'paper' },
          });
          // eslint-disable-next-line no-await-in-loop
          await audit(schoolId, key, { action: 'reminder_sent', kind: 'markingOverdue', paperId: paperDoc.id });
        }
      }
    }
    });
  });

  return api;
};
