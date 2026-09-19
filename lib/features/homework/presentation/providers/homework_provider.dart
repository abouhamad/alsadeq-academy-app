import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/homework_repository.dart';
import '../../data/models/homework_model.dart';

final homeworkRepositoryProvider = Provider<HomeworkRepository>((ref) {
  return HomeworkRepository(ref.watch(apiClientProvider));
});

final homeworkListProvider = FutureProvider.autoDispose<List<HomeworkModel>>((ref) async {
  final user = ref.watch(authControllerProvider).user;
  if (user == null) return const [];
  return ref.watch(homeworkRepositoryProvider).fetchHomework(user);
});

/// Homework for one of a parent's children, keyed by that child's
/// student_records id (see HomeworkRepository.fetchHomeworkForChild).
final homeworkForChildProvider =
    FutureProvider.autoDispose.family<List<HomeworkModel>, int>((ref, recordId) {
  return ref.watch(homeworkRepositoryProvider).fetchHomeworkForChild(recordId);
});
