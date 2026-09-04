import 'package:cloud_functions/cloud_functions.dart';

import '../models/parent_access_invite_model.dart';

/// Thin wrapper around the four parent-access Cloud Functions
/// (createParentAccessCode, reallocateParentLink, revokeParentAccessCode,
/// listParentAccessInvites). Kept free of Either/Failure mapping - that
/// happens one layer up in ParentAccessRepositoryImpl - so this class stays
/// a plain, easily-mocked boundary around FirebaseFunctions.
abstract class ParentAccessRemoteDataSource {
  Future<Map<String, dynamic>> createParentAccessCode({
    required String parentName,
    required String phoneNumber,
    required List<Map<String, String>> learners,
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
}

class ParentAccessRemoteDataSourceImpl implements ParentAccessRemoteDataSource {
  final FirebaseFunctions functions;

  ParentAccessRemoteDataSourceImpl({FirebaseFunctions? functions})
    : functions = functions ?? FirebaseFunctions.instance;

  @override
  Future<Map<String, dynamic>> createParentAccessCode({
    required String parentName,
    required String phoneNumber,
    required List<Map<String, String>> learners,
  }) async {
    final result = await functions.httpsCallable('createParentAccessCode').call({
      'parentName': parentName,
      'phoneNumber': phoneNumber,
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
      if (parentName != null) 'parentName': parentName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
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
    final result = await functions.httpsCallable('listParentAccessInvites').call({
      'pageSize': pageSize,
      if (cursor != null) 'cursor': cursor,
    });
    return ParentAccessInvitesPage.fromCallableData(
      Map<String, dynamic>.from(result.data as Map),
    );
  }
}
