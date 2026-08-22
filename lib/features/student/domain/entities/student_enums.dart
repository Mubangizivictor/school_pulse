enum StudentStatus {
  applicant,
  pendingAdmission,
  admitted,
  enrollmentInProgress,
  enrolled,
  active,
  deferred,
  onLeave,
  suspended,
  transferredIn,
  transferredOut,
  withdrawn,
  completed,
  graduated,
  alumni,
  expelled,
  deceased,
  archived,
}

enum AdmissionStatus { application, review, approved, admitted, rejected }

/// Maps the narrower application-review lifecycle to the broader student
/// lifecycle so both can be tracked without merging the two enums outright.
StudentStatus studentStatusFromAdmissionStatus(AdmissionStatus status) {
  switch (status) {
    case AdmissionStatus.application:
      return StudentStatus.applicant;
    case AdmissionStatus.review:
      return StudentStatus.pendingAdmission;
    case AdmissionStatus.approved:
      return StudentStatus.pendingAdmission;
    case AdmissionStatus.admitted:
      return StudentStatus.admitted;
    case AdmissionStatus.rejected:
      return StudentStatus.withdrawn;
  }
}

enum Gender { male, female, other }

/// Whether a student boards on-site or attends as a day scholar. Drives
/// the Enrollment Setup Wizard's Finance (studentType-filtered fee
/// structures) and Boarding/House steps.
enum StudentBoardingType { day, boarding }

enum EducationLevel {
  kindergarten,
  primary,
  secondary,
  vocational,
  university,
  international,
}
