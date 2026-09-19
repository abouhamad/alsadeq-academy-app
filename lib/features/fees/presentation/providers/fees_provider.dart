import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/fees_repository.dart';
import '../../data/models/fees_due_model.dart';

final feesRepositoryProvider = Provider<FeesRepository>((ref) {
  return FeesRepository(ref.watch(apiClientProvider));
});

final feesDueListProvider = FutureProvider.autoDispose<List<FeesDueModel>>((ref) async {
  final user = ref.watch(authControllerProvider).user;
  if (user == null) return const [];
  return ref.watch(feesRepositoryProvider).fetchFeesDue(user);
});
