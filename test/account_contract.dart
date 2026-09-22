import 'dart:io';
import 'package:sendgo_flutter/sendgo_flutter.dart';

Future<void> main() async {
  final url = '${Platform.environment['SENDGO_TEST_URL']}/';
  try {
    AccountClient(agentToken: '');
    throw StateError('빈 토큰 허용');
  } on ArgumentError {}
  final c = AccountClient(agentToken: 'test-agent', baseUrl: url);
  void check(Map<String, dynamic> data) {
    if (data['message'] != 'Success') throw StateError('응답 오류');
  }

  try {
    check(await c.me());
    check(await c.organizations());
    check(await c.selectOrganization(null));
    check(await c.selectOrganization("team-id"));
    check(await c.apiKeys());
    check(await c.createApiKey({
      "name": "한글 이름",
      "ipAddresses": [
        {"ip": "192.0.2.1", "description": "서버"}
      ]
    }));
    check(await c.apiKey("key/id ?"));
    check(await c.updateApiKey("key/id ?", "새 이름"));
    check(await c.deleteApiKey("key/id ?"));
    check(await c.issueToken("key/id ?"));
    check(await c.allowedIps("key/id ?"));
    check(await c
        .addAllowedIp("key/id ?", {"ip": "192.0.2.1", "description": "서버"}));
    check(await c.deleteAllowedIp("key/id ?", "ip/id ?"));
  } finally {
    c.close();
  }
  for (final token in ['expired', 'forbidden']) {
    final client = AccountClient(agentToken: token, baseUrl: url);
    try {
      await client.me();
      throw StateError('오류가 발생하지 않음');
    } on SendgoException catch (e) {
      if (e.statusCode != (token == 'expired' ? 401 : 403) ||
          e.errorCode !=
              (token == 'expired'
                  ? 'AGENT_TOKEN_EXPIRED'
                  : 'AGENT_ABILITY_MISSING')) rethrow;
    } finally {
      client.close();
    }
  }
}
