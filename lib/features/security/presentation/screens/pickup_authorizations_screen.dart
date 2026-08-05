import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/search_students.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:uuid/uuid.dart';
import '../../domain/entities/security_entities.dart';
import '../../domain/usecases/security_usecases.dart';
import '../../data/models/security_models.dart';

class PickupAuthorizationsScreen extends StatefulWidget {
  const PickupAuthorizationsScreen({super.key});

  @override
  State<PickupAuthorizationsScreen> createState() =>
      _PickupAuthorizationsScreenState();
}

class _PickupAuthorizationsScreenState
    extends State<PickupAuthorizationsScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;
  List<Student> _results = [];
  Student? _selectedStudent;

  String get _schoolId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearching = true);
    final result = await di.sl<SearchStudents>()(
      schoolId: _schoolId,
      query: query.trim(),
    );
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (students) => setState(() => _results = students),
    );
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedStudent != null) {
      return _StudentAuthorizationsView(
        student: _selectedStudent!,
        schoolId: _schoolId,
        onBack: () => setState(() => _selectedStudent = null),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Pickup Authorizations')),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSearchField(
                  controller: _searchController,
                  hintText: 'Search student by name or code',
                  onChanged: (v) {
                    if (v.length >= 3) _search(v);
                  },
                ),
                const SizedBox(height: 24),
                if (_isSearching)
                  const Center(child: CircularProgressIndicator()),
                Expanded(
                  child: _results.isEmpty && !_isSearching
                      ? const EmptyState(
                          icon: Icons.person_search_outlined,
                          title: 'Search Students',
                          message:
                              'Enter a student name or registration code to manage their authorized pickup persons.',
                        )
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: screenWidth > 1100
                                    ? 3
                                    : (isLargeScreen ? 2 : 1),
                                mainAxisExtent: 80,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final student = _results[index];
                            return AppCard(
                              padding: EdgeInsets.zero,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  child: Icon(
                                    Icons.person_outline,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                title: Text(
                                  student.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(student.studentCode),
                                onTap: () =>
                                    setState(() => _selectedStudent = student),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudentAuthorizationsView extends StatefulWidget {
  final Student student;
  final String schoolId;
  final VoidCallback onBack;

  const _StudentAuthorizationsView({
    required this.student,
    required this.schoolId,
    required this.onBack,
  });

  @override
  State<_StudentAuthorizationsView> createState() =>
      _StudentAuthorizationsViewState();
}

class _StudentAuthorizationsViewState
    extends State<_StudentAuthorizationsView> {
  List<PickupAuthorization> _authorizations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final result = await di.sl<GetPickupAuthorizations>()(
      widget.schoolId,
      widget.student.id,
    );
    if (!mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (authorizations) => setState(() => _authorizations = authorizations),
    );
    setState(() => _isLoading = false);
  }

  void _openAddForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: _AddAuthorizationSheet(
          student: widget.student,
          schoolId: widget.schoolId,
          onSaved: () {
            Navigator.pop(sheetContext);
            _load();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 700;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text('${widget.student.name} — Pickup List'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: _authorizations.isEmpty
                    ? const EmptyState(
                        icon: Icons.badge_outlined,
                        title: 'No Authorizations',
                        message:
                            'No persons have been authorized to pick up this student yet.',
                      )
                    : GridView.builder(
                        padding: EdgeInsets.all(isLargeScreen ? 24 : 12),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: screenWidth > 1100
                              ? 3
                              : (isLargeScreen ? 2 : 1),
                          mainAxisExtent: 100,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _authorizations.length,
                        itemBuilder: (context, index) {
                          final auth = _authorizations[index];
                          final expired =
                              auth.expiryDate != null &&
                              auth.expiryDate!.isBefore(DateTime.now());
                          return AppCard(
                            padding: EdgeInsets.zero,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundImage: auth.photoUrl != null
                                    ? NetworkImage(auth.photoUrl!)
                                    : null,
                                child: auth.photoUrl == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              title: Text(
                                auth.authorizedPersonName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${auth.relationship} • ${auth.phone}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: expired
                                  ? const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange,
                                    )
                                  : const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                            ),
                          );
                        },
                      ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddForm,
        icon: const Icon(Icons.add),
        label: const Text('Add Person'),
      ),
    );
  }
}

class _AddAuthorizationSheet extends StatefulWidget {
  final Student student;
  final String schoolId;
  final VoidCallback onSaved;

  const _AddAuthorizationSheet({
    required this.student,
    required this.schoolId,
    required this.onSaved,
  });

  @override
  State<_AddAuthorizationSheet> createState() => _AddAuthorizationSheetState();
}

class _AddAuthorizationSheetState extends State<_AddAuthorizationSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController();
  DateTime? _expiryDate;
  XFile? _photo;
  bool _isSaving = false;

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _photo = picked);
  }

  Future<String?> _uploadPhoto(String authorizationId) async {
    if (_photo == null) return null;
    final ref = FirebaseStorage.instance.ref(
      'pickup_authorizations/${widget.schoolId}/$authorizationId.jpg',
    );
    await ref.putFile(File(_photo!.path));
    return ref.getDownloadURL();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty)
      return;
    final authState = context.read<AuthBloc>().state;

    setState(() => _isSaving = true);
    final id = const Uuid().v4();
    final photoUrl = await _uploadPhoto(id);

    final authorization = PickupAuthorizationModel(
      id: id,
      studentId: widget.student.id,
      parentId: authState is AuthAuthenticated ? authState.user.id : '',
      authorizedPersonName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      relationship: _relationshipController.text.trim().isEmpty
          ? 'Guardian'
          : _relationshipController.text.trim(),
      photoUrl: photoUrl,
      expiryDate: _expiryDate,
      schoolId: widget.schoolId,
    );

    final result = await di.sl<AddPickupAuthorization>()(authorization);
    if (!mounted) return;
    result.fold((failure) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
      );
    }, (_) => widget.onSaved());
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          controller: scrollController,
          children: [
            Text(
              'Authorize Pickup Person',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _photo != null
                      ? FileImage(File(_photo!.path))
                      : null,
                  child: _photo == null
                      ? const Icon(Icons.camera_alt, size: 28)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _relationshipController,
              decoration: const InputDecoration(
                labelText: 'Relationship (e.g. Uncle, Driver, Caretaker)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) setState(() => _expiryDate = picked);
              },
              child: Text(
                _expiryDate == null
                    ? 'Set Expiry Date (optional)'
                    : 'Expires ${_expiryDate!.toLocal().toString().split(' ').first}',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Authorization'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
