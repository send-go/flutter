import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_manager.dart';
import 'exceptions.dart';

/// 서버 전용 이메일 API. Map/List/null 또는 EML의 Uint8List를 반환합니다.
class EmailService {
  final TokenManager? _tokens;
  final String _baseUrl;
  final String _version;
  final String? _credential;
  EmailService(TokenManager tokens, String baseUrl, String version)
      : _tokens = tokens,
        _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        _version = version,
        _credential = null;

  /// 앱 키가 아닌 이메일 전용 ID/password입니다.
  EmailService.withCredentials(String id, String password,
      {String baseUrl = 'https://sendgo.io'})
      : _tokens = null,
        _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        _version = 'v2',
        _credential = base64Encode(utf8.encode('$id:$password'));

  Future<dynamic> _request(String method, String path,
      Map<String, dynamic>? body, Map<String, String>? query, bool raw,
      [bool retry = false]) async {
    if (_version != 'v2') throw StateError('이메일 API는 apiVersion=v2가 필요합니다.');
    final prefix = _credential == null ? 'email' : 'email-service';
    var uri = Uri.parse('$_baseUrl/api/v2/$prefix/$path');
    if (query != null && query.isNotEmpty)
      uri = uri.replace(queryParameters: query);
    final req = http.Request(method, uri)..followRedirects = false;
    req.headers['Authorization'] = _credential == null
        ? 'Bearer ${await _tokens!.getToken()}'
        : 'Basic $_credential';
    req.headers['Accept'] = 'application/json';
    if (body != null) {
      req.headers['Content-Type'] = 'application/json';
      req.body = jsonEncode(body);
    }
    final client = http.Client();
    try {
      final response = await client
          .send(req)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 60));
      final ok = response.statusCode >= 200 && response.statusCode < 300;
      if (ok && raw) return response.bodyBytes;
      dynamic data;
      if (response.bodyBytes.isNotEmpty) {
        try {
          data = jsonDecode(utf8.decode(response.bodyBytes));
        } catch (e) {
          if (ok) rethrow;
        }
      }
      if (!ok) {
        final error = data is Map<String, dynamic> ? data : <String, dynamic>{};
        if (!retry &&
            _credential == null &&
            response.statusCode == 401 &&
            _tokens!.shouldRefresh(401, error['code'] as String?)) {
          _tokens.invalidate();
          return await _request(method, path, body, query, raw, true);
        }
        throw SendgoException.fromResponse(
            response.statusCode, error, path, 'v2');
      }
      return data;
    } finally {
      client.close();
    }
  }

  /// GET /email/account
  Future<dynamic> account([Map<String, String>? query]) =>
      _request('GET', 'account', null, query, false);

  /// POST /email/request
  Future<dynamic> requestAccess(Map<String, dynamic> body) =>
      _request('POST', 'request', body, null, false);

  /// POST /email/credentials
  Future<dynamic> createCredential(Map<String, dynamic> body) =>
      _request('POST', 'credentials', body, null, false);

  /// GET /email/credentials
  Future<dynamic> credentials([Map<String, String>? query]) =>
      _request('GET', 'credentials', null, query, false);

  /// DELETE /email/credentials/{id}
  Future<dynamic> revokeCredential(String id) => _request(
      'DELETE', 'credentials/${Uri.encodeComponent(id)}', null, null, false);

  /// GET /email/domains
  Future<dynamic> domains([Map<String, String>? query]) =>
      _request('GET', 'domains', null, query, false);

  /// POST /email/domains
  Future<dynamic> registerDomain(Map<String, dynamic> body) =>
      _request('POST', 'domains', body, null, false);

  /// POST /email/domains/{id}/verify
  Future<dynamic> verifyDomain(String id, Map<String, dynamic> body) =>
      _request('POST', 'domains/${Uri.encodeComponent(id)}/verify', body, null,
          false);

  /// GET /email/senders
  Future<dynamic> senders([Map<String, String>? query]) =>
      _request('GET', 'senders', null, query, false);

  /// POST /email/senders
  Future<dynamic> requestSender(Map<String, dynamic> body) =>
      _request('POST', 'senders', body, null, false);

  /// POST /email/senders/{id}/verify
  Future<dynamic> verifySender(String id, Map<String, dynamic> body) =>
      _request('POST', 'senders/${Uri.encodeComponent(id)}/verify', body, null,
          false);

  /// POST /email/recipients/verification
  Future<dynamic> requestRecipientVerification(Map<String, dynamic> body) =>
      _request('POST', 'recipients/verification', body, null, false);

  /// POST /email/recipients/check
  Future<dynamic> checkRecipients(Map<String, dynamic> body) =>
      _request('POST', 'recipients/check', body, null, false);

  /// GET /email/address-book
  Future<dynamic> addressBook([Map<String, String>? query]) =>
      _request('GET', 'address-book', null, query, false);

  /// GET /email/sender-profiles
  Future<dynamic> senderProfiles([Map<String, String>? query]) =>
      _request('GET', 'sender-profiles', null, query, false);

  /// POST /email/sender-profiles
  Future<dynamic> createSenderProfile(Map<String, dynamic> body) =>
      _request('POST', 'sender-profiles', body, null, false);

  /// PATCH /email/sender-profiles/{id}
  Future<dynamic> updateSenderProfile(String id, Map<String, dynamic> body) =>
      _request('PATCH', 'sender-profiles/${Uri.encodeComponent(id)}', body,
          null, false);

  /// DELETE /email/sender-profiles/{id}
  Future<dynamic> deleteSenderProfile(String id) => _request('DELETE',
      'sender-profiles/${Uri.encodeComponent(id)}', null, null, false);

  /// POST /email/address-book/import
  Future<dynamic> importAddressBook(Map<String, dynamic> body) =>
      _request('POST', 'address-book/import', body, null, false);

  /// POST /email/address-book/preferences
  Future<dynamic> updateAddressBookPreferences(Map<String, dynamic> body) =>
      _request('POST', 'address-book/preferences', body, null, false);

  /// POST /email/send
  Future<dynamic> send(Map<String, dynamic> body) =>
      _request('POST', 'send', body, null, false);

  /// POST /email/quote
  Future<dynamic> quote(Map<String, dynamic> body) =>
      _request('POST', 'quote', body, null, false);

  /// GET /email/messages
  Future<dynamic> messages([Map<String, String>? query]) =>
      _request('GET', 'messages', null, query, false);

  /// GET /email/messages/{id}
  Future<dynamic> message(String id, [Map<String, String>? query]) => _request(
      'GET', 'messages/${Uri.encodeComponent(id)}', null, query, false);

  /// POST /email/messages/{id}/cancel
  Future<dynamic> cancelMessage(String id, Map<String, dynamic> body) =>
      _request('POST', 'messages/${Uri.encodeComponent(id)}/cancel', body, null,
          false);

  /// GET /email/inboxes
  Future<dynamic> inboxes([Map<String, String>? query]) =>
      _request('GET', 'inboxes', null, query, false);

  /// POST /email/inboxes
  Future<dynamic> createInbox(Map<String, dynamic> body) =>
      _request('POST', 'inboxes', body, null, false);

  /// PATCH /email/inboxes/{id}
  Future<dynamic> updateInbox(String id, Map<String, dynamic> body) => _request(
      'PATCH', 'inboxes/${Uri.encodeComponent(id)}', body, null, false);

  /// GET /email/inboxes/{id}/messages
  Future<dynamic> inboxMessages(String id, [Map<String, String>? query]) =>
      _request('GET', 'inboxes/${Uri.encodeComponent(id)}/messages', null,
          query, false);

  /// GET /email/inboxes/{id}/messages/{messageId}
  Future<dynamic> inboxMessage(String id, String messageId,
          [Map<String, String>? query]) =>
      _request(
          'GET',
          'inboxes/${Uri.encodeComponent(id)}/messages/${Uri.encodeComponent(messageId)}',
          null,
          query,
          false);

  /// GET /email/inboxes/{id}/messages/{messageId}/raw
  Future<dynamic> rawMessage(String id, String messageId,
          [Map<String, String>? query]) =>
      _request(
          'GET',
          'inboxes/${Uri.encodeComponent(id)}/messages/${Uri.encodeComponent(messageId)}/raw',
          null,
          query,
          true);

  /// DELETE /email/inboxes/{id}/messages/{messageId}
  Future<dynamic> deleteInboxMessage(String id, String messageId) => _request(
      'DELETE',
      'inboxes/${Uri.encodeComponent(id)}/messages/${Uri.encodeComponent(messageId)}',
      null,
      null,
      false);

  /// GET /email/templates
  Future<dynamic> templates([Map<String, String>? query]) =>
      _request('GET', 'templates', null, query, false);

  /// GET /email/templates/{id}
  Future<dynamic> template(String id, [Map<String, String>? query]) => _request(
      'GET', 'templates/${Uri.encodeComponent(id)}', null, query, false);

  /// POST /email/templates
  Future<dynamic> createTemplate(Map<String, dynamic> body) =>
      _request('POST', 'templates', body, null, false);

  /// PATCH /email/templates/{id}
  Future<dynamic> updateTemplate(String id, Map<String, dynamic> body) =>
      _request(
          'PATCH', 'templates/${Uri.encodeComponent(id)}', body, null, false);

  /// DELETE /email/templates/{id}
  Future<dynamic> deleteTemplate(String id) => _request(
      'DELETE', 'templates/${Uri.encodeComponent(id)}', null, null, false);

  /// GET /email/contacts
  Future<dynamic> contacts([Map<String, String>? query]) =>
      _request('GET', 'contacts', null, query, false);

  /// POST /email/contacts
  Future<dynamic> saveContact(Map<String, dynamic> body) =>
      _request('POST', 'contacts', body, null, false);

  /// POST /email/contacts/import
  Future<dynamic> importContacts(Map<String, dynamic> body) =>
      _request('POST', 'contacts/import', body, null, false);

  /// POST /email/contacts/{id}/unsubscribe
  Future<dynamic> unsubscribeContact(String id, Map<String, dynamic> body) =>
      _request('POST', 'contacts/${Uri.encodeComponent(id)}/unsubscribe', body,
          null, false);

  /// GET /email/campaigns
  Future<dynamic> campaigns([Map<String, String>? query]) =>
      _request('GET', 'campaigns', null, query, false);

  /// POST /email/campaigns
  Future<dynamic> createCampaign(Map<String, dynamic> body) =>
      _request('POST', 'campaigns', body, null, false);

  /// GET /email/campaigns/{id}
  Future<dynamic> campaign(String id, [Map<String, String>? query]) => _request(
      'GET', 'campaigns/${Uri.encodeComponent(id)}', null, query, false);

  /// POST /email/campaigns/{id}/quote
  Future<dynamic> quoteCampaign(String id, Map<String, dynamic> body) =>
      _request('POST', 'campaigns/${Uri.encodeComponent(id)}/quote', body, null,
          false);

  /// POST /email/campaigns/{id}/send
  Future<dynamic> sendCampaign(String id, Map<String, dynamic> body) =>
      _request('POST', 'campaigns/${Uri.encodeComponent(id)}/send', body, null,
          false);

  /// POST /email/campaigns/{id}/cancel
  Future<dynamic> cancelCampaign(String id, Map<String, dynamic> body) =>
      _request('POST', 'campaigns/${Uri.encodeComponent(id)}/cancel', body,
          null, false);

  /// GET /email/auth
  Future<dynamic> auth([Map<String, String>? query]) =>
      _request('GET', 'auth', null, query, false);
}
