import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'models/general_settings_model.dart';
import 'models/login_result.dart';
import 'models/user_model.dart';

class AuthRepository {
  AuthRepository(this._client, this._storage);

  final ApiClient _client;
  final SecureStorageService _storage;

  Future<LoginResult> login({required String email, required String password}) async {
    final response = await _client.post<LoginResult>(
      ApiEndpoints.login,
      v2: true,
      body: {'email': email, 'password': password},
      fromData: (json) => LoginResult.fromJson((json as Map).cast<String, dynamic>()),
    );

    final result = response.data!;
    await _storage.saveSession(
      accessToken: result.accessToken,
      userId: result.user.id,
      roleId: result.user.roleId,
      schoolId: result.user.schoolId,
    );
    return result;
  }

  Future<void> logout() async {
    try {
      await _client.post<dynamic>(ApiEndpoints.logout, v2: true);
    } finally {
      // Always clear local session even if the network call fails, so a
      // user is never stuck logged-in-looking on a dead connection.
      await _storage.clear();
    }
  }

  /// Refreshes the logged-in user's profile (notably `full_name`, which
  /// isn't persisted locally) after a session is restored from a cached
  /// token rather than a fresh login.
  Future<UserModel> fetchMe() async {
    final response = await _client.get<UserModel>(
      ApiEndpoints.me,
      v2: true,
      fromData: (json) => UserModel.fromJson((json as Map).cast<String, dynamic>()),
    );
    return response.data!;
  }

  Future<GeneralSettingsModel> fetchGeneralSettings() async {
    final response = await _client.get<GeneralSettingsModel>(
      ApiEndpoints.generalSettings,
      v2: true,
      fromData: (json) => GeneralSettingsModel.fromJson((json as Map).cast<String, dynamic>()),
    );
    return response.data!;
  }
}
