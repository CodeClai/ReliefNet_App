import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? requestId;
  
  ApiException(this.message, {this.statusCode, this.requestId});
  
  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  
  late final Dio dio;
  final _storage = const FlutterSecureStorage();

  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? get currentUser => _currentUser;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_BASE_URL']!,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: false,
      responseHeader: false,
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token!= null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Auto-unwrap standard format: {success, data, error}
        final data = response.data;
        if (data is Map && data.containsKey('success')) {
          if (data['success'] == true) {
            // Replace response.data with just the data field
            response.data = data['data'];
          } else {
            // Convert to DioException for error handler
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error: data['error'] ?? 'Unknown error',
              ),
            );
          }
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        final response = error.response;
        String message = 'Network error';
        String? requestId;
        
        if (response?.data is Map) {
          final data = response!.data;
          message = data['error'] ?? data['message'] ?? message;
          requestId = data['requestId'];
        } else if (error.message != null) {
          message = error.message!;
        }

        // Handle 401: clear token
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'token');
          _currentUser = null;
        }

        // Convert to ApiException
        final apiError = ApiException(
          message,
          statusCode: response?.statusCode,
          requestId: requestId,
        );

        return handler.next(DioException(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: apiError,
        ));
      },
    ));
  }

  void setCurrentUser(Map<String, dynamic> user) {
    _currentUser = user;
  }

  void clearCurrentUser() {
    _currentUser = null;
  }

  // Helper: throw typed exception
  Never _throw(Response response) {
    throw ApiException(
      response.data?['error'] ?? 'Request failed',
      statusCode: response.statusCode,
      requestId: response.data?['requestId'],
    );
  }
}