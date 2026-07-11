import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(body: Center(child: Text('Login Screen'))),
      ),
      // TODO: Add more routes as features are implemented
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Academics'),
              ],
              onTap: (index) {
                // Navigation logic here
              },
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/parent/home',
            builder: (context, state) => const Center(child: Text('Parent Home')),
          ),
          GoRoute(
            path: '/parent/academics',
            builder: (context, state) => const Center(child: Text('Academics')),
          ),
        ],
      ),
    ],
  );
});
