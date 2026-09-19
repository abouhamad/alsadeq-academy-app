import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/role.dart';
import '../../../../core/navigation/menu_sections.dart';
import '../../../../shared/widgets/menu_list_button.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Welcome screen: a full-width list of the role's main sections. Each
/// section also gets a persistent bottom bar of its own (see
/// [MainScaffold]) once opened, so this list is the "big, easy to read"
/// entry point rather than the only way to switch sections.
class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final role = user?.role ?? AppRole.unknown;
    final sections = menuSectionsForRole(role);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
          const SignOutButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user?.fullName.isNotEmpty == true ? 'Welcome, ${user!.fullName}' : 'Welcome',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: sections.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final section = sections[index];
                  return MenuListButton(
                    icon: section.icon,
                    label: section.label,
                    onTap: () => context.push(section.path),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
