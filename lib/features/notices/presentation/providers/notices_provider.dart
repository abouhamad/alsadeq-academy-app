import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/models/notice_model.dart';
import '../../data/notices_repository.dart';

final noticesRepositoryProvider = Provider<NoticesRepository>((ref) {
  return NoticesRepository(ref.watch(apiClientProvider));
});

final noticesListProvider = FutureProvider.autoDispose<List<NoticeModel>>((ref) async {
  return ref.watch(noticesRepositoryProvider).fetchNotices();
});
