const { randomBytes, scryptSync, timingSafeEqual } = require("crypto");

const SCRYPT_KEYLEN = 32;
const MAX_FAILED_ATTEMPTS = 5;
const LOCKOUT_MS = 15 * 60 * 1000;

/** Hashes a PIN with a random per-PIN salt. Format: "<saltHex>:<hashHex>". */
function hashPin(pin) {
  const salt = randomBytes(16);
  const derived = scryptSync(String(pin), salt, SCRYPT_KEYLEN);
  return `${salt.toString("hex")}:${derived.toString("hex")}`;
}

/**
 * Verifies a PIN against a stored hash. Also accepts a legacy plaintext
 * value (no ":" separator) for records written before hashing was added -
 * callers should rehash on successful legacy verification.
 */
function verifyPin(pin, stored) {
  if (typeof stored !== "string" || !stored) return { valid: false, legacy: false };
  const sepIndex = stored.indexOf(":");
  if (sepIndex === -1) {
    return { valid: stored === String(pin), legacy: true };
  }
  const saltHex = stored.slice(0, sepIndex);
  const hashHex = stored.slice(sepIndex + 1);
  try {
    const salt = Buffer.from(saltHex, "hex");
    const expected = Buffer.from(hashHex, "hex");
    const derived = scryptSync(String(pin), salt, SCRYPT_KEYLEN);
    if (derived.length !== expected.length) return { valid: false, legacy: false };
    return { valid: timingSafeEqual(derived, expected), legacy: false };
  } catch {
    return { valid: false, legacy: false };
  }
}

/**
 * Throws if the account is currently locked out from too many failed PIN
 * attempts. Call before verifying the PIN.
 */
function assertNotLockedOut(data, HttpsError) {
  const lockedUntil = data.pinLockedUntil;
  const lockedUntilMillis = lockedUntil && typeof lockedUntil.toMillis === "function"
    ? lockedUntil.toMillis()
    : (typeof lockedUntil === "number" ? lockedUntil : 0);
  if (lockedUntilMillis && lockedUntilMillis > Date.now()) {
    const minutes = Math.ceil((lockedUntilMillis - Date.now()) / 60000);
    throw new HttpsError(
      "resource-exhausted",
      `Too many incorrect attempts. Try again in ${minutes} minute${minutes === 1 ? "" : "s"}.`,
    );
  }
}

/** Fields to write after a failed PIN attempt. */
function failedAttemptUpdate(data, admin) {
  const attempts = (Number(data.failedPinAttempts) || 0) + 1;
  const update = { failedPinAttempts: attempts };
  if (attempts >= MAX_FAILED_ATTEMPTS) {
    update.pinLockedUntil = admin.firestore.Timestamp.fromMillis(Date.now() + LOCKOUT_MS);
    update.failedPinAttempts = 0;
  }
  return update;
}

/** Fields to write after a successful PIN attempt, clearing lockout state. */
function clearLockoutUpdate(admin) {
  return { failedPinAttempts: 0, pinLockedUntil: admin.firestore.FieldValue.delete() };
}

module.exports = {
  hashPin,
  verifyPin,
  assertNotLockedOut,
  failedAttemptUpdate,
  clearLockoutUpdate,
  MAX_FAILED_ATTEMPTS,
};
