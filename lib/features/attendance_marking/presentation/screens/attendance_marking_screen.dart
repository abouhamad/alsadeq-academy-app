import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../providers/attendance_marking_provider.dart';

const _statusOptions = [
  ('P', 'Present'),
  ('L', 'Late'),
  ('A', 'Absent'),
  ('E', 'Excused'),
];

class AttendanceMarkingScreen extends ConsumerWidget {
  const AttendanceMarkingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(attendanceMarkingControllerProvider);
    final controller = ref.read(attendanceMarkingControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take attendance'),
        actions: [
          TextButton(
            onPressed: () => context.push('/attendance'),
            child: const Text('My report', style: TextStyle(color: Colors.white)),
          ),
          const SignOutButton(),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: state.classId,
                    decoration: const InputDecoration(labelText: 'Class'),
                    items: [
                      for (final c in state.classes) DropdownMenuItem(value: c.id, child: Text(c.name)),
                    ],
                    onChanged: (value) {
                      if (value != null) controller.selectClass(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: state.sectionId,
                    decoration: const InputDecoration(labelText: 'Section'),
                    items: [
                      for (final s in state.sections) DropdownMenuItem(value: s.id, child: Text(s.name)),
                    ],
                    onChanged: state.classId == null
                        ? null
                        : (value) {
                            if (value != null) controller.selectSection(value);
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(DateFormat('EEE, MMM d, yyyy').format(state.date)),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: state.date,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) controller.selectDate(picked);
              },
            ),
            const SizedBox(height: 16),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(state.error!, style: const TextStyle(color: AppColors.error)),
              ),
            if (state.isLoading) const LinearProgressIndicator(),
            Expanded(
              child: state.classId == null || state.sectionId == null
                  ? const Center(
                      child: Text('Choose a class and section to load the roster.',
                          style: TextStyle(color: AppColors.textSecondary)),
                    )
                  : state.roster.isEmpty && !state.isLoading
                      ? const Center(
                          child: Text('No students found for this class and section.',
                              style: TextStyle(color: AppColors.textSecondary)),
                        )
                      : ListView.separated(
                          itemCount: state.roster.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final student = state.roster[index];
                            final status = state.statusByStudent[student.studentId];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Wrap(
                                    spacing: 4,
                                    children: [
                                      for (final option in _statusOptions)
                                        ChoiceChip(
                                          label: Text(option.$2),
                                          selected: status == option.$1,
                                          onSelected: (_) => controller.setStatus(student.studentId, option.$1),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
            if (state.classId != null && state.sectionId != null && state.roster.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: ElevatedButton(
                  onPressed: state.isSaving
                      ? null
                      : () async {
                          final success = await controller.save();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? 'Attendance saved.' : 'Could not save attendance.'),
                              ),
                            );
                          }
                        },
                  child: state.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
