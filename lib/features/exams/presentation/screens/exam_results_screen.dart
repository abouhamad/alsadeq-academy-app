import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../providers/exams_provider.dart';

class ExamResultsScreen extends ConsumerWidget {
  const ExamResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(examScheduleListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Exams'), actions: const [SignOutButton()]),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(examScheduleListProvider.future),
        child: AsyncValueView(
          value: schedule,
          isEmpty: (list) => list.isEmpty,
          emptyMessage: 'No exams scheduled yet.',
          onRetry: () => ref.invalidate(examScheduleListProvider),
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
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.secondary,
                      child: Icon(Icons.edit_note, color: Colors.white),
                    ),
                    title: Text(item.examName, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      [item.subject, item.date].whereType<String>().join(' • '),
                    ),
                    trailing: Text(
                      [item.startTime, item.endTime].whereType<String>().join('-'),
                      style: const TextStyle(fontSize: 12),
                    ),
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
