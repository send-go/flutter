/// 수신자 정보
class Contact {
  final String contact;
  final String? name;
  final String? var1, var2, var3, var4, var5, var6, var7, var8;

  /// 임의 명명 템플릿 변수 (예: {'title': '...'}) → 알림톡 #{title} 치환.
  /// contact 오브젝트에 평탄하게 직렬화됩니다.
  final Map<String, String>? variables;

  const Contact({
    required this.contact,
    this.name,
    this.var1, this.var2, this.var3, this.var4,
    this.var5, this.var6, this.var7, this.var8,
    this.variables,
  });

  Map<String, dynamic> toJson() => {
    'contact': contact,
    if (name != null) 'name': name,
    if (var1 != null) 'var1': var1,
    if (var2 != null) 'var2': var2,
    if (var3 != null) 'var3': var3,
    if (var4 != null) 'var4': var4,
    if (var5 != null) 'var5': var5,
    if (var6 != null) 'var6': var6,
    if (var7 != null) 'var7': var7,
    if (var8 != null) 'var8': var8,
    if (variables != null) ...variables!,
  };
}

/// 카카오 알림톡 요청
class AlimtalkRequest {
  final String templateCode;
  final List<Contact> contacts;
  final String scheduleType;
  final String? at;
  final String replaceSms;
  final String? smsSubject;
  final String? smsContent;

  const AlimtalkRequest({
    required this.templateCode,
    required this.contacts,
    this.scheduleType = 'DIRECTLY',
    this.at,
    this.replaceSms = 'N',
    this.smsSubject,
    this.smsContent,
  });

  Map<String, dynamic> toJson() => {
    'at': at,
    'scheduleType': scheduleType,
    'templateCode': templateCode,
    'replaceSms': replaceSms,
    'smsSubject': replaceSms == 'Y' ? smsSubject : null,
    'smsContent': replaceSms == 'Y' ? smsContent : null,
    'contacts': contacts.map((c) => c.toJson()).toList(),
  };
}

/// 카카오 친구톡 요청
class FriendtalkRequest {
  final String content;
  final List<Contact> contacts;
  final String messageType;
  final String scheduleType;
  final String? at;
  final List<Map<String, dynamic>> buttons;
  final String? imageUrl;
  final String? imageLink;
  final String adFlag;
  final String wide;
  final String adult;
  final String? header;
  final String replaceSms;
  final String? smsSubject;
  final String? smsContent;

  const FriendtalkRequest({
    required this.content,
    required this.contacts,
    this.messageType = 'FT',
    this.scheduleType = 'DIRECTLY',
    this.at,
    this.buttons = const [],
    this.imageUrl,
    this.imageLink,
    this.adFlag = 'Y',
    this.wide = 'N',
    this.adult = 'N',
    this.header,
    this.replaceSms = 'N',
    this.smsSubject,
    this.smsContent,
  });

  Map<String, dynamic> toJson() => {
    'at': at,
    'scheduleType': scheduleType,
    'messageType': messageType,
    'content': content,
    'buttons': buttons,
    'image': null,
    'imageUrl': imageUrl,
    'imageLink': imageLink,
    'adFlag': adFlag,
    'wide': wide,
    'adult': adult,
    'header': header,
    'replaceSms': replaceSms,
    'smsSubject': replaceSms == 'Y' ? smsSubject : null,
    'smsContent': replaceSms == 'Y' ? smsContent : null,
    'contacts': contacts.map((c) => c.toJson()).toList(),
  };
}

