import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/exams_repository.dart';
import '../../data/models/exam_schedule_model.dart';

final examsRepositoryProvider = Provider<ExamsRepository>((ref) {
  return ExamsRepository(ref.watch(apiClientProvider));
});

final examScheduleListProvider = FutureProvider.autoDispose<List<ExamScheduleModel>>((ref) async {
  final user = ref.watch(authControllerProvider).user;
  if (user == null) return const [];
  return ref.watch(examsRepositoryProvider).fetchExamSchedule(user);
});
