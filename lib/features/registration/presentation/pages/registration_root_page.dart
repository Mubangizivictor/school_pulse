import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/registration_bloc.dart';
import '../bloc/registration_state.dart';
import '../registration_theme.dart';
import 'application_status_page.dart';
import 'registration_welcome_page.dart';
import 'step1_school_details_page.dart';
import 'step2_admin_account_page.dart';
import 'step3_calendar_page.dart';
import 'step4_students_pricing_page.dart';
import 'step5_address_page.dart';
import 'step6_review_page.dart';

/// Public entry point for the mobile school-registration wizard, mounted at
/// GoRouter's /register-school route (outside any authenticated shell/
/// redirect guard). Owns the single RegistrationBloc instance for the whole
/// wizard and switches screens purely off wizard step / submit phase, so
/// back/forward navigation never desyncs from the BLoC's state.
class RegistrationRootPage extends StatelessWidget {
  const RegistrationRootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegistrationBloc(),
      child: Theme(
        data: regTheme(),
        child: const _RegistrationRootBody(),
      ),
    );
  }
}

class _RegistrationRootBody extends StatelessWidget {
  const _RegistrationRootBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegistrationBloc, RegistrationState>(
      buildWhen: (a, b) => a.step != b.step || a.submitPhase != b.submitPhase,
      builder: (context, state) {
        if (state.submitPhase == SubmitPhase.submitted) {
          return const ApplicationStatusPage();
        }
        switch (state.step) {
          case RegWizardStep.welcome:
            return const RegistrationWelcomePage();
          case RegWizardStep.schoolDetails:
            return const Step1SchoolDetailsPage();
          case RegWizardStep.adminAccount:
            return const Step2AdminAccountPage();
          case RegWizardStep.calendar:
            return const Step3CalendarPage();
          case RegWizardStep.studentCount:
            return const Step4StudentsPricingPage();
          case RegWizardStep.address:
            return const Step5AddressPage();
          case RegWizardStep.review:
            return const Step6ReviewPage();
        }
      },
    );
  }
}
