import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/async_value_view.dart';
import '../../../../shared/widgets/sign_out_button.dart';
import '../providers/fees_provider.dart';

class FeesScreen extends ConsumerWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fees = ref.watch(feesDueListProvider);
    final formatter = NumberFormat.currency(symbol: '', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(title: const Text('Fees'), actions: const [SignOutButton()]),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(feesDueListProvider.future),
        child: AsyncValueView(
          value: fees,
          isEmpty: (list) => list.isEmpty,
          emptyMessage: 'No fees due. All clear!',
          onRetry: () => ref.invalidate(feesDueListProvider),
          data: (context, list) {
            final totalDue = list.fold<double>(0, (sum, item) => sum + item.amountDue);
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: AppColors.primary,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total due', style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text(
                          formatter.format(totalDue),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...list.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(item.feesType ?? item.feesGroup ?? 'Fees'),
                      subtitle: item.dueDate != null ? Text('Due ${item.dueDate}') : null,
                      trailing: Text(
                        formatter.format(item.amountDue),
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.error),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
