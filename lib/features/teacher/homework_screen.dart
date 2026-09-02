import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_homework.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_work/class_work_bloc.dart';
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
    _refresh();
  }

  void _refresh() {
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active == null) return;
    context.read<ClassWorkBloc>().add(ClassWorkRequested(active));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Classwork',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: BlocBuilder<ClassTeacherContextBloc, ClassTeacherContextState>(
        builder: (context, contextState) {
          if (contextState.active == null) {
            return const EmptyState(
              icon: Icons.class_outlined,
              title: 'No class assigned',
              message:
                  'You are not currently the Class Teacher for any class, '
                  'so there is no class work to set.',
            );
          }

          return BlocConsumer<ClassWorkBloc, ClassWorkState>(
            listenWhen: (previous, current) =>
                previous.errorMessage != current.errorMessage ||
                previous.successMessage != current.successMessage,
            listener: (context, state) {
              final message = state.successMessage ?? state.errorMessage;
              if (message == null) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(message),
                    backgroundColor: state.successMessage != null
                        ? AppColors.success(context)
                        : AppColors.danger(context),
                  ),
                );
              context.read<ClassWorkBloc>().add(
                const ClassWorkFeedbackCleared(),
              );
            },
            builder: (context, state) {
              if (state.isLoading) {
                return Center(child: const SchoolPulseLoader());
              }

              if (state.homework.isEmpty) {
                return EmptyState(
                  icon: Icons.assignment_outlined,
                  title: 'No classwork yet',
                  message: state.canCreate
                      ? 'Create homework or a class resource for this class.'
                      : 'There is no classwork for this class yet.',
                  ctaLabel: state.canCreate ? 'Create classwork' : null,
                  onCtaPressed: state.canCreate
                      ? () => _showHomeworkSheet(context, state)
                      : null,
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _refresh(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  itemCount: state.homework.length,
                  itemBuilder: (context, index) {
                    final homework = state.homework[index];
                    return _HomeworkCard(
                      homework: homework,
                      canPublish: state.canPublish,
                      onEdit: () => _showHomeworkSheet(
                        context,
                        state,
                        homework: homework,
                      ),
                      onPublish: () => context.read<ClassWorkBloc>().add(
                        ClassHomeworkPublished(homework),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<ClassWorkBloc, ClassWorkState>(
        builder: (context, state) {
          if (!state.canCreate) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () => _showHomeworkSheet(context, state),
            backgroundColor: AppColors.primary(context),
            tooltip: 'Create classwork',
            child: const Icon(
              Icons.add,
              color: Colors.white,
              semanticLabel: 'Create classwork',
            ),
          );
        },
      ),
    );
  }

  void _showHomeworkSheet(
    BuildContext context,
    ClassWorkState state, {
    ClassHomework? homework,
  }) {
    final bloc = context.read<ClassWorkBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.xl),
        ),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: bloc,
        child: _HomeworkSheet(homework: homework, canPublish: state.canPublish),
      ),
    );
  }
}

class _HomeworkSheet extends StatefulWidget {
  final ClassHomework? homework;
  final bool canPublish;

