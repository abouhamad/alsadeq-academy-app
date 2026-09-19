import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import 'models/pickup_token_model.dart';

class PickupRepository {
  PickupRepository(this._client);

  final ApiClient _client;

  Future<PickupTokenModel> issueToken(int studentId) async {
    final response = await _client.post<PickupTokenModel>(
      ApiEndpoints.pickupTokenIssue,
      v2: true,
      body: {'student_id': studentId},
      fromData: (json) => PickupTokenModel.fromJson((json as Map).cast<String, dynamic>()),
    );
    return response.data!;
  }
}
