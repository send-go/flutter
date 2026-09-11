import 'dart:convert';

import 'package:crypto/crypto.dart';

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
///
/// 친구톡은 카카오 정책에 따라 2025-12-31 종료되었다. 2026-01-01 부터 친구톡
/// 발송 요청은 카카오 측에서 브랜드메시지(자유형)로 자동 대체 발송되므로, 이
/// 서비스를 호출해도 실제로 나가는 것은 브랜드메시지다. 신규 연동은
/// [BrandMessageService] 를 사용한다. 다만 자유 본문 타입(FT/FI/FW)을 개별
/// 수신자에게 보내는 경로는 아직 이 서비스뿐이다 — 브랜드메시지 API 는 그 조합에
/// NOT_A_BRAND_MESSAGE 를 반환한다. 메시지 타입은 1:1 대응된다 —
/// FT→BT, FI→BI, FW→BW, FL→BL, FC→BC, FM→BM, FP→BP, FA→BA.
@Deprecated('친구톡은 2025-12-31 종료되었습니다. brandMessage 를 사용하세요.')
class FriendtalkService {
  final SendgoHttpClient _http;
  final String? _kakaoSenderKey;
  final String? _smsSenderKey;

  FriendtalkService(this._http, this._kakaoSenderKey, this._smsSenderKey);

  /// 친구톡을 전송한다.
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


// ---------------------------------------------------------------- 관리 API
// 콘솔에서만 되던 등록·심사. 발송과 달리 대부분 즉시 완료되지 않는다 —
// 등록 성공은 "접수됨"이지 "사용 가능"이 아니다. 카카오 채널 등록의 인증번호와
// 휴대폰 발신번호의 본인인증은 사람이 개입해야 하므로 API 로 대체되지 않는다.

/// 카카오 발신프로필(채널) 관리 — 등록 · 동기화 · 브랜드메시지 타겟팅 신청.
///
/// v2 전용이며 **기업(Team) 소유 애플리케이션**만 사용할 수 있다.
///
/// 채널 등록은 두 단계다. 카카오가 인증번호를 채널 관리자 **휴대폰으로 SMS
/// 발송**하므로 완전 무인 자동화는 불가능하다 — 사람이 문자를 받아 [create] 에
/// 넣어야 한다.
class KakaoSenderService {
  final SendgoHttpClient _http;

  KakaoSenderService(this._http);

  /// 1단계 — 채널 인증번호 발송.
  ///
  /// 응답에 인증번호는 들어있지 않다. 카카오가 [phoneNumber] 로 SMS 를 보낸다.
  Future<Map<String, dynamic>> requestToken(
          String yellowId, String phoneNumber) =>
      _http.post('kakao-senders/token', {
        'yellowId': yellowId,
        'phoneNumber': phoneNumber,
      });

  /// 2단계 — 발신프로필 등록.
  ///
  /// 이미 등록된 채널을 다시 등록해도 오류가 아니다. 카카오가 같은 senderKey 를
  /// 돌려주고 서버가 기존 행을 갱신한다.
  Future<Map<String, dynamic>> create(KakaoSenderCreateRequest request) =>
      _http.post('kakao-senders', request.toJson());

  /// 목록 조회.
  Future<Map<String, dynamic>> list() => _http.get('kakao-senders');

  /// 상세 조회.
  Future<Map<String, dynamic>> show(String kakaoSenderKey) =>
      _http.get('kakao-senders/${Uri.encodeComponent(kakaoSenderKey)}');

  /// 카테고리 조회. 등록 시 `categoryCode` 로 넣을 값이다.
  Future<Map<String, dynamic>> categories([String? categoryCode]) =>
      _http.get('kakao-senders/categories', {'categoryCode': categoryCode});

  /// 상태 동기화. 키를 주면 단건, 없으면 팀 전체.
  ///
  /// 채널이 카카오 쪽에서 차단·휴면되면 발송이 조용히 실패하기 시작한다.
  /// 그 사실을 먼저 알 방법은 이 호출뿐이므로 하루 한 번 정도 돌리는 게 좋다.
  Future<Map<String, dynamic>> sync([String? kakaoSenderKey]) => _http.post(
        kakaoSenderKey == null
            ? 'kakao-senders/sync'
            : 'kakao-senders/${Uri.encodeComponent(kakaoSenderKey)}/sync',
        const {},
      );

