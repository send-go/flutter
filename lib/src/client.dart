import 'dart:convert';
import 'package:http/http.dart' as http;
import 'exceptions.dart';
import 'models.dart';
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

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) =>
      _request('PUT', path, body: body, isRetry: false);

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) =>
      _request('PATCH', path, body: body, isRetry: false);

  /// DELETE 요청. 짧은 URL 리다이렉트 중지에서 사용한다.
  Future<Map<String, dynamic>> delete(String path) =>
      _request('DELETE', path, isRetry: false);

  /// multipart/form-data POST — 서류·이미지 첨부가 있는 관리 API 전용.
  ///
  /// 발신번호 등록과 이미지 템플릿은 JSON 으로 보낼 수 없다. multipart 에는
  /// 배열도 불리언도 없으므로, List/Map 값은 JSON 문자열로 눌러 보낸다 —
  /// 서버가 그렇게 받아 읽는다.
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    Map<String, dynamic>? fields,
    List<SendgoMultipartFile>? files,
  }) =>
      _multipartRequest(path, fields ?? {}, files ?? const [], isRetry: false);

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

    // GET 이 아닌 모든 요청을 POST 로 보내면 DELETE·PUT·PATCH 가 조용히
    // POST 가 되고, 서버는 라우트를 못 찾아 405 를 준다.
    final response = switch (method) {
      'GET' => await http.get(uri, headers: headers),
      'DELETE' => await http.delete(uri, headers: headers),
      'PUT' => await http.put(uri, headers: headers, body: jsonEncode(body)),
      'PATCH' => await http.patch(uri, headers: headers, body: jsonEncode(body)),
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

  Future<Map<String, dynamic>> _multipartRequest(
    String path,
    Map<String, dynamic> fields,
    List<SendgoMultipartFile> files, {
    required bool isRetry,
  }) async {
    final token = await _tokenManager.getToken();
    final uri = Uri.parse('$_baseUrl/api/$_apiVersion/$path');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = _bearerAuth(token)
      ..headers['Accept'] = 'application/json';

    fields.forEach((key, value) {
      if (value == null) return;

      request.fields[key] = switch (value) {
        bool flag => flag ? '1' : '0',
        String text => text,
        List<dynamic>() || Map<dynamic, dynamic>() => jsonEncode(value),
        _ => value.toString(),
      };
    });

    for (final file in files) {
      request.files.add(http.MultipartFile.fromBytes(
        file.fieldName,
        file.bytes,
        filename: file.fileName,
      ));
    }

    // 파일 업로드는 JSON 요청보다 오래 걸린다.
    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);

    final responseBody =
        jsonDecode(response.body) as Map<String, dynamic>? ?? {};

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorCode = responseBody['code'] as String?;
      final endpoint = path.split('/').last;
      if (!isRetry &&
          _tokenManager.shouldRefresh(response.statusCode, errorCode)) {
        _tokenManager.invalidate();
        return _multipartRequest(path, fields, files, isRetry: true);
      }
      throw SendgoException.fromResponse(
          response.statusCode, responseBody, endpoint, _apiVersion);
    }

    return responseBody;
  }

  String _bearerAuth(String token) {
    if (_apiVersion == 'v2') return 'Bearer $token';
    return 'Bearer ${base64Encode(utf8.encode(token))}';
  }
}
