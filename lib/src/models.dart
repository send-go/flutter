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
