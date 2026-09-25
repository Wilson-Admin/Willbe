import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
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
import 'main2_U.dart';
import 'sql.dart';
import 'utils/CustomAppBar.dart';

int ChatPage_unread_count=0;
Timer? ChatPage_timer;
class ChatPage extends StatefulWidget {
  int index=0;
  ChatPage({int index=0}){
    this.index=index;
  }
  @override
  State<ChatPage> createState() => _ChatPageState(index:this.index);
}

class _ChatPageState extends State<ChatPage> {

  List<types.Message> _messages = [];

  late final _user;

  TextEditingController message_TextEditingController = TextEditingController();
  List<EMPLOYEE> _eMPLOYEEs = [];
  List<CLASS> _cLASSs = [];
  int index=0;
  _ChatPageState({int index=0}){
    this.index = index;
    _eMPLOYEEs.addAll(cUSTOMERs[this.index].cLASS_NO_for_teacher);//eMPLOYEEs.where((element) => element.CLASS_NO==cUSTOMERs[index].CLASS_NO).toList();
    _cLASSs = cLASSs.where((element) => element.CLASS_NO==cUSTOMERs[this.index].CLASS_NO).toList();

    _user = types.User(
      id: '${cUSTOMERs[this.index].sel_cUSTOMER_DL!.ACCOUNT.trim()}',//Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
      lastName:'',
      firstName: '${cUSTOMERs[this.index].sel_cUSTOMER_DL!.USER_NM}',
    );
  }

  String ChatID = "";

  //final AutoScrollController _scrollController = AutoScrollController();
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isRunning = false;

  @override
  void initState() {
    // TODO: implement initState

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    /*
    _scrollController.addListener(() {
      if (_scrollController.offset <= 0 && !_isLoadingMore && _hasMore) {
        _loadMoreMessages();
      }
    });

     */

    in_chat = true;


    init();

  }

  // 刪除訊息邏輯
  void _deleteMessage(String messageId) async {
    // 1. 先刪掉本地訊息
    setState(() {
      _messages.removeWhere((msg) => msg.id == messageId);
    });

    // 2. 後端刪除 SQL
    String comm = '''
BEGIN TRAN;  -- 開始交易

DELETE FROM MSDL2 WHERE MessageID = N'$messageId';
DELETE FROM MSRS WHERE MessageID = N'$messageId';

COMMIT TRAN; -- 提交交易（兩個刪除都成功才真正寫入）
''';

    try {
      String result = await sql_command(comm);
      dev.log("刪除訊息(回應): $result");

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
      dev.log("刪除訊息失敗: $e");

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


  Offset? _longPressPosition; // 在 State 裡定義變數

  Widget _myTextMessageBuilder(
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
                  //message.author.firstName ?? '',
                  cUSTOMERs[this.index].cLASS_NO_for_teacher.where((c) => c.ACCOUNT == message.author.id).toList().length>0? '老師':message.author.firstName ?? '',
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

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) return; // 防止多次觸發
    _isLoadingMore = true;
    setState(() {

    });
    final oldestMessageId = _messages.last.id;
    await fetchLatestMessages(beforeId: oldestMessageId, limit: 15);
    _isLoadingMore = false;
    setState(() {

    });
  }


  @override
  void dispose() {
    in_chat = false;
    if(ChatPage_timer!=null) {
      ChatPage_timer!.cancel();
    }
    MyHomePage2_U_fun1!(reflash_db:"聊天室未讀狀態更新");
    super.dispose();
  }

  init()async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    dev.log("處理中...");
    await check_is_ChatID_sub(
      //UserAccount: '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}',
      //TeacherAccount:"${_eMPLOYEEs[].ACCOUNT}",
      CS_NO:cUSTOMERs[this.index].CS_NO,
      CLASS_NO:cUSTOMERs[this.index].CLASS_NO,
      DEPM_NO:cUSTOMERs[this.index].DEPM_NO,
    );//檢查是否已建立聊天室
    SmartDialog.dismiss();
    dev.log("聊天室id:${ChatID}");
    if(ChatID.isNotEmpty){
      await read_message_sub();
      if (!mounted) return;
      setState(() {

      });
    }
    ChatPage_timer = Timer.periodic(const Duration(seconds: 6), (timer)async{

      if (_isRunning) return; // 正在跑，直接跳過
      _isRunning = true;

      try {
        if(ChatID.isNotEmpty){
          await read_message_sub();
          await check_all_message_is_seen_sub();
          await _syncDeletedMessages(ChatID);
          if (!mounted) return;
          setState(() {

          });
        }
        else{

          await check_is_ChatID_sub(
            //UserAccount: '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}',
            //TeacherAccount:"${_eMPLOYEEs[].ACCOUNT}",
            CS_NO:cUSTOMERs[this.index].CS_NO,
            CLASS_NO:cUSTOMERs[this.index].CLASS_NO,
            DEPM_NO:cUSTOMERs[this.index].DEPM_NO,
          );//檢查是否已建立聊天室

        }
      } finally {
        _isRunning = false;
      }




    });
  }