  /// 브랜드메시지 M 신청에 필요한 광고성 정보 수신동의 증적자료 업로드.
  /// jpg/png, 5MB 이하.
  Future<Map<String, dynamic>> uploadBrandMessageEvidence(
          String kakaoSenderKey, SendgoMultipartFile evidence) =>
      _http.postMultipart(
        'kakao-senders/${Uri.encodeComponent(kakaoSenderKey)}/brand-message/evidence',
        files: [evidence.withFieldName('evidence')],
      );

  /// 브랜드메시지 `M`(마케팅) / `N`(정보성) 사용 신청.
  ///
  /// 결과는 즉시 확정되지 않는다. 발신프로필의 `brandMessageStatus` 로 확인한다.
  Future<Map<String, dynamic>> applyBrandMessageTargeting(
          String kakaoSenderKey, String targetType) =>
      _http.post(
        'kakao-senders/${Uri.encodeComponent(kakaoSenderKey)}/brand-message/apply',
        {'targetType': targetType},
      );
}

/// 알림톡 템플릿 관리 — 등록 · 수정 · 검수 요청.
///
/// v2 전용이며 **기업(Team) 소유 애플리케이션**만 사용할 수 있다.
///
/// 템플릿은 만든 즉시 쓸 수 없다. 카카오 검수를 통과해야 한다.
///
/// ```
/// 등록      inspectionStatus=REG   ← 발송 불가
/// 검수 요청  inspectionStatus=REQ   ← 카카오 심사 중
/// 승인      inspectionStatus=APR   ← 여기부터 발송 가능
/// 반려      inspectionStatus=REJ   ← comments 에 사유
/// ```
///
/// 검수 결과는 비동기다. 웹훅이 없으므로 [sync] 로 폴링한다.
class NoticeTemplateService {
  final SendgoHttpClient _http;

  NoticeTemplateService(this._http);

  /// 목록 조회.
  Future<Map<String, dynamic>> list({
    String? kakaoSenderKey,
    String? inspectionStatus,
    String? search,
    int? count,
  }) =>
      _http.get('notice-templates', {
        'kakaoSenderKey': kakaoSenderKey,
        'inspectionStatus': inspectionStatus,
        'search': search,
        'count': count?.toString(),
      });

  /// 상세 조회. `data.template.policy` 에 정책 검토 상태가 들어 있다.
  Future<Map<String, dynamic>> show(String templateCode) =>
      _http.get(_path(templateCode));

  /// 템플릿 등록. 등록만으로는 발송할 수 없다 — 검수를 요청해야 한다.
  Future<Map<String, dynamic>> create(NoticeTemplateRequest request) =>
      _http.post('notice-templates', request.toJson());

  /// 이미지 템플릿 등록 (`templateEmphasizeType: 'IMAGE'`).
  ///
  /// multipart 로 나가므로 buttons 같은 필드는 JSON 문자열로 직렬화된다.
  Future<Map<String, dynamic>> createWithImage(
          NoticeTemplateRequest request, SendgoMultipartFile image) =>
      _http.postMultipart(
        'notice-templates',
        fields: request.toJson(),
        files: [image.withFieldName('image')],
      );

  /// 템플릿 수정.
  ///
  /// 발신프로필과 템플릿 코드는 바꿀 수 없다. 본문·버튼처럼 카카오에 등록된
  /// 내용이 바뀌면 검수 상태가 되돌아가므로 재검수를 요청해야 한다.
  Future<Map<String, dynamic>> update(
          String templateCode, NoticeTemplateRequest request) =>
      _http.put(_path(templateCode), request.toJson());

