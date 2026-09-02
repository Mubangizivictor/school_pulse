const { onCall, HttpsError } = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const { requirePlatformOwner, OwnerAuthorizationError } = require('./vendor/owner-auth');

if (!admin.apps.length) admin.initializeApp();
const db = admin.firestore();

async function owner(request) {
  try {
    return await requirePlatformOwner(request, { db });
  } catch (error) {
    if (error instanceof OwnerAuthorizationError) throw new HttpsError(error.code, error.message);
    throw error;
  }
}

// Mirrors kStatusGroups[StudentStatusGroup.active] in
// lib/features/student/presentation/screens/admin_students_dashboard_screen.dart
// - the one place "active enrollment" is already defined in this app. Do not
// diverge from this list; if that Dart map changes, update this one to match.
const ACTIVE_STUDENT_STATUSES = ['active', 'enrolled'];

// "Staff" = every UserRole (lib/core/user_roles.dart) except parent/student/
// superAdmin - ~24 roles, too many for a Firestore array-contains-any filter
// (max 10 values). UserModel.toJson always writes the legacy singular
// `role` field as roles.first.name (lib/features/auth/data/models/
// user_model.dart:149) alongside the roles array, and parent/student
// accounts never carry a staff role, so filtering the 2-value exclusion
// list on that reliable singular field is equivalent to "any staff role"
// without needing all 24 names enumerated here.
const NON_STAFF_ROLES = ['parent', 'student'];

// School Overview's Students/Staff metric tile. Runs count() aggregation
// queries via the Admin SDK rather than exposing student/staff documents to
// the client - firestore.rules gives Super Admin no direct read access to
// `students` or `users` (by design, since those rules are the tenant-privacy
// boundary for those collections), and a maintained counter field would need
// new trigger infrastructure this app doesn't have. A live count() query is
// simplest and always accurate for a screen that's read on-demand /
// pull-to-refresh, not streamed.
exports.getSchoolCounts = onCall({ region: 'europe-west1' }, async (request) => {
  await owner(request);
  const schoolId = String(request.data?.schoolId || '').trim();
  if (!schoolId) throw new HttpsError('invalid-argument', 'A school ID is required.');

  const studentsQuery = db.collection('students')
    .where('schoolId', '==', schoolId)
    .where('status', 'in', ACTIVE_STUDENT_STATUSES);
  const staffQuery = db.collection('users')
    .where('schoolId', '==', schoolId)
    .where('role', 'not-in', NON_STAFF_ROLES)
    .where('isActive', '==', true);

  const [studentsCount, staffCount] = await Promise.all([
    studentsQuery.count().get(),
    staffQuery.count().get(),
  ]);

  return {
    schoolId,
    studentCount: studentsCount.data().count,
    staffCount: staffCount.data().count,
    updatedAt: Date.now(),
  };
});

exports.__test__ = { ACTIVE_STUDENT_STATUSES, NON_STAFF_ROLES };
