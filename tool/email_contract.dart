import 'dart:io';
import 'dart:convert';
import 'package:sendgo_flutter/sendgo_flutter.dart';

void check(dynamic v, String n, String verb) {
  if (n == 'rawMessage') {
    if (base64Encode(v) != 'RU1MDQoA/w==') throw StateError('raw');
    return;
  }
  if (verb == 'DELETE') {
    if (v != null) throw StateError('204');
    return;
  }
  if (n == 'domains') v = v[0];
  if (v['marker'] != '한글') throw StateError('marker');
}

Future<void> main() async {
  final url = Platform.environment['SENDGO_TEST_URL']!;
  final email = SendgoClient(
          accessKey: 'ak', secretKey: 'sk', apiVersion: 'v2', baseUrl: url)
      .email;
  final basic =
      EmailService.withCredentials('credential', 'password', baseUrl: url);
  final body = <String, dynamic>{
    'subject': '한글',
    'enabled': false,
    'optional': null,
    'idempotency_key': 'fixed-key',
    'attachments': [
      {'name': 'a.txt', 'type': 'text/plain', 'content': 'aGk='}
    ]
  };
  final query = {'search': '한글 +&', 'page': '2'};
  check(await email.account(query), 'account', 'GET');
  check(await email.requestAccess(body), 'requestAccess', 'POST');
  check(await email.createCredential(body), 'createCredential', 'POST');
  check(await email.credentials(query), 'credentials', 'GET');
  check(await email.revokeCredential("id 한글+"), 'revokeCredential', 'DELETE');
  check(await email.domains(query), 'domains', 'GET');
  check(await email.registerDomain(body), 'registerDomain', 'POST');
  check(await email.verifyDomain("id 한글+", body), 'verifyDomain', 'POST');
  check(await email.senders(query), 'senders', 'GET');
  check(await email.requestSender(body), 'requestSender', 'POST');
  check(await email.verifySender("id 한글+", body), 'verifySender', 'POST');
  check(await email.requestRecipientVerification(body),
      'requestRecipientVerification', 'POST');
  check(await email.checkRecipients(body), 'checkRecipients', 'POST');
  check(await email.addressBook(query), 'addressBook', 'GET');
  check(await email.senderProfiles(query), 'senderProfiles', 'GET');
  check(await email.createSenderProfile(body), 'createSenderProfile', 'POST');
  check(await email.updateSenderProfile("id 한글+", body), 'updateSenderProfile',
      'PATCH');
  check(await email.deleteSenderProfile("id 한글+"), 'deleteSenderProfile',
      'DELETE');
  check(await email.importAddressBook(body), 'importAddressBook', 'POST');
  check(await email.updateAddressBookPreferences(body),
      'updateAddressBookPreferences', 'POST');
  check(await email.send(body), 'send', 'POST');
  check(await email.quote(body), 'quote', 'POST');
  check(await email.messages(query), 'messages', 'GET');
  check(await email.message("id 한글+", query), 'message', 'GET');
  check(await email.cancelMessage("id 한글+", body), 'cancelMessage', 'POST');
  check(await email.inboxes(query), 'inboxes', 'GET');
  check(await email.createInbox(body), 'createInbox', 'POST');
  check(await email.updateInbox("id 한글+", body), 'updateInbox', 'PATCH');
  check(await email.inboxMessages("id 한글+", query), 'inboxMessages', 'GET');
  check(await email.inboxMessage("id 한글+", "id 한글+", query), 'inboxMessage',
      'GET');
  check(await email.rawMessage("id 한글+", "id 한글+", query), 'rawMessage', 'GET');
  check(await email.deleteInboxMessage("id 한글+", "id 한글+"),
      'deleteInboxMessage', 'DELETE');
  check(await email.templates(query), 'templates', 'GET');
  check(await email.template("id 한글+", query), 'template', 'GET');
  check(await email.createTemplate(body), 'createTemplate', 'POST');
  check(await email.updateTemplate("id 한글+", body), 'updateTemplate', 'PATCH');
  check(await email.deleteTemplate("id 한글+"), 'deleteTemplate', 'DELETE');
  check(await email.contacts(query), 'contacts', 'GET');
  check(await email.saveContact(body), 'saveContact', 'POST');
  check(await email.importContacts(body), 'importContacts', 'POST');
  check(await email.unsubscribeContact("id 한글+", body), 'unsubscribeContact',
      'POST');
  check(await email.campaigns(query), 'campaigns', 'GET');
  check(await email.createCampaign(body), 'createCampaign', 'POST');
  check(await email.campaign("id 한글+", query), 'campaign', 'GET');
  check(await email.quoteCampaign("id 한글+", body), 'quoteCampaign', 'POST');
  check(await email.sendCampaign("id 한글+", body), 'sendCampaign', 'POST');
  check(await email.cancelCampaign("id 한글+", body), 'cancelCampaign', 'POST');
  check(await basic.domains(query), 'domains', 'GET');
  check(await basic.registerDomain(body), 'registerDomain', 'POST');
  check(await basic.verifyDomain("id 한글+", body), 'verifyDomain', 'POST');
  check(await basic.send(body), 'send', 'POST');
  check(await basic.quote(body), 'quote', 'POST');
  check(await basic.messages(query), 'messages', 'GET');
  check(await basic.message("id 한글+", query), 'message', 'GET');
  check(await basic.cancelMessage("id 한글+", body), 'cancelMessage', 'POST');
  check(await basic.auth(query), 'auth', 'GET');
  check(await email.messages({'mode': 'refresh'}), 'messages', 'GET');
  try {
    await email.messages({'mode': '403'});
    throw StateError('missing error');
  } on SendgoException catch (e) {
    if (e.statusCode != 403) rethrow;
  }
  try {
    await email.messages({'mode': '422'});
    throw StateError('missing error');
  } on SendgoException catch (e) {
    if (e.statusCode != 422) rethrow;
  }
  try {
    await email.messages({'mode': '429'});
    throw StateError('missing error');
  } on SendgoException catch (e) {
    if (e.statusCode != 429) rethrow;
  }
  try {
    await email.messages({'mode': '500'});
    throw StateError('missing error');
  } on SendgoException catch (e) {
    if (e.statusCode != 500) rethrow;
  }
  try {
    await basic.messages({'mode': '401'});
    throw StateError('missing error');
  } on SendgoException catch (e) {
    if (e.statusCode != 401) rethrow;
  }
  await SendgoClient(
          accessKey: 'ak', secretKey: 'sk', apiVersion: 'v2', baseUrl: url)
      .brandMessage
      .send(BrandMessageRequest(
          friendTemplateUuid: 'template',
          targeting: 'O',
          contacts: [Contact(contact: '01000000000')]));
  print('PASS email');
}
