import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;

  ApiClient._(this.dio);

  /// Minimal client without attaching JWT Authorization header.
  ///
  /// You can provide `baseUrl` explicitly, or set it at compile/run time via
  /// `--dart-define=API_BASE_URL=https://your.url`.
  factory ApiClient({String? baseUrl}) {
    // Allow overriding with a compile-time environment variable when provided.
    const envBase = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    // Default to local backend for development. Can be overridden via
    // `--dart-define=API_BASE_URL=...` or by passing `baseUrl` programmatically.
    final resolvedBase =
        baseUrl ?? (envBase.isNotEmpty ? envBase : 'http://localhost:8080/api');

    final dio = Dio(BaseOptions(
      baseUrl: resolvedBase,
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ));

    // No interceptor to add Authorization header — JWT removed on client side
    return ApiClient._(dio);
  }

  Future<Response> post(String path, Object? data) =>
      dio.post(path, data: data);
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      dio.get(path, queryParameters: queryParameters);
}

List<T> normalizeArrayResponse<T>(Object? payload) {
  if (payload is List) {
    return payload.cast<T>();
  }

  if (payload is Map) {
    final data = payload['data'];
    if (data is List) {
      return data.cast<T>();
    }
  }

  return <T>[];
}
