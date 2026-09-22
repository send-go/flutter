import 'dart:convert';
import 'package:http/http.dart' as http;
import 'exceptions.dart';

/// 서버 전용 계정 API. 에이전트 토큰을 앱에 포함하지 마세요.
/// 토큰 만료·권한 오류를 자동 재시도하거나 갱신하지 않습니다.
class AccountClient {
  final String _agentToken;
  final String _baseUrl;
  final http.Client _http = http.Client();

  AccountClient(
      {required String agentToken, String baseUrl = 'https://sendgo.io'})
      : _agentToken = agentToken,
        _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), '') {
    if (agentToken.trim().isEmpty)
      throw ArgumentError('Sendgo: agentToken은 필수입니다.');
  }

  /// 계정 상태와 다음 단계 조회.
  Future<Map<String, dynamic>> me() => _request('GET', '');

  /// 조직 목록 조회.
  Future<Map<String, dynamic>> organizations() =>
      _request('GET', 'organizations');

  /// 조직 선택. null은 개인 계정.
  Future<Map<String, dynamic>> selectOrganization(String? organizationId) =>
      _request(
          'POST', 'organizations/select', {'organizationId': organizationId});

  /// 현재 조직의 API 키 목록.
  Future<Map<String, dynamic>> apiKeys() => _request('GET', 'api-keys');

  /// API 키 발급. secretKey는 이 응답에서만 반환.
  Future<Map<String, dynamic>> createApiKey(Map<String, dynamic> params) =>
      _request('POST', 'api-keys', params);

  /// API 키 상세 조회.
  Future<Map<String, dynamic>> apiKey(String apiKeyId) =>
      _request('GET', 'api-keys/${Uri.encodeComponent(apiKeyId)}');

  /// API 키 이름 변경.
  Future<Map<String, dynamic>> updateApiKey(String apiKeyId, String name) =>
      _request(
          'PATCH', 'api-keys/${Uri.encodeComponent(apiKeyId)}', {'name': name});

  /// API 키 폐기.
  Future<Map<String, dynamic>> deleteApiKey(String apiKeyId) =>
      _request('DELETE', 'api-keys/${Uri.encodeComponent(apiKeyId)}');

  /// 승인된 API 키의 발송용 토큰 발급.
  Future<Map<String, dynamic>> issueToken(String apiKeyId) =>
      _request('POST', 'api-keys/${Uri.encodeComponent(apiKeyId)}/token', {});

  /// 허용 IP 목록과 호출자 IP 조회.
  Future<Map<String, dynamic>> allowedIps(String apiKeyId) =>
      _request('GET', 'api-keys/${Uri.encodeComponent(apiKeyId)}/allowed-ips');

  /// 허용 IP 추가. ip와 선택적 description 사용.
  Future<Map<String, dynamic>> addAllowedIp(
          String apiKeyId, Map<String, dynamic> params) =>
      _request('POST', 'api-keys/${Uri.encodeComponent(apiKeyId)}/allowed-ips',
          params);

  /// 허용 IP 삭제.
  Future<
      Map<String,
          dynamic>> deleteAllowedIp(String apiKeyId, String ipId) => _request(
      'DELETE',
      'api-keys/${Uri.encodeComponent(apiKeyId)}/allowed-ips/${Uri.encodeComponent(ipId)}');

  Future<Map<String, dynamic>> _request(String method, String path,
      [Map<String, dynamic>? body]) async {
    final request = http.Request(method,
        Uri.parse('$_baseUrl/api/v2/account${path.isEmpty ? '' : '/$path'}'))
      ..followRedirects = false
      ..headers['Authorization'] = 'Bearer $_agentToken'
      ..headers['Accept'] = 'application/json';
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    final response = await (() async {
      final streamed = await _http.send(request);
      return http.Response.fromStream(streamed);
    })()
        .timeout(const Duration(seconds: 15));
    Map<String, dynamic> data;
    try {
      data = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      data = {};
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SendgoException.fromResponse(
          response.statusCode, data, path.isEmpty ? 'account' : path, 'v2');
    }
    return data;
  }

  void close() => _http.close();
}
