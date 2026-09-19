import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/dismissal_repository.dart';
import '../../data/models/dismissal_record_model.dart';

final dismissalRepositoryProvider = Provider<DismissalRepository>((ref) {
  return DismissalRepository(ref.watch(apiClientProvider));
});

/// Polls the shared dismissal queue every 5s while this screen is open -
/// no Pusher/broadcasting involved, per the "polling only" decision for
/// this feature. Auto-cancels (the `while (true)` loop stops getting
/// listened to) when the screen is popped, since this is `autoDispose`.
final dismissalQueueProvider = StreamProvider.autoDispose<List<DismissalRecordModel>>((ref) async* {
  final repository = ref.watch(dismissalRepositoryProvider);
  while (true) {
    yield await repository.fetchQueue();
    await Future.delayed(const Duration(seconds: 5));
  }
});
