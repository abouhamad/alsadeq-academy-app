class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.unauthorized() =>
      const ApiException('Session expired. Please log in again.', statusCode: 401);

  factory ApiException.network() =>
      const ApiException('Could not reach the server. Check your connection.');

  factory ApiException.unknown([String? detail]) =>
      ApiException(detail ?? 'Something went wrong. Please try again.');

  @override
  String toString() => message;
}
