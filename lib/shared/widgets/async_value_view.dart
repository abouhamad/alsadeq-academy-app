import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_state.dart';
import 'error_view.dart';
import 'loading_indicator.dart';

/// Renders an [AsyncValue] with consistent loading / error / empty / data
/// states so every feature screen (homework, attendance, notices, fees...)
/// doesn't reimplement this switch.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.isEmpty,
    this.emptyMessage = 'Nothing to show yet.',
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) data;
  final bool Function(T data)? isEmpty;
  final String emptyMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const LoadingIndicator(),
      error: (error, _) => ErrorView(message: error.toString(), onRetry: onRetry),
      data: (value) {
        if (isEmpty != null && isEmpty!(value)) {
          return EmptyState(message: emptyMessage);
        }
        return data(context, value);
      },
    );
  }
}
