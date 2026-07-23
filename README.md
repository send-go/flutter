# sendgo_flutter

> **Flutter / Dart 서버에서 카카오 알림톡, 친구톡, SMS를 발송하는 공식 Dart SDK**

[![pub.dev](https://img.shields.io/pub/v/sendgo_flutter)](https://pub.dev/packages/sendgo_flutter)
[![Dart](https://img.shields.io/badge/Dart-3.3%2B-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

> **중요**: 이 패키지는 **서버사이드 전용**입니다 (Dart 백엔드, Shelf, Serverpod 등).
> API 키가 클라이언트(Flutter 앱)에 노출되지 않도록 반드시 서버에서만 사용하세요.

---

## 설치

```yaml
# pubspec.yaml
dependencies:
  sendgo_flutter: ^1.0.0
```

```bash
dart pub get
```

---

## 빠른 시작

```dart
import 'package:sendgo_flutter/sendgo_flutter.dart';

void main() async {
  final client = SendgoClient(
    accessKey:      Platform.environment['SENDGO_ACCESS_KEY']!,
    secretKey:      Platform.environment['SENDGO_SECRET_KEY']!,
    kakaoSenderKey: Platform.environment['SENDGO_KAKAO_SENDER_KEY'],
    smsSenderKey:   Platform.environment['SENDGO_SMS_SENDER_KEY'],
    apiVersion:     'v2',
  );

  // 알림톡 발송
  await client.alimtalk.send(
    templateCode: 'ORDER_CONFIRM_001',
    contacts: [
      Contact(contact: '01012345678', name: '홍길동', var1: 'ORD-001', var2: '29,000원'),
    ],
  );
}
```

---

## 알림톡 상세 사용법

```dart
import 'package:sendgo_flutter/sendgo_flutter.dart';

final client = SendgoClient(
  accessKey: Platform.environment['SENDGO_ACCESS_KEY']!,
  secretKey: Platform.environment['SENDGO_SECRET_KEY']!,
  kakaoSenderKey: Platform.environment['SENDGO_KAKAO_SENDER_KEY'],
  smsSenderKey:   Platform.environment['SENDGO_SMS_SENDER_KEY'],
  apiVersion: 'v2',
);

// 다건 발송
await client.alimtalk.send(
  templateCode: 'ORDER_CONFIRM_001',
  contacts: [
    Contact(contact: '01011111111', name: '홍길동', var1: 'ORD-001', var2: '29,000원'),
    Contact(contact: '01022222222', name: '김철수', var1: 'ORD-002', var2: '15,000원'),
    Contact(contact: '01033333333', name: '이영희', var1: 'ORD-003', var2: '52,000원'),
  ],
);

// 예약 발송
await client.alimtalk.send(
  templateCode: 'PROMO_SUMMER_2026',
  scheduleType: 'SCHEDULED',
  at:           '2026-07-28 09:00:00',
  contacts: [Contact(contact: '01012345678', var1: '여름 한정 50% 할인')],
);

// SMS 자동 대체 발송
await client.alimtalk.send(
  templateCode: 'DELIVERY_START_001',
  replaceSms:   'Y',
  smsSubject:   '[배송 시작 안내]',
  smsContent:   '주문하신 상품이 출고되었습니다.\n송장번호: #{var2}',
  contacts: [Contact(contact: '01012345678', var1: 'ORD-001', var2: '1234567890')],
);
```

---

## 친구톡 사용법

```dart
// 텍스트형
await client.friendtalk.send(
  content:  '안녕하세요! 7월 한정 특가 이벤트를 확인해보세요.',
  contacts: [Contact(contact: '01012345678')],
);

// 이미지형
await client.friendtalk.send(
  messageType: 'FI',
  content:     '이번 주 특가 상품을 확인하세요!',
  imageUrl:    'https://cdn.example.com/banner.jpg',
  imageLink:   'https://example.com/event',
  contacts:    [Contact(contact: '01012345678')],
);
```

---

## SMS / LMS / MMS 사용법

```dart
// SMS
await client.sms.sendSms(
  content:  '[Sendgo] 인증번호: 123456 (5분 이내 입력)',
  contacts: [Contact(contact: '01012345678')],
);

// LMS
await client.sms.sendLms(
  subject:  '[중요] 서비스 점검 안내',
  content:  '안녕하세요. 서비스 점검이 예정되어 있습니다.\n■ 일시: 2026-07-25 02:00 ~ 06:00',
  contacts: [Contact(contact: '01012345678')],
);

// MMS
await client.sms.sendMms(
  subject:  '[이벤트] 7월 특가',
  content:  '이번 달 특가 상품을 확인하세요!',
  contacts: [
    Contact(contact: '01011111111'),
    Contact(contact: '01022222222'),
  ],
);
```

---

## Shelf 서버 통합

```dart
// bin/server.dart
import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:sendgo_flutter/sendgo_flutter.dart';

final sendgo = SendgoClient(
  accessKey:      Platform.environment['SENDGO_ACCESS_KEY']!,
  secretKey:      Platform.environment['SENDGO_SECRET_KEY']!,
  kakaoSenderKey: Platform.environment['SENDGO_KAKAO_SENDER_KEY'],
  apiVersion:     'v2',
);

Response handler(Request request) async {
  if (request.url.path == 'api/notify/order' && request.method == 'POST') {
    final body = jsonDecode(await request.readAsString());
    await sendgo.alimtalk.send(
      templateCode: 'ORDER_CONFIRM_001',
      contacts: [Contact(contact: body['phone'], var1: body['orderNo'])],
    );
    return Response.ok(jsonEncode({'success': true}),
        headers: {'content-type': 'application/json'});
  }
  return Response.notFound('Not found');
}

void main() async {
  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  print('서버 시작: ${server.port}');
}
```

---

## 예외 처리

```dart
import 'package:sendgo_flutter/sendgo_flutter.dart';

try {
  await client.alimtalk.send(
    templateCode: 'ORDER_CONFIRM_001',
    contacts: [Contact(contact: '01012345678')],
  );
} on SendgoException catch (e) {
  print('발송 실패: HTTP ${e.statusCode} [${e.errorCode}]');

  switch (e.errorCode) {
    case 'INVALID_ACCESS_KEY':
    case 'INVALID_SECRET_KEY':
      alertOps('Sendgo 인증키를 확인하세요.');
    case 'INVALID_TEMPLATE_CODE':
      logger.warn('존재하지 않는 템플릿: ${e.message}');
    case 'PAYMENT_REQUIRED':
      alertOps('Sendgo 크레딧이 부족합니다.');
    case 'IP_NOT_ALLOWED':
      alertOps('허용되지 않은 IP');
  }
}
```

---

## 설정 옵션

| 파라미터 | 타입 | 필수 | 기본값 | 설명 |
|---------|------|------|--------|------|
| `accessKey` | `String` | **필수** | — | Sendgo 액세스 키 |
| `secretKey` | `String` | **필수** | — | Sendgo 시크릿 키 |
| `kakaoSenderKey` | `String?` | 선택 | `null` | 카카오 발신프로필 키 |
| `smsSenderKey` | `String?` | 선택 | `null` | SMS 발신자 키 |
| `apiVersion` | `String` | 선택 | `'v2'` | API 버전 (`v1` \| `v2`) |
| `baseUrl` | `String` | 선택 | `'https://api.sendgo.io'` | API 기본 URL |

---

## 관련 패키지

| 언어/프레임워크 | 패키지 | GitHub |
|----------------|--------|--------|
| Spring Boot | `io.sendgo:sendgo-spring` | [spring](https://github.com/send-go/spring) |
| Node.js | `@sendgo/node` | [node](https://github.com/send-go/node) |
| Python | `sendgo-python` | [python](https://github.com/send-go/python) |
| 전체 목록 | — | [send-go GitHub 조직](https://github.com/send-go) |

---

## 라이선스

MIT License © 2026 [Sendgo](https://sendgo.io)

---

*키워드: 카카오 알림톡 Flutter, 카카오 친구톡 Dart, SMS 발송 Flutter, 알림톡 Dart SDK, Dart 카카오 API, Sendgo Flutter SDK, pub.dev 알림 발송*
