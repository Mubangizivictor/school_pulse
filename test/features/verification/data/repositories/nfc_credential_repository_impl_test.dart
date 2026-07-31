import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:school_pulse/features/verification/data/datasources/verification_local_data_source.dart';
import 'package:school_pulse/features/verification/data/models/verification_isar_models.dart';
import 'package:school_pulse/features/verification/data/repositories/nfc_credential_repository_impl.dart';

class MockVerificationLocalDataSource extends Mock implements VerificationLocalDataSource {}

void main() {
  late NfcCredentialRepositoryImpl repository;
  late MockVerificationLocalDataSource localDataSource;

  const schoolId = 'school-1';
  const cardUid = 'CARD-001';

  setUpAll(() {
    registerFallbackValue(CachedCredentialIsar());
    registerFallbackValue(RevokedCredentialIsar());
  });

  setUp(() {
    localDataSource = MockVerificationLocalDataSource();
    repository = NfcCredentialRepositoryImpl(localDataSource: localDataSource);

    when(() => localDataSource.cacheCredential(any())).thenAnswer((_) async {});
    when(() => localDataSource.saveRevocation(any())).thenAnswer((_) async {});
    when(() => localDataSource.deleteRevocation(any(), any())).thenAnswer((_) async {});
  });

  group('assign', () {
    test('creates a new active mapping and clears any denylist entry when the card is unassigned', () async {
      when(() => localDataSource.findCredential(cardUid, schoolId)).thenAnswer((_) async => null);

      final result = await repository.assign(
        credentialValue: cardUid,
        identityId: 'SP-STUDENT-1',
        identityType: 'student',
        schoolId: schoolId,
      );

      expect(result.isRight(), true);
      verify(() => localDataSource.deleteRevocation(cardUid, schoolId)).called(1);
      final captured = verify(() => localDataSource.cacheCredential(captureAny())).captured;
      final saved = captured.single as CachedCredentialIsar;
      expect(saved.credentialValue, cardUid);
      expect(saved.credentialType, 'nfc');
      expect(saved.identityId, 'SP-STUDENT-1');
      expect(saved.identityType, 'student');
      expect(saved.status, 'active');
    });

    test('is idempotent when the card is already actively assigned to the same identity', () async {
      final existing = CachedCredentialIsar()
        ..credentialValue = cardUid
        ..credentialType = 'nfc'
        ..identityId = 'SP-STUDENT-1'
        ..identityType = 'student'
        ..schoolId = schoolId
        ..status = 'active'
        ..updatedAt = DateTime(2026);
      when(() => localDataSource.findCredential(cardUid, schoolId)).thenAnswer((_) async => existing);

      final result = await repository.assign(
        credentialValue: cardUid,
        identityId: 'SP-STUDENT-1',
        identityType: 'student',
        schoolId: schoolId,
      );

      expect(result.isRight(), true);
      verify(() => localDataSource.cacheCredential(any())).called(1);
    });

    test('fails without writing anything when the card is actively assigned to a different identity', () async {
      final existing = CachedCredentialIsar()
        ..credentialValue = cardUid
        ..credentialType = 'nfc'
        ..identityId = 'SP-STUDENT-OTHER'
        ..identityType = 'student'
        ..schoolId = schoolId
        ..status = 'active'
        ..updatedAt = DateTime(2026);
      when(() => localDataSource.findCredential(cardUid, schoolId)).thenAnswer((_) async => existing);

      final result = await repository.assign(
        credentialValue: cardUid,
        identityId: 'SP-STUDENT-1',
        identityType: 'student',
        schoolId: schoolId,
      );

      expect(result.isLeft(), true);
      verifyNever(() => localDataSource.cacheCredential(any()));
      verifyNever(() => localDataSource.deleteRevocation(any(), any()));
    });

    test('reuse: reassigns a previously-revoked card to a new identity and clears the denylist', () async {
      final existing = CachedCredentialIsar()
        ..credentialValue = cardUid
        ..credentialType = 'nfc'
        ..identityId = 'SP-STUDENT-OLD'
        ..identityType = 'student'
        ..schoolId = schoolId
        ..status = 'revoked'
        ..updatedAt = DateTime(2026);
      when(() => localDataSource.findCredential(cardUid, schoolId)).thenAnswer((_) async => existing);

      final result = await repository.assign(
        credentialValue: cardUid,
        identityId: 'SP-STUDENT-NEW',
        identityType: 'student',
        schoolId: schoolId,
      );

      expect(result.isRight(), true);
      verify(() => localDataSource.deleteRevocation(cardUid, schoolId)).called(1);
      final captured = verify(() => localDataSource.cacheCredential(captureAny())).captured;
      expect((captured.single as CachedCredentialIsar).identityId, 'SP-STUDENT-NEW');
    });
  });

  group('revoke', () {
    test('marks the cached mapping revoked and adds a denylist entry', () async {
      final existing = CachedCredentialIsar()
        ..credentialValue = cardUid
        ..credentialType = 'nfc'
        ..identityId = 'SP-STUDENT-1'
        ..identityType = 'student'
        ..schoolId = schoolId
        ..status = 'active'
        ..updatedAt = DateTime(2026);
      when(() => localDataSource.findCredential(cardUid, schoolId)).thenAnswer((_) async => existing);

      final result = await repository.revoke(credentialValue: cardUid, schoolId: schoolId, reason: 'lost');

      expect(result.isRight(), true);
      expect(existing.status, 'revoked');
      verify(() => localDataSource.cacheCredential(existing)).called(1);
      final captured = verify(() => localDataSource.saveRevocation(captureAny())).captured;
      final revocation = captured.single as RevokedCredentialIsar;
      expect(revocation.credentialValue, cardUid);
      expect(revocation.reason, 'lost');
    });

    test('still denylists a card with no prior cached mapping', () async {
      when(() => localDataSource.findCredential(cardUid, schoolId)).thenAnswer((_) async => null);

      final result = await repository.revoke(credentialValue: cardUid, schoolId: schoolId, reason: 'stolen');

      expect(result.isRight(), true);
      verifyNever(() => localDataSource.cacheCredential(any()));
      verify(() => localDataSource.saveRevocation(any())).called(1);
    });
  });

  group('reactivate', () {
    test('clears the denylist entry and restores the cached mapping to active', () async {
      final existing = CachedCredentialIsar()
        ..credentialValue = cardUid
        ..credentialType = 'nfc'
        ..identityId = 'SP-STUDENT-1'
        ..identityType = 'student'
        ..schoolId = schoolId
        ..status = 'revoked'
        ..updatedAt = DateTime(2026);
      when(() => localDataSource.findCredential(cardUid, schoolId)).thenAnswer((_) async => existing);

      final result = await repository.reactivate(credentialValue: cardUid, schoolId: schoolId);

      expect(result.isRight(), true);
      expect(existing.status, 'active');
      verify(() => localDataSource.deleteRevocation(cardUid, schoolId)).called(1);
      verify(() => localDataSource.cacheCredential(existing)).called(1);
    });

    test('fails when there is no prior mapping to reactivate', () async {
      when(() => localDataSource.findCredential(cardUid, schoolId)).thenAnswer((_) async => null);

      final result = await repository.reactivate(credentialValue: cardUid, schoolId: schoolId);

      expect(result.isLeft(), true);
      verifyNever(() => localDataSource.deleteRevocation(any(), any()));
      verifyNever(() => localDataSource.cacheCredential(any()));
    });
  });

  group('replace', () {
    test('revokes the old card and assigns the new one to the same identity', () async {
      when(() => localDataSource.findCredential('OLD', schoolId)).thenAnswer((_) async => CachedCredentialIsar()
        ..credentialValue = 'OLD'
        ..credentialType = 'nfc'
        ..identityId = 'SP-STUDENT-1'
        ..identityType = 'student'
        ..schoolId = schoolId
        ..status = 'active'
        ..updatedAt = DateTime(2026));
      when(() => localDataSource.findCredential('NEW', schoolId)).thenAnswer((_) async => null);

      final result = await repository.replace(
        oldCredentialValue: 'OLD',
        newCredentialValue: 'NEW',
        identityId: 'SP-STUDENT-1',
        identityType: 'student',
        schoolId: schoolId,
        reason: 'damaged',
      );

      expect(result.isRight(), true);
      verify(() => localDataSource.saveRevocation(any())).called(1);
      // cacheCredential is called twice here: once by revoke() re-saving
      // OLD as revoked, once by assign() saving NEW as active.
      final captured = verify(() => localDataSource.cacheCredential(captureAny())).captured;
      final saved = captured.cast<CachedCredentialIsar>();
      expect(saved.map((c) => c.credentialValue), containsAll(['OLD', 'NEW']));
      expect(saved.firstWhere((c) => c.credentialValue == 'NEW').status, 'active');
    });
  });

  group('findAssignedCredential', () {
    test('returns the credentialValue of the most recent mapping for an identity', () async {
      when(() => localDataSource.findCredentialByIdentity('SP-STUDENT-1', schoolId)).thenAnswer(
        (_) async => CachedCredentialIsar()
          ..credentialValue = cardUid
          ..credentialType = 'nfc'
          ..identityId = 'SP-STUDENT-1'
          ..identityType = 'student'
          ..schoolId = schoolId
          ..status = 'revoked'
          ..updatedAt = DateTime(2026),
      );

      final result = await repository.findAssignedCredential(identityId: 'SP-STUDENT-1', schoolId: schoolId);

      expect(result, Right(cardUid));
    });

    test('returns null when the identity has never had a card assigned', () async {
      when(() => localDataSource.findCredentialByIdentity('SP-STUDENT-1', schoolId)).thenAnswer((_) async => null);

      final result = await repository.findAssignedCredential(identityId: 'SP-STUDENT-1', schoolId: schoolId);

      expect(result, const Right<Object, String?>(null));
    });
  });
}
