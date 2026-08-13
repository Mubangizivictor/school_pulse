import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/features/branding/domain/entities/school_branding.dart';

class GetSchoolBranding implements UseCase<SchoolBranding, String> {
  final FirebaseFirestore firestore;

  GetSchoolBranding(this.firestore);

  @override
  Future<Either<Failure, SchoolBranding>> call(String schoolId) async {
    try {
      final doc = await firestore.collection('schools').doc(schoolId).get();

      if (!doc.exists) {
        return Left(ServerFailure('School branding not found'));
      }

      final data = doc.data()!;
      // Structure owns this document. Branding is optional presentation data,
      // not a second configuration source, so a valid school can still open
      // with safe platform defaults while its admin finishes setup.
      final brandingData =
          (data['branding'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final schoolName = (data['name'] ?? data['schoolName'])
          ?.toString()
          .trim();
      if (schoolName == null || schoolName.isEmpty) {
        return Left(ServerFailure('School identity is incomplete'));
      }

      return Right(
        SchoolBranding(
          schoolId: schoolId,
          schoolName: schoolName,
          schoolInitials: (data['initials'] ?? data['schoolInitials'] ?? '')
              .toString(),
          schoolMotto: brandingData['motto'] ?? '',
          schoolType: data['schoolType']?.toString(),
          logoUrl: brandingData['logoUrl'],
          badgeUrl: brandingData['badgeUrl'],
          primaryColor: brandingData['primaryColor'],
          secondaryColor: brandingData['secondaryColor'],
          accentColor: brandingData['accentColor'],
          welcomeMessage: brandingData['welcomeMessage'],
          dashboardBannerUrl: brandingData['dashboardBannerUrl'],
          loginBackgroundUrl: brandingData['loginBackgroundUrl'],
          version: brandingData['version'] ?? 1,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