  const _HomeworkSheet({this.homework, required this.canPublish});

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
    _subjectController = TextEditingController(
      text: widget.homework?.subjectName,
    );
    _dueDate =
        widget.homework?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _attachments.addAll(widget.homework?.attachments ?? const []);
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
                isEditing ? 'Edit classwork' : 'New classwork',
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
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                style: TextStyle(color: AppColors.textPrimary(context)),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.m),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                style: TextStyle(color: AppColors.textPrimary(context)),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.m),
              TextFormField(
                controller: _descController,
                decoration: InputDecoration(
                  labelText: 'Instructions',
                  labelStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                style: TextStyle(color: AppColors.textPrimary(context)),
                maxLines: 3,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.m),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Due Date',
                  style: TextStyle(color: AppColors.textPrimary(context)),
                ),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy').format(_dueDate),
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
                trailing: Icon(
                  Icons.calendar_today,
                  color: AppColors.primary(context),
                ),
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
              ..._attachments.map(
                (a) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    a,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: AppColors.textPrimary(context)),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.danger(context),
                    ),
                    onPressed: () => setState(() => _attachments.remove(a)),
                  ),
                ),
              ),
              // File upload lands with the Resources phase, which owns storage
              // and its validation; linking one here instead of inventing a
              // filename keeps this honest in the meantime.
              TextButton.icon(
                onPressed: _addLink,
                icon: Icon(
                  Icons.attach_file,
                  color: AppColors.primary(context),
                ),
                label: Text(
                  'Add Link',
                  style: TextStyle(color: AppColors.primary(context)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (widget.canPublish) ...[
                PrimaryButton(
                  label: isEditing ? 'Save & publish' : 'Create & publish',
                  onPressed: () => _submit(publish: true),
                ),
                const SizedBox(height: AppSpacing.m),
                SecondaryButton(
                  label: 'Save as Draft',
                  onPressed: () => _submit(publish: false),
                ),
              ] else
                PrimaryButton(
                  label: isEditing ? 'Save Changes' : 'Save as Draft',
                  onPressed: () => _submit(publish: false),
                ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addLink() async {
    final controller = TextEditingController();
    final link = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated(dialogContext),
        title: const Text('Add a link'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: 'https://...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.of(dialogContext).pop(text);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (link != null) setState(() => _attachments.add(link));
  }

  void _submit({required bool publish}) {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final existing = widget.homework;
    final homework = existing == null
        // A blank id is what tells the repository this is new; it stamps the
        // school, class and year from the verified context rather than
        // trusting anything this form holds.
        ? ClassHomework(
            id: '',
            schoolId: '',
            classId: '',
            academicYearId: '',
            title: _titleController.text,
            description: _descController.text,
            subjectName: _subjectController.text,
            dueDate: _dueDate,
            attachments: _attachments,
            createdAt: DateTime.now(),
          )
        : existing.copyWith(
            title: _titleController.text,
            description: _descController.text,
            subjectName: _subjectController.text,
            dueDate: _dueDate,
            attachments: _attachments,
          );

    context.read<ClassWorkBloc>().add(
      ClassHomeworkSaved(homework, publish: publish),
    );
    Navigator.of(context).pop();
  }
}

class _HomeworkCard extends StatelessWidget {
  final ClassHomework homework;
  final bool canPublish;
  final VoidCallback onEdit;
  final VoidCallback onPublish;

  const _HomeworkCard({
    required this.homework,
    required this.canPublish,
    required this.onEdit,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    final status = homework.effectiveStatus();
    final color = _colorFor(context, status);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              StatusBadge(label: status.label, color: color),
            ],
          ),
          if (homework.subjectName?.isNotEmpty ?? false) ...[
            const SizedBox(height: 2),
            Text(
              homework.subjectName!,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted(context),
              ),
            ),
          ],
          if (homework.description.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              homework.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 16,
                color: AppColors.textMuted(context),
              ),
              const SizedBox(width: 4),
              Text(
                'Due ${DateFormat('MMM dd, yyyy').format(homework.dueDate)}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              const Spacer(),
              // Offered only on drafts, and only to a teacher who holds the
              // publish permission - drafting and reaching parents are
              // deliberately different rights.
              if (homework.isDraft && canPublish)
                TextButton(
                  onPressed: onPublish,
                  child: Text(
                    'Publish',
                    style: TextStyle(color: AppColors.primary(context)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _colorFor(BuildContext context, ClassHomeworkStatus status) =>
      switch (status) {
        ClassHomeworkStatus.overdue => AppColors.danger(context),
        ClassHomeworkStatus.dueSoon => AppColors.warning(context),
        ClassHomeworkStatus.active ||
        ClassHomeworkStatus.published => AppColors.success(context),
        ClassHomeworkStatus.completed => AppColors.information(context),
        ClassHomeworkStatus.cancelled => AppColors.danger(context),
        _ => AppColors.textMuted(context),
      };
}
