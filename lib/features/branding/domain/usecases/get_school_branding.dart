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
      final school = firestore.collection('schools').doc(schoolId);
      final snapshots = await Future.wait([
        school.get(),
        school.collection('config').doc('institution_profile').get(),
      ]);
      final doc = snapshots[0];
      final profileDoc = snapshots[1];

      if (!doc.exists) {
        return Left(ServerFailure('School branding not found'));
      }

      final data = doc.data()!;
      // Institution profile is the editable, tenant-scoped source of truth.
      // The root school document remains a platform-owned tenant record; its
      // legacy branding fields are retained only as a migration fallback.
      final profileData = profileDoc.data() ?? const <String, dynamic>{};
      final brandingData =
          (data['branding'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      String? nonEmpty(Object? value) {
        final text = value?.toString().trim();
        return text == null || text.isEmpty ? null : text;
      }

      final schoolName =
          nonEmpty(profileData['name']) ??
          nonEmpty(data['name']) ??
          nonEmpty(data['schoolName']);
      if (schoolName == null || schoolName.isEmpty) {
        return Left(ServerFailure('School identity is incomplete'));
      }

      final profileColors = List<String>.from(
        profileData['colors'] ?? const <String>[],
      ).where((color) => color.trim().isNotEmpty).toList();
      final primaryColor = profileColors.isNotEmpty
          ? profileColors[0]
          : brandingData['primaryColor']?.toString();
      final secondaryColor = profileColors.length > 1
          ? profileColors[1]
          : brandingData['secondaryColor']?.toString();
      final accentColor = profileColors.length > 2
          ? profileColors[2]
          : brandingData['accentColor']?.toString();

      return Right(
        SchoolBranding(
          schoolId: schoolId,
          schoolName: schoolName,
          schoolInitials:
              nonEmpty(profileData['shortName']) ??
              (data['initials'] ?? data['schoolInitials'] ?? '').toString(),
          schoolMotto:
              nonEmpty(profileData['motto']) ??
              brandingData['motto']?.toString() ??
              '',
          schoolType:
              nonEmpty(profileData['schoolType']) ??
              data['schoolType']?.toString(),
          logoUrl:
              nonEmpty(profileData['logoUrl']) ??
              brandingData['logoUrl']?.toString(),
          badgeUrl:
              nonEmpty(profileData['badgeUrl']) ??
              brandingData['badgeUrl']?.toString(),
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          accentColor: accentColor,
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
