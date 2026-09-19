import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/routine_entry_model.dart';
import '../../data/routine_repository.dart';

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return RoutineRepository(ref.watch(apiClientProvider));
});

final routineListProvider = FutureProvider.autoDispose<List<RoutineEntryModel>>((ref) async {
  final user = ref.watch(authControllerProvider).user;
  if (user == null) return const [];
  return ref.watch(routineRepositoryProvider).fetchRoutine(user);
});

/// Routine for one of a parent's children, keyed by that child's own
/// student id (see RoutineRepository.fetchRoutineForChild).
final routineForChildProvider =
    FutureProvider.autoDispose.family<List<RoutineEntryModel>, int>((ref, studentId) {
  return ref.watch(routineRepositoryProvider).fetchRoutineForChild(studentId);
});