/// 카카오 브랜드메시지 요청.
///
/// 브랜드메시지는 친구톡의 후속 채널로, [messageType] 에는 친구톡 코드
/// (FT/FI/FW/FL/FC/FM/FP/FA)를 그대로 넘기며 브랜드메시지 코드
/// (BT/BI/BW/BL/BC/BM/BP/BA) 변환은 서버가 처리한다.
///
/// [targeting] 은 M(채널 친구) / N(비친구) / I(전체) / F(동보)이며,
/// F 는 수신자 목록을 카카오 측에서 확장하므로 [contacts] 를 넘기지 않는다.
class BrandMessageRequest {
  final String friendTemplateUuid;
  final String targeting;
  final String messageType;
  final List<Contact>? contacts;
  final String? content;
  final String scheduleType;
  final String? at;
  final List<Map<String, dynamic>> buttons;
  final String? imageUrl;
  final String? imageLink;
  final String adFlag;
  final String adult;
  final String pushAlarm;
  final String? header;
  final Map<String, dynamic>? coupon;
  final Map<String, dynamic>? item;
  final Map<String, dynamic>? commerce;
  final List<Map<String, dynamic>>? list;
  final Map<String, dynamic>? head;
  final Map<String, dynamic>? tail;
  final Map<String, dynamic>? video;
  final String? additionalContent;
  final String? friendGroupKey;
  final String replaceSms;
  final String? smsSubject;
  final String? smsContent;
  final String? rejectServiceId;
  final List<String> webhooks;

  const BrandMessageRequest({
    required this.friendTemplateUuid,
    this.targeting = 'M',
    this.messageType = 'FT',
    this.contacts,
    this.content,
    this.scheduleType = 'DIRECTLY',
    this.at,
    this.buttons = const [],
    this.imageUrl,
    this.imageLink,
    this.adFlag = 'Y',
    this.adult = 'N',
    this.pushAlarm = 'Y',
    this.header,
    this.coupon,
    this.item,
    this.commerce,
    this.list,
    this.head,
    this.tail,
    this.video,
    this.additionalContent,
    this.friendGroupKey,
    this.replaceSms = 'N',
    this.smsSubject,
    this.smsContent,
    this.rejectServiceId,
    this.webhooks = const [],
  });

  /// [targeting] 이 'F'(동보)면 수신자 목록이 없으므로 contacts 키를 넣지 않는다.
  /// 빈 배열을 보내면 잘못된 요청으로 거절된다.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'at': at,
      'scheduleType': scheduleType,
      'targeting': targeting,
      'messageType': messageType,
      'friendTemplateUuid': friendTemplateUuid,
      'content': content,
      'buttons': buttons,
      'imageUrl': imageUrl,
      'imageLink': imageLink,
      'adFlag': adFlag,
      'adult': adult,
      'pushAlarm': pushAlarm,
      'header': header,
      'coupon': coupon,
      'item': item,
      'commerce': commerce,
      'list': list,
      'head': head,
      'tail': tail,
      'video': video,
      'additionalContent': additionalContent,
      'friendGroupKey': friendGroupKey,
      'replaceSms': replaceSms,
      'smsSubject': replaceSms == 'Y' ? smsSubject : null,
      'smsContent': replaceSms == 'Y' ? smsContent : null,
      'rejectServiceId': rejectServiceId,
      'webhooks': webhooks,
    };

    if (targeting != 'F') {
      json['contacts'] = (contacts ?? const <Contact>[]).map((c) => c.toJson()).toList();
    }

    return json;
  }

  /// 동보 발송용 사본을 만든다 (targeting 'F', contacts 제거).
  BrandMessageRequest asBroadcast() => BrandMessageRequest(
        friendTemplateUuid: friendTemplateUuid,
        targeting: 'F',
        messageType: messageType,
        content: content,
        scheduleType: scheduleType,
        at: at,
        buttons: buttons,
        imageUrl: imageUrl,
        imageLink: imageLink,
        adFlag: adFlag,
        adult: adult,
        pushAlarm: pushAlarm,
        header: header,
        coupon: coupon,
        item: item,
        commerce: commerce,
        list: list,
        head: head,
        tail: tail,
        video: video,
        additionalContent: additionalContent,
        friendGroupKey: friendGroupKey,
        replaceSms: replaceSms,
        smsSubject: smsSubject,
        smsContent: smsContent,
        rejectServiceId: rejectServiceId,
        webhooks: webhooks,
      );
}

