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

/// 카카오 브랜드메시지 서비스.
///
/// 브랜드메시지는 친구톡의 후속 채널로, 친구톡과 달리 채널 친구가 아닌
/// 수신자에게도 보낼 수 있고(targeting 'N'), 수신 동의한 전체 채널 친구에게
/// 동보 발송할 수 있다(targeting 'F'). v2 전용.
class BrandMessageService {
  final SendgoHttpClient _http;
  final String? _kakaoSenderKey;
  final String? _smsSenderKey;

  BrandMessageService(this._http, this._kakaoSenderKey, this._smsSenderKey);

  /// 브랜드메시지를 전송한다.
  ///
  /// targeting 이 M/N/I 이면 contacts 가 필요하고 응답 data 에 발송 건수
  /// (sentCount)가 담긴다. F 는 동보 발송이라 접수 여부(accepted)만 반환되므로,
  /// 그 경우 [broadcast] 가 더 명확하다.
  Future<Map<String, dynamic>> send(BrandMessageRequest request) {
    final body = request.toJson()
      ..addAll({'kakaoSenderKey': _kakaoSenderKey, 'senderKey': _smsSenderKey});
    return _http.post('brand-messages/send', body);
  }

  /// 동보 발송 — 수신 동의한 전체 채널 친구 (targeting 'F').
  ///
  /// 결과는 즉시 알 수 없으므로 [campaigns] / [campaign] 으로 확인한다.
  Future<Map<String, dynamic>> broadcast(BrandMessageRequest request) =>
      send(request.asBroadcast());

  /// 브랜드메시지 캠페인 목록을 조회한다.
  Future<Map<String, dynamic>> campaigns({String? from, String? to, int? count}) =>
      _http.get('brand-messages', {
        'from': from,
        'to': to,
        'count': count?.toString(),
      });

  /// 브랜드메시지 캠페인 상세를 조회한다.
  /// [campaignId] 는 발송 응답의 campaignId (UUID).
  Future<Map<String, dynamic>> campaign(String campaignId) =>
      _http.get('brand-messages/$campaignId');
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

/// 짧은 URL 서비스.
///
/// 메시지에 넣는 링크를 줄이고 클릭 반응을 집계한다. v2 전용.
class ShortUrlService {
  final SendgoHttpClient _http;

  ShortUrlService(this._http);

  /// 짧은 URL 을 만든다.
  ///
  /// 같은 원본 URL 을 다시 줄이면 기존 링크가 그대로 반환된다.
  /// 캠페인별로 반응을 분리해 집계하려면 [ShortUrlRequest.forceNew] 를 쓴다.
  Future<Map<String, dynamic>> create(ShortUrlRequest request) =>
      _http.post('short-urls', request.toJson());

  /// 목록 조회.
  Future<Map<String, dynamic>> list({String? from, String? to, int? count}) =>
      _http.get('short-urls', {
        'from': from,
        'to': to,
        'count': count?.toString(),
      });

  /// 상세 조회.
  Future<Map<String, dynamic>> show(String code) =>
      _http.get('short-urls/${Uri.encodeComponent(code)}');

  /// 반응 통계. 일별 추이와 디바이스/유입경로/국가별 분해를 반환한다.
  Future<Map<String, dynamic>> stats(String code, {String? from, String? to}) =>
      _http.get('short-urls/${Uri.encodeComponent(code)}/stats', {
        'from': from,
        'to': to,
      });

  /// 리다이렉트를 중지한다. 링크는 삭제되지 않고 누적 통계도 남는다.
  /// 이후 그 링크로 들어오면 410 Gone 이 반환된다.
  Future<Map<String, dynamic>> deactivate(String code) =>
      _http.delete('short-urls/${Uri.encodeComponent(code)}');
}

/// Sendgo Flutter SDK 메인 클라이언트.
class SendgoClient {
  late final AlimtalkService alimtalk;
  late final FriendtalkService friendtalk;

  /// 카카오 브랜드메시지 — 친구톡의 후속 채널. v2 전용.
  late final BrandMessageService brandMessage;
  /// 짧은 URL — 링크 단축과 클릭 반응 분석. v2 전용.
  late final ShortUrlService shortUrl;
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
    brandMessage = BrandMessageService(http, kakaoSenderKey, smsSenderKey);
    shortUrl   = ShortUrlService(http);
    sms        = SmsService(http, smsSenderKey);
  }
}
