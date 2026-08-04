#!/usr/bin/env node
const admin = require("firebase-admin");

const ADMIN_EMAILS = ["mubangizivic@gmail.com", "admin@gmail.com"];
const DEMO_SCHOOL_ID = 'school-pulse-academy';

async function main() {
  const projectId = process.env.GOOGLE_CLOUD_PROJECT || process.env.GCLOUD_PROJECT;
  admin.initializeApp({ projectId });
  const db = admin.firestore();

  console.log(`Target Project: ${projectId}`);
  console.log("Purging Firestore data...");

  const collections = [
    'students', 'parent_access_codes', 'attendance',
    'academic_records', 'report_cards', 'report_comments', 'fees', 'payments',
    'health_visits', 'health_profiles', 'clinic_visits',
    'emergency_incidents', 'medical_inventory', 'medical_supply_requests',
    'welfare_records',
    'discipline_incidents',
    'counseling_sessions',
    'library_books',
    'homework',
    'visitors',
    'appointments',
    'meal_plans',
    'sports_houses',
    'sports_competitions',
    'dormitories', 'religion_activities', 'spiritual_groups', 'alerts',
    'config', 'inventory_items', 'inventory_movements',
    'lesson_plans', 'school_events', 'staff_attendance',
    'payroll', 'bus_routes', 'trips', 'pickup_logs', 'exams',
    'stats', 'classes', 'subjects', 'class_streams',
    'academic_years', 'academic_terms', 'educational_levels',
    'school_contacts',
    'broadcast_queue',
    'notification_queue',
    'sms_queue',
    'conversations',
    'audit_logs',
  ];

  for (const collection of collections) {
    await deleteCollection(db, collection);
  }

  const schoolSubCollections = [
    'staff_role_assignments',
    'subject_audit_logs',
    'class_attendance_sessions',
    'class_attendance_corrections',
    'class_report_entries',
    'class_homework',
    'class_behaviour_records',
    'lessons',
  ];

  const schoolRef = db.collection('schools').doc(DEMO_SCHOOL_ID);
  for (const sub of schoolSubCollections) {
    await deleteCollection(db, schoolRef.collection(sub));
  }

  // Delete users except admins
  const usersSnap = await db.collection('users').get();
  let userCount = 0;
  for (const doc of usersSnap.docs) {
    const data = doc.data();
    if (!ADMIN_EMAILS.includes(data.email)) {
      await doc.ref.delete();
      userCount++;
    }
  }
  console.log(`Deleted ${userCount} user profiles from Firestore.`);
  console.log("Firestore Purge Complete.");
}

async function deleteCollection(db, collectionPathOrRef) {
  const collectionRef = typeof collectionPathOrRef === 'string'
    ? db.collection(collectionPathOrRef)
    : collectionPathOrRef;

  const path = collectionRef.path;
  const snapshot = await collectionRef.get();

  if (snapshot.empty) {
    return;
  }

  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });

  await batch.commit();
  console.log(`🗑️  Cleared: ${path} (${snapshot.size} docs)`);
}

main().catch(console.error);
