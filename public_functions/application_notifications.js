const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const admin = require('firebase-admin');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

function text(value, max = 180) {
  return String(value ?? '').trim().slice(0, max);
}

async function getOwnerDocs() {
  const byRole = await db.collection('users').where('role', '==', 'superAdmin').get();
  const owners = new Map();
  byRole.docs.forEach((doc) => owners.set(doc.id, doc));

  // Support owner records that use a roles array instead of a single role field.
  const byRoles = await db.collection('users').where('roles', 'array-contains', 'superAdmin').get();
  byRoles.docs.forEach((doc) => owners.set(doc.id, doc));
  return [...owners.values()];
}

async function pushToOwner(ownerDoc, notification, data) {
  const owner = ownerDoc.data() || {};
  if (owner.isActive === false) return;

  const tokensSnapshot = await ownerDoc.ref.collection('tokens').get();
  const tokenEntries = tokensSnapshot.docs
    .map((doc) => ({
      doc,
      token: text(doc.data()?.token || doc.id, 4096),
    }))
    .filter((entry) => Boolean(entry.token));

  if (tokenEntries.length === 0) return;

  try {
    const response = await admin.messaging().sendEachForMulticast({
      tokens: tokenEntries.slice(0, 500).map((entry) => entry.token),
      notification,
      data,
    });

    const removals = [];
    response.responses.forEach((result, index) => {
      if (result.success) return;
      const code = result.error?.code || '';
      if (
        code === 'messaging/registration-token-not-registered' ||
        code === 'messaging/invalid-registration-token'
      ) {
        const entry = tokenEntries[index];
        if (entry) removals.push(entry.doc.ref.delete());
      }
    });
    await Promise.all(removals);
  } catch (error) {
    // Application submission must never fail because push delivery failed.
    console.error('Failed to push school application alert', data.applicationId, error);
  }
}

/**
 * Notify every active SaaS Owner when a school finishes website onboarding and
 * submits a new application for review.
 *
 * The Firestore alert is the source of truth for the in-app notification. FCM
 * is best-effort so simulator/APNs issues can never lose the application.
 */
exports.notifyOwnerOfSchoolApplication = onDocumentCreated(
  {
    region: 'europe-west1',
    document: 'public_school_applications/{applicationId}',
  },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const application = snapshot.data() || {};
    const applicationId = event.params.applicationId;
    if (String(application.status || '') !== 'pending_review') return;

    const schoolName = text(application.school?.name, 160) || 'A school';
    const plan = text(application.plan, 60) || 'School Pulse';
    const district = text(application.location?.district, 100);
    const adminName = [
      text(application.administrator?.firstName, 80),
      text(application.administrator?.lastName, 80),
    ].filter(Boolean).join(' ');

    const ownerDocs = await getOwnerDocs();
    if (ownerDocs.length === 0) {
      console.warn('School application submitted but no superAdmin user document was found.', applicationId);
      return;
    }

    const bodyParts = [`${schoolName} submitted a new school application`, plan];
    if (district) bodyParts.push(district);

    await Promise.all(
      ownerDocs.map(async (ownerDoc) => {
        const owner = ownerDoc.data() || {};
        if (owner.isActive === false) return;

        const alertRef = db.collection('alerts').doc(`school_application_${applicationId}_${ownerDoc.id}`);
        await alertRef.set(
          {
            userId: ownerDoc.id,
            title: 'New school application',
            body: `${schoolName} submitted an application for ${plan}${district ? ` in ${district}` : ''}. Review it in Applications.`,
            data: {
              type: 'school_application',
              applicationId,
              schoolName,
              plan,
              district,
              administratorName: adminName,
            },
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            readBy: [],
            type: 'Direct',
          },
          { merge: true },
        );

        await pushToOwner(
          ownerDoc,
          {
            title: 'New school application',
            body: bodyParts.join(' • '),
          },
          {
            type: 'school_application',
            applicationId,
            schoolName,
          },
        );
      }),
    );
  },
);
