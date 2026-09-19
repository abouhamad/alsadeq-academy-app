import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the auth token and a few identity fields returned at login.
///
/// The backend's `data.accessToken` value already includes the `"Bearer "`
/// prefix (see SmApiController@mobileLogin / AuthenticationController@login)
/// so it is stored and replayed verbatim in the Authorization header.
class SecureStorageService {
  SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'access_token';
  static const _kUserId = 'user_id';
  static const _kRoleId = 'role_id';
  static const _kSchoolId = 'school_id';

  Future<void> saveSession({
    required String accessToken,
    required int userId,
    required int roleId,
    int? schoolId,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kUserId, value: userId.toString()),
      _storage.write(key: _kRoleId, value: roleId.toString()),
      if (schoolId != null)
        _storage.write(key: _kSchoolId, value: schoolId.toString()),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  Future<int?> getUserId() async {
    final value = await _storage.read(key: _kUserId);
    return value == null ? null : int.tryParse(value);
  }

  Future<int?> getRoleId() async {
    final value = await _storage.read(key: _kRoleId);
    return value == null ? null : int.tryParse(value);
  }

  Future<int?> getSchoolId() async {
    final value = await _storage.read(key: _kSchoolId);
    return value == null ? null : int.tryParse(value);
  }

  Future<bool> hasSession() async => (await getAccessToken()) != null;

  Future<void> clear() => _storage.deleteAll();
}
