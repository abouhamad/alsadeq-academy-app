import 'package:flutter/material.dart';

import '../constants/role.dart';

/// One entry in the app's main menu - shown as a full-width row on the
/// welcome/dashboard screen and as an icon+label on the persistent bottom
/// bar of each main section screen. Single source of truth so both places
/// can't drift out of sync.
class MenuSection {
  final IconData icon;
  final String label;
  final String path;

  const MenuSection({required this.icon, required this.label, required this.path});
}

List<MenuSection> menuSectionsForRole(AppRole role) {
  switch (role) {
    case AppRole.parent:
      return const [
        MenuSection(icon: Icons.home_outlined, label: 'Home', path: '/parent/home'),
        MenuSection(icon: Icons.schedule_outlined, label: 'Schedule', path: '/parent/schedule'),
        MenuSection(icon: Icons.qr_code_2_outlined, label: 'Pickup', path: '/pickup'),
        MenuSection(icon: Icons.campaign_outlined, label: 'Notice', path: '/notices'),
        MenuSection(icon: Icons.forum_outlined, label: 'Messages', path: '/messages'),
      ];
    case AppRole.teacher:
      return const [
        MenuSection(icon: Icons.home_outlined, label: 'Home', path: '/teacher/home'),
        MenuSection(icon: Icons.fact_check_outlined, label: 'Attendance', path: '/attendance/mark'),
        MenuSection(icon: Icons.campaign_outlined, label: 'Notice', path: '/notices'),
        MenuSection(icon: Icons.forum_outlined, label: 'Messages', path: '/messages'),
        MenuSection(icon: Icons.qr_code_scanner_outlined, label: 'Dismissal', path: '/dismissal'),
      ];
    default:
      return const [
        MenuSection(icon: Icons.menu_book_outlined, label: 'Homework', path: '/homework'),
        MenuSection(icon: Icons.campaign_outlined, label: 'Notices', path: '/notices'),
      ];
  }
}
