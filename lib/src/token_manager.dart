import 'dart:convert';
import 'package:http/http.dart' as http;
import 'exceptions.dart';

const _noRefreshCodes = {
  'INVALID_AUTH_HEADER', 'INVALID_BASIC_AUTH', 'INVALID_BASIC_AUTH_PAYLOAD',
  'INVALID_ACCESS_KEY', 'INVALID_SECRET_KEY', 'ACCESS_KEY_NOT_APPROVED',
  'TEAM_REQUIRED_FOR_KAKAO', 'IP_NOT_ALLOWED', 'INVALID_SENDER_KEY', 'INVALID_KAKAO_SENDER_KEY',
};

/// 토큰 발급 및 50분 캐시 관리.
class TokenManager {
  final String baseUrl;
  final String accessKey;
  final String secretKey;
  final String apiVersion;

  String? _token;
  DateTime _expiresAt = DateTime.fromMillisecondsSinceEpoch(0);

  TokenManager({
    required this.baseUrl,
    required this.accessKey,
    required this.secretKey,
    required this.apiVersion,
  });

  Future<String> getToken() async {
    if (_token != null && DateTime.now().isBefore(_expiresAt)) return _token!;
    return _fetchToken();
  }

  void invalidate() {
    _token = null;
    _expiresAt = DateTime.fromMillisecondsSinceEpoch(0);
  }

  bool shouldRefresh(int status, String? errorCode) {
    if (status != 401 && status != 403) return false;
    if (apiVersion == 'v2' && errorCode != null && _noRefreshCodes.contains(errorCode)) return false;
    return true;
  }

  Future<String> _fetchToken() async {
    final uri = Uri.parse('$baseUrl/api/$apiVersion/token');
    final credentials = base64Encode(utf8.encode('$accessKey:$secretKey'));

    final response = await http.post(uri, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Basic $credentials',
    });

    final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};

    if (response.statusCode < 200 || response.statusCode >= 300 ||
        body['data']?['token'] == null) {
      throw SendgoException.fromResponse(response.statusCode, body, 'token', apiVersion);
    }

    _token = body['data']['token'] as String;
    _expiresAt = DateTime.now().add(const Duration(minutes: 50));
    return _token!;
  }
}
