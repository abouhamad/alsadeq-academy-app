import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../../data/models/routine_entry_model.dart';
import '../providers/routine_provider.dart';

class RoutineScreen extends ConsumerWidget {
  const RoutineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routine = ref.watch(routineListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Class routine'), actions: const [SignOutButton()]),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(routineListProvider.future),
        child: AsyncValueView(
          value: routine,
          isEmpty: (list) => list.isEmpty,
          emptyMessage: 'No routine published yet.',
          onRetry: () => ref.invalidate(routineListProvider),
          data: (context, list) {
            final byDay = <String, List<RoutineEntryModel>>{};
            for (final entry in list) {
              byDay.putIfAbsent(entry.day.isEmpty ? 'Schedule' : entry.day, () => []).add(entry);
            }

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: byDay.entries.map((dayGroup) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayGroup.key,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      ...dayGroup.value.map(
                        (entry) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.schedule, color: AppColors.primary),
                            title: Text(entry.subject ?? 'Class'),
                            subtitle: entry.room != null ? Text('Room ${entry.room}') : null,
                            trailing: Text(
                              [entry.startTime, entry.endTime].whereType<String>().join(' - '),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