  Future<void> _syncDeletedMessages(String chatId) async {
    if (_messages.isEmpty) return;

    // 先複製並排序，不影響原本 _messages
    List<Message> sortedMessages = List.from(_messages)
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
    dev.log("本地端(要刪掉的訊息):${result}");
    List<String> serverIds = (jsonDecode(result) as List)
        .map((e) => e['MessageID'] as String)
        .toList();

    // 3. 比對出「本地有但後端沒有」的訊息
    Set<String> serverIdSet = serverIds.toSet();
    List<String> toRemove = _messages
        .where((msg) => !serverIdSet.toString().trim().contains(msg.id))
        .map((msg) => msg.id)
        .toList();

    // 4. 刪除多餘訊息
    if (toRemove.isNotEmpty) {
      setState(() {
        _messages.removeWhere((msg) => toRemove.contains(msg.id));
      });
    }
  }

  /*
  檢查是否已建立聊天室
   */
  Future<void>check_is_ChatID_sub(
      {
        String TeacherAccount="",
        String UserAccount="",
        String CS_NO="",
        String CLASS_NO="",
        String DEPM_NO="",
      })async{

    TeacherAccount = TeacherAccount.trim();
    UserAccount = UserAccount.trim();

    //SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    String result = await sql_command("SELECT * FROM MSMT2 WHERE CS_NO='${CS_NO}' AND CLASS_NO='${CLASS_NO}' AND DEPM_NO='${DEPM_NO}'");
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
      if(data_list.length==0){
        dev.log("尚未建立聊天室");
        await insert_MSMT2_db_sub(CS_NO:CS_NO,CLASS_NO:CLASS_NO,DEPM_NO:DEPM_NO);
      }
      else{
        dev.log("已建立聊天室");
        ChatID =  "${data_list[0]["ChatID"]}".trim(); //await get_ChatID_form_MSMT2_db_sub(CS_NO:CS_NO,CLASS_NO:CLASS_NO,DEPM_NO:DEPM_NO);
        dev.log("ChatID:${ChatID}");
        if(ChatID.isNotEmpty){

          _isLoadingMore = true;
          setState(() {

          });
          //await _loadMessages();
          _isLoadingMore = false;
          setState(() {

          });

        }

      }
      setState(() {

      });


    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }


  Future<void> insert_MSMT2_db_sub({
    String CS_NO="",
    String CLASS_NO="",
    String DEPM_NO="",
})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    ChatID = "${DateTime.now().microsecondsSinceEpoch}";

    List<String> TeacherAccount = [];
    List<String> UserAccount=[];
    for(int i=0;i<cUSTOMERs[this.index].cLASS_NO_for_teacher.length;i++){
      TeacherAccount.add("${cUSTOMERs[this.index].cLASS_NO_for_teacher[i].ACCOUNT.trim()}");
    }
    for(int i=0;i<cUSTOMERs[this.index].cUSTOMER_DLs.length;i++){
      UserAccount.add("${cUSTOMERs[this.index].cUSTOMER_DLs[i]!.ACCOUNT.trim()}");
    }