  /// 템플릿 삭제.
  ///
  /// **카카오는 템플릿 삭제 API 를 제공하지 않는다.** sendgo 목록에서만
  /// 지워지고 비즈니스 채널 쪽 템플릿은 남는다. 동기화하면 다시 나타난다.
  Future<Map<String, dynamic>> delete(String templateCode) =>
      _http.delete(_path(templateCode));

  /// 카카오에서 검수 상태와 반려 사유를 다시 읽어 온다.
  Future<Map<String, dynamic>> sync(String templateCode) =>
      _http.post('${_path(templateCode)}/sync', const {});

  /// 검수 요청.
  ///
  /// 첨부가 있으면 [comment] 는 필수다. 정책 검토를 통과하지 못한 템플릿은
  /// `POLICY_REVIEW_REQUIRED` 로 거절되고 `errors.reasons` 에 사유가 담긴다.
  Future<Map<String, dynamic>> requestInspection(
    String templateCode, {
    String? comment,
    List<SendgoMultipartFile>? attachments,
  }) {
    final endpoint = '${_path(templateCode)}/inspection';

    if (attachments == null || attachments.isEmpty) {
      return _http.post(endpoint, {if (comment != null) 'comment': comment});
    }

    // 서버는 attachments[0], attachments[1] 형태를 기대한다.
    final named = [
      for (var i = 0; i < attachments.length; i++)
        attachments[i].withFieldName('attachments[$i]'),
    ];

    return _http.postMultipart(
      endpoint,
      fields: {if (comment != null) 'comment': comment},
      files: named,
    );
  }

  /// 검수 요청 취소. 아직 심사 중(REQ)일 때만 통한다.
  Future<Map<String, dynamic>> cancelInspection(String templateCode) =>
      _http.delete('${_path(templateCode)}/inspection');

  /// 승인 취소. 승인(APR)된 템플릿을 되돌린다. 이후에는 발송할 수 없다.
  Future<Map<String, dynamic>> cancelApproval(String templateCode) =>
      _http.delete('${_path(templateCode)}/approval');

  /// 휴면 해제. 오래 안 쓴 템플릿이 dormant 로 잠기면 이걸로 깨운다.
  Future<Map<String, dynamic>> release(String templateCode) =>
      _http.post('${_path(templateCode)}/release', const {});

  /// 템플릿 카테고리 코드 조회.
  Future<Map<String, dynamic>> categories([String? categoryCode]) =>
      _http.get('notice-templates/categories', {'categoryCode': categoryCode});

  String _path(String templateCode) =>
      'notice-templates/${Uri.encodeComponent(templateCode)}';
}

/// 브랜드메시지(구 친구톡) 템플릿 관리.
///
/// v2 전용이며 **기업(Team) 소유 애플리케이션**만 사용할 수 있다.
/// 알림톡 템플릿과 달리 **검수 요청 단계가 없다.**
class BrandTemplateService {
  final SendgoHttpClient _http;

  BrandTemplateService(this._http);

  /// 목록 조회.
  Future<Map<String, dynamic>> list({
    String? kakaoSenderKey,
    String? search,
    int? count,
  }) =>
      _http.get('brand-templates', {
        'kakaoSenderKey': kakaoSenderKey,
        'search': search,
        'count': count?.toString(),
      });

  /// 상세 조회. sendgo 코드(`KFT-...`)와 카카오 브랜드 템플릿 코드 둘 다 받는다.
  Future<Map<String, dynamic>> show(String templateCode) =>
      _http.get(_path(templateCode));

  /// 템플릿 등록.
  Future<Map<String, dynamic>> create(BrandTemplateRequest request) =>
      _http.post('brand-templates', request.toJson());

  /// 템플릿 수정. 발신프로필은 바꿀 수 없다.
  Future<Map<String, dynamic>> update(
          String templateCode, BrandTemplateRequest request) =>
      _http.put(_path(templateCode), request.toJson());

  /// 템플릿 삭제. 알림톡과 달리 카카오 쪽에서도 실제로 삭제된다.
  Future<Map<String, dynamic>> delete(String templateCode) =>
      _http.delete(_path(templateCode));

