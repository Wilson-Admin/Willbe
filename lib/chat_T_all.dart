import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:code3/main.dart';
import 'package:code3/main2_U.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as dev;
import 'DRUG_MT_T_page.dart';
import 'api.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as chat_ui;
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'fcm_notifity.dart';
import 'main2_T.dart';
import 'sql.dart';
import 'package:badges/badges.dart' as badges;

import 'student_T.dart';


int ChatPage_T_all_unread_count=0;
Function? ChatPage_T_all_fun1;
Function? ChatPage_T_all_fun2;
Function? ChatPage_T_all_fun3;
Timer? ChatPage_T_all_timer;
bool ChatPage_T_all_init_finish = false;
class ChatPage_T_all extends StatefulWidget {
  @override
  State<ChatPage_T_all> createState() => _ChatPage_T_allState();
}

class _ChatPage_T_allState extends State<ChatPage_T_all> {



  var _user=null;

  TextEditingController message_TextEditingController = TextEditingController();
  List<EMPLOYEE> _eMPLOYEEs = [];
  List<CLASS> _cLASSs = [];
  int index=0;

  int page = 0;
  int sel_chat_index=0;

  Entrusted_pick_and_drop entrusted_pick_and_drop = Entrusted_pick_and_drop();
  var showDialog_setState;

  EXCUSED eXCUSED = EXCUSED();

  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isRunning = false;

  List<CUSTOMER> cUSTOMERs_for_chats = [];

  @override
  void initState() {
    // TODO: implement initState
    //dev.log("ChatPage_T_all-initState()");
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();


    cUSTOMERs_for_chats =
        EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs;

    ChatPage_T_all_fun1 = () async {

      ChatPage_T_all_init_finish = false;

      _user = types.User(
        id: '${EMPLOYEE_teacher.ACCOUNT}',
        //Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
        lastName: '',
        firstName: '${EMPLOYEE_teacher.EMP_NM}',
      );
      setState(() {

      });


      await init();

      /*
      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
        if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].cUSTOMER_DLs.isNotEmpty) {
          await read_message_sub2(index:i);
        }
      }

       */

      //先讀取未讀數
      /*
      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
        String comm = "SELECT UnreadCount FROM View_Chatid_UnreaderCount WHERE ChatID='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].ChatID}' AND USER_NO='${EMPLOYEE_teacher.ACCOUNT}'";
        String result = await sql_command("${comm}");
        try{
          List<dynamic> maps = jsonDecode(result);
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].unread_count = int.parse("${maps[0]["UnreadCount"]}");
        }
        catch(e){
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].unread_count=0;
        }
      }

       */

      // 1. 收集所有 ChatID
      List<String> chatIds = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
          .cUSTOMERs
          .map((c) => "'${c.ChatID}'") // 注意加上引號
          .toList();

      // 2. 組合成 IN 的 SQL 字串
      String chatIdList = chatIds.join(",");

      // 3. 建立 SQL 查詢一次撈取
      String comm = """
SELECT ChatID, UnreadCount 
FROM View_Chatid_UnreaderCount 
WHERE ChatID IN (${chatIdList}) 
AND USER_NO='${EMPLOYEE_teacher.ACCOUNT}'
""";

      String result = await sql_command(comm);

      // 4. 將查詢結果轉成 Map<ChatID, UnreadCount>
      // 將查詢結果轉成 Map<int, int>
      Map<int, int> unreadMap = {};
      try {
        List<dynamic> maps = jsonDecode(result);
        for (var row in maps) {
          int? chatId = int.tryParse("${row["ChatID"]}");
          if (chatId != null) {
            unreadMap[chatId] = int.tryParse("${row["UnreadCount"]}") ?? 0;
          }
        }
      } catch (e) {
        unreadMap = {};
      }

      //dev.log("unreadMap:${unreadMap}");
      // 5. 將對應值回填進每個 CUSTOMER 物件
      for (int i = 0; i <
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs
              .length; i++) {
        var customer = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
            .cUSTOMERs[i];
        int? chatId = int.tryParse("${customer.ChatID}");
        //dev.log("unreadMap[$chatId]: ${unreadMap[chatId]}");
        EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i]
            .unread_count =
            unreadMap[chatId] ?? 0;
      }

      int _unread_count = 0;
      for (int i = 0; i <
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs
              .length; i++) {
        _unread_count +=
            EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i]
                .unread_count;
      }
      ChatPage_T_all_unread_count = _unread_count;
      MyHomePage2_T_fun3!();

      comm = """
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ChatID ORDER BY CreatedAt DESC) AS rn
    FROM MSDL2
    WHERE ChatID IN (${chatIdList})
) t
WHERE rn = 1
""";
      result = await sql_command(comm);
      List<dynamic> maps = jsonDecode(result);
      maps = trim_proc(maps);
      for (int i = 0; i < maps.length; i++) {
        for (int j = 0; j <
            EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs
                .length; j++) {
          //dev.log(">>>,${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].ChatID},${maps[i]["ChatID"]}");
          if (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
              .ChatID == maps[i]["ChatID"]) {
            //dev.log("Type:${maps[i]["Type"]}");
            EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
                .last_MessageID = "${maps[i]["MessageID"]}";
            if ("${maps[i]["Type"]}" == "text") {
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
                  .last_message =
              "${maps[i]["AuthorFirstName"]} ${maps[i]["Text"]}";
            }
            else {
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
                  .last_message = "${maps[i]["AuthorFirstName"]} 傳送一張圖片";
            }
          }
        }
      }
      cUSTOMERs_for_chats = List.from(
        EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs,
      );
      cUSTOMERs_for_chats.sort((a, b) {
        final timeA = DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(a.last_MessageID ?? '') ?? 0,
        );
        final timeB = DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(b.last_MessageID ?? '') ?? 0,
        );
        return timeB.compareTo(timeA);
      });
      MyHomePage2_T_fun3!();

      //dev.log("開始處理聊天室");

      ChatPage_T_all_timer =
          Timer.periodic(const Duration(seconds: 6), (timer) async {
            if (is_Student_T_page == true) {
              return;
            }

            if (_isRunning) return; // 正在跑，直接跳過
            _isRunning = true;
            try {
              await init();
              //dev.log("page:${page}");
              if (page == 1) {
                if (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
                    .cUSTOMERs[sel_chat_index].ChatID.isNotEmpty) {
                  await read_message_sub(index: sel_chat_index);
                  await check_all_message_is_seen_sub(index: sel_chat_index);
                  await _syncDeletedMessages(
                      EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
                          .cUSTOMERs[sel_chat_index].ChatID);
                }
              }
              else {
                //讀取最後一筆訊息

                // 1. 收集所有 ChatID
                List<String> chatIds = EMPLOYEE_teacher
                    .Teacher_CUSTOMER_selectedValue.cUSTOMERs
                    .map((c) => "'${c.ChatID}'") // 注意加上引號
                    .toList();

                // 2. 組合成 IN 的 SQL 字串
                String chatIdList = chatIds.join(",");

                // 3. 建立 SQL 查詢一次撈取
                String comm = """
SELECT ChatID, UnreadCount 
FROM View_Chatid_UnreaderCount 
WHERE ChatID IN (${chatIdList}) 
AND USER_NO='${EMPLOYEE_teacher.ACCOUNT}'
""";

                String result = await sql_command(comm);

                // 4. 將查詢結果轉成 Map<ChatID, UnreadCount>
                // 將查詢結果轉成 Map<int, int>
                Map<int, int> unreadMap = {};
                try {
                  List<dynamic> maps = jsonDecode(result);
                  for (var row in maps) {
                    int? chatId = int.tryParse("${row["ChatID"]}");
                    if (chatId != null) {
                      unreadMap[chatId] =
                          int.tryParse("${row["UnreadCount"]}") ?? 0;
                    }
                  }
                } catch (e) {
                  unreadMap = {};
                }

                //dev.log("unreadMap:${unreadMap}");
                // 5. 將對應值回填進每個 CUSTOMER 物件
                for (int i = 0; i <
                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs
                        .length; i++) {
                  var customer = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
                      .cUSTOMERs[i];
                  int? chatId = int.tryParse("${customer.ChatID}");
                  //dev.log("unreadMap[$chatId]: ${unreadMap[chatId]}");
                  EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i]
                      .unread_count =
                      unreadMap[chatId] ?? 0;
                }

                int _unread_count = 0;
                for (int i = 0; i <
                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs
                        .length; i++) {
                  _unread_count +=
                      EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
                          .cUSTOMERs[i].unread_count;
                }
                ChatPage_T_all_unread_count = _unread_count;
                MyHomePage2_T_fun3!();

                comm = """
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ChatID ORDER BY CreatedAt DESC) AS rn
    FROM MSDL2
    WHERE ChatID IN (${chatIdList})
) t
WHERE rn = 1
""";
                result = await sql_command(comm);
                List<dynamic> maps = jsonDecode(result);
                maps = trim_proc(maps);
                for (int i = 0; i < maps.length; i++) {
                  for (int j = 0; j <
                      EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs
                          .length; j++) {
                    //dev.log(">>>,${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].ChatID},${maps[i]["ChatID"]}");
                    if (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
                        .cUSTOMERs[j].ChatID == maps[i]["ChatID"]) {
                      //dev.log("Type:${maps[i]["Type"]}");
                      EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
                          .cUSTOMERs[j].last_MessageID =
                      "${maps[i]["MessageID"]}";
                      if ("${maps[i]["Type"]}" == "text") {
                        EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
                            .cUSTOMERs[j].last_message =
                        "${maps[i]["AuthorFirstName"]} ${maps[i]["Text"]}";
                      }
                      else {
                        EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
                            .cUSTOMERs[j].last_message =
                        "${maps[i]["AuthorFirstName"]} 傳送一張圖片";
                      }
                    }
                  }
                }
                cUSTOMERs_for_chats = List.from(
                  EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs,
                );
                cUSTOMERs_for_chats.sort((a, b) {
                  final timeA = DateTime.fromMillisecondsSinceEpoch(
                    int.tryParse(a.last_MessageID ?? '') ?? 0,
                  );
                  final timeB = DateTime.fromMillisecondsSinceEpoch(
                    int.tryParse(b.last_MessageID ?? '') ?? 0,
                  );
                  return timeB.compareTo(timeA);
                });
                MyHomePage2_T_fun3!();
              }
            } finally {
              _isRunning = false;
            }

            /*
        if(page==1){
          if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID.isNotEmpty){
            read_message_sub(index:sel_chat_index);
            check_all_message_is_seen_sub(index:sel_chat_index);
          }
        }
        else{
          for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
            if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].cUSTOMER_DLs.isNotEmpty) {
              if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].ChatID.isNotEmpty){
                await read_message_sub2(index:i);
              }
            }
          }
        }

        int _unread_count=0;
        for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
          _unread_count+=EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].unread_count;
        }
        ChatPage_T_all_unread_count = _unread_count;
        MyHomePage2_T_fun3!();

         */


          });

      ChatPage_T_all_init_finish = true;
    };

    ChatPage_T_all_fun2 = () async {
      ChatPage_T_all_init_finish = false;
      page = 0;
      setState(() {

      });
      await init();

      // 1. 收集所有 ChatID
      List<String> chatIds = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
          .cUSTOMERs
          .map((c) => "'${c.ChatID}'") // 注意加上引號
          .toList();

      // 2. 組合成 IN 的 SQL 字串
      String chatIdList = chatIds.join(",");

      // 3. 建立 SQL 查詢一次撈取
      String comm = """
SELECT ChatID, UnreadCount 
FROM View_Chatid_UnreaderCount 
WHERE ChatID IN (${chatIdList}) 
AND USER_NO='${EMPLOYEE_teacher.ACCOUNT}'
""";

      String result = await sql_command(comm);

      // 4. 將查詢結果轉成 Map<ChatID, UnreadCount>
      // 將查詢結果轉成 Map<int, int>
      Map<int, int> unreadMap = {};
      try {
        List<dynamic> maps = jsonDecode(result);
        for (var row in maps) {
          int? chatId = int.tryParse("${row["ChatID"]}");
          if (chatId != null) {
            unreadMap[chatId] = int.tryParse("${row["UnreadCount"]}") ?? 0;
          }
        }
      } catch (e) {
        unreadMap = {};
      }

      //dev.log("unreadMap:${unreadMap}");
      // 5. 將對應值回填進每個 CUSTOMER 物件
      for (int i = 0; i <
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs
              .length; i++) {
        var customer = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
            .cUSTOMERs[i];
        int? chatId = int.tryParse("${customer.ChatID}");
        //dev.log("unreadMap[$chatId]: ${unreadMap[chatId]}");
        EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i]
            .unread_count =
            unreadMap[chatId] ?? 0;
      }

      int _unread_count = 0;
      for (int i = 0; i <
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs
              .length; i++) {
        _unread_count +=
            EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i]
                .unread_count;
      }
      ChatPage_T_all_unread_count = _unread_count;
      MyHomePage2_T_fun3!();

      comm = """
SELECT *
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ChatID ORDER BY CreatedAt DESC) AS rn
    FROM MSDL2
    WHERE ChatID IN (${chatIdList})
) t
WHERE rn = 1
""";
      result = await sql_command(comm);
      List<dynamic> maps = jsonDecode(result);
      maps = trim_proc(maps);
      for (int i = 0; i < maps.length; i++) {
        for (int j = 0; j <
            EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs
                .length; j++) {
          //dev.log(">>>,${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].ChatID},${maps[i]["ChatID"]}");
          if (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
              .ChatID == maps[i]["ChatID"]) {
            //dev.log("Type:${maps[i]["Type"]}");
            EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
                .last_MessageID = "${maps[i]["MessageID"]}";
            if ("${maps[i]["Type"]}" == "text") {
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
                  .last_message =
              "${maps[i]["AuthorFirstName"]} ${maps[i]["Text"]}";
            }
            else {
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
                  .last_message = "${maps[i]["AuthorFirstName"]} 傳送一張圖片";
            }
          }
        }
      }
      cUSTOMERs_for_chats = List.from(
        EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs,
      );
      cUSTOMERs_for_chats.sort((a, b) {
        final timeA = DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(a.last_MessageID ?? '') ?? 0,
        );
        final timeB = DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(b.last_MessageID ?? '') ?? 0,
        );
        return timeB.compareTo(timeA);
      });

      /*
      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
        if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].cUSTOMER_DLs.isNotEmpty) {
          await read_message_sub2(index:i);
        }
      }

       */

      ChatPage_T_all_init_finish = true;

    };

    Future waitUntilInit() async {
      final completer = Completer();

      Timer.periodic(Duration(seconds: 1), (timer) {
        if (ChatPage_T_all_init_finish == true) {
          timer.cancel();
          completer.complete();
        }
      });

      return completer.future;
    }

    ChatPage_T_all_fun3 = ({String ChatID = ''}) async {

      await waitUntilInit();  // 會真正等待
      dev.log("初始化完成，繼續往下執行");

      final customers = cUSTOMERs_for_chats;

      // 找出 index（找不到會是 -1）
      final index = customers.indexWhere(
            (c) => c.ChatID.toString() == ChatID.toString(),
      );

      if (index != -1) {
        // 找到了 → 帶 index 跳轉
        await goto_chat_sub(index: index);

        if(pendingMessage!=null){
          pendingMessage=null;
          MyHomePage2_T_fun3!();
        }



      } else {
        dev.log("未找到相同 ChatID: $ChatID");
      }
    };

  }


  @override
  void dispose() {
    in_chat = false;
    if(ChatPage_T_all_timer!=null) {
      ChatPage_T_all_timer!.cancel();
      ChatPage_T_all_timer=null;
    }
    super.dispose();
  }

  // 刪除訊息邏輯
  void _deleteMessage(String messageId) async {
    // 1. 先刪掉本地訊息
    /*
    setState(() {
      EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages.removeWhere((msg) => msg.id == messageId);
    });

     */


    // 2. 後端刪除 SQL
    String comm = '''
BEGIN TRAN;  -- 開始交易

DELETE FROM MSDL2 WHERE MessageID = N'$messageId';
DELETE FROM MSRS WHERE MessageID = N'$messageId';

COMMIT TRAN; -- 提交交易（兩個刪除都成功才真正寫入）
''';

    try {
      String result = await sql_command(comm);
      //dev.log("刪除訊息(回應): $result");

      final messages = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
          .cUSTOMERs[sel_chat_index].messages;

      // 找到要刪除的 index
      final index = messages.indexWhere((msg) => msg.id == messageId);
      if (index == -1) return;

      // 先本地刪除，確保 id 唯一且順序正常
      setState(() {
        EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
            .cUSTOMERs[sel_chat_index].messages = List.from(messages)..removeAt(index);
      });

      // ✅ 成功提示
      Fluttertoast.showToast(
        msg: "✅ 訊息已刪除",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green.shade600,
        textColor: Colors.white,
        fontSize: 16.0.sp,
      );
    } catch (e) {
      //dev.log("刪除訊息失敗: $e");

      // ❌ 失敗提示
      Fluttertoast.showToast(
        msg: "❌ 刪除失敗：$e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red.shade600,
        textColor: Colors.white,
        fontSize: 16.0.sp,
      );
    }
  }

  void _showDeleteDialog(types.Message message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(0, 0, 8, 8),
        title: Row(
          children:  [
            Icon(Icons.delete_forever_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text(
              '刪除訊息',
              textScaler: TextScaler.linear(1),
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
          ],
        ),
        content:  Text(
          '確定要刪除此訊息嗎？',
          textScaler: TextScaler.linear(1),
          style: TextStyle(color: Colors.black87, fontSize: 16.sp),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child:  Text('取消',textScaler: TextScaler.linear(1),
              style: TextStyle(fontSize: 16.sp),),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteMessage(message.id);
            },
            icon: const Icon(Icons.delete_outline),
            label:  Text('刪除',textScaler: TextScaler.linear(1),
              style: TextStyle(fontSize: 16.sp),),
          ),
        ],
      ),
    );
  }

  Widget _myImageMessageBuilder(
      types.ImageMessage message, {
        required int messageWidth,
      }) {
    final bool isMine = message.author.id == _user.id;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        if (isMine) _showDeleteDialog(message);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(maxWidth: messageWidth.toDouble()),
        decoration: BoxDecoration(
          color: isMine ? Colors.blue[100] : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8),
        child: Image.network(
          message.uri,
          fit: BoxFit.cover,
        ),
      ),
    );
  }


  Offset? _longPressPosition; // 在 State 裡定義變數



  Widget _myTextMessageBuilder(
      types.TextMessage message, {
        required int messageWidth,
        required bool showName,
      }) {
    final bool isMine = message.author.id == _user.id;
    final bgColor = Colors.transparent;//isMine ? const Color(0xffedcaf5) : const Color(0xffe1e4e8);
    final alignment = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (details) {
        _longPressPosition = details.globalPosition;
      },
      onLongPress: () async {
        if (_longPressPosition == null) return;
        final items = <PopupMenuEntry<String>>[
          PopupMenuItem(
            value: 'copy',
            child: Row(
              children: [
                Icon(Icons.copy, color: Colors.black54),
                SizedBox(width: 8),
                Text(
                  '複製',
                  textScaler: TextScaler.linear(1),
                  style: TextStyle(fontSize: 20.sp),
                ),
              ],
            ),
          ),
        ];
        if (isMine) {
          items.add(
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    '刪除',
                    textScaler: TextScaler.linear(1),
                    style: TextStyle(color: Colors.red, fontSize: 20.sp),
                  ),
                ],
              ),
            ),
          );
        }
        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            _longPressPosition!.dx,
            _longPressPosition!.dy,
            _longPressPosition!.dx,
            _longPressPosition!.dy,
          ),
          items: items,
        );
        if (selected == 'copy') {
          Clipboard.setData(ClipboardData(text: message.text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('已複製文字', textScaler: TextScaler.linear(1)),
            ),
          );
        } else if (selected == 'delete') {
          _showDeleteDialog(message);
        }
        _longPressPosition = null;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(maxWidth: messageWidth.toDouble()),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: alignment,
          children: [
            if (showName)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  message.author.firstName ?? '',
                  textScaler: TextScaler.linear(1),
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                ),
              ),
            if (message.previewData != null) ...[
              Text(
                message.text,
                textScaler: TextScaler.linear(1),
                style: TextStyle(color: Colors.black87, fontSize: 16.sp),
              ),
              const SizedBox(height: 6),
              Image.network(
                message.previewData?.image?.url ?? 'https://example.com/default.png',
                fit: BoxFit.contain,
                width: double.infinity,
                height: 150,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              ),
              if (message.previewData!.title != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    message.previewData!.title!,
                    textScaler: TextScaler.linear(1),
                    style: TextStyle(color:(isMine)?Colors.white:Colors.blue,fontWeight: FontWeight.bold),
                  ),
                ),
              if (message.previewData!.description != null)
                Text(
                  message.previewData!.description!,
                  textScaler: TextScaler.linear(1),
                  style: const TextStyle(color: Colors.black54),
                ),
            ] else ...[
              // 使用 RichText + TapGestureRecognizer 處理對方訊息匹配
              if (!isMine)
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.black87, fontSize: 16.sp),
                    children: parseMatchText(message.text),
                  ),
                )
              else
                Text(
                  message.text,
                  textScaler: TextScaler.linear(1),
                  style: TextStyle(color: Colors.black87, fontSize: 16.sp),
                ),
            ],
          ],
        ),
      ),
    );
  }

