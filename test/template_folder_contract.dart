import 'dart:io';
import 'package:sendgo_flutter/sendgo_flutter.dart';

Future<void> main() async {
  final c = SendgoClient(accessKey: 'test-access', secretKey: 'test-secret', apiVersion: 'v2', baseUrl: Platform.environment['SENDGO_TEST_URL']!);
  const f = '11111111-1111-4111-8111-111111111111', key = '채널 /?';
  await c.templateFolders.list();
  await c.templateFolders.list(templateType: 'brand', kakaoSenderKey: key);
  await c.templateFolders.create(name: '주문');
  await c.templateFolders.create(name: '하위', parentUuid: f);
  for (final kind in ['notice', 'brand']) {
    await c.templateFolders.assign(templateType: kind, kakaoSenderKey: key, templateCodes: ['코드 1', 'code/2'], folderUuid: f);
    await c.templateFolders.assign(templateType: kind, kakaoSenderKey: key, templateCodes: ['코드 1'], folderUuid: null);
  }
  await c.noticeTemplates.list(folderUuid: 'none');
  await c.brandTemplates.list(folderUuid: f);
  await c.noticeTemplates.create(const NoticeTemplateRequest(templateName: '테스트', folderUuid: f, templateContent: '본문', categoryCode: '001001', messagePurpose: 'order_delivery', legalBasis: 'transaction', benefitOrigin: 'none', expiryType: 'none'));
  await c.brandTemplates.create(const BrandTemplateRequest(templateName: '테스트', folderUuid: f));
  for (final tc in [('forbidden',403,'ACCESS_KEY_NOT_APPROVED'),('invalid',422,'VALIDATION_FAILED'),('missing',404,'TEMPLATE_FOLDER_NOT_FOUND')]) {
    try { await c.templateFolders.list(templateType: tc.$1); throw StateError('오류가 발생하지 않음'); }
    on SendgoException catch (e) { if (e.statusCode != tc.$2 || e.errorCode != tc.$3) rethrow; }
  }
}
