# school_pulse

A modern school management system standardizing the experience across Web and Mobile.

## Core Business Rules & Constraints

### User Access & Roles
- **Universal Access**: All user roles (Staff, Parents, Admins) have full access to both Web and Mobile platforms.
- **Platform Consistency**: Navigation is unified via sidebars (Web/Desktop) and "More" menus (Mobile).

### Parent-Student Allocation
- **Student Limit**: A student can be linked to a maximum of **2 parents** (e.g., Mother and Father).
- **Parent Capacity**: A single parent account can be linked to **many students** (siblings).
- **Allocation Locking**: Once a student is allocated to a parent, they cannot be reallocated by non-admin users.
- **Admin Authority**: Only School Administrators have the permission to edit or reallocate student-parent links.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
