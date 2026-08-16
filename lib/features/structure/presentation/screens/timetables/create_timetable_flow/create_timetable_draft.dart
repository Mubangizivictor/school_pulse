/// Mutable state carried across the 4-step create-timetable wizard
/// (Basic Info -> Periods -> Schedule -> Review) before it becomes a real
/// [Timetable] on submit.
class CreateTimetableDraft {
  String academicYearId;
  String termId;
  String classId;
  String streamId;
  String name;
  String description;

  CreateTimetableDraft({
    this.academicYearId = '',
    this.termId = '',
    this.classId = '',
    this.streamId = '',
    this.name = '',
    this.description = '',
  });

  bool get isBasicInfoComplete =>
      academicYearId.isNotEmpty && classId.isNotEmpty && name.isNotEmpty;
}
