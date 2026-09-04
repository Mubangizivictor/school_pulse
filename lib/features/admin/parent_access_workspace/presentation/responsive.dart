/// Three-tier responsive breakpoints for the Parents & access workspace,
/// following the single-constant/bool-helper convention already used by
/// `lib/features/super_admin/presentation/responsive.dart`. Two cutoffs
/// (tablet, web) rather than super_admin's one, because this spec explicitly
/// names three distinct layouts (phone/tablet/web), not just
/// compact-vs-wide.
const double kParentAccessTabletBreakpoint = 760;
const double kParentAccessWebBreakpoint = 1024;

bool isParentAccessTablet(double width) =>
    width >= kParentAccessTabletBreakpoint && width < kParentAccessWebBreakpoint;

bool isParentAccessWeb(double width) => width >= kParentAccessWebBreakpoint;

bool isParentAccessPhone(double width) => width < kParentAccessTabletBreakpoint;
