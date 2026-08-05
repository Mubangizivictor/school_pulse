import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/security_models.dart';
import '../../domain/entities/security_entities.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';

class LostAndFoundScreen extends StatefulWidget {
  const LostAndFoundScreen({super.key});

  @override
  State<LostAndFoundScreen> createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  String get _schoolId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  @override
  void initState() {
    super.initState();
    context.read<SecurityBloc>().add(WatchLostAndFoundRequested(_schoolId));
  }

  void _openReportForm() {
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
        child: _ReportFoundItemSheet(schoolId: _schoolId),
      ),
    );
  }

  void _openClaimForm(LostAndFoundItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) =>
          _ClaimItemDialog(item: item, schoolId: _schoolId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth >= 700;

    return Scaffold(
      appBar: AppBar(title: const Text('Lost & Found')),
      body: BlocConsumer<SecurityBloc, SecurityState>(
        listenWhen: (previous, current) =>
            !identical(previous.feedback, current.feedback) &&
            current.feedback != null,
        listener: (context, state) {
          final feedback = state.feedback!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(feedback.message),
              backgroundColor: feedback.isError ? Colors.red : null,
            ),
          );
        },
        builder: (context, state) {
          if (state.lostAndFound.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No Items Found',
              message:
                  'When you find a lost item, report it here to help return it to its owner.',
            );
          }

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: GridView.builder(
                padding: EdgeInsets.all(isLargeScreen ? 24 : 12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: screenWidth > 1100
                      ? 3
                      : (isLargeScreen ? 2 : 1),
                  mainAxisExtent: 110,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: state.lostAndFound.length,
                itemBuilder: (context, index) {
                  final item = state.lostAndFound[index];
                  return AppCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundImage: item.photoUrl != null
                            ? NetworkImage(item.photoUrl!)
                            : null,
                        child: item.photoUrl == null
                            ? const Icon(Icons.inventory_2_outlined)
                            : null,
                      ),
                      title: Text(
                        item.description,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${item.locationFound} • ${item.dateFound.toLocal().toString().split(' ').first}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: item.isClaimed
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : OutlinedButton(
                              onPressed: () => _openClaimForm(item),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              child: const Text('Claim'),
                            ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openReportForm,
        icon: const Icon(Icons.add),
        label: const Text('Report Item'),
      ),
    );
  }
}

class _ReportFoundItemSheet extends StatefulWidget {
  final String schoolId;
  const _ReportFoundItemSheet({required this.schoolId});

  @override
  State<_ReportFoundItemSheet> createState() => _ReportFoundItemSheetState();
}

class _ReportFoundItemSheetState extends State<_ReportFoundItemSheet> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  XFile? _photo;
  bool _isSaving = false;

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _photo = picked);
  }

  Future<void> _save() async {
    if (_descriptionController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty)
      return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final securityBloc = context.read<SecurityBloc>();

    setState(() => _isSaving = true);
    final id = const Uuid().v4();
    String? photoUrl;
    if (_photo != null) {
      final ref = FirebaseStorage.instance.ref(
        'lost_and_found/${widget.schoolId}/$id.jpg',
      );
      await ref.putFile(File(_photo!.path));
      photoUrl = await ref.getDownloadURL();
    }
    if (!mounted) return;

    final item = LostAndFoundItemModel(
      id: id,
      description: _descriptionController.text.trim(),
      locationFound: _locationController.text.trim(),
      dateFound: DateTime.now(),
      photoUrl: photoUrl,
      foundByPersonId: authState.user.id,
      isClaimed: false,
      schoolId: widget.schoolId,
    );
    securityBloc.add(ReportFoundItemRequested(item));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Report Found Item',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Item Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location Found',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.camera_alt_outlined),
            label: Text(_photo == null ? 'Add Photo' : 'Photo Added'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _ClaimItemDialog extends StatefulWidget {
  final LostAndFoundItem item;
  final String schoolId;
  const _ClaimItemDialog({required this.item, required this.schoolId});

  @override
  State<_ClaimItemDialog> createState() => _ClaimItemDialogState();
}

class _ClaimItemDialogState extends State<_ClaimItemDialog> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _verificationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Release Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Claimant Name'),
          ),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: 'Claimant Phone'),
          ),
          TextField(
            controller: _verificationController,
            decoration: const InputDecoration(labelText: 'Verification Notes'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.trim().isEmpty) return;
            context.read<SecurityBloc>().add(
              ClaimItemRequested(widget.schoolId, widget.item.id, {
                'claimantName': _nameController.text.trim(),
                'claimantPhone': _phoneController.text.trim(),
                'verificationNotes': _verificationController.text.trim(),
                'releasedAt': DateTime.now().toIso8601String(),
              }),
            );
            Navigator.pop(context);
          },
          child: const Text('Confirm Release'),
        ),
      ],
    );
  }
}
