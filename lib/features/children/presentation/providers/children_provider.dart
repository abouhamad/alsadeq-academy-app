import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/role.dart';
import '../../../../core/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/children_repository.dart';
import '../../data/models/child_model.dart';

final childrenRepositoryProvider = Provider<ChildrenRepository>((ref) {
  return ChildrenRepository(ref.watch(apiClientProvider));
});

final childrenListProvider = FutureProvider.autoDispose<List<ChildModel>>((ref) async {
  final user = ref.watch(authControllerProvider).user;
  if (user == null || user.role != AppRole.parent) return const [];
  return ref.watch(childrenRepositoryProvider).fetchChildren();
});

/// The child currently selected on the Home/Schedule/Pickup screens.
/// Deliberately not `autoDispose` so the choice survives navigating between
/// those three screens instead of resetting to the first child each time.
final selectedChildProvider = StateProvider<ChildModel?>((ref) => null);