/// SMS/LMS/MMS 요청
class SmsRequest {
  final String content;
  final List<Contact> contacts;
  final String messageType;
  final String campaignType;
  final String scheduleType;
  final String? at;
  final String? subject;
  final List<dynamic> files;

  const SmsRequest({
    required this.content,
    required this.contacts,
    this.messageType = 'SMS',
    this.campaignType = 'MESSAGE',
    this.scheduleType = 'DIRECTLY',
    this.at,
    this.subject,
    this.files = const [],
  });

  Map<String, dynamic> toJson() => {
    'campaignType': campaignType,
    'messageType': messageType,
    'scheduleType': scheduleType,
    'at': at,
    'subject': subject,
    'content': content,
    'files': files,
    'contacts': contacts.map((c) => c.toJson()).toList(),
  };
}

/// 짧은 URL 생성 요청.
class ShortUrlRequest {
  /// 줄일 원본 URL. http/https 만 허용된다.
  final String targetUrl;

  /// 관리 화면에서 구분하기 위한 이름.
  final String? title;

  /// 이 시각 이후에는 리다이렉트하지 않고 410 Gone 을 반환한다.
  final String? expiresAt;

  /// true 면 같은 URL 이라도 새 코드를 만든다.
  /// 캠페인별로 반응을 분리해 집계할 때 사용한다.
  final bool forceNew;

  const ShortUrlRequest({
    required this.targetUrl,
    this.title,
    this.expiresAt,
    this.forceNew = false,
  });

  Map<String, dynamic> toJson() => {
        'targetUrl': targetUrl,
        if (title != null) 'title': title,
        if (expiresAt != null) 'expiresAt': expiresAt,
        'forceNew': forceNew,
      };
}

// ----------------------------------------------------------------
// 관리 API (v2 전용) — 등록 · 심사
// ----------------------------------------------------------------

/// multipart 업로드에 붙일 파일.
///
/// 서류·이미지 첨부가 있는 관리 API(발신번호 등록, 이미지 템플릿, 검수 첨부)는
/// JSON 으로 보낼 수 없다. 서버 검증이 확장자를 보므로 [fileName] 은 반드시
/// 실제 확장자를 포함해야 한다.
class SendgoMultipartFile {
  /// 폼 필드 이름 (예: `csuCertificate`).
  final String fieldName;

  /// 서버에 알릴 파일명 (예: `csu.pdf`).
  final String fileName;

  /// 파일 내용.
  final List<int> bytes;

  const SendgoMultipartFile({
    required this.fieldName,
    required this.fileName,
    required this.bytes,
  });

  /// 필드 이름만 바꾼 복사본. 서비스가 필드명을 정할 때 쓴다.
  SendgoMultipartFile withFieldName(String name) => SendgoMultipartFile(
        fieldName: name,
        fileName: fileName,
        bytes: bytes,
      );
}

/// 카카오 발신프로필 등록 요청 (2단계).
///
/// [token] 은 1단계에서 카카오가 채널 관리자 휴대폰으로 SMS 발송한 인증번호다.
/// SDK 는 그 값을 볼 수 없다 — 사람이 문자를 읽어 넣어야 한다.
class KakaoSenderCreateRequest {
  final String token;

  /// 채널 검색용 아이디. `@` 는 있어도 없어도 된다.
  final String yellowId;
  final String phoneNumber;

  /// `categories()` 로 조회한 코드.
  final String categoryCode;

