import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../../data/models/homework_model.dart';

class HomeworkDetailScreen extends StatelessWidget {
  const HomeworkDetailScreen({super.key, required this.homework});

  final Map<String, dynamic> homework;

  @override
  Widget build(BuildContext context) {
    final item = HomeworkModel(homework);

    return Scaffold(
      appBar: AppBar(title: const Text('Homework details'), actions: const [SignOutButton()]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (item.subject != null)
              Chip(label: Text(item.subject!), backgroundColor: AppColors.primary.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            if (item.homeworkDate != null) _InfoRow(label: 'Assigned on', value: item.homeworkDate!),
            if (item.submissionDate != null) _InfoRow(label: 'Due by', value: item.submissionDate!),
            const SizedBox(height: 16),
            if (item.description != null) ...[
              const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(item.description!, style: const TextStyle(color: AppColors.textSecondary)),
            ],
            if (item.fileUrl != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: wire to url_launcher against ApiEndpoints.studentHomeworkFileDownload
                  // or item.fileUrl directly once confirmed absolute vs relative.
                },
                icon: const Icon(Icons.attach_file),
                label: const Text('Open attachment'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
