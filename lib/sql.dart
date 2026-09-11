import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'api.dart';

const platform = const MethodChannel('samples.flutter.io/sql');

/*
資料庫IP：123.252.108.29
名稱：APP
登入帳號：sa
密碼：Ws53826282
 */

//ipv6 ip
String SQL_IP_IPV6 = "www.tw-wilson.com";//"2001:b030:d932:ff08:0:ffff:d316:f33d:1433";//"123.252.108.29";

//ipv4 ip
String SQL_IP_IPV4 = "www.tw-wilson.com";//"123.252.108.29";

String SQL_IP = "www.tw-wilson.com:1433";//"123.252.108.29";

String SQL_NAME = "APP";
String SQL_LOGIN_ACCOUNT = "sa";
String SQL_LOGIN_PASSWORD = "Ws53826282";

Future<String> sql_command(String command,{int timeout=15})async{
  String? result;
  try{


    result = await fetchData(sql_command:command,timeout: timeout);
    return result;


    /*
    Map<String,dynamic> map = {

      "url":"jdbc:jtds:sqlserver://${SQL_IP}/${SQL_NAME};user=" + "${SQL_LOGIN_ACCOUNT}" + ";password=" + "${SQL_LOGIN_PASSWORD};useLOBs=false;ssl=require",
      "SQL_IP":"${SQL_IP}",
      "SQL_NAME":"${SQL_NAME}",
      "SQL_LOGIN_ACCOUNT":"${SQL_LOGIN_ACCOUNT}",
      "SQL_LOGIN_PASSWORD":"${SQL_LOGIN_PASSWORD}",
      "command":"${command}"

    };
    dev.log(jsonEncode(map));
    result = await platform.invokeMethod(jsonEncode(map));
    dev.log("sql_result:${result}");
    return result!;

     */




  }
  catch(e){
    dev.log("e:${e}");
    return "e:${e}";
  }
}


/*
對所有欄位執行 trim()
 */
List<dynamic> trim_proc(List<dynamic> data_list){
  // 對所有欄位執行 trim()
  return data_list.map((row) {
    return row.map((key, value) {
      if (value is String) {
        return MapEntry(key, value.trim());
      }
      return MapEntry(key, value);
    });
  }).toList();
}





Future<String> fetchData({String sql_command = "",int timeout=15}) async {

  // 統一將 '...' 形式的字串轉為 N'...'
  //這邊會處理emoji符號
  /*
  String modifiedSql = sql_command.replaceAllMapped(
    RegExp(r"(?<!N)'([^']*)'"), // 找出沒有 N 前綴的字串常數
        (match) => "N'${match.group(1)}'",
  );

   */
  String modifiedSql = sql_command.replaceAllMapped(
    RegExp(r"(?<!N)'([^']*)'(?!')"),  // 避開 N'...'
        (match) {
      final original = match.group(0)!;
      // 檢查是否在宣告 NVARCHAR 或 N' 開頭的上下文中
      if (RegExp(r"(N(VAR)?CHAR|=)\s*N'").hasMatch(sql_command.substring(0, match.start))) {
        return original; // 保留原樣
      } else {
        return "N'${match.group(1)}'";
      }
    },
  );

  Map<String,dynamic> body = {
    'sql_command': modifiedSql,
  };
  Map<String,String> headers = {
    'Content-Type': 'application/json; charset=utf-8',
    //'Authorization': 'Bearer ${user.ACCOUNT}'
    'Authorization': 'WILSONq7tXJpA4Mvksf2y1bZ9hQnE6R3oFLUu8mCgxYr0VdzKNTijw5aOBGPHclSDe'
  };
  //dev.log("headers:${headers}");
  //dev.log("body:${jsonEncode(body)}");
  final response = await http.post(Uri.parse('https://tw-wilson.com/api/v2/data'),headers: headers,body: jsonEncode(body)).timeout(Duration(seconds: timeout));
  if (response.statusCode == 200) {
    //dev.log("response.body:${response.body}");
    //final List<dynamic> data = json.decode(response.body);
    //dev.log("資料：$data");
    return response.body;
  } else {
    dev.log("API 連線失敗：${response.statusCode}\n${response.body}");
    return "";
  }
}


