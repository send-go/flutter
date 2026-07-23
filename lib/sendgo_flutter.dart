/// Sendgo Flutter SDK — 카카오 알림톡/친구톡, SMS/LMS/MMS
///
/// 주의: API 키는 절대 Flutter 앱에 직접 포함하지 마세요.
/// 서버(Cloud Functions, Backend API)에서 호출하거나,
/// Flutter 서버사이드(Dart 서버)에서 사용하세요.
///
/// @example (Dart 서버 / Cloud Functions)
/// ```dart
/// import 'package:sendgo_flutter/sendgo_flutter.dart';
///
/// final client = SendgoClient(
///   accessKey: Platform.environment['SENDGO_ACCESS_KEY']!,
///   secretKey: Platform.environment['SENDGO_SECRET_KEY']!,
///   kakaoSenderKey: Platform.environment['SENDGO_KAKAO_KEY'],
///   smsSenderKey: Platform.environment['SENDGO_SMS_KEY'],
///   apiVersion: 'v2',
/// );
///
/// await client.alimtalk.send(AlimtalkRequest(
///   templateCode: 'ORDER_CONFIRM_001',
///   contacts: [Contact(contact: '01012345678', var1: 'ORD-001')],
/// ));
/// ```
library sendgo_flutter;

export 'src/models.dart';
export 'src/exceptions.dart';
export 'src/sendgo_client.dart';
