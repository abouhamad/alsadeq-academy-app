/// Central place for environment-specific configuration.
///
/// The backend (eSkooly Pro / Laravel) exposes two API generations on the
/// same host, confirmed from `RouteServiceProvider@mapApiRoutes` /
/// `mapV2ApiRoutes`:
///   - v1: `{baseUrl}/api`      (routes/api.php)
///   - v2: `{baseUrl}/api/v2`   (routes/v2api.php)
///
/// v2 is preferred where it exists (auth, homework); everything else falls
/// back to v1, per routes/api.php.
class AppConfig {
  AppConfig._();

  static const String baseUrl = 'https://e.alsadeq-academy.com';
  static const String apiV1BaseUrl = '$baseUrl/api';
  static const String apiV2BaseUrl = '$baseUrl/api/v2';

  static const String appName = 'Al Sadeq Academy';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
