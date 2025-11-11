import 'dart:convert';
import 'package:http/http.dart' as http;

/// Базовый сервис для HTTP запросов с обработкой ошибок
class ApiService {
  static const Duration _timeoutDuration = Duration(seconds: 30);

  /// Выполняет GET запрос с обработкой ошибок
  static Future<ApiResponse<T>> get<T>({
    required String url,
    Map<String, String>? headers,
    required T Function(dynamic) parser,
  }) async {
    try {
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(_timeoutDuration);

      return _handleResponse(response, parser);
    } on http.ClientException catch (e) {
      return ApiResponse.error(
        errorType: ApiErrorType.network,
        message: 'Ошибка сети: ${e.message}',
      );
    } on FormatException catch (e) {
      return ApiResponse.error(
        errorType: ApiErrorType.parsing,
        message: 'Ошибка парсинга данных: ${e.message}',
      );
    } catch (e) {
      return ApiResponse.error(
        errorType: ApiErrorType.unknown,
        message: 'Неизвестная ошибка: ${e.toString()}',
      );
    }
  }

  static ApiResponse<T> _handleResponse<T>(
      http.Response response,
      T Function(dynamic) parser,
      ) {
    try {
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parsedData = parser(data);
        return ApiResponse.success(data: parsedData);
      } else {
        return ApiResponse.error(
          errorType: ApiErrorType.server,
          message: 'Ошибка сервера: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        errorType: ApiErrorType.parsing,
        message: 'Ошибка обработки ответа: ${e.toString()}',
      );
    }
  }
}

/// Типы ошибок API
enum ApiErrorType {
  network,
  server,
  parsing,
  unknown,
}

/// Универсальный ответ API с обработкой ошибок
class ApiResponse<T> {
  final T? data;
  final String? message;
  final ApiErrorType? errorType;
  final int? statusCode;
  final bool success;

  ApiResponse._({
    this.data,
    this.message,
    this.errorType,
    this.statusCode,
    required this.success,
  });

  factory ApiResponse.success({required T data}) {
    return ApiResponse._(success: true, data: data);
  }

  factory ApiResponse.error({
    required ApiErrorType errorType,
    String? message,
    int? statusCode,
  }) {
    return ApiResponse._(
      success: false,
      errorType: errorType,
      message: message,
      statusCode: statusCode,
    );
  }

  bool get hasError => !success;
}