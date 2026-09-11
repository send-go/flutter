## 1.3.0

- **관리 API 추가** — 콘솔에서만 되던 등록·심사를 코드로 처리합니다.
  `client.kakaoSenders`(카카오 채널 인증·등록·동기화, 브랜드메시지 M/N 신청),
  `client.noticeTemplates`(알림톡 템플릿 CRUD·검수 요청·승인 취소·휴면 해제),
  `client.brandTemplates`(브랜드메시지 템플릿 CRUD·동기화·가져오기),
  `client.senderRegistration`(발신번호 등록 신청·중복 확인·유형 안내),
  `client.messageTemplates`(문자 상용구 템플릿 CRUD).
- `SendgoHttpClient` 에 `put`·`patch`·`postMultipart` 를 추가했습니다.
  서류 첨부와 이미지 템플릿은 JSON 으로 보낼 수 없습니다.
- 요청 모델과 첨부용 `SendgoMultipartFile` 을 추가했습니다.
- **휴대폰 발신번호도 API 로 접수됩니다.** 콘솔의 PASS 본인인증 대신
  `identityDocument`(신분증 사본)를 첨부하면 sendgo 운영자가 확인합니다.
  이 경로는 자동 승인되지 않고 항상 `PENDING` 으로 시작합니다.
- **이벤트 웹훅** 추가 — 발신번호 승인, 알림톡 검수 결과, 채널 차단,
  브랜드메시지 타겟팅 결과를 구독해 받습니다. `WebhookService.verifySignature`
  로 서명을 검증합니다(받은 원본 바이트로).
- **카카오 이미지 업로드** 추가 — 브랜드메시지 템플릿의 `imageUrl` 은 카카오가
  호스팅하는 URL 이어야 하는데, 그 URL 을 얻는 길이 콘솔에만 있었습니다.
- **수신거부(080) 조회** 추가 — 자기 DB 의 수신 상태를 맞출 수 있습니다.
- `crypto` 의존성이 추가됐습니다 (웹훅 서명 검증용).
- **리셀러는 sendgo.io 콘솔에 들어올 일이 없습니다.** 사람이 개입하는 지점은
  카카오 채널 인증번호 하나뿐이고, 그것도 리셀러 화면에서 입력받으면 됩니다.

## 1.2.1

- pub.dev 패키지 설명에서 친구톡을 브랜드메시지로 교체했다. 검색 결과에 그대로
  노출되는 문자열이라 종료된 채널을 계속 홍보하고 있었다.

## 1.2.0

- **친구톡 Deprecated 표기.** 친구톡은 카카오 정책에 따라 2025-12-31 종료되었고,
  2026-01-01 부터 친구톡 발송 요청은 카카오 측에서 브랜드메시지(자유형)로 자동
  대체 발송된다. `FriendtalkService` 와 `SendgoClient.friendtalk` 에
  `@Deprecated` 를 달았다.
- 자유 본문 타입(FT/FI/FW)을 개별 수신자에게 보내는 경로는 아직 친구톡 API
  뿐이라는 점을 문서에 명시했다 — 브랜드메시지 API 는 그 조합에
  `NOT_A_BRAND_MESSAGE` 를 반환한다.
- README 태그라인에서 친구톡을 브랜드메시지로 교체하고 전환 안내를 추가했다.

## 1.1.0

- **순수 Dart 패키지로 전환.** `flutter: sdk: flutter` 의존성과 `flutter` 환경
  제약을 제거했다. `lib/` 는 `dart:convert` 와 `package:http` 만 쓰고 Flutter
  API를 전혀 사용하지 않는데, 이 의존성 때문에 Flutter SDK가 없는 환경에서는
  설치 자체가 되지 않았다. 이 SDK는 API 키를 다루므로 서버에서만 써야 하지만
  (README의 경고 참고) 정작 그 서버 환경 — Dart Frog, Shelf, Serverpod,
  Cloud Functions — 에서 쓸 수 없고, 절대 쓰면 안 되는 Flutter 앱에서만 쓸 수
  있는 상태였다. 이제 양쪽 모두에서 설치된다.
- `dev_dependencies` 를 `flutter_test`/`flutter_lints` 에서 `test`/`lints` 로 교체
- 문서에 실린 예제 전체를 타입 체크하는 `example/doc_examples.dart` 추가
- 브랜드메시지(친구톡의 후속 채널) 사용법을 문서화

## 1.0.2

- `repository` 링크를 실제 저장소(`send-go/flutter`)로 수정
- `CHANGELOG.md`, `LICENSE` 를 저장소에 포함

## 1.0.1

- base URL을 `https://sendgo.io` 로 변경

## 1.0.0

- 최초 릴리스
- 카카오 알림톡/친구톡, SMS/LMS/MMS 발송 지원
- 액세스 토큰 자동 발급 및 갱신
