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
      _request('POST', path, body: body, isRetry: false);

  /// GET 요청. 캠페인 조회 엔드포인트에서 사용한다.
  /// [query] 의 null 값은 제외되어 서버 기본값이 적용된다.
  Future<Map<String, dynamic>> get(String path, [Map<String, String?>? query]) =>
      _request('GET', path, query: query, isRetry: false);

  /// DELETE 요청. 짧은 URL 리다이렉트 중지에서 사용한다.
  Future<Map<String, dynamic>> delete(String path) =>
      _request('DELETE', path, isRetry: false);

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String?>? query,
    required bool isRetry,
  }) async {
    final token = await _tokenManager.getToken();
    var uri = Uri.parse('$_baseUrl/api/$_apiVersion/$path');

    if (query != null) {
      final params = <String, String>{};
      query.forEach((key, value) {
        if (value != null) params[key] = value;
      });
      if (params.isNotEmpty) uri = uri.replace(queryParameters: params);
    }

    final headers = <String, String>{'Authorization': _bearerAuth(token)};
    if (body != null) headers['Content-Type'] = 'application/json';

    // GET 이 아닌 모든 요청을 POST 로 보내면 DELETE 가 조용히 POST 가 된다.
    final response = switch (method) {
      'GET' => await http.get(uri, headers: headers),
      'DELETE' => await http.delete(uri, headers: headers),
      _ => await http.post(uri, headers: headers, body: jsonEncode(body)),
    };

    final responseBody =
        jsonDecode(response.body) as Map<String, dynamic>? ?? {};

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorCode = responseBody['code'] as String?;
      final endpoint = path.split('/').last;
      if (!isRetry && _tokenManager.shouldRefresh(response.statusCode, errorCode)) {
        _tokenManager.invalidate();
        return _request(method, path, body: body, query: query, isRetry: true);
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