// 解析文字，返回 InlineSpan 列表，匹配中文 + 括號12位數字
  List<InlineSpan> parseMatchText(String text) {
    final pattern = RegExp(r'[\u4e00-\u9fa5]+\s*\((\d{12})\)');
    final matches = pattern.allMatches(text);

    if (matches.isEmpty) return [TextSpan(text: text)];

    List<InlineSpan> spans = [];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          recognizer: TapGestureRecognizer()
            ..onTap = ()async {
              final matchedText = match.group(0);
              //dev.log("點擊了 $matchedText");

              final text = matchedText;
              final regex = RegExp(r'\b(\d{12})\b');
              final matches = regex.allMatches(text!);
              //dev.log("抓到符合格式的代碼: ${text}");
              for (final match in matches) {
                final candidate = match.group(1);
                if (candidate != null) {
                  final year = int.tryParse(candidate.substring(0, 4));
                  final month = int.tryParse(candidate.substring(4, 6));
                  final day = int.tryParse(candidate.substring(6, 8));

                  if (year != null && month != null && day != null) {
                    try {
                      final date = DateTime(year, month, day);
                      //dev.log("抓到符合格式的代碼: $candidate, 日期為: ${DateFormat('yyyy-MM-dd').format(date)}");
                      if(text.contains("用藥委託")){
                        //SmartDialog.showLoading(msg: "處理中...");
                        await read_DRUG_MT_db_sub(DRUG_NO: candidate);
                        //SmartDialog.dismiss();

                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: DRUG_MT_T_page()));


                      }
                      else if(text.contains("接送委託")){

                        entrusted_pick_and_drop = Entrusted_pick_and_drop();

                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                showDialog_setState = setState;

                                //找出老師名字
                                EMPLOYEE eMPLOYEE = EMPLOYEE();
                                try{
                                  eMPLOYEE = eMPLOYEEs.firstWhere((element) => element.EMP_NO==entrusted_pick_and_drop.CFM_USER);
                                }
                                catch(e){

                                }
                                //dev.log("找出老師名字:${eMPLOYEE.EMP_NM}");

                                return Dialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // 取消圓角
                                  backgroundColor: Colors.white,
                                  insetPadding: EdgeInsets.all(0),
                                  child: entrusted_pick_and_drop.NO==""?
                                  ListView(
                                    padding: EdgeInsets.all(10),
                                    children: [
                                      Row(children: [
                                        IconButton(
                                          icon: Icon(Icons.close, color: Colors.transparent,size: 30.sp,),
                                          onPressed: (){},
                                        ),
                                        Expanded(child: Center(child:Text("接送委託",style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20.sp,
                                            color: Color(0xff555555))))),
                                        IconButton(
                                          icon: Icon(Icons.close, color: Colors.black,size: 30.sp,),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],),
                                      Container(height: 100.h,),
                                      Text(eXCUSED.NO==""?"此委託不存在\n或被家長收回":"${eXCUSED.NO}",textAlign: TextAlign.center,style: TextStyle(
                                          fontFamily: "GenJyuuGothic",
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20.sp,
                                          color: Color(0xff555555)))
                                    ],)
                                      :
                                  ListView(
                                    padding: EdgeInsets.all(10),
                                    children: [

                                      Row(children: [
                                        IconButton(
                                          icon: Icon(Icons.close, color: Colors.transparent,size: 30.sp,),
                                          onPressed: (){},
                                        ),
                                        Expanded(child: Center(child:Text("接送委託",style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20.sp,
                                            color: Color(0xff555555))))),
                                        IconButton(
                                          icon: Icon(Icons.close, color: Colors.black,size: 30.sp,),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],),

                                      Row(children: [
                                        Text("${entrusted_pick_and_drop.DateStr}",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Colors.blue)),
                                      ],),
                                      Container(height: 5.h,),
                                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                      Container(height: 5.h,),
                                      Column(children: entrusted_pick_and_drop.eNTRUSTED_DL_list.map((e) {
                                        ENTRUSTED_TYPE_ITEM? _ENTRUSTED_TYPE_ITEM;
                                        dev.log("ENTRUSTED_TYPE_ITEM_list.length:${ENTRUSTED_TYPE_ITEM_list.length}");
                                        if(ENTRUSTED_TYPE_ITEM_list.length>0){
                                          _ENTRUSTED_TYPE_ITEM = ENTRUSTED_TYPE_ITEM_list.firstWhere((element) => element.ITEM_NO==e.TYPE_NO);
                                        }

                                        TimeOfDay? timeOfDay;
                                        List<String> t1 = e.TIME.split(":");
                                        try{
                                          timeOfDay = TimeOfDay(hour: int.parse(t1[0]),minute: int.parse(t1[1]));
                                        }
                                        catch(e){

                                        }


                                        return Container(width: ScreenUtil().screenWidth,child: Column(children: [
                                          Row(children: [
                                            Text("${e.SR}.${_ENTRUSTED_TYPE_ITEM==null?"":_ENTRUSTED_TYPE_ITEM.ITEM_NM}",
                                                maxLines: null,
                                                style: TextStyle(
                                                    fontFamily: "GenJyuuGothic",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16.sp,
                                                    color: Color(0xff555555))),
                                            Container(width: 5.w,),
                                            Text("接送時間${(timeOfDay==null)?"":"${timeOfDay.period==DayPeriod.am?"上午":"下午"}${timeOfDay.hourOfPeriod}:${timeOfDay.minute.toString().padLeft(2,"0")}"}",
                                                maxLines: null,
                                                style: TextStyle(
                                                    fontFamily: "GenJyuuGothic",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16.sp,
                                                    color: Colors.blue)),
                                          ],),
                                        ],)
                                        );

                                      }).toList()),
                                      Container(height: 5.h,),
                                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                      Container(height: 5.h,),
                                      Row(children: [
                                        Text("代理人姓名:",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff555555))),
                                        Container(width: 5.w,),
                                        Text("${entrusted_pick_and_drop.AGENT_NM}",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Colors.blue)),
                                      ],),
                                      Container(height: 5.h,),
                                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                      Container(height: 5.h,),
                                      Row(children: [
                                        Text("代理人電話:",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff555555))),
                                        Container(width: 5.w,),
                                        Text("${entrusted_pick_and_drop.AGENT_PHONE}",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Colors.blue)),
                                      ],),
                                      Container(height: 5.h,),
                                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                      Container(height: 5.h,),
                                      Row(children: [
                                        Text("關係:",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff555555))),
                                        Container(width: 5.w,),
                                        Text("${entrusted_pick_and_drop.RELATION}",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Colors.blue)),
                                      ],),
                                      Container(height: 5.h,),
                                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                      Container(height: 5.h,),
                                      Row(children: [
                                        Text("說明:",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff555555))),
                                      ],),
                                      Row(children: [
                                        Expanded(child:
                                        Text("${entrusted_pick_and_drop.NOTE}",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Colors.blue))),
                                      ],),
                                      Container(height: 5.h,),
                                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                      Container(height: 5.h,),
                                      Row(children: [
                                        Expanded(child:
                                        Text("家長簽名",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff555555)))),
                                      ],),
                                      Container(width: ScreenUtil().screenWidth,height: 200.h,child: Image.network(entrusted_pick_and_drop.SIGN_LINK),),
                                      Container(height: 5.h,),
                                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                      Container(height: 5.h,),

                                      Container(width: ScreenUtil().screenWidth,child: Row(children: [

                                        Expanded(child: Column(children: [

                                          Row(children: [
                                            Text("確認者:",
                                                maxLines: null,
                                                style: TextStyle(
                                                    fontFamily: "GenJyuuGothic",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16.sp,
                                                    color: Color(0xff555555))),
                                            Container(width: 5.w,),
                                            Text("${eMPLOYEE.EMP_NM}",
                                                maxLines: null,
                                                style: TextStyle(
                                                    fontFamily: "GenJyuuGothic",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16.sp,
                                                    color: Colors.blue)),
                                          ],),
                                          Container(height: 5.h,),
                                          Row(children: [
                                            Text("確認日期時間:",
                                                maxLines: null,
                                                style: TextStyle(
                                                    fontFamily: "GenJyuuGothic",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16.sp,
                                                    color: Color(0xff555555))),
                                            Container(width: 5.w,),
                                            Text("${entrusted_pick_and_drop.CFM_DT_str}",
                                                maxLines: null,
                                                style: TextStyle(
                                                    fontFamily: "GenJyuuGothic",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 12.sp,
                                                    color: Colors.blue)),
                                          ],),
                                          Container(height: 5.h,),

                                        ],)),

                                        Container(
                                            padding: EdgeInsets.only( left:0.w,right: 0.w),
                                            width: 60.w,
                                            height: 40.h,
                                            child: ElevatedButton(
                                              style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(Color(0xff48C2BC)),
                                                  surfaceTintColor: MaterialStateProperty.all(Color(0xff48C2BC)),
                                                  padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                      RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(5.w),
                                                          side: BorderSide(color: Color(0xff555555))
                                                      )
                                                  )
                                              ),
                                              onPressed: () async{


                                                write_ENTRUSTED_db_sub(
                                                    NO:"${entrusted_pick_and_drop.NO}",
                                                    CFM_USER:EMPLOYEE_teacher.EMP_NO
                                                );

                                                /*
                                                      write_EXCUSED_db_sub(
                                                          NO:"${item.NO}",
                                                          CS_NO:"${item.CS_NO}",
                                                          CFM_NO:item.CFM_ITEM_selectedValue.CFM_NO,
                                                          CFM_USER:EMPLOYEE_teacher.EMP_NO
                                                      );

                                                       */


                                              },
                                              child: Row(children: [
                                                Expanded(child: Container()),
                                                Text('確認', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.white , fontSize: 20.sp)),
                                                Expanded(child: Container()),
                                              ],),
                                            )),

                                      ],),),

                                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                      Container(height: 5.h,),

                                    ],),
                                );
                              },
                            );
                          },
                        );


                        await ENTRUSTED_db_sub(NO:candidate);

                      }
                      else if(text.contains("請假委託")){

                        eXCUSED = EXCUSED();
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                showDialog_setState = setState;

                                //學校(DEPM)
                                //DEPM _DEPM = dEPMs.firstWhere((element) => element.DEPM_NO==eXCUSED.DEPM_NO);
                                CLASS _CLASS = CLASS();

                                try{
                                  _CLASS = cLASSs.firstWhere((element) => element.CLASS_NO==eXCUSED.CLASS_NO);
                                }
                                catch(e){

                                }



                                EXCUSED_HOURS_ITEM _EXCUSED_HOURS_ITEM = EXCUSED_HOURS_ITEM();
                                EXCUSED_REASON_ITEM _EXCUSED_REASON_ITEM = EXCUSED_REASON_ITEM();
                                CFM_ITEM _CFM_ITEM = CFM_ITEM();
                                try{
                                  if(EXCUSED_HOURS_ITEM_list.length>0) {
                                    _EXCUSED_HOURS_ITEM = EXCUSED_HOURS_ITEM_list
                                        .firstWhere((element) =>
                                    element.ITEM_NO == eXCUSED.HOURS_NO);
                                  }
                                  _EXCUSED_REASON_ITEM = EXCUSED_REASON_ITEM_list.firstWhere((element) => element.ITEM_NO==eXCUSED.REASON_NO);
                                  _CFM_ITEM = CFM_ITEM_list.firstWhere((element) => element.CFM_NO==eXCUSED.CFM_NO);

                                }
                                catch(e){

                                }


                                //老師名字
                                String teacher_name = "";
                                for(int i=0;i<eMPLOYEEs.length;i++){
                                  if(eMPLOYEEs[i].EMP_NO==eXCUSED.CFM_USER){
                                    teacher_name = eMPLOYEEs[i].EMP_NM;
                                    break;
                                  }
                                }

                                String student_name = "";
                                for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMERs.length;i++){
                                  for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs.length;j++){
                                    if(EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs[j].CS_NO==eXCUSED.CS_NO){
                                      student_name = EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs[j].CS_NM;
                                      break;
                                    }
                                  }
                                }



                                return Dialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // 取消圓角
                                  backgroundColor: Colors.white,
                                  insetPadding: EdgeInsets.all(0),
                                  child: eXCUSED.NO=="處理中"||eXCUSED.NO==""?
                                  ListView(
                                    padding: EdgeInsets.all(10),
                                    children: [
                                      Row(children: [
                                        IconButton(
                                          icon: Icon(Icons.close, color: Colors.transparent,size: 30.sp,),
                                          onPressed: (){},
                                        ),
                                        Expanded(child: Center(child:Text("請假委託",style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20.sp,
                                            color: Color(0xff555555))))),
                                        IconButton(
                                          icon: Icon(Icons.close, color: Colors.black,size: 30.sp,),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],),
                                      Container(height: 100.h,),
                                      Text(eXCUSED.NO==""?"此委託不存在\n或被家長收回":"${eXCUSED.NO}",textAlign: TextAlign.center,style: TextStyle(
                                          fontFamily: "GenJyuuGothic",
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20.sp,
                                          color: Color(0xff555555)))
                                    ],)
                                      :
                                  ListView(
                                    padding: EdgeInsets.all(10),
                                    children: [

                                      Row(children: [
                                        IconButton(
                                          icon: Icon(Icons.close, color: Colors.transparent,size: 30.sp,),
                                          onPressed: (){},
                                        ),
                                        Expanded(child: Center(child:Text("請假委託",style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20.sp,
                                            color: Color(0xff555555))))),
                                        IconButton(
                                          icon: Icon(Icons.close, color: Colors.black,size: 30.sp,),
                                          onPressed: () => Navigator.pop(context),
                                        ),
                                      ],),


                                      Row(children: [
                                        Text('${_CLASS==null?"":_CLASS.CLASS_NM}-${student_name}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 15.sp)),
                                      ],),
                                      Row(children: [
                                        Container(
                                          //width: ScreenUtil().screenWidth,
                                            child: Text("${eXCUSED.DateStr}",
                                                maxLines: null,
                                                style: TextStyle(
                                                    fontFamily: "GenJyuuGothic",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16.sp,
                                                    color: Color(0xff555555)))),
                                      ],),
                                      Row(children: [
                                        Text((_EXCUSED_REASON_ITEM==null)?"":"${_EXCUSED_REASON_ITEM.ITEM_NM}",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Colors.blue)),
                                        Container(width: 10.w,),
                                        Text((_EXCUSED_HOURS_ITEM==null)?"":"${_EXCUSED_HOURS_ITEM.ITEM_NM}",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Colors.blue)),
                                      ],),

                                      Container(height: 5.h,),
                                      Row(children: [
                                        Text("說明:",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff555555))),
                                      ],),
                                      Row(children: [
                                        Expanded(child:
                                        Text("${eXCUSED.NOTE}",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Colors.blue))),
                                      ],),
                                      Container(height: 5.h,),
                                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                      Container(height: 5.h,),
                                      Row(children: [
                                        Expanded(child:
                                        Text("家長簽名",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff555555)))),
                                      ],),
                                      Container(width: ScreenUtil().screenWidth,height: 200.h,child: Image.network(eXCUSED.SING_LINK),),
                                      Container(height: 5.h,),
                                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                      Container(height: 5.h,),
                                      Row(children: [
                                        Text("確認者:",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14.sp,
                                                color: Color(0xff555555))),
                                        Container(width: 5.w,),
                                        Text("${teacher_name}",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14.sp,
                                                color: Colors.blue)),
                                        Expanded(child: Container()),

                                        Text("確認:",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14.sp,
                                                color: Color(0xff555555))),
                                        Container(width: 5.w,),
                                        Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(5.w),
                                            ),
                                            //width: 80.w,
                                            height: 36.h,
                                            child:(eXCUSED.CFM_ITEM_selectedValue.CFM_NO.isEmpty)?Container():
                                            DropdownButtonHideUnderline(
                                              child: DropdownButton2<CFM_ITEM>(
                                                isExpanded: true,
                                                items: CFM_ITEM_list
                                                    .map((CFM_ITEM item) => DropdownMenuItem<CFM_ITEM>(
                                                  value: item,
                                                  child: Text(
                                                    item.CFM_NM,
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      fontWeight: FontWeight.bold,
                                                      color:Colors.blue,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ))
                                                    .toList(),
                                                value: eXCUSED.CFM_ITEM_selectedValue,
                                                onChanged: (value) {

                                                  setState(() {
                                                    eXCUSED.CFM_ITEM_selectedValue = value!;
                                                  });
                                                },
                                                buttonStyleData:  ButtonStyleData(
                                                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                                                  height: 40.h,
                                                  width: 110.w,
                                                ),
                                                menuItemStyleData: MenuItemStyleData(
                                                  height: 40.h,
                                                  padding: EdgeInsets.only(left: 14.w, right: 14.w),
                                                ),
                                              ),
                                            )),

                                        Container(width: 5.w,),
                                        /*
                                                    Text((_CFM_ITEM==null)?"":"${_CFM_ITEM.CFM_NM}",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Colors.blue)),

                                                     */
                                      ],),
                                      Container(height: 5.h,),
                                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                      Container(height: 5.h,),
                                      Row(children: [
                                        Text("確認日期時間:",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14.sp,
                                                color: Color(0xff555555))),
                                        Container(width: 5.w,),
                                        Text((eXCUSED.CFM_DT.isEmpty)?"":"${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(eXCUSED.CFM_DT))}",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14.sp,
                                                color: Colors.blue)),
                                      ],),
                                      Container(height: 5.h,),
                                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                      Container(height: 5.h,),
                                      Container(
                                          padding: EdgeInsets.only( left:0.w,right: 0.w),
                                          width: ScreenUtil().screenWidth,
                                          height: 55.h,
                                          child: ElevatedButton(
                                            style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all(Color(0xff48C2BC)),
                                                surfaceTintColor: MaterialStateProperty.all(Color(0xff48C2BC)),
                                                padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(28.w),
                                                        side: BorderSide(color: Color(0xff555555))
                                                    )
                                                )
                                            ),
                                            onPressed: () async{


                                              write_EXCUSED_db_sub(
                                                  NO:"${eXCUSED.NO}",
                                                  CS_NO:"${eXCUSED.CS_NO}",
                                                  CFM_NO:eXCUSED.CFM_ITEM_selectedValue.CFM_NO,
                                                  CFM_USER:EMPLOYEE_teacher.EMP_NO
                                              );



                                            },
                                            child: Row(children: [
                                              Expanded(child: Container()),
                                              Text('送出', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                                              Expanded(child: Container()),
                                            ],),
                                          )),
                                      Container(height: 5.h,),

                                    ],),
                                );
                              },
                            );
                          },
                        );
                        await EXCUSED_db_sub(NO:candidate);
                      }
                    } catch (e) {
                      //dev.log("解析日期失敗: $candidate");
                    }
                  }
                }
              }


            },

        ),
      );
      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return spans;
  }



  Widget _myTextMessageBuilder2(
      types.TextMessage message, {
        required int messageWidth,
        required bool showName,
      }) {
    final bool isMine = message.author.id == _user.id;
    final bgColor = isMine ? const Color(0xffedcaf5) : const Color(0xffe1e4e8);
    final alignment = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: (details) {
        _longPressPosition = details.globalPosition; // 記錄長按開始的位置
      },
      onLongPress: () async {
        if (_longPressPosition == null) return;
        final items = <PopupMenuEntry<String>>[
          PopupMenuItem(
            value: 'copy',
            child: Row(
              children:  [
                Icon(Icons.copy, color: Colors.black54),
                SizedBox(width: 8),
                Text('複製',textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 20.sp),),
              ],
            ),
          ),
        ];
        if (isMine) {
          items.add(
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children:  [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text(
                    '刪除', textScaler: TextScaler.linear(1),
                    style: TextStyle(color: Colors.red,fontSize: 20.sp),
                  ),
                ],
              ),
            ),
          );
        }
        final selected = await showMenu<String>(
          context: context,
          position: RelativeRect.fromLTRB(
            _longPressPosition!.dx,
            _longPressPosition!.dy,
            _longPressPosition!.dx,
            _longPressPosition!.dy,
          ),
          items: items,
        );
        if (selected == 'copy') {
          Clipboard.setData(ClipboardData(text: message.text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已複製文字',textScaler: TextScaler.linear(1),)),
          );
        } else if (selected == 'delete') {
          _showDeleteDialog(message);
        }
        _longPressPosition = null; // 用完清掉
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        constraints: BoxConstraints(maxWidth: messageWidth.toDouble()),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: alignment,
          children: [
            if (showName)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  message.author.firstName ?? '',
                  textScaler: TextScaler.linear(1),
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                ),
              ),
            if (message.previewData != null) ...[
              Text(
                message.text,
                textScaler: TextScaler.linear(1),
                style: TextStyle(color: Colors.black87, fontSize: 16.sp),
              ),
              const SizedBox(height: 6),
              Image.network(
                message.previewData!.image!.url,
                fit: BoxFit.contain,
                width: double.infinity,
                height: 150,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              ),
              if (message.previewData!.title != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    message.previewData!.title!,
                    textScaler: TextScaler.linear(1),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              if (message.previewData!.description != null)
                Text(
                  message.previewData!.description!,
                  textScaler: TextScaler.linear(1),
                  style: const TextStyle(color: Colors.black54),
                ),
            ] else
              Text(
                message.text,
                textScaler: TextScaler.linear(1),
                style:  TextStyle(color: Colors.black87, fontSize: 16.sp),
              ),
          ],
        ),
      ),
    );
  }


  Future<void> _syncDeletedMessages(String chatId) async {
    if (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages.isEmpty) return;

    // 先複製並排序，不影響原本 _messages
    List<types.Message> sortedMessages = List.from(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages)
      ..sort((a, b) => a.id.compareTo(b.id));

    // 1. 取本地第一筆與最後一筆的 MessageID
    String minId = sortedMessages.first.id;
    String maxId = sortedMessages.last.id;


    // 2. SQL 查詢區間內的訊息 ID
    String sql = '''
SELECT MessageID
FROM MSDL2
WHERE ChatID = N'$chatId'
  AND MessageID BETWEEN N'$minId' AND N'$maxId'
''';

    String result = await sql_command(sql);
    //dev.log("本地端(要刪掉的訊息):${result}");
    List<String> serverIds = (jsonDecode(result) as List)
        .map((e) => e['MessageID'] as String)
        .toList();

    // 3. 比對出「本地有但後端沒有」的訊息
    Set<String> serverIdSet = serverIds.toSet();
    List<String> toRemove = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages
        .where((msg) => !serverIdSet.toString().trim().contains(msg.id))
        .map((msg) => msg.id)
        .toList();

    // 4. 刪除多餘訊息
    if (toRemove.isNotEmpty) {
      setState(() {
        EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages.removeWhere((msg) => toRemove.contains(msg.id));
      });
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) return; // 防止多次觸發
    _isLoadingMore = true;
    setState(() {

    });
    final oldestMessageId = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages.last.id;
    //dev.log("oldestMessageId:${oldestMessageId}");
    await fetchLatestMessages(beforeId: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(int.parse(oldestMessageId))), limit: 15);
    _isLoadingMore = false;
    setState(() {

    });
  }

  Future<void> fetchLatestMessages({String beforeId="",int limit=15}) async {

    String comm = '''SELECT TOP 15 *
FROM MSDL2
WHERE ChatID = '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID}'
  AND CreatedAt < '${beforeId}'
ORDER BY CreatedAt DESC''';
    //dev.log("${comm}");
    String result = await sql_command("${comm}");
    //SmartDialog.dismiss();
    try{
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      data_list = trim_proc(data_list);

      data_list.sort((a,b) => a['CreatedAt'].compareTo(b['CreatedAt']));

      List<dynamic> data_list2 = [];
      bool check = false;
      for(int i=0;i<data_list.length;i++){
        check = false;
        for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages.length;j++){
          if(data_list[i]["MessageID"].trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages[j].id){
            check = true;
            break;
          }
        }
        if(check==false){
          data_list2.add(data_list[i]);
        }
      }

      //dev.log("data_list2.lengt:${data_list2.length}");

      for(int i=0;i<data_list2.length;i++){

        //dev.log("Type:${data_list2[i]["Type"]}");
        //dev.log("AuthorID:${data_list2[i]["AuthorID"]}");
        //dev.log("_user.id:${_user.id}");


        //檢查每則訊息的已讀狀態
        int is_read_count = 0;
        List<dynamic> MSRS_data_list = await check_MSRS_Status_sub(
          ChatID:'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID}',
          MessageID:data_list2[i]["MessageID"].trim(),
        );
        for(int j=0;j<MSRS_data_list.length;j++){
          if("${MSRS_data_list[j]["Status"]}"=="seen"){
            is_read_count+=1;
          }
        }
        //dev.log("is_read_count:${is_read_count}");

        if("${data_list2[i]["Type"]}".trim()=="text"){

          var textMessage = types.TextMessage(
            author: types.User(
              id: "${data_list2[i]["AuthorID"]}".trim(),//Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
              lastName:'',
              firstName: "${data_list2[i]["AuthorFirstName"]}".trim(),
            ),
            createdAt: (DateTime.parse(data_list2[i]["CreatedAt"].trim()).subtract(Duration(hours: (Platform.isIOS)?0:0)).millisecondsSinceEpoch).toInt(),
            id: data_list2[i]["MessageID"].trim(),
            text: data_list2[i]["Text"].trim(),
            status: is_read_count<=0?null:types.Status.seen,
            metadata: {
              'is_read_count': '${is_read_count}',
              'text':data_list2[i]["Text"].trim(),
              'type':'文字',
              'ChatID':'${data_list2[i]["ChatID"]}'
            },
          );
          _addMessage2(textMessage,index: sel_chat_index);
        }
        else if("${data_list2[i]["Type"]}".trim()=="image"){

          String resourceUri = "${data_list2[i]["ResourceUri"]}";
          if(resourceUri.isNotEmpty){
            String _LINK = resourceUri.replaceAll("~/", "");
            resourceUri = "${IMAGE_IP}/${_LINK}";
          }

          final message = types.ImageMessage(
            author: types.User(
              id: "${data_list2[i]["AuthorID"]}".trim(),//Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
              lastName:'',
              firstName: "${data_list2[i]["AuthorFirstName"]}".trim(),
            ),
            createdAt: (DateTime.parse(data_list2[i]["CreatedAt"].trim()).subtract(Duration(hours: (Platform.isIOS)?0:0)).millisecondsSinceEpoch).toInt(),
            height: double.parse("${data_list2[i]["ImageHeight"]}".trim()),
            id: "${data_list2[i]["MessageID"]}".trim(),
            name: "${data_list2[i]["ResourceUri"]}".trim(),
            size: int.parse("${data_list2[i]["ResourceSize"]}".trim().contains("null")?"100":"${data_list2[i]["ResourceSize"]}".trim()),
            uri: resourceUri,
            width: double.parse("${data_list2[i]["ImageWidth"]}".trim()),
            status: is_read_count<=0?null:types.Status.seen,
            metadata: {
              'type':'圖片',
              'is_read_count': '${is_read_count}',
              'name':"${data_list2[i]["ResourceUri"]}".trim(),
              'height':double.parse("${data_list2[i]["ImageHeight"]}".trim()),
              'width':double.parse("${data_list2[i]["ImageWidth"]}".trim()),
              'uri': resourceUri,
              'size': int.parse("${data_list2[i]["ResourceSize"]}".trim().contains("null")?"100":"${data_list2[i]["ResourceSize"]}".trim()),
              'ChatID':'${data_list2[i]["ChatID"]}'
            },
          );

          _addMessage2(message,index: sel_chat_index);

        }

      }

      //把未讀狀態改為已讀
      for(int i=0;i<data_list2.length;i++){
        await update_MSRS_by_Status_sub(
          AuthorID:EMPLOYEE_teacher.ACCOUNT,
          MessageID:data_list2[i]["MessageID"].trim(),
          ChatID:'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID}',
        );
      }

      _hasMore = data_list.length == 15;


    }
    catch(e){
      //dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }

  }


  String generateMultiConditionSQL(List<String> csNos, List<String> classNos, List<String> depmNos) {
    if (csNos.length != classNos.length || csNos.length != depmNos.length) {
      throw Exception("三個陣列長度不一致");
    }

    List<String> conditionList = [];

    for (int i = 0; i < csNos.length; i++) {
      final cs = csNos[i].replaceAll("'", "''");
      final cl = classNos[i].replaceAll("'", "''");
      final dp = depmNos[i].replaceAll("'", "''");

      conditionList.add("(CS_NO = N'$cs' AND CLASS_NO = N'$cl' AND DEPM_NO = N'$dp')");
    }

    String whereClause = conditionList.join(" OR ");

    return "SELECT * FROM MSMT2 WHERE $whereClause";
  }

  Future<void> init()async{
    //dev.log("執行init()");

    List<String> csNos = [];
    List<String> classNos = [];
    List<String> depmNos = [];
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      csNos.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO);
      classNos.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CLASS_NO);
      depmNos.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].DEPM_NO);
    }
    String sql = generateMultiConditionSQL(csNos, classNos, depmNos);
    String result = await sql_command(sql);
    //dev.log("))):${result}");

    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      //dev.log("???${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NM},${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO},${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].cUSTOMER_DLs.length}");
      if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].cUSTOMER_DLs.isNotEmpty &&
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].ChatID.isEmpty
      ) {

        try{
          List<dynamic> list = jsonDecode(result);
          List<dynamic> data_list = [];
          data_list = list;
          data_list = trim_proc(data_list);
          for(int j=0;j<data_list.length;j++){
            if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].DEPM_NO=="${data_list[j]["DEPM_NO"]}" &&
                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CLASS_NO=="${data_list[j]["CLASS_NO"]}" &&
                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO=="${data_list[j]["CS_NO"]}"
            ){
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].ChatID = "${data_list[j]["ChatID"]}";
            }
          }

          //如果聊天室id還是空的 , 需要創建一個新的聊天室id
          if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].ChatID.isEmpty){
            await insert_MSMT2_db_sub(CS_NO:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO,CLASS_NO:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CLASS_NO,DEPM_NO:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].DEPM_NO,index:i);
          }

        }
        catch(e){

        }

        MyHomePage2_T_fun3!();
        setState(() {

        });
      }
    }

    /*
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].cUSTOMER_DLs.isNotEmpty &&
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].ChatID.isEmpty
      ) {
        await check_is_ChatID_sub(
            //UserAccount: '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
            //    .cUSTOMERs[i].cUSTOMER_DL!.ACCOUNT}',
            //TeacherAccount: "${EMPLOYEE_teacher.ACCOUNT}",
            CS_NO:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO,
            CLASS_NO:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CLASS_NO,
            DEPM_NO:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].DEPM_NO,
            index: i
        ); //檢查是否已建立聊天室
        MyHomePage2_T_fun3!();
        setState(() {

        });
      }
    }

     */
  }

  /*
  檢查是否已建立聊天室
   */
  /*
  Future<void>check_is_ChatID_sub(
      {
        String TeacherAccount="",
        String UserAccount="",
        int index=0,
        String CS_NO="",
        String CLASS_NO="",
        String DEPM_NO="",
      })async{

    TeacherAccount = TeacherAccount.trim();
    UserAccount = UserAccount.trim();
    //dev.log("檢查聊天室(${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].CS_NO},${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].CS_NM})");
    //await EasyLoading.show(status: "處理中...");
    String result = await sql_command("SELECT * FROM MSMT2 WHERE CS_NO='${CS_NO}' AND CLASS_NO='${CLASS_NO}' AND DEPM_NO='${DEPM_NO}'");
    //await EasyLoading.dismiss();
    try{
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      data_list = trim_proc(data_list);
      if(data_list.length==0){
        //dev.log("尚未建立聊天室");
        insert_MSMT2_db_sub(CS_NO:CS_NO,CLASS_NO:CLASS_NO,DEPM_NO:DEPM_NO,index:index);
        EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_count=0;
        setState(() {

        });
      }
      else{
        //dev.log("已建立聊天室");
        //EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID = await get_ChatID_form_MSMT2_db_sub(CS_NO:CS_NO,CLASS_NO:CLASS_NO,DEPM_NO:DEPM_NO);
        EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID = "${data_list[0]["ChatID"]}".trim();
        if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID.isNotEmpty){
          //await _loadMessages(index:index);
        }
      }

      dev.log("-------------------------------------------------");

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }

   */


  Future<void> insert_MSMT2_db_sub(
      {
        String CS_NO="",
        String CLASS_NO="",
        String DEPM_NO="",
        int index=0
      })async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");

    // 先產生一個候選 ChatID (僅在 INSERT 時會用到)
    String newChatID = "${DateTime.now().microsecondsSinceEpoch}";

    List<String> TeacherAccount = [];
    List<String> UserAccount=[];
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].cLASS_NO_for_teacher.length;i++){
      TeacherAccount.add("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].cLASS_NO_for_teacher[i].ACCOUNT.trim()}");
    }
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].cUSTOMER_DLs.length;i++){
      UserAccount.add("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].cUSTOMER_DLs[i]!.ACCOUNT.trim()}");
    }
    //EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID = ChatID;

    //String comm = "INSERT INTO MSMT2(ChatID,CS_NO,CLASS_NO,DEPM_NO,TeacherAccount,UserAccount) VALUES ('${ChatID}','${CS_NO}',${CLASS_NO},'${DEPM_NO}','${jsonEncode(TeacherAccount)}','${jsonEncode(UserAccount)}')";

    String comm = """
MERGE MSMT2 AS target
USING (SELECT '${CS_NO}' AS CS_NO, '${CLASS_NO}' AS CLASS_NO, '${DEPM_NO}' AS DEPM_NO) AS source
ON (target.CS_NO = source.CS_NO AND target.CLASS_NO = source.CLASS_NO AND target.DEPM_NO = source.DEPM_NO)
WHEN MATCHED THEN
    UPDATE SET TeacherAccount = '${jsonEncode(TeacherAccount)}',
               UserAccount = '${jsonEncode(UserAccount)}'
WHEN NOT MATCHED THEN
    INSERT (ChatID, CS_NO, CLASS_NO, DEPM_NO, TeacherAccount, UserAccount)
    VALUES ('${newChatID}', source.CS_NO, source.CLASS_NO, source.DEPM_NO, '${jsonEncode(TeacherAccount)}', '${jsonEncode(UserAccount)}')
OUTPUT inserted.ChatID;
""";
    dev.log("${comm}");
    String result = await sql_command2("${comm}");
    SmartDialog.dismiss();
    try{
      if (result.isNotEmpty) {
        final chatId = result;
        EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID = chatId;
        dev.log("操作結果:ChatID=$chatId");
      }
    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }

  Future<String> get_ChatID_form_MSMT2_db_sub(
      {
        String TeacherAccount="",
        String UserAccount="",
        String CS_NO="",
        String CLASS_NO="",
        String DEPM_NO="",
      })async{
    //await EasyLoading.show(status: "處理中...");
    String comm = "SELECT * FROM MSMT2 WHERE CS_NO='${CS_NO}' AND CLASS_NO='${CLASS_NO}' AND DEPM_NO='${DEPM_NO}'";
    //dev.log("${comm}");
    String result = await sql_command("${comm}");
    //await EasyLoading.dismiss();
    try{
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      data_list = trim_proc(data_list);
      return data_list[0]["ChatID"].toString().trim();
    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
      return "";
    }
  }


  void _addMessage(types.Message message,{int index=0}) {
    // 檢查是否已存在相同 id 的訊息
    /*
    bool exists = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages.any((m) => m.id == message.id);
    if (!exists) {
      EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages.insert(0, message);
      EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages.sort((a,b) => "${b.id}".compareTo("${a.id}"));
      setState(() {

      });
    }

     */

    dev.log("_addMessage()");

    final messagesList = EMPLOYEE_teacher
        .Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages;

    // 1️⃣ 判斷是否已有相同 ID（避免重複）
    if (messagesList.any((m) => m.id == message.id)) {
      return;
    }

    // 2️⃣ 找到正確插入位置（因為 id 是時間戳，可以排序）
    final insertIndex = messagesList.indexWhere((m) => m.id.compareTo(message.id) < 0);

    if (insertIndex == -1) {
      // 如果沒找到比它小的，就放最後
      messagesList.add(message);
    } else {
      messagesList.insert(insertIndex, message);
    }

    setState(() {});

  }

  void _addMessage2(types.Message message,{int index=0}) {


    dev.log("_addMessage2()");

    // 檢查是否已存在相同 id 的訊息
    /*
    bool exists = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages.any((m) => m.id == message.id);
    if (!exists) {
      EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages.insert(0, message);
      EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages.sort((a,b) => "${b.id}".compareTo("${a.id}"));
    }

     */

    final messagesList = EMPLOYEE_teacher
        .Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages;

    // 1️⃣ 判斷是否已有相同 ID（避免重複）
    if (messagesList.any((m) => m.id == message.id)) {
      return;
    }

    // 2️⃣ 找到正確插入位置（因為 id 是時間戳，可以排序）
    final insertIndex = messagesList.indexWhere((m) => m.id.compareTo(message.id) < 0);

    if (insertIndex == -1) {
      // 如果沒找到比它小的，就放最後
      messagesList.add(message);
    } else {
      messagesList.insert(insertIndex, message);
    }


  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 140.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: Container()),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('圖片',style: TextStyle(fontSize: 20.sp),),
                ),
              ),
              /*
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('File'),
                ),
              ),

               */
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text('取消',style: TextStyle(fontSize: 20.sp),),
                ),
              ),
              Expanded(child: Container()),
            ],
          ),
        ),
      ),
    );
  }

  /*
  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      final message = types.FileMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: const Uuid().v4(),
        mimeType: lookupMimeType(result.files.single.path!),
        name: result.files.single.name,
        size: result.files.single.size,
        uri: result.files.single.path!,
      );

      _addMessage(message);
    }
  }

   */


  /// Captures the current screen and saves it as an image in the gallery.
  Future<void> _saveScreen({String img_url=""}) async {

    dev.log("下載圖片:${img_url}");

    try {
      final response = await Dio().get(
        img_url,
        options: Options(responseType: ResponseType.bytes),
      );
      final result = await ImageGallerySaverPlus.saveImage(
          Uint8List.fromList(response.data),
          quality: downloadImageCompress_quality,
          isReturnImagePathOfIOS: true,
          name: "${DateTime.now().microsecondsSinceEpoch}");
      Fluttertoast.showToast(msg: "下載圖片成功\n${result["filePath"]}", toastLength: Toast.LENGTH_LONG);

    } catch (e) {
      Fluttertoast.showToast(msg: "下載圖片遇到錯誤", toastLength: Toast.LENGTH_LONG);
    }
  }

  void showImageViewer(BuildContext context, types.ImageMessage message) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(8),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(child: Image.network(message.uri)),
            ),
            // 關閉按鈕
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black,size: 30.sp,),
                onPressed: () => Navigator.pop(_),
              ),
            ),
            // 下載按鈕
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Color(0xffF9AA88),
                child: Icon(Icons.download, color: Colors.black),
                onPressed: () async {


                  if(Platform.isAndroid){
                    if(await checkAndRequestPermissions(skipIfExists: true)==true){
                      _saveScreen(img_url:message.uri);
                    }
                  }
                  else{
                    _saveScreen(img_url:message.uri);
                  }


                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  /*
  [托嬰/幼兒]用藥委託主表單(個人) DRUG_MT
   */
  Future<void> read_DRUG_MT_db_sub({String DRUG_NO=""})async{



    setState(() {

    });
    String comm = '''
    SELECT * FROM DRUG_MT WHERE DRUG_NO='${DRUG_NO}'
    AND DEPM_NO='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].DEPM_NO}'
         AND CLASS_NO='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].CLASS_NO}'
         AND CS_NO='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].CS_NO}'
    ''';
    dev.log("${comm}");
    String result = await sql_command("${comm}");

    try{
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      data_list = trim_proc(data_list);
      if(data_list.length==0){
      }
      else{

        for(int i=0;i<data_list.length;i++){
          dRUG_MT = DRUG_MT();
          dRUG_MT.REASON = "${data_list[i]["REASON"]}"=="null"?"":"${data_list[i]["REASON"]}";
          dRUG_MT.DATETIME = "${data_list[i]["DATETIME"]}"=="null"?"":"${data_list[i]["DATETIME"]}";
          dRUG_MT.CLASS_NO = "${data_list[i]["CLASS_NO"]}"=="null"?"":"${data_list[i]["CLASS_NO"]}";
          dRUG_MT.DEPM_NO = "${data_list[i]["DEPM_NO"]}"=="null"?"":"${data_list[i]["DEPM_NO"]}";
          dRUG_MT.AGREE = "${data_list[i]["AGREE"]}"=="null"?"":"${data_list[i]["AGREE"]}";
          dRUG_MT.DATE = "${data_list[i]["DATE"]}"=="null"?"":"${data_list[i]["DATE"]}";
          dRUG_MT.DRUG_NO = "${data_list[i]["DRUG_NO"]}"=="null"?"":"${data_list[i]["DRUG_NO"]}";
          dRUG_MT.DRUG_LINK = "${data_list[i]["DRUG_LINK"]}"=="null"?"":"${data_list[i]["DRUG_LINK"]}";
          dRUG_MT.SIGN_LINK = "${data_list[i]["SIGN_LINK"]}"=="null"?"":"${data_list[i]["SIGN_LINK"]}";
          dRUG_MT.CS_NO = "${data_list[i]["CS_NO"]}"=="null"?"":"${data_list[i]["CS_NO"]}";
          dRUG_MT.DEL = "${data_list[i]["DEL"]}"=="null"?"":"${data_list[i]["DEL"]}";

          if(dRUG_MT.DRUG_LINK.isNotEmpty){
            String DRUG_LINK = dRUG_MT.DRUG_LINK.replaceAll("~/", "");
            dRUG_MT.DRUG_LINK = "${IMAGE_IP}/${DRUG_LINK}";
          }

          if(dRUG_MT.SIGN_LINK.isNotEmpty){
            String SIGN_LINK = dRUG_MT.SIGN_LINK.replaceAll("~/", "");
            dRUG_MT.SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK}";
          }
          dRUG_MT.DATE = DateFormat("yyyy-MM-dd").format(DateTime.parse(dRUG_MT.DATE));
          List<String> list = dRUG_MT.DATE.split("-");
          dRUG_MT.DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[DateTime(int.parse(list[0]),int.parse(list[1]),int.parse(list[2])).weekday-1]})";
          if(dRUG_MT.DEL.isNotEmpty){
            dRUG_MT = DRUG_MT();
          }
        }


      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  void _handleMessageTap(BuildContext _, types.Message message) async {

    dev.log("點擊訊息:");
    if (message is types.TextMessage && message.previewData?.link != null) {
      final url = message.previewData!.link!;
      launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
    }
    /*
    else if (message is types.TextMessage && message.previewData?.link == null) {
      final text = message.text;
      final regex = RegExp(r'\b(\d{12})\b');
      final matches = regex.allMatches(text);
      dev.log("抓到符合格式的代碼: ${text}");
      for (final match in matches) {
        final candidate = match.group(1);
        if (candidate != null) {
          final year = int.tryParse(candidate.substring(0, 4));
          final month = int.tryParse(candidate.substring(4, 6));
          final day = int.tryParse(candidate.substring(6, 8));

          if (year != null && month != null && day != null) {
            try {
              final date = DateTime(year, month, day);
              dev.log("抓到符合格式的代碼: $candidate, 日期為: ${DateFormat('yyyy-MM-dd').format(date)}");
              if(text.contains("用藥委託")){
                //SmartDialog.showLoading(msg: "處理中...");
                await read_DRUG_MT_db_sub(DRUG_NO: candidate);
                //SmartDialog.dismiss();
                Navigator.push(context, PageTransition(
                    type: PageTransitionType.rightToLeft, child: DRUG_MT_T_page()));

              }
              else if(text.contains("接送委託")){

                entrusted_pick_and_drop = Entrusted_pick_and_drop();

                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        showDialog_setState = setState;

                        //找出老師名字
                        EMPLOYEE eMPLOYEE = EMPLOYEE();
                        try{
                          eMPLOYEE = eMPLOYEEs.firstWhere((element) => element.EMP_NO==entrusted_pick_and_drop.CFM_USER);
                        }
                        catch(e){

                        }
                        dev.log("找出老師名字:${eMPLOYEE.EMP_NM}");

                        return Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // 取消圓角
                          backgroundColor: Colors.white,
                          insetPadding: EdgeInsets.all(0),
                          child: ListView(
                            padding: EdgeInsets.all(10),
                            children: [

                              Row(children: [
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.transparent,size: 30.sp,),
                                  onPressed: (){},
                                ),
                                Expanded(child: Center(child:Text("接送委託",style: TextStyle(
                                    fontFamily: "GenJyuuGothic",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20.sp,
                                    color: Color(0xff555555))))),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.black,size: 30.sp,),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],),
                              Column(children: entrusted_pick_and_drop.eNTRUSTED_DL_list.map((e) {
                                ENTRUSTED_TYPE_ITEM? _ENTRUSTED_TYPE_ITEM;
                                if(ENTRUSTED_TYPE_ITEM_list.length>0){
                                  _ENTRUSTED_TYPE_ITEM = ENTRUSTED_TYPE_ITEM_list.firstWhere((element) => element.ITEM_NO==e.TYPE_NO);
                                }

                                TimeOfDay? timeOfDay;
                                List<String> t1 = e.TIME.split(":");
                                try{
                                  timeOfDay = TimeOfDay(hour: int.parse(t1[0]),minute: int.parse(t1[1]));
                                }
                                catch(e){

                                }


                                return Container(width: ScreenUtil().screenWidth,child: Column(children: [
                                  Row(children: [
                                    Text("${e.SR}.${_ENTRUSTED_TYPE_ITEM==null?"":_ENTRUSTED_TYPE_ITEM.ITEM_NM}",
                                        maxLines: null,
                                        style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16.sp,
                                            color: Color(0xff555555))),
                                    Container(width: 5.w,),
                                    Text("接送時間${(timeOfDay==null)?"":"${timeOfDay.period==DayPeriod.am?"上午":"下午"}${timeOfDay.hourOfPeriod}:${timeOfDay.minute.toString().padLeft(2,"0")}"}",
                                        maxLines: null,
                                        style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16.sp,
                                            color: Colors.blue)),
                                  ],),
                                ],)
                                );

                              }).toList()),
                              Container(height: 5.h,),
                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                              Container(height: 5.h,),
                              Row(children: [
                                Text("代理人姓名:",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        color: Color(0xff555555))),
                                Container(width: 5.w,),
                                Text("${entrusted_pick_and_drop.AGENT_NM}",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        color: Colors.blue)),
                              ],),
                              Container(height: 5.h,),
                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                              Container(height: 5.h,),
                              Row(children: [
                                Text("代理人電話:",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        color: Color(0xff555555))),
                                Container(width: 5.w,),
                                Text("${entrusted_pick_and_drop.AGENT_PHONE}",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        color: Colors.blue)),
                              ],),
                              Container(height: 5.h,),
                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                              Container(height: 5.h,),
                              Row(children: [
                                Text("關係:",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        color: Color(0xff555555))),
                                Container(width: 5.w,),
                                Text("${entrusted_pick_and_drop.RELATION}",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        color: Colors.blue)),
                              ],),
                              Container(height: 5.h,),
                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                              Container(height: 5.h,),
                              Row(children: [
                                Text("說明:",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        color: Color(0xff555555))),
                              ],),
                              Row(children: [
                                Expanded(child:
                                Text("${entrusted_pick_and_drop.NOTE}",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        color: Colors.blue))),
                              ],),
                              Container(height: 5.h,),
                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                              Container(height: 5.h,),
                              Row(children: [
                                Expanded(child:
                                Text("家長簽名",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        color: Color(0xff555555)))),
                              ],),
                              Container(width: ScreenUtil().screenWidth,height: 200.h,child: Image.network(entrusted_pick_and_drop.SIGN_LINK),),
                              Container(height: 5.h,),
                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                              Container(height: 5.h,),

                              Container(width: ScreenUtil().screenWidth,child: Row(children: [

                                Expanded(child: Column(children: [

                                  Row(children: [
                                    Text("確認者:",
                                        maxLines: null,
                                        style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16.sp,
                                            color: Color(0xff555555))),
                                    Container(width: 5.w,),
                                    Text("${eMPLOYEE.EMP_NM}",
                                        maxLines: null,
                                        style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16.sp,
                                            color: Colors.blue)),
                                  ],),
                                  Container(height: 5.h,),
                                  Row(children: [
                                    Text("確認日期時間:",
                                        maxLines: null,
                                        style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16.sp,
                                            color: Color(0xff555555))),
                                    Container(width: 5.w,),
                                    Text("${entrusted_pick_and_drop.CFM_DT_str}",
                                        maxLines: null,
                                        style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.sp,
                                            color: Colors.blue)),
                                  ],),
                                  Container(height: 5.h,),

                                ],)),

                                Container(
                                    padding: EdgeInsets.only( left:0.w,right: 0.w),
                                    width: 60.w,
                                    height: 40.h,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor: MaterialStateProperty.all(Color(0xff48C2BC)),
                                          surfaceTintColor: MaterialStateProperty.all(Color(0xff48C2BC)),
                                          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5.w),
                                                  side: BorderSide(color: Color(0xff555555))
                                              )
                                          )
                                      ),
                                      onPressed: () async{


                                        write_ENTRUSTED_db_sub(
                                            NO:"${entrusted_pick_and_drop.NO}",
                                            CFM_USER:EMPLOYEE_teacher.EMP_NO
                                        );

                                        /*
                                                      write_EXCUSED_db_sub(
                                                          NO:"${item.NO}",
                                                          CS_NO:"${item.CS_NO}",
                                                          CFM_NO:item.CFM_ITEM_selectedValue.CFM_NO,
                                                          CFM_USER:EMPLOYEE_teacher.EMP_NO
                                                      );

                                                       */


                                      },
                                      child: Row(children: [
                                        Expanded(child: Container()),
                                        Text('確認', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.white , fontSize: 20.sp)),
                                        Expanded(child: Container()),
                                      ],),
                                    )),

                              ],),),

                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                              Container(height: 5.h,),

                            ],),
                        );
                      },
                    );
                  },
                );


                await ENTRUSTED_db_sub(NO:candidate);

              }
              else if(text.contains("請假委託")){

                eXCUSED = EXCUSED();
                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        showDialog_setState = setState;

                        //老師名字
                        String teacher_name = "";
                        for(int i=0;i<eMPLOYEEs.length;i++){
                          if(eMPLOYEEs[i].EMP_NO==eXCUSED.CFM_USER){
                            teacher_name = eMPLOYEEs[i].EMP_NM;
                            break;
                          }
                        }

                        return Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // 取消圓角
                          backgroundColor: Colors.white,
                          insetPadding: EdgeInsets.all(0),
                          child:
                          ListView(
                            padding: EdgeInsets.all(10),
                            children: [

                              Row(children: [
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.transparent,size: 30.sp,),
                                  onPressed: (){},
                                ),
                                Expanded(child: Center(child:Text("接送委託",style: TextStyle(
                                    fontFamily: "GenJyuuGothic",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20.sp,
                                    color: Color(0xff555555))))),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.black,size: 30.sp,),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],),
                              Container(height: 5.h,),
                              Row(children: [
                                Text("說明:",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        color: Color(0xff555555))),
                              ],),
                              Row(children: [
                                Expanded(child:
                                Text("${eXCUSED.NOTE}",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        color: Colors.blue))),
                              ],),
                              Container(height: 5.h,),
                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                              Container(height: 5.h,),
                              Row(children: [
                                Expanded(child:
                                Text("家長簽名",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        color: Color(0xff555555)))),
                              ],),
                              Container(width: ScreenUtil().screenWidth,height: 200.h,child: Image.network(eXCUSED.SING_LINK),),
                              Container(height: 5.h,),
                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                              Container(height: 5.h,),
                              Row(children: [
                                Text("確認者:",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                        color: Color(0xff555555))),
                                Container(width: 5.w,),
                                Text("${teacher_name}",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                        color: Colors.blue)),
                                Expanded(child: Container()),

                                Text("確認:",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                        color: Color(0xff555555))),
                                Container(width: 5.w,),
                                Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5.w),
                                    ),
                                    //width: 80.w,
                                    height: 36.h,
                                    child:(eXCUSED.CFM_ITEM_selectedValue.CFM_NO.isEmpty)?Container():
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton2<CFM_ITEM>(
                                        isExpanded: true,
                                        items: CFM_ITEM_list
                                            .map((CFM_ITEM item) => DropdownMenuItem<CFM_ITEM>(
                                          value: item,
                                          child: Text(
                                            item.CFM_NM,
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color:Colors.blue,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                            .toList(),
                                        value: eXCUSED.CFM_ITEM_selectedValue,
                                        onChanged: (value) {

                                          setState(() {
                                            eXCUSED.CFM_ITEM_selectedValue = value!;
                                          });
                                        },
                                        buttonStyleData:  ButtonStyleData(
                                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                                          height: 40.h,
                                          width: 110.w,
                                        ),
                                        menuItemStyleData: MenuItemStyleData(
                                          height: 40.h,
                                          padding: EdgeInsets.only(left: 14.w, right: 14.w),
                                        ),
                                      ),
                                    )),

                                Container(width: 5.w,),
                                /*
                                                    Text((_CFM_ITEM==null)?"":"${_CFM_ITEM.CFM_NM}",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Colors.blue)),

                                                     */
                              ],),
                              Container(height: 5.h,),
                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                              Container(height: 5.h,),
                              Row(children: [
                                Text("確認日期時間:",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                        color: Color(0xff555555))),
                                Container(width: 5.w,),
                                Text((eXCUSED.CFM_DT.isEmpty)?"":"${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(eXCUSED.CFM_DT))}",
                                    maxLines: null,
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14.sp,
                                        color: Colors.blue)),
                              ],),
                              Container(height: 5.h,),
                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                              Container(height: 5.h,),
                              Container(
                                  padding: EdgeInsets.only( left:0.w,right: 0.w),
                                  width: ScreenUtil().screenWidth,
                                  height: 55.h,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(Color(0xff48C2BC)),
                                        surfaceTintColor: MaterialStateProperty.all(Color(0xff48C2BC)),
                                        padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(28.w),
                                                side: BorderSide(color: Color(0xff555555))
                                            )
                                        )
                                    ),
                                    onPressed: () async{


                                      write_EXCUSED_db_sub(
                                          NO:"${eXCUSED.NO}",
                                          CS_NO:"${eXCUSED.CS_NO}",
                                          CFM_NO:eXCUSED.CFM_ITEM_selectedValue.CFM_NO,
                                          CFM_USER:EMPLOYEE_teacher.EMP_NO
                                      );



                                    },
                                    child: Row(children: [
                                      Expanded(child: Container()),
                                      Text('送出', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                                      Expanded(child: Container()),
                                    ],),
                                  )),
                              Container(height: 5.h,),

                            ],),
                        );
                      },
                    );
                  },
                );
                await EXCUSED_db_sub(NO:candidate);
              }
            } catch (e) {
              dev.log("解析日期失敗: $candidate");
            }
          }
        }
      }
    }

     */
    else if (message is types.ImageMessage) {
      showImageViewer(context, message);
    }

    /*
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages[index] = updatedMessage;
          });

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final index =
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages[index]as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages[index] = updatedMessage;
          });
        }
      }

      await OpenFilex.open(localPath);
    }

     */
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    setState(() {
      final messages = EMPLOYEE_teacher
          .Teacher_CUSTOMER_selectedValue
          .cUSTOMERs[sel_chat_index]
          .messages
          .map((m) {
        if (m.id == message.id && m is types.TextMessage) {
          return m.copyWith(previewData: previewData);
        }
        return m;
      }).toList();

      EMPLOYEE_teacher
          .Teacher_CUSTOMER_selectedValue
          .cUSTOMERs[sel_chat_index]
          .messages = messages;
    });
    /*
    final index = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );
    setState(() {
      EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages[index] = updatedMessage;
    });

     */
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );


    //_addMessage(textMessage);
  }

  Future<void> _loadMessages({int index=0}) async {

    /*
    String response = await rootBundle.loadString('assets/file/messages.json');
    response = response.replaceAll("XXX", (_eMPLOYEEs.length==0)?"":"${_eMPLOYEEs[0].EMP_NM}");
    response = response.replaceAll("YYY", "老師");
    final messages = (jsonDecode(response) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _messages = messages;
    });

     */
    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_data_list.clear();
    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages.clear();
    DateTime datetime = DateTime.now();
    //String comm = "SELECT * FROM MSDL2 WHERE (ChatID='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID}') AND (CreatedAt BETWEEN '${DateFormat("yyyy-MM-dd hh:mm:ss").format(datetime.subtract(Duration(days: 2)))}' AND '${DateFormat("yyyy-MM-dd hh:mm:ss").format(datetime.subtract(Duration(days: 0)))}')";
    //String comm = "SELECT TOP 10 * FROM MSDL2 WHERE (ChatID='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID}') ORDER BY MessageID DESC";
    String comm = '''SELECT TOP 10 *
FROM MSDL2
WHERE ChatID = '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID}'
ORDER BY CreatedAt DESC''';
    dev.log("${comm}");
    String result = await sql_command("${comm}");
    SmartDialog.dismiss();
    try{
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      data_list = trim_proc(data_list);

      data_list.sort((a,b) => a['CreatedAt'].compareTo(b['CreatedAt']));


      //確認群組的訊息狀態未讀數量
      dev.log("確認群組的訊息狀態未讀數量");
      EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_count=0;
      EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_data_list.clear();
      for(int i=0;i<data_list.length;i++){
        List<dynamic> MSRS_data_list = await check_MSRS_Status_sub(
            ChatID:'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID}',
            MessageID:data_list[i]["MessageID"].trim(),
            AuthorID:EMPLOYEE_teacher.ACCOUNT,
            Status:"non_seen"
        );
        if(MSRS_data_list.isNotEmpty){
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_count+=MSRS_data_list.length;
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_data_list.add(MSRS_data_list[0]);
        }
      }
      dev.log("unread_count:${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_count}");
      setState(() {

      });

      for(int i=0;i<data_list.length;i++){
        dev.log("Type:${data_list[i]["Type"]}");
        dev.log("AuthorID:${data_list[i]["AuthorID"]}");
        dev.log("_user.id:${_user.id}");

        //檢查每則訊息的已讀狀態
        int is_read_count = 0;
        List<dynamic> MSRS_data_list = await check_MSRS_Status_sub(
          ChatID:'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID}',
          MessageID:data_list[i]["MessageID"].trim(),
        );
        for(int j=0;j<MSRS_data_list.length;j++){
          if("${MSRS_data_list[j]["Status"]}"=="seen"){
            is_read_count+=1;
          }
        }
        dev.log("is_read_count:${is_read_count}");

        if("${data_list[i]["Type"]}".trim()=="text"){

          var textMessage = types.TextMessage(
            author: types.User(
              id: "${data_list[i]["AuthorID"]}".trim(),//Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
              lastName:'',
              firstName: "${data_list[i]["AuthorFirstName"]}".trim(),
            ),
            createdAt: (DateTime.parse(data_list[i]["CreatedAt"].trim()).subtract(Duration(hours: (Platform.isIOS)?0:0)).millisecondsSinceEpoch).toInt(),
            id: data_list[i]["MessageID"].trim(),
            text: data_list[i]["Text"].trim(),
            status: is_read_count<=0?null:types.Status.seen,
            metadata: {
              'is_read_count': '${is_read_count}',
              'text':data_list[i]["Text"].trim(),
              'type':'文字',
              'ChatID':'${data_list[i]["ChatID"]}'
            },
          );
          _addMessage2(textMessage,index:index);
        }
        else if("${data_list[i]["Type"]}".trim()=="image"){

          String resourceUri = "${data_list[i]["ResourceUri"]}".trim();
          if(resourceUri.isNotEmpty){
            String _LINK = resourceUri.replaceAll("~/", "");
            resourceUri = "${IMAGE_IP}/${_LINK}";
          }

          final message = types.ImageMessage(
              author: types.User(
                id: "${data_list[i]["AuthorID"]}".trim(),//Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
                lastName:'',
                firstName: "${data_list[i]["AuthorFirstName"]}".trim(),
              ),
              createdAt: (DateTime.parse(data_list[i]["CreatedAt"].trim()).subtract(Duration(hours: (Platform.isIOS)?0:0)).millisecondsSinceEpoch).toInt(),
              height: double.parse("${data_list[i]["ImageHeight"]}".trim()),
              id: "${data_list[i]["MessageID"]}".trim(),
              name: "${data_list[i]["ResourceUri"]}".trim(),
              size: int.parse("${data_list[i]["ResourceSize"]}".trim().contains("null")?"100":"${data_list[i]["ResourceSize"]}".trim()),
              uri: resourceUri,
              width: double.parse("${data_list[i]["ImageWidth"]}".trim()),
              status: is_read_count<=0?null:types.Status.seen,
              metadata: {
                'type':'圖片',
                'is_read_count': '${is_read_count}',
                'name':"${data_list[i]["ResourceUri"]}".trim(),
                'height':double.parse("${data_list[i]["ImageHeight"]}".trim()),
                'width':double.parse("${data_list[i]["ImageWidth"]}".trim()),
                'uri': resourceUri,
                'size': int.parse("${data_list[i]["ResourceSize"]}".trim().contains("null")?"100":"${data_list[i]["ResourceSize"]}".trim()),
                'ChatID':'${data_list[i]["ChatID"]}'
              },
          );

          _addMessage2(message,index:index);

        }



        /*
        if("${data_list[i]["AuthorID"]}".trim()=="${_user.id}".trim()){
          dev.log("家長");
          //家長
          if("${data_list[i]["Type"]}"=="text"){

            var textMessage = types.TextMessage(
              author: types.User(
                id: "${data_list[i]["AuthorID"]}".trim(),//Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
                lastName:'',
                firstName: "${data_list[i]["AuthorFirstName"]}".trim(),
              ),
              createdAt: (DateTime.parse(data_list[i]["CreatedAt"]).subtract(Duration(hours: (Platform.isIOS)?8:0)).millisecondsSinceEpoch).toInt(),
              id: data_list[i]["MessageID"],
              text: data_list[i]["Text"],
            );
            _addMessage(textMessage);
          }
          else if("${data_list[i]["Type"]}"=="image"){

            String resourceUri = "${data_list[i]["ResourceUri"]}";
            if(resourceUri.isNotEmpty){
              String _LINK = resourceUri.replaceAll("~/", "");
              resourceUri = "${IMAGE_IP}/${_LINK}";
            }

            final message = types.ImageMessage(
              author: types.User(
                id: "${data_list[i]["AuthorID"]}".trim(),//Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
                lastName:'',
                firstName: "${data_list[i]["AuthorFirstName"]}".trim(),
              ),
              createdAt: (DateTime.parse(data_list[i]["CreatedAt"]).subtract(Duration(hours: (Platform.isIOS)?8:0)).millisecondsSinceEpoch).toInt(),
              height: double.parse("${data_list[i]["ImageHeight"]}"),
              id: "${data_list[i]["MessageID"]}",
              name: "${data_list[i]["ResourceUri"]}",
              size: int.parse("${data_list[i]["ResourceSize"]}".contains("null")?"100":"${data_list[i]["ResourceSize"]}"),
              uri: resourceUri,
              width: double.parse("${data_list[i]["ImageWidth"]}"),
            );

            _addMessage(message);

          }

        }
        else{

          dev.log("老師");
          if("${data_list[i]["Type"]}"=="text"){

            var textMessage = types.TextMessage(
              author: _user,
              createdAt: (DateTime.parse(data_list[i]["CreatedAt"]).subtract(Duration(hours: (Platform.isIOS)?8:0)).millisecondsSinceEpoch).toInt(),
              id: data_list[i]["MessageID"],
              text: data_list[i]["Text"],
            );
            _addMessage(textMessage);
          }
          else if("${data_list[i]["Type"]}"=="image"){

            String resourceUri = "${data_list[i]["ResourceUri"]}";
            if(resourceUri.isNotEmpty){
              String _LINK = resourceUri.replaceAll("~/", "");
              resourceUri = "${IMAGE_IP}/${_LINK}";
            }

            final message = types.ImageMessage(
              author: _user,
              createdAt: (DateTime.parse(data_list[i]["CreatedAt"]).subtract(Duration(hours: (Platform.isIOS)?8:0)).millisecondsSinceEpoch).toInt(),
              height: double.parse("${data_list[i]["ImageHeight"]}"),
              id: "${data_list[i]["MessageID"]}",
              name: "${data_list[i]["ResourceUri"]}",
              size: int.parse("${data_list[i]["ResourceSize"]}".contains("null")?"100":"${data_list[i]["ResourceSize"]}"),
              uri: resourceUri,
              width: double.parse("${data_list[i]["ImageWidth"]}"),
            );

            _addMessage(message);

          }

        }

         */


      }

      setState(() {

      });


    }
    catch(e){
      dev.log(">>>${e}");
      //SmartDialog.showToast("網路異常");
    }

  }

  Future<List<dynamic>> check_MSRS_Status_sub({
    String ChatID="",
    String MessageID="",
    String AuthorID="",
    String Status="",
})async{

    String comm = "SELECT * FROM MSRS WHERE (ChatID='${ChatID}') AND (MessageID='${MessageID}')";
    if(AuthorID.isNotEmpty && Status.isNotEmpty){
      comm = "SELECT * FROM MSRS WHERE (ChatID='${ChatID}') AND (MessageID='${MessageID}') AND AuthorID='${AuthorID}' AND Status='${Status}'";
    }

    //dev.log("${comm}");
    String result = await sql_command("${comm}");
    //SmartDialog.dismiss();
    List<dynamic> data_list = [];
    try {
      List<dynamic> list = jsonDecode(result);
      if (Platform.isAndroid) {
        data_list = list;
      }
      else if (Platform.isIOS) {
        data_list = list;
      }
      data_list = trim_proc(data_list);
    }
    catch(e){
      data_list = [];
    }
    return data_list;
  }



  Future<void> update_MSRS_by_Status_sub(
      {
        String AuthorID="",
        String MessageID="",
        String ChatID=""
      }) async {

    String comm = "UPDATE MSRS SET Status='seen' WHERE ChatID='${ChatID}' AND MessageID='${MessageID}' AND AuthorID='${AuthorID}'";
    //dev.log("${comm}");
    String result = await sql_command("${comm}");
    SmartDialog.dismiss();
    try{

      /*
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      data_list = trim_proc(data_list);

       */

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }


  Future<types.PreviewData?> generatePreviewData(String url) async {
    final data = await MetadataFetch.extract(url);
    if (data == null) return null;

    String? fullImageUrl;
    if (data.image != null) {
      // 如果是相對路徑，就補上 host
      if (data.image!.startsWith('/')) {
        final uri = Uri.parse(url);
        fullImageUrl = '${uri.scheme}://${uri.host}${data.image}';
      } else {
        fullImageUrl = data.image;
      }
    }

    return types.PreviewData(
      title: data.title,
      description: data.description,
      link: url,
      image: fullImageUrl != null ? types.PreviewDataImage(url: fullImageUrl,width: 100.w,height: 20.h) : null,
    );
  }


  /*
  回頭持續檢查訊息是否已讀
   */
  Future<void> check_all_message_is_seen_sub({int index=0})async{

    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages.length;i++){
      if( int.parse("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["is_read_count"]}") < EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].cLASS_NO_for_teacher.length){

        int is_read_count = 0;
        List<dynamic> MSRS_data_list = await check_MSRS_Status_sub(
          ChatID:'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID}',
          MessageID:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].id}",
        );
        for(int j=0;j<MSRS_data_list.length;j++){
          if("${MSRS_data_list[j]["Status"]}"=="seen"){
            is_read_count+=1;
          }
        }

        if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].type==types.MessageType.text){

          var currentMessage = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i];

          if (currentMessage is types.TextMessage) {
            var textMessage = types.TextMessage(
              author: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].author,
              createdAt: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].createdAt,
              id: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].id,
              text: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["text"],
              status: is_read_count<=0?null:types.Status.seen,
              metadata: {
                'is_read_count': '${is_read_count}',
                'text':EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["text"],
                'type':'文字',
                'ChatID':EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["ChatID"],
              },
              // 只有 TextMessage 才有 previewData
              previewData: currentMessage.previewData,
            );



            final uriRegExp = RegExp(r'https?:\/\/[^\s]+');
            final match = uriRegExp.firstMatch(textMessage.text);
            if (match != null) {
              if(textMessage.previewData == null){
                final url = match.group(0)!;
                final preview = await generatePreviewData(url);
                if (preview != null) {
                  final previewed = textMessage.copyWith(previewData: preview);
                  EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i] = previewed;
                }
              }
              else{
                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i] = textMessage;
              }
            }
            else{
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i] = textMessage;
            }

          }



        }
        else if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].type==types.MessageType.image){

          final message = types.ImageMessage(
            author: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].author,
            createdAt: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].createdAt,
            id: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].id,
            height: double.parse("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["height"]}".trim()),
            name: "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["name"]}".trim(),
            size: int.parse("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["size"]}".trim()),
            uri: "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["uri"]}".trim(),
            width: double.parse("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["width"]}".trim()),
            status: is_read_count<=0?null:types.Status.seen,
            metadata: {
              'type':'圖片',
              'is_read_count': '${is_read_count}',
              'name':"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["name"]}".trim(),
              'height':double.parse("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["height"]}".trim()),
              'width':double.parse("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["width"]}".trim()),
              'uri': "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["uri"]}".trim(),
              'size': int.parse("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["size"]}".trim()),
              'ChatID':EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i].metadata!["ChatID"],
            },
          );

          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[i] = message;

        }

      }
    }
  }

  Future<void> read_message_sub({int index=0}) async {

    DateTime datetime = DateTime.now();
    //String comm = "SELECT * FROM MSDL2 WHERE (ChatID='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID}') AND (CreatedAt BETWEEN '${DateFormat("yyyy-MM-dd HH:mm:ss").format(datetime.subtract(Duration(minutes: 30)))}' AND '${DateFormat("yyyy-MM-dd").format(datetime)} 23:59:59')";
    String comm = '''SELECT TOP 10 *
FROM MSDL2
WHERE ChatID = '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID}'
ORDER BY CreatedAt DESC''';
    //dev.log("${comm}");
    String result = await sql_command("${comm}");
    SmartDialog.dismiss();
    try{
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      data_list = trim_proc(data_list);
      List<dynamic> data_list2 = [];
      bool check = false;
      for(int i=0;i<data_list.length;i++){
        check = false;
        for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages.length;j++){
          if(data_list[i]["MessageID"].trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[j].id){
            check = true;
            break;
          }
        }
        if(check==false){
          data_list2.add(data_list[i]);
        }
      }

      dev.log("data_list2.lengt:${data_list2.length}");

      for(int i=0;i<data_list2.length;i++){

        dev.log("Type:${data_list2[i]["Type"]}");
        dev.log("AuthorID:${data_list2[i]["AuthorID"]}");
        dev.log("_user.id:${_user.id}");


        //檢查每則訊息的已讀狀態
        int is_read_count = 0;
        List<dynamic> MSRS_data_list = await check_MSRS_Status_sub(
          ChatID:'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID}',
          MessageID:data_list2[i]["MessageID"].trim(),
        );
        for(int j=0;j<MSRS_data_list.length;j++){
          if("${MSRS_data_list[j]["Status"]}"=="seen"){
            is_read_count+=1;
          }
        }
        dev.log("is_read_count:${is_read_count}");

        if("${data_list2[i]["Type"]}".trim()=="text"){

          var textMessage = types.TextMessage(
            author: types.User(
              id: "${data_list2[i]["AuthorID"]}".trim(),//Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
              lastName:'',
              firstName: "${data_list2[i]["AuthorFirstName"]}".trim(),
            ),
            createdAt: (DateTime.parse(data_list2[i]["CreatedAt"].trim()).subtract(Duration(hours: (Platform.isIOS)?0:0)).millisecondsSinceEpoch).toInt(),
            id: data_list2[i]["MessageID"].trim(),
            text: data_list2[i]["Text"].trim(),
            status: is_read_count<=0?null:types.Status.seen,
            metadata: {
              'is_read_count': '${is_read_count}',
              'text':data_list2[i]["Text"].trim(),
              'type':'文字',
              'ChatID':'${data_list2[i]["ChatID"]}'
            },
          );
          _addMessage(textMessage,index: index);
        }
        else if("${data_list2[i]["Type"]}".trim()=="image"){

          String resourceUri = "${data_list2[i]["ResourceUri"]}";
          if(resourceUri.isNotEmpty){
            String _LINK = resourceUri.replaceAll("~/", "");
            resourceUri = "${IMAGE_IP}/${_LINK}";
          }

          final message = types.ImageMessage(
            author: types.User(
              id: "${data_list2[i]["AuthorID"]}".trim(),//Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
              lastName:'',
              firstName: "${data_list2[i]["AuthorFirstName"]}".trim(),
            ),
            createdAt: (DateTime.parse(data_list2[i]["CreatedAt"].trim()).subtract(Duration(hours: (Platform.isIOS)?0:0)).millisecondsSinceEpoch).toInt(),
            height: double.parse("${data_list2[i]["ImageHeight"]}".trim()),
            id: "${data_list2[i]["MessageID"]}".trim(),
            name: "${data_list2[i]["ResourceUri"]}".trim(),
            size: int.parse("${data_list2[i]["ResourceSize"]}".trim().contains("null")?"100":"${data_list2[i]["ResourceSize"]}".trim()),
            uri: resourceUri,
            width: double.parse("${data_list2[i]["ImageWidth"]}".trim()),
            status: is_read_count<=0?null:types.Status.seen,
            metadata: {
              'type':'圖片',
              'is_read_count': '${is_read_count}',
              'name':"${data_list2[i]["ResourceUri"]}".trim(),
              'height':double.parse("${data_list2[i]["ImageHeight"]}".trim()),
              'width':double.parse("${data_list2[i]["ImageWidth"]}".trim()),
              'uri': resourceUri,
              'size': int.parse("${data_list2[i]["ResourceSize"]}".trim().contains("null")?"100":"${data_list2[i]["ResourceSize"]}".trim()),
              'ChatID':'${data_list2[i]["ChatID"]}'
            },
          );

          _addMessage(message,index: index);

        }

      }

      //把未讀狀態改為已讀
      for(int i=0;i<data_list2.length;i++){
        await update_MSRS_by_Status_sub(
            AuthorID:EMPLOYEE_teacher.ACCOUNT,
            MessageID:data_list2[i]["MessageID"].trim(),
            ChatID:'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID}',
        );
      }

      setState(() {

      });



    }
    catch(e){
      dev.log(">>${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }

  Future<void> read_message_sub2({int index=0}) async {

    DateTime datetime = DateTime.now();
    //String comm = "SELECT * FROM MSDL2 WHERE (ChatID='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID}') AND (CreatedAt BETWEEN '${DateFormat("yyyy-MM-dd HH:mm:ss").format(datetime.subtract(Duration(days: 1)))}' AND '${DateFormat("yyyy-MM-dd HH:mm:ss").format(datetime)}')";
    String comm = '''SELECT TOP 10 *
FROM MSDL2
WHERE ChatID = '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID}'
 ORDER BY CreatedAt DESC''';
    dev.log("${comm}");
    String result = await sql_command("${comm}");
    //SmartDialog.dismiss();
    try{
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      data_list = trim_proc(data_list);
      List<dynamic> data_list2 = [];
      bool check = false;

      for(int i=0;i<data_list.length;i++){
        check = false;
        for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages.length;j++){
          if(data_list[i]["MessageID"].trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[j].id){
            check = true;
            break;
          }
        }
        if(check==false){
          data_list2.add(data_list[i]);
        }
      }

      for(int i=0;i<data_list2.length;i++){

        dev.log("Type:${data_list2[i]["Type"]}");
        dev.log("AuthorID:${data_list2[i]["AuthorID"]}");
        dev.log("_user.id:${_user.id}");


        //檢查每則訊息的已讀狀態
        int is_read_count = 0;
        List<dynamic> MSRS_data_list = await check_MSRS_Status_sub(
          ChatID:'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID}',
          MessageID:data_list2[i]["MessageID"].trim(),
        );
        for(int j=0;j<MSRS_data_list.length;j++){
          if("${MSRS_data_list[j]["Status"]}"=="seen"){
            is_read_count+=1;
          }
        }
        dev.log("is_read_count:${is_read_count}");

        if("${data_list2[i]["Type"]}".trim()=="text"){

          var textMessage = types.TextMessage(
            author: types.User(
              id: "${data_list2[i]["AuthorID"]}".trim(),//Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
              lastName:'',
              firstName: "${data_list2[i]["AuthorFirstName"]}".trim(),
            ),
            createdAt: (DateTime.parse(data_list2[i]["CreatedAt"].trim()).subtract(Duration(hours: (Platform.isIOS)?0:0)).millisecondsSinceEpoch).toInt(),
            id: data_list2[i]["MessageID"].trim(),
            text: data_list2[i]["Text"].trim(),
            status: is_read_count<=0?null:types.Status.seen,
            metadata: {
              'is_read_count': '${is_read_count}',
              'text':data_list2[i]["Text"].trim(),
              'type':'文字',
              'ChatID':'${data_list2[i]["ChatID"]}'
            },
          );
          _addMessage(textMessage,index: index);
        }
        else if("${data_list2[i]["Type"]}".trim()=="image"){

          String resourceUri = "${data_list2[i]["ResourceUri"]}";
          if(resourceUri.isNotEmpty){
            String _LINK = resourceUri.replaceAll("~/", "");
            resourceUri = "${IMAGE_IP}/${_LINK}";
          }

          final message = types.ImageMessage(
            author: types.User(
              id: "${data_list2[i]["AuthorID"]}".trim(),//Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
              lastName:'',
              firstName: "${data_list2[i]["AuthorFirstName"]}".trim(),
            ),
            createdAt: (DateTime.parse(data_list2[i]["CreatedAt"].trim()).subtract(Duration(hours: (Platform.isIOS)?0:0)).millisecondsSinceEpoch).toInt(),
            height: double.parse("${data_list2[i]["ImageHeight"]}".trim()),
            id: "${data_list2[i]["MessageID"]}".trim(),
            name: "${data_list2[i]["ResourceUri"]}".trim(),
            size: int.parse("${data_list2[i]["ResourceSize"]}".trim().contains("null")?"100":"${data_list2[i]["ResourceSize"]}".trim()),
            uri: resourceUri,
            width: double.parse("${data_list2[i]["ImageWidth"]}".trim()),
            status: is_read_count<=0?null:types.Status.seen,
            metadata: {
              'type':'圖片',
              'is_read_count': '${is_read_count}',
              'name':"${data_list2[i]["ResourceUri"]}".trim(),
              'height':double.parse("${data_list2[i]["ImageHeight"]}".trim()),
              'width':double.parse("${data_list2[i]["ImageWidth"]}".trim()),
              'uri': resourceUri,
              'size': int.parse("${data_list2[i]["ResourceSize"]}".trim().contains("null")?"100":"${data_list2[i]["ResourceSize"]}".trim()),
              'ChatID':'${data_list2[i]["ChatID"]}'
            },
          );

          _addMessage(message,index: index);

        }

      }


      //確認群組的訊息狀態未讀數量
      dev.log("確認群組的訊息狀態未讀數量:${data_list2.length}");
      //EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_count=0;
      //EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_data_list.clear();
      for(int i=0;i<data_list2.length;i++){

        List<dynamic> MSRS_data_list = await check_MSRS_Status_sub(
            ChatID:'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].ChatID}',
            MessageID:data_list2[i]["MessageID"].trim(),
            AuthorID:EMPLOYEE_teacher.ACCOUNT,
            Status:"non_seen"
        );
        if(MSRS_data_list.isNotEmpty){
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_count+=MSRS_data_list.length;
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_data_list.add(MSRS_data_list[0]);
        }
      }

      setState(() {

      });

    }
    catch(e){
      dev.log(">>${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }


  /*
  Future<void> update_MSDL_by_Status_sub(dynamic msdl) async {

    String comm = "UPDATE MSDL SET Status='seen' WHERE ChatID='${msdl["ChatID"]}' AND MessageID='${msdl["MessageID"]}'";
    dev.log("${comm}");
    String result = await sql_command("${comm}");
    SmartDialog.dismiss();
    try{
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      data_list = trim_proc(data_list);
    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }

   */

  // For the testing purposes, you should probably use https://pub.dev/packages/uuid.
  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }


  bool isNowInRange(TimeOfDay start, TimeOfDay end) {
    final now = TimeOfDay.fromDateTime(DateTime.now());

    // 轉成分鐘比較
    int nowMinutes = now.hour * 60 + now.minute;
    int startMinutes = start.hour * 60 + start.minute;
    int endMinutes = end.hour * 60 + end.minute;

    return nowMinutes >= startMinutes && nowMinutes <= endMinutes;
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final dt = DateTime(0, 0, 0, tod.hour, tod.minute);
    return DateFormat("HH:mm").format(dt);
  }

  String decodeUnicode(String input) {
    //  regex find all unicode escape sequences dạng \\u{xxxx}
    final RegExp regex = RegExp(r'\\u\{([A-Fa-f0-9]+)\}');

    // replace unicode sequenc
    return input.replaceAllMapped(regex, (match) {
      final hexCode = match.group(1);
      if (hexCode != null) {
        // convert from hex to character code
        final emoji = String.fromCharCode(int.parse(hexCode, radix: 16));
        return emoji;
      }
      return match.group(0)!;
    });
  }

  Future<void> insert_MSDL2_db_sub({String message=""})async{

    DateTime dateTime = DateTime.now();
    String MessageID = "${dateTime.millisecondsSinceEpoch}";
    String AuthorID = _user.id;
    String AuthorFirstName=_user.firstName!;
    String AuthorLastName="";
    String CreatedAt="${DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)}";
    String Type="text";

    //處理群組多人已讀未讀狀態
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher.length;i++){
      if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher[i].ACCOUNT!=EMPLOYEE_teacher.ACCOUNT) {
        String ACCOUNT = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher[i].ACCOUNT.trim();
        String comm = "INSERT INTO MSRS(ChatID,MessageID,AuthorID,Status) VALUES ('${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID}','${MessageID}','${ACCOUNT}','non_seen')";
        dev.log("${comm}");
        String result = await sql_command("${comm}");
        dev.log("result:${result}");
      }
    }

    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs.length;i++){
      String ACCOUNT = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs[i]!.ACCOUNT.trim();
      String comm = "INSERT INTO MSRS(ChatID,MessageID,AuthorID,Status) VALUES ('${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID}','${MessageID}','${ACCOUNT}','non_seen')";
      dev.log("${comm}");
      String result = await sql_command("${comm}");
      dev.log("result:${result}");
    }


    String Status="";
    //String Status="non_seen";

    String Text=message;


    var textMessage = types.TextMessage(
        author: _user,
        createdAt: (dateTime.millisecondsSinceEpoch).toInt(),
        id: MessageID,
        text: message,
    );

    String comm = "INSERT INTO MSDL2(ChatID,MessageID,AuthorID,AuthorFirstName,AuthorLastName,CreatedAt,Type,Status,Text) VALUES ('${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID}','${MessageID}','${AuthorID}','${AuthorFirstName}','${AuthorLastName}','${CreatedAt}','${Type}','${Status}','${Text}')";
    dev.log("${comm}");
    String result = await sql_command("${comm}");

    try{
      if(result.contains("執行成功")){

      }
      else{

      }
      /*
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      data_list = trim_proc(data_list);

       */
      //_addMessage(textMessage);
      message_TextEditingController.text="";
      setState(() {

      });

      read_message_sub(index:sel_chat_index);

      //先檢查該校使用時間才可送出
      String comm = "SELECT * FROM AVAILABILITY_TIME_SETTING WHERE DEPM_NO = '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].DEPM_NO}'";
      dev.log("${comm}");

      result = await sql_command("${comm}");
      dev.log("result:${result}");
      //[{"DEPM_NO":"4101","START_TIME":"07:00:00","END_TIME":"21:00:00","GOHOME_START_TIME":"16:00:00.0000000","GOHOME_END_TIME":"18:00:00.0000000"}]
      List<dynamic> maps = jsonDecode(result);
      if(maps.isNotEmpty){

        // 轉成 TimeOfDay
        // HH:mm:ss.SSSSSSS 格式解析 16:00:00.0000000
        DateFormat format = DateFormat("HH:mm:ss");
        DateTime parsed_start = format.parse(maps[0]["START_TIME"]);
        DateTime parsed_end = format.parse(maps[0]["END_TIME"]);
        TimeOfDay START_TIME = TimeOfDay(hour: parsed_start.hour, minute: parsed_start.minute);
        TimeOfDay END_TIME = TimeOfDay(hour: parsed_end.hour, minute: parsed_end.minute);

        if (isNowInRange(START_TIME, END_TIME)) {
          for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs.length;i++){
            String FCM = await search_CUSTOMER_DL_fcm_sub(ACCOUNT:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs[i]!.ACCOUNT);
            await sendPushNotification(
                title: "老師",
                message: message,
                token: FCM,//EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs[i]!.FCM,
                ChatID:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID.trim(),
                UserAccount: '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs[i]!.ACCOUNT}',
                TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}"
            );
          }

          for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher.length;i++){
            String FCM = await search_EMPLOYEE_fcm_sub(ACCOUNT:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher[i].ACCOUNT);
            if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher[i].ACCOUNT!=EMPLOYEE_teacher.ACCOUNT){
              await sendPushNotification(
                  title: "老師",
                  message: message,
                  token: FCM,//EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher[i].FCM,
                  ChatID:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID.trim(),
                  UserAccount: '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher[i].ACCOUNT}',
                  TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}"
              );
            }
          }

        }

      }





    }
    catch(e){
      dev.log("${e}");
    }

  }

  void _handleImageSelection() async {

    final result = await ImagePicker().pickImage(
      imageQuality: 40,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      DateTime dateTime = DateTime.now();
      String MessageID = "${dateTime.millisecondsSinceEpoch}";
      String AuthorID = _user.id;
      String AuthorFirstName=_user.firstName!;
      String AuthorLastName="";
      String CreatedAt="${DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)}";
      String Type="image";

      //處理群組多人已讀未讀狀態
      Map<String,String> Status_list = {};
      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher.length;i++){
        if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher[i].ACCOUNT!=EMPLOYEE_teacher.ACCOUNT) {
          String ACCOUNT = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher[i].ACCOUNT.trim();
          String comm = "INSERT INTO MSRS(ChatID,MessageID,AuthorID,Status) VALUES ('${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID}','${MessageID}','${ACCOUNT}','non_seen')";
          dev.log("${comm}");
          String result2 = await sql_command("${comm}");
          dev.log("result2:${result2}");
        }
      }

      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs.length;i++){
        String ACCOUNT = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs[i]!.ACCOUNT.trim();
        String comm = "INSERT INTO MSRS(ChatID,MessageID,AuthorID,Status) VALUES ('${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID}','${MessageID}','${ACCOUNT}','non_seen')";
        dev.log("${comm}");
        String result2 = await sql_command("${comm}");
        dev.log("result2:${result2}");
      }

      String Status="";

      String ResourceName=result.name;
      int ImageHeight=image.height;
      int ImageWidth=image.width;
      int ResourceSize = bytes.length;
      String? MimeType = lookupMimeType(result.path);
      String file_name = "${AuthorID}_${DateFormat('yyyyMMddHHmmss').format(dateTime)}";
      String ResourceUri = "~/School/Images/Chat/${file_name}.jpg";//簽名

      final message = types.ImageMessage(
        author: _user,
        createdAt: dateTime.millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: "${dateTime.millisecondsSinceEpoch}",
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );


      await upload_image(img: bytes,file_name: file_name,folder: "Chat");

      String comm = "INSERT INTO MSDL2(ChatID,MessageID,AuthorID,AuthorFirstName,AuthorLastName,CreatedAt,Type,Status,ResourceName,ImageHeight,ImageWidth,MimeType,ResourceUri,ResourceSize) VALUES ('${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID}','${MessageID}','${AuthorID}','${AuthorFirstName}','${AuthorLastName}','${CreatedAt}','${Type}','${Status}','${ResourceName}','${ImageHeight}','${ImageWidth}','${MimeType}','${ResourceUri}','${ResourceSize}')";
      dev.log("${comm}");
      String _result = await sql_command("${comm}");

      try{
        if(_result.contains("執行成功")){

        }
        else{

        }
        /*
        List<dynamic> list = jsonDecode(_result);
        List<dynamic> data_list = [];
        if(Platform.isAndroid){
          data_list = list;
        }
        else if(Platform.isIOS){
          data_list = list;
        }
        data_list = trim_proc(data_list);

         */
        //_addMessage(message);
        setState(() {

        });

        read_message_sub(index:sel_chat_index);


        //先檢查該校使用時間才可送出
        String comm = "SELECT * FROM AVAILABILITY_TIME_SETTING WHERE DEPM_NO = '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].DEPM_NO}'";
        dev.log("${comm}");

        String result = await sql_command("${comm}");
        dev.log("result:${result}");
        //[{"DEPM_NO":"4101","START_TIME":"07:00:00","END_TIME":"21:00:00","GOHOME_START_TIME":"16:00:00.0000000","GOHOME_END_TIME":"18:00:00.0000000"}]
        List<dynamic> maps = jsonDecode(result);
        if(maps.isNotEmpty){

          // 轉成 TimeOfDay
          // HH:mm:ss.SSSSSSS 格式解析 16:00:00.0000000
          DateFormat format = DateFormat("HH:mm:ss");
          DateTime parsed_start = format.parse(maps[0]["START_TIME"]);
          DateTime parsed_end = format.parse(maps[0]["END_TIME"]);
          TimeOfDay START_TIME = TimeOfDay(hour: parsed_start.hour, minute: parsed_start.minute);
          TimeOfDay END_TIME = TimeOfDay(hour: parsed_end.hour, minute: parsed_end.minute);

          if (isNowInRange(START_TIME, END_TIME)) {
            for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs.length;i++){
              String FCM = await search_CUSTOMER_DL_fcm_sub(ACCOUNT:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs[i]!.ACCOUNT);
              await sendPushNotification(
                  title: "老師",
                  message: "傳送一張圖片給您",
                  token: FCM,//EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs[i]!.FCM,
                  ChatID:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID.trim(),
                  UserAccount: '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs[i]!.ACCOUNT}',
                  TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}"
              );
            }
            for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher.length;i++){
              if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher[i].ACCOUNT!=EMPLOYEE_teacher.ACCOUNT){
                String FCM = await search_EMPLOYEE_fcm_sub(ACCOUNT:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher[i].ACCOUNT);
                await sendPushNotification(
                    title: "老師",
                    message: "傳送一張圖片給您",
                    token: FCM,//EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher[i].FCM,
                    ChatID:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID.trim(),
                    UserAccount: '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher[i].ACCOUNT}',
                    TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}"
                );
              }
            }
          }

        }



      }
      catch(e){
        dev.log("${e}");
      }

    }
  }


  /// 自訂 customStatusBuilder
  Widget customStatusBuilder(types.Message message, {required BuildContext context}) {
    // 若訊息為我們自訂的 CustomTextMessage，則根據 statuses 渲染狀態圖示
    //dev.log(">>>TextMessage:${message.type},${message.id},${message.metadata}");
    if (message.type==types.MessageType.text) {
      //dev.log(">>>TextMessage");
    }
    return ("${message.metadata!["is_read_count"]}"=="0")?Container():Container(child:Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check,color: Colors.black,size: 10.sp,),
        Text("已讀(${message.metadata!["is_read_count"]})",style: TextStyle(color: Colors.black,fontSize: 10.sp),)
      ],
    ));
    // 非自訂訊息則返回空的 Widget
    //return const SizedBox.shrink();
  }


  Future<void> ENTRUSTED_db_sub({String NO=""})async{
    String result = await sql_command('''
    SELECT * FROM ENTRUSTED WHERE NO='${NO}'
    AND DEPM_NO='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].DEPM_NO}'
         AND CLASS_NO='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].CLASS_NO}'
         AND CS_NO='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].CS_NO}'
    ''');
    SmartDialog.dismiss();
    try{
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      data_list = trim_proc(data_list);
      if(data_list.length==0){
      }
      else{
        for(int i=0;i<data_list.length;i++){
          Entrusted_pick_and_drop b = Entrusted_pick_and_drop();
          b.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
          b.DATE = "${data_list[i]["DATE"]}".contains("null")?"":"${data_list[i]["DATE"]}";
          b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
          b.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}";
          b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}";
          b.NOTE = "${data_list[i]["NOTE"]}".contains("null")?"":"${data_list[i]["NOTE"]}";
          b.AGENT_NM = "${data_list[i]["AGENT_NM"]}".contains("null")?"":"${data_list[i]["AGENT_NM"]}";
          b.AGENT_PHONE = "${data_list[i]["AGENT_PHONE"]}".contains("null")?"":"${data_list[i]["AGENT_PHONE"]}";
          b.RELATION = "${data_list[i]["RELATION"]}".contains("null")?"":"${data_list[i]["RELATION"]}";
          b.ADD_DATE = "${data_list[i]["ADD_DATE"]}".contains("null")?"":"${data_list[i]["ADD_DATE"]}";
          b.DEL = "${data_list[i]["DEL"]}".contains("null")?"":"${data_list[i]["DEL"]}";
          String SIGN_LINK = "${data_list[i]["SIGN_LINK"]}".replaceAll("~/", "");
          b.SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK}";
          b.CFM_USER = "${data_list[i]["CFM_USER"]}".contains("null")?"":"${data_list[i]["CFM_USER"]}";
          b.CFM_DT = "${data_list[i]["CFM_DT"]}".contains("null")?"":"${data_list[i]["CFM_DT"]}";

          b.DATE = DateFormat('yyyy-MM-dd').format(DateTime.parse(b.DATE));
          List<String> list = b.DATE.split("-");
          b.DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[DateTime(int.parse(list[0]),int.parse(list[1]),int.parse(list[2])).weekday-1]})";
          if(b.CFM_DT.isNotEmpty){
            DateTime dateTime = DateTime.parse(b.CFM_DT);
            b.CFM_DT_str = "${DateFormat("yyyy年MM月dd日 HH:mm:ss").format(dateTime)} (${WEEK_DAY[dateTime.weekday-1]})";
          }
          if(b.DEL.isEmpty){
            entrusted_pick_and_drop = b;
          }


        }
      }


      /*
        明細
         */
        await read_for_ENTRUSTED_DL_db_sub(NO:entrusted_pick_and_drop.NO);

    }
    catch(e){
      dev.log("${e}");
    }
  }


  /*
  [托嬰/幼兒] 預約接送明細 ENTRUSTED_DL
   */
  Future<void> read_for_ENTRUSTED_DL_db_sub({String NO="",int index=0})async{
    //await EasyLoading.show(status: "處理中...");

    String result = await sql_command("SELECT * FROM ENTRUSTED_DL WHERE NO='${NO}'");

    SmartDialog.dismiss();
    try{
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      data_list = trim_proc(data_list);
      if(data_list.length==0){
      }
      else{
        for(int i=0;i<data_list.length;i++){
          ENTRUSTED_DL b = ENTRUSTED_DL();
          b.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
          b.SR = "${data_list[i]["SR"]}".contains("null")?"":"${data_list[i]["SR"]}";
          b.TYPE_NO = "${data_list[i]["TYPE_NO"]}".contains("null")?"":"${data_list[i]["TYPE_NO"]}";
          b.TIME = "${data_list[i]["TIME"]}".contains("null")?"":"${data_list[i]["TIME"]}";
          entrusted_pick_and_drop.eNTRUSTED_DL_list.add(b);
        }

        try{
          showDialog_setState(() {

          });
        }
        catch(e){

        }



      }



    }
    catch(e){
      dev.log("${e}");
    }
  }


  /*
  [托嬰/幼兒] 請假 EXCUSED
   */
  Future<void> write_ENTRUSTED_db_sub({String NO="",String CFM_USER="",})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    String datetime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    String result = await sql_command('''UPDATE ENTRUSTED SET CFM_DT='${datetime}', CFM_USER='${CFM_USER}' WHERE NO='${NO}' ''');
    SmartDialog.dismiss();
    try{

      /*
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      dev.log("data_list.length:${data_list.length}");

       */

      SmartDialog.showToast("送出成功");
      await ENTRUSTED_db_sub(NO:entrusted_pick_and_drop.NO);
      setState(() {

      });


    }
    catch(e){
      dev.log("${e}");
      //SmartDialog.showToast("網路異常");
    }
  }



  Future<void> EXCUSED_db_sub({String NO=""})async{

    String result = await sql_command('''
         SELECT * FROM EXCUSED WHERE NO='${NO}' 
         AND DEPM_NO='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].DEPM_NO}'
         AND CLASS_NO='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].CLASS_NO}'
         AND CS_NO='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].CS_NO}'
        ''');
    try{
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      data_list = trim_proc(data_list);
      if(data_list.length==0){
      }
      else{
        for(int i=0;i<data_list.length;i++){
          EXCUSED b = EXCUSED();
          b.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
          b.DATE = "${data_list[i]["DATE"]}".contains("null")?"":"${data_list[i]["DATE"]}";
          b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
          b.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}";
          b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}";
          b.NOTE = "${data_list[i]["NOTE"]}".contains("null")?"":"${data_list[i]["NOTE"]}";
          b.HOURS_NO = "${data_list[i]["HOURS_NO"]}".contains("null")?"":"${data_list[i]["HOURS_NO"]}";
          b.REASON_NO = "${data_list[i]["REASON_NO"]}".contains("null")?"":"${data_list[i]["REASON_NO"]}";
          b.CFM_NO = "${data_list[i]["CFM_NO"]}".contains("null")?"":"${data_list[i]["CFM_NO"]}";
          b.ADD_DATE = "${data_list[i]["ADD_DATE"]}".contains("null")?"":"${data_list[i]["ADD_DATE"]}";
          b.CFM_USER = "${data_list[i]["CFM_USER"]}".contains("null")?"":"${data_list[i]["CFM_USER"]}";
          b.CFM_DT = "${data_list[i]["CFM_DT"]}".contains("null")?"":"${data_list[i]["CFM_DT"]}";
          b.DEL = "${data_list[i]["DEL"]}".contains("null")?"":"${data_list[i]["DEL"]}";
          String SING_LINK = "${data_list[i]["SING_LINK"]}".replaceAll("~/", "");
          b.SING_LINK = "${IMAGE_IP}/${SING_LINK}";

          b.DATE = DateFormat('yyyy-MM-dd').format(DateTime.parse(b.DATE));
          List<String> list = b.DATE.split("-");
          b.DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[DateTime(int.parse(list[0]),int.parse(list[1]),int.parse(list[2])).weekday-1]})";
          //b.CFM_ITEM_selectedValue = CFM_ITEM_list.firstWhere((element) => element.CFM_NO==b.CFM_NO);
          b.CFM_ITEM_selectedValue = CFM_ITEM_list.firstWhere(
                (element) => element.CFM_NO == b.CFM_NO,
            orElse: () => CFM_ITEM(),
          );
          if(b.DEL.isEmpty &&
              b.CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].CS_NO &&
              b.CLASS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].CLASS_NO &&
              b.DEPM_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].DEPM_NO
          ) {
            eXCUSED = b;
          }
        }
      }

      showDialog_setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }
  }


  /*
  [托嬰/幼兒] 請假 EXCUSED
   */
  Future<void> write_EXCUSED_db_sub({String NO="",String CS_NO="",String CFM_NO="",String CFM_USER="",})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    String datetime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    String result = await sql_command('''UPDATE EXCUSED SET CFM_DT='${datetime}', CFM_NO='${CFM_NO}', CFM_USER='${CFM_USER}' WHERE NO='${NO}' AND CS_NO='${CS_NO}' ''');
    SmartDialog.dismiss();
    try{

      /*
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      dev.log("data_list.length:${data_list.length}");

       */

      SmartDialog.showToast("送出成功");
      await EXCUSED_db_sub(NO:eXCUSED.NO);
      setState(() {

      });

      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs.length;i++){
        String FCM = await search_CUSTOMER_DL_fcm_sub(ACCOUNT:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs[i]!.ACCOUNT);
        await sendPushNotification(
            title: "老師",
            message: "老師已將請假委託變更為${eXCUSED.CFM_ITEM_selectedValue.CFM_NM}",
            token: FCM,//EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs[i]!.FCM,
            ChatID:"老師已將請假委託變更為${eXCUSED.CFM_ITEM_selectedValue.CFM_NM}",
            UserAccount: '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs[i]!.ACCOUNT}',
            TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}",
            CS_NO:CS_NO,
            CFM_NO:CFM_NO,
            EXCUSED_NO:NO
        );
      }




    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }


  /*
  跳轉進單一聊天室
   */
  Future<void> goto_chat_sub({int index=0})async{

    //找出對應的index
    final item = cUSTOMERs_for_chats[index];
    final originalIndex = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.indexOf(item);
    if(originalIndex==-1){
      Fluttertoast.showToast(
          msg: "索引不存在",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
    sel_chat_index = originalIndex;

    if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID.isEmpty){
      return;
    }

    MyHomePage2_T_fun5!();

    page=1;
    in_chat = true;
    setState(() {

    });

    //把未讀狀態改為已讀
    String comm = "UPDATE MSRS SET Status='seen' WHERE ChatID='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID}' AND AuthorID='${EMPLOYEE_teacher.ACCOUNT}'";
    //dev.log("${comm}");
    String result = await sql_command("${comm}");
    /*
                  for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_data_list.length;i++){
                    await update_MSRS_by_Status_sub(
                        AuthorID:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_data_list[i]["AuthorID"],
                        MessageID:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_data_list[i]["MessageID"],
                        ChatID:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].unread_data_list[i]["ChatID"]
                    );
                  }

                   */

    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].unread_data_list.clear();
    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].unread_count=0;

    setState(() {

    });


    if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID.isNotEmpty){
      await read_message_sub(index:sel_chat_index);
      await check_all_message_is_seen_sub(index:sel_chat_index);
      await _syncDeletedMessages(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].ChatID);
    }


  }


  @override
  Widget build(BuildContext context) {


    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    //dev.log("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages.length}");

    return GestureDetector(
        onTap: (){
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: PopScope(
        canPop: false,  //It should be false to work
        onPopInvoked : (didPop) {
        if (didPop) {
        return;
        }
        },
        child:(page==0)?
        Container(
            color: Color(0xffFAF7F2),
            padding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 10.w),
            width: ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,child:
        ListView.builder(
          padding: EdgeInsets.only(top: 0.h),
          itemCount:  cUSTOMERs_for_chats.length,
          itemBuilder: (BuildContext context, int index) {

            //顯示最新一筆內容
            String message = "${cUSTOMERs_for_chats[index].last_message}";
            /*
            if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages.length>0) {
              if (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
                  .cUSTOMERs[index].messages[0].metadata!['type'] == "文字") {
                message = "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
                    .cUSTOMERs[index].messages[0].author
                    .firstName} ${EMPLOYEE_teacher
                    .Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].messages[0]
                    .metadata!["text"]}";
              }
              else {
                message = "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue
                    .cUSTOMERs[index].messages[0].author.firstName} 傳送了圖片";
              }
            }

             */


            return
              (cUSTOMERs_for_chats[index].cUSTOMER_DLs.isEmpty)?Container()
                  :
              GestureDetector(
                onTap: ()async{

                  //跳轉進單一聊天室
                  goto_chat_sub(index: index);

                },
                child: badges.Badge(
                    showBadge:'${cUSTOMERs_for_chats[index].unread_count}'=="0"?false:true,
                    position: badges.BadgePosition.topEnd(top: -5.h, end: 0),
                    badgeContent: SizedBox(
                    //width: 20.w, // 固定寬度
                    //height: 20.w, // 固定高度，這邊設跟寬度一樣做成正方形
                    child:Center(child:
                    Text('${cUSTOMERs_for_chats[index].unread_count}',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 12.sp)))),
                    badgeStyle: badges.BadgeStyle(
                      shape: badges.BadgeShape.circle,
                      badgeColor: Colors.red,
                      padding: EdgeInsets.all(6.w),
                      borderRadius: BorderRadius.circular(0),
                      elevation: 0,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(10.w),
                      margin: EdgeInsets.only(bottom: 5.h,top: 5.h),
                      decoration: BoxDecoration(
                          color: Color(0xffFAF7F2),
                          borderRadius: BorderRadius.circular(10.w),
                          border: Border.all(
                            width: 1,
                            color: Color(0xff555555),
                          )),
                      child: Column(children: [

                        /*
                        Row(children: [
                          Text("老師:", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xff555555) , fontSize: 16.sp)),
                        ],),
                        Row(children: [
                          Expanded(child:Wrap(children: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].cLASS_NO_for_teacher.map((item){
                            return Text("${item.EMP_NM}，",textAlign: TextAlign.left, style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.blue , fontSize: 16.sp));
                          }).toList())),
                          Expanded(child: Container()),
                        ],),
                        Container(height: 10.h,),
                        Row(children: [
                          Text("家長:", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xff555555) , fontSize: 16.sp)),
                        ],),
                        Row(children: [
                          Row(children: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].cUSTOMER_DLs.map((item){
                            return Text("${item!.USER_NM}，",textAlign: TextAlign.left, style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.blue , fontSize: 16.sp));
                          }).toList()),
                          Expanded(child: Container()),
                        ],),
                        Container(height: 10.h,),

                         */
                        Row(children: [
                          Text("${cUSTOMERs_for_chats[index].CS_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.blue , fontSize: 20.sp)),
                          Container(width: 5.w,),
                          Column(children: [
                            Container(height: 6.h,),
                            Text("小朋友", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xff555555) , fontSize: 14.sp)),
                          ],),
                          ],),
                        (cUSTOMERs_for_chats[index].ChatID.isEmpty)?
                        Column(children: [
                          Container(height: 5.h,),
                          Container(width: ScreenUtil().screenWidth,child: Text("處理中...",maxLines: 2,overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Colors.black26 , fontSize: 16.sp)),),
                          Container(height: 5.h,),
                        ],)
                            :
                        (message.isEmpty)?Container():
                        Column(children: [
                          Container(height: 5.h,),
                          Container(width: ScreenUtil().screenWidth,child: Text("${message}",maxLines: 2,overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,color: Color(0xff555555) , fontSize: 16.sp)),),
                          Container(height: 5.h,),
                        ],),

                        Row(children: [
                          Container(width: 5.w,),
                          Expanded(child: Container()),
                          Text("進入聊天室", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xff555555) , fontSize: 16.sp)),
                          Icon(Icons.arrow_forward,size: 24.sp,),
                          Container(width: 5.w,),
                        ],),

                      ],),
                    )));
          },

        ))
            :
        Container(
            color: Color(0xffFAF7F2),
            padding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 10.w),
            width: ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,child:Column(children: [

            Container(width: ScreenUtil().screenWidth,height:45.h,child: Column(children: [
              Expanded(child:Container()),
              Row(children: [


                GestureDetector(
                    onTap: (){
                      dev.log("按下");
                      page=0;
                      in_chat = false;
                      setState(() {

                      });
                      /*
                      check_is_ChatID_sub(
                          UserAccount: '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DL!.ACCOUNT}',
                          TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}",
                          CS_NO:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].CS_NO,
                          CLASS_NO:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].CLASS_NO,
                          DEPM_NO:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].DEPM_NO,
                          index: sel_chat_index
                      );//檢查是否已建立聊天室

                       */
                    }, child: Container(color:Color(0x01000000),child: Icon(Icons.arrow_back,size: (iPad)?24.sp:30.sp,))),
                Container(width: 10.w,),

                Row(children: [
                    Text('${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].CS_NM}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.blue , fontSize: (iPad)?14.sp:18.sp)),
                    Container(width: 3.w,),
                    Column(
                      children: [
                        SizedBox(height: 5), // 下移 10 像素
                        Text(
                          '小朋友',
                          style: TextStyle(
                            fontFamily: "GenJyuuGothic",
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                            fontSize: (iPad) ? 8.sp : 12.sp,
                          ),
                        ),
                      ],
                    ),
                    Container(width: 3.w,),

                    PopupMenuButton<String>(
                    onSelected: (value) {

                    },
                    itemBuilder: (context) {
                      List<PopupMenuItem<String>> list = [];
                      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher.length;i++){
                        list.add(PopupMenuItem(
                            height: 20.h,
                            value: '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher[i].EMP_NM}', child:
                            Text('${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher[i].EMP_NM} 老師',textAlign: TextAlign.left, style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.black , fontSize: 16.sp))));
                      }
                      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs.length;i++){
                        list.add(PopupMenuItem(
                            height: 20.h,
                            value: '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs[i]!.USER_NM}', child:
                        Text('${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs[i]!.USER_NM}',textAlign: TextAlign.left, style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.black , fontSize: 16.sp))));
                      }
                      return list;
                    },
                    child:
                      Text('聊天室人數(${(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs.length+EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cLASS_NO_for_teacher.length)})', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.black , fontSize: (iPad)?14.sp:18.sp))
                    )

                  ],),



              ],),
              Expanded(child:Container()),
            ],),),
            Container(height: 15.h,),
            Expanded(child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Stack(children: [


                (_user==null)?Container():chat_ui.Chat(
                  onEndReached: ()async{
                    if (!_isLoadingMore && _hasMore) {
                      _loadMoreMessages();
                    }
                  },
                  disableImageGallery: true, // ⬅️ 加上這一行關閉內建圖片預覽！
                  messages: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].messages,
                  isLeftStatus: true,
                  //onAttachmentPressed: _handleAttachmentPressed,
                  textMessageOptions:  chat_ui.TextMessageOptions(
                    matchers: [
                      MatchText(
                        pattern: r'[\u4e00-\u9fa5]+\s*\((\d{12})\)',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        onTap: (matchedText) async{

                          final text = matchedText;
                          final regex = RegExp(r'\b(\d{12})\b');
                          final matches = regex.allMatches(text);
                          dev.log("抓到符合格式的代碼: ${text}");
                          for (final match in matches) {
                            final candidate = match.group(1);
                            if (candidate != null) {
                              final year = int.tryParse(candidate.substring(0, 4));
                              final month = int.tryParse(candidate.substring(4, 6));
                              final day = int.tryParse(candidate.substring(6, 8));

                              if (year != null && month != null && day != null) {
                                try {
                                  final date = DateTime(year, month, day);
                                  dev.log("抓到符合格式的代碼: $candidate, 日期為: ${DateFormat('yyyy-MM-dd').format(date)}");
                                  if(text.contains("用藥委託")){
                                    //SmartDialog.showLoading(msg: "處理中...");
                                    await read_DRUG_MT_db_sub(DRUG_NO: candidate);
                                    //SmartDialog.dismiss();

                                    Navigator.push(context, PageTransition(
                                        type: PageTransitionType.rightToLeft, child: DRUG_MT_T_page()));


                                  }
                                  else if(text.contains("接送委託")){

                                    entrusted_pick_and_drop = Entrusted_pick_and_drop();

                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            showDialog_setState = setState;

                                            //找出老師名字
                                            EMPLOYEE eMPLOYEE = EMPLOYEE();
                                            try{
                                              eMPLOYEE = eMPLOYEEs.firstWhere((element) => element.EMP_NO==entrusted_pick_and_drop.CFM_USER);
                                            }
                                            catch(e){

                                            }
                                            dev.log("找出老師名字:${eMPLOYEE.EMP_NM}");

                                            return Dialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // 取消圓角
                                              backgroundColor: Colors.white,
                                              insetPadding: EdgeInsets.all(0),
                                              child: entrusted_pick_and_drop.NO==""?
                                              ListView(
                                                padding: EdgeInsets.all(10),
                                                children: [
                                                  Row(children: [
                                                    IconButton(
                                                      icon: Icon(Icons.close, color: Colors.transparent,size: 30.sp,),
                                                      onPressed: (){},
                                                    ),
                                                    Expanded(child: Center(child:Text("接送委託",style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 20.sp,
                                                        color: Color(0xff555555))))),
                                                    IconButton(
                                                      icon: Icon(Icons.close, color: Colors.black,size: 30.sp,),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                  ],),
                                                  Container(height: 100.h,),
                                                  Text(eXCUSED.NO==""?"此委託不存在\n或被家長收回":"${eXCUSED.NO}",textAlign: TextAlign.center,style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 20.sp,
                                                      color: Color(0xff555555)))
                                                ],)
                                                  :
                                              ListView(
                                                padding: EdgeInsets.all(10),
                                                children: [

                                                  Row(children: [
                                                    IconButton(
                                                      icon: Icon(Icons.close, color: Colors.transparent,size: 30.sp,),
                                                      onPressed: (){},
                                                    ),
                                                    Expanded(child: Center(child:Text("接送委託",style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 20.sp,
                                                        color: Color(0xff555555))))),
                                                    IconButton(
                                                      icon: Icon(Icons.close, color: Colors.black,size: 30.sp,),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                  ],),

                                                  Row(children: [
                                                    Text("${entrusted_pick_and_drop.DateStr}",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Colors.blue)),
                                                  ],),
                                                  Container(height: 5.h,),
                                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                                  Container(height: 5.h,),
                                                  Column(children: entrusted_pick_and_drop.eNTRUSTED_DL_list.map((e) {
                                                    ENTRUSTED_TYPE_ITEM? _ENTRUSTED_TYPE_ITEM;
                                                    if(ENTRUSTED_TYPE_ITEM_list.length>0){
                                                      _ENTRUSTED_TYPE_ITEM = ENTRUSTED_TYPE_ITEM_list.firstWhere((element) => element.ITEM_NO==e.TYPE_NO);
                                                    }

                                                    TimeOfDay? timeOfDay;
                                                    List<String> t1 = e.TIME.split(":");
                                                    try{
                                                      timeOfDay = TimeOfDay(hour: int.parse(t1[0]),minute: int.parse(t1[1]));
                                                    }
                                                    catch(e){

                                                    }


                                                    return Container(width: ScreenUtil().screenWidth,child: Column(children: [
                                                      Row(children: [
                                                        Text("${e.SR}.${_ENTRUSTED_TYPE_ITEM==null?"":_ENTRUSTED_TYPE_ITEM.ITEM_NM}",
                                                            maxLines: null,
                                                            style: TextStyle(
                                                                fontFamily: "GenJyuuGothic",
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: 16.sp,
                                                                color: Color(0xff555555))),
                                                        Container(width: 5.w,),
                                                        Text("接送時間${(timeOfDay==null)?"":"${timeOfDay.period==DayPeriod.am?"上午":"下午"}${timeOfDay.hourOfPeriod}:${timeOfDay.minute.toString().padLeft(2,"0")}"}",
                                                            maxLines: null,
                                                            style: TextStyle(
                                                                fontFamily: "GenJyuuGothic",
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: 16.sp,
                                                                color: Colors.blue)),
                                                      ],),
                                                    ],)
                                                    );

                                                  }).toList()),
                                                  Container(height: 5.h,),
                                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                                  Container(height: 5.h,),
                                                  Row(children: [
                                                    Text("代理人姓名:",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Color(0xff555555))),
                                                    Container(width: 5.w,),
                                                    Text("${entrusted_pick_and_drop.AGENT_NM}",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Colors.blue)),
                                                  ],),
                                                  Container(height: 5.h,),
                                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                                  Container(height: 5.h,),
                                                  Row(children: [
                                                    Text("代理人電話:",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Color(0xff555555))),
                                                    Container(width: 5.w,),
                                                    Text("${entrusted_pick_and_drop.AGENT_PHONE}",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Colors.blue)),
                                                  ],),
                                                  Container(height: 5.h,),
                                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                                  Container(height: 5.h,),
                                                  Row(children: [
                                                    Text("關係:",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Color(0xff555555))),
                                                    Container(width: 5.w,),
                                                    Text("${entrusted_pick_and_drop.RELATION}",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Colors.blue)),
                                                  ],),
                                                  Container(height: 5.h,),
                                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                                  Container(height: 5.h,),
                                                  Row(children: [
                                                    Text("說明:",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Color(0xff555555))),
                                                  ],),
                                                  Row(children: [
                                                    Expanded(child:
                                                    Text("${entrusted_pick_and_drop.NOTE}",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Colors.blue))),
                                                  ],),
                                                  Container(height: 5.h,),
                                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                                  Container(height: 5.h,),
                                                  Row(children: [
                                                    Expanded(child:
                                                    Text("家長簽名",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Color(0xff555555)))),
                                                  ],),
                                                  Container(width: ScreenUtil().screenWidth,height: 200.h,child: Image.network(entrusted_pick_and_drop.SIGN_LINK),),
                                                  Container(height: 5.h,),
                                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                                  Container(height: 5.h,),

                                                  Container(width: ScreenUtil().screenWidth,child: Row(children: [

                                                    Expanded(child: Column(children: [

                                                      Row(children: [
                                                        Text("確認者:",
                                                            maxLines: null,
                                                            style: TextStyle(
                                                                fontFamily: "GenJyuuGothic",
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: 16.sp,
                                                                color: Color(0xff555555))),
                                                        Container(width: 5.w,),
                                                        Text("${eMPLOYEE.EMP_NM}",
                                                            maxLines: null,
                                                            style: TextStyle(
                                                                fontFamily: "GenJyuuGothic",
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: 16.sp,
                                                                color: Colors.blue)),
                                                      ],),
                                                      Container(height: 5.h,),
                                                      Row(children: [
                                                        Text("確認日期時間:",
                                                            maxLines: null,
                                                            style: TextStyle(
                                                                fontFamily: "GenJyuuGothic",
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: 16.sp,
                                                                color: Color(0xff555555))),
                                                        Container(width: 5.w,),
                                                        Text("${entrusted_pick_and_drop.CFM_DT_str}",
                                                            maxLines: null,
                                                            style: TextStyle(
                                                                fontFamily: "GenJyuuGothic",
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: 12.sp,
                                                                color: Colors.blue)),
                                                      ],),
                                                      Container(height: 5.h,),

                                                    ],)),

                                                    Container(
                                                        padding: EdgeInsets.only( left:0.w,right: 0.w),
                                                        width: 60.w,
                                                        height: 40.h,
                                                        child: ElevatedButton(
                                                          style: ButtonStyle(
                                                              backgroundColor: MaterialStateProperty.all(Color(0xff48C2BC)),
                                                              surfaceTintColor: MaterialStateProperty.all(Color(0xff48C2BC)),
                                                              padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                  RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(5.w),
                                                                      side: BorderSide(color: Color(0xff555555))
                                                                  )
                                                              )
                                                          ),
                                                          onPressed: () async{


                                                            write_ENTRUSTED_db_sub(
                                                                NO:"${entrusted_pick_and_drop.NO}",
                                                                CFM_USER:EMPLOYEE_teacher.EMP_NO
                                                            );

                                                            /*
                                                      write_EXCUSED_db_sub(
                                                          NO:"${item.NO}",
                                                          CS_NO:"${item.CS_NO}",
                                                          CFM_NO:item.CFM_ITEM_selectedValue.CFM_NO,
                                                          CFM_USER:EMPLOYEE_teacher.EMP_NO
                                                      );

                                                       */


                                                          },
                                                          child: Row(children: [
                                                            Expanded(child: Container()),
                                                            Text('確認', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.white , fontSize: 20.sp)),
                                                            Expanded(child: Container()),
                                                          ],),
                                                        )),

                                                  ],),),

                                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                                  Container(height: 5.h,),

                                                ],),
                                            );
                                          },
                                        );
                                      },
                                    );


                                    await ENTRUSTED_db_sub(NO:candidate);

                                  }
                                  else if(text.contains("請假委託")){

                                    eXCUSED = EXCUSED();
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            showDialog_setState = setState;

                                            //學校(DEPM)
                                            //DEPM _DEPM = dEPMs.firstWhere((element) => element.DEPM_NO==eXCUSED.DEPM_NO);
                                            CLASS _CLASS = CLASS();

                                            try{
                                              _CLASS = cLASSs.firstWhere((element) => element.CLASS_NO==eXCUSED.CLASS_NO);
                                            }
                                            catch(e){

                                            }



                                            EXCUSED_HOURS_ITEM _EXCUSED_HOURS_ITEM = EXCUSED_HOURS_ITEM();
                                            EXCUSED_REASON_ITEM _EXCUSED_REASON_ITEM = EXCUSED_REASON_ITEM();
                                            CFM_ITEM _CFM_ITEM = CFM_ITEM();
                                            try{
                                              if(EXCUSED_HOURS_ITEM_list.length>0) {
                                                _EXCUSED_HOURS_ITEM = EXCUSED_HOURS_ITEM_list
                                                    .firstWhere((element) =>
                                                element.ITEM_NO == eXCUSED.HOURS_NO);
                                              }
                                              _EXCUSED_REASON_ITEM = EXCUSED_REASON_ITEM_list.firstWhere((element) => element.ITEM_NO==eXCUSED.REASON_NO);
                                              _CFM_ITEM = CFM_ITEM_list.firstWhere((element) => element.CFM_NO==eXCUSED.CFM_NO);

                                            }
                                            catch(e){

                                            }


                                            //老師名字
                                            String teacher_name = "";
                                            for(int i=0;i<eMPLOYEEs.length;i++){
                                              if(eMPLOYEEs[i].EMP_NO==eXCUSED.CFM_USER){
                                                teacher_name = eMPLOYEEs[i].EMP_NM;
                                                break;
                                              }
                                            }

                                            String student_name = "";
                                            for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMERs.length;i++){
                                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs.length;j++){
                                                if(EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs[j].CS_NO==eXCUSED.CS_NO){
                                                  student_name = EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs[j].CS_NM;
                                                  break;
                                                }
                                              }
                                            }



                                            return Dialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // 取消圓角
                                              backgroundColor: Colors.white,
                                              insetPadding: EdgeInsets.all(0),
                                              child: eXCUSED.NO=="處理中"||eXCUSED.NO==""?
                                              ListView(
                                                padding: EdgeInsets.all(10),
                                                children: [
                                                  Row(children: [
                                                    IconButton(
                                                      icon: Icon(Icons.close, color: Colors.transparent,size: 30.sp,),
                                                      onPressed: (){},
                                                    ),
                                                    Expanded(child: Center(child:Text("請假委託",style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 20.sp,
                                                        color: Color(0xff555555))))),
                                                    IconButton(
                                                      icon: Icon(Icons.close, color: Colors.black,size: 30.sp,),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                  ],),
                                                  Container(height: 100.h,),
                                                  Text(eXCUSED.NO==""?"此委託不存在\n或被家長收回":"${eXCUSED.NO}",textAlign: TextAlign.center,style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 20.sp,
                                                      color: Color(0xff555555)))
                                                ],)
                                                  :
                                              ListView(
                                                padding: EdgeInsets.all(10),
                                                children: [

                                                  Row(children: [
                                                    IconButton(
                                                      icon: Icon(Icons.close, color: Colors.transparent,size: 30.sp,),
                                                      onPressed: (){},
                                                    ),
                                                    Expanded(child: Center(child:Text("請假委託",style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 20.sp,
                                                        color: Color(0xff555555))))),
                                                    IconButton(
                                                      icon: Icon(Icons.close, color: Colors.black,size: 30.sp,),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                  ],),


                                                  Row(children: [
                                                    Text('${_CLASS==null?"":_CLASS.CLASS_NM}-${student_name}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 15.sp)),
                                                  ],),
                                                  Row(children: [
                                                    Container(
                                                      //width: ScreenUtil().screenWidth,
                                                        child: Text("${eXCUSED.DateStr}",
                                                            maxLines: null,
                                                            style: TextStyle(
                                                                fontFamily: "GenJyuuGothic",
                                                                fontWeight: FontWeight.w700,
                                                                fontSize: 16.sp,
                                                                color: Color(0xff555555)))),
                                                  ],),
                                                  Row(children: [
                                                    Text((_EXCUSED_REASON_ITEM==null)?"":"${_EXCUSED_REASON_ITEM.ITEM_NM}",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Colors.blue)),
                                                    Container(width: 10.w,),
                                                    Text((_EXCUSED_HOURS_ITEM==null)?"":"${_EXCUSED_HOURS_ITEM.ITEM_NM}",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Colors.blue)),
                                                  ],),

                                                  Container(height: 5.h,),
                                                  Row(children: [
                                                    Text("說明:",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Color(0xff555555))),
                                                  ],),
                                                  Row(children: [
                                                    Expanded(child:
                                                    Text("${eXCUSED.NOTE}",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Colors.blue))),
                                                  ],),
                                                  Container(height: 5.h,),
                                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                                  Container(height: 5.h,),
                                                  Row(children: [
                                                    Expanded(child:
                                                    Text("家長簽名",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Color(0xff555555)))),
                                                  ],),
                                                  Container(width: ScreenUtil().screenWidth,height: 200.h,child: Image.network(eXCUSED.SING_LINK),),
                                                  Container(height: 5.h,),
                                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                                  Container(height: 5.h,),
                                                  Row(children: [
                                                    Text("確認者:",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 14.sp,
                                                            color: Color(0xff555555))),
                                                    Container(width: 5.w,),
                                                    Text("${teacher_name}",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 14.sp,
                                                            color: Colors.blue)),
                                                    Expanded(child: Container()),

                                                    Text("確認:",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 14.sp,
                                                            color: Color(0xff555555))),
                                                    Container(width: 5.w,),
                                                    Container(
                                                        decoration: BoxDecoration(
                                                          border: Border.all(color: Colors.grey),
                                                          borderRadius: BorderRadius.circular(5.w),
                                                        ),
                                                        //width: 80.w,
                                                        height: 36.h,
                                                        child:(eXCUSED.CFM_ITEM_selectedValue.CFM_NO.isEmpty)?Container():
                                                        DropdownButtonHideUnderline(
                                                          child: DropdownButton2<CFM_ITEM>(
                                                            isExpanded: true,
                                                            items: CFM_ITEM_list
                                                                .map((CFM_ITEM item) => DropdownMenuItem<CFM_ITEM>(
                                                              value: item,
                                                              child: Text(
                                                                item.CFM_NM,
                                                                style: TextStyle(
                                                                  fontSize: 16.sp,
                                                                  fontWeight: FontWeight.bold,
                                                                  color:Colors.blue,
                                                                ),
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ))
                                                                .toList(),
                                                            value: eXCUSED.CFM_ITEM_selectedValue,
                                                            onChanged: (value) {

                                                              setState(() {
                                                                eXCUSED.CFM_ITEM_selectedValue = value!;
                                                              });
                                                            },
                                                            buttonStyleData:  ButtonStyleData(
                                                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                                                              height: 40.h,
                                                              width: 110.w,
                                                            ),
                                                            menuItemStyleData: MenuItemStyleData(
                                                              height: 40.h,
                                                              padding: EdgeInsets.only(left: 14.w, right: 14.w),
                                                            ),
                                                          ),
                                                        )),

                                                    Container(width: 5.w,),
                                                    /*
                                                    Text((_CFM_ITEM==null)?"":"${_CFM_ITEM.CFM_NM}",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Colors.blue)),

                                                     */
                                                  ],),
                                                  Container(height: 5.h,),
                                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                                  Container(height: 5.h,),
                                                  Row(children: [
                                                    Text("確認日期時間:",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 14.sp,
                                                            color: Color(0xff555555))),
                                                    Container(width: 5.w,),
                                                    Text((eXCUSED.CFM_DT.isEmpty)?"":"${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(eXCUSED.CFM_DT))}",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 14.sp,
                                                            color: Colors.blue)),
                                                  ],),
                                                  Container(height: 5.h,),
                                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                                  Container(height: 5.h,),
                                                  Container(
                                                      padding: EdgeInsets.only( left:0.w,right: 0.w),
                                                      width: ScreenUtil().screenWidth,
                                                      height: 55.h,
                                                      child: ElevatedButton(
                                                        style: ButtonStyle(
                                                            backgroundColor: MaterialStateProperty.all(Color(0xff48C2BC)),
                                                            surfaceTintColor: MaterialStateProperty.all(Color(0xff48C2BC)),
                                                            padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(28.w),
                                                                    side: BorderSide(color: Color(0xff555555))
                                                                )
                                                            )
                                                        ),
                                                        onPressed: () async{


                                                          write_EXCUSED_db_sub(
                                                              NO:"${eXCUSED.NO}",
                                                              CS_NO:"${eXCUSED.CS_NO}",
                                                              CFM_NO:eXCUSED.CFM_ITEM_selectedValue.CFM_NO,
                                                              CFM_USER:EMPLOYEE_teacher.EMP_NO
                                                          );



                                                        },
                                                        child: Row(children: [
                                                          Expanded(child: Container()),
                                                          Text('送出', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                                                          Expanded(child: Container()),
                                                        ],),
                                                      )),
                                                  Container(height: 5.h,),

                                                ],),
                                            );
                                          },
                                        );
                                      },
                                    );
                                    await EXCUSED_db_sub(NO:candidate);
                                  }
                                } catch (e) {
                                  dev.log("解析日期失敗: $candidate");
                                }
                              }
                            }
                          }


                        },
                      ),
                      MatchText(
                        type: ParsedType.URL,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        onTap: (url) {
                          launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
                        },
                      ),
                    ],
                  ),

                  textMessageBuilder: _myTextMessageBuilder,
                  imageMessageBuilder: _myImageMessageBuilder,

                  onMessageTap: _handleMessageTap,
                  onPreviewDataFetched: _handlePreviewDataFetched,
                  onSendPressed: _handleSendPressed,
                  showUserAvatars: true,
                  showUserNames: true,
                  user: _user,
                  customStatusBuilder:customStatusBuilder,
                  customBottomWidget: Container(
                    width: ScreenUtil().screenWidth,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end, // 讓附件與傳送按鈕固定對齊在多行輸入框底部
                      children: [
                        Container(width: 10.w),
                        GestureDetector(
                          onTap: () {
                            _handleAttachmentPressed();
                          },
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 6.h),
                            child: SvgPicture.asset(
                              "assets/images/组 1153.svg",
                              width: (iPad) ? 28.w : 45.w,
                            ),
                          ),
                        ),
                        Container(width: 5.w),
                        Expanded(
                          flex: (iPad) ? 10 : 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                            // 設定最小高度（單行）與最大自動延展高度（超過此高度內部可捲動）
                            constraints: BoxConstraints(
                              minHeight: 46.h,
                              maxHeight: 130.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffF2F2F2),
                              borderRadius: BorderRadius.circular(18.w),
                              border: Border.all(
                                color: const Color(0xffA7A7A7),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Form(
                                    child: TextFormField(
                                      controller: message_TextEditingController,
                                      // 啟用多行並支援 iOS / Android 換行
                                      keyboardType: TextInputType.multiline,
                                      textInputAction: TextInputAction.newline,
                                      minLines: 1,
                                      maxLines: 5, // 1~5 行內會隨著文字行數自動長高
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: const Color(0xff555555),
                                      ),
                                      inputFormatters: [
                                        SingleQuoteToFullQuoteFormatter(),
                                      ],
                                      autofocus: false,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.transparent,
                                        hintText: '請輸入',
                                        hintStyle: TextStyle(
                                          color: const Color(0xff9E9E9E),
                                          fontSize: 16.sp,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    String message = message_TextEditingController.text.trim();
                                    message_TextEditingController.clear();
                                    if (message.isNotEmpty) {
                                      insert_MSDL2_db_sub(message: message);
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 6.h, left: 6.w),
                                    child: SvgPicture.asset(
                                      "assets/images/Icon ionic-ios-send.svg",
                                      width: (iPad) ? 20.w : 28.w,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 10.w),
                      ],
                    ),
                  ),
                  theme: const chat_ui.DefaultChatTheme(
                    backgroundColor: Color(0xffFAF7F2),
                    secondaryColor: Color(0xffffffff),
                    primaryColor: Color(0xffF9AA88),
                    receivedMessageBodyTextStyle: TextStyle(color: Color(0xff555555), fontWeight: FontWeight.bold),
                    sentMessageBodyTextStyle: TextStyle(color: Color(0xff555555), fontWeight: FontWeight.bold),
                  ),
                ),

                if (_isLoadingMore)
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children:  [
                            SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "載入中...",
                              style: TextStyle(fontSize: 14.sp,color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

              ],)
              )),


          ],))

        ));
  }
}
