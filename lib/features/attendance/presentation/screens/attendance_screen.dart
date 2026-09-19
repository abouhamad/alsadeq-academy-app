import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../providers/attendance_provider.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendance = ref.watch(attendanceListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance'), actions: const [SignOutButton()]),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(attendanceListProvider.future),
        child: AsyncValueView(
          value: attendance,
          isEmpty: (list) => list.isEmpty,
          emptyMessage: 'No attendance records found.',
          onRetry: () => ref.invalidate(attendanceListProvider),
          data: (context, list) {
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = list[index];
                final color = item.isPresent
                    ? AppColors.success
                    : item.isAbsent
                        ? AppColors.error
                        : AppColors.warning;
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Icon(
                        item.isPresent
                            ? Icons.check
                            : item.isAbsent
                                ? Icons.close
                                : Icons.help_outline,
                        color: color,
                      ),
                    ),
                    title: Text(item.date ?? 'Unknown date'),
                    subtitle: Text(item.status),
                    trailing: item.note != null ? Text(item.note!) : null,
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