  /// 동기화. 카카오 쪽에서 이미 삭제됐으면 로컬에서도 제거하고
  /// `data.deleted: true` 를 반환한다.
  Future<Map<String, dynamic>> sync(String templateCode) =>
      _http.post('${_path(templateCode)}/sync', const {});

  /// 발신프로필 단위 가져오기 — 카카오 쪽에 이미 있는 템플릿을 들여온다.
  Future<Map<String, dynamic>> import(String kakaoSenderKey) =>
      _http.post('brand-templates/import', {'kakaoSenderKey': kakaoSenderKey});

  String _path(String templateCode) =>
      'brand-templates/${Uri.encodeComponent(templateCode)}';
}

/// 발신번호(문자) 등록 · 심사 접수.
///
/// v2 전용. 카카오와 달리 **개인 계정 애플리케이션도** 쓸 수 있다.
///
/// 등록하면 곧바로 쓸 수 있는 게 아니라 `PENDING` 으로 **접수**되고, 운영자
/// 승인 후 `SUCCESS` 가 된다.
class SenderRegistrationService {
  final SendgoHttpClient _http;

  SenderRegistrationService(this._http);

  /// 목록 조회. 심사 상태(`status`)를 여기서 확인한다.
  Future<Map<String, dynamic>> list() => _http.get('senders');

  /// 상세 조회.
  Future<Map<String, dynamic>> show(String senderKey) =>
      _http.get('senders/${Uri.encodeComponent(senderKey)}');

  /// 계정 종류에 맞는 발신번호 유형과 유형별 필수 서류.
  ///
  /// 유형별 `identityVerification`(`none`/`document`)과 필요한 서류 목록을 준다.
  Future<Map<String, dynamic>> numberTypes() =>
      _http.get('senders/number-types');

  /// 등록 전 형식·중복 확인.
  ///
  /// 응답의 `duplicationReasonRequired` 가 true 면 [create] 에
  /// `duplicationReason` 을 함께 넣어야 한다.
  Future<Map<String, dynamic>> validate(
          String phoneE164, String senderNumberType) =>
      _http.post('senders/validate', {
        'phoneE164': phoneE164,
        'senderNumberType': senderNumberType,
      });

  /// 등록 신청. 서류가 붙으므로 multipart 로 나간다.
  ///
  /// [files] 에는 최소한 `csuCertificate`(통신서비스 이용증명원)가 있어야 한다.
  /// 휴대폰 계열은 `identityDocument`(신분증 사본)가, `team_other_company` 는
  /// 수임·위임 서류가 더 필요하다 — [numberTypes] 로 확인한다.
  Future<Map<String, dynamic>> create(
    SenderRegistrationRequest request,
    List<SendgoMultipartFile> files,
  ) =>
      _http.postMultipart('senders',
          fields: request.toFields(), files: files);

  /// 별칭 변경 / 기본 발신 지정. 번호와 심사 상태는 바꿀 수 없다.
  Future<Map<String, dynamic>> update(
    String senderKey, {
    required String senderAlias,
    String? primaryType,
  }) =>
      _http.patch('senders/${Uri.encodeComponent(senderKey)}', {
        'senderAlias': senderAlias,
        if (primaryType != null) 'primaryType': primaryType,
      });

  /// 삭제. 기본 발신번호를 지우면 남은 번호 중 하나가 기본으로 승계된다.
  Future<Map<String, dynamic>> delete(String senderKey) =>
      _http.delete('senders/${Uri.encodeComponent(senderKey)}');
}

/// 문자(SMS/LMS/MMS) 상용구 템플릿.
///
/// v2 전용. 카카오 템플릿과 달리 **검수가 없어** 만들면 바로 쓸 수 있고,
/// 기업 계정이 아니어도 된다.
class MessageTemplateService {
  final SendgoHttpClient _http;

  MessageTemplateService(this._http);

  /// 목록 조회.
  Future<Map<String, dynamic>> list({
    String? messageType,
    String? search,
    int? count,
  }) =>
      _http.get('message-templates', {
        'messageType': messageType,
        'search': search,
        'count': count?.toString(),
      });

