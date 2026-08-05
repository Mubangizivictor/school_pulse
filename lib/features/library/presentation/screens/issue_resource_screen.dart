import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/library/domain/entities/library_borrowing.dart';
import 'package:school_pulse/features/library/domain/entities/library_resource.dart';
import 'package:school_pulse/features/library/domain/entities/library_policy.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/qr_scanner/domain/entities/scanner_mode.dart';
import 'package:school_pulse/features/qr_scanner/presentation/screens/qr_scanner_screen.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_state.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../bloc/library_bloc.dart';
import '../bloc/library_event.dart';
import '../bloc/library_state.dart';
import 'package:uuid/uuid.dart';

class IssueResourceScreen extends StatefulWidget {
  final String schoolId;
  const IssueResourceScreen({super.key, required this.schoolId});

  @override
  State<IssueResourceScreen> createState() => _IssueResourceScreenState();
}

class _IssueResourceScreenState extends State<IssueResourceScreen> {
  LibraryResource? _selectedResource;
  dynamic _selectedBorrower; // Student or Teacher
  String _borrowerType = 'student';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));
  List<LibraryPolicy> _policies = [];

  @override
  void initState() {
    super.initState();
    context.read<LibraryBloc>().add(WatchPoliciesRequested(widget.schoolId));
  }

  void _onResourceScanned(String code) {
    // Find resource by barcode/QR in the loaded state or fetch from repo
    final state = context.read<LibraryBloc>().state;
    if (state is LibraryResourcesLoaded) {
      try {
        final resource = state.resources.firstWhere(
          (r) => r.barcode == code || r.qrCode == code,
        );
        setState(() => _selectedResource = resource);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resource not found in catalog')),
        );
      }
    }
  }

  void _onBorrowerScanned(String code) {
    // Assuming barcode on ID card is studentCode or teacherId
    if (_borrowerType == 'student') {
      context.read<StudentsBloc>().add(SearchStudents(code));
    }
    // Handle teacher scanning if applicable
  }

  void _calculateDueDate() {
    if (_policies.isEmpty) return;
    try {
      final policy = _policies.firstWhere(
        (p) => p.borrowerType == _borrowerType,
      );
      setState(() {
        _dueDate = DateTime.now().add(
          Duration(days: policy.borrowDurationDays),
        );
      });
    } catch (_) {
      // Default to 14 days if no policy found
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LibraryBloc, LibraryState>(
      listener: (context, state) {
        if (state is LibraryPoliciesLoaded) {
          _policies = state.policies.cast<LibraryPolicy>();
          _calculateDueDate();
        }
        if (state is LibraryActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Issue Resource')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildResourceSection(),
            const SizedBox(height: 24),
            _buildBorrowerSection(),
            const SizedBox(height: 24),
            if (_selectedResource != null && _selectedBorrower != null)
              _buildIssueDetails(),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: (_selectedResource != null && _selectedBorrower != null)
                ? _issueResource
                : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm Issue'),
          ),
        ),
      ),
    );
  }

  Widget _buildResourceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '1. Select Resource'),
        const SizedBox(height: 12),
        if (_selectedResource == null)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrScannerScreen(
                        mode: ScannerMode.library,
                        onScan: _onResourceScanned,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Barcode'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showResourceSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Search Catalog'),
                ),
              ),
            ],
          )
        else
          AppCard(
            child: ListTile(
              leading: const Icon(Icons.book, size: 40),
              title: Text(_selectedResource!.title),
              subtitle: Text(
                'Author: ${_selectedResource!.author}\nShelf: ${_selectedResource!.shelf}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedResource = null),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBorrowerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '2. Select Borrower'),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'student',
              label: Text('Student'),
              icon: Icon(Icons.person),
            ),
            ButtonSegment(
              value: 'teacher',
              label: Text('Teacher'),
              icon: Icon(Icons.school),
            ),
          ],
          selected: {_borrowerType},
          onSelectionChanged: (val) {
            setState(() {
              _borrowerType = val.first;
              _selectedBorrower = null;
              _calculateDueDate();
            });
          },
        ),
        const SizedBox(height: 16),
        if (_selectedBorrower == null)
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrScannerScreen(
                        mode: ScannerMode.library,
                        onScan: _onBorrowerScanned,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.badge_outlined),
                  label: const Text('Scan ID Card'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showBorrowerSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Search Name'),
                ),
              ),
            ],
          )
        else
          AppCard(
            child: ListTile(
              leading: AvatarInitials(
                name: _borrowerType == 'student'
                    ? (_selectedBorrower as Student).name
                    : (_selectedBorrower as UserEntity).name,
              ),
              title: Text(
                _borrowerType == 'student'
                    ? (_selectedBorrower as Student).name
                    : (_selectedBorrower as UserEntity).name,
              ),
              subtitle: Text(
                _borrowerType == 'student'
                    ? 'Code: ${(_selectedBorrower as Student).studentCode}'
                    : 'Staff Code: ${(_selectedBorrower as UserEntity).staffCode ?? 'N/A'}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedBorrower = null),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIssueDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '3. Issue Details'),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(
                  DateFormat('EEEE, MMM d, yyyy').format(_dueDate),
                ),
                trailing: const Icon(Icons.calendar_month),
                onTap: _selectDueDate,
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This resource will be automatically marked as overdue if not returned by the due date.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showResourceSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search resources...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) => context.read<LibraryBloc>().add(
                  SearchResourcesRequested(widget.schoolId, val),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<LibraryBloc, LibraryState>(
                builder: (context, state) {
                  if (state is LibraryResourcesLoaded) {
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: state.resources.length,
                      itemBuilder: (context, index) {
                        final resource = state.resources[index];
                        return ListTile(
                          title: Text(resource.title),
                          subtitle: Text(resource.author),
                          onTap: () {
                            setState(() => _selectedResource = resource);
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBorrowerSearch() {
    if (_borrowerType == 'student') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search students...',
                    prefixIcon: const Icon(Icons.person_search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (val) =>
                      context.read<StudentsBloc>().add(SearchStudents(val)),
                ),
              ),
              Expanded(
                child: BlocBuilder<StudentsBloc, StudentsState>(
                  builder: (context, state) {
                    if (state is StudentsLoaded) {
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: state.students.length,
                        itemBuilder: (context, index) {
                          final student = state.students[index];
                          return ListTile(
                            leading: AvatarInitials(name: student.name),
                            title: Text(student.name),
                            subtitle: Text(student.studentCode),
                            onTap: () {
                              setState(() => _selectedBorrower = student);
                              _calculateDueDate();
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => _TeacherSearchSheet(
          onTeacherSelected: (teacher) {
            setState(() {
              _selectedBorrower = teacher;
              _calculateDueDate();
            });
          },
        ),
      );
    }
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() => _dueDate = picked);
    }
  }

  void _issueResource() {
    final authState = context.read<AuthBloc>().state;
    String librarianId = 'system';
    if (authState is AuthAuthenticated) {
      librarianId = authState.user.id;
    }

    final borrowing = LibraryBorrowing(
      id: const Uuid().v4(),
      schoolId: widget.schoolId,
      resourceId: _selectedResource!.id,
      resourceTitle: _selectedResource!.title,
      borrowerId: _borrowerType == 'student'
          ? (_selectedBorrower as Student).id
          : (_selectedBorrower as UserEntity).id,
      borrowerName: _borrowerType == 'student'
          ? (_selectedBorrower as Student).name
          : (_selectedBorrower as UserEntity).name,
      borrowerType: _borrowerType,
      borrowDate: DateTime.now(),
      dueDate: _dueDate,
      issuedBy: librarianId,
    );

    context.read<LibraryBloc>().add(IssueResourceRequested(borrowing));
  }
}

class _TeacherSearchSheet extends StatefulWidget {
  final Function(UserEntity) onTeacherSelected;

  const _TeacherSearchSheet({required this.onTeacherSelected});

  @override
  State<_TeacherSearchSheet> createState() => _TeacherSearchSheetState();
}

class _TeacherSearchSheetState extends State<_TeacherSearchSheet> {
  late Future<List<UserEntity>> _staffFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _staffFuture = di.sl<GetStaffMembers>()(NoParams()).then(
      (result) => result.fold((l) => [], (r) => r),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search staff by name or code...',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) => setState(() => _query = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<UserEntity>>(
              future: _staffFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Error loading staff'));
                }

                final filtered = snapshot.data!
                    .where(
                      (s) =>
                          s.name.toLowerCase().contains(_query) ||
                          (s.staffCode?.toLowerCase().contains(_query) ??
                              false),
                    )
                    .toList();

                if (filtered.isEmpty) {
                  return const EmptyState(
                    icon: Icons.person_off_outlined,
                    title: 'No staff found',
                    message: 'Try a different search term',
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final staff = filtered[index];
                    return ListTile(
                      leading: AvatarInitials(name: staff.name),
                      title: Text(staff.name),
                      subtitle: Text(staff.staffCode ?? staff.email),
                      onTap: () {
                        widget.onTeacherSelected(staff);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
