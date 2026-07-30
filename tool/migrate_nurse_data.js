#!/usr/bin/env node

/**
 * Idempotently upgrades the demo Firestore data used by the Nurse module.
 *
 * Dry run: node tool/migrate_nurse_data.js
 * Apply:   node tool/migrate_nurse_data.js --apply
 *
 * Authentication comes from the active gcloud account. The access token is
 * kept in memory and is never printed or written to disk.
 */

const { execFileSync } = require('node:child_process');

const projectId = process.env.FIREBASE_PROJECT_ID || 'school-pulse-3d95b';
const schoolId = process.env.SCHOOL_ID || 'school-pulse-academy';
const shouldApply = process.argv.includes('--apply');
const databaseRoot =
  `https://firestore.googleapis.com/v1/projects/${projectId}` +
  '/databases/(default)/documents';

const token = execFileSync(
  '/opt/homebrew/bin/gcloud',
  ['auth', 'print-access-token'],
  { encoding: 'utf8' },
).trim();

function decodeValue(value) {
  if (!value) return null;
  if ('nullValue' in value) return null;
  if ('stringValue' in value) return value.stringValue;
  if ('booleanValue' in value) return value.booleanValue;
  if ('integerValue' in value) return Number(value.integerValue);
  if ('doubleValue' in value) return Number(value.doubleValue);
  if ('timestampValue' in value) return new Date(value.timestampValue);
  if ('arrayValue' in value) {
    return (value.arrayValue.values || []).map(decodeValue);
  }
  if ('mapValue' in value) {
    return decodeFields(value.mapValue.fields || {});
  }
  return null;
}

function decodeFields(fields) {
  return Object.fromEntries(
    Object.entries(fields || {}).map(([key, value]) => [key, decodeValue(value)]),
  );
}

function encodeValue(value) {
  if (value === null || value === undefined) return { nullValue: null };
  if (value instanceof Date) return { timestampValue: value.toISOString() };
  if (typeof value === 'string') return { stringValue: value };
  if (typeof value === 'boolean') return { booleanValue: value };
  if (typeof value === 'number') {
    return Number.isInteger(value)
      ? { integerValue: String(value) }
      : { doubleValue: value };
  }
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map(encodeValue) } };
  }
  return {
    mapValue: {
      fields: Object.fromEntries(
        Object.entries(value).map(([key, item]) => [key, encodeValue(item)]),
      ),
    },
  };
}

function documentId(document) {
  return document.name.split('/').pop();
}

async function firestoreRequest(url, options = {}) {
  const response = await fetch(url, {
    ...options,
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      ...(options.headers || {}),
    },
  });
  if (!response.ok) {
    const body = await response.text();
    throw new Error(`${options.method || 'GET'} ${url}: ${response.status} ${body}`);
  }
  return response.status === 204 ? null : response.json();
}

async function listDocuments(collection) {
  const documents = [];
  let pageToken;
  do {
    const params = new URLSearchParams({ pageSize: '300' });
    if (pageToken) params.set('pageToken', pageToken);
    const payload = await firestoreRequest(
      `${databaseRoot}/${encodeURIComponent(collection)}?${params}`,
    );
    documents.push(...(payload.documents || []));
    pageToken = payload.nextPageToken;
  } while (pageToken);
  return documents.map((document) => ({
    id: documentId(document),
    data: decodeFields(document.fields),
  }));
}

async function patchDocument(collection, id, fields) {
  if (!shouldApply) return;
  const params = new URLSearchParams();
  for (const field of Object.keys(fields)) {
    params.append('updateMask.fieldPaths', field);
  }
  const encodedFields = Object.fromEntries(
    Object.entries(fields).map(([key, value]) => [key, encodeValue(value)]),
  );
  await firestoreRequest(
    `${databaseRoot}/${encodeURIComponent(collection)}/${encodeURIComponent(id)}?${params}`,
    { method: 'PATCH', body: JSON.stringify({ fields: encodedFields }) },
  );
}

function normalizeUgandaPhone(phone) {
  const digits = String(phone || '').replace(/\D/g, '');
  if (!digits) return '';
  if (digits.startsWith('256')) return `+${digits}`;
  if (digits.startsWith('0')) return `+256${digits.slice(1)}`;
  return `+256${digits}`;
}

