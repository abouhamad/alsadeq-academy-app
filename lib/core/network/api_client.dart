import 'dart:async';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import 'api_exception.dart';
import 'api_response.dart';

/// Thin wrapper around two [Dio] instances (v1 `/api`, v2 `/api/v2`) that:
///  - attaches the stored bearer token to every request,
///  - unwraps the backend's `{success, data, message}` envelope,
///  - normalizes both the v1 "HTTP 200 but success:false" kill-switch and
///    real HTTP/network errors into [ApiException],
///  - broadcasts [unauthorizedStream] so the auth layer can force a logout
///    on a 401 without this class needing to know about app-level state.
class ApiClient {
  ApiClient(this._storage) {
    _v1 = _buildDio(AppConfig.apiV1BaseUrl);
    _v2 = _buildDio(AppConfig.apiV2BaseUrl);
  }

  final SecureStorageService _storage;
  late final Dio _v1;
  late final Dio _v2;

  final _unauthorizedController = StreamController<void>.broadcast();
  Stream<void> get unauthorizedStream => _unauthorizedController.stream;

  Dio _buildDio(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: '$baseUrl/',
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null) {
            // data.accessToken already contains the "Bearer " prefix.
            options.headers['Authorization'] = token;
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            _unauthorizedController.add(null);
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    bool v2 = false,
    Map<String, dynamic>? query,
    T Function(dynamic json)? fromData,
  }) {
    return _request<T>(
      v2: v2,
      fromData: fromData,
      call: (dio) => dio.get(path, queryParameters: query),
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    bool v2 = false,
    Map<String, dynamic>? body,
    T Function(dynamic json)? fromData,
  }) {
    return _request<T>(
      v2: v2,
      fromData: fromData,
      call: (dio) => dio.post(path, data: body),
    );
  }

  Future<ApiResponse<T>> _request<T>({
    required bool v2,
    required Future<Response<dynamic>> Function(Dio dio) call,
    T Function(dynamic json)? fromData,
  }) async {
    try {
      final response = await call(v2 ? _v2 : _v1);
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw ApiException.unknown('Unexpected response from server.');
      }
      final parsed = ApiResponse<T>.fromJson(body, fromData);
      if (!parsed.success) {
        throw ApiException(parsed.message, statusCode: parsed.code);
      }
      return parsed;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException.unauthorized();
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ApiException.network();
      }
      final serverMessage = e.response?.data is Map
          ? (e.response?.data as Map)['message']?.toString()
          : null;
      throw ApiException.unknown(serverMessage);
    }
  }

  void dispose() => _unauthorizedController.close();
}
