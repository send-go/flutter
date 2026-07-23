import 'client.dart';
import 'models.dart';
import 'token_manager.dart';

/// 알림톡 서비스
class AlimtalkService {
  final SendgoHttpClient _http;
  final String? _kakaoSenderKey;
  final String? _smsSenderKey;

  AlimtalkService(this._http, this._kakaoSenderKey, this._smsSenderKey);

  Future<Map<String, dynamic>> send(AlimtalkRequest request) {
    final body = request.toJson()
      ..addAll({'kakaoSenderKey': _kakaoSenderKey, 'senderKey': _smsSenderKey});
    return _http.post('notices/send', body);
  }
}

/// 친구톡 서비스
class FriendtalkService {
  final SendgoHttpClient _http;
  final String? _kakaoSenderKey;
  final String? _smsSenderKey;

  FriendtalkService(this._http, this._kakaoSenderKey, this._smsSenderKey);

  Future<Map<String, dynamic>> send(FriendtalkRequest request) {
    final body = request.toJson()
      ..addAll({'kakaoSenderKey': _kakaoSenderKey, 'senderKey': _smsSenderKey});
    return _http.post('friends/send', body);
  }
}

/// SMS 서비스
class SmsService {
  final SendgoHttpClient _http;
  final String? _smsSenderKey;

  SmsService(this._http, this._smsSenderKey);

  Future<Map<String, dynamic>> sendSms(SmsRequest req) =>
      send(SmsRequest(content: req.content, contacts: req.contacts, messageType: 'SMS',
          campaignType: req.campaignType, scheduleType: req.scheduleType, at: req.at,
          subject: req.subject, files: req.files));

  Future<Map<String, dynamic>> sendLms(SmsRequest req) =>
      send(SmsRequest(content: req.content, contacts: req.contacts, messageType: 'LMS',
          campaignType: req.campaignType, scheduleType: req.scheduleType, at: req.at,
          subject: req.subject, files: req.files));

  Future<Map<String, dynamic>> sendMms(SmsRequest req) =>
      send(SmsRequest(content: req.content, contacts: req.contacts, messageType: 'MMS',
          campaignType: req.campaignType, scheduleType: req.scheduleType, at: req.at,
          subject: req.subject, files: req.files));

  Future<Map<String, dynamic>> send(SmsRequest request) {
    final body = request.toJson()..['senderKey'] = _smsSenderKey;
    return _http.post('messages/send', body);
  }
}

/// Sendgo Flutter SDK 메인 클라이언트.
class SendgoClient {
  late final AlimtalkService alimtalk;
  late final FriendtalkService friendtalk;
  late final SmsService sms;

  SendgoClient({
    required String accessKey,
    required String secretKey,
    String? kakaoSenderKey,
    String? smsSenderKey,
    String apiVersion = 'v1',
    String baseUrl = 'https://sendgo.io',
  }) {
    final tm = TokenManager(
        baseUrl: baseUrl, accessKey: accessKey, secretKey: secretKey, apiVersion: apiVersion);
    final http = SendgoHttpClient(tokenManager: tm, apiVersion: apiVersion, baseUrl: baseUrl);

    alimtalk   = AlimtalkService(http, kakaoSenderKey, smsSenderKey);
    friendtalk = FriendtalkService(http, kakaoSenderKey, smsSenderKey);
    sms        = SmsService(http, smsSenderKey);
  }
}
