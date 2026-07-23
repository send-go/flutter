# sendgo_flutter

> **Sendgo** Flutter / Dart SDK — 카카오 알림톡/친구톡, SMS/LMS/MMS

[![pub.dev](https://img.shields.io/pub/v/sendgo_flutter)](https://pub.dev/packages/sendgo_flutter)
[![Dart](https://img.shields.io/badge/Dart-3.3+-blue)](https://dart.dev)

> **보안 주의사항**: API 키는 Flutter 앱(클라이언트)에 직접 포함하지 마세요.
> 이 SDK는 **Dart 서버사이드**(Cloud Functions, Dart Frog, etc.)에서 사용하도록 설계되어 있습니다.

---

## 빠른 시작 (3단계)

### 1단계 — 설치

```yaml
# pubspec.yaml
dependencies:
  sendgo_flutter: ^1.0.0
```
```bash
flutter pub get
```

### 2단계 — Dart 서버 환경변수 설정

```env
SENDGO_ACCESS_KEY=your_access_key
SENDGO_SECRET_KEY=your_secret_key
SENDGO_KAKAO_SENDER_KEY=your_kakao_key
SENDGO_SMS_SENDER_KEY=your_sms_key
```

### 3단계 — 알림톡 전송 (Dart 서버)

```dart
import 'dart:io';
import 'package:sendgo_flutter/sendgo_flutter.dart';

Future<void> main() async {
  final client = SendgoClient(
    accessKey:      Platform.environment['SENDGO_ACCESS_KEY']!,
    secretKey:      Platform.environment['SENDGO_SECRET_KEY']!,
    kakaoSenderKey: Platform.environment['SENDGO_KAKAO_SENDER_KEY'],
    smsSenderKey:   Platform.environment['SENDGO_SMS_SENDER_KEY'],
    apiVersion:     'v2',
  );

  await client.alimtalk.send(AlimtalkRequest(
    templateCode: 'ORDER_CONFIRM_001',
    contacts: [Contact(contact: '01012345678', name: '홍길동', var1: 'ORD-001')],
  ));
}
```

---

## 기능별 사용법

### 알림톡

```dart
// SMS 대체 발송
await client.alimtalk.send(AlimtalkRequest(
  templateCode: 'DELIVERY_001',
  contacts: [Contact(contact: '01012345678', var1: 'ORD-001')],
  replaceSms: 'Y',
  smsSubject: '[배송 안내]',
  smsContent: '상품이 출고되었습니다.',
));

// 예약 발송
await client.alimtalk.send(AlimtalkRequest(
  templateCode: 'PROMO_001',
  contacts: [Contact(contact: '01012345678')],
  scheduleType: 'SCHEDULED',
  at: '2026-04-01 09:00:00',
));
```

### SMS / LMS / MMS

```dart
await client.sms.sendSms(SmsRequest(content: '인증번호: 123456', contacts: [Contact(contact: '01012345678')]));
await client.sms.sendLms(SmsRequest(subject: '[공지]', content: '...', contacts: [...]));
```

### 친구톡

```dart
await client.friendtalk.send(FriendtalkRequest(
  content: '안녕하세요! 이번 주 특가 이벤트입니다.',
  contacts: [Contact(contact: '01012345678')],
));
```

---

## 예외 처리

```dart
try {
  await client.alimtalk.send(...);
} on SendgoException catch (e) {
  print('발송 실패: ${e.statusCode} [${e.errorCode}] ${e.message}');
  switch (e.errorCode) {
    case 'INVALID_TEMPLATE_CODE': print('템플릿 코드를 확인하세요.'); break;
    case 'PAYMENT_REQUIRED':      print('크레딧이 부족합니다.'); break;
  }
}
```

---

## Flutter 앱에서 사용하는 방법

Flutter 앱에서 Sendgo API를 호출하려면 **서버 API를 경유**해야 합니다:

```dart
// Flutter 앱 (클라이언트)
final response = await http.post(
  Uri.parse('https://your-server.com/api/notify'),
  body: jsonEncode({'phone': phone, 'orderNumber': orderNumber}),
);

// 서버 (Cloud Functions / Dart Frog)
final client = SendgoClient(...); // API 키는 서버에만 보관
await client.alimtalk.send(...);
```

---

## 라이선스

MIT License © [Sendgo](https://sendgo.io)