  const KakaoSenderCreateRequest({
    required this.token,
    required this.yellowId,
    required this.phoneNumber,
    required this.categoryCode,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'yellowId': yellowId,
        'phoneNumber': phoneNumber,
        'categoryCode': categoryCode,
      };
}

/// 알림톡 템플릿 등록·수정 요청.
///
/// 뒤쪽 정책 필드 일곱 개는 sendgo 자체 게이트다. 카카오 심사와 별개이며,
/// 조합이 본문과 어긋나면 `POLICY_VALIDATION_FAILED` 로 거절된다. 확인 플래그
/// 셋은 기본값이 `true` 지만, **내용을 실제로 검토한 뒤에** 그대로 두어야 한다 —
/// 이 값은 법적 확인의 기록이다.
class NoticeTemplateRequest {
  /// 등록 시 폴더 지정. 이동은 templateFolders.assign을 사용합니다.
  final String? folderUuid;
  /// 발신프로필 키. 수정 시에는 무시된다 (변경 불가).
  final String? kakaoSenderKey;
  final String templateName;

  /// 본문. 변수는 `#{name}` 형식으로 쓴다.
  final String templateContent;

  /// BA 기본형 / EX 부가정보형 / AD 채널추가형 / MI 복합형.
  final String templateMessageType;

  /// NONE / TEXT 강조표기 / ITEM_LIST / IMAGE.
  final String templateEmphasizeType;

  /// 6자리 숫자. `categories()` 로 조회한다.
  final String categoryCode;

  final String? templateTitle;
  final String? templateSubtitle;
  final String? templateHeader;
  final String? templateExtra;
  final Map<String, dynamic>? templateItem;
  final Map<String, dynamic>? templateItemHighlight;
  final Map<String, dynamic>? templateRepresentLink;
  final List<Map<String, dynamic>>? buttons;
  final List<Map<String, dynamic>>? quickReplies;
  final bool securityFlag;
  final bool adultFlag;

  /// order_delivery / reservation_booking / payment_billing / account_auth /
  /// service_ops / policy_notice / benefit_notice / customer_support / other.
  final String messagePurpose;

  /// transaction / paid_purchase / event_entry / contract / policy_notice.
  final String legalBasis;

  /// none / paid / event / contract / promo / free.
  final String benefitOrigin;

  /// none / rights_based / promo.
  final String expiryType;

  final bool optInReviewConfirmed;
  final bool ctaClearConfirmed;
  final bool policyConfirmed;

  const NoticeTemplateRequest({
    this.folderUuid,
    this.kakaoSenderKey,
    required this.templateName,
    required this.templateContent,
    this.templateMessageType = 'BA',
    this.templateEmphasizeType = 'NONE',
    required this.categoryCode,
    this.templateTitle,
    this.templateSubtitle,
    this.templateHeader,
    this.templateExtra,
    this.templateItem,
    this.templateItemHighlight,
    this.templateRepresentLink,
    this.buttons,
    this.quickReplies,
    this.securityFlag = false,
    this.adultFlag = false,
    required this.messagePurpose,
    required this.legalBasis,
    required this.benefitOrigin,
    required this.expiryType,
    this.optInReviewConfirmed = true,
    this.ctaClearConfirmed = true,
    this.policyConfirmed = true,
  });

  Map<String, dynamic> toJson() => {
        if (folderUuid != null) 'folderUuid': folderUuid,
        if (kakaoSenderKey != null) 'kakaoSenderKey': kakaoSenderKey,
        'templateName': templateName,
        'templateContent': templateContent,
        'templateMessageType': templateMessageType,
        'templateEmphasizeType': templateEmphasizeType,
        'categoryCode': categoryCode,
        if (templateTitle != null) 'templateTitle': templateTitle,
        if (templateSubtitle != null) 'templateSubtitle': templateSubtitle,
        if (templateHeader != null) 'templateHeader': templateHeader,
        if (templateExtra != null) 'templateExtra': templateExtra,
        if (templateItem != null) 'templateItem': templateItem,
        if (templateItemHighlight != null)
          'templateItemHighlight': templateItemHighlight,
        if (templateRepresentLink != null)
          'templateRepresentLink': templateRepresentLink,
        if (buttons != null) 'buttons': buttons,
        if (quickReplies != null) 'quickReplies': quickReplies,
        'securityFlag': securityFlag,
        'adultFlag': adultFlag,
        'messagePurpose': messagePurpose,
        'legalBasis': legalBasis,
        'benefitOrigin': benefitOrigin,
        'expiryType': expiryType,
        'optInReviewConfirmed': optInReviewConfirmed,
        'ctaClearConfirmed': ctaClearConfirmed,
        'policyConfirmed': policyConfirmed,
      };
}

/// 브랜드메시지(구 친구톡) 템플릿 등록·수정 요청.
///
/// [templateType] 은 친구톡 표기(FT/FI/FW/FL/FC/FM/FP/FA)를 그대로 쓴다 —
/// 서버가 chatBubbleType 으로 변환한다.
class BrandTemplateRequest {
  /// 등록 시 폴더 지정. 이동은 templateFolders.assign을 사용합니다.
  final String? folderUuid;
  final String? kakaoSenderKey;
  final String templateName;
  final String templateType;

