import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/child_selector_dropdown.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../../../children/presentation/providers/children_provider.dart';
import '../providers/pickup_provider.dart';

class PickupScreen extends ConsumerWidget {
  const PickupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedChild = ref.watch(selectedChildProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pickup'), actions: const [SignOutButton()]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ChildSelectorDropdown(),
            const SizedBox(height: 24),
            Expanded(
              child: selectedChild == null
                  ? const SizedBox.shrink()
                  : _PickupQrCode(studentId: selectedChild.studentId),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupQrCode extends ConsumerWidget {
  const _PickupQrCode({required this.studentId});

  final int studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenAsync = ref.watch(pickupTokenProvider(studentId));

    return AsyncValueView(
      value: tokenAsync,
      onRetry: () => ref.invalidate(pickupTokenProvider(studentId)),
      data: (context, token) {
        final expired = token.expiresAt.isBefore(DateTime.now());
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(token.studentName, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: QrImageView(data: token.token, size: 220),
            ),
            const SizedBox(height: 16),
            Text(
              expired ? 'This code has expired.' : 'Show this code to your child\'s teacher at pickup.',
              textAlign: TextAlign.center,
              style: TextStyle(color: expired ? AppColors.error : AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(pickupTokenProvider(studentId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Regenerate code'),
            ),
          ],
        );
      },
    );
  }
}
