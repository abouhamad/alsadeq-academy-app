/// Mirrors the backend's consistent response envelope:
/// `{success: bool, data: <mixed>, message: string, code: int?}`
/// (see ApiBaseMethod::sendResponse / sendError in the Laravel app).
///
/// IMPORTANT: some legacy (v1) endpoints return HTTP 200 even on business
/// failure (e.g. the "Api Disabled" kill-switch) — always check [success],
/// never rely on HTTP status alone.
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? code;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.code,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromData,
  ) {
    final rawData = json['data'];
    return ApiResponse<T>(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      code: json['code'] is int ? json['code'] as int : null,
      data: rawData == null
          ? null
          : (fromData != null ? fromData(rawData) : rawData as T),
    );
  }
}
