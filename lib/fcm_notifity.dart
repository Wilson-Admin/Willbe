
import 'dart:convert';
import 'dart:developer';
import 'package:code3/sql.dart';
import 'package:googleapis_auth/auth_io.dart'; // ✅ 改用 googleapis_auth
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'api.dart';
import 'dart:developer' as dev;



String normalizeToken(String token) {
  try {
    // 嘗試 base64 decode
    final decoded = utf8.decode(base64.decode(token));
    return decoded;
  } catch (e) {
    // decode 失敗，回傳原始字串
    return token;
  }
}


int _messageCount = 0;
Future<void> sendPushNotification(
    {
      String token="",
      String title="",
      String message="",
      String ChatID="",
      String TeacherAccount="",
      String UserAccount="",
      String CS_NO="",
      String DATE="",
      String EXCUSED_NO="",
      String CFM_NO="",
      String DRUG_NO="",
      String ENTRUSTED_NO="",
      String DAILY_NOT_NO="",
      String DAILY_PRS_NO=""

    }) async {


  _messageCount++;
  final accessToken = await getOAuthToken();

  final url = Uri.parse('https://fcm.googleapis.com/v1/projects/huaweidigi2/messages:send');
  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $accessToken',
  };
  final body = jsonEncode({
    'message': {
      'token': '${normalizeToken("${token}")}',
      'data': {
        'ChatID': '${ChatID}',
        'TeacherAccount': "${TeacherAccount}",
        'UserAccount': "${UserAccount}",
        'CS_NO': "${CS_NO}",
        'DATE': "${DATE}",
        'EXCUSED_NO':"${EXCUSED_NO}",
        'CFM_NO':"${CFM_NO}",
        'DRUG_NO':"${DRUG_NO}",
        'ENTRUSTED_NO':"${ENTRUSTED_NO}",
        'DAILY_NOT_NO':"${DAILY_NOT_NO}",
        'DAILY_PRS_NO':"${DAILY_PRS_NO}",
        'title':"${title}"
      },
      'notification': {
        'title': '${title}',
        'body': '${message}',
      },
      'android': {
        'priority': 'high',  // ✅ 注意是小寫
      },
      "apns": {
        "headers": {
          "apns-priority": "10",//10：即時送達，會喚醒裝置。
        },
        "payload": {
          "aps": {
            "alert": {
              "title": '${title}',
              "body": '${message}',
            },
            "badge": 1,
            "sound": "default",
            "content-available": 1 //背景也能收到並處理 data 部分的資料，請在 apns.payload.aps 裡加上
          }
        }
      }
    },
  });
  log("推播headers:${headers}");
  log("推播body:${body}");
  final response = await http.post(url, headers: headers, body: body);
  if (response.statusCode == 200) {
    log('Push notification sent successfully');
  } else {
    log('Failed to send push notification: ${response.statusCode} - ${response.body}');
  }
}

// ✅ 使用 googleapis_auth 解析 Service Account 金鑰並取得 Bearer Token
Future<String?> getOAuthToken() async {
  try {
    final jsonStr = await rootBundle.loadString(
      'assets/file/huaweidigi2-firebase-adminsdk-g8i8z-cb0db58236.json',
    );
    final accountCredentials = ServiceAccountCredentials.fromJson(
      json.decode(jsonStr),
    );

    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(accountCredentials, scopes);
    final token = client.credentials.accessToken.data;
    client.close();

    if (token.isEmpty) {
      log('⚠️ FCM 憑證取得失敗：AccessToken 為空');
      return null;
    }

    return token;
  } catch (e, stackTrace) {
    log('⚠️ FCM 後端金鑰失效或取得憑證異常: $e');
    log('Stack trace: $stackTrace');
    return null;
  }
}
/*
Future<String?> getOAuthToken() async {
  try {
    final jsonStr = await rootBundle.loadString(
      'assets/file/huaweidigi2-firebase-adminsdk-g8i8z-cb0db58236.json',
    );
    final app = FirebaseAdmin.instance.certFromMap(json.decode(jsonStr));
    final tokenResult = await app.getAccessToken();

    // 避免將 null 轉為字串 "null"
    final token = tokenResult.accessToken;
    if (token == null || token.isEmpty) {
      log('⚠️ FCM 憑證取得失敗：AccessToken 為空');
      return null;
    }

    return token;
  } catch (e, stackTrace) {
    // 攔截 OpenIdException、Invalid JWT Signature 或其他憑證例外
    log('⚠️ FCM 後端金鑰失效或取得憑證異常: $e');
    log('Stack trace: $stackTrace');
    return null;
  }
}

 */
/*
Future<String> getOAuthToken() async {

  var app = FirebaseAdmin.instance.certFromMap(json.decode(await rootBundle.loadString('assets/file/huaweidigi2-firebase-adminsdk-g8i8z-4866db06b2.json')));
  final accessToken = await app.getAccessToken();
  //log("accessToken:${accessToken.accessToken}");
  //final credentials = GoogleCredentials.fromServiceAccount(serviceAccount);
  //final accessToken = await credentials.tokenInfo.accessToken;
  return accessToken.accessToken.toString();
}

 */


test()async{
  await sendPushNotification(
      title: "工程測試",
      message: "工程測試",
      token: "fImYv87jSTW4uKzZRTOWbL:APA91bH1XCRRSvrXbe8W9DHQrXLXveHoYP1XT9v02o4WiEOylrh7fNpS11LcwpS68pas0NhpQY9RyA24BDbRbf0aOwP9oXEnz07eAbZ_yHwOnSIQpBd-JQ0"
  );
}