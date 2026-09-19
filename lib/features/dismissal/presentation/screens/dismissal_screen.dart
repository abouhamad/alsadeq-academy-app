import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/dismissal_record_model.dart';
import '../providers/dismissal_provider.dart';
import 'qr_scan_screen.dart';

class DismissalScreen extends ConsumerWidget {
  const DismissalScreen({super.key});

  Future<void> _scan(BuildContext context, WidgetRef ref) async {
    final token = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
    if (token == null || !context.mounted) return;

    try {
      final record = await ref.read(dismissalRepositoryProvider).scan(token);
      ref.invalidate(dismissalQueueProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${record.studentName} added to the dismissal list.')),
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _remove(BuildContext context, WidgetRef ref, DismissalRecordModel record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from list?'),
        content: Text('Clear ${record.studentName} from the dismissal list?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(dismissalRepositoryProvider).remove(record.id);
      ref.invalidate(dismissalQueueProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(dismissalQueueProvider);
    final myStaffId = ref.watch(authControllerProvider).user?.staffId;

    return Scaffold(
      appBar: AppBar(title: const Text('Dismissal'), actions: const [SignOutButton()]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _scan(context, ref),
        icon: const Icon(Icons.qr_code_scanner_outlined),
        label: const Text('Scan QR'),
      ),
      body: queue.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(dismissalQueueProvider),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyState(message: 'No students on the dismissal list yet.');
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = records[index];
              final isMine = myStaffId != null && record.addedByStaffId == myStaffId;
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    child: Icon(Icons.directions_walk),
                  ),
                  title: Text(record.studentName),
                  subtitle: Text(
                    [record.className, record.sectionName].whereType<String>().join(' / '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('by ${record.addedByName}', style: const TextStyle(fontSize: 12)),
                      if (isMine)
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.error),
                          tooltip: 'Remove',
                          onPressed: () => _remove(context, ref, record),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
