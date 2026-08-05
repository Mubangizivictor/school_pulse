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
      final brandingData = data['branding'] as Map<String, dynamic>?;

      if (brandingData == null) {
        return Left(ServerFailure('Branding data is missing for this school'));
      }

      return Right(
        SchoolBranding(
          schoolId: schoolId,
          schoolName: data['name'] ?? 'School Name',
          schoolMotto: brandingData['motto'] ?? '',
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
