import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_event.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

class StaffRolePickerScreen extends StatelessWidget {
  const StaffRolePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final roles = UserRole.values.where((r) => r != UserRole.parent).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Portal')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Your Role",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Please choose your primary responsibility to continue."),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3.2,
              ),
              itemCount: roles.length,
              itemBuilder: (context, index) {
                final role = roles[index];
                return _RoleTile(
                  role: role,
                  onTap: () => context.push('/staff/login?role=${role.name}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final UserRole role;
  final VoidCallback onTap;

  const _RoleTile({required this.role, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(
                _getIconForRole(role),
                size: 20,
                color: Theme.of(context).extension<SemanticColors>()?.primaryBlue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getDisplayName(role),
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForRole(UserRole role) {
    switch (role) {
      case UserRole.director: return Icons.account_balance;
      case UserRole.headTeacher: return Icons.school;
      case UserRole.deputyHead: return Icons.school_outlined;
      case UserRole.deanOfStudies: return Icons.auto_stories;
      case UserRole.schoolAdmin: return Icons.admin_panel_settings;
      case UserRole.bursar: return Icons.payments;
      case UserRole.classTeacher: return Icons.assignment_ind;
      case UserRole.subjectTeacher: return Icons.book;
      case UserRole.librarian: return Icons.local_library;
      case UserRole.nurse: return Icons.medical_services;
      case UserRole.boardingMatron: return Icons.bed;
      case UserRole.transportCoordinator: return Icons.directions_bus;
      case UserRole.guidanceDiscipline: return Icons.gavel;
      case UserRole.storeInventory: return Icons.inventory;
      case UserRole.gatekeeper: return Icons.security;
      case UserRole.securityHead: return Icons.admin_panel_settings;
      case UserRole.gamesMaster: return Icons.sports_soccer;
      case UserRole.cateringManager: return Icons.restaurant;
      case UserRole.religiousLeader: return Icons.church;
      case UserRole.receptionist: return Icons.support_agent;
      case UserRole.hrOfficer: return Icons.badge;
      default: return Icons.person;
    }
  }

  String _getDisplayName(UserRole role) => UserRoleDisplay.name(role);
}

class StaffCredentialsScreen extends StatefulWidget {
  final UserRole? initialRole;
  const StaffCredentialsScreen({super.key, this.initialRole});

  @override
  State<StaffCredentialsScreen> createState() => _StaffCredentialsScreenState();
}

class _StaffCredentialsScreenState extends State<StaffCredentialsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    context.read<AuthBloc>().add(LoginWithEmailPressed(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.mustChangePassword) {
            context.go('/auth/force-setup', extra: state.user);
          } else {
            context.go('/school-splash', extra: state.user);
          }
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(title: const Text('Staff Login')),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.lock, size: 64, color: Theme.of(context).extension<SemanticColors>()?.primaryBlue),
                    const SizedBox(height: 24),
                    Text(
                      "Staff Credentials",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.initialRole != null)
                       Padding(
                         padding: const EdgeInsets.only(top: 8.0),
                         child: Text(
                            "Logging in as ${UserRoleDisplay.name(widget.initialRole!)}",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          ),
                       ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Sign In',
                      isLoading: isLoading,
                      onPressed: isLoading ? null : _handleLogin,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text("Change role"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