  /// 상세 조회.
  Future<Map<String, dynamic>> show(String templateKey) =>
      _http.get('message-templates/${Uri.encodeComponent(templateKey)}');

  /// 등록. LMS·MMS 는 `messageTranSubject` 가 필수다.
  Future<Map<String, dynamic>> create(MessageTemplateRequest request) =>
      _http.post('message-templates', request.toJson());

  /// 수정.
  Future<Map<String, dynamic>> update(
          String templateKey, MessageTemplateRequest request) =>
      _http.put('message-templates/${Uri.encodeComponent(templateKey)}',
          request.toJson());

  /// 삭제 (소프트 삭제 — 목록에서만 사라진다).
  Future<Map<String, dynamic>> delete(String templateKey) =>
      _http.delete('message-templates/${Uri.encodeComponent(templateKey)}');
}

/// 카카오 이미지 업로드 — 브랜드메시지 템플릿에 넣을 URL 발급.
///
/// v2 전용, 기업 계정 전용. 브랜드메시지 템플릿의 `imageUrl` 은 아무 URL 이나
/// 되는 게 아니라 **카카오가 호스팅하는 URL** 이어야 하고, 그 URL 을 얻는
/// 방법이 이 업로드뿐이다.
class KakaoImageService {
  final SendgoHttpClient _http;

  KakaoImageService(this._http);

  /// 업로드 가능한 유형과 제약.
  Future<Map<String, dynamic>> types() => _http.get('kakao-images/types');

  /// 단일 이미지 업로드. jpg/png, 2MB 이하. `data.imageUrl` 을 받는다.
  Future<Map<String, dynamic>> upload(
          String imageType, SendgoMultipartFile image) =>
      _http.postMultipart(
        'kakao-images/${Uri.encodeComponent(imageType)}',
        files: [image.withFieldName('image')],
      );

  /// 다중 이미지 업로드. 유형별 최대 개수가 다르다.
  Future<Map<String, dynamic>> uploadMany(
    String imageType,
    List<SendgoMultipartFile> images,
  ) {
    // 서버는 images[0], images[1] 형태를 기대한다.
    final named = [
      for (var i = 0; i < images.length; i++)
        images[i].withFieldName('images[$i]'),
    ];

    return _http.postMultipart(
      'kakao-images/${Uri.encodeComponent(imageType)}',
      files: named,
    );
  }
}

/// 수신거부(080) 번호 조회. v2 전용, 조회 전용.
///
/// 발송 API 가 알아서 제외하지만 **자기 DB 의 수신 상태도 맞춰야** 한다 —
/// 그러지 않으면 매번 보내고 매번 걸러지는 것을 반복하고, 자기 화면에서는
/// 여전히 "수신 동의" 로 보인다.
class RejectedNumberService {
  final SendgoHttpClient _http;

  RejectedNumberService(this._http);

  /// `since` 로 증분만 가져간다. 전체를 매번 받으면 번호가 쌓일수록 무거워진다.
  Future<Map<String, dynamic>> list({
    String? since,
    String? search,
    int? count,
  }) =>
      _http.get('rejected-numbers', {
        'since': since,
        'search': search,
        'count': count?.toString(),
      });
}

/// 이벤트 웹훅 구독 — 등록·심사 결과를 밀어 받는다. v2 전용.
///
/// 심사는 비동기라 폴링 말고는 방법이 없었다. 구독해 두면 상태가 바뀔 때마다
/// 도착한다.
class WebhookService {
  final SendgoHttpClient _http;

  WebhookService(this._http);

  /// 현재 구독 설정. 마지막 전송 결과(`lastStatus`)도 함께 온다.
  Future<Map<String, dynamic>> show() => _http.get('webhook');

  /// 구독 생성·수정.
  ///
  /// [secret] 을 생략하면 서버가 만들어 **이 응답에서 한 번만** 돌려준다.
  /// 이미 시크릿이 있는 상태에서 생략하면 기존 값을 유지한다 — URL 만 바꾸는
  /// 호출이 서명 키를 날리지 않는다.
  ///
  /// [events] 가 null 이면 전체 구독이다.
  Future<Map<String, dynamic>> subscribe(
    String url, {
    String? secret,
    List<String>? events,
    bool enabled = true,
  }) =>
      _http.put('webhook', {
        'url': url,
        'enabled': enabled,
        if (secret != null) 'secret': secret,
        if (events != null) 'events': events,
      });