  /// 본문. FW·FP 는 76자, FI 는 400자, FT 는 1000자 제한.
  final String? templateContent;
  final bool adult;
  final String? header;

  /// 서버는 이 필드만 snake_case 로 받는다.
  final String? additionalContent;

  /// FI·FW 는 필수.
  final String? imageUrl;
  final String? imageLink;
  final List<Map<String, dynamic>>? buttons;
  final Map<String, dynamic>? coupon;
  final Map<String, dynamic>? item;
  final Map<String, dynamic>? commerce;
  final List<Map<String, dynamic>>? list;
  final Map<String, dynamic>? head;
  final Map<String, dynamic>? tail;
  final Map<String, dynamic>? video;
  final Map<String, dynamic>? mainWideItem;
  final List<Map<String, dynamic>>? subWideItemList;

  const BrandTemplateRequest({
    this.folderUuid,
    this.kakaoSenderKey,
    required this.templateName,
    this.templateType = 'FT',
    this.templateContent,
    this.adult = false,
    this.header,
    this.additionalContent,
    this.imageUrl,
    this.imageLink,
    this.buttons,
    this.coupon,
    this.item,
    this.commerce,
    this.list,
    this.head,
    this.tail,
    this.video,
    this.mainWideItem,
    this.subWideItemList,
  });

  Map<String, dynamic> toJson() => {
        if (folderUuid != null) 'folderUuid': folderUuid,
        if (kakaoSenderKey != null) 'kakaoSenderKey': kakaoSenderKey,
        'templateName': templateName,
        'templateType': templateType,
        if (templateContent != null) 'templateContent': templateContent,
        'adult': adult,
        if (header != null) 'header': header,
        if (additionalContent != null) 'additional_content': additionalContent,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (imageLink != null) 'imageLink': imageLink,
        if (buttons != null) 'buttons': buttons,
        if (coupon != null) 'coupon': coupon,
        if (item != null) 'item': item,
        if (commerce != null) 'commerce': commerce,
        if (list != null) 'list': list,
        if (head != null) 'head': head,
        if (tail != null) 'tail': tail,
        if (video != null) 'video': video,
        if (mainWideItem != null) 'mainWideItem': mainWideItem,
        if (subWideItemList != null) 'subWideItemList': subWideItemList,
      };
}

/// 발신번호 등록 신청의 텍스트 필드. 서류는 [SendgoMultipartFile] 목록으로
/// 따로 넘긴다.
class SenderRegistrationRequest {
  /// API 로 접수할 수 있는 발신번호 유형 — 전부다.
  static const registrableTypes = [
    'personal_mobile',
    'personal_other',
    'team_main',
    'team_representative_mobile',
    'team_emp_mobile',
    'team_other_company',
  ];

  /// 신분증 사본(`identityDocument`)이 필요한 유형.
  ///
  /// 콘솔은 PASS 본인인증을 쓰지만 API 는 신분증 사본을 받아 sendgo 운영자가
  /// 직접 확인한다. 이 경로로 접수된 건은 자동 승인되지 않는다.
  static const identityDocumentTypes = [
    'personal_mobile',
    'team_representative_mobile',
    'team_emp_mobile',
  ];

