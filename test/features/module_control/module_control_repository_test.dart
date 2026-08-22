import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/module_control/data/module_control_repository.dart';
import 'package:school_pulse/features/module_control/domain/institution_policy.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ModuleControlRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = ModuleControlRepository(firestore: firestore);
  });

  group('module enablement', () {
    test('rejects enabling a non-entitled module', () async {
      await firestore
          .collection('schools')
          .doc('s1')
          .collection('module_configuration')
          .doc('boarding')
          .set({'entitled': false, 'enabled': false});
      expect(
        () => repository.setModuleEnabled(
          schoolId: 's1',
          moduleKey: 'boarding',
          enabled: true,
          actorId: 'admin1',
          reason: 'test',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test(
      'enabling an entitled module increments version and writes audit',
      () async {
        await firestore
            .collection('schools')
            .doc('s1')
            .collection('module_configuration')
            .doc('attendance')
            .set({
              'entitled': true,
              'enabled': false,
              'configurationVersion': 1,
            });
        await repository.setModuleEnabled(
          schoolId: 's1',
          moduleKey: 'attendance',
          enabled: true,
          actorId: 'admin1',
          reason: 'term start',
        );
        final doc = await firestore
            .collection('schools')
            .doc('s1')
            .collection('module_configuration')
            .doc('attendance')
            .get();
        expect(doc.data()!['enabled'], true);
        expect(doc.data()!['configurationVersion'], 2);
        expect(doc.data()!['updatedBy'], 'admin1');

        final audit = await firestore
            .collection('schools')
            .doc('s1')
            .collection('module_policy_audit')
            .get();
        expect(audit.docs, hasLength(1));
        expect(audit.docs.single.data()['action'], 'module_enabled');
      },
    );
  });

  group('policy versioning', () {
    InstitutionPolicy policy({
      int version = 0,
      PolicyStatus status = PolicyStatus.active,
    }) => InstitutionPolicy(
      id: 'p1',
      institutionId: 's1',
      name: 'Attendance Policy',
      createdBy: 'admin1',
      updatedBy: 'admin1',
      changeReason: 'initial',
      type: InstitutionPolicyType.attendance,
      scope: const PolicyScope(),
      configuration: const {'lateThresholdMinutes': 15},
      status: status,
      version: version,
      effectiveFrom: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('first save creates version 1 and an audit entry', () async {
      await repository.savePolicy(policy());
      final doc = await firestore
          .collection('schools')
          .doc('s1')
          .collection('institution_policies')
          .doc('p1')
          .get();
      expect(doc.data()!['version'], 1);
      final versions = await firestore
          .collection('schools')
          .doc('s1')
          .collection('institution_policies')
          .doc('p1')
          .collection('versions')
          .get();
      expect(versions.docs, hasLength(1));
      final audit = await firestore
          .collection('schools')
          .doc('s1')
          .collection('module_policy_audit')
          .get();
      expect(audit.docs, hasLength(1));
    });

    test(
      'subsequent saves append a new version without deleting history',
      () async {
        await repository.savePolicy(policy());
        await repository.savePolicy(
          policy(version: 1),
          previousVersion: policy(version: 1),
        );
        final versions = await firestore
            .collection('schools')
            .doc('s1')
            .collection('institution_policies')
            .doc('p1')
            .collection('versions')
            .get();
        expect(versions.docs, hasLength(2));
        final doc = await firestore
            .collection('schools')
            .doc('s1')
            .collection('institution_policies')
            .doc('p1')
            .get();
        expect(doc.data()!['version'], 2);
      },
    );
  });

  group('watchPolicies / watchModules', () {
    test('streams typed policies back from Firestore', () async {
      await firestore
          .collection('schools')
          .doc('s1')
          .collection('institution_policies')
          .doc('p1')
          .set({
            'institutionId': 's1',
            'policyType': 'parentPortal',
            'policyName': 'Parent Portal Policy',
            'scope': {'type': 'institution'},
            'configuration': {'portalEnabled': true},
            'status': 'active',
            'version': 1,
            'effectiveFrom': Timestamp.fromDate(DateTime(2026, 1, 1)),
            'createdBy': 'admin1',
            'updatedBy': 'admin1',
            'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
            'updatedAt': Timestamp.fromDate(DateTime(2026, 1, 1)),
            'changeReason': 'initial',
          });
      final policies = await repository.watchPolicies('s1').first;
      expect(policies.single.type, InstitutionPolicyType.parentPortal);
      expect(policies.single.configuration['portalEnabled'], true);
    });
  });
}
