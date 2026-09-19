import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/child_selector_dropdown.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../children/presentation/providers/children_provider.dart';
import '../../../homework/presentation/providers/homework_provider.dart';
import '../../../notices/presentation/providers/notices_provider.dart';

/// Composes the children/homework/notices features rather than owning its
/// own repository - this screen is purely a "parent's dashboard" layout.
class ParentHomeScreen extends ConsumerWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final selectedChild = ref.watch(selectedChildProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home'), actions: const [SignOutButton()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null && user.fullName.isNotEmpty)
            Text('Welcome, ${user.fullName}', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          const ChildSelectorDropdown(),
          const SizedBox(height: 24),
          const Text('Homework', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (selectedChild?.recordId == null)
            const Text('No homework to show yet.', style: TextStyle(color: AppColors.textSecondary))
          else
            _HomeworkPreview(recordId: selectedChild!.recordId!),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notice board', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(
                onPressed: () => context.push('/notices'),
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const _NoticesPreview(),
        ],
      ),
    );
  }
}

class _HomeworkPreview extends ConsumerWidget {
  const _HomeworkPreview({required this.recordId});

  final int recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homework = ref.watch(homeworkForChildProvider(recordId));

    return AsyncValueView(
      value: homework,
      isEmpty: (list) => list.isEmpty,
      emptyMessage: 'No homework assigned yet.',
      onRetry: () => ref.invalidate(homeworkForChildProvider(recordId)),
      data: (context, list) {
        return Column(
          children: list.take(5).map((item) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.menu_book_outlined, color: AppColors.primary),
                title: Text(item.title),
                subtitle: item.submissionDate != null ? Text('Due ${item.submissionDate}') : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _NoticesPreview extends ConsumerWidget {
  const _NoticesPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(noticesListProvider);

    return AsyncValueView(
      value: notices,
      isEmpty: (list) => list.isEmpty,
      emptyMessage: 'No notices posted yet.',
      onRetry: () => ref.invalidate(noticesListProvider),
      data: (context, list) {
        return Column(
          children: list.take(3).map((item) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.campaign_outlined, color: AppColors.primary),
                title: Text(item.title),
                subtitle: item.date != null ? Text(item.date!) : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
