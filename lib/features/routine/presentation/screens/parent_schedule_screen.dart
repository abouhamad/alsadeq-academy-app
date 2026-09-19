import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/child_selector_dropdown.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../../../children/presentation/providers/children_provider.dart';
import '../providers/routine_provider.dart';

const _weekDays = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

final _selectedScheduleDayProvider = StateProvider<String>((ref) => _weekDays[DateTime.now().weekday % 7]);

/// Child dropdown + day dropdown; picking a day filters that child's
/// routine down to just that day's classes.
class ParentScheduleScreen extends ConsumerWidget {
  const ParentScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChild = ref.watch(selectedChildProvider);
    final selectedDay = ref.watch(_selectedScheduleDayProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule'), actions: const [SignOutButton()]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ChildSelectorDropdown(),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedDay,
              decoration: const InputDecoration(labelText: 'Day'),
              items: [for (final day in _weekDays) DropdownMenuItem(value: day, child: Text(day))],
              onChanged: (day) {
                if (day != null) ref.read(_selectedScheduleDayProvider.notifier).state = day;
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: selectedChild == null
                  ? const SizedBox.shrink()
                  : _DaySchedule(studentId: selectedChild.studentId, day: selectedDay),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaySchedule extends ConsumerWidget {
  const _DaySchedule({required this.studentId, required this.day});

  final int studentId;
  final String day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routine = ref.watch(routineForChildProvider(studentId));

    return AsyncValueView(
      value: routine,
      onRetry: () => ref.invalidate(routineForChildProvider(studentId)),
      data: (context, list) {
        final entries = list.where((e) => e.day.toLowerCase() == day.toLowerCase()).toList();
        if (entries.isEmpty) {
          return const Center(
            child: Text('No classes scheduled for this day.', style: TextStyle(color: AppColors.textSecondary)),
          );
        }
        return ListView.separated(
          itemCount: entries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.schedule, color: AppColors.primary),
                title: Text(entry.subject ?? 'Class'),
                subtitle: entry.room != null ? Text('Room ${entry.room}') : null,
                trailing: Text(
                  [entry.startTime, entry.endTime].whereType<String>().join(' - '),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