    String comm = "INSERT INTO MSMT2(ChatID,CS_NO,CLASS_NO,DEPM_NO,TeacherAccount,UserAccount) VALUES ('${ChatID}','${CS_NO}',${CLASS_NO},'${DEPM_NO}','${jsonEncode(TeacherAccount)}','${jsonEncode(UserAccount)}')";
    dev.log("${comm}");
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
    //SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    String comm = "SELECT * FROM MSMT2 WHERE CS_NO='${CS_NO}' AND CLASS_NO='${CLASS_NO}' AND DEPM_NO='${DEPM_NO}'";
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
      return data_list[0]["ChatID"].toString().trim();
    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
      return "";
    }
  }


  void _addMessage(types.Message message) {
    // 檢查是否已存在相同 id 的訊息
    /*
    bool exists = _messages.any((m) => m.id == message.id);
    if (!exists) {
      _messages.insert(0, message);
      _messages.sort((a, b) => "${b.id}".compareTo("${a.id}")); // 字串比較（你可以視 id 類型優化）
    }

     */

    final messagesList = _messages;

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

    setState(() {

    });
  }

  void _addMessage2(types.Message message) {
    // 檢查是否已存在相同 id 的訊息
    /*
    bool exists = _messages.any((m) => m.id == message.id);
    if (!exists) {
      _messages.insert(0, message);
      _messages.sort((a, b) => "${b.id}".compareTo("${a.id}")); // 字串比較（你可以視 id 類型優化）
    }

     */

    final messagesList = _messages;

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
                  child: Text('圖片',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 20.sp),),
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
                  child: Text('取消',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 20.sp),),
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
    final result = await FilePicker.pickFiles(
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



  void _handleMessageTap(BuildContext _, types.Message message) async {

    dev.log("點擊訊息:${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.fromMicrosecondsSinceEpoch(message.createdAt!*1000))}");
    if (message is types.TextMessage && message.previewData?.link != null) {
      final url = message.previewData!.link!;
      launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
    }
    else if (message is types.ImageMessage) {
      showImageViewer(context, message);
    }

    /*
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: true,
          );

          setState(() {
            _messages[index] = updatedMessage;
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
          _messages.indexWhere((element) => element.id == message.id);
          final updatedMessage =
          (_messages[index] as types.FileMessage).copyWith(
            isLoading: null,
          );

          setState(() {
            _messages[index] = updatedMessage;
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
      final messages = _messages
          .map((m) {
        if (m.id == message.id && m is types.TextMessage) {
          return m.copyWith(previewData: previewData);
        }
        return m;
      }).toList();

      _messages = messages;
    });

    /*
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
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

  Future<void> _loadMessages() async {

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



    DateTime datetime = DateTime.now();
    //String comm = "SELECT * FROM MSDL2 WHERE (ChatID='${ChatID}') AND (CreatedAt BETWEEN '${DateFormat("yyyy-MM-dd").format(datetime.subtract(Duration(days: 3)))} 00:00:00' AND '${DateFormat("yyyy-MM-dd").format(datetime)} 23:59:59')";
    String comm = '''SELECT TOP 15 *
FROM MSDL2
WHERE ChatID = '${ChatID}'
ORDER BY MessageID DESC;''';
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

      data_list.sort((a,b) => a['CreatedAt'].compareTo(b['CreatedAt']));

      for(int i=0;i<data_list.length;i++){
        dev.log("Type:${data_list[i]["Type"]}");
        dev.log("AuthorID:${data_list[i]["AuthorID"]}");
        dev.log("_user.id:${_user.id}");

        //檢查每則訊息的已讀狀態
        int is_read_count = 0;
        List<dynamic> MSRS_data_list = await check_MSRS_Status_sub(
          ChatID:'${ChatID}',
          MessageID:data_list[i]["MessageID"].trim(),
        );
        for(int j=0;j<MSRS_data_list.length;j++){
          if("${MSRS_data_list[j]["Status"]}"=="seen"){
            is_read_count+=1;
          }
        }
        dev.log("is_read_count:${is_read_count}");


        //先檢查非自己的留言,如為小孩的爸媽,則顯示姓,如為老師顯示"師"
        String name = "老師";
        for(int j=0;j<cUSTOMERs[this.index].cUSTOMER_DLs.length;j++){
          if( "${data_list[i]["AuthorFirstName"]}".trim()==cUSTOMERs[this.index].cUSTOMER_DLs[j]!.USER_NM){
            name = "${data_list[i]["AuthorFirstName"]}".trim();
            break;
          }
        }


        if("${data_list[i]["Type"]}".trim()=="text"){

          var textMessage = types.TextMessage(
            author: types.User(
              id: "${data_list[i]["AuthorID"]}".trim(),//Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
              lastName:'',
              firstName: name,
            ),
            createdAt: (DateTime.parse(data_list[i]["CreatedAt"].trim()).subtract(Duration(hours: (Platform.isIOS)?0:0)).millisecondsSinceEpoch).toInt(),
            id: data_list[i]["MessageID"].trim(),
            text: data_list[i]["Text"].trim(),
            status: is_read_count<=0?null:types.Status.seen,
            metadata: {
              'is_read_count': '${is_read_count}',
              'text':data_list[i]["Text"].trim()
            },
          );
          _addMessage2(textMessage);
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
              firstName: name,
            ),
            createdAt: (DateTime.parse(data_list[i]["CreatedAt"].trim()).subtract(Duration(hours: (Platform.isIOS)?0:0)).millisecondsSinceEpoch).toInt(),
            height: double.parse("${data_list[i]["ImageHeight"]}".trim()),
            id: "${data_list[i]["MessageID"]}",
            name: "${data_list[i]["ResourceUri"]}",
            size: int.parse("${data_list[i]["ResourceSize"]}".contains("null")?"100":"${data_list[i]["ResourceSize"]}"),
            uri: resourceUri,
            width: double.parse("${data_list[i]["ImageWidth"]}".trim()),
            status: is_read_count<=0?null:types.Status.seen,
            metadata: {
              'is_read_count': '${is_read_count}',
              'name':"${data_list[i]["ResourceUri"]}".trim(),
              'height':double.parse("${data_list[i]["ImageHeight"]}".trim()),
              'width':double.parse("${data_list[i]["ImageWidth"]}".trim()),
              'uri': resourceUri,
              'size': int.parse("${data_list[i]["ResourceSize"]}".trim().contains("null")?"100":"${data_list[i]["ResourceSize"]}".trim()),
            },
          );

          _addMessage2(message);

        }
        /*
        if("${data_list[i]["AuthorID"]}".trim()=="${_user.id}".trim()){
          dev.log("家長");
          //家長
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
        else{


        }

         */
      }




      //確認老師的訊息狀態改為已讀
      dev.log("確認訊息狀態改為已讀");
      String account = "${cUSTOMERs[this.index].sel_cUSTOMER_DL!.ACCOUNT}".trim();
      for(int i=0;i<data_list.length;i++){
        String MessageID = data_list[i]["MessageID"];
        String AuthorID = data_list[i]["AuthorID"];
        if(AuthorID != account){
          update_MSRS_by_Status_sub(AuthorID:account,MessageID:MessageID,ChatID:ChatID);
        }
      }


    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }

  }

  Future<void> fetchLatestMessages({String beforeId="",int limit=15}) async {

    String comm = '''SELECT TOP 15 *
FROM MSDL2
WHERE ChatID = '${ChatID}'
  AND MessageID < '${beforeId}'
ORDER BY MessageID DESC''';
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

      data_list.sort((a,b) => a['CreatedAt'].compareTo(b['CreatedAt']));

      for(int i=0;i<data_list.length;i++){
        dev.log("Type:${data_list[i]["Type"]}");
        dev.log("AuthorID:${data_list[i]["AuthorID"]}");
        dev.log("_user.id:${_user.id}");

        //檢查每則訊息的已讀狀態
        int is_read_count = 0;
        List<dynamic> MSRS_data_list = await check_MSRS_Status_sub(
          ChatID:'${ChatID}',
          MessageID:data_list[i]["MessageID"].trim(),
        );
        for(int j=0;j<MSRS_data_list.length;j++){
          if("${MSRS_data_list[j]["Status"]}"=="seen"){
            is_read_count+=1;
          }
        }
        dev.log("is_read_count:${is_read_count}");

        //先檢查非自己的留言,如為小孩的爸媽,則顯示姓,如為老師顯示"師"
        String name = "老師";
        for(int j=0;j<cUSTOMERs[this.index].cUSTOMER_DLs.length;j++){
          if( "${data_list[i]["AuthorFirstName"]}".trim()==cUSTOMERs[this.index].cUSTOMER_DLs[j]!.USER_NM){
            name = "${data_list[i]["AuthorFirstName"]}".trim();
            break;
          }
        }

        if("${data_list[i]["Type"]}".trim()=="text"){

          var textMessage = types.TextMessage(
            author: types.User(
              id: "${data_list[i]["AuthorID"]}".trim(),//Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
              lastName:'',
              firstName: name,
            ),
            createdAt: (DateTime.parse(data_list[i]["CreatedAt"].trim()).subtract(Duration(hours: (Platform.isIOS)?0:0)).millisecondsSinceEpoch).toInt(),
            id: data_list[i]["MessageID"].trim(),
            text: data_list[i]["Text"].trim(),
            status: is_read_count<=0?null:types.Status.seen,
            metadata: {
              'is_read_count': '${is_read_count}',
              'text':data_list[i]["Text"].trim()
            },
          );
          _addMessage2(textMessage);
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
              firstName: name,
            ),
            createdAt: (DateTime.parse(data_list[i]["CreatedAt"].trim()).subtract(Duration(hours: (Platform.isIOS)?0:0)).millisecondsSinceEpoch).toInt(),
            height: double.parse("${data_list[i]["ImageHeight"]}".trim()),
            id: "${data_list[i]["MessageID"]}",
            name: "${data_list[i]["ResourceUri"]}",
            size: int.parse("${data_list[i]["ResourceSize"]}".contains("null")?"100":"${data_list[i]["ResourceSize"]}"),
            uri: resourceUri,
            width: double.parse("${data_list[i]["ImageWidth"]}".trim()),
            status: is_read_count<=0?null:types.Status.seen,
            metadata: {
              'is_read_count': '${is_read_count}',
              'name':"${data_list[i]["ResourceUri"]}".trim(),
              'height':double.parse("${data_list[i]["ImageHeight"]}".trim()),
              'width':double.parse("${data_list[i]["ImageWidth"]}".trim()),
              'uri': resourceUri,
              'size': int.parse("${data_list[i]["ResourceSize"]}".trim().contains("null")?"100":"${data_list[i]["ResourceSize"]}".trim()),
            },
          );

          _addMessage2(message);

        }

      }

      _hasMore = data_list.length == 15;




      //確認老師的訊息狀態改為已讀
      dev.log("確認訊息狀態改為已讀");
      String account = "${cUSTOMERs[this.index].sel_cUSTOMER_DL!.ACCOUNT}".trim();
      for(int i=0;i<data_list.length;i++){
        String MessageID = data_list[i]["MessageID"];
        String AuthorID = data_list[i]["AuthorID"];
        if(AuthorID != account){
          update_MSRS_by_Status_sub(AuthorID:account,MessageID:MessageID,ChatID:ChatID);
        }
      }


    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }

  }


  Future<List<dynamic>> check_MSRS_Status_sub({
    String ChatID="",
    String MessageID="",
  })async{

    String comm = "SELECT * FROM MSRS WHERE (ChatID='${ChatID}') AND (MessageID='${MessageID}')";
    dev.log("${comm}");
    String result = await sql_command("${comm}");
    SmartDialog.dismiss();
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
    dev.log("${comm}");
    String result = await sql_command("${comm}");
    //SmartDialog.dismiss();
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

  /*
  Future<void> update_MSDL2_by_Status_sub(dynamic msdl,dynamic Status) async {


    String comm = "UPDATE MSDL2 SET Status='${Status}' WHERE ChatID='${msdl["ChatID"]}' AND MessageID='${msdl["MessageID"]}'";
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
  Future<void> check_all_message_is_seen_sub()async{
    for(int i=0;i<_messages.length;i++){
      if( int.parse("${_messages[i].metadata!["is_read_count"]}") < cUSTOMERs[this.index].cLASS_NO_for_teacher.length){

        int is_read_count = 0;
        List<dynamic> MSRS_data_list = await check_MSRS_Status_sub(
          ChatID:'${ChatID}',
          MessageID:"${_messages[i].id}",
        );
        for(int j=0;j<MSRS_data_list.length;j++){
          if("${MSRS_data_list[j]["Status"]}"=="seen"){
            is_read_count+=1;
          }
        }

        if(_messages[i].type==MessageType.text){

          var currentMessage = _messages[i];
          if (currentMessage is types.TextMessage) {
            var textMessage = types.TextMessage(
              author: _messages[i].author,
              createdAt: _messages[i].createdAt,
              id: _messages[i].id,
              text: _messages[i].metadata!["text"],
              status: is_read_count<=0?null:types.Status.seen,
              metadata: {
                'is_read_count': '${is_read_count}',
                'text':_messages[i].metadata!["text"],
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
                  _messages[i] = previewed;
                }
              }
              else{
                _messages[i] = textMessage;
              }
            }
            else{
              _messages[i] = textMessage;
            }
          }



        }
        else if(_messages[i].type==MessageType.image){

          final message = types.ImageMessage(
            author: _messages[i].author,
            createdAt: _messages[i].createdAt,
            id: _messages[i].id,
            height: double.parse("${_messages[i].metadata!["height"]}".trim()),
            name: "${_messages[i].metadata!["name"]}".trim(),
            size: int.parse("${_messages[i].metadata!["size"]}".trim()),
            uri: "${_messages[i].metadata!["uri"]}".trim(),
            width: double.parse("${_messages[i].metadata!["width"]}".trim()),
            status: is_read_count<=0?null:types.Status.seen,
            metadata: {
              'is_read_count': '${is_read_count}',
              'name':"${_messages[i].metadata!["name"]}".trim(),
              'height':double.parse("${_messages[i].metadata!["height"]}".trim()),
              'width':double.parse("${_messages[i].metadata!["width"]}".trim()),
              'uri': "${_messages[i].metadata!["uri"]}".trim(),
              'size': int.parse("${_messages[i].metadata!["size"]}".trim()),
            },
          );

          _messages[i] = message;

        }

      }
    }
  }

  Future<void> read_message_sub() async {

    DateTime datetime = DateTime.now();
    //String comm = "SELECT * FROM MSDL2 WHERE (ChatID='${ChatID}') AND (CreatedAt BETWEEN '${DateFormat("yyyy-MM-dd HH:mm:ss").format(datetime.subtract(Duration(minutes: 30)))}' AND '${DateFormat("yyyy-MM-dd").format(datetime)} 23:59:59')";
    String comm = '''SELECT TOP 10 *
FROM MSDL2
WHERE ChatID = '${ChatID}'
ORDER BY MessageID DESC;''';
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
        for(int j=0;j<_messages.length;j++){
          dev.log(">>${DateTime.parse(data_list[i]["CreatedAt"]).millisecondsSinceEpoch}");
          dev.log(">>>${_messages[j].createdAt}");
          if("${data_list[i]["MessageID"]}".trim()=="${_messages[j].id}".trim()){
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
          ChatID:'${ChatID}',
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
              'text':data_list2[i]["Text"].trim()
            },
          );
          _addMessage(textMessage);
        }
        else if("${data_list2[i]["Type"]}".trim()=="image"){

          String resourceUri = "${data_list2[i]["ResourceUri"]}".trim();
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
              'is_read_count': '${is_read_count}',
              'name':"${data_list2[i]["ResourceUri"]}".trim(),
              'height':double.parse("${data_list2[i]["ImageHeight"]}".trim()),
              'width':double.parse("${data_list2[i]["ImageWidth"]}".trim()),
              'uri': resourceUri,
              'size': int.parse("${data_list2[i]["ResourceSize"]}".trim().contains("null")?"100":"${data_list2[i]["ResourceSize"]}".trim()),
            },
          );

          _addMessage(message);

        }

        /*
        if("${data_list2[i]["AuthorID"]}".trim()=="${_user.id}".trim()){
          dev.log("家長");
          //家長
          if("${data_list2[i]["Type"]}"=="text"){

            var textMessage = types.TextMessage(
              author: _user,
              createdAt: (DateTime.parse(data_list2[i]["CreatedAt"]).subtract(Duration(hours: (Platform.isIOS)?8:0)).millisecondsSinceEpoch).toInt(),
              id: data_list2[i]["MessageID"],
              text: data_list2[i]["Text"],
            );
            _addMessage(textMessage);
          }
          else if("${data_list2[i]["Type"]}"=="image"){

            String resourceUri = "${data_list2[i]["ResourceUri"]}";
            if(resourceUri.isNotEmpty){
              String _LINK = resourceUri.replaceAll("~/", "");
              resourceUri = "${IMAGE_IP}/${_LINK}";
            }

            final message = types.ImageMessage(
              author: _user,
              createdAt: (DateTime.parse(data_list2[i]["CreatedAt"]).subtract(Duration(hours: (Platform.isIOS)?8:0)).millisecondsSinceEpoch).toInt(),
              height: double.parse("${data_list2[i]["ImageHeight"]}"),
              id: "${data_list2[i]["MessageID"]}",
              name: "${data_list2[i]["ResourceUri"]}",
              size: int.parse("${data_list2[i]["ResourceSize"]}".contains("null")?"100":"${data_list2[i]["ResourceSize"]}"),
              uri: resourceUri,
              width: double.parse("${data_list2[i]["ImageWidth"]}"),
            );

            _addMessage(message);

          }

        }
        else{


        }

         */

      }

      //確認老師的訊息狀態改為已讀
      dev.log("確認訊息狀態改為已讀");
      String account = "${cUSTOMERs[this.index].sel_cUSTOMER_DL!.ACCOUNT}".trim();
      for(int i=0;i<data_list2.length;i++){
        String MessageID = data_list2[i]["MessageID"];
        String AuthorID = data_list2[i]["AuthorID"];
        if(AuthorID != account){
          update_MSRS_by_Status_sub(AuthorID:account,MessageID:MessageID,ChatID:ChatID);
        }
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }

  // For the testing purposes, you should probably use https://pub.dev/packages/uuid.
  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
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
    String AuthorFirstName= cUSTOMERs[this.index].sel_cUSTOMER_DL!.USER_NM;
    String AuthorLastName="";
    String CreatedAt="${DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)}";
    String Type="text";

    //處理群組多人已讀未讀狀態
    for(int i=0;i<cUSTOMERs[this.index].cLASS_NO_for_teacher.length;i++){
      String ACCOUNT = cUSTOMERs[this.index].cLASS_NO_for_teacher[i].ACCOUNT.trim();
      String comm = "INSERT INTO MSRS(ChatID,MessageID,AuthorID,Status) VALUES ('${ChatID}','${MessageID}','${ACCOUNT}','non_seen')";
      dev.log("${comm}");
      String result = await sql_command("${comm}");
      dev.log("result:${result}");
    }

    for(int i=0;i<cUSTOMERs[this.index].cUSTOMER_DLs.length;i++){
      if(cUSTOMERs[this.index].cUSTOMER_DLs[i]!.ACCOUNT.trim()!=user.ACCOUNT){
        String ACCOUNT = cUSTOMERs[this.index].cUSTOMER_DLs[i]!.ACCOUNT.trim();
        String comm = "INSERT INTO MSRS(ChatID,MessageID,AuthorID,Status) VALUES ('${ChatID}','${MessageID}','${ACCOUNT}','non_seen')";
        dev.log("${comm}");
        String result = await sql_command("${comm}");
        dev.log("result:${result}");
      }
    }

    String Status="";

    String Text=message;


    var textMessage = types.TextMessage(
        author: _user,
        createdAt: (dateTime.millisecondsSinceEpoch).toInt(),
        id: MessageID,
        text: message,
    );

    String comm = "INSERT INTO MSDL2(ChatID,MessageID,AuthorID,AuthorFirstName,AuthorLastName,CreatedAt,Type,Status,Text) VALUES ('${ChatID}','${MessageID}','${AuthorID}','${AuthorFirstName}','${AuthorLastName}','${CreatedAt}','${Type}','${Status}','${Text}')";
    dev.log("${comm}");
    String result = await sql_command("${comm}");
    dev.log("result:${result}");


    try{
      if(result.contains("執行成功")){

      }
      else{

      }
      message_TextEditingController.text="";
      setState(() {

      });



      read_message_sub();

      //先檢查該校使用時間
      comm = "SELECT * FROM AVAILABILITY_TIME_SETTING WHERE DEPM_NO = '${cUSTOMERs[this.index].DEPM_NO}'";
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

        //確定在通知時間區間,就發推播
        if (isNowInRange(START_TIME, END_TIME)) {

          for(int i=0;i<cUSTOMERs[this.index].cLASS_NO_for_teacher.length;i++){
            String FCM = await search_EMPLOYEE_fcm_sub(ACCOUNT:cUSTOMERs[this.index].cLASS_NO_for_teacher[i].ACCOUNT);
            await sendPushNotification(
                title: "${cUSTOMERs[this.index].sel_cUSTOMER_DL!.USER_NM} 家長",
                message: message,
                token: FCM,//cUSTOMERs[this.index].cLASS_NO_for_teacher[i].FCM,
                ChatID:ChatID.trim(),
                UserAccount:'${cUSTOMERs[this.index].sel_cUSTOMER_DL!.ACCOUNT.trim()}',
                TeacherAccount:"${cUSTOMERs[this.index].cLASS_NO_for_teacher[i].ACCOUNT}".trim()
            );
          }

          for(int i=0;i<cUSTOMERs[this.index].cUSTOMER_DLs.length;i++){
            if(cUSTOMERs[this.index].cUSTOMER_DLs[i]!.ACCOUNT!=user.ACCOUNT){
              String FCM = await search_EMPLOYEE_fcm_sub(ACCOUNT:cUSTOMERs[this.index].cUSTOMER_DLs[i]!.ACCOUNT);
              await sendPushNotification(
                  title: "${cUSTOMERs[this.index].sel_cUSTOMER_DL!.USER_NM} 家長",
                  message: message,
                  token: FCM,//cUSTOMERs[this.index].cUSTOMER_DLs[i]!.FCM,
                  ChatID:ChatID.trim(),
                  UserAccount:'${cUSTOMERs[this.index].sel_cUSTOMER_DL!.ACCOUNT.trim()}',
                  TeacherAccount:"${cUSTOMERs[this.index].cUSTOMER_DLs[i]!.ACCOUNT}".trim()
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
      String AuthorFirstName = cUSTOMERs[this.index].sel_cUSTOMER_DL!.USER_NM;
      String AuthorLastName="";
      String CreatedAt="${DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)}";
      String Type="image";

      //處理群組多人已讀未讀狀態
      for(int i=0;i<cUSTOMERs[this.index].cLASS_NO_for_teacher.length;i++){
        String ACCOUNT = cUSTOMERs[this.index].cLASS_NO_for_teacher[i].ACCOUNT.trim();
        String comm = "INSERT INTO MSRS(ChatID,MessageID,AuthorID,Status) VALUES ('${ChatID}','${MessageID}','${ACCOUNT}','non_seen')";
        dev.log("${comm}");
        String result = await sql_command("${comm}");
        dev.log("result:${result}");
      }
      for(int i=0;i<cUSTOMERs[this.index].cUSTOMER_DLs.length;i++){
        if(cUSTOMERs[this.index].cUSTOMER_DLs[i]!.ACCOUNT!=user.ACCOUNT){
          String ACCOUNT = cUSTOMERs[this.index].cUSTOMER_DLs[i]!.ACCOUNT.trim();
          String comm = "INSERT INTO MSRS(ChatID,MessageID,AuthorID,Status) VALUES ('${ChatID}','${MessageID}','${ACCOUNT}','non_seen')";
          dev.log("${comm}");
          String result = await sql_command("${comm}");
          dev.log("result:${result}");
        }
      }


      String Status="";

      String ResourceName=result.name;
      int ImageHeight=image.height;
      int ImageWidth=image.width;
      int ResourceSize = bytes.length;
      String? MimeType = lookupMimeType(result.path);
      String file_name = "${_user.id}_${DateFormat('yyyyMMddHHmmss').format(dateTime)}";
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

      String comm = "INSERT INTO MSDL2(ChatID,MessageID,AuthorID,AuthorFirstName,AuthorLastName,CreatedAt,Type,Status,ResourceName,ImageHeight,ImageWidth,MimeType,ResourceUri,ResourceSize) VALUES ('${ChatID}','${MessageID}','${AuthorID}','${AuthorFirstName}','${AuthorLastName}','${CreatedAt}','${Type}','${Status}','${ResourceName}','${ImageHeight}','${ImageWidth}','${MimeType}','${ResourceUri}','${ResourceSize}')";
      dev.log("${comm}");
      String _result = await sql_command("${comm}");
      dev.log("result:${result}");


      try{

        if(_result.contains("執行成功")){

        }
        else{

        }


        setState(() {

        });

        read_message_sub();

        //先檢查該校使用時間才可送出
        comm = "SELECT * FROM AVAILABILITY_TIME_SETTING WHERE DEPM_NO = '${cUSTOMERs[this.index].DEPM_NO}'";
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
            for(int i=0;i<cUSTOMERs[this.index].cLASS_NO_for_teacher.length;i++){
              String FCM = await search_EMPLOYEE_fcm_sub(ACCOUNT:cUSTOMERs[this.index].cLASS_NO_for_teacher[i].ACCOUNT);
              await sendPushNotification(
                  title: "${cUSTOMERs[0].sel_cUSTOMER_DL!.USER_NM} 家長",
                  message: "傳送一張圖片給您",
                  token: FCM,//cUSTOMERs[this.index].cLASS_NO_for_teacher[i].FCM,
                  ChatID:ChatID.trim(),
                  UserAccount:'${cUSTOMERs[0].sel_cUSTOMER_DL!.ACCOUNT.trim()}',
                  TeacherAccount:"${cUSTOMERs[this.index].cLASS_NO_for_teacher[i].ACCOUNT}".trim()
              );
            }
            for(int i=0;i<cUSTOMERs[this.index].cUSTOMER_DLs.length;i++){
              if(cUSTOMERs[this.index].cUSTOMER_DLs[i]!.ACCOUNT!=user.ACCOUNT){
                String FCM = await search_CUSTOMER_DL_fcm_sub(ACCOUNT:cUSTOMERs[this.index].cUSTOMER_DLs[i]!.ACCOUNT);
                await sendPushNotification(
                    title: "${cUSTOMERs[0].sel_cUSTOMER_DL!.USER_NM} 家長",
                    message: "傳送一張圖片給您",
                    token: FCM,//cUSTOMERs[this.index].cUSTOMER_DLs[i]!.FCM,
                    ChatID:ChatID.trim(),
                    UserAccount:'${cUSTOMERs[0].sel_cUSTOMER_DL!.ACCOUNT.trim()}',
                    TeacherAccount:"${cUSTOMERs[this.index].cUSTOMER_DLs[i]!.ACCOUNT}".trim()
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
    dev.log(">>>TextMessage:${message.type},${message.id}");
    if (message.type==MessageType.text) {
      dev.log(">>>TextMessage");
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

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
        onTap: (){
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          backgroundColor: Color(0xffffffff),
          appBar: CustomAppBar(
              //automaticallyImplyLeading:true,
            backgroundColor: Color(0xffF9AA88),
            toolbarHeight: 42.h,
            title: Text("聊天室", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xffffffff) , fontSize: 20.sp)),
            //Text("聊天室人數(${cUSTOMERs[this.index].cLASS_NO_for_teacher.length+cUSTOMERs[this.index].cUSTOMER_DLs.length})", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xffffffff) , fontSize: 20.sp)),
            centerTitle: false,
            actions: [
              /*
              Container(child:
              CircleAvatar(
                  backgroundColor: Color(0x01ED8522),
                  child: Padding(padding: EdgeInsets.all(8.w),
                      child:GestureDetector(
                          onTap: ()async{
                            final Uri launchUri = Uri(
                              scheme: 'tel',
                              path: "${_eMPLOYEEs[0].ACCOUNT}",
                            );
                            await launchUrl(launchUri);
                          },
                          child: SvgPicture.asset("assets/images/Icon feather-phone-call.svg"))))),

               */
              Container(width: 10.w,),
            ],
          ),
          body: Container(
              color: Color(0xffFAF7F2),
              padding: EdgeInsets.only(left:0.w,right: 10.w,bottom: 10.w),
              width: ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,child:Column(children: [

              Expanded(child:Stack(children: [

                chat_ui.Chat(
                  onEndReached: ()async{
                    if (!_isLoadingMore && _hasMore) {
                      _loadMoreMessages();
                    }
                  },
                  disableImageGallery: true, // ⬅️ 加上這一行關閉內建圖片預覽！
                  messages: _messages,
                  //onAttachmentPressed: _handleAttachmentPressed,
                  isLeftStatus: true,
                  textMessageOptions:  chat_ui.TextMessageOptions(
                    matchers: [
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
                  avatarBuilder: (user) {
                    final isCurrentUser = user.id == _user.id;


                    //先檢查非自己的留言,如為小孩的爸媽,則顯示姓,如為老師顯示"師"
                    String name = "師";
                    Color _coloe = const Color(0xffF9AA88);
                    for(int i=0;i<cUSTOMERs[this.index].cUSTOMER_DLs.length;i++){
                      if(user.firstName==cUSTOMERs[this.index].cUSTOMER_DLs[i]!.USER_NM){
                        name = user.firstName!.substring(0, 1);
                        _coloe = Colors.blue;
                        break;
                      }
                    }


                    return Padding(
                        padding: EdgeInsets.only(
                          right: isCurrentUser ? 0 : 8.w,
                          left: isCurrentUser ? 8.w : 0,
                        ),
                        child: CircleAvatar(
                          backgroundColor: _coloe,
                          radius: 16, // 可根據需要調整大小
                          child: Text(
                            '${name}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ));
                  },
                  showUserAvatars: true,
                  showUserNames: true, // 先關閉預設顯示名稱
                  user: _user,
                  dateIsUtc: false,
                  customStatusBuilder:customStatusBuilder,
                  customBottomWidget: Container(
                    width: ScreenUtil().screenWidth,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end, // 多行時按鈕貼齊底部
                      children: [
                        Container(width: 10.w),
                        GestureDetector(
                          onTap: () async {
                            if (ChatID.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "聊天室id為空,可嘗試回上一頁重新進入",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              return;
                            }
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
                          flex: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
                            // 設定最小初始高度與最大自適應延展高度
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
                                      // 啟用多行並支援 iOS 與 Android 軟體鍵盤換行
                                      keyboardType: TextInputType.multiline,
                                      textInputAction: TextInputAction.newline,
                                      minLines: 1,
                                      maxLines: 5, // 1~5 行內依文字內容自動長高，超過則內部滾動
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
                                  onTap: () async {
                                    if (ChatID.isEmpty) {
                                      Fluttertoast.showToast(
                                        msg: "聊天室id為空,可嘗試回上一頁重新進入",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                      return;
                                    }

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
                  //scrollController: _scrollController,
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


              ],)),


          ],))

        ));
  }
}
