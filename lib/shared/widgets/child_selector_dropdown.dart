import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/children/presentation/providers/children_provider.dart';
import 'error_view.dart';
import 'loading_indicator.dart';

/// Dropdown of the logged-in parent's children, shared verbatim by the
/// Home/Schedule/Pickup screens. Defaults to the first child on first load
/// and keeps [selectedChildProvider] in sync as the user switches.
class ChildSelectorDropdown extends ConsumerWidget {
  const ChildSelectorDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(childrenListProvider);

    return childrenAsync.when(
      loading: () => const LoadingIndicator(),
      error: (error, _) => ErrorView(
        message: error.toString(),
        onRetry: () => ref.invalidate(childrenListProvider),
      ),
      data: (children) {
        if (children.isEmpty) {
          return const Text('No children linked to this account.');
        }

        final current = ref.watch(selectedChildProvider);
        final selected = children.any((c) => c.studentId == current?.studentId)
            ? current
            : children.first;

        if (selected != current) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedChildProvider.notifier).state = selected;
          });
        }

        return DropdownButtonFormField<int>(
          value: selected?.studentId,
          decoration: const InputDecoration(labelText: 'Child'),
          items: [
            for (final child in children)
              DropdownMenuItem(value: child.studentId, child: Text(child.fullName)),
          ],
          onChanged: (studentId) {
            final child = children.firstWhere((c) => c.studentId == studentId);
            ref.read(selectedChildProvider.notifier).state = child;
          },
        );
      },
    );
  }
}
