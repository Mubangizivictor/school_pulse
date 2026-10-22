/**
 * Read-only backup of every Structure/Curriculum/Timetable collection for
 * one schoolId. Two storage shapes exist and are both covered:
 *  - Top-level collections filtered by a `schoolId` field
 *    (structure_remote_data_source.dart CollectionReference getters,
 *    plus structure_curriculum_assignments / structure_teaching_assignments)
 *  - Subcollections nested under schools/{schoolId}/... (config docs,
 *    timetables, timetable_lessons - per structure_remote_data_source.dart's
 *    _*Doc() getters and timetable_remote_data_source.dart's _school()).
 *
 * Writes one timestamped JSON file capturing doc id + full field data per
 * collection, so a real restore is possible if seeding ever needs reverting.
 *
 * Run: node functions/scripts/backup_school_structure.js <schoolId>
 */
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

const schoolId = process.argv[2];
if (!schoolId) {
  console.error('Usage: node backup_school_structure.js <schoolId>');
  process.exit(1);
}

admin.initializeApp({ projectId: 'school-pulse-3d95b' });
const db = admin.firestore();

// Top-level collections filtered by the `schoolId` field.
const FIELD_FILTERED_COLLECTIONS = [
  'educational_levels',
  'academic_years',
  'academic_terms',
  'classes',
  'class_streams',
  'subjects',
  'departments',
  'staff_designations',
  'campuses',
  'houses',
  'clubs',
  'facilities',
  'hostels',
  'hostel_rooms',
  'transport_routes',
  'transport_stops',
  'transport_vehicles',
  'structure_fee_categories',
  'structure_assessment_types',
  'structure_grading_systems',
  'grade_bands',
  'attendance_types',
  'attendance_sessions',
  'announcement_categories',
  'notification_categories',
  'message_templates',
  'document_templates',
  'custom_fields',
  'structure_curriculum_assignments',
  'structure_teaching_assignments',
];

// Subcollections nested under schools/{schoolId}/...
const SCHOOL_SUBCOLLECTIONS = ['timetables', 'timetable_lessons'];

// Singleton config docs at schools/{schoolId}/config/{docId}.
const CONFIG_DOC_IDS = [
  'feature_toggles',
  'institution_profile',
  'timetable_config',
  'attendance_defaults',
  'communication_defaults',
];

async function backupFieldFiltered(name) {
  const snap = await db.collection(name).where('schoolId', '==', schoolId).get();
  return snap.docs.map((d) => ({ id: d.id, data: d.data() }));
}

async function backupSubcollection(name) {
  const snap = await db.collection('schools').doc(schoolId).collection(name).get();
  return snap.docs.map((d) => ({ id: d.id, data: d.data() }));
}

async function main() {
  const result = {
    schoolId,
    backedUpAt: new Date().toISOString(),
    collections: {},
    schoolSubcollections: {},
    config: {},
  };

  for (const name of FIELD_FILTERED_COLLECTIONS) {
    try {
      result.collections[name] = await backupFieldFiltered(name);
      console.log(`${name}: ${result.collections[name].length} docs`);
    } catch (e) {
      console.log(`${name}: SKIPPED (${e.message})`);
      result.collections[name] = { error: e.message };
    }
  }

  for (const name of SCHOOL_SUBCOLLECTIONS) {
    try {
      result.schoolSubcollections[name] = await backupSubcollection(name);
      console.log(`schools/${schoolId}/${name}: ${result.schoolSubcollections[name].length} docs`);
    } catch (e) {
      console.log(`schools/${schoolId}/${name}: SKIPPED (${e.message})`);
      result.schoolSubcollections[name] = { error: e.message };
    }
  }

  for (const docId of CONFIG_DOC_IDS) {
    try {
      const doc = await db
        .collection('schools')
        .doc(schoolId)
        .collection('config')
        .doc(docId)
        .get();
      result.config[docId] = doc.exists ? doc.data() : null;
      console.log(`schools/${schoolId}/config/${docId}: ${doc.exists ? 'found' : 'not found'}`);
    } catch (e) {
      console.log(`schools/${schoolId}/config/${docId}: SKIPPED (${e.message})`);
    }
  }

  // The school + user-profile docs themselves, for completeness.
  try {
    const schoolDoc = await db.collection('schools').doc(schoolId).get();
    result.schoolDoc = schoolDoc.exists ? schoolDoc.data() : null;
    console.log(`schools/${schoolId} (root doc): ${schoolDoc.exists ? 'found' : 'not found'}`);
  } catch (e) {
    console.log(`schools/${schoolId} (root doc): SKIPPED (${e.message})`);
  }

  const outPath = path.join(__dirname, 'backups', `${schoolId}_${Date.now()}.json`);
  fs.writeFileSync(outPath, JSON.stringify(result, null, 2));
  console.log(`\nBackup written to ${outPath}`);
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error('BACKUP FAILED', e);
    process.exit(1);
  });