  /// 계정 안에서 중복될 수 없는 관리용 이름 (20자).
  final String senderAlias;

  /// 여섯 유형 전부 API 로 접수할 수 있다. 휴대폰 계열은 PASS 대신
  /// `identityDocument`(신분증 사본)를 함께 올린다.
  final String senderNumberType;

  /// 숫자와 하이픈만. 서버가 E.164 로 정규화한다.
  final String phoneE164;

  /// `validate()` 의 duplicationReasonRequired 가 true 면 필수.
  final String? duplicationReason;

  /// team_other_company 필수.
  final String? acceptanceName;

  /// team_other_company 필수.
  final String? delegationName;

  /// team_other_company 필수.
  final String? delegationReason;

  const SenderRegistrationRequest({
    required this.senderAlias,
    required this.senderNumberType,
    required this.phoneE164,
    this.duplicationReason,
    this.acceptanceName,
    this.delegationName,
    this.delegationReason,
  });

  /// multipart 필드 맵. 빈 값은 넣지 않는다 — 서버가 "빈 값으로 저장"으로 읽는다.
  Map<String, dynamic> toFields() => {
        'senderAlias': senderAlias,
        'senderNumberType': senderNumberType,
        'phoneE164': phoneE164,
        if (duplicationReason != null) 'duplicationReason': duplicationReason,
        if (acceptanceName != null) 'acceptanceName': acceptanceName,
        if (delegationName != null) 'delegationName': delegationName,
        if (delegationReason != null) 'delegationReason': delegationReason,
      };
}

/// 문자(SMS/LMS/MMS) 상용구 템플릿 등록·수정 요청.
class MessageTemplateRequest {
  /// SMS / LMS / MMS.
  final String messageTranType;

  /// 본문 (2,000자).
  final String messageTranMsg;

  /// 제목 (40자). LMS·MMS 는 필수. SMS 에 넣으면 발송 시 버려진다.
  final String? messageTranSubject;

  final bool isFavorite;

  const MessageTemplateRequest({
    this.messageTranType = 'SMS',
    required this.messageTranMsg,
    this.messageTranSubject,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'messageTranType': messageTranType,
        'messageTranMsg': messageTranMsg,
        if (messageTranSubject != null)
          'messageTranSubject': messageTranSubject,
        'isFavorite': isFavorite,
      };
}

/// 구독할 수 있는 웹훅 이벤트.
class WebhookEvents {
  /// 발신번호 심사 상태가 바뀜.
  static const senderStatus = 'sender.status_changed';

  /// 알림톡 검수 상태가 바뀜.
  static const noticeTemplateInspection =
      'notice_template.inspection_status_changed';

  /// 카카오 채널의 차단·휴면·프로필 상태가 바뀜.
  static const kakaoSenderStatus = 'kakao_sender.status_changed';

  /// 브랜드메시지 M/N 신청 상태가 바뀜.
  static const brandMessageTargeting =
      'kakao_sender.brand_message_status_changed';

  /// 전체 목록.
  static const all = [
    senderStatus,
    noticeTemplateInspection,
    kakaoSenderStatus,
    brandMessageTargeting,
  ];

  const WebhookEvents._();
}

/// 카카오 이미지 업로드 유형.
class KakaoImageTypes {
  /// 파일 하나를 올리고 URL 하나를 받는 유형.
  static const single = [
    'alimtalk',
    'alimtalk_highlight',
    'default',
    'wide',
    'wide_item_list_first',
  ];

  /// 파일 여러 개를 올리는 유형과 최대 개수.
  static const multi = {
    'wide_item_list': 4,
    'carousel_feed': 10,
    'carousel_commerce': 11,
  };

  const KakaoImageTypes._();
}
