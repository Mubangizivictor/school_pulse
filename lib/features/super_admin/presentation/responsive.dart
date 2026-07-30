import 'package:flutter/material.dart';

/// Below this width the owner console switches from the desktop sidebar/
/// multi-column layouts to a single-column, bottom-nav mobile layout.
const double kSuperAdminWideBreakpoint = 760;

bool isSuperAdminWide(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= kSuperAdminWideBreakpoint;