  /// 테스트 이벤트 발송. 구독 목록과 무관하게 도착한다.
  Future<Map<String, dynamic>> test() => _http.post('webhook/test', const {});

  /// 구독 해지.
  Future<Map<String, dynamic>> unsubscribe() => _http.delete('webhook');

  /// 수신한 웹훅의 서명을 검증한다.
  ///
  /// [rawBody] 는 **받은 바이트 그대로**여야 한다. 파싱한 뒤 다시 인코딩한
  /// 값으로 계산하면 키 순서나 이스케이프 차이로 검증이 깨진다.
  static bool verifySignature(
    List<int> rawBody,
    String signature,
    String secret,
  ) {
    final expected =
        Hmac(sha256, utf8.encode(secret)).convert(rawBody).toString();

    // 길이가 다르면 즉시 거절한다. 같으면 상수 시간으로 비교한다.
    if (expected.length != signature.length) return false;

    var diff = 0;
    for (var i = 0; i < expected.length; i++) {
      diff |= expected.codeUnitAt(i) ^ signature.codeUnitAt(i);
    }

    return diff == 0;
  }
}

/// Sendgo Flutter SDK 메인 클라이언트.
class SendgoClient {
  late final AlimtalkService alimtalk;

  /// 카카오 친구톡.
  @Deprecated('친구톡은 2025-12-31 종료되었습니다. brandMessage 를 사용하세요.')
  // ignore: deprecated_member_use_from_same_package
  late final FriendtalkService friendtalk;

  /// 카카오 브랜드메시지 — 친구톡의 후속 채널. v2 전용.
  late final BrandMessageService brandMessage;
  /// 짧은 URL — 링크 단축과 클릭 반응 분석. v2 전용.
  late final ShortUrlService shortUrl;
  late final SmsService sms;

  /// 카카오 발신프로필(채널) 등록·동기화. v2 전용, 기업 계정 전용.
  late final KakaoSenderService kakaoSenders;

  /// 알림톡 템플릿 등록·수정·검수 요청. v2 전용, 기업 계정 전용.
  late final NoticeTemplateService noticeTemplates;

  /// 브랜드메시지(구 친구톡) 템플릿 관리. v2 전용, 기업 계정 전용.
  late final BrandTemplateService brandTemplates;

  /// 발신번호 등록·심사 접수. v2 전용.
  late final SenderRegistrationService senderRegistration;

  /// 문자 상용구 템플릿. v2 전용.
  late final MessageTemplateService messageTemplates;

  /// 카카오 이미지 업로드 — 브랜드메시지 템플릿용 URL 발급. v2 전용, 기업 계정 전용.
  late final KakaoImageService kakaoImages;

  /// 수신거부(080) 번호 조회. v2 전용.
  late final RejectedNumberService rejectedNumbers;

  /// 이벤트 웹훅 구독 — 등록·심사 결과를 밀어 받는다. v2 전용.
  late final WebhookService webhook;

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
    // ignore: deprecated_member_use_from_same_package
    friendtalk = FriendtalkService(http, kakaoSenderKey, smsSenderKey);
    brandMessage = BrandMessageService(http, kakaoSenderKey, smsSenderKey);
    shortUrl   = ShortUrlService(http);
    sms        = SmsService(http, smsSenderKey);

    kakaoSenders       = KakaoSenderService(http);
    noticeTemplates    = NoticeTemplateService(http);
    brandTemplates     = BrandTemplateService(http);
    senderRegistration = SenderRegistrationService(http);
    messageTemplates   = MessageTemplateService(http);
    kakaoImages        = KakaoImageService(http);
    rejectedNumbers    = RejectedNumberService(http);
    webhook            = WebhookService(http);
  }
}