Future<String> sql_command2(String command)async{
  String? result;
  try{

    result = await fetchData2(sql_command:command);
    return result;
    /*
    Map<String,dynamic> map = {

      "url":"jdbc:jtds:sqlserver://${SQL_IP}/${SQL_NAME};user=" + "${SQL_LOGIN_ACCOUNT}" + ";password=" + "${SQL_LOGIN_PASSWORD};useLOBs=false;ssl=require",
      "SQL_IP":"${SQL_IP}",
      "SQL_NAME":"${SQL_NAME}",
      "SQL_LOGIN_ACCOUNT":"${SQL_LOGIN_ACCOUNT}",
      "SQL_LOGIN_PASSWORD":"${SQL_LOGIN_PASSWORD}",
      "command":"${command}"

    };
    dev.log(jsonEncode(map));
    result = await platform.invokeMethod(jsonEncode(map));
    dev.log("sql_result:${result}");
    return result!;

     */

  }
  catch(e){
    dev.log("e:${e}");
    return "e:${e}";
  }
}
Future<String> fetchData2({String sql_command = ""}) async {

  //先處理emoji符號
  String modifiedSql = sql_command.replaceAllMapped(
    RegExp(r"(?<!N)'([^']*)'(?!')"),  // 避開 N'...'
        (match) {
      final original = match.group(0)!;
      // 檢查是否在宣告 NVARCHAR 或 N' 開頭的上下文中
      if (RegExp(r"(N(VAR)?CHAR|=)\s*N'").hasMatch(sql_command.substring(0, match.start))) {
        return original; // 保留原樣
      } else {
        return "N'${match.group(1)}'";
      }
    },
  );

  Map<String,dynamic> body = {
    'sql_command': modifiedSql,
  };
  Map<String,String> headers = {
    'Content-Type': 'application/json; charset=utf-8',
    //'Authorization': 'Bearer ${user.ACCOUNT}'
    'Authorization': 'WILSONq7tXJpA4Mvksf2y1bZ9hQnE6R3oFLUu8mCgxYr0VdzKNTijw5aOBGPHclSDe'
  };
  //dev.log("headers:${headers}");
  //dev.log("sql_command:${sql_command}");
  final response = await http.post(Uri.parse('https://tw-wilson.com/api/v2/data/FirstNO'),headers: headers,body: jsonEncode(body)).timeout(Duration(seconds: 10));
  if (response.statusCode == 200) {
    //dev.log("response.body:${response.body}");
    //final List<dynamic> data = json.decode(response.body);
    //dev.log("資料：$data");
    return response.body;
  } else {
    dev.log("API 連線失敗：${response.statusCode}\n${response.body}");
    return "";
  }
}

Future<String> search_EMPLOYEE_fcm_sub({String ACCOUNT=""})async{
  String FCM = "";
  String comm = "SELECT * FROM EMPLOYEE WHERE ACCOUNT='${ACCOUNT}'";
  //dev.log("comm:${comm}");
  String result = await sql_command("${comm}");
  try {
    List<dynamic> list = jsonDecode(result);
    List<dynamic> data_list = [];
    data_list = list;
    if(data_list.isNotEmpty){
      FCM = data_list[0]["FCM"];
    }
  }
  catch(e){
    dev.log("err:${e}");
  }
  return FCM;
}


Future<String> search_CUSTOMER_DL_fcm_sub({String ACCOUNT=""})async{
  String FCM = "";
  String comm = "SELECT * FROM CUSTOMER_DL WHERE ACCOUNT='${ACCOUNT}'";
  String result = await sql_command("${comm}");
  try {
    List<dynamic> list = jsonDecode(result);
    List<dynamic> data_list = [];
    data_list = list;
    if(data_list.isNotEmpty){
      FCM = data_list[0]["FCM"];
    }
  }
  catch(e){

  }
  return FCM;
}

