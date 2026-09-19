import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../providers/homework_provider.dart';

class HomeworkListScreen extends ConsumerWidget {
  const HomeworkListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homework = ref.watch(homeworkListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Homework'), actions: const [SignOutButton()]),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(homeworkListProvider.future),
        child: AsyncValueView(
          value: homework,
          isEmpty: (list) => list.isEmpty,
          emptyMessage: 'No homework assigned yet.',
          onRetry: () => ref.invalidate(homeworkListProvider),
          data: (context, list) {
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = list[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      child: Icon(Icons.menu_book_outlined),
                    ),
                    title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      [item.subject, item.submissionDate].whereType<String>().join(' • '),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/homework/detail', extra: item.raw),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
