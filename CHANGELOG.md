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
