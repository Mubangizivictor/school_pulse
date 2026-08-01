import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/homework.dart';
import 'package:intl/intl.dart';

class HomeworkScreen extends StatefulWidget {
  const HomeworkScreen({super.key});

  @override
  State<HomeworkScreen> createState() => _HomeworkScreenState();
}

class _HomeworkScreenState extends State<HomeworkScreen> {
  @override
  void initState() {
    super.initState();
    _refreshHomework();
  }

  void _refreshHomework() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TeacherBloc>().add(TeacherHomeworkRequested(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Homework & Assignments',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: BlocConsumer<TeacherBloc, TeacherState>(
        listener: (context, state) {
          if (state is TeacherOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is TeacherError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.danger(context),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TeacherLoading) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary(context)));
          }

          if (state is TeacherHomeworkLoaded) {
            if (state.homeworkList.isEmpty) {
              return EmptyState(
                icon: Icons.assignment_outlined,
                title: 'No assignments yet',
                message: 'Manage and track homework for your classes here.',
                ctaLabel: 'Add Assignment',
                onCtaPressed: () => _showHomeworkSheet(context),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _refreshHomework(),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.l),
                itemCount: state.homeworkList.length,
                itemBuilder: (context, index) {
                  final homework = state.homeworkList[index];
                  return _HomeworkCard(
                    homework: homework,
                    onEdit: () => _showHomeworkSheet(context, homework: homework),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHomeworkSheet(context),
        backgroundColor: AppColors.primary(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showHomeworkSheet(BuildContext context, {Homework? homework}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.xl)),
      ),
      builder: (context) => _HomeworkSheet(homework: homework),
    );
  }
}

class _HomeworkSheet extends StatefulWidget {
  final Homework? homework;
  const _HomeworkSheet({this.homework});

  @override
  State<_HomeworkSheet> createState() => _HomeworkSheetState();
}

class _HomeworkSheetState extends State<_HomeworkSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _subjectController;
  late DateTime _dueDate;
  final List<String> _attachments = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.homework?.title);
    _descController = TextEditingController(text: widget.homework?.description);
    _subjectController = TextEditingController(text: widget.homework?.subject);
    _dueDate = widget.homework?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    if (widget.homework?.attachments != null) {
      _attachments.addAll(widget.homework!.attachments!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.homework != null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? 'Edit Assignment' : 'New Assignment',
                style: AppTypography.headlineSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: AppColors.textSecondary(context)),
                ),
                style: TextStyle(color: AppColors.textPrimary(context)),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.m),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  labelStyle: TextStyle(color: AppColors.textSecondary(context)),
                ),
                style: TextStyle(color: AppColors.textPrimary(context)),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.m),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Instructions',
                  labelStyle: TextStyle(color: AppColors.textSecondary(context)),
                ),
                style: TextStyle(color: AppColors.textPrimary(context)),
                maxLines: 3,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.m),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Due Date', style: TextStyle(color: AppColors.textPrimary(context))),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy').format(_dueDate),
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
                trailing: Icon(Icons.calendar_today, color: AppColors.primary(context)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _dueDate = picked);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                'Attachments',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              ..._attachments.map((a) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      a,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: AppColors.textPrimary(context)),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.close, size: 20, color: AppColors.danger(context)),
                      onPressed: () => setState(() => _attachments.remove(a)),
                    ),
                  )),
              TextButton.icon(
                onPressed: () {
                  // Mock adding an attachment
                  setState(() => _attachments.add('attachment_${_attachments.length + 1}.pdf'));
                },
                icon: Icon(Icons.attach_file, color: AppColors.primary(context)),
                label: Text('Add Attachment', style: TextStyle(color: AppColors.primary(context))),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: isEditing ? 'Save Changes' : 'Create Assignment',
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        if (widget.homework != null) {
          context.read<TeacherBloc>().add(TeacherHomeworkUpdated(
                widget.homework!.copyWith(
                  title: _titleController.text,
                  description: _descController.text,
                  subject: _subjectController.text,
                  dueDate: _dueDate,
                  attachments: _attachments,
                ),
              ));
        } else {
          context.read<TeacherBloc>().add(TeacherHomeworkCreated(
                Homework(
                  id: '',
                  title: _titleController.text,
                  description: _descController.text,
                  className: authState.user.assignedClass ?? 'General',
                  subject: _subjectController.text,
                  dueDate: _dueDate,
                  createdAt: DateTime.now(),
                  teacherId: authState.user.id,
                  attachments: _attachments,
                ),
              ));
        }
        Navigator.pop(context);
      }
    }
  }
}

class _HomeworkCard extends StatelessWidget {
  final Homework homework;
  final VoidCallback onEdit;

  const _HomeworkCard({required this.homework, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      onTap: onEdit,
      color: AppColors.surfaceElevated(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  homework.title,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StatusBadge(
                label: homework.className,
                color: AppColors.primary(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            homework.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          if (homework.attachments != null && homework.attachments!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.m),
            Row(
              children: [
                Icon(Icons.attach_file, size: 14, color: AppColors.primary(context)),
                const SizedBox(width: 4),
                Text(
                  '${homework.attachments!.length} attachment(s)',
                  style: TextStyle(fontSize: 12, color: AppColors.primary(context)),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: AppColors.textMuted(context)),
              const SizedBox(width: 4),
              Text(
                'Due: ${DateFormat('MMM dd, yyyy').format(homework.dueDate)}',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
              ),
              const Spacer(),
              Text(
                homework.subject,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary(context),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              IconButton(
                icon: Icon(Icons.delete_outline, size: 20, color: AppColors.danger(context)),
                onPressed: () => _confirmDelete(context),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) async {
    final confirmed = await confirmActionDialog(
      context,
      title: 'Delete Assignment',
      message: 'Are you sure you want to delete this assignment? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && context.mounted) {
      context.read<TeacherBloc>().add(TeacherHomeworkDeleted(homework.id));
    }
  }
}

