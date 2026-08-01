import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';

class TeacherStudentListScreen extends StatefulWidget {
  const TeacherStudentListScreen({super.key});

  @override
  State<TeacherStudentListScreen> createState() => _TeacherStudentListScreenState();
}

class _TeacherStudentListScreenState extends State<TeacherStudentListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<Student> _mockStudents = List.generate(
    10,
    (index) => Student(
      id: 'student_$index',
      schoolId: 'school_1',
      name: index % 2 == 0 ? 'Abalo Peter' : 'Adong Grace',
      admissionNumber: '2021/PE/01$index',
      studentCode: 'STU$index',
      dateOfBirth: DateTime(2014, 5, 12),
      gender: index % 2 == 0 ? Gender.male : Gender.female,
      classId: 'P.4 Blue',
      academicYearId: '2024',
      status: StudentStatus.active,
      level: EducationLevel.primary,
    ),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Students',
          style: AppTypography.headlineMedium.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(AppSpacing.m),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(AppSpacing.m),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.royalBlue,
            labelColor: AppColors.royalBlue,
            unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
            unselectedLabelStyle: AppTypography.labelLarge,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'All (32)'),
              Tab(text: 'Present (30)'),
              Tab(text: 'Absent (2)'),
            ],
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: _mockStudents.length,
              itemBuilder: (context, index) {
                final student = _mockStudents[index];
                final isAbsent = index == 3 || index == 7; // Mocking some absent students

                return _StudentListTile(
                  student: student,
                  isPresent: !isAbsent,
                  onTap: () => context.push('/staff/students/${student.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentListTile extends StatelessWidget {
  final Student student;
  final bool isPresent;
  final VoidCallback onTap;

  const _StudentListTile({
    required this.student,
    required this.isPresent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.l),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSpacing.l),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.royalBlue.withValues(alpha: 0.1),
              child: Text(
                student.name[0],
                style: AppTypography.headlineSmall.copyWith(color: AppColors.royalBlue),
              ),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Admission No: ${student.admissionNumber}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              isPresent ? 'Present' : 'Absent',
              style: AppTypography.labelMedium.copyWith(
                color: isPresent ? AppColors.successGreen : AppColors.errorRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
