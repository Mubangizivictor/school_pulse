import 'package:cloud_functions/cloud_functions.dart';

import '../models/parent_access_invite_model.dart';

/// Thin wrapper around the parent-access Cloud Functions. Kept free of
/// Either/Failure mapping - that happens one layer up in
/// [ParentAccessRepositoryImpl] - so this class stays a plain, easily-mocked
/// boundary around FirebaseFunctions.
abstract class ParentAccessRemoteDataSource {
  Future<Map<String, dynamic>> createParentAccessCode({
    required String parentName,
    required String phoneNumber,
    String? email,
    required List<Map<String, dynamic>> learners,
  });

  Future<Map<String, dynamic>> reallocateParentLink({
    required String linkId,
    String? parentName,
    String? phoneNumber,
    required String reason,
  });

  Future<void> revokeParentAccessCode({required String inviteId});

  Future<ParentAccessInvitesPage> listParentAccessInvites({
    required int pageSize,
    String? cursor,
  });

  /// parent_invitations.js
  Future<Map<String, dynamic>> createParentInvitation({
    required String inviteId,
    String? rawCode,
  });

  Future<void> cancelParentInvitation({required String inviteId});

  Future<Map<String, dynamic>> getParentAccessRecord({
    required String inviteId,
  });

  /// [email] is only sent when non-null; pass an empty string to clear the
  /// address, a non-empty string to set it, and null to leave it unchanged.
  Future<void> updateParentInvitationDetails({
    required String inviteId,
    String? parentName,
    String? phoneNumber,
    String? email,
  });

  Future<Map<String, dynamic>> linkLearnersToExistingParent({
    required String inviteId,
    required List<Map<String, dynamic>> learners,
  });

  Future<List<Map<String, dynamic>>> listParentLinkAudit({
    String? inviteId,
    String? studentId,
  });
}

class ParentAccessRemoteDataSourceImpl implements ParentAccessRemoteDataSource {
  final FirebaseFunctions functions;

  ParentAccessRemoteDataSourceImpl({FirebaseFunctions? functions})
    : functions = functions ?? FirebaseFunctions.instance;

  @override
  Future<Map<String, dynamic>> createParentAccessCode({
    required String parentName,
    required String phoneNumber,
    String? email,
    required List<Map<String, dynamic>> learners,
  }) async {
    final result = await functions
        .httpsCallable('createParentAccessCode')
        .call({
          'parentName': parentName,
          'phoneNumber': phoneNumber,
          if (email != null && email.isNotEmpty) 'email': email,
          'learners': learners,
        });
    return Map<String, dynamic>.from(result.data as Map);
  }

  @override
  Future<Map<String, dynamic>> reallocateParentLink({
    required String linkId,
    String? parentName,
    String? phoneNumber,
    required String reason,
  }) async {
    final result = await functions.httpsCallable('reallocateParentLink').call({
      'linkId': linkId,
      'parentName': ?parentName,
      'phoneNumber': ?phoneNumber,
      'reason': reason,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  @override
  Future<void> revokeParentAccessCode({required String inviteId}) async {
    await functions.httpsCallable('revokeParentAccessCode').call({
      'inviteId': inviteId,
    });
  }

  @override
  Future<ParentAccessInvitesPage> listParentAccessInvites({
    required int pageSize,
    String? cursor,
  }) async {
    final result = await functions
        .httpsCallable('listParentAccessInvites')
        .call({'pageSize': pageSize, 'cursor': ?cursor});
    return ParentAccessInvitesPage.fromCallableData(
      Map<String, dynamic>.from(result.data as Map),
    );
  }

  @override
  Future<Map<String, dynamic>> createParentInvitation({
    required String inviteId,
    String? rawCode,
  }) async {
    final result = await functions.httpsCallable('createParentInvitation').call(
      {'inviteId': inviteId, 'rawCode': ?rawCode},
    );
    return Map<String, dynamic>.from(result.data as Map);
  }

  @override
  Future<void> cancelParentInvitation({required String inviteId}) async {
    await functions.httpsCallable('cancelParentInvitation').call({
      'inviteId': inviteId,
    });
  }

  @override
  Future<Map<String, dynamic>> getParentAccessRecord({
    required String inviteId,
  }) async {
    final result = await functions.httpsCallable('getParentAccessRecord').call({
      'inviteId': inviteId,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }

  @override
  Future<void> updateParentInvitationDetails({
    required String inviteId,
    String? parentName,
    String? phoneNumber,
    String? email,
  }) async {
    await functions.httpsCallable('updateParentInvitationDetails').call({
      'inviteId': inviteId,
      'parentName': ?parentName,
      'phoneNumber': ?phoneNumber,
      // null => key omitted => unchanged. '' => clear. non-empty => set.
      'email': ?email,
    });
  }

  @override
  Future<Map<String, dynamic>> linkLearnersToExistingParent({
    required String inviteId,
    required List<Map<String, dynamic>> learners,
  }) async {
    final result = await functions
        .httpsCallable('linkLearnersToExistingParent')
        .call({'inviteId': inviteId, 'learners': learners});
    return Map<String, dynamic>.from(result.data as Map);
  }

  @override
  Future<List<Map<String, dynamic>>> listParentLinkAudit({
    String? inviteId,
    String? studentId,
  }) async {
    final result = await functions.httpsCallable('listParentLinkAudit').call({
      'inviteId': ?inviteId,
      'studentId': ?studentId,
    });
    final entries =
        (Map<String, dynamic>.from(result.data as Map)['entries'] as List?) ??
        const [];
    return entries.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