async function run() {
  const [users, students, codes, legacyVisits, existingWelfare] =
    await Promise.all([
      listDocuments('users'),
      listDocuments('students'),
      listDocuments('parent_access_codes'),
      listDocuments('health_visits'),
      listDocuments('welfare_records'),
    ]);

  const nurse = users.find((entry) => entry.data.role === 'nurse');
  const matron = users.find((entry) => entry.data.role === 'boardingMatron');
  if (!nurse) throw new Error('No nurse account was found; migration stopped.');

  await patchDocument('schools', schoolId, {
    name: 'School Pulse Academy',
    status: 'active',
    updatedAt: new Date(),
  });

  let userUpdates = 0;
  let contacts = 0;
  for (const user of users) {
    const role = user.data.role || 'subjectTeacher';
    const roles = Array.isArray(user.data.roles) && user.data.roles.length > 0
      ? user.data.roles
      : [role];
    if (role !== 'superAdmin') {
      await patchDocument('users', user.id, { schoolId, roles });
      userUpdates += 1;
    }
    if (!['parent', 'student', 'superAdmin'].includes(role)) {
      await patchDocument('school_contacts', user.id, {
        name: user.data.name || 'School staff',
        role,
        roles,
        schoolId,
        isActive: user.data.isActive !== false,
      });
      contacts += 1;
    }
  }

  for (const student of students) {
    const legacyCode = student.data.studentId || student.id;
    await patchDocument('students', student.id, {
      id: student.id,
      schoolId,
      studentCode: student.data.studentCode || legacyCode,
      admissionNumber: student.data.admissionNumber || legacyCode,
      classId: student.data.classId || student.data.className || '',
      academicYearId: student.data.academicYearId || '2026',
      dateOfBirth: student.data.dateOfBirth || new Date('2000-01-01T00:00:00Z'),
      status: student.data.status || 'active',
      level: student.data.level || 'primary',
    });
  }

  for (const code of codes) {
    await patchDocument('parent_access_codes', code.id, {
      schoolId,
      parentCode: code.data.parentCode || code.data.code || code.id,
      phoneNumber: normalizeUgandaPhone(code.data.phoneNumber),
    });
  }

  for (const visit of legacyVisits) {
    const medication = visit.data.medication;
    const date = visit.data.date instanceof Date
      ? visit.data.date
      : new Date(visit.data.date || Date.now());
    const medicationsGiven = medication && medication !== 'None'
      ? [{
          medicationId: `legacy-${visit.id}`,
          medicationName: String(medication),
          dosage: 'As recorded',
          timeAdministered: date,
          administeredBy: nurse.id,
          notes: 'Migrated from the legacy health log',
        }]
      : [];
    await patchDocument('clinic_visits', `legacy_${visit.id}`, {
      id: `legacy_${visit.id}`,
      schoolId,
      studentId: visit.data.studentId || '',
      dateTime: date,
      reason: visit.data.reason || 'Legacy clinic visit',
      symptoms: visit.data.reason || '',
      treatmentProvided: visit.data.treatment || null,
      medicationsGiven,
      followUpRequired: false,
      outcome: 'VisitOutcome.sentBackToClass',
      recordedBy: nurse.id,
    });
  }

  const inventory = [
    ['paracetamol-500mg', 'Paracetamol 500 mg', 'MedicalItemType.medication', 'Pain relief', 120, 'Tablets', 30],
    ['disposable-gloves', 'Disposable gloves', 'MedicalItemType.supply', 'PPE', 18, 'Pairs', 25],
    ['antiseptic-solution', 'Antiseptic solution', 'MedicalItemType.medication', 'First aid', 8, 'Bottles', 5],
    ['digital-thermometer', 'Digital thermometer', 'MedicalItemType.equipment', 'Equipment', 3, 'Pieces', 2],
  ];
  for (const [id, name, type, category, quantity, unit, reorderLevel] of inventory) {
    await patchDocument('medical_inventory', id, {
      id,
      schoolId,
      name,
      type,
      category,
      quantity,
      unit,
      reorderLevel,
      purchaseDate: new Date(),
    });
  }

  const profileStudents = students.slice(0, 12);
  for (const student of profileStudents) {
    const code = codes.find((entry) =>
      Array.isArray(entry.data.studentIds) &&
      entry.data.studentIds.includes(student.id),
    );
    const profileId = Buffer.from(`${schoolId}:${student.id}`)
      .toString('base64url');
    await patchDocument('health_profiles', profileId, {
      studentId: student.id,
      schoolId,
      bloodGroup: student.id === 's1' ? 'A' : 'Unknown',
      rhesusFactor: student.id === 's1' ? '+' : null,
      allergies: student.id === 's1' ? ['Peanuts'] : [],
      chronicIllnesses: [],
      currentMedications: [],
      emergencyContactName: code?.data.parentName || 'Parent / Guardian',
      emergencyContactPhone: normalizeUgandaPhone(code?.data.phoneNumber),
      vaccinationHistory: [],
    });
  }

  if (existingWelfare.length === 0 && matron) {
    const sampleStudent = students.find((entry) => entry.id === 's2') || students[0];
    if (sampleStudent) {
      await patchDocument('welfare_records', 'nurse-demo-public-welfare', {
        schoolId,
        studentId: sampleStudent.id,
        studentName: sampleStudent.data.name || sampleStudent.id,
        category: 'Sick',
        note: 'Reported feeling unwell during the evening dormitory check.',
        date: new Date(),
        recordedBy: matron.id,
        isPrivate: false,
        gender: sampleStudent.data.gender || '',
      });
    }
  }

  await patchDocument('medical_supply_requests', 'nurse-demo-gloves-request', {
    id: 'nurse-demo-gloves-request',
    schoolId,
    itemName: 'Disposable gloves',
    quantity: 5,
    unit: 'Boxes',
    requestedBy: nurse.id,
    requestDate: new Date(),
    status: 'SupplyRequestStatus.pending',
  });

  console.log(JSON.stringify({
    mode: shouldApply ? 'applied' : 'dry-run',
    projectId,
    schoolId,
    usersToBackfill: userUpdates,
    schoolContacts: contacts,
    studentsToBackfill: students.length,
    parentCodesToBackfill: codes.length,
    clinicVisitsToMigrate: legacyVisits.length,
    healthProfiles: profileStudents.length,
    inventoryItems: inventory.length,
    sampleSupplyRequests: 1,
  }, null, 2));
}

run().catch((error) => {
  console.error(error.message || error);
  process.exitCode = 1;
});
