// Shared, theme-aware presentation primitives for both teacher experiences.
import 'package:flutter/material.dart';

class TeacherScaffold extends StatelessWidget {
  const TeacherScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: appBar,
    body: SafeArea(top: false, child: body),
    bottomNavigationBar: bottomNavigationBar,
    floatingActionButton: floatingActionButton,
  );
}
