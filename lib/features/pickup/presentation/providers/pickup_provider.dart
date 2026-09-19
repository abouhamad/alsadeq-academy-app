import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/models/pickup_token_model.dart';
import '../../data/pickup_repository.dart';

final pickupRepositoryProvider = Provider<PickupRepository>((ref) {
  return PickupRepository(ref.watch(apiClientProvider));
});

/// Issues (and re-issues, on invalidate) a pickup QR token for a child,
/// keyed by student id so switching children re-issues automatically.
final pickupTokenProvider =
    FutureProvider.autoDispose.family<PickupTokenModel, int>((ref, studentId) {
  return ref.watch(pickupRepositoryProvider).issueToken(studentId);
});
