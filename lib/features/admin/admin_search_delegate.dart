import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Searches staff (by name/email/role) and students (by name/class/ID) using
/// the same repositories already backing User Management and the roster -
/// no separate search index needed at this data scale.
class AdminSearchDelegate extends SearchDelegate<void> {
  AdminSearchDelegate()
    : super(searchFieldLabel: 'Search staff, students, settings...');

  @override
  List<Widget> buildActions(BuildContext context) => [
    if (query.isNotEmpty)
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildBody(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildBody(context);

  Widget _buildBody(BuildContext context) {
    if (query.trim().length < 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Type at least 2 characters to search staff or students'),
        ),
      );
    }
    return FutureBuilder(
      future: Future.wait([
        di.sl<GetStaffMembers>()(NoParams()),
        di.sl<GetAllStudents>()(),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final q = query.trim().toLowerCase();

        final staffEither = snapshot.data![0] as dynamic;
        final List<UserEntity> staff = staffEither.fold(
          (_) => <UserEntity>[],
          (s) => s as List<UserEntity>,
        );
        final matchedStaff = staff
            .where(
              (s) =>
                  s.name.toLowerCase().contains(q) ||
                  s.email.toLowerCase().contains(q) ||
                  UserRoleDisplay.name(s.role).toLowerCase().contains(q),
            )
            .toList();

        final studentsEither = snapshot.data![1] as dynamic;
        final List<Student> students = studentsEither.fold(
          (_) => <Student>[],
          (s) => s as List<Student>,
        );
        final matchedStudents = students
            .where(
              (s) =>
                  s.name.toLowerCase().contains(q) ||
                  s.className.toLowerCase().contains(q) ||
                  s.studentId.toLowerCase().contains(q),
            )
            .toList();

        if (matchedStaff.isEmpty && matchedStudents.isEmpty) {
          return const Center(child: Text('No matches found'));
        }

        return ListView(
          children: [
            if (matchedStaff.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  'Staff',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...matchedStaff.map(
                (s) => ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(s.name),
                  subtitle: Text(
                    '${UserRoleDisplay.name(s.role)} • ${s.email}',
                  ),
                  onTap: () {
                    close(context, null);
                    context.go('/staff/admin/users?tab=1');
                  },
                ),
              ),
            ],
            if (matchedStudents.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Text(
                  'Students',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...matchedStudents.map(
                (s) => ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: Text(s.name),
                  subtitle: Text('${s.className} • ${s.studentId}'),
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(s.name),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Class: ${s.className}'),
                          const SizedBox(height: 4),
                          Text('Student ID: ${s.studentId}'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context); // Close dialog
                            close(context, null); // Close search
                            context.go(
                              '/staff/admin/student-id-card',
                              extra: s,
                            );
                          },
                          icon: const Icon(Icons.badge_outlined, size: 18),
                          label: const Text('Issue ID Card'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
