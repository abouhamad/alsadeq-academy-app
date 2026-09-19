import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../providers/notices_provider.dart';

class NoticesScreen extends ConsumerWidget {
  const NoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(noticesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notice board'), actions: const [SignOutButton()]),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(noticesListProvider.future),
        child: AsyncValueView(
          value: notices,
          isEmpty: (list) => list.isEmpty,
          emptyMessage: 'No notices posted yet.',
          onRetry: () => ref.invalidate(noticesListProvider),
          data: (context, list) {
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = list[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.campaign_outlined, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        if (item.message != null) ...[
                          const SizedBox(height: 8),
                          Text(item.message!, style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                        if (item.date != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            item.date!,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ],
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
