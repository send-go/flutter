# sendgo_flutter

> **Flutter / Dart 서버에서 카카오 알림톡, 브랜드메시지, SMS를 발송하는 공식 Dart SDK**

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
  sendgo_flutter: ^1.1.0
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

> ⚠️ **Deprecated — 친구톡은 카카오 정책에 따라 2025-12-31 종료되었습니다.**
> 2026-01-01 부터 친구톡 발송 요청은 카카오 측에서 **브랜드메시지(자유형)** 로 자동 대체 발송됩니다.
> 호출은 계속 성공하며, 자유 본문 타입(`FT`/`FI`/`FW`)을 개별 수신자에게 보내는 경로는
> 현재 이것뿐이므로 기존 코드를 당장 바꿀 필요는 없습니다.
>
> 다음의 경우에는 **브랜드메시지**를 사용하세요.
> - 템플릿 기반 리치 타입 (`FL`/`FC`/`FM`/`FP`/`FA`)
> - 채널 친구가 **아닌** 수신자 (`targeting` = `N` / `I`)
> - 수신 동의한 전체 채널 친구 동보 (`targeting` = `F`)
>
> 메시지 타입은 1:1 대응되며 변환은 서버가 처리합니다 — `FT`→`BT`, `FI`→`BI`, `FW`→`BW`,
> `FL`→`BL`, `FC`→`BC`, `FM`→`BM`, `FP`→`BP`, `FA`→`BA`.

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

## 브랜드메시지 사용법

브랜드메시지는 친구톡의 후속 채널입니다. 메시지 타입이 친구톡과 1:1 대응되며
(`FT`→`BT`, `FI`→`BI`, `FW`→`BW`, `FL`→`BL`, `FC`→`BC`, `FM`→`BM`, `FP`→`BP`, `FA`→`BA`),
요청에는 **친구톡 코드를 그대로** 넘기고 변환은 서버가 처리합니다.

친구톡과 달리 다음이 가능합니다.

- 채널 친구가 **아닌** 수신자에게 발송 (`targeting: N`)
- 수신 동의한 **전체 채널 친구 동보** 발송 (`targeting: F`, 수신자 목록 불필요)
- 리스트·캐러셀·커머스·동영상 등 **템플릿 기반 리치 메시지**

> v2 전용입니다. 자유 본문 타입(`FT`/`FI`/`FW`)을 개별 수신자에게 보낼 때는 여전히 친구톡 API 를 쓰세요 — 이 엔드포인트는 그 조합에 `NOT_A_BRAND_MESSAGE` 를 반환합니다. 친구톡 요청은 카카오 측에서 브랜드메시지(자유형)로 대체 발송됩니다.

```dart
// 단건 발송 — 채널 친구 대상
await client.brandMessage.send(BrandMessageRequest(
  targeting: 'M',
  messageType: 'FL',
  friendTemplateUuid: '9cd5460b-6458-4edc-9b11-c26d3013c340',
  contacts: [Contact(contact: '01012345678', var1: '29,000원')],
));

// 동보 발송 — 수신 동의한 전체 채널 친구 (contacts 불필요)
await client.brandMessage.broadcast(BrandMessageRequest(
  messageType: 'FW',
  friendTemplateUuid: '9cd5460b-6458-4edc-9b11-c26d3013c340',
));

// 캠페인 조회
final list = await client.brandMessage.campaigns(count: 10);
final one  = await client.brandMessage.campaign('1f0a6d0e-6b3b-4f0f-9b2f-2f6f6a1b7c11');
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
| `baseUrl` | `String` | 선택 | `'https://sendgo.io'` | API 기본 URL |

---

## 관련 패키지

| 언어/프레임워크 | 패키지 | GitHub |
|----------------|--------|--------|
| Spring Boot | `io.sendgo:sendgo-spring` | [spring](https://github.com/send-go/spring) |
| Node.js | `@sendgo/node` | [node](https://github.com/send-go/node) |
| Python | `sendgo-python` | [python](https://github.com/send-go/python) |
| 전체 목록 | — | [send-go GitHub 조직](https://github.com/send-go) |

---

## 짧은 URL

짧은 URL 은 메시지 본문의 링크를 줄이고, 그 링크가 실제로 눌렸는지 집계합니다.
문자는 바이트 수가 요금과 직결되므로 링크를 줄이면 그만큼 본문을 더 쓸 수 있습니다.

같은 원본 URL 을 다시 줄이면 **기존 링크가 그대로 반환**됩니다. 캠페인별로 반응을
따로 집계하려면 `forceNew` 로 새 코드를 만드세요.

`deactivate` 는 링크를 삭제하지 않고 리다이렉트만 중지합니다. 이미 발송한 메시지의
링크를 무효화할 때 쓰며, 누적 통계는 남고 이후 접속은 `410 Gone` 이 됩니다.

```dart
// 짧은 URL 생성 (v2 전용)
final created = await sendgo.shortUrl.create(const ShortUrlRequest(
  targetUrl: 'https://example.com/promotions/summer-sale',
  title: '여름 세일 랜딩',
));

final code = created['data']['code'] as String;

// 반응 통계 — 일별 추이 + 디바이스/유입경로/국가별 분해
final stats = await sendgo.shortUrl.stats(code, from: '2026-08-01');

await sendgo.shortUrl.list(count: 10);
await sendgo.shortUrl.show(code);
await sendgo.shortUrl.deactivate(code);   // 리다이렉트만 중지, 통계는 남는다
```

`stats` 는 일별 추이(`daily`)와 디바이스(`byDevice`)·유입경로(`byReferer`)·국가(`byCountry`)별
분해를 반환합니다. 일별 추이는 사전 집계 표에서 읽으므로 클릭이 많아도 응답 시간이 일정합니다.

## 변경 사항

### 1.2.1 (2026-08-14)

- 레지스트리 목록에 노출되는 패키지 설명에서 친구톡을 브랜드메시지로 교체했습니다.
  npm/PyPI/Packagist/Maven/NuGet/RubyGems 검색 결과에 그대로 찍히는 문자열이라
  종료된 채널을 계속 홍보하고 있었습니다.
- 검색 키워드에 `brand-message` 를 추가했습니다 (`friendtalk` 은 유입 검색어라 유지).

### 1.2.0 (2026-08-14)

- **친구톡 Deprecated 표기** — 친구톡은 카카오 정책에 따라 2025-12-31 종료되었고,
  2026-01-01 부터 발송 요청이 브랜드메시지(자유형)로 자동 대체 발송됩니다.
  관련 API 에 각 언어의 표준 deprecation 표기를 달았습니다.
- 자유 본문 타입(`FT`/`FI`/`FW`)의 개별 발송 경로는 아직 친구톡 API 뿐이라는 점을
  문서에 명시했습니다 — 브랜드메시지 API 는 그 조합에 `NOT_A_BRAND_MESSAGE` 를 반환합니다.
- 브랜드메시지 전환 안내와 메시지 타입 1:1 대응표를 README 에 추가했습니다.

## 라이선스

MIT License © 2026 [Sendgo](https://sendgo.io)

---

*키워드: 카카오 알림톡 Flutter, 카카오 친구톡 Dart, SMS 발송 Flutter, 알림톡 Dart SDK, Dart 카카오 API, Sendgo Flutter SDK, pub.dev 알림 발송*
