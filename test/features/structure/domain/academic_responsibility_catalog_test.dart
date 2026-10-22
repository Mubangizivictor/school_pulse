import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/teaching_assignment.dart';
import 'package:school_pulse/features/structure/domain/services/academic_responsibility_catalog.dart';

StaffDesignation designation(String name) => StaffDesignation(
  id: name.toLowerCase().replaceAll(' ', '-'),
  schoolId: 'school-a',
  name: name,
);

void main() {
  test('only active configured academic responsibilities are selectable', () {
    final choices = configuredAcademicResponsibilities([
      designation('Subject Teacher'),
      designation('Head of Department'),
      designation('Bursar'),
      designation('Class Teacher').copyWith(isArchived: true),
    ]);

    expect(choices.map((item) => item.title), [
      'Head of Department',
      'Subject Teacher',
    ]);
  });

  test('dynamic scope requirements match the configured responsibility', () {
    final choices = configuredAcademicResponsibilities([
      designation('Subject Teacher'),
      designation('Class Teacher'),
      designation('Head of Department'),
      designation('Examinations Officer'),
    ]);
    final subject = choices.firstWhere(
      (item) => item.type == TeachingResponsibilityType.subjectTeacher,
    );
    final classTeacher = choices.firstWhere(
      (item) => item.type == TeachingResponsibilityType.classTeacher,
    );
    final hod = choices.firstWhere(
      (item) => item.type == TeachingResponsibilityType.headOfDepartment,
    );
    final examinations = choices.firstWhere(
      (item) => item.type == TeachingResponsibilityType.examinationsOfficer,
    );

    expect(
      (subject.needsClass, subject.needsSubject, subject.needsDepartment),
      (true, true, false),
    );
    expect((classTeacher.needsClass, classTeacher.needsSubject), (true, false));
    expect((hod.needsDepartment, hod.needsClass), (true, false));
    expect(examinations.isInstitutionWide, isTrue);
  });
}
