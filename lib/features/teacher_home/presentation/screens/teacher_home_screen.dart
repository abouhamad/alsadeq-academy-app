import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../../../homework/presentation/providers/homework_provider.dart';
import '../providers/teacher_home_provider.dart';

const _weekDays = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedScheduleDayProvider);
    final schedule = ref.watch(teacherScheduleProvider);
    final homework = ref.watch(homeworkListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home'), actions: const [SignOutButton()]),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(teacherScheduleProvider);
          ref.invalidate(homeworkListProvider);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            DropdownButtonFormField<String>(
              value: selectedDay,
              decoration: const InputDecoration(labelText: 'Day'),
              items: [for (final day in _weekDays) DropdownMenuItem(value: day, child: Text(day))],
              onChanged: (day) {
                if (day != null) ref.read(selectedScheduleDayProvider.notifier).state = day;
              },
            ),
            const SizedBox(height: 16),
            AsyncValueView(
              value: schedule,
              isEmpty: (list) => list.where((e) => e.day == selectedDay).isEmpty,
              emptyMessage: 'No classes scheduled for this day.',
              onRetry: () => ref.invalidate(teacherScheduleProvider),
              data: (context, list) {
                final entries = list.where((e) => e.day == selectedDay).toList();
                return Column(
                  children: entries.map((entry) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.school_outlined, color: AppColors.primary),
                        title: Text(entry.classLabel),
                        subtitle: entry.room != null ? Text('Room ${entry.room}') : null,
                        trailing: Text(
                          [entry.startTime, entry.endTime].whereType<String>().join(' - '),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Recent homework', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            AsyncValueView(
              value: homework,
              isEmpty: (list) => list.isEmpty,
              emptyMessage: 'No homework assigned yet.',
              onRetry: () => ref.invalidate(homeworkListProvider),
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
            ),
          ],
        ),
      ),
    );
  }
}
