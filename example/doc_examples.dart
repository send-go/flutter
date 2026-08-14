// Type-checks the API surface used by the published guides.
// Not run — `dart analyze` proving it compiles is the point.
//
// 친구톡 예제는 2025-12-31 종료된 API 를 그대로 남겨 둔다. 기존 사용자의 코드가
// 아직 동작한다는 것을 보여야 하므로, 의도적으로 deprecated 경고만 끈다.
// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:io';

import 'package:sendgo_flutter/sendgo_flutter.dart';

final sendgo = SendgoClient(
  accessKey: Platform.environment['SENDGO_ACCESS_KEY']!,
  secretKey: Platform.environment['SENDGO_SECRET_KEY']!,
  kakaoSenderKey: Platform.environment['SENDGO_KAKAO_SENDER_KEY'],
  smsSenderKey: Platform.environment['SENDGO_SMS_SENDER_KEY'],
  apiVersion: 'v2',
);

void alertOps(String m) => stderr.writeln(m);

Future<void> alimtalk() async {
  await sendgo.alimtalk.send(AlimtalkRequest(
    templateCode: 'ORDER_CONFIRM_001',
    contacts: [
      Contact(contact: '01011111111', name: '洪吉童', var1: 'ORD-001', var2: '29,000元'),
      Contact(contact: '01022222222', var1: 'ORD-002', var8: 'x'),
    ],
  ));

  await sendgo.alimtalk.send(AlimtalkRequest(
    templateCode: 'PROMO_SUMMER_2026',
    scheduleType: 'SCHEDULED',
    at: '2026-07-28 09:00:00',
    contacts: [Contact(contact: '01012345678', var1: '夏季限定 5 折')],
  ));

  await sendgo.alimtalk.send(AlimtalkRequest(
    templateCode: 'DELIVERY_START_001',
    replaceSms: 'Y',
    smsSubject: '[发货通知]',
    smsContent: '您购买的商品已出库。',
    contacts: [Contact(contact: '01012345678', var1: 'ORD-001')],
  ));
}

/// 친구톡은 2025-12-31 종료되었다. brandMessage() 예제를 참고할 것.
Future<void> friendtalk() async {
  await sendgo.friendtalk.send(FriendtalkRequest(
    content: '7 月限时特惠开始了，欢迎查看。',
    contacts: [Contact(contact: '01012345678')],
  ));

  await sendgo.friendtalk.send(FriendtalkRequest(
    messageType: 'FI',
    content: '本周特价商品',
    imageUrl: 'https://cdn.example.com/banner.jpg',
    imageLink: 'https://example.com/event',
    contacts: [Contact(contact: '01012345678')],
  ));
}

Future<void> brandMessage() async {
  await sendgo.brandMessage.send(BrandMessageRequest(
    targeting: 'M',
    messageType: 'FL',
    friendTemplateUuid: '9cd5460b-6458-4edc-9b11-c26d3013c340',
    contacts: [Contact(contact: '01012345678', var1: '29,000元')],
  ));

  final accepted = await sendgo.brandMessage.broadcast(BrandMessageRequest(
    messageType: 'FW',
    friendTemplateUuid: '9cd5460b-6458-4edc-9b11-c26d3013c340',
  ));

  await sendgo.brandMessage.campaign(accepted['data']['campaignId'] as String);
  await sendgo.brandMessage.campaigns(from: '2026-08-01', count: 10);
}

Future<void> sms() async {
  await sendgo.sms.sendSms(SmsRequest(
    content: '[Sendgo] 验证码：123456（请在 5 分钟内输入）',
    contacts: [Contact(contact: '01012345678')],
  ));

  await sendgo.sms.sendLms(SmsRequest(
    subject: '[重要] 服务维护通知',
    content: '服务将于 2026-07-25 02:00 ~ 06:00 进行维护。',
    contacts: [Contact(contact: '01012345678')],
  ));

  await sendgo.sms.sendMms(SmsRequest(
    subject: '[活动] 7 月特惠',
    content: '欢迎查看本月特价商品。',
    contacts: [Contact(contact: '01012345678')],
  ));
}

Future<void> errorHandling(AlimtalkRequest request) async {
  try {
    await sendgo.alimtalk.send(request);
  } on SendgoException catch (e) {
    stderr.writeln('Sendgo ${e.statusCode} [${e.errorCode}] ${e.endpoint}: ${e.message}');
    stderr.writeln('${e.apiVersion} ${e.responseBody}');

    switch (e.errorCode) {
      case 'INVALID_ACCESS_KEY':
      case 'INVALID_SECRET_KEY':
        alertOps('请检查 Sendgo 密钥');
      case 'IP_NOT_ALLOWED':
        alertOps('该 IP 未在白名单中');
      case 'PAYMENT_REQUIRED':
        alertOps('Sendgo 余额不足');
      default:
        if (e.statusCode >= 500) rethrow;
    }
  }
}

Future<void> shortUrls() async {
  final created = await sendgo.shortUrl.create(const ShortUrlRequest(
    targetUrl: 'https://example.com/promotions/summer-sale',
    title: '여름 세일 랜딩',
    expiresAt: '2026-09-30 23:59:59',
  ));

  final code = created['data']['code'] as String;
  final short = created['data']['shortUrl'] as String;
  stderr.writeln('$code -> $short');

  await sendgo.shortUrl.list(from: '2026-08-01', count: 10);
  await sendgo.shortUrl.show(code);
  await sendgo.shortUrl.stats(code, from: '2026-08-01', to: '2026-08-31');
  await sendgo.shortUrl.deactivate(code);

  // forceNew: 캠페인별로 반응을 분리해 집계할 때
  await sendgo.shortUrl.create(const ShortUrlRequest(
    targetUrl: 'https://example.com/promotions/summer-sale',
    forceNew: true,
  ));
}
