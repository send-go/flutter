/// 수신자 정보
class Contact {
  final String contact;
  final String? name;
  final String? var1, var2, var3, var4, var5, var6, var7, var8;

  const Contact({
    required this.contact,
    this.name,
    this.var1, this.var2, this.var3, this.var4,
    this.var5, this.var6, this.var7, this.var8,
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
