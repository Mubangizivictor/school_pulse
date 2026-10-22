import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_cash_bank_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_payroll_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_petty_cash_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_suppliers_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/expenditure_screen.dart';
import 'package:school_pulse/features/finance/presentation/screens/web/bursar_web_overview_screen.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// The Fees tab's content, hosted entirely inside [AdminShell] — School
/// Admin never leaves the admin console's own sidebar/bottom-nav chrome to
/// reach this. Every tab below is the exact same screen widget the Bursar
/// console uses (same BLoCs, same repositories, same write callables), just
/// reached from a different shell. School Admin already carries the
/// `bursar`-equivalent permission on every one of these screens' own
/// backend checks (see `_reconcileRoles`/callable-side role checks in each
/// screen) so no new authorization surface is introduced here.
class AdminFeesScreen extends StatefulWidget {
  const AdminFeesScreen({super.key});

  @override
  State<AdminFeesScreen> createState() => _AdminFeesScreenState();
}

class _AdminFeesScreenState extends State<AdminFeesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 6, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();

    return BlocProvider(
      create: (_) => di.sl<FinanceBloc>(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.surfaceElevated(context),
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              labelColor: AppColors.textPrimary(context),
              unselectedLabelColor: AppColors.textMuted(context),
              indicatorColor: AppColors.primary(context),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Payroll'),
                Tab(text: 'Expenses'),
                Tab(text: 'Cash & bank'),
                Tab(text: 'Suppliers'),
                Tab(text: 'Petty cash'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                BursarWebOverviewScreen(),
                BursarPayrollScreen(),
                ExpenditureScreen(),
                BursarCashBankScreen(),
                BursarSuppliersScreen(),
                BursarPettyCashScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
