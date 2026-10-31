import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late final Dio dio;
  String? _authToken;

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        // Extended timeouts to handle Render Free Tier cold starts (30-60s)
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth & Logging Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null && _authToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Cold-Start Retry Logic for Render Free instances
          // When a free Render service spins down, initial connection times out or returns 503
          final isColdStartOrTimeout = error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.connectionError ||
              (error.response?.statusCode == 503);

          final retryCount = error.requestOptions.extra['retry_count'] as int? ?? 0;

          if (isColdStartOrTimeout && retryCount < 2) {
            error.requestOptions.extra['retry_count'] = retryCount + 1;
            // Wait 2 seconds before retry to give the Render container time to boot
            await Future.delayed(const Duration(seconds: 2));
            try {
              final response = await dio.fetch(error.requestOptions);
              return handler.resolve(response);
            } catch (retryError) {
              if (retryError is DioException) {
                return handler.next(retryError);
              }
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }
}
