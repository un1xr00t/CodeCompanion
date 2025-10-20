import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.githubApiBase,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Accept': ApiConstants.acceptHeader,
        },
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log request only in debug mode
          if (kDebugMode) {
            debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Log response only in debug mode
          if (kDebugMode) {
            debugPrint('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          // Log error only in debug mode
          if (kDebugMode) {
            debugPrint('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handling
  Exception _handleError(DioException error) {
    String errorMessage = 'An error occurred';

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Receive timeout';
        break;
      case DioExceptionType.badResponse:
        errorMessage = _handleStatusCode(error.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      case DioExceptionType.unknown:
        errorMessage = 'Network error: ${error.message}';
        break;
      default:
        errorMessage = 'Unexpected error occurred';
    }

    return Exception(errorMessage);
  }

  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 422:
        return 'Validation error';
      case 500:
        return 'Server error';
      case 503:
        return 'Service unavailable';
      default:
        return 'Error: $statusCode';
    }
  }
}