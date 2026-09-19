import 'user_model.dart';

/// Result of `POST /api/v2/login` (AuthenticationController@login).
/// `data.accessToken` already carries the "Bearer " prefix.
class LoginResult {
  final String accessToken;
  final UserModel user;
  final int unreadNotifications;

  const LoginResult({
    required this.accessToken,
    required this.user,
    this.unreadNotifications = 0,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      accessToken: (json['accessToken'] ?? '').toString(),
      user: UserModel.fromJson(
        (json['user'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      unreadNotifications: json['unread_notifications'] is int
          ? json['unread_notifications'] as int
          : int.tryParse('${json['unread_notifications']}') ?? 0,
    );
  }
}
