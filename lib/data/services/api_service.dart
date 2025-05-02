import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:travel_joy/data/services/auth_service.dart';

class ApiService {
  final String _baseUrl;
  final AuthService _authService;
  
  ApiService({
    required String baseUrl,
    required AuthService authService,
  }) : _baseUrl = baseUrl,
       _authService = authService;
  
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    
    try {
      final response = await http.get(
        uri,
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    
    try {
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: data != null ? jsonEncode(data) : null,
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    
    try {
      final response = await http.put(
        uri,
        headers: await _getHeaders(),
        body: data != null ? jsonEncode(data) : null,
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final uri = _buildUri(endpoint, queryParameters);
    
    try {
      final response = await http.delete(
        uri,
        headers: await _getHeaders(),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final apiPath = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    
    return Uri.parse('$_baseUrl$apiPath').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }
  
  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty 
        ? jsonDecode(response.body) as Map<String, dynamic> 
        : <String, dynamic>{};
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final message = body['message'] ?? 'Unknown error occurred';
      final code = body['code'] ?? response.statusCode.toString();
      
      throw ApiException(
        message: message,
        code: code,
        statusCode: response.statusCode,
      );
    }
  }
  
  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    
    return ApiException(
      message: error.toString(),
      code: 'unknown_error',
      statusCode: 0,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final String code;
  final int statusCode;
  
  ApiException({
    required this.message,
    required this.code,
    required this.statusCode,
  });
  
  @override
  String toString() => 'ApiException[$statusCode]: $message (Code: $code)';
} 