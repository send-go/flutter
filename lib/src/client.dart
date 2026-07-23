import 'dart:convert';
import 'package:http/http.dart' as http;
import 'exceptions.dart';
import 'token_manager.dart';

/// Sendgo API HTTP 클라이언트.
class SendgoHttpClient {
  final TokenManager _tokenManager;
  final String _apiVersion;
  final String _baseUrl;

  SendgoHttpClient({
    required TokenManager tokenManager,
    required String apiVersion,
    required String baseUrl,
  })  : _tokenManager = tokenManager,
        _apiVersion = apiVersion,
        _baseUrl = baseUrl;

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) =>
      _doPost(path, body, isRetry: false);

  Future<Map<String, dynamic>> _doPost(
    String path,
    Map<String, dynamic> body, {
    required bool isRetry,
  }) async {
    final token = await _tokenManager.getToken();
    final uri = Uri.parse('$_baseUrl/api/$_apiVersion/$path');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': _bearerAuth(token),
      },
      body: jsonEncode(body),
    );

    final responseBody =
        jsonDecode(response.body) as Map<String, dynamic>? ?? {};

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorCode = responseBody['code'] as String?;
      final endpoint = path.split('/').last;
      if (!isRetry && _tokenManager.shouldRefresh(response.statusCode, errorCode)) {
        _tokenManager.invalidate();
        return _doPost(path, body, isRetry: true);
      }
      throw SendgoException.fromResponse(response.statusCode, responseBody, endpoint, _apiVersion);
    }

    return responseBody;
  }

  String _bearerAuth(String token) {
    if (_apiVersion == 'v2') return 'Bearer $token';
    return 'Bearer ${base64Encode(utf8.encode(token))}';
  }
}
