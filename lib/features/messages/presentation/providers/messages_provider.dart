import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/messages_repository.dart';
import '../../data/models/contact_model.dart';
import '../../data/models/message_model.dart';

final messagesRepositoryProvider = Provider<MessagesRepository>((ref) {
  return MessagesRepository(ref.watch(apiClientProvider));
});

final contactsListProvider = FutureProvider.autoDispose<List<ContactModel>>((ref) {
  return ref.watch(messagesRepositoryProvider).fetchContacts();
});

/// Polls every 4s while a thread is open, same pattern as
/// dismissalQueueProvider - a plain one-shot fetch left the screen showing
/// stale messages until a manual pull-to-refresh, including right after
/// tapping a new-message push notification into this exact thread.
final threadProvider =
    StreamProvider.autoDispose.family<List<MessageModel>, int>((ref, otherUserId) async* {
  final repository = ref.watch(messagesRepositoryProvider);
  while (true) {
    yield await repository.fetchThread(otherUserId);
    await Future.delayed(const Duration(seconds: 4));
  }
});
