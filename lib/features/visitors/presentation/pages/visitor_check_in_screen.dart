import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_state.dart';
import 'package:school_pulse/features/visitors/presentation/widgets/badge_widget.dart';
import 'package:school_pulse/features/visitors/presentation/widgets/signature_pad.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/entities/pre_approved_visitor.dart';
import '../../domain/entities/scheduled_visit.dart';
import '../bloc/visitors_bloc.dart';
import '../bloc/visitors_event.dart';
import '../bloc/visitors_state.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:school_pulse/core/services/printer/printer_service.dart';
import 'package:school_pulse/injection_container.dart';

const _kDefaultVisitorGates = ['Main Gate'];

class VisitorCheckInScreen extends StatefulWidget {
  final PreApprovedVisitor? preApprovedVisitor;
  final ScheduledVisit? scheduledVisit;

  const VisitorCheckInScreen({super.key, this.preApprovedVisitor, this.scheduledVisit});

  @override
  State<VisitorCheckInScreen> createState() => _VisitorCheckInScreenState();
}

class _VisitorCheckInScreenState extends State<VisitorCheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _parkingSlotController = TextEditingController();
  final _companyController = TextEditingController();
  final _hostController = TextEditingController();
  final _departmentController = TextEditingController();
  final _purposeController = TextEditingController();
  final _expectedDurationController = TextEditingController();
  final _itemsCarriedController = TextEditingController();
  final _notesController = TextEditingController();

  File? _image;
  File? _idImage;
  ui.Image? _signatureImage;
  final _picker = ImagePicker();
  bool _isBlacklisted = false;
  VisitorCategory _category = VisitorCategory.personal;
  String? _selectedGate;
  bool _agreementAccepted = false;

  Student? _selectedStudent;
  final _studentSearchController = TextEditingController();

  List<String> _availableGates(BuildContext context) {
    final gates = context.watch<ThemeProvider>().config?.visitorGates;
    return (gates != null && gates.isNotEmpty) ? gates : _kDefaultVisitorGates;
  }

  @override
  void initState() {
    super.initState();
    if (widget.preApprovedVisitor != null) {
      _fullNameController.text = widget.preApprovedVisitor!.fullName;
      _phoneController.text = widget.preApprovedVisitor!.phone;
      _purposeController.text = widget.preApprovedVisitor!.purpose;
      _hostController.text = widget.preApprovedVisitor!.host;
    }
    if (widget.scheduledVisit != null) {
      _fullNameController.text = widget.scheduledVisit!.fullName;
      _phoneController.text = widget.scheduledVisit!.phone;
      _purposeController.text = widget.scheduledVisit!.purpose;
      _hostController.text = widget.scheduledVisit!.host;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _vehicleNumberController.dispose();
    _parkingSlotController.dispose();
    _companyController.dispose();
    _hostController.dispose();
    _departmentController.dispose();
    _purposeController.dispose();
    _expectedDurationController.dispose();
    _itemsCarriedController.dispose();
    _notesController.dispose();
    _studentSearchController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 800,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _takeIdPhoto() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      maxWidth: 1200,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _idImage = File(pickedFile.path);
      });
    }
  }

  void _onStudentSelected(Student student) {
    setState(() {
      _selectedStudent = student;
      if (_purposeController.text.isEmpty) {
        _purposeController.text = 'Visiting ${student.name} (${student.className})';
      }
    });
  }

  Future<String?> _saveSignature() async {
    if (_signatureImage == null) return null;
    final byteData = await _signatureImage!.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return null;
    
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return path;
  }

  void _checkBlacklist(String phone) {
    final state = context.read<VisitorsBloc>().state;
    if (state is VisitorsLoaded) {
      final isBlacklisted = state.blacklist.any((b) =>
          (b.phone.isNotEmpty && b.phone == phone) ||
          (b.fullName.isNotEmpty && b.fullName.toLowerCase() == _fullNameController.text.toLowerCase()));
      if (isBlacklisted != _isBlacklisted) {
        setState(() {
          _isBlacklisted = isBlacklisted;
        });
      }
    }
  }

  Future<void> _onPhoneChanged(String phone) async {
    _checkBlacklist(phone);
    if (phone.length >= 9) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        if (!mounted) return;
        context.read<VisitorsBloc>().add(SearchVisitorsEvent(authState.user.schoolId, phone));
      }
    }
  }

  void _autoFillFromHistory(Visitor visitor) {
    setState(() {
      _fullNameController.text = visitor.fullName;
      _companyController.text = visitor.company ?? '';
      _vehicleNumberController.text = visitor.vehicleNumber ?? '';
      _category = visitor.category;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == VisitorCategory.parent && _selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select which student this parent is visiting')),
      );
      return;
    }
    if (!_agreementAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the visitor agreement to continue')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final gates = _availableGates(context);
    final selectedGate = (_selectedGate != null && gates.contains(_selectedGate)) ? _selectedGate! : gates.first;

    final signaturePath = await _saveSignature();
    if (!mounted) return;

    final visitor = Visitor(
      id: const Uuid().v4(),
      schoolId: authState.user.schoolId,
      fullName: _fullNameController.text,
      phone: _phoneController.text,
      vehicleNumber: _vehicleNumberController.text.isEmpty ? null : _vehicleNumberController.text,
      parkingSlot: _parkingSlotController.text.isEmpty ? null : _parkingSlotController.text,
      company: _companyController.text.isEmpty ? null : _companyController.text,
      host: _hostController.text,
      hostId: widget.scheduledVisit?.hostId,
      department: _departmentController.text,
      purpose: _purposeController.text,
      category: _category,
      expectedDuration: _expectedDurationController.text.isEmpty ? null : _expectedDurationController.text,
      itemsCarried: _itemsCarriedController.text.isEmpty ? null : _itemsCarriedController.text,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      arrivalTime: DateTime.now(),
      status: VisitorStatus.checkedIn,
      deviceId: 'local_device',
      gateId: selectedGate,
      photoLocalPath: _image?.path,
      idImageLocalPath: _idImage?.path,
      signatureLocalPath: signaturePath,
      isBlacklisted: _isBlacklisted,
      agreementAccepted: _agreementAccepted,
      scheduledVisitId: widget.scheduledVisit?.id,
      studentId: _selectedStudent?.id,
    );

    context.read<VisitorsBloc>().add(CheckInNewVisitor(
          visitor,
          preApprovedId: widget.preApprovedVisitor?.id,
        ));
    
    // Show Preview/Print Badge Dialog
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check-in Successful'),
        content: SingleChildScrollView(
          child: VisitorBadgeWidget(
            visitor: visitor,
            schoolName: authState.user.schoolName ?? 'School Pulse',
          ),
        ),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('Close')),
          ElevatedButton(onPressed: () async {
            final printerService = sl<PrinterService>();
            final isConnected = await printerService.isConnected();
            if (isConnected) {
              await printerService.printVisitorBadge(visitor);
              if (context.mounted) context.pop();
            } else {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Printer not connected. Please check settings.')),
                );
              }
            }
          }, child: const Text('Print Badge')),
        ],
      ),
    ).then((_) {
      if (mounted) context.pop();
    });
  }

  Widget _buildIdPhotoCapture(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _takeIdPhoto,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 72,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
              image: _idImage != null ? DecorationImage(image: FileImage(_idImage!), fit: BoxFit.cover) : null,
            ),
            child: _idImage == null
                ? const Icon(Icons.badge_outlined, color: Colors.grey)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('National ID / Passport photo (optional)', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: _takeIdPhoto,
                    icon: Icon(_idImage == null ? Icons.camera_alt_outlined : Icons.refresh, size: 18),
                    label: Text(_idImage == null ? 'Take Photo' : 'Retake'),
                  ),
                  if (_idImage != null)
                    TextButton(
                      onPressed: () => setState(() => _idImage = null),
                      child: const Text('Remove'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParentStudentSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Which student are you visiting? *', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _studentSearchController,
            decoration: InputDecoration(
              hintText: 'Search enrolled student by name or ID',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              isDense: true,
            ),
            onChanged: (query) {
              if (query.trim().isEmpty) return;
              context.read<StudentsBloc>().add(SearchStudents(query.trim()));
            },
          ),
          if (_selectedStudent != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_selectedStudent!.name} • ${_selectedStudent!.className}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedStudent = null),
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
          ] else
            BlocBuilder<StudentsBloc, StudentsState>(
              builder: (context, state) {
                if (_studentSearchController.text.trim().isEmpty) return const SizedBox.shrink();
                if (state is StudentsLoading) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (state is StudentsLoaded) {
                  if (state.students.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No enrolled student matches that search.'),
                    );
                  }
                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    constraints: const BoxConstraints(maxHeight: 220),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.students.length,
                      itemBuilder: (context, index) {
                        final student = state.students[index];
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.school_outlined),
                          title: Text(student.name),
                          subtitle: Text('${student.className} • ${student.studentId}'),
                          onTap: () => _onStudentSelected(student),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visitor Check-in'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isBlacklisted)
                const AlertBanner(
                  title: 'Blacklist Warning',
                  message: 'This visitor is on the blacklist. Please follow security protocols.',
                  color: Colors.red,
                  icon: Icons.warning,
                ),
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _image != null ? FileImage(_image!) : null,
                      child: _image == null
                          ? const Icon(Icons.person, size: 60, color: Colors.grey)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white),
                          onPressed: _takePhoto,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Visitor photo (optional)',
                  style: TextStyle(color: Theme.of(context).colorScheme.outline, fontSize: 12),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<VisitorCategory>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
                      items: VisitorCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))).toList(),
                      onChanged: (v) => setState(() {
                        _category = v!;
                        if (_category != VisitorCategory.parent) _selectedStudent = null;
                      }),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Builder(builder: (context) {
                      final gates = _availableGates(context);
                      final selected = (_selectedGate != null && gates.contains(_selectedGate)) ? _selectedGate : gates.first;
                      return DropdownButtonFormField<String>(
                        initialValue: selected,
                        decoration: const InputDecoration(labelText: 'Gate', prefixIcon: Icon(Icons.door_front_door_outlined)),
                        items: gates.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                        onChanged: (v) => setState(() => _selectedGate = v),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onChanged: (_) => _checkBlacklist(_phoneController.text),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number *',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  suffixIcon: BlocBuilder<VisitorsBloc, VisitorsState>(
                    builder: (context, state) {
                      if (state is VisitorsLoaded && _phoneController.text.length >= 9) {
                        final history = state.visitors.where((v) => v.phone == _phoneController.text).toList();
                        if (history.isNotEmpty) {
                          return IconButton(
                            icon: const Icon(Icons.history, color: Colors.blue),
                            onPressed: () => _autoFillFromHistory(history.first),
                            tooltip: 'Auto-fill from history',
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onChanged: _onPhoneChanged,
              ),
              const SizedBox(height: 16),
              _buildIdPhotoCapture(context),
              const SizedBox(height: 16),
              TextFormField(
                controller: _vehicleNumberController,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number (optional)',
                  prefixIcon: Icon(Icons.directions_car_outlined),
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (_vehicleNumberController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _parkingSlotController,
                  decoration: const InputDecoration(
                    labelText: 'Parking Slot (optional)',
                    prefixIcon: Icon(Icons.local_parking_outlined),
                  ),
                ),
              ],
              if (_category == VisitorCategory.parent) ...[
                const SizedBox(height: 16),
                _buildParentStudentSection(context),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _hostController,
                decoration: const InputDecoration(
                  labelText: 'Person to Visit (Host) *',
                  prefixIcon: Icon(Icons.account_box_outlined),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose of Visit *',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(
                  labelText: 'Department *',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _itemsCarriedController,
                decoration: const InputDecoration(
                  labelText: 'Items Carried (e.g. Laptop)',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Visitor Agreement: By checking in, you confirm the information provided is '
                  'accurate, agree to abide by all school premises rules and safety guidelines '
                  'while on campus, and consent to being escorted or asked to leave at the '
                  'discretion of school security staff.',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _agreementAccepted,
                onChanged: (v) => setState(() => _agreementAccepted = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text('I have read and agree to the visitor agreement above'),
              ),
              const SizedBox(height: 8),
              const Text('Visitor Signature (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SignaturePad(
                onChanged: (image) {
                  _signatureImage = image;
                },
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Check In Visitor',
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

