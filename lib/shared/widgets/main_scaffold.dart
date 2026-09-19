import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/role.dart';
import '../../core/navigation/menu_sections.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Wraps a main section screen (Home, Schedule, Attendance, ...) with a
/// persistent bottom bar mirroring the same items shown as a list on the
/// welcome screen, so the user doesn't have to go back to the dashboard to
/// switch sections. Detail screens pushed on top (homework detail, a
/// message thread, ...) are left unwrapped, per the app's usual back-arrow
/// full-screen convention.
class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key, required this.currentPath, required this.child});

  final String currentPath;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authControllerProvider).user?.role ?? AppRole.unknown;
    final sections = menuSectionsForRole(role);
    final currentIndex = sections.indexWhere((s) => s.path == currentPath);

    return Scaffold(
      body: child,
      bottomNavigationBar: sections.isEmpty
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex < 0 ? 0 : currentIndex,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              onTap: (index) {
                if (index == currentIndex) return;
                context.go(sections[index].path);
              },
              items: [
                for (final section in sections)
                  BottomNavigationBarItem(icon: Icon(section.icon), label: section.label),
              ],
            ),
    );
  }
}
