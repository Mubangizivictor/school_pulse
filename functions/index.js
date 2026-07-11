const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { randomBytes } = require("crypto");
const admin = require("firebase-admin");

admin.initializeApp();

// Roles allowed to land on the /staff/admin screen in the app - the same
// set that's allowed to invite new staff.
const ADMIN_ROLES = ["director", "headTeacher", "schoolAdmin"];

const STAFF_ROLES = [
  "director", "headTeacher", "deputyHead", "schoolAdmin", "bursar",
  "classTeacher", "subjectTeacher", "librarian", "nurse", "boardingMatron",
  "transportCoordinator", "guidanceDiscipline", "storeInventory",
  "examsOfficer", "receptionist", "gatekeeper", "securityHead",
  "gamesMaster", "cateringManager",
];

// Excludes visually ambiguous characters (0/O, 1/l/I) since admins read
// this aloud or copy it onto a note for the teacher.
const PASSWORD_CHARS = "ABCDEFGHJKMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz23456789";

function generateTemporaryPassword() {
  const bytes = randomBytes(12);
  let password = "";
  for (let i = 0; i < bytes.length; i++) {
    password += PASSWORD_CHARS[bytes[i] % PASSWORD_CHARS.length];
  }
  return password;
}

exports.createStaffAccount = onCall(async (request) => {
  const auth = request.auth;
  if (!auth) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  const { name, email, role } = request.data || {};
  if (typeof name !== "string" || !name.trim()) {
    throw new HttpsError("invalid-argument", "Name is required.");
  }
  if (typeof email !== "string" || !email.trim()) {
    throw new HttpsError("invalid-argument", "Email is required.");
  }
  if (!STAFF_ROLES.includes(role)) {
    throw new HttpsError("invalid-argument", "Invalid staff role.");
  }

  // The Admin SDK bypasses Firestore rules entirely, so this check is the
  // only gate on who may create staff accounts - it must happen here.
  const callerDoc = await admin.firestore().collection("users").doc(auth.uid).get();
  const callerRole = callerDoc.exists ? callerDoc.data().role : null;
  if (!ADMIN_ROLES.includes(callerRole)) {
    throw new HttpsError("permission-denied", "Only school administrators can create staff accounts.");
  }

  const temporaryPassword = generateTemporaryPassword();

  let userRecord;
  try {
    userRecord = await admin.auth().createUser({
      email: email.trim(),
      password: temporaryPassword,
      displayName: name.trim(),
    });
  } catch (err) {
    if (err.code === "auth/email-already-exists") {
      throw new HttpsError("already-exists", "An account with this email already exists.");
    }
    throw new HttpsError("internal", err.message || "Failed to create the account.");
  }

  await admin.firestore().collection("users").doc(userRecord.uid).set({
    name: name.trim(),
    email: email.trim(),
    role,
    studentIds: [],
    mustChangePassword: true,
    createdBy: auth.uid,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { uid: userRecord.uid, temporaryPassword };
});
