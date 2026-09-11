import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:widget_zoom/widget_zoom.dart';
import 'DRUG_MT_T_page.dart';
import 'Daily_language_settings.dart';
import 'EXCUSED_page.dart';
import 'add_BLOG_page.dart';
import 'barcode_scanner_pageview.dart';
import 'chat.dart';
import 'chat_T_all.dart';
import 'draggable_fab.dart';
import 'edit_BLOG_page.dart';
import 'edit_DAILY_NOT_page.dart';
import 'fcm_notifity.dart';
import 'main.dart';
import 'signature_teacher.dart';
import 'student_T.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:floating_draggable_widget/floating_draggable_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:webdav_client/webdav_client.dart' as webdav_client;
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as dev;
import 'GROWING_T_page.dart';
import 'add_DAILY_ACT_page.dart';
import 'add_DAILY_CLN_page.dart';
import 'add_DAILY_CLS_page.dart';
import 'add_DAILY_CND_page.dart';
import 'add_DAILY_DRY_page.dart';
import 'add_DAILY_EAT_page.dart';
import 'add_DAILY_MLK_page.dart';
import 'add_DAILY_NOT_page.dart';
import 'add_DAILY_POP_page.dart';
import 'add_DAILY_RQD_page.dart';
import 'add_DAILY_SLP_page.dart';
import 'add_DAILY_TMP_page.dart';
import 'add_ROLLCALL_page.dart';
import 'api.dart';
import 'sql.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart' show parse;
import 'package:image_picker/image_picker.dart' as ImagePicker;
import 'package:badges/badges.dart' as badges;

Function? MyHomePage2_T_fun1;
Function? MyHomePage2_T_fun2;
Function? MyHomePage2_T_fun3;
Function? MyHomePage2_T_fun4;
Function? MyHomePage2_T_fun5;
class MyHomePage2_T extends StatefulWidget {

  @override
  State<MyHomePage2_T> createState() => _MyHomePage2_TState();
}

class _MyHomePage2_TState extends State<MyHomePage2_T> {



  String page = "班級";
  String page_notify_menu = "公佈欄";
  String page_notify_menu2 = "活動花絮";
  String page_notify_menu5 = "用藥委託";
  String page_notify_menu4 = "託藥訊息";

  var showModalBottomSheet_context;
  var showModalBottomSheet_image_context;
  var showModalBottomSheet_image_setState;
  ScrollController _scrollController = ScrollController();

  CUSTOMER CUSTOMER_selectedValue = CUSTOMER();
  CLASS _class = CLASS();
  DEPM _depm = DEPM();

  DateTime dateTime = DateTime.now();
  DateTime sel_datetime_2 = DateTime.now();
  DateTime sel_datetime_4 = DateTime.now();
  DateTime sel_datetime_7 = DateTime.now();

  TooltipBehavior? _tooltipBehavior;
  GlobalKey btnKey = GlobalKey();
  late PopupMenu menu;
  var showModalBottomSheet_GROWING_STANDARD_context;
  var showModalBottomSheet_GROWING_STANDARD_setState;

  bool checkbox = false;
  BuildContext? this_context;

  int _selectedIndex=0;

  @override
  void initState() {
    // TODO: implement initState

    DAILY_MT_TYPE_ITEMs.clear();
    DAILY_MT_TYPE_ITEMs_2.clear();

    user_is_login = true;
    _tooltipBehavior = TooltipBehavior(enable: true);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    MyHomePage2_T_fun1=({String type="",String CS_NO="",String DATE="",bool show_toast=true})async{
      if(type=="刷新點名紀錄"){
        await ROLLCALL_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
      }
      else if(type=="刷新活動花絮"){
        await BLOG_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");
      }
      else if(type=="刷新託藥訊息"){
        await read_for_DRUG_MT_db_sub(show_toast:show_toast);
      }
      else if(type=="前往家長已回簽通知單"){
        try{
          Student_T_page_fun!(action:"前往家長已回簽通知單");
        }
        catch(e){

        }
      }
      else if(type=="前往聊天室"){
        page="聯絡";
      }
      else if(type=="前往用藥委託"){

        page="班級";


      }
      else if(type=="前往接送委託"){

        page="班級";


      }
      else if(type=="前往請假委託"){

        page="班級";

      }
      else if(type=="前往聯絡簿回簽有備註"){

        page="班級";

      }
      setState(() {

      });
    };

    MyHomePage2_T_fun2=({String DAILY_NOT_NO="",String type="",String CS_NO="",String DATE="",bool show_toast=true})async{

      if(type=="前往用藥委託"){

        /*
        檢查該學生是否有用藥委託
         */
        if(DATE==DateFormat('yyyy-MM-dd').format(dateTime)){
          for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
            if(CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DRUG_MT=true;
            }
          }

          //在外部調用該 widget 的方法
          if (Student_T_page_WidgetKey.currentState != null) {
            Student_T_page_WidgetKey.currentState!.updateData(newData:"更新用藥委託數據");
          }

        }


      }
      else if(type=="前往用藥委託(刪除)"){

        dev.log("前往用藥委託(刪除):${CS_NO},${DATE},${DateFormat('yyyy-MM-dd').format(dateTime)}");

        /*
        檢查每位學生是否有請假委託
         */
        if(DATE=="${DateFormat('yyyy-MM-dd').format(dateTime)}") {

          for (int j = 0; j < EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length; j++) {
            if (CS_NO.trim() == EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
                .CS_NO) {
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
                  .is_DRUG_MT = false;
            }
          }

          //在外部調用該 widget 的方法
          if (Student_T_page_WidgetKey.currentState != null) {
            Student_T_page_WidgetKey.currentState!.updateData(newData:"更新用藥委託數據");
          }
        }

      }
      else if(type=="前往接送委託"){


        /*
        檢查每位學生是否有接送委託
         */
        if(DATE=="${DateFormat('yyyy-MM-dd').format(dateTime)}") {
          for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
            if(CS_NO.trim().trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_ENTRUSTED=true;
            }
          }

          //在外部調用該 widget 的方法
          if (Student_T_page_WidgetKey.currentState != null) {
            Student_T_page_WidgetKey.currentState!.updateData(newData:"更新接送委託數據");
          }
        }



      }
      else if(type=="前往接送委託(刪除)"){

        dev.log("前往接送委託(刪除):${CS_NO},${DATE},${DateFormat('yyyy-MM-dd').format(dateTime)}");

        /*
        檢查每位學生是否有請假委託
         */
        if(DATE=="${DateFormat('yyyy-MM-dd').format(dateTime)}") {

          for (int j = 0; j < EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length; j++) {
            if (CS_NO.trim() == EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
                .CS_NO) {
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
                  .is_ENTRUSTED = false;
            }
          }

          //在外部調用該 widget 的方法
          if (Student_T_page_WidgetKey.currentState != null) {
            Student_T_page_WidgetKey.currentState!.updateData(newData:"更新接送委託數據");
          }
        }

      }
      else if(type=="前往請假委託"){



        /*
        檢查每位學生是否有請假委託
         */
        if(DATE=="${DateFormat('yyyy-MM-dd').format(dateTime)}") {
          for (int j = 0; j < EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length; j++) {
            if (CS_NO.trim() ==
                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
                    .CS_NO) {
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
                  .is_EXCUSED = true;
            }
          }
          //在外部調用該 widget 的方法
          if (Student_T_page_WidgetKey.currentState != null) {
            Student_T_page_WidgetKey.currentState!.updateData(newData:"更新請假委託數據");
          }
        }

      }
      else if(type=="前往請假委託(刪除)"){

        dev.log("前往請假委託(刪除):${CS_NO},${DATE},${DateFormat('yyyy-MM-dd').format(dateTime)}");

        /*
        檢查每位學生是否有請假委託
         */
        if(DATE=="${DateFormat('yyyy-MM-dd').format(dateTime)}") {

          dev.log("前往請假委託(刪除):${CS_NO}");
          for (int j = 0; j < EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length; j++) {
            if (CS_NO.trim() == EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
                    .CS_NO) {
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j]
                  .is_EXCUSED = false;
            }
          }

          //在外部調用該 widget 的方法
          if (Student_T_page_WidgetKey.currentState != null) {
            Student_T_page_WidgetKey.currentState!.updateData(newData:"更新請假委託數據");
          }
        }

      }
      else if(type=="前往聯絡簿回簽有備註"){

        /*
        檢查每位學生家長聯絡簿是否已回簽
         */
        dev.log("檢查每位學生家長聯絡簿是否已回簽(${CS_NO.trim()},${DATE})");
        if(DATE=="${DateFormat('yyyy-MM-dd').format(dateTime)}"){
          for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
            if(CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
              dev.log("is_DAILY_PRS=true");
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DAILY_PRS=true;
            }
          }
          //在外部調用該 widget 的方法
          if (Student_T_page_WidgetKey.currentState != null) {
            Student_T_page_WidgetKey.currentState!.updateData(newData:"更新聯絡簿是否已回簽");
          }
        }


      }
      else if(type=="前往家長已回簽通知單"){

        try{
          Student_T_page_fun!(action:"前往家長已回簽通知單");
        }
        catch(e){

        }

        await read_DAILY_MT_TYPE_ITEM_db_sub();
        String comm = "SELECT * FROM View_DAILY WHERE CS_NO='${CS_NO}' AND NO='${DAILY_NOT_NO}'";
        dev.log("${comm}");
        try{
          String result = await sql_command("${comm}");
          List<dynamic> data_list = jsonDecode(result);
          data_list = trim_proc(data_list);
          if(data_list.length>0){
            View_DAILY v = View_DAILY();
            v.TYPE = "${data_list[0]["TYPE"]}"=="null"?"":"${data_list[0]["TYPE"]}".replaceAll(" ", "");
            v.NO = "${data_list[0]["NO"]}"=="null"?"":"${data_list[0]["NO"]}".replaceAll(" ", "");
            v.DEPM_NO = "${data_list[0]["DEPM_NO"]}"=="null"?"":"${data_list[0]["DEPM_NO"]}".replaceAll(" ", "");
            v.CS_NO = "${data_list[0]["CS_NO"]}"=="null"?"":"${data_list[0]["CS_NO"]}".replaceAll(" ", "");
            v.CLASS_NO = "${data_list[0]["CLASS_NO"]}"=="null"?"":"${data_list[0]["CLASS_NO"]}".replaceAll(" ", "");
            v.DATE = "${data_list[0]["DATE"]}"=="null"?"":"${data_list[0]["DATE"]}".replaceAll(" ", "");
            v.TIME = "${data_list[0]["TIME"]}"=="null"?"":"${data_list[0]["TIME"]}".replaceAll(" ", "");
            v.MARK = "${data_list[0]["MARK"]}"=="null"?"":"${data_list[0]["MARK"]}";
            Navigator.push(context, PageTransition(
                type: PageTransitionType.rightToLeft, child: Edit_DAILY_NOT_page(view_DAILY:v)));
          }
        }
        catch(e){

        }


      }
      setState(() {

      });
    };

    MyHomePage2_T_fun3=()async{
      setState(() {

      });
    };

    MyHomePage2_T_fun4=({String ROLLCALL_NO=""})async{
      //刪除該筆點名編號
      ROLLCALL_list.removeWhere((item) => item.NO == ROLLCALL_NO);
      setState(() {

      });
    };

    MyHomePage2_T_fun5=(){
      if(is_Student_T_page==true){
        try{
          Navigator.pop(context);
        }
        catch(e){

        }
      }
      _selectedIndex=2;
      page='聯絡';
      setState(() {

      });
    };

    Future.delayed(const Duration(milliseconds: 500), () {

      init();

    });

    Future.delayed(const Duration(milliseconds: 1000), () {

      check_app_version_sub();
      checkShouldShowDialog(context: context);
      is_login_main = true;

    });



  }


  void check_app_version_sub(){
    if (Platform.isAndroid) {
      //https://play.google.com/store/apps/details?id={package name}

      Map<String, String> headers = {
        //"Content-type": "application/json",
        "Cache-Control": "no-cache",
      };

      http.get(
          Uri.parse("${PLAY_STORE_URL}"),
          headers: headers)
          .timeout(const Duration(seconds: 15))
          .catchError((onError) {
        //print(onError);
        //ReTryDialog("錯誤","${onError.toString()}");
      })
          .then((response) {
        try {
          //dev.log("商店:${response.body}");
          var document = parse(response.body);

          //"^[0-9]{1}.[0-9]{1}.[0-9]{1}$"
          //<span class="htlgb">1.1.6</span>
          bool check = true; //document.outerHtml.contains("<span class=\"htlgb\">1.1.6</span>");
          //check = true;
          //print("check android version>>${check} ");

          String SfzRHd;
          if (check) {
            for (int i = 0; i < document
                .getElementsByClassName("SfzRHd")
                .length; i++) {
              SfzRHd = document
                  .getElementsByClassName("SfzRHd")
                  .elementAt(i)
                  .text;

              //SfzRHd = "⟪版本:1.8.5⟫1";
              //print("SfzRHd:${SfzRHd}");

              if (SfzRHd.contains(RegExp(r'^⟪版本:[0-9].[0-9].[0-9]⟫'))) {
                //print("SfzRHd>>:${SfzRHd}");
                String version = SfzRHd.replaceAll("版本:", "");
                version = version.substring(1, 1 + 5);
                //print("version>>:${version}");
                List<String> array = [];
                array = version.split(".");
                int _version = int.parse(
                    '${array.elementAt(0)}${array.elementAt(1)}${array
                        .elementAt(2)}');

                dev.log("android version:${_version}");
                if (_version > android_version) {
                  //檢查到有新版本
                  _showVersionDialog(this_context!,
                      '${array.elementAt(0)}.${array.elementAt(1)}.${array
                          .elementAt(2)}');
                }
                break;
              }
            }
          }
        }
        catch (e) {

        }
      });
    }
    else {
      Map<String, String> headers = {
        //"Content-type": "application/json",
        "Cache-Control": "no-cache",
      };

      http.get(
          Uri.parse("http://itunes.apple.com/tw/lookup?bundleId=com.huaweidigi.app2&t=${DateTime
              .now().millisecondsSinceEpoch}"), headers: headers)
          .timeout(const Duration(seconds: 15))
          .catchError((onError) {
        //print(onError);
        //ReTryDialog("錯誤","${onError.toString()}");
      })
          .then((response) {
        //print("response:${response.body}");

        Map<String, dynamic> map = jsonDecode(response.body);
        List<dynamic> results = map["results"];
        Map<String, dynamic> supportedDevices = results[0];
        //print("results:${results}");
        //print("supportedDevices[version]:${supportedDevices["version"]}");
        String version = "${supportedDevices["version"]}";


        List<String> array = [];
        array = version.split(".");
        int _version = int.parse(
            '${array.elementAt(0)}${array.elementAt(1)}${array.elementAt(
                2)}');

        //print("ios version:${_version}");

        if (_version > ios_version) {
          //檢查到有新版本
          _showVersionDialog(this_context!,
              '${array.elementAt(0)}.${array.elementAt(1)}.${array.elementAt(
                  2)}');
        }
      });
    }
  }

  //Show Dialog to force user to update
  _showVersionDialog(BuildContext __context , String str) async {
    await showDialog<String>(
      context: __context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String title = "有新的更新可用 版本:${str}";
        String message =
            "有可用的較新版本的應用程式(威寶通)，請立即更新。";
        String btnLabel = "現在更新";
        String btnLabelCancel = "稍後更新";
        return Platform.isIOS
            ? new CupertinoAlertDialog(
          title: Text(title,textScaler: const TextScaler.linear(1),style: TextStyle(color:Colors.black,fontSize: 16.sp),),
          content: Text(message,textScaler: const TextScaler.linear(1),style: TextStyle(color:Colors.black,fontSize: 14.sp)),
          actions: <Widget>[
            TextButton(
              child: Text(btnLabel,textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 14.sp,color: Colors.blue)),
              onPressed: () => _launchURL(APP_STORE_URL),
            ),
            TextButton(
              child: Text(btnLabelCancel,textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 14.sp,color: Colors.blue)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        )
            : AlertDialog(
          title: Text(title,textScaler: const TextScaler.linear(1),style: TextStyle(color:Colors.black,fontSize: 16.sp),),
          content: Text(message,textScaler: const TextScaler.linear(1),style: TextStyle(color:Colors.black,fontSize: 14.sp)),
          actions: <Widget>[
            TextButton(
              child: Text(btnLabel,textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 14.sp,color: Colors.blue)),
              onPressed: () => _launchURL(PLAY_STORE_URL),
            ),
            TextButton(
              child: Text(btnLabelCancel,textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 14.sp,color: Colors.blue)),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }


  _launchURL(var url) async {
    //const url = 'https://flutter.dev';
    Navigator.pop(this_context!);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void init()async{
    SmartDialog.showLoading(msg:"初始化中...，請稍候",
      clickMaskDismiss: false, // 禁止點擊遮罩關閉
      backDismiss: false,      // 禁止按返回鍵關閉（可選）
    );
    EMPLOYEE_teacher.Teacher_CUSTOMERs.clear();
    //await BULLETIN_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(sel_datetime_1)}");
    await ENTRUSTED_TYPE_ITEM_db_sub();
    await DRUG_CANCEL_REASON_db_sub();
    await EXCUSED_HOURS_ITEM_db_sub();
    await EXCUSED_REASON_ITEM_db_sub();
    await CFM_ITEM_db_sub();
    await DRUG_STORE_ITEM_db_sub();
    await DRUG_UNIT_ITEM_db_sub();
    await DRUG_MODE_ITEM_db_sub();
    await ROLLCALL_ITEMS_db_sub();
    await BULLETIN_SORT_ITEM_db_sub();
    await DEPM_db_sub();
    await CLASS_db_sub();
    SmartDialog.showLoading(msg:"載入老師資料...，請稍候",
      clickMaskDismiss: false, // 禁止點擊遮罩關閉
      backDismiss: false,      // 禁止按返回鍵關閉（可選）
    );
    await EMPLOYEE_db_sub();
    is_finish_load = true;
    await ROLLCALL_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
    await BLOG_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");
    ChatPage_T_all_fun1!();
    //await read_DAILY_MT_TYPE_ITEM_db_sub();
    //await BULLETIN_db_sub();
    SmartDialog.dismiss();
    setState(() {

    });
    is_finish_load = true;

  }


  Future<void> read_DAILY_MT_TYPE_ITEM_db_sub()async{

    //DAILY_MT_TYPE_ITEMs_2.clear();
    //DAILY_MT_TYPE_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_MT_TYPE_ITEM WHERE DEPM_NO='${EMPLOYEE_teacher.DEPM_NO}'";
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

        List<DAILY_MT_TYPE_ITEM> _DAILY_MT_TYPE_ITEMs = [];
        List<DAILY_MT_TYPE_ITEM> _DAILY_MT_TYPE_ITEMs_2 = [];
        for(int i=0;i<data_list.length;i++){
          DAILY_MT_TYPE_ITEM v = DAILY_MT_TYPE_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}".contains("null")?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}".contains("null")?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          v.VISABLE = "${data_list[i]["VISABLE"]}"=="null"?true:("${data_list[i]["VISABLE"]}".contains("0")||"${data_list[i]["VISABLE"]}".contains("false"))?false:true;

          if(v.ITEM_NO=="ACT"){
            v.color = Colors.cyan;
            v.svg_icon = SvgPicture.asset("assets/images/Icon material-sports-handball.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="MLK"){
            v.color = Colors.blueAccent;
            v.svg_icon = SvgPicture.asset("assets/images/组 29134.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="POP"){
            v.color = Colors.redAccent;
            v.svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-poop.svg",color: v.color);
          }
          else if(v.ITEM_NO=="CLN"){
            v.color = Colors.pinkAccent;
            v.svg_icon = SvgPicture.asset("assets/images/Icon core-shower.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="CLS"){
            v.color = Colors.green;
            v.svg_icon = SvgPicture.asset("assets/images/Icon ion-shirt-sharp.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="EAT"){
            v.color = Colors.orange;
            v.svg_icon = SvgPicture.asset("assets/images/Icon material-food-bank.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="DRY"){
            v.color = Colors.lightGreen;
            v.svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-file-signature.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="TMP"){
            v.color = Colors.deepPurpleAccent;
            v.svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-temperature-full.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="SLP"){
            v.color = Colors.lightBlueAccent;
            v.svg_icon = SvgPicture.asset("assets/images/组 29166.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="RQD"){
            v.color = Colors.purpleAccent;
            v.svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-basket-shopping.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="CND"){
            v.color = Colors.amber;
            v.svg_icon = SvgPicture.asset("assets/images/Icon ion-body-sharp.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="NOT"){
            v.color = Colors.pink;
            v.svg_icon = SvgPicture.asset("assets/images/Icon material-notifications-none-4.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="POV"){
            v.color = Colors.cyanAccent;
            v.svg_icon = Text("📒",textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 24.sp),);
          }
          if(v.VISABLE == true) {
            _DAILY_MT_TYPE_ITEMs.add(v);
          }
        }
        _DAILY_MT_TYPE_ITEMs_2.addAll(_DAILY_MT_TYPE_ITEMs);
        //DAILY_MT_TYPE_ITEMs_2.addAll(DAILY_MT_TYPE_ITEMs);
        //DAILY_MT_TYPE_ITEMs.removeWhere((e){ return e.ITEM_NO=="NOT"; });
        //DAILY_MT_TYPE_ITEMs_2.removeWhere((e){ return e.ITEM_NO=="NOT"; });

        DAILY_MT_TYPE_ITEM v = DAILY_MT_TYPE_ITEM();
        v.ITEM_NM = "健康紀錄";
        v.ITEM_NO = "健康紀錄";
        v.color = Colors.deepPurpleAccent;
        v.svg_icon = SvgPicture.asset("assets/images/组 29165.svg",color: v.color);
        _DAILY_MT_TYPE_ITEMs.add(v);

        DAILY_MT_TYPE_ITEM v1 = DAILY_MT_TYPE_ITEM();
        v1.ITEM_NM = "成長曲線";
        v1.ITEM_NO = "成長曲線";
        v1.color = Colors.amber;
        v1.svg_icon = SvgPicture.asset("assets/images/Icon material-auto-stories.svg",color: v1.color,);
        _DAILY_MT_TYPE_ITEMs.add(v1);

        DAILY_MT_TYPE_ITEM v2 = DAILY_MT_TYPE_ITEM();
        v2.ITEM_NM = "到/離校";
        v2.ITEM_NO = "到/離校";
        v2.color = Colors.lightGreen;
        v2.svg_icon = SvgPicture.asset("assets/images/Icon material-access-time.svg",color: v2.color,);
        _DAILY_MT_TYPE_ITEMs.add(v2);
        _DAILY_MT_TYPE_ITEMs_2.add(v2);

        DAILY_MT_TYPE_ITEMs = _DAILY_MT_TYPE_ITEMs;
        DAILY_MT_TYPE_ITEMs_2 = _DAILY_MT_TYPE_ITEMs_2;

        /*
        int add_count1 = 4-((DAILY_MT_TYPE_ITEMs.length % 4)==0?4:(DAILY_MT_TYPE_ITEMs.length % 4));
        int add_count2 = 4-((DAILY_MT_TYPE_ITEMs_2.length % 4)==0?4:(DAILY_MT_TYPE_ITEMs_2.length % 4));
        DAILY_MT_TYPE_ITEM v3 = DAILY_MT_TYPE_ITEM();
        v3.ITEM_NM = "";
        v3.ITEM_NO = "";
        v3.color = Colors.transparent;
        v3.svg_icon = SvgPicture.asset("assets/images/Icon material-access-time.svg",color: v3.color,);
        for(int i=0;i<add_count1;i++){
          DAILY_MT_TYPE_ITEMs.add(v3);
        }
        dev.log("add_count2:${add_count2}");
        for(int i=0;i<add_count2;i++){
          DAILY_MT_TYPE_ITEMs_2.add(v3);
        }

         */


      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  /*
  刪除活動花絮
   */
  Future<void>delete_BLOG_db_sub({String BLOG_NO=""})async{


    String comm = "DELETE FROM BLOG WHERE BLOG_NO='${BLOG_NO}'";
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
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }

  Future<void>delete_BLOG_DL_db_sub({String BLOG_NO=""})async{

    //EasyLoading.show(status: "處理中...");
    String comm = "DELETE FROM BLOG_DL WHERE BLOG_NO='${BLOG_NO}'";
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
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }


  Future<void>DRUG_CANCEL_REASON_db_sub()async{

    DRUG_CANCEL_REASONs.clear();
    String comm = "SELECT * FROM DRUG_CANCEL_REASON";
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
        for(int j=0;j<data_list.length;j++){
          DRUG_CANCEL_REASON ss = DRUG_CANCEL_REASON();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          ss.LINK = "${data_list[j]["LINK"]}";
          ss.LINK = ss.LINK.replaceAll("~/", "");
          ss.LINK = "${IMAGE_IP}/${ss.LINK}";
          DRUG_CANCEL_REASONs.add(ss);
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

  Future<void>EXCUSED_HOURS_ITEM_db_sub()async{

    EXCUSED_HOURS_ITEM_list.clear();
    String comm = "SELECT * FROM EXCUSED_HOURS_ITEM";
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
        for(int j=0;j<data_list.length;j++){
          EXCUSED_HOURS_ITEM ss = EXCUSED_HOURS_ITEM();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          EXCUSED_HOURS_ITEM_list.add(ss);
          sel_EXCUSED_HOURS_ITEM = EXCUSED_HOURS_ITEM_list[0];
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

  Future<void>EXCUSED_REASON_ITEM_db_sub()async{

    EXCUSED_REASON_ITEM_list.clear();
    String comm = "SELECT * FROM EXCUSED_REASON_ITEM";
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
        for(int j=0;j<data_list.length;j++){
          EXCUSED_REASON_ITEM ss = EXCUSED_REASON_ITEM();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          EXCUSED_REASON_ITEM_list.add(ss);
          sel_EXCUSED_REASON_ITEM = EXCUSED_REASON_ITEM_list[0];
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

  Future<void>CFM_ITEM_db_sub()async{

    CFM_ITEM_list.clear();
    String comm = "SELECT * FROM CFM_ITEM";
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
        for(int j=0;j<data_list.length;j++){
          CFM_ITEM ss = CFM_ITEM();
          ss.CFM_NO = "${data_list[j]["CFM_NO"]}";
          ss.CFM_NM = "${data_list[j]["CFM_NM"]}";
          CFM_ITEM_list.add(ss);
          sel_CFM_ITEM = CFM_ITEM_list[0];
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


  /*
  老師資料(EMPLOYEE)
   */
  Future<void>EMPLOYEE_db_sub()async{

    eMPLOYEEs.clear();
    String comm = "SELECT * FROM EMPLOYEE";
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
        dev.log("data_list.length:${data_list.length}");
        for(int j=0;j<data_list.length;j++){
          EMPLOYEE ss = EMPLOYEE();
          ss.EMP_NO = "${data_list[j]["EMP_NO"]}".contains("null")?"":"${data_list[j]["EMP_NO"]}";
          ss.EMP_NM = "${data_list[j]["EMP_NM"]}".contains("null")?"":"${data_list[j]["EMP_NM"]}";
          ss.RANK = "${data_list[j]["RANK"]}".contains("null")?"":"${data_list[j]["RANK"]}";
          ss.DEPM_NO = "${data_list[j]["DEPM_NO"]}".contains("null")?"":"${data_list[j]["DEPM_NO"]}";
          ss.CLASS_NO = "${data_list[j]["CLASS_NO"]}".contains("null")?"":"${data_list[j]["CLASS_NO"]}";
          ss.ACCOUNT = "${data_list[j]["ACCOUNT"]}".contains("null")?"":"${data_list[j]["ACCOUNT"]}".replaceAll(" ", "");
          ss.PASSWORD = "${data_list[j]["PASSWORD"]}".contains("null")?"":"${data_list[j]["PASSWORD"]}";
          ss.password_TextEditingController.text=ss.PASSWORD;
          ss.STATUS = "${data_list[j]["STATUS"]}".contains("null")?"":"${data_list[j]["STATUS"]}";
          ss.ADD_DT = "${data_list[j]["ADD_DT"]}".contains("null")?"":"${data_list[j]["ADD_DT"]}";
          ss.ADD_USER = "${data_list[j]["ADD_USER"]}".contains("null")?"":"${data_list[j]["ADD_USER"]}";
          ss.TOKEN_ID = "${data_list[j]["TOKEN_ID"]}".contains("null")?"":"${data_list[j]["TOKEN_ID"]}";
          ss.STATUS = "${data_list[j]["STATUS"]}".contains("null")?"":"${data_list[j]["STATUS"]}";
          ss.FCM = "${data_list[j]["FCM"]}".contains("null")?"":"${data_list[j]["FCM"]}";
          ss.RESERVE1 = "${data_list[j]["RESERVE1"]}".contains("null")?"":"${data_list[j]["RESERVE1"]}";
          ss.RESERVE2 = "${data_list[j]["RESERVE2"]}".contains("null")?"":"${data_list[j]["RESERVE2"]}";
          ss.SIGN_LINK = "${data_list[j]["SIGN_LINK"]}".contains("null")?"":"${data_list[j]["SIGN_LINK"]}";
          String SIGN_LINK = "${data_list[j]["SIGN_LINK"]}".replaceAll("~/", "");
          ss.SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK}";
          eMPLOYEEs.add(ss);
        }
        for(int i=0;i<eMPLOYEEs.length;i++){
          if(eMPLOYEEs[i].ACCOUNT==user.ACCOUNT){

            EMPLOYEE_teacher = eMPLOYEEs[i];
            dev.log("EMPLOYEE_teacher.DEPM_NO:${EMPLOYEE_teacher.DEPM_NO}");
            break;
          }
        }

        if(EMPLOYEE_teacher.RANK=="M"){
          //學校主管底下多個班級
          for(int j=0;j<cLASSs.length;j++){
            //dev.log("EMPLOYEE_teacher.DEPM_NO:${EMPLOYEE_teacher.DEPM_NO},(${cLASSs[j].DEPM_NO})");
            if(EMPLOYEE_teacher.DEPM_NO==cLASSs[j].DEPM_NO){
              EMPLOYEE_teacher.CLASS_NOs.add(cLASSs[j].CLASS_NO);
            }
          }

          dev.log("學校主管底下多個班級:${EMPLOYEE_teacher.CLASS_NOs.length}");
        }
        else{


          /*
        老師底下多個班級
         */
          for(int i=0;i<cLASSs.length;i++){
            if(cLASSs[i].CLASS_NO==user.CLASS_NO){
              EMPLOYEE_teacher.CLASS_NOs.add(cLASSs[i].CLASS_NO);
            }
          }

          dev.log("EMPLOYEE_teacher.CLASS_NOs.length:${EMPLOYEE_teacher.CLASS_NOs.length}");
        }


        for(int i=0;i<EMPLOYEE_teacher.CLASS_NOs.length;i++){
          for(int j=0;j<cLASSs.length;j++){
            if(EMPLOYEE_teacher.CLASS_NOs[i]==cLASSs[j].CLASS_NO){
              Teacher_CUSTOMER t = Teacher_CUSTOMER();
              t.cLASS = cLASSs[j];
              EMPLOYEE_teacher.Teacher_CUSTOMERs.add(t);
            }
          }
        }

        if(EMPLOYEE_teacher.Teacher_CUSTOMERs.length>0){
          EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue = EMPLOYEE_teacher.Teacher_CUSTOMERs[0];
          user.CLASS_NO = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO;
          user.DEPM_NO = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO;
        }

        SmartDialog.showLoading(msg:"載入班級-學生資料...，請稍候",
          clickMaskDismiss: false, // 禁止點擊遮罩關閉
          backDismiss: false,      // 禁止按返回鍵關閉（可選）
        );
        // 1. 收集所有 CLASS_NO
        List<String> CLASS_NOs = EMPLOYEE_teacher.Teacher_CUSTOMERs
            .map((c) => "'${c.cLASS.CLASS_NO}'") // 注意加上引號
            .toList();

        // 2. 組合成 IN 的 SQL 字串
        String CLASS_NOsList = CLASS_NOs.join(",");
        String comm = """
SELECT * 
FROM CUSTOMER
WHERE CLASS_NO IN (${CLASS_NOsList}) AND STATUS='Y' 
""";
        String result = await sql_command(comm);
        try {
          List<dynamic> list = jsonDecode(result);
          List<dynamic> data_list = [];
          data_list = list;
          data_list = trim_proc(data_list);
          if (data_list.length == 0) {}
          else {
            for (int i = 0; i < data_list.length; i++) {
              CUSTOMER b = CUSTOMER();
              b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")
                  ? ""
                  : "${data_list[i]["CS_NO"]}";
              b.CS_NM = "${data_list[i]["CS_NM"]}".contains("null")
                  ? ""
                  : "${data_list[i]["CS_NM"]}";
              b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")
                  ? ""
                  : "${data_list[i]["DEPM_NO"]}";
              b.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")
                  ? ""
                  : "${data_list[i]["CLASS_NO"]}";
              b.STATUS = "${data_list[i]["STATUS"]}".contains("null")
                  ? ""
                  : "${data_list[i]["STATUS"]}";
              b.BIRTHDAY = "${data_list[i]["BIRTHDAY"]}".contains("null")
                  ? ""
                  : "${data_list[i]["BIRTHDAY"]}";
              b.SEX = "${data_list[i]["SEX"]}".contains("null")
                  ? ""
                  : "${data_list[i]["SEX"]}";
              b.PICTURE_LINK =
              "${data_list[i]["PICTURE_LINK"]}".contains("null")
                  ? ""
                  : "${data_list[i]["PICTURE_LINK"]}";
              String PICTURE_LINK = b.PICTURE_LINK.replaceAll("~/", "");
              b.PICTURE_LINK = "${IMAGE_IP}/${PICTURE_LINK}";
              b.ADD_DT = "${data_list[i]["ADD_DT"]}".contains("null")
                  ? ""
                  : "${data_list[i]["ADD_DT"]}";
              b.ADD_USER = "${data_list[i]["ADD_USER"]}".contains("null")
                  ? ""
                  : "${data_list[i]["ADD_USER"]}";
              b.NOTE = "${data_list[i]["NOTE"]}".contains("null")
                  ? ""
                  : "${data_list[i]["NOTE"]}";
              for (int j = 0; j <
                  EMPLOYEE_teacher.Teacher_CUSTOMERs.length; j++) {
                if (EMPLOYEE_teacher.Teacher_CUSTOMERs[j].cLASS.CLASS_NO ==
                    b.CLASS_NO) {
                  EMPLOYEE_teacher.Teacher_CUSTOMERs[j].cUSTOMERs.add(b);
                }
              }
            }
          }
        }
        catch(e){

        }

        EMPLOYEE_teacher.Teacher_CUSTOMERs.forEach((t) {
          t.cUSTOMERs.sort((a, b) => a.CS_NM.compareTo(b.CS_NM));
        });

        setState(() {

        });

        SmartDialog.showLoading(msg:"載入班級-家長資料...，請稍候",
          clickMaskDismiss: false, // 禁止點擊遮罩關閉
          backDismiss: false,      // 禁止按返回鍵關閉（可選）
        );

        // 1. 收集所有 csNos
        List<String> csNos = EMPLOYEE_teacher.Teacher_CUSTOMERs
            .expand((t) => t.cUSTOMERs)
            .map((c) => c.CS_NO)
            .toSet()
            .toList();

        // 2. 組合成 IN 的 SQL 字串
        String csNoList = csNos.map((e) => "'$e'").join(",");

        comm = """
SELECT * 
FROM CUSTOMER_DL
WHERE CS_NO IN (${csNoList}) 
""";
        result = await sql_command(comm);
        try{
          List<dynamic> list = jsonDecode(result);
          List<dynamic> data_list = [];
          data_list = list;
          data_list = trim_proc(data_list);
          if(data_list.length==0){
          }
          else{

            for(int i=0;i<data_list.length;i++){
              CUSTOMER_DL b = CUSTOMER_DL();
              b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}";
              b.CS_SR = "${data_list[i]["CS_SR"]}".contains("null")?"":"${data_list[i]["CS_SR"]}";
              b.ACCOUNT = "${data_list[i]["ACCOUNT"]}".contains("null")?"":"${data_list[i]["ACCOUNT"]}";
              b.PASSWORD = "${data_list[i]["PASSWORD"]}".contains("null")?"":"${data_list[i]["PASSWORD"]}";
              b.USER_NM = "${data_list[i]["USER_NM"]}".contains("null")?"":"${data_list[i]["USER_NM"]}";
              b.RANK = "${data_list[i]["RANK"]}".contains("null")?"":"${data_list[i]["RANK"]}";
              b.TOKEN_ID = "${data_list[i]["TOKEN_ID"]}".contains("null")?"":"${data_list[i]["TOKEN_ID"]}";
              b.SIGN_LINK = "${data_list[i]["SIGN_LINK"]}".contains("null")?"":"${data_list[i]["SIGN_LINK"]}";
              if(b.SIGN_LINK.isNotEmpty){
                String SIGN_LINK = b.SIGN_LINK.replaceAll("~/", "");
                b.SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK}";
              }
              b.FCM = "${data_list[i]["FCM"]}".contains("null")?"":"${data_list[i]["FCM"]}";
              b.new_password_TextEditingController.text="";
              b.password_TextEditingController.text="";
              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMERs.length;j++){
                for(int k=0;k<EMPLOYEE_teacher.Teacher_CUSTOMERs[j].cUSTOMERs.length;k++){
                  if(EMPLOYEE_teacher.Teacher_CUSTOMERs[j].cUSTOMERs[k].CS_NO==b.CS_NO){
                    EMPLOYEE_teacher.Teacher_CUSTOMERs[j].cUSTOMERs[k].cUSTOMER_DLs.add(b);
                  }
                }
              }

            }


            setState(() {

            });


          }

        }
        catch(e){
          dev.log("${e}");
          //SmartDialog.showToast("網路異常");
        }

        /*
        for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMERs.length;i++){
          SmartDialog.showLoading(msg:"載入班級-學生資料...(${i+1}/${EMPLOYEE_teacher.Teacher_CUSTOMERs.length})，請稍候",
            clickMaskDismiss: false, // 禁止點擊遮罩關閉
            backDismiss: false,      // 禁止按返回鍵關閉（可選）
          );
          await read_for_CUSTOMER_db_sub(CLASS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cLASS.CLASS_NO}",index:i);
        }

        for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMERs.length;i++){
          SmartDialog.showLoading(msg:"載入班級-家長資料...(${i+1}/${EMPLOYEE_teacher.Teacher_CUSTOMERs.length})，請稍候",
            clickMaskDismiss: false, // 禁止點擊遮罩關閉
            backDismiss: false,      // 禁止按返回鍵關閉（可選）
          );
          for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs.length;j++){
            await read_for_CUSTOMER_DL_db_sub(CS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs[j].CS_NO}",index: i,index2:j);
          }
        }

         */

        for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMERs.length;i++){
          for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs.length;j++){
            EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs[j].cLASS_NO_for_teacher.clear();
            for(int k=0;k<eMPLOYEEs.length;k++){
              if(EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs[j].CLASS_NO==eMPLOYEEs[k].CLASS_NO){
                EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs[j].cLASS_NO_for_teacher.add(eMPLOYEEs[k]);
              }
            }
          }
        }
        dev.log("學生:${EMPLOYEE_teacher.Teacher_CUSTOMERs[0].cUSTOMERs[0].CS_NM},老師:${EMPLOYEE_teacher.Teacher_CUSTOMERs[0].cUSTOMERs[0].cLASS_NO_for_teacher.length}");


        /*
        檢查每位學生是否有用藥委託
         */
        await read_for_DRUG_MT_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
        for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
          for(int k=0;k<DRUG_MT_list.length;k++){
            if(DRUG_MT_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DRUG_MT=true;
            }
          }
        }


        /*
        檢查每位學生是否有請假委託
         */
        await read_for_EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
        for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
          for(int k=0;k<EXCUSED_list.length;k++){
            if(EXCUSED_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_EXCUSED=true;
            }
          }
        }

        /*
        檢查每位學生是否有接送委託
         */
        await read_for_ENTRUSTED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
        for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
          for(int k=0;k<entrusted_pick_and_drop_list.length;k++){
            if(entrusted_pick_and_drop_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_ENTRUSTED=true;
            }
          }
        }

        /*
        檢查每位學生家長聯絡簿是否已回簽
         */
        await read_for_DAILY_PRS_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
        for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
          for(int k=0;k<DAILY_PRSs.length;k++){
            if(DAILY_PRSs[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DAILY_PRS=true;
              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_STATUS=DAILY_PRSs[k].STATUS=='老師已讀'?true:false;
            }
          }
        }





      }

      setState(() {

      });

    }
    catch(e){
      dev.log("=====>${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }


  Future<void>read_for_ENTRUSTED_db_sub({String datetime="",bool show_toast = true})async{
    FocusManager.instance.primaryFocus?.unfocus();
    if(show_toast==true) {
      SmartDialog.showLoading(msg: "處理中...");
    }
    await Future.delayed(const Duration(milliseconds: 500), () {});

    List<String> CS_NOs = [];
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      CS_NOs.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO);
    }

    //檢查學生是否為0
    if(CS_NOs.length==0){
      SmartDialog.dismiss();
      SmartDialog.showToast("目前無學生在此班級");
      return;
    }

    String CS_NO_json = jsonEncode(CS_NOs.toList());
    CS_NO_json = CS_NO_json.replaceAll("[", "(");
    CS_NO_json = CS_NO_json.replaceAll("]", ")");
    CS_NO_json = CS_NO_json.replaceAll("\"", "'");


    //dev.log("CS_NO_json:${CS_NO_json}");

    /*
    String YEAR="";
    String MONTH="";
    if(datetime.contains("-")) {
      YEAR = datetime.split("-").elementAt(0);
      MONTH = datetime.split("-").elementAt(1);
    }

     */

    entrusted_pick_and_drop_list.clear();
    setState(() {

    });

    //datetime = DateFormat("yyyy-MM-dd").format(DateTime.now());

    String result = await sql_command("SELECT * FROM ENTRUSTED WHERE (CS_NO in ${CS_NO_json}) AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'");
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
        List<Entrusted_pick_and_drop>  _entrusted_pick_and_drop_list=[];
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
          if(b.DEL.isEmpty){
            _entrusted_pick_and_drop_list.add(b);
          }

        }
        entrusted_pick_and_drop_list = _entrusted_pick_and_drop_list;
        entrusted_pick_and_drop_list.sort((a,b) => b.DATE.compareTo(a.DATE));


        setState(() {

        });

        /*
        明細
         */
        /*
        for(int i=0;i<entrusted_pick_and_drop_list.length;i++){
          await read_for_ENTRUSTED_DL_db_sub(NO:entrusted_pick_and_drop_list[i].NO,index: i);
        }

         */




      }



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }

  /*
  學校(DEPM)
   */
  Future<void>DEPM_db_sub()async{

    dEPMs.clear();
    String comm = "SELECT * FROM DEPM";
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
        for(int j=0;j<data_list.length;j++){
          DEPM ss = DEPM();
          ss.DEPM_NO = "${data_list[j]["DEPM_NO"]}".contains("null")?"":"${data_list[j]["DEPM_NO"]}";
          ss.DEPM_NM = "${data_list[j]["DEPM_NM"]}".contains("null")?"":"${data_list[j]["DEPM_NM"]}";
          ss.DEPM_NM_S = "${data_list[j]["DEPM_NM_S"]}".contains("null")?"":"${data_list[j]["DEPM_NM_S"]}";
          ss.FB_URL = "${data_list[j]["FB_URL"]}".contains("null")?"":"${data_list[j]["FB_URL"]}";
          ss.ADDRESS = "${data_list[j]["ADDRESS"]}".contains("null")?"":"${data_list[j]["ADDRESS"]}";
          ss.TELEPHONE = "${data_list[j]["TELEPHONE"]}".contains("null")?"":"${data_list[j]["TELEPHONE"]}";
          ss.EMAIL = "${data_list[j]["EMAIL"]}".contains("null")?"":"${data_list[j]["EMAIL"]}";
          ss.NOTE = "${data_list[j]["NOTE"]}".contains("null")?"":"${data_list[j]["NOTE"]}";
          dEPMs.add(ss);
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


  /*
  班級(CLASS)
   */
  Future<void>CLASS_db_sub()async{

    cLASSs.clear();
    String comm = "SELECT * FROM CLASS";
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
        for(int j=0;j<data_list.length;j++){
          CLASS ss = CLASS();
          ss.CLASS_NO = "${data_list[j]["CLASS_NO"]}".contains("null")?"":"${data_list[j]["CLASS_NO"]}";
          ss.CLASS_NM = "${data_list[j]["CLASS_NM"]}".contains("null")?"":"${data_list[j]["CLASS_NM"]}";
          ss.DEPM_NO = "${data_list[j]["DEPM_NO"]}".contains("null")?"":"${data_list[j]["DEPM_NO"]}";
          ss.TYPE = "${data_list[j]["TYPE"]}".contains("null")?"":"${data_list[j]["TYPE"]}";
          ss.ICON_PICTURE_LINK = "${data_list[j]["ICON_PICTURE_LINK"]}".contains("null")?"":"${data_list[j]["ICON_PICTURE_LINK"]}";
          ss.VISABLE = "${data_list[j]["VISABLE"]}".contains("null")?"":"${data_list[j]["VISABLE"]}";
          ss.NOTE = "${data_list[j]["NOTE"]}".contains("null")?"":"${data_list[j]["NOTE"]}";
          cLASSs.add(ss);
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


  /*
  BULLETIN_SORT_ITEM
   */
  Future<void>BULLETIN_SORT_ITEM_db_sub()async{

    BULLETIN_SORT_ITEM_list.clear();
    String comm = "SELECT * FROM BULLETIN_SORT_ITEM";
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
        for(int j=0;j<data_list.length;j++){
          BULLETIN_SORT_ITEM ss = BULLETIN_SORT_ITEM();
          ss.SORT_ID = "${data_list[j]["SORT_ID"]}";
          ss.SORT_NM = "${data_list[j]["SORT_NM"]}";
          BULLETIN_SORT_ITEM_list.add(ss);
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


  /*
  DRUG_STORE_ITEM
   */
  Future<void>DRUG_STORE_ITEM_db_sub()async{

    dRUG_STORE.DRUG_STORE_ITEM_list.clear();
    String comm = "SELECT * FROM DRUG_STORE_ITEM";
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
        for(int j=0;j<data_list.length;j++){
          DRUG_STORE_ITEM ss = DRUG_STORE_ITEM();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          dRUG_STORE.DRUG_STORE_ITEM_list.add(ss);
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

  /*
  DRUG_UNIT_ITEM
   */
  Future<void>DRUG_UNIT_ITEM_db_sub()async{

    DRUG_UNIT_ITEM_list.clear();
    String comm = "SELECT * FROM DRUG_UNIT_ITEM";
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
        for(int j=0;j<data_list.length;j++){
          DRUG_UNIT_ITEM ss = DRUG_UNIT_ITEM();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          DRUG_UNIT_ITEM_list.add(ss);
        }

        dev.log("DRUG_UNIT_ITEM_list.length:${DRUG_UNIT_ITEM_list.length}");
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }


  /*
  DRUG_MODE_ITEM
   */
  Future<void>DRUG_MODE_ITEM_db_sub()async{

    dRUG_MODE.DRUG_MODE_ITEM_list.clear();
    String comm = "SELECT * FROM DRUG_MODE_ITEM";
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
        for(int j=0;j<data_list.length;j++){
          DRUG_MODE_ITEM ss = DRUG_MODE_ITEM();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          dRUG_MODE.DRUG_MODE_ITEM_list.add(ss);
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


  /*
  ROLLCALL_ITEMS
   */
  Future<void>ROLLCALL_ITEMS_db_sub()async{

    ROLLCALL_ITEMS_list.clear();
    String comm = "SELECT * FROM ROLLCALL_ITEMS";
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
        for(int j=0;j<data_list.length;j++){
          ROLLCALL_ITEMS ss = ROLLCALL_ITEMS();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          ROLLCALL_ITEMS_list.add(ss);
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


  /*
  公告欄 INTRODUCTION
   */
  /*
  Future<void> BULLETIN_db_sub({String datetime="",String SORT_ID=""})async{
    //await EasyLoading.show(status: "處理中...");
    BULLETIN_list.clear();
    setState(() {

    });
    /*
    String result = await sql_command("SELECT * FROM BULLETIN WHERE BLTN_DT BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'");

     */
    String result = await sql_command((SORT_ID.isEmpty)?"SELECT * FROM BULLETIN":"SELECT * FROM BULLETIN WHERE SORT_ID IN(${SORT_ID})");

    await EasyLoading.dismiss();
    try{
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      dev.log("data_list.length:${data_list.length}");
      if(data_list.length==0){
      }
      else{
         for(int i=0;i<data_list.length;i++){
           BULLETIN b = BULLETIN();
           b.BLTN_NO = "${data_list[i]["BLTN_NO"]}".contains("null")?"":"${data_list[i]["BLTN_NO"]}";
           b.TITLE = "${data_list[i]["TITLE"]}".contains("null")?"":"${data_list[i]["TITLE"]}";
           b.DETAIL = "${data_list[i]["DETAIL"]}".contains("null")?"":"${data_list[i]["DETAIL"]}";
           b.BLTN_DT = "${data_list[i]["BLTN_DT"]}".contains("null")?"":"${data_list[i]["BLTN_DT"]}";
           b.SORT_ID = "${data_list[i]["SORT_ID"]}".contains("null")?"":"${data_list[i]["SORT_ID"]}";
           b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
           BULLETIN_list.add(b);
         }
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      EasyLoading.showInfo("網路異常");
    }
  }

   */


  /*
  [托嬰/幼兒] 點名 ROLLCALL
   */
  Future<void> ROLLCALL_db_sub({String datetime=""})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    ROLLCALL_list.clear();
    setState(() {

    });
    String comm = "SELECT * FROM ROLLCALL WHERE (DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59') AND CLASS_NO='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}'";
    dev.log("${comm}");
    String result = await sql_command(comm);
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
      dev.log("data_list.length:${data_list.length}");
      if(data_list.length==0){
      }
      else{
        List<ROLLCALL> _ROLLCALL_list  = [];
        for(int i=0;i<data_list.length;i++){
          ROLLCALL b = ROLLCALL();
          b.NO = "${data_list[i]["NO"]}";
          b.DATE = "${data_list[i]["DATE"]}";
          b.TIME = "${data_list[i]["TIME"]}";
          b.DEPM_NO = "${data_list[i]["DEPM_NO"]}";
          b.CLASS_NO = "${data_list[i]["CLASS_NO"]}";
          b.CS_NO = "${data_list[i]["CS_NO"]}";
          b.STATUS = "${data_list[i]["STATUS"]}";

          b.DATE = DateFormat('yyyy-MM-dd').format(DateTime.parse(b.DATE));
          List<String> list = b.DATE.split("-");

          List<String> t1 = b.TIME.split(":");
          b.timeOfDay = TimeOfDay(hour: int.parse(t1[0]),minute: int.parse(t1[1]));

          b.DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[DateTime(int.parse(list[0]),int.parse(list[1]),int.parse(list[2])).weekday-1]})";
          b.DateStr1 ='${"${b.timeOfDay.period==DayPeriod.am?"上午":"下午"}${b.timeOfDay.hourOfPeriod}:${b.timeOfDay.minute.toString().padLeft(2,"0")}"}';
          _ROLLCALL_list.add(b);
        }
        ROLLCALL_list = _ROLLCALL_list;
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }


  /*
  [托嬰/幼兒] 請假 EXCUSED
   */
  /*
  Future<void> read_for_month_EXCUSED_db_sub({String datetime=""})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    List<String> CS_NOs = [];
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      CS_NOs.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO);
    }

    //檢查學生是否為0
    if(CS_NOs.length==0){
      SmartDialog.dismiss();
      SmartDialog.showToast("目前無學生在此班級");
      return;
    }

    String CS_NO_json = jsonEncode(CS_NOs.toList());
    CS_NO_json = CS_NO_json.replaceAll("[", "(");
    CS_NO_json = CS_NO_json.replaceAll("]", ")");
    CS_NO_json = CS_NO_json.replaceAll("\"", "'");

    dev.log("CS_NO_json:${CS_NO_json}");
    String YEAR="";
    String MONTH="";
    if(datetime.contains("-")) {
      YEAR = datetime.split("-").elementAt(0);
      MONTH = datetime.split("-").elementAt(1);
    }

    EXCUSED_list.clear();
    setState(() {

    });
    String result = datetime.isEmpty?
    await sql_command("SELECT * FROM EXCUSED WHERE (CS_NO in ${CS_NO_json})")
        :
    await sql_command("SELECT * FROM EXCUSED WHERE (CS_NO in ${CS_NO_json}) AND YEAR(DATE) = ${YEAR} AND MONTH(DATE) = ${MONTH}");
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
          b.CFM_ITEM_selectedValue = CFM_ITEM_list.firstWhere(
                (element) => element.CFM_NO == b.CFM_NO,
            orElse: () => CFM_ITEM(),
          );
          if(b.DEL.isEmpty){
            EXCUSED_list.add(b);
          }
        }
        EXCUSED_list.sort((a,b) => b.DATE.compareTo(a.DATE));


        setState(() {

        });


      }



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }

   */

  /*
  生活花絮 BLOG
   */
  Future<void> BLOG_db_sub({String datetime=""})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    String YEAR="";
    String MONTH="";
    if(datetime.contains("-")) {
      YEAR = datetime.split("-").elementAt(0);
      MONTH = datetime.split("-").elementAt(1);
    }

    BLOG_list.clear();
    setState(() {

    });
    String result = datetime.isEmpty?
    await sql_command("SELECT * FROM BLOG WHERE DEPM_NO=${user.DEPM_NO} AND CLASS_NO=${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}")
        :
    await sql_command("SELECT * FROM BLOG WHERE YEAR(BLTN_DT) = ${YEAR} AND MONTH(BLTN_DT) = ${MONTH} AND DEPM_NO=${user.DEPM_NO} AND CLASS_NO=${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}");
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
          BLOG b = BLOG();
          b.BLOG_NO = "${data_list[i]["BLOG_NO"]}".contains("null")?"":"${data_list[i]["BLOG_NO"]}";
          b.TITLE = "${data_list[i]["TITLE"]}".contains("null")?"":"${data_list[i]["TITLE"]}";
          b.DETAIL = "${data_list[i]["DETAIL"]}".contains("null")?"":"${data_list[i]["DETAIL"]}";
          b.BLTN_DT = "${data_list[i]["BLTN_DT"]}".contains("null")?"":"${data_list[i]["BLTN_DT"]}";
          b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
          b.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}";
          b.NOTE = "${data_list[i]["NOTE"]}".contains("null")?"":"${data_list[i]["NOTE"]}";
          DateTime d = DateTime.parse(b.BLTN_DT);
          b.BLTN_DT_str = DateFormat("yyyy年MM月dd日").format(d);
          BLOG_list.add(b);
        }

        setState(() {

        });

        BLOG_list.sort((a,b) {
          return b.BLTN_DT.compareTo(a.BLTN_DT);
        });

        for(int i=0;i<BLOG_list.length;i++){
          await BLOG_DL_db_sub(BLOG_NO:BLOG_list[i].BLOG_NO,index:i);
        }

        setState(() {

        });

      }



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }

  /*
  生活花絮子表單 BLOG_DL
   */
  Future<void> BLOG_DL_db_sub({String BLOG_NO="",int index=0})async{
    String result = await sql_command("SELECT * FROM BLOG_DL WHERE BLOG_NO = ${BLOG_NO}");
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
      if(data_list.length==0){}
      else{

        for(int j=0;j<data_list.length;j++){
          String img_url = "${data_list[j]["LINK"]}".replaceAll("~/", "");
          BLOG_list[index].LINK.add("${IMAGE_IP}/${img_url}");
          BLOG_DL b = BLOG_DL();
          b.NOTE = "${data_list[j]["NOTE"]}".contains("null")?"":"${data_list[j]["NOTE"]}";
          b.BLOG_NO = "${data_list[j]["BLOG_NO"]}".contains("null")?"":"${data_list[j]["BLOG_NO"]}";
          b.BLOG_SR = "${data_list[j]["BLOG_SR"]}".contains("null")?"":"${data_list[j]["BLOG_SR"]}";
          //b.LINK = "${data_list[j]["LINK"]}".contains("null")?"":"${data_list[j]["LINK"]}";
          b.LINK = "${IMAGE_IP}/${img_url}";
          b.NOTE_textEditingController.text = b.NOTE;
          BLOG_list[index].bLOG_DL.add(b);
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

  /*
  故事繪本 STORY
   */
  Future<void> STORY_db_sub({String datetime=""})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    STORY_list.clear();
    setState(() {

    });
    String result = await sql_command("SELECT * FROM STORY WHERE DEPM_NO=${user.DEPM_NO}");
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
          STORY s = STORY();
          String video_url = "${data_list[i]["VIDEO_LINK"]}".replaceAll("~/", "");
          String image_url = "${data_list[i]["COVER_LINK"]}".replaceAll("~/", "");
          s.VIDEO_LINK = "${IMAGE_IP}/${video_url}";
          s.TITLE = "${data_list[i]["TITLE"]}";
          s.COVER_LINK = "${IMAGE_IP}/${image_url}";
          s.DEPM_NO = "${data_list[i]["DEPM_NO"]}";
          s.LANGUAGE = "${data_list[i]["LANGUAGE"]}";
          s.NO = "${data_list[i]["NO"]}";
          s.NOTE = "${data_list[i]["NOTE"]}";


          // #docregion platform_features
          late final PlatformWebViewControllerCreationParams params;
          if (WebViewPlatform.instance is WebKitWebViewPlatform) {
            params = WebKitWebViewControllerCreationParams(
              allowsInlineMediaPlayback: true,
              mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
            );
          } else {
            params = const PlatformWebViewControllerCreationParams();
          }

          final WebViewController controller =
          WebViewController.fromPlatformCreationParams(params);
          // #enddocregion platform_features

          controller
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(
              NavigationDelegate(
                onProgress: (int progress) {
                  debugPrint('WebView is loading (progress : $progress%)');
                },
                onPageStarted: (String url) {
                  debugPrint('Page started loading: $url');
                },
                onPageFinished: (String url) {
                  debugPrint('Page finished loading: $url');
                },
                onWebResourceError: (WebResourceError error) {
                  debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
                },
                onNavigationRequest: (NavigationRequest request) {
                  if (request.url.startsWith('https://www.youtube.com/')) {
                    debugPrint('blocking navigation to ${request.url}');
                    return NavigationDecision.prevent;
                  }
                  debugPrint('allowing navigation to ${request.url}');
                  return NavigationDecision.navigate;
                },
                onUrlChange: (UrlChange change) {
                  debugPrint('url change to ${change.url}');
                },
                onHttpAuthRequest: (HttpAuthRequest request) {
                  dev.log("${request}");
                },
              ),
            )
            ..addJavaScriptChannel(
              'Toaster',
              onMessageReceived: (JavaScriptMessage message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message.message)),
                );
              })
            ..loadHtmlString('''<video src="${s.VIDEO_LINK}"  preload="none" playsinline controls controlsList="nofullscreen" width="100%" height="100%"></video>''');
            //..loadRequest(Uri.parse('${s.VIDEO_LINK}'));

          // #docregion platform_features
          if (controller.platform is AndroidWebViewController) {
            AndroidWebViewController.enableDebugging(true);
            (controller.platform as AndroidWebViewController)
                .setMediaPlaybackRequiresUserGesture(false);
          }
          // #enddocregion platform_features



          s.web_controller = controller;
          //s.web_controller!.loadHtmlString('''<video src="${s.VIDEO_LINK}"  webkit-playsinline autoplay playsinline controls width="" height="100%"></video>''');


          STORY_list.add(s);
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


  /*
  故事繪本分類選單 STORY_LANGUAGE_ITEM
   */
  Future<void> STORY_LANGUAGE_ITEM_db_sub()async{
    String result = await sql_command("SELECT * FROM STORY_LANGUAGE_ITEM");
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
      if(data_list.length==0){}
      else{
        STORY_MENU.clear();
        for(int i=0;i<data_list.length;i++){
          STORY_LANGUAGE_ITEM ss = STORY_LANGUAGE_ITEM();
          ss.ITEM_NM="${data_list[i]["ITEM_NM"]}";
          ss.ITEM_NO="${data_list[i]["ITEM_NO"]}";
          STORY_MENU.add(ss);
          if(i==0){
            STORY_MENU_selectedValue=STORY_MENU[i];
          }
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


  /*
[托嬰/幼兒]成長紀錄
   */
  Future<void> GROWING_db_sub({String datetime=""})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    GROWING_list.clear();
    setState(() {

    });

    List<String> CS_NOs = [];
    for(int i=0;i<cUSTOMERs.length;i++){
      CS_NOs.add(cUSTOMERs[i].CS_NO);
    }

    //檢查學生是否為0
    if(CS_NOs.length==0){
      SmartDialog.dismiss();
      SmartDialog.showToast("目前無學生在此班級");
      return;
    }

    String CS_NO_json = jsonEncode(CS_NOs.toList());
    CS_NO_json = CS_NO_json.replaceAll("[", "(");
    CS_NO_json = CS_NO_json.replaceAll("]", ")");
    CS_NO_json = CS_NO_json.replaceAll("\"", "'");

    //dev.log("CS_NO_json:${CS_NO_json}");

    String result = await sql_command("""SELECT * FROM GROWING WHERE (CS_NO in ${CS_NO_json}) AND
        DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'
        AND
        CLASS_NO = '${user.CLASS_NO}'
        AND
        CS_NO = '${user.KIDS_NO}'
        """);
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
          GROWING b = GROWING();
          b.TYPE = "${data_list[i]["TYPE"]}";
          b.NO = "${data_list[i]["NO"]}";
          b.DATE = "${data_list[i]["DATE"]}";
          b.DEPM_NO = "${data_list[i]["DEPM_NO"]}";
          b.CLASS_NO = "${data_list[i]["CLASS_NO"]}";
          b.CS_NO = "${data_list[i]["CS_NO"]}";
          b.USER_NO = "${data_list[i]["USER_NO"]}";
          GROWING_list.add(b);
        }

        for(int i=0;i<GROWING_list.length;i++){
          await GROWING_TYPE_ITEM_db_sub(GROWING_list_index:i);
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


  /*
   */
  Future<void> GROWING_TYPE_ITEM_db_sub({int GROWING_list_index=0})async{
    //await EasyLoading.show(status: "處理中...");
    GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list.clear();
    setState(() {

    });
    String result = await sql_command("SELECT * FROM GROWING_TYPE_ITEM");
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
      }
      else{
        for(int i=0;i<data_list.length;i++){
          GROWING_TYPE_ITEM b = GROWING_TYPE_ITEM();
          b.ITEM_NO = "${data_list[i]["ITEM_NO"]}";
          b.ITEM_NM = "${data_list[i]["ITEM_NM"]}";
          b.ITEM_ICON = "${GROWING_TYPE_ITEM_ICON["${b.ITEM_NO}"]}";
          b.ITEM_VALUE = "";
          b.ITEM_UNIT = "${GROWING_TYPE_ITEM_UNIT["${b.ITEM_NO}"]}";
          GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list.add(b);
        }

        for(int i=0;i<GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list.length;i++){
          await GROWING_DL_db_sub(GROWING_list_index:GROWING_list_index,GROWING_TYPE_ITEM_list_index:i);
          await GROWING_EYE_DL_db_sub(GROWING_list_index:GROWING_list_index,GROWING_TYPE_ITEM_list_index:i);
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


  /*
  [托嬰/幼兒]成長紀錄 子表單 GROWING_DL
   */
  Future<void> GROWING_DL_db_sub({int GROWING_list_index=0,int GROWING_TYPE_ITEM_list_index=0})async{
    //await EasyLoading.show(status: "處理中...");
    String result = await sql_command("SELECT * FROM GROWING_DL WHERE TYPE='${GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].ITEM_NO}' AND NO='${GROWING_list[GROWING_list_index].NO}'");
    //String result = await sql_command("SELECT * FROM GROWING_DL WHERE TYPE='${GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].ITEM_NO}' AND NO='${GROWING_list[GROWING_list_index].NO}'");
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
      }
      else{

        GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].ITEM_VALUE="${data_list[0]["DATA"]}";

      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }


  /*
  [托嬰/幼兒]成長紀錄 視力 子表單 GROWING_EYE_DL
   */
  Future<void> GROWING_EYE_DL_db_sub({int GROWING_list_index=0,int GROWING_TYPE_ITEM_list_index=0})async{
    //await EasyLoading.show(status: "處理中...");
    String result = await sql_command("SELECT * FROM GROWING_EYE_DL WHERE TYPE='${GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].ITEM_NO}' AND NO='${GROWING_list[GROWING_list_index].NO}'");
    //String result = await sql_command("SELECT * FROM GROWING_DL WHERE TYPE='${GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].ITEM_NO}' AND NO='${GROWING_list[GROWING_list_index].NO}'");
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
      }
      else{

        GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].ITEM_VALUE="${data_list[0]["L_DATA"]}-${data_list[0]["R_DATA"]}";

      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }


  /*
  View_SURVEY
   */
  Future<void> View_SURVEY_db_sub()async{
    //await EasyLoading.show(status: "處理中...");
    View_SURVEY_list.clear();
    String result = await sql_command("SELECT * FROM View_SURVEY WHERE CLASS_NO ='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}' AND DEPM_NO='${EMPLOYEE_teacher.DEPM_NO.trim()}'");
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
          View_SURVEY s = View_SURVEY();
          s.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
          s.TITLE = "${data_list[i]["TITLE"]}".contains("null")?"":"${data_list[i]["TITLE"]}";
          s.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
          s.TARGET = "${data_list[i]["TARGET"]}".contains("null")?"":"${data_list[i]["TARGET"]}";
          String img_url = "${data_list[i]["LINK"]}".replaceAll("~/", "");
          s.LINK = "${IMAGE_IP}/${img_url}";
          s.ADD_DATE = "${data_list[i]["ADD_DATE"]}".contains("null")?"":"${data_list[i]["ADD_DATE"]}";
          s.ADD_DATE = DateFormat("yyyy-MM-dd hh:MM:ss").format(DateTime.parse(s.ADD_DATE));
          s.ADD_USER = "${data_list[i]["ADD_USER"]}".contains("null")?"":"${data_list[i]["ADD_USER"]}";
          s.SR = "${data_list[i]["SR"]}".contains("null")?"":"${data_list[i]["SR"]}";
          s.ACCOUNT = "${data_list[i]["ACCOUNT"]}".contains("null")?"":"${data_list[i]["ACCOUNT"]}";
          s.ANSWER = "${data_list[i]["ANSWER"]}".contains("null")?"":"${data_list[i]["ANSWER"]}";
          s.SURVEY_NM = "${data_list[i]["SURVEY_NM"]}".contains("null")?"":"${data_list[i]["SURVEY_NM"]}";
          s.KIDS_NO = "${data_list[i]["KIDS_NO"]}".contains("null")?"":"${data_list[i]["KIDS_NO"]}";
          s.KIDS_NM = "${data_list[i]["KIDS_NM"]}".contains("null")?"":"${data_list[i]["KIDS_NM"]}";
          s.DATETIME = "${data_list[i]["DATETIME"]}".contains("null")?"":"${data_list[i]["DATETIME"]}";
          s.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}";
          s.NOTE = "${data_list[i]["NOTE"]}".contains("null")?"":"${data_list[i]["NOTE"]}";
          View_SURVEY_list.add(s);

        }

        List<View_SURVEY> _View_SURVEY_list = [];
        for(int i=0;i<View_SURVEY_list.length;i++){
          for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
            for(int k=0;k<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].cUSTOMER_DLs.length;k++){
              if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].cUSTOMER_DLs[k]!=null){
                if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].cUSTOMER_DLs[k]!.ACCOUNT.trim()==View_SURVEY_list[i].ACCOUNT.trim() &&
                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CLASS_NO==View_SURVEY_list[i].CLASS_NO.trim()
                ){
                  _View_SURVEY_list.add(View_SURVEY_list[i]);
                }
              }
            }
          }
        }




        View_SURVEY_list.clear();
        bool check = false;
        for(int i=0;i<_View_SURVEY_list.length;i++){
          check = false;
          for(int j=0;j<View_SURVEY_list.length;j++){
             if(
                     _View_SURVEY_list[i].NO==View_SURVEY_list[j].NO &&
                     _View_SURVEY_list[i].KIDS_NO==View_SURVEY_list[j].KIDS_NO
             ){
               check = true;
               break;
             }
          }
          if(check==false){
            View_SURVEY_list.add(_View_SURVEY_list[i]);
          }
        }

        for(int i=0;i<View_SURVEY_list.length;i++){
          dev.log("View_SURVEY_list[${i}]:${View_SURVEY_list[i].NO},${View_SURVEY_list[i].SR},${View_SURVEY_list[i].ANSWER}");
        }


        setState(() {

        });

      }

    }
    catch(e){
      dev.log("err:${e}");
      SmartDialog.showToast("網路異常");
    }
  }


  /*

   */
  Future<void> View_SURVEY_COUNTS_db_sub({String NO="",int index=0,String CLASS_NO=""})async{

    String result = await sql_command("SELECT * FROM View_SURVEY_COUNTS WHERE NO='${NO}' AND CLASS_NO='${CLASS_NO}'");
    try{
      dev.log("View_SURVEY_COUNTS_db_sub-result:${result}");
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
        for(int i=0;i<1;i++){
          SURVEY_list[index].View_SURVEY_COUNTS_SentCount = "${data_list[i]["SentCount"]}".contains("null")?"":"${data_list[i]["SentCount"]}";
          SURVEY_list[index].View_SURVEY_COUNTS_ReceivedCount = "${data_list[i]["ReceivedCount"]}".contains("null")?"":"${data_list[i]["ReceivedCount"]}";
        }

        setState(() {

        });
      }

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }

  /*

   */
  Future<void> View_SURVEY_ANSWER_STATS_db_sub({String NO="",int index=0,String CLASS_NO=""})async{

    String result = await sql_command("SELECT * FROM View_SURVEY_ANSWER_STATS WHERE NO='${NO}' AND CLASS_NO='${CLASS_NO}'");
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
          View_SURVEY_ANSWER_STATS v = View_SURVEY_ANSWER_STATS();
          v.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
          v.ANSWER = "${data_list[i]["ANSWER"]}".contains("null")?"":"${data_list[i]["ANSWER"]}";
          v.AnswerCount = "${data_list[i]["AnswerCount"]}".contains("null")?"":"${data_list[i]["AnswerCount"]}";
          SURVEY_list[index].View_SURVEY_ANSWER_STATS_list.add(v);
        }

        setState(() {

        });
      }

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }

  /*
  問卷 SURVEY
   */
  Future<void> SURVEY_db_sub({String datetime=""})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    String YEAR="";
    String MONTH="";
    if(datetime.contains("-")) {
      YEAR = datetime.split("-").elementAt(0);
      MONTH = datetime.split("-").elementAt(1);
    }

    SURVEY_list.clear();
    setState(() {

    });
    String comm = '''
SELECT *
FROM SURVEY
WHERE NO IN (
    SELECT NO
    FROM View_SURVEY_COUNTS
    WHERE CLASS_NO = '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}'
      AND DEPM_NO = '${EMPLOYEE_teacher.DEPM_NO.trim()}'
      AND YEAR(ADD_DATE) = ${YEAR}
      AND MONTH(ADD_DATE) = ${MONTH}
)
''';
    String result = await sql_command(comm);
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
          SURVEY s = SURVEY();
          s.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
          s.TITLE = "${data_list[i]["TITLE"]}".contains("null")?"":"${data_list[i]["TITLE"]}";
          String img_url = "${data_list[i]["LINK"]}".replaceAll("~/", "");
          s.LINK = "${IMAGE_IP}/${img_url}";
          s.ADD_DATE = "${data_list[i]["ADD_DATE"]}".contains("null")?"":"${data_list[i]["ADD_DATE"]}";
          s.ADD_USER = "${data_list[i]["ADD_USER"]}".contains("null")?"":"${data_list[i]["ADD_USER"]}";
          s.TARGET = "${data_list[i]["TARGET"]}".contains("null")?"":"${data_list[i]["TARGET"]}";
          dev.log("問卷(LINK):${s.LINK}");
          SURVEY_list.add(s);
        }

        setState(() {

        });

        for(int i=0;i<SURVEY_list.length;i++){
          await SURVEY_DL_db_sub(NO:SURVEY_list[i].NO);
        }

        SURVEY_list.sort((a,b)=>b.ADD_DATE.compareTo(a.ADD_DATE));

        for(int i=0;i<SURVEY_list.length;i++){
          await View_SURVEY_COUNTS_db_sub(NO:SURVEY_list[i].NO,index:i,CLASS_NO: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO);
          await View_SURVEY_ANSWER_STATS_db_sub(NO:SURVEY_list[i].NO,index:i,CLASS_NO: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO);
        }

        setState(() {

        });



      }



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }


  /*
  通知單 副表 SURVEY_DL
   */
  Future<void> SURVEY_DL_db_sub({String NO=""})async{
    String result = await sql_command("SELECT * FROM SURVEY_DL WHERE NO = ${NO}");
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
      if(data_list.length==0){}
      else{

        for(int i=0;i<SURVEY_list.length;i++){
          if(SURVEY_list[i].NO==NO){
            for(int j=0;j<data_list.length;j++){
              SURVEY_DL ss = SURVEY_DL();
              ss.NO = "${data_list[j]["NO"]}";
              ss.SR = "${data_list[j]["SR"]}";
              ss.NOTE = "${data_list[j]["NOTE"]}";
              SURVEY_list[i].survey_dl_list.add(ss);
            }
            break;
          }
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


  /*
  通知單 回復表單 SURVEY_RT
   */
  Future<void> SURVEY_RT_db_sub(
      {
        String NO="",//編號
        String SR="",//序號
        String ANSWER="",//選擇問卷序號
        String ACCOUNT="",//家長電話
        String NOTE=""//說明
      })async{

    DateTime now = DateTime.now();
    String DATETIME = DateFormat('yyyy-MM-dd kk:mm').format(now);
    String comm = "SELECT * FROM SURVEY_RT WHERE NO = '${NO}'";
    /*
    """
    IF EXISTS (SELECT * FROM SURVEY_RT WHERE NO = '${NO}')
        UPDATE SURVEY_RT SET SR='${SR}', ANSWER='${ANSWER}',ACCOUNT='${ACCOUNT}',DATETIME='${DATETIME}',NOTE='${NOTE}' WHERE NO='${NO}'
        ELSE
        INSERT INTO SURVEY_RT(NO,SR,ANSWER,ACCOUNT,DATETIME,NOTE) VALUES ('${NO}','${SR}','${ANSWER}','${ACCOUNT}','${DATETIME}','${NOTE}')
        """;

     */
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
        String comm = "INSERT INTO SURVEY_RT(NO,SR,ANSWER,ACCOUNT,DATETIME,NOTE) VALUES ('${NO}','${SR}','${ANSWER}','${ACCOUNT}','${DATETIME}','${NOTE}')";
        dev.log("${comm}");
        String result = await sql_command("${comm}");
      }
      else{
        String comm = "UPDATE SURVEY_RT SET SR='${SR}', ANSWER='${ANSWER}',ACCOUNT='${ACCOUNT}',DATETIME='${DATETIME}',NOTE='${NOTE}' WHERE NO='${NO}'";
        dev.log("${comm}");
        String result = await sql_command("${comm}");
      }

      SmartDialog.showToast("送出問卷成功");

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }


  /*
  [托嬰/幼兒]用藥委託主表單(個人) DRUG_MT
   */
  Future<void> insert_DRUG_MT_db_sub(
      {
        String DRUG_NO="",//編號
        String DATE="",//日期
        String DEPM_NO="",//學校
        String CLASS_NO="",//班級
        String CS_NO="",//學生編號
        String REASON="",//用藥原因
        String DRUG_LINK="",//藥單封面
        bool AGREE=true,//同意
        String SIGN_LINK="",//簽名
        String DATETIME=""//送出時間
      })async{

    String comm = "INSERT INTO DRUG_MT(DRUG_NO,DATE,DEPM_NO,CLASS_NO,CS_NO,REASON,DRUG_LINK,AGREE,SIGN_LINK,DATETIME) VALUES ('${DRUG_NO}','${DATE}','${DEPM_NO}','${CLASS_NO}','${CS_NO}','${REASON}','${DRUG_LINK}','${AGREE}','${SIGN_LINK}','${DATETIME}')";
    dev.log("${comm}");
    String result = await sql_command("${comm}");
    dev.log("result:${result}");
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
        //EasyLoading.showSuccess("用藥委託送出成功");
        //drug_reason = DRUG_REASON();
        setState(() {

        });
      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }
  }

  /*
  [托嬰/幼兒]用藥委託主表單(個人) DRUG_MT
   */
  Future<int> read_DRUG_MT_db_sub()async{

    int DRUG_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(drug_reason.dateTime!)}";
    String comm = "SELECT * FROM DRUG_MT WHERE DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";
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
        String DRUG_NO = "${data_list[data_list.length-1]["DRUG_NO"]}";
        dev.log("DRUG_NO:${DRUG_NO}");
        //找出流水號
        DRUG_NO_num = int.parse("${DRUG_NO.substring(DRUG_NO.length-4,DRUG_NO.length)}");
        dev.log("DRUG_NO_num:${DRUG_NO_num}");
      }
      setState(() {

      });

    }
    catch(e){
      DRUG_NO_num=-1;
      dev.log("${e}");
    }

    return DRUG_NO_num;

  }



  /*
  [托嬰/幼兒]用藥委託主表單(個人) DRUG_MT (每月)
   */
  Future<void> read_for_month_DRUG_MT_db_sub({String datetime=""})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    List<String> CS_NOs = [];
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      CS_NOs.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO);
    }

    //檢查學生是否為0
    if(CS_NOs.length==0){
      SmartDialog.dismiss();
      SmartDialog.showToast("目前無學生在此班級");
      return;
    }

    String CS_NO_json = jsonEncode(CS_NOs.toList());
    CS_NO_json = CS_NO_json.replaceAll("[", "(");
    CS_NO_json = CS_NO_json.replaceAll("]", ")");
    CS_NO_json = CS_NO_json.replaceAll("\"", "'");

    //dev.log("CS_NO_json:${CS_NO_json}");

    String YEAR="";
    String MONTH="";
    if(datetime.contains("-")) {
      YEAR = datetime.split("-").elementAt(0);
      MONTH = datetime.split("-").elementAt(1);
    }

    DRUG_MT_list.clear();
    setState(() {

    });
    String result = datetime.isEmpty?
    await sql_command("SELECT * FROM DRUG_MT WHERE (CS_NO in ${CS_NO_json})")
        :
    await sql_command("SELECT * FROM DRUG_MT WHERE (CS_NO in ${CS_NO_json}) AND YEAR(DATE) = ${YEAR} AND MONTH(DATE) = ${MONTH}");
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
          DRUG_MT b = DRUG_MT();
          b.DRUG_NO = "${data_list[i]["DRUG_NO"]}".contains("null")?"":"${data_list[i]["DRUG_NO"]}";
          b.DATE = "${data_list[i]["DATE"]}".contains("null")?"":"${data_list[i]["DATE"]}";
          b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
          b.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}";
          b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}";
          b.REASON = "${data_list[i]["REASON"]}".contains("null")?"":"${data_list[i]["REASON"]}";
          b.DEL = "${data_list[i]["DEL"]}".contains("null")?"":"${data_list[i]["DEL"]}";

          String DRUG_LINK = "${data_list[i]["DRUG_LINK"]}".replaceAll("~/", "");
          b.DRUG_LINK = "${IMAGE_IP}/${DRUG_LINK}";

          b.AGREE = "${data_list[i]["AGREE"]}".contains("null")?"":"${data_list[i]["AGREE"]}";

          String SIGN_LINK = "${data_list[i]["SIGN_LINK"]}".replaceAll("~/", "");
          b.SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK}";

          b.DATETIME = "${data_list[i]["DATETIME"]}".contains("null")?"":"${data_list[i]["DATETIME"]}";

          b.DATE = DateFormat('yyyy-MM-dd').format(DateTime.parse(b.DATE));
          List<String> list = b.DATE.split("-");
          b.DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[DateTime(int.parse(list[0]),int.parse(list[1]),int.parse(list[2])).weekday-1]})";
          if(b.DEL.isEmpty){
            DRUG_MT_list.add(b);
          }

        }

        DRUG_MT_list.sort((a,b) => b.DATE.compareTo(a.DATE));

        setState(() {

        });

        /*
        明細
         */
        for(int i=0;i<DRUG_MT_list.length;i++){
          await read_for_DRUG_DL_db_sub(DRUG_NO:DRUG_MT_list[i].DRUG_NO,index: i);
        }




      }



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }


  /*
  [托嬰/幼兒]用藥委託主表單(個人) DRUG_MT
   */
  Future<void> read_for_DRUG_MT_db_sub({String datetime="",bool show_toast=true})async{
    if(show_toast==true) {
      FocusManager.instance.primaryFocus?.unfocus();
      SmartDialog.showLoading(msg: "處理中...");
    }
    await Future.delayed(const Duration(milliseconds: 500), () {});
    List<String> CS_NOs = [];
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      CS_NOs.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO);
    }

    //檢查學生是否為0
    if(CS_NOs.length==0){
      SmartDialog.dismiss();
      SmartDialog.showToast("目前無學生在此班級");
      return;
    }

    String CS_NO_json = jsonEncode(CS_NOs.toList());
    CS_NO_json = CS_NO_json.replaceAll("[", "(");
    CS_NO_json = CS_NO_json.replaceAll("]", ")");
    CS_NO_json = CS_NO_json.replaceAll("\"", "'");

    //dev.log("CS_NO_json:${CS_NO_json}");

    if(datetime.isEmpty){
      datetime = DateFormat("yyyy-MM-dd").format(DateTime.now());
    }


    DRUG_MT_list.clear();
    setState(() {

    });
    String result = await sql_command("SELECT * FROM DRUG_MT WHERE (CS_NO in ${CS_NO_json}) AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'");
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
          DRUG_MT b = DRUG_MT();
          b.DRUG_NO = "${data_list[i]["DRUG_NO"]}".contains("null")?"":"${data_list[i]["DRUG_NO"]}";
          b.DATE = "${data_list[i]["DATE"]}".contains("null")?"":"${data_list[i]["DATE"]}";
          b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
          b.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}";
          b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}";
          b.REASON = "${data_list[i]["REASON"]}".contains("null")?"":"${data_list[i]["REASON"]}";
          b.DEL = "${data_list[i]["DEL"]}".contains("null")?"":"${data_list[i]["DEL"]}";

          String DRUG_LINK = "${data_list[i]["DRUG_LINK"]}".replaceAll("~/", "");
          b.DRUG_LINK = "${IMAGE_IP}/${DRUG_LINK}";

          b.AGREE = "${data_list[i]["AGREE"]}".contains("null")?"":"${data_list[i]["AGREE"]}";

          String SIGN_LINK = "${data_list[i]["SIGN_LINK"]}".replaceAll("~/", "");
          b.SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK}";

          b.DATETIME = "${data_list[i]["DATETIME"]}".contains("null")?"":"${data_list[i]["DATETIME"]}";

          b.DATE = DateFormat('yyyy-MM-dd').format(DateTime.parse(b.DATE));
          List<String> list = b.DATE.split("-");
          b.DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[DateTime(int.parse(list[0]),int.parse(list[1]),int.parse(list[2])).weekday-1]})";

          if(b.DEL.isEmpty){
            DRUG_MT_list.add(b);
          }

        }

        DRUG_MT_list.sort((a,b) => b.DATE.compareTo(a.DATE));

        setState(() {

        });

        /*
        明細
         */
        for(int i=0;i<DRUG_MT_list.length;i++){
          await read_for_DRUG_DL_db_sub(DRUG_NO:DRUG_MT_list[i].DRUG_NO,index: i,show_toast:show_toast);
        }




      }



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }


  /*
  [托嬰/幼兒] 請假 EXCUSED
   */
  Future<void> read_for_EXCUSED_db_sub({String datetime="",bool show_toast = true})async{
    FocusManager.instance.primaryFocus?.unfocus();
    if(show_toast==true) {
      SmartDialog.showLoading(msg: "處理中...");
    }
    await Future.delayed(const Duration(milliseconds: 500), () {});
    List<String> CS_NOs = [];
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      CS_NOs.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO);
    }

    //檢查學生是否為0
    if(CS_NOs.length==0){
      SmartDialog.dismiss();
      SmartDialog.showToast("目前無學生在此班級");
      return;
    }

    String CS_NO_json = jsonEncode(CS_NOs.toList());
    CS_NO_json = CS_NO_json.replaceAll("[", "(");
    CS_NO_json = CS_NO_json.replaceAll("]", ")");
    CS_NO_json = CS_NO_json.replaceAll("\"", "'");

    //dev.log("CS_NO_json:${CS_NO_json}");

    if(datetime.isEmpty) {
      datetime = DateFormat("yyyy-MM-dd").format(DateTime.now());
    }

    EXCUSED_list.clear();
    setState(() {

    });
    String result = await sql_command("SELECT * FROM EXCUSED WHERE (CS_NO in ${CS_NO_json}) AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'");
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
        List<EXCUSED> _EXCUSED_list=[];
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
          b.CFM_ITEM_selectedValue = CFM_ITEM_list.firstWhere(
                (element) => element.CFM_NO == b.CFM_NO,
            orElse: () => CFM_ITEM(),
          );
          if(b.DEL.isEmpty) {
            _EXCUSED_list.add(b);
          }
        }
        EXCUSED_list=_EXCUSED_list;
        EXCUSED_list.sort((a,b) => b.DATE.compareTo(a.DATE));
        setState(() {

        });

      }



    }
    catch(e){
      dev.log("err:${e}");
      //SmartDialog.showToast("<<網路異常");
    }
  }


  /*
  [托嬰/幼兒] DAILY_PRS
   */
  Future<void> read_for_DAILY_PRS_db_sub({String datetime="",bool show_toast = true})async{
    FocusManager.instance.primaryFocus?.unfocus();
    if(show_toast==true) {
      SmartDialog.showLoading(msg: "處理中...");
    }
    await Future.delayed(const Duration(milliseconds: 500), () {});
    List<String> CS_NOs = [];
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      CS_NOs.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO);
    }

    //檢查學生是否為0
    if(CS_NOs.length==0){
      SmartDialog.dismiss();
      SmartDialog.showToast("目前無學生在此班級");
      return;
    }

    String CS_NO_json = jsonEncode(CS_NOs.toList());
    CS_NO_json = CS_NO_json.replaceAll("[", "(");
    CS_NO_json = CS_NO_json.replaceAll("]", ")");
    CS_NO_json = CS_NO_json.replaceAll("\"", "'");

    //dev.log("CS_NO_json:${CS_NO_json}");

    //datetime = DateFormat("yyyy-MM-dd").format(DateTime.now());

    DAILY_PRSs.clear();
    setState(() {

    });
    String result = await sql_command("SELECT * FROM DAILY_PRS WHERE (CS_NO in ${CS_NO_json}) AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'");
    SmartDialog.dismiss();
    try{
      dev.log('result:${result}');
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
        List<DAILY_PRS> _DAILY_PRSs=[];
        for(int i=0;i<data_list.length;i++){
          DAILY_PRS b = DAILY_PRS();
          b.TYPE = "${data_list[i]["TYPE"]}".contains("null")?"":"${data_list[i]["TYPE"]}";
          b.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
          b.DATE = "${data_list[i]["DATE"]}".contains("null")?"":"${data_list[i]["DATE"]}";
          b.TIME = "${data_list[i]["TIME"]}".contains("null")?"":"${data_list[i]["TIME"]}";
          b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
          b.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}";
          b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}";
          b.NOTE = "${data_list[i]["NOTE"]}".contains("null")?"":"${data_list[i]["NOTE"]}";
          b.STATUS = "${data_list[i]["STATUS"]}".contains("null")?"":"${data_list[i]["STATUS"]}";
          String SIGN_LINK = "${data_list[i]["SIGN_LINK"]}".replaceAll("~/", "");
          b.SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK}";
          b.DATE = DateFormat('yyyy-MM-dd').format(DateTime.parse(b.DATE));
          List<String> list = b.DATE.split("-");
          b.DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[DateTime(int.parse(list[0]),int.parse(list[1]),int.parse(list[2])).weekday-1]})";
          _DAILY_PRSs.add(b);
        }
        DAILY_PRSs=_DAILY_PRSs;
        DAILY_PRSs.sort((a,b) => b.DATE.compareTo(a.DATE));
        setState(() {

        });
      }



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
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
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      data_list = trim_proc(data_list);

      SmartDialog.showToast("送出成功");
      await read_for_EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
      if(data_list.length==0){
      }
      else{

      }

    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }

  /*
  [托嬰/幼兒]用藥委託明細(個人) DRUG_DL (每月)
   */
  Future<void> read_for_DRUG_DL_db_sub({String DRUG_NO="",int index=0,bool show_toast=true})async{
    FocusManager.instance.primaryFocus?.unfocus();
    if(show_toast==true){
      SmartDialog.showLoading(msg: "處理中...");
    }
    await Future.delayed(const Duration(milliseconds: 500), () {});
    String result = await sql_command("SELECT * FROM DRUG_DL WHERE DRUG_NO = '${DRUG_NO}'");

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
      dev.log("data_list.length:${data_list.length}");
      if(data_list.length==0){
      }
      else{
        for(int i=0;i<data_list.length;i++){
          DRUG_DL b = DRUG_DL();
          b.DRUG_NO = "${data_list[i]["DRUG_NO"]}".contains("null")?"":"${data_list[i]["DRUG_NO"]}";
          b.DRUG_SR = "${data_list[i]["DRUG_SR"]}".contains("null")?"":"${data_list[i]["DRUG_SR"]}";
          b.DETAIL = "${data_list[i]["DETAIL"]}".contains("null")?"":"${data_list[i]["DETAIL"]}";
          b.STORE = "${data_list[i]["STORE"]}".contains("null")?"":"${data_list[i]["STORE"]}";
          b.DOSAGE = "${data_list[i]["DOSAGE"]}".contains("null")?"":"${data_list[i]["DOSAGE"]}";
          b.MODE = "${data_list[i]["MODE"]}".contains("null")?"":"${data_list[i]["MODE"]}";
          b.UNIT = "${data_list[i]["UNIT"]}".contains("null")?"":"${data_list[i]["UNIT"]}";
          b.TIME1 = "${data_list[i]["TIME1"]}".contains("null")?"":"${data_list[i]["TIME1"]}";
          b.TIME2 = "${data_list[i]["TIME2"]}".contains("null")?"":"${data_list[i]["TIME2"]}";
          b.TIME3 = "${data_list[i]["TIME3"]}".contains("null")?"":"${data_list[i]["TIME3"]}";
          b.DRUG_LINK = "${data_list[i]["DRUG_LINK"]}".contains("null")?"":"${data_list[i]["DRUG_LINK"]}";
          b.NOTE = "${data_list[i]["NOTE"]}".contains("null")?"":"${data_list[i]["NOTE"]}";
          b.CMPT_SIGN1 = "${data_list[i]["CMPT_SIGN1"]}".contains("null")?"":"${data_list[i]["CMPT_SIGN1"]}";
          b.CMPT_SIGN2 = "${data_list[i]["CMPT_SIGN2"]}".contains("null")?"":"${data_list[i]["CMPT_SIGN2"]}";
          b.CMPT_SIGN3 = "${data_list[i]["CMPT_SIGN3"]}".contains("null")?"":"${data_list[i]["CMPT_SIGN3"]}";
          b.CMPT_Time1 = "${data_list[i]["CMPT_Time1"]}".contains("null")?"":"${data_list[i]["CMPT_Time1"]}";
          b.CMPT_Time2 = "${data_list[i]["CMPT_Time2"]}".contains("null")?"":"${data_list[i]["CMPT_Time2"]}";
          b.CMPT_Time3 = "${data_list[i]["CMPT_Time3"]}".contains("null")?"":"${data_list[i]["CMPT_Time3"]}";
          b.CMPT_NOTE1 = "${data_list[i]["CMPT_NOTE1"]}".contains("null")?"":"${data_list[i]["CMPT_NOTE1"]}";
          b.CMPT_NOTE2 = "${data_list[i]["CMPT_NOTE2"]}".contains("null")?"":"${data_list[i]["CMPT_NOTE2"]}";
          b.CMPT_NOTE3 = "${data_list[i]["CMPT_NOTE3"]}".contains("null")?"":"${data_list[i]["CMPT_NOTE3"]}";
          String DRUG_LINK = b.DRUG_LINK.replaceAll("~/", "");
          b.DRUG_LINK = "${IMAGE_IP}/${DRUG_LINK}";

          String CMPT_SIGN1 = b.CMPT_SIGN1.replaceAll("~/", "");
          b.CMPT_SIGN1 = "${IMAGE_IP}/${CMPT_SIGN1}";

          String CMPT_SIGN2 = b.CMPT_SIGN2.replaceAll("~/", "");
          b.CMPT_SIGN2 = "${IMAGE_IP}/${CMPT_SIGN2}";

          String CMPT_SIGN3 = b.CMPT_SIGN3.replaceAll("~/", "");
          b.CMPT_SIGN3 = "${IMAGE_IP}/${CMPT_SIGN3}";

          DRUG_MT_list[index].DRUG_DL_list.add(b);
        }

        setState(() {

        });




      }



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }



  /*
  [托嬰/幼兒]用藥委託主表單(個人) DRUG_DL
   */
  Future<void> insert_DRUG_DL_db_sub(
      {
        String DRUG_NO="",//編號
        String DRUG_SR="",//序號
        String DETAIL="",//藥品名稱
        String STORE="",//用藥保存
        String MODE="",//用藥方式
        String UNIT="",//用量單位
        String DOSAGE="",//用量
        String TIME1="",//第1次
        String TIME2="",//第2次
        String TIME3="",//第3次
        String DRUG_LINK="",//藥品照片
        String NOTE="",//說明

      })async{

    String comm = "INSERT INTO DRUG_DL(DRUG_NO,DRUG_SR,DETAIL,STORE,MODE,UNIT,DOSAGE,TIME1,TIME2,TIME3,DRUG_LINK,NOTE) VALUES ('${DRUG_NO}','${DRUG_SR}','${DETAIL}','${STORE}','${MODE}','${UNIT}','${DOSAGE}','${TIME1}','${TIME2}','${TIME3}','${DRUG_LINK}','${NOTE}')";
    dev.log("${comm}");
    String result = await sql_command("${comm}");
    dev.log("result:${result}");
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
        SmartDialog.showToast("用藥委託送出成功");
        drug_reason = DRUG_REASON();
        setState(() {

        });
      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }
  }




  /*
  ENTRUSTED_TYPE_ITEM_db_sub
   */
  Future<void>ENTRUSTED_TYPE_ITEM_db_sub()async{

    ENTRUSTED_TYPE_ITEM_list.clear();
    String comm = "SELECT * FROM ENTRUSTED_TYPE_ITEM";
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
        List<ENTRUSTED_TYPE_ITEM> _ENTRUSTED_TYPE_ITEM_list=[];
        for(int j=0;j<data_list.length;j++){
          ENTRUSTED_TYPE_ITEM ss = ENTRUSTED_TYPE_ITEM();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          _ENTRUSTED_TYPE_ITEM_list.add(ss);
        }
        ENTRUSTED_TYPE_ITEM_list = _ENTRUSTED_TYPE_ITEM_list;
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }


  /*

   */
  /*
  Future<void>read_for_month_ENTRUSTED_db_sub({String datetime=""})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    List<String> CS_NOs = [];
    for(int i=0;i<cUSTOMERs.length;i++){
      CS_NOs.add(cUSTOMERs[i].CS_NO);
    }

    //檢查學生是否為0
    if(CS_NOs.length==0){
      SmartDialog.dismiss();
      SmartDialog.showToast("目前無學生在此班級");
      return;
    }

    String CS_NO_json = jsonEncode(CS_NOs.toList());
    CS_NO_json = CS_NO_json.replaceAll("[", "(");
    CS_NO_json = CS_NO_json.replaceAll("]", ")");
    CS_NO_json = CS_NO_json.replaceAll("\"", "'");

    dev.log("CS_NO_json:${CS_NO_json}");
    String YEAR="";
    String MONTH="";
    if(datetime.contains("-")) {
      YEAR = datetime.split("-").elementAt(0);
      MONTH = datetime.split("-").elementAt(1);
    }

    entrusted_pick_and_drop_list.clear();
    setState(() {

    });
    String result = datetime.isEmpty?
    await sql_command("SELECT * FROM ENTRUSTED WHERE (CS_NO in ${CS_NO_json})")
        :
    await sql_command("SELECT * FROM ENTRUSTED WHERE (CS_NO in ${CS_NO_json}) AND YEAR(DATE) = ${YEAR} AND MONTH(DATE) = ${MONTH}");
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
          String SIGN_LINK = "${data_list[i]["SIGN_LINK"]}".replaceAll("~/", "");
          b.SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK}";
          b.CFM_USER = "${data_list[i]["CFM_USER"]}".contains("null")?"":"${data_list[i]["CFM_USER"]}";
          b.CFM_DT = "${data_list[i]["CFM_DT"]}".contains("null")?"":"${data_list[i]["CFM_DT"]}";
          b.DEL = "${data_list[i]["DEL"]}".contains("null")?"":"${data_list[i]["DEL"]}";
          b.DATE = DateFormat('yyyy-MM-dd').format(DateTime.parse(b.DATE));
          List<String> list = b.DATE.split("-");
          b.DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[DateTime(int.parse(list[0]),int.parse(list[1]),int.parse(list[2])).weekday-1]})";
          if(b.DEL.isEmpty){
            entrusted_pick_and_drop_list.add(b);
          }

        }
        entrusted_pick_and_drop_list.sort((a,b) => b.DATE.compareTo(a.DATE));


        setState(() {

        });

        /*
        明細
         */
        for(int i=0;i<entrusted_pick_and_drop_list.length;i++){
          await read_for_ENTRUSTED_DL_db_sub(NO:entrusted_pick_and_drop_list[i].NO,index: i);
        }




      }



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }

   */


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
          entrusted_pick_and_drop_list[index].eNTRUSTED_DL_list.add(b);
        }

        setState(() {

        });




      }



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }


  /*
  學生資料 CUSTOMER
   */
  Future<void> read_for_CUSTOMER_db_sub({String CLASS_NO="",int index=0})async{
    //await EasyLoading.show(status: "處理中...");

    String result = await sql_command("SELECT * FROM CUSTOMER WHERE CLASS_NO='${CLASS_NO}' AND STATUS='Y'");

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
      }
      else{
        for(int i=0;i<data_list.length;i++){
          CUSTOMER b = CUSTOMER();
          b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}";
          b.CS_NM = "${data_list[i]["CS_NM"]}".contains("null")?"":"${data_list[i]["CS_NM"]}";
          b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
          b.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}";
          b.STATUS = "${data_list[i]["STATUS"]}".contains("null")?"":"${data_list[i]["STATUS"]}";
          b.BIRTHDAY = "${data_list[i]["BIRTHDAY"]}".contains("null")?"":"${data_list[i]["BIRTHDAY"]}";
          b.SEX = "${data_list[i]["SEX"]}".contains("null")?"":"${data_list[i]["SEX"]}";
          b.PICTURE_LINK = "${data_list[i]["PICTURE_LINK"]}".contains("null")?"":"${data_list[i]["PICTURE_LINK"]}";
          String PICTURE_LINK = b.PICTURE_LINK.replaceAll("~/", "");
          b.PICTURE_LINK = "${IMAGE_IP}/${PICTURE_LINK}";
          b.ADD_DT = "${data_list[i]["ADD_DT"]}".contains("null")?"":"${data_list[i]["ADD_DT"]}";
          b.ADD_USER = "${data_list[i]["ADD_USER"]}".contains("null")?"":"${data_list[i]["ADD_USER"]}";
          b.NOTE = "${data_list[i]["NOTE"]}".contains("null")?"":"${data_list[i]["NOTE"]}";
          EMPLOYEE_teacher.Teacher_CUSTOMERs[index].cUSTOMERs.add(b);
          if(i==0) {
            EMPLOYEE_teacher.Teacher_CUSTOMERs[index].CUSTOMER_selectedValue = b;
            CUSTOMER_selectedValue = b;
          }
        }

        EMPLOYEE_teacher.Teacher_CUSTOMERs[index].cUSTOMERs.sort((a, b) => a.CS_NM.compareTo(b.CS_NM));

        setState(() {

        });




      }



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }

  /*
  授權家長子表單 CUSTOMER_DL
   */
  Future<void> read_for_CUSTOMER_DL_db_sub({String CS_NO="",int index=0,int index2=0})async{
    //await EasyLoading.show(status: "處理中...");

    EMPLOYEE_teacher.Teacher_CUSTOMERs[index].cUSTOMERs[index2].cUSTOMER_DLs.clear();
    String result = await sql_command("SELECT * FROM CUSTOMER_DL WHERE CS_NO='${CS_NO}'");

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
      }
      else{

        for(int i=0;i<data_list.length;i++){
          CUSTOMER_DL b = CUSTOMER_DL();
          b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}";
          b.CS_SR = "${data_list[i]["CS_SR"]}".contains("null")?"":"${data_list[i]["CS_SR"]}";
          b.ACCOUNT = "${data_list[i]["ACCOUNT"]}".contains("null")?"":"${data_list[i]["ACCOUNT"]}";
          b.PASSWORD = "${data_list[i]["PASSWORD"]}".contains("null")?"":"${data_list[i]["PASSWORD"]}";
          b.USER_NM = "${data_list[i]["USER_NM"]}".contains("null")?"":"${data_list[i]["USER_NM"]}";
          b.RANK = "${data_list[i]["RANK"]}".contains("null")?"":"${data_list[i]["RANK"]}";
          b.TOKEN_ID = "${data_list[i]["TOKEN_ID"]}".contains("null")?"":"${data_list[i]["TOKEN_ID"]}";
          b.SIGN_LINK = "${data_list[i]["SIGN_LINK"]}".contains("null")?"":"${data_list[i]["SIGN_LINK"]}";
          if(b.SIGN_LINK.isNotEmpty){
            String SIGN_LINK = b.SIGN_LINK.replaceAll("~/", "");
            b.SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK}";
          }
          b.FCM = "${data_list[i]["FCM"]}".contains("null")?"":"${data_list[i]["FCM"]}";
          b.new_password_TextEditingController.text="";
          b.password_TextEditingController.text="";
          EMPLOYEE_teacher.Teacher_CUSTOMERs[index].cUSTOMERs[index2].cUSTOMER_DLs.add(b);
        }


        setState(() {

        });




      }



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }


  Future<void> upload_xxx_from_EMPLOYEE_db({String PASSWORD="",String SIGN_LINK="",String ACCOUNT=""})async{

    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});

    String comm="";
    if(SIGN_LINK.isNotEmpty){
      comm = "UPDATE EMPLOYEE SET SIGN_LINK='${SIGN_LINK}' WHERE ACCOUNT='${ACCOUNT}'";
    }
    if(PASSWORD.isNotEmpty){
      comm = '''
        UPDATE EMPLOYEE SET PASSWORD='${PASSWORD}' WHERE ACCOUNT='${ACCOUNT}'
        UPDATE CUSTOMER_DL SET PASSWORD='${PASSWORD}' WHERE ACCOUNT='${ACCOUNT}'
      ''';
    }

    dev.log("${comm}");
    String result = await sql_command("${comm}");
    SmartDialog.dismiss();
    try{

      if(result.contains("執行成功")) {
        if(SIGN_LINK.isNotEmpty){
          EMPLOYEE_teacher.SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK.replaceAll("~", "")}";
        }
        setState(() {

        });
        return;
      }

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
        //SmartDialog.showToast("送出成功");
        //EMPLOYEE_db_sub();
      }



    }
    catch(e){
      dev.log("${e}");
      //SmartDialog.showToast("網路異常");
    }

  }


  /*
  成長曲線基準
   */
  Future<void> resd_GROWING_STANDARD_db_sub()async{
    FocusManager.instance.primaryFocus?.unfocus();

    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    GROWING_STANDARDs.clear();
    String comm = "SELECT * FROM GROWING_STANDARD";
    String result = await sql_command(comm);
    SmartDialog.dismiss();
    try{
      List<dynamic> list = jsonDecode(result);
      dev.log("list.length:${list[0]}");
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
          GROWING_STANDARD g = GROWING_STANDARD();
          g.TYPE = "${data_list[i]["TYPE"]}".contains("null")?"":"${data_list[i]["TYPE"]}".replaceAll(" ", "");
          g.SEX = "${data_list[i]["SEX"]}".contains("null")?"":"${data_list[i]["SEX"]}".replaceAll(" ", "");
          g.MONTH = "${data_list[i]["MONTH"]}".contains("null")?"":"${data_list[i]["MONTH"]}".replaceAll(" ", "");
          g.DATA_3 = "${data_list[i]["DATA_3"]}".contains("null")?"":"${data_list[i]["DATA_3"]}".replaceAll(" ", "");
          g.DATA_15 = "${data_list[i]["DATA_15"]}".contains("null")?"":"${data_list[i]["DATA_15"]}".replaceAll(" ", "");
          g.DATA_50 = "${data_list[i]["DATA_50"]}".contains("null")?"":"${data_list[i]["DATA_50"]}".replaceAll(" ", "");
          g.DATA_85 = "${data_list[i]["DATA_85"]}".contains("null")?"":"${data_list[i]["DATA_85"]}".replaceAll(" ", "");
          g.DATA_97 = "${data_list[i]["DATA_97"]}".contains("null")?"":"${data_list[i]["DATA_97"]}".replaceAll(" ", "");

          GROWING_STANDARDs.add(g);
        }

        Male_salesDatas_3.clear();
        Male_salesDatas_15.clear();
        Male_salesDatas_50.clear();
        Male_salesDatas_85.clear();
        Male_salesDatas_97.clear();
        Female_salesDatas_3.clear();
        Female_salesDatas_15.clear();
        Female_salesDatas_50.clear();
        Female_salesDatas_85.clear();
        Female_salesDatas_97.clear();

        sel_GROWING_STANDARD_TYPE = GROWING_STANDARD_TYPE[0];

        for(int i=0;i<GROWING_STANDARDs.length;i++){
          if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="M"){
            Male_salesDatas_3.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_3)));
            Male_salesDatas_15.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_15)));
            Male_salesDatas_50.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_50)));
            Male_salesDatas_85.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_85)));
            Male_salesDatas_97.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_97)));
          }
          if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="F"){
            Female_salesDatas_3.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_3)));
            Female_salesDatas_15.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_15)));
            Female_salesDatas_50.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_50)));
            Female_salesDatas_85.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_85)));
            Female_salesDatas_97.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_97)));
          }
        }

        Male_salesDatas_3.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Male_salesDatas_15.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Male_salesDatas_50.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Male_salesDatas_85.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Male_salesDatas_97.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Female_salesDatas_3.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Female_salesDatas_15.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Female_salesDatas_50.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Female_salesDatas_85.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Female_salesDatas_97.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        showModalBottomSheet_GROWING_STANDARD_setState(() {

        });

        dev.log("test-1");
        this.showModalBottomSheet_GROWING_STANDARD_setState((){});
        dev.log("test-2");
        setState(() {

        });

      }

    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }


  }


  Future<void> upload_PICTURE_LINK_CUSTOMER_db_sub({int index=0})async{
    SmartDialog.showLoading(msg:"上傳圖片中...，請稍候",
      clickMaskDismiss: false, // 禁止點擊遮罩關閉
      backDismiss: false,      // 禁止按返回鍵關閉（可選）
    );
    await Future.delayed(const Duration(milliseconds: 1500), () {});
    String file_name = "${DateTime.now().microsecondsSinceEpoch}";
    await upload_image(image_path: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].PICTURE_LINK_xfile.path,file_name: file_name,folder: "Student");
    String PICTURE_LINK = "~/School/Images/Student/${file_name}.jpg";//簽名
    await upload_xxx_from_CUSTOMER_db(
      PICTURE_LINK:PICTURE_LINK,
      //PASSWORD:cUSTOMERs[0].cUSTOMER_DL!.new_password_TextEditingController.text,
      CS_NO:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].CS_NO,
    );//上傳授權家長子表單(簽名檔)
    SmartDialog.dismiss();
  }

  /*
  上傳學生照片
   */
  Future<void> upload_xxx_from_CUSTOMER_db({String PICTURE_LINK="",String CS_NO=""})async{

    String comm="";
    if(PICTURE_LINK.isNotEmpty){
      comm = "UPDATE CUSTOMER SET PICTURE_LINK='${PICTURE_LINK}' WHERE CS_NO='${CS_NO}'";
    }

    dev.log("${comm}");
    String result = await sql_command("${comm}");

  }


  void showImageViewer(BuildContext context,{int index=0}) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(8),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(child: (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].PICTURE_LINK_xfile==null)?
              Image.network("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].PICTURE_LINK}"):
              Image.file(File(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].PICTURE_LINK_xfile!.path)),
            )),
            // 關閉按鈕
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black,size: 30.sp,),
                onPressed: () => Navigator.pop(_),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void add_all_DAILY_MT_db_sub2()async{

    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    List<CUSTOMER> _cUSTOMERs = [];
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].is_sel==true){
        _cUSTOMERs.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i]);
      }
    }

    String datetime = "${DateFormat('yyyy-MM-dd').format(dateTime!)}";
    String TYPE = "POV";
    int cUSTOMERs_length = _cUSTOMERs.length;

    dev.log("datetime:(${datetime})");

    final jsonCustomers = jsonEncode(_cUSTOMERs.map((c) => {
      'DEPM_NO': c.DEPM_NO,
      'CLASS_NO': c.CLASS_NO,
      'CS_NO': c.CS_NO,
      'USER_NO': EMPLOYEE_teacher.EMP_NO,
    }).toList());

    dev.log("jsonCustomers:${jsonCustomers}");
    final escapedJson = jsonCustomers.replaceAll("'", "''");
    dev.log("escapedJson:${escapedJson}");

    List<dynamic> is_povs = [];
    for(int i=0;i<_cUSTOMERs.length;i++){
      bool check = await check_DAILY_MT_db_sub(TYPE: "POV",CS_NO: _cUSTOMERs[i].CS_NO);
      is_povs.add({
        'CS_NO': _cUSTOMERs[i].CS_NO,
        'is_pov': check
      });
    }
    dev.log("is_povs:${is_povs}");

    String comm = '''
    
BEGIN TRANSACTION;
SET NOCOUNT ON;

-- 1. 傳入參數（Flutter 傳來）
DECLARE @json NVARCHAR(MAX) = N'${escapedJson}';
DECLARE @Count INT = ${cUSTOMERs_length};                         -- 學生人數
DECLARE @PicPerStudent INT = ${0};                -- 每人圖片數
DECLARE @Date DATE = '${datetime}';
DECLARE @Type CHAR(4) = '${TYPE}';

-- 2. 編號處理
DECLARE @Prefix NVARCHAR(6);
DECLARE @StartNo INT;
DECLARE @BaseNO NVARCHAR(13) = '';              -- 第一筆 NO（圖片命名用）

SET @Prefix = RIGHT(CONVERT(CHAR(8), @Date, 112), 6);

SELECT @StartNo = ISNULL(MAX(CAST(RIGHT(NO, 7) AS INT)), 0)
FROM DAILY_MT WITH (UPDLOCK, HOLDLOCK)
WHERE TYPE = @Type AND DATE = @Date AND LEFT(NO, 6) = @Prefix;

-- 3. 建立 #NewNOs 暫存表
IF OBJECT_ID('tempdb..#NewNOs') IS NOT NULL DELETE FROM #NewNOs;
ELSE CREATE TABLE #NewNOs (Seq INT, NO NVARCHAR(13));

WITH NewNOs AS (
    SELECT 1 AS Seq, @Prefix + RIGHT('0000000' + CAST(@StartNo + 1 AS VARCHAR), 7) AS NO
    UNION ALL
    SELECT Seq + 1, @Prefix + RIGHT('0000000' + CAST(@StartNo + Seq + 1 AS VARCHAR), 7) AS NO
    FROM NewNOs
    WHERE Seq < @Count
)
INSERT INTO #NewNOs
SELECT * FROM NewNOs;

-- 4. 建立 #CustomerData 暫存表
IF OBJECT_ID('tempdb..#CustomerData') IS NOT NULL DELETE FROM #CustomerData;

SELECT
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Seq,
    DEPM_NO,
    CLASS_NO,
    CS_NO,
    USER_NO
INTO #CustomerData
FROM OPENJSON(@json)
WITH (
    DEPM_NO NVARCHAR(50),
    CLASS_NO NVARCHAR(50),
    CS_NO NVARCHAR(50),
    USER_NO NVARCHAR(50)
);

-- 5. 建立 #PictureSR 暫存表
IF @PicPerStudent > 0
BEGIN
    IF OBJECT_ID('tempdb..#PictureSR') IS NOT NULL DELETE FROM #PictureSR;
    ELSE CREATE TABLE #PictureSR (SR INT);
    
    WITH Numbers AS (
        SELECT 1 AS SR
        UNION ALL
        SELECT SR + 1 FROM Numbers WHERE SR + 1 <= @PicPerStudent
    )
    INSERT INTO #PictureSR
    SELECT SR FROM Numbers OPTION (MAXRECURSION 0);
END

-- 6. 取得第一筆 NO（圖片命名用）
SELECT TOP 1 @BaseNO = NO FROM #NewNOs ORDER BY Seq;

-- 7. 寫入 DAILY_MT（基本資料）
INSERT INTO DAILY_MT (TYPE, NO, DATE, TIME, DEPM_NO, CLASS_NO, CS_NO, USER_NO)
SELECT
    @Type,
    n.NO,
    @Date,
    SYSDATETIME(),
    c.DEPM_NO,
    c.CLASS_NO,
    c.CS_NO,
    c.USER_NO
FROM #NewNOs n
INNER JOIN #CustomerData c ON n.Seq = c.Seq
WHERE NOT EXISTS (
    SELECT 1
    FROM DAILY_MT d
    WHERE d.TYPE = @Type
      AND d.DATE = @Date
      AND d.DEPM_NO = c.DEPM_NO
      AND d.CLASS_NO = c.CLASS_NO
      AND d.CS_NO = c.CS_NO
);


-- 10. 回傳 JSON 結果
DECLARE @Result TABLE (
    message NVARCHAR(20),
    affectedRows INT,
    FirstNO NVARCHAR(13)
);

INSERT INTO @Result
SELECT N'執行成功', @Count * (1 + 1 + @PicPerStudent), @BaseNO;

-- 提交交易
COMMIT;

-- 輸出 JSON 結果（欄位加上別名避免錯誤）
SELECT 
    message AS message,
    affectedRows AS affectedRows,
    FirstNO AS FirstNO
FROM @Result
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    ''';

    String result = await sql_command2("${comm}");
    dev.log("全班寫入聯絡簿送出(回應):${result}");

    try{
      Map<String,dynamic> map = jsonDecode(result);
      if("${map["message"]}"=="執行成功"){

        for(int i=0;i<_cUSTOMERs.length;i++){

          for(int j=0;j<is_povs.length;j++){

            if(is_povs[j]["CS_NO"]==_cUSTOMERs[i].CS_NO && "${is_povs[j]["is_pov"]}"=="false"){
              try{
                dev.log("親愛的家長您好，今天的電子聯絡簿已完成上傳～請至系統查閱，瞭解寶貝在園的生活喔！");
                SmartDialog.showLoading(msg: "推播通知...(${i+1}/${_cUSTOMERs.length})");

                for(int k=0;k<_cUSTOMERs[i].cUSTOMER_DLs.length;k++){

                  String FCM = await search_CUSTOMER_DL_fcm_sub(ACCOUNT:_cUSTOMERs[i].cUSTOMER_DLs[k]!.ACCOUNT);
                  await sendPushNotification(
                      title: "老師",
                      message: "親愛的家長您好，今天的電子聯絡簿已完成上傳～請至系統查閱，瞭解寶貝在園的生活喔！",
                      token: FCM,//_cUSTOMERs[i].cUSTOMER_DLs[j]!.FCM,
                      ChatID:"電子聯絡簿已完成上傳",
                      UserAccount: '${_cUSTOMERs[i].cUSTOMER_DLs[k]!.ACCOUNT}',
                      TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}"
                  );

                }


              }
              catch(e){

              }
            }

          }

        }

        SmartDialog.dismiss();
        SmartDialog.showToast("聯絡簿送出成功");

      }
      else{

        SmartDialog.dismiss();

        showDialog(
          context: context,
          barrierDismissible: false, // 點外面不關閉 dialog
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('⚠️ 警告',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
              content: Text('上傳失敗，請重試',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
              actions: <Widget>[
                TextButton(
                  child:  Text('關閉',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
                  onPressed: () {
                    Navigator.of(context).pop(); // 關閉 Dialog
                  },
                ),
              ],
            );
          },
        );


      }
    }
    catch(e){

      SmartDialog.dismiss();

      showDialog(
        context: context,
        barrierDismissible: false, // 點外面不關閉 dialog
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('⚠️ 警告',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
            content: Text('上傳失敗，請重試',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
            actions: <Widget>[
              TextButton(
                child:  Text('關閉',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
                onPressed: () {
                  Navigator.of(context).pop(); // 關閉 Dialog
                },
              ),
            ],
          );
        },
      );

    }




  }

  /*
  void add_all_DAILY_MT_db_sub()async{

    FocusManager.instance.primaryFocus?.unfocus();
    List<CUSTOMER> _cUSTOMERs = [];
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].is_sel==true){
        _cUSTOMERs.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i]);
      }
    }



    for(int i=0;i<_cUSTOMERs.length;i++){

      SmartDialog.showLoading(msg: "處理中...(${i+1}/${_cUSTOMERs.length})");
      await Future.delayed(const Duration(milliseconds: 300), () {});

      //先確認是否已送出
      bool check = await check_DAILY_MT_db_sub(TYPE: "POV",CS_NO: _cUSTOMERs[i].CS_NO);

      if(check==false){
        dev.log('聯絡簿已送出');
        int View_DAILY_NO_num = await read_View_DAILY_db_sub2(TYPE:"POV");
        dev.log("View_DAILY_NO_num:${View_DAILY_NO_num}");
        if(View_DAILY_NO_num==-1){
          SmartDialog.dismiss();
          SmartDialog.showToast("read_View_DAILY_db_sub error");
          return;
        }

        //View_DAILY_NO_num+=1;
        String View_DAILY_NO = "${View_DAILY_NO_num}";
        //View_DAILY_NO = View_DAILY_NO.substring(2,View_DAILY_NO.length);
        dev.log("View_DAILY_NO:${View_DAILY_NO}");

        bool check = await insert_DAILY_MT_db_sub(
          TYPE:"POV",
          NO:View_DAILY_NO,//編號
          DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
          TIME:"${DateFormat('HH:mm').format(DateTime.now())}",//"${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00",//時間
          DEPM_NO:"${_cUSTOMERs[i].DEPM_NO}",//學校
          CLASS_NO:"${_cUSTOMERs[i].CLASS_NO}",//班級
          CS_NO:"${_cUSTOMERs[i].CS_NO}",//學生身分證字號
          USER_NO:"${EMPLOYEE_teacher.EMP_NO}",//系統自動帶入老師編號
        );

        if(check==false){
          SmartDialog.dismiss();
          SmartDialog.showToast("忙碌中，請重試");
          break;
        }

        for(int j=0;j<_cUSTOMERs[i].cUSTOMER_DLs.length;j++){
          String FCM = await search_CUSTOMER_DL_fcm_sub(ACCOUNT:_cUSTOMERs[i].cUSTOMER_DLs[j]!.ACCOUNT);
          await sendPushNotification(
              title: "老師",
              message: "親愛的家長您好，今天的電子聯絡簿已完成上傳～請至系統查閱，瞭解寶貝在園的生活喔！",
              token: FCM,//_cUSTOMERs[i].cUSTOMER_DLs[j]!.FCM,
              ChatID:"電子聯絡簿已完成上傳",
              UserAccount: '${_cUSTOMERs[i].cUSTOMER_DLs[j]!.ACCOUNT}',
              TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}"
          );
        }

      }
      else{
        dev.log('聯絡簿已送出');
        //SmartDialog.showToast("聯絡簿已送出");
      }

    }

    SmartDialog.dismiss();
    SmartDialog.showToast("聯絡簿送出成功");


  }

   */


  /*
  聯絡簿送出(家長可顯示)
   */
  Future<bool> check_DAILY_MT_db_sub(
      {
        String TYPE="",
        String CS_NO="",
      })async{

    bool check = false;

    String DATE="${DateFormat('yyyy-MM-dd').format(dateTime!)}";//日期
    String DEPM_NO="${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}";//學校
    String CLASS_NO="${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}";//班級
    String USER_NO="${EMPLOYEE_teacher.EMP_NO}";//系統自動帶入老師編號

    String comm = '''
    SELECT *
FROM DAILY_MT
WHERE TYPE = '${TYPE}'
  AND DATE = '${DATE}'
  AND DEPM_NO = '${DEPM_NO}'
  AND CLASS_NO = '${CLASS_NO}'
  AND CS_NO = '${CS_NO}'
  AND USER_NO = '${USER_NO}'
    ''';
    dev.log("${comm}");

    String result = await sql_command("${comm}");
    dev.log("result:${result}");
    try{
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      if(data_list.length==0){

      }
      else{
        check = true;
      }


    }
    catch(e){
      dev.log("${e}");
    }

    return check;

  }



  /*
  生活概況
   */
  Future<int> read_View_DAILY_db_sub2({String TYPE=""})async{

    int View_DAILY_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(dateTime!)}";

    //2025/05/15修改搜尋條件
    //String comm = "SELECT * FROM DAILY_MT WHERE TYPE='ACT' AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";
    String comm = '''SELECT *
    FROM DAILY_MT
    WHERE TYPE = '${TYPE}'
      AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'
      AND NO = (
        SELECT MAX(NO)
        FROM DAILY_MT
        WHERE TYPE = '${TYPE}'
          AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'
      );''';
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

        View_DAILY_NO_num+=1;
        String ss = "${DateFormat('yyyyMMdd').format(dateTime!)}";
        View_DAILY_NO_num = int.parse("${ss.substring(2,ss.length)}${View_DAILY_NO_num.toString().padLeft(7,"0")}");

      }
      else{
        dev.log("筆數:${data_list.length}");
        data_list.sort((a,b)=> int.parse(a["NO"]).compareTo(int.parse(b["NO"])));
        String View_DAILY_NO = "${data_list[data_list.length-1]["NO"]}";
        dev.log("View_DAILY_NO:${View_DAILY_NO}");
        //找出流水號
        //View_DAILY_NO_num = int.parse("${View_DAILY_NO.substring(View_DAILY_NO.length-7,View_DAILY_NO.length)}");
        View_DAILY_NO_num = int.parse("${View_DAILY_NO}");
        View_DAILY_NO_num+=1;
        dev.log("View_DAILY_NO_num:${View_DAILY_NO_num}");
      }
      setState(() {

      });

    }
    catch(e){
      View_DAILY_NO_num=-1;
      dev.log("${e}");
    }

    return View_DAILY_NO_num;

  }


  /*

   */
  Future<bool> insert_DAILY_MT_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        String DATE="",//日期
        String TIME="",//時間
        String DEPM_NO="",//學校編號
        String CLASS_NO="",//班級編號
        String CS_NO="",//學生編號
        String USER_NO="",//
      })async{

    String comm = "INSERT INTO DAILY_MT(TYPE,NO,DATE,TIME,DEPM_NO,CLASS_NO,CS_NO,USER_NO) VALUES ('${TYPE}','${NO}','${DATE}','${TIME}','${DEPM_NO}','${CLASS_NO}','${CS_NO}','${USER_NO}')";
    dev.log("${comm}");


    String result = await sql_command("${comm}");
    dev.log("result:${result}");
    try{
      if(result.contains("執行成功")){
        setState(() {

        });
        return true;
      }
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      if(data_list.length==0){

      }


      setState(() {

      });

      return true;

    }
    catch(e){
      dev.log("${e}");
      return false;
    }


  }


  void checkPasswordChangeAndShowDialog(BuildContext context, TextEditingController newPasswordController) {
    if (newPasswordController.text.isNotEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false, // 禁止點背景關閉
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false, // 禁止返回鍵關閉
            child: AlertDialog(
              backgroundColor: Colors.white, // ✅ 白底
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                "需要重新登入",
                textScaler: TextScaler.linear(1),
                style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold,fontSize: 20.sp),
              ),
              content: Text("你已變更密碼，請重新登入以繼續使用應用程式。",textScaler: TextScaler.linear(1),style: TextStyle(color:Colors.black,fontWeight: FontWeight.normal,fontSize: 20.sp),),
              actions: [
                TextButton(
                  onPressed: () async{
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('is_login', 'false');
                    Navigator.of(context).pop(); // 關閉 dialog
                    // TODO: 執行登出與跳轉登入畫面邏輯
                    // 呼叫重啟
                    Phoenix.rebirth(context);
                  },
                  child: Text("確認",textScaler: TextScaler.linear(1),style: TextStyle(fontWeight: FontWeight.normal,fontSize: 20.sp),),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> updata_fcm_token_sub({String TOKEN_ID=""})async{
    FocusManager.instance.primaryFocus?.unfocus();
    //SmartDialog.showLoading(msg: "處理中...");
    //await Future.delayed(const Duration(milliseconds: 500), () {});

    //String safeToken = safeForSql(TOKEN_ID);
    String result = "";
    String comm = '''
    DECLARE @fcm NVARCHAR(MAX) = N'${TOKEN_ID}';
    UPDATE CUSTOMER_DL SET FCM =  @fcm WHERE ACCOUNT = '${user.ACCOUNT}';
    UPDATE EMPLOYEE SET FCM =  @fcm WHERE ACCOUNT = '${user.ACCOUNT}'
        ''';
    dev.log("comm:${comm}");
    result = await sql_command(comm);
    //result = await sql_command("UPDATE EMPLOYEE SET FCM = '${TOKEN_ID}' WHERE ACCOUNT = '${user.ACCOUNT}'");
    /*
    if(user.RANK=="U"){
      //家長
      //只允許推播id只有一組
      //result = await sql_command("UPDATE CUSTOMER_DL SET FCM = '' WHERE FCM = '${TOKEN_ID}'");
      //result = await sql_command("UPDATE EMPLOYEE SET FCM = '' WHERE FCM = '${TOKEN_ID}'");
      result = await sql_command("UPDATE CUSTOMER_DL SET FCM = '${TOKEN_ID}' WHERE ACCOUNT = '${user.ACCOUNT}'");
    }
    else if(user.RANK=="T" || user.RANK=="M") {
      //老師
      //result = await sql_command("UPDATE CUSTOMER_DL SET FCM = '' WHERE FCM = '${TOKEN_ID}'");
      //result = await sql_command("UPDATE EMPLOYEE SET FCM = '' WHERE FCM = '${TOKEN_ID}'");
      result = await sql_command("UPDATE EMPLOYEE SET FCM = '${TOKEN_ID}' WHERE ACCOUNT = '${user.ACCOUNT}'");
    }

     */


    //SmartDialog.dismiss();
    try{

      dev.log("${result}");
      /*
      List<dynamic> list = jsonDecode(result);
      dev.log("list.length:${list[0]}");
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      dev.log("data_list.length:${data_list.length}");
      if(data_list.length==0){

      }
      else{

      }

       */

    }
    catch(e){
      dev.log("${e}");
      //SmartDialog.showToast("網路異常a2");
    }
  }

  @override
  Widget build(BuildContext context) {

    this_context = context;

    setAdaptiveSystemUI(context);

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
        child:Scaffold(
      body: Container(
        color: page=="聯絡"?Color(0xffFAF7F2):Colors.white,//Color(0xffF8F8F8),
        padding: EdgeInsets.only(left:0.w,right: 0.w,top: 40.h),width: ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
        child: Column(children: [

            (pendingMessage == null)
            ? Container()
            : Container(
          color: Colors.red,
          width: ScreenUtil().screenWidth,
          height: 30.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "點擊推播打開中，請稍候...",
                textScaler: TextScaler.linear(1),
                style: TextStyle(fontSize: 16.sp, color: Colors.white),
              ),
              SizedBox(width: 8.w), // 文字與轉圈圈間距
              SizedBox(
                width: 16.w,
                height: 16.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),

          Expanded(child: IndexedStack(
              index: _selectedIndex,
              children:[

                Stack(children: [
                  Container(
                      color: Colors.white,
                      width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                      padding: EdgeInsets.only(left:12.w,right: 12.w),child:Column(children: [

                    /*
                Container(
                width: ScreenUtil().screenWidth,
                height: 55.h,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                      surfaceTintColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                      padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.w),
                              side: BorderSide(color: Color(0xff707070))
                          )
                      )
                  ),
                  onPressed: () async{
                  },
                  child: Row(children: [

                    Container(width: 15.w,),
                    SvgPicture.asset("assets/images/Icon-fa-solid-school-flag.svg",width: 12.sp,),
                    Container(width: 15.w,),
                    Text("${user.DEPM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp)),
                    Expanded(child: Container()),
                  ],),
                )),

                 */
                    //Container(height: 15.h,),
                    //Container(width: ScreenUtil().screenWidth,child:
                    //Text("班級選單", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp))),
                    Container(height: 15.h,),
                    Container(width: ScreenUtil().screenWidth,child:Row(children: [
                      Expanded(child:GestureDetector(
                          onTap: (){

                            Navigator.push(context, PageTransition(
                                type: PageTransitionType.rightToLeft, child: BarcodeScannerPageView()));

                          },
                          child: Container(
                            width: 70.w,
                            padding: EdgeInsets.all(4.sp),
                            decoration: BoxDecoration(
                                color: Color(0x01000000),
                                borderRadius: BorderRadius.circular(10.w),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.black,
                                )),
                            child: Row(children: [

                              Expanded(child:Container()),
                              Icon(Icons.qr_code,size: 20.sp,),
                              Text('點名', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,color: Color(0xff555555) , fontSize: 16.sp)),
                              Expanded(child:Container()),

                            ],),))),
                      Container(width: 10.w,),
                      Expanded(flex:3,child:GestureDetector(
                          onTap: ()async{
                            List<DateTime?>? results = await showCalendarDatePicker2Dialog(
                              context: context,
                              config: CalendarDatePicker2WithActionButtonsConfig(
                                selectedDayHighlightColor:Color(0xff004ea2),
                              ),
                              dialogSize: const Size(325, 400),
                              value: [dateTime],
                              borderRadius: BorderRadius.circular(15),
                            )??[];

                            if(results.length>0){

                              dateTime = results[0]!;
                              await ROLLCALL_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_ENTRUSTED=false;
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DRUG_MT=false;
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_EXCUSED=false;
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DAILY_PRS=false;
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_STATUS=false;
                              }
                              setState(() {

                              });

                              /*
                            檢查每位學生是否有用藥委託
                             */
                              await read_for_DRUG_MT_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                for(int k=0;k<DRUG_MT_list.length;k++){
                                  if(DRUG_MT_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DRUG_MT=true;
                                  }
                                }
                              }




                              /*
                            檢查每位學生是否有請假委託
                             */
                              await read_for_EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                for(int k=0;k<EXCUSED_list.length;k++){
                                  if(EXCUSED_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_EXCUSED=true;
                                  }
                                }
                              }


                              /*
                            檢查每位學生是否有接送委託
                             */
                              await read_for_ENTRUSTED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                for(int k=0;k<entrusted_pick_and_drop_list.length;k++){
                                  if(entrusted_pick_and_drop_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_ENTRUSTED=true;
                                  }
                                }
                              }



                              /*
                            檢查每位學生家長聯絡簿是否已回簽
                             */
                              await read_for_DAILY_PRS_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                for(int k=0;k<DAILY_PRSs.length;k++){
                                  if(DAILY_PRSs[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DAILY_PRS=true;
                                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_STATUS = DAILY_PRSs[k].STATUS=='老師已讀';
                                  }
                                }
                              }

                            }

                            setState(() {

                            });



                          },
                          child: Container(color:Color(0x01000000),child:Row(children: [

                            Expanded(child: Container()),
                            Icon(Icons.date_range,size: 24.sp,),
                            Container(width: 5.w,),
                            Text("${DateFormat("MM月dd日").format(dateTime)} (${WEEK_DAY[dateTime.weekday-1]})", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 17.sp)),
                            Icon(Icons.arrow_forward_ios,size: 24.sp,),
                            Expanded(child: Container()),

                          ],)))),
                      Container(width: 10.w,),
                      Expanded(child:Row(children: [
                        Container(width: 5.w,),
                        Container(
                            width:20.w,
                            height: 20.w,
                            child: Checkbox(
                                checkColor: Colors.white,
                                value: checkbox, onChanged: (v){
                              checkbox=v!;
                              for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].is_sel = v;
                              }
                              setState(() {

                              });
                            })),
                        Container(width: 5.w,),
                        Text("全選",
                          style: TextStyle(
                              fontFamily: "GenJyuuGothic",
                              fontWeight: FontWeight.bold,
                              fontSize: 17.sp,
                              color: Color(0xff292929)),),
                      ],))
                    ],)
                    ),
                    Container(height: 5.h,),
                    Container(width: ScreenUtil().screenWidth,height: 2,color: Colors.black,),
                    Container(height: 5.h,),
                    /*
                Container(
                    width: ScreenUtil().screenWidth,child:Row(children: [
                    Container(width: 3.h,),

                    Text("學生", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp)),
                    Expanded(flex:1,child: Center(child:Text('姓名', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 16.sp)))),
                    Expanded(child: Center(child:Text('到校', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 16.sp)))),
                    Expanded(child: Center(child:Text('離校', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 16.sp)))),
                    Expanded(child: Center(child:Text('狀態', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 16.sp)))),

                ],)),

                 */
                    Expanded(child: RefreshIndicator(
                        onRefresh: () async {

                          await ROLLCALL_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

                          for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                            EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_ENTRUSTED=false;
                            EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DRUG_MT=false;
                            EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_EXCUSED=false;
                            EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DAILY_PRS=false;
                            EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_STATUS=false;
                          }
                          setState(() {

                          });

                          /*
                            檢查每位學生是否有用藥委託
                             */
                          await read_for_DRUG_MT_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}",show_toast: false);
                          for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                            for(int k=0;k<DRUG_MT_list.length;k++){
                              if(DRUG_MT_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DRUG_MT=true;
                              }
                            }
                          }


                          /*
                            檢查每位學生是否有請假委託
                             */
                          await read_for_EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}",show_toast: false);
                          for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                            for(int k=0;k<EXCUSED_list.length;k++){
                              if(EXCUSED_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_EXCUSED=true;
                              }
                            }
                          }


                          /*
                            檢查每位學生是否有接送委託
                             */
                          await read_for_ENTRUSTED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}",show_toast: false);
                          for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                            for(int k=0;k<entrusted_pick_and_drop_list.length;k++){
                              if(entrusted_pick_and_drop_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_ENTRUSTED=true;
                              }
                            }
                          }



                          /*
                            檢查每位學生家長聯絡簿是否已回簽
                             */
                          await read_for_DAILY_PRS_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}",show_toast: false);
                          for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                            for(int k=0;k<DAILY_PRSs.length;k++){
                              dev.log('老師已讀,${DAILY_PRSs[k].STATUS},${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_STATUS}');
                              if(DAILY_PRSs[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DAILY_PRS=true;
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_STATUS = DAILY_PRSs[k].STATUS=='老師已讀';
                              }
                            }
                          }

                        },
                        child:
                        ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length,
                        itemBuilder: (c,index){


                          List<ROLLCALL> start_ROLLCALL = ROLLCALL_list.where((element) =>
                          (element.CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].CS_NO && element.STATUS=="1")
                          ).toList();
                          List<ROLLCALL> end_ROLLCALL = ROLLCALL_list.where((element) =>
                          (element.CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].CS_NO && element.STATUS=="2")
                          ).toList();

                          String start_time = start_ROLLCALL.isEmpty?"":"${start_ROLLCALL[0].DateStr1}";
                          String end_time = end_ROLLCALL.isEmpty?"":"${end_ROLLCALL[0].DateStr1}";

                          //dev.log("start_ROLLCALL.length:${start_ROLLCALL.length}");
                          //dev.log("end_ROLLCALL.length:${end_ROLLCALL.length}");


                          return GestureDetector(

                              onLongPress: (){

                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_sel = !EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_sel;
                                setState(() {

                                });

                              },
                              onTap: (){

                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index];
                                Navigator.push(context, PageTransition(
                                    type: PageTransitionType.rightToLeft, child: Student_T_page(dateTime:dateTime,key: Student_T_page_WidgetKey)));

                              },
                              child: Container(color: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_sel==true?Color(0xff91d9d5):Color(0x01000000),width: ScreenUtil().screenWidth,child:Column(children: [
                                Container(height: 10.h,),
                                Row(children: [
                                  Container(width: 3.h,),
                                  GestureDetector(
                                      onTap: (){
                                         dev.log("點大頭照");

                                         showModalBottomSheet(
                                             context: context,
                                             builder: (
                                                 BuildContext _context) {
                                               showModalBottomSheet_image_context = _context;
                                               return Column(
                                                 mainAxisSize: MainAxisSize
                                                     .min,
                                                 children: <Widget>[
                                                   ListTile(
                                                     leading: Icon(Icons.photo,size: 28.sp,),
                                                     title: Text(
                                                         "圖片放大",textScaleFactor: 1,style:TextStyle(fontSize: 18.sp)),
                                                     onTap: () async {

                                                       Navigator.pop(showModalBottomSheet_image_context!);

                                                       showImageViewer(context,index:index);

                                                     },
                                                   ),
                                                   ListTile(
                                                     leading: Icon(Icons.photo_camera,size: 28.sp,),
                                                     title: Text(
                                                         "拍照",textScaleFactor: 1,style:TextStyle(fontSize: 18.sp)),
                                                     onTap: () async {

                                                       Navigator.pop(showModalBottomSheet_image_context!);

                                                       XFile? imageFile;
                                                       imageFile = await ImagePicker.ImagePicker().pickImage(source: ImagePicker.ImageSource.camera);


                                                       if(imageFile!=null) {

                                                         DateTime t = DateTime.now();
                                                         Directory tempDir = await getTemporaryDirectory();
                                                         var tempDirPath = tempDir.path;
                                                         final myAppPath = '$tempDirPath/威寶通/Student';
                                                         final res = await Directory(myAppPath).create(recursive: true);
                                                         String filePath = '${myAppPath}/${DateFormat('yyyyMMddHHmmss').format(t)}.jpg';


                                                         //壓縮image
                                                         EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].PICTURE_LINK_xfile = await FlutterImageCompress.compressAndGetFile(
                                                           imageFile.path, filePath,
                                                           minWidth: FlutterImageCompress_width,
                                                           minHeight: FlutterImageCompress_height,
                                                           quality: FlutterImageCompress_quality,
                                                           rotate: 0,
                                                         );

                                                         //final path = xfile!.path;
                                                         //final bytes = await File(path).readAsBytes();
                                                         //image = img.decodeImage(bytes);


                                                         setState(() {

                                                         });

                                                         upload_PICTURE_LINK_CUSTOMER_db_sub(index:index);


                                                       }
                                                       else
                                                       {
                                                         Navigator.pop(showModalBottomSheet_image_context!);
                                                       }


                                                     },
                                                   ),
                                                   ListTile(
                                                     leading: Icon(Icons.photo_library,size: 28.sp,),
                                                     title: Text(
                                                         "相簿",textScaleFactor: 1,style:TextStyle(fontSize: 18.sp)),
                                                     onTap: () async {

                                                       Navigator.pop(showModalBottomSheet_image_context!);
                                                       if (Platform.isAndroid) {


                                                         PermissionStatus? status;

                                                         final androidInfo = await DeviceInfoPlugin().androidInfo;
                                                         if (androidInfo.version.sdkInt <= 32) {
                                                           /// use [Permissions.storage.status]
                                                           status = await Permission.storage.status;
                                                         }  else {
                                                           /// use [Permissions.photos.status]
                                                           //print("test-1");
                                                           status = await Permission.photos.status;
                                                           //print("test-2");
                                                         }



                                                         //print("相簿-1${permission[Permission.WRITE_EXTERNAL_STORAGE]}");

                                                         if( status.isGranted == false ) {

                                                           //print("相簿-3");

                                                           try {
                                                             Map<Permission, PermissionStatus> statuses = await [
                                                               (androidInfo.version.sdkInt <= 32)?Permission.storage:Permission.photos,
                                                             ].request();
                                                           } on Exception {
                                                             //debugPrint("Error");
                                                           }

                                                           if (androidInfo.version.sdkInt <= 32) {
                                                             /// use [Permissions.storage.status]
                                                             status = await Permission.storage.status;
                                                           }  else {
                                                             /// use [Permissions.photos.status]
                                                             status = await Permission.photos.status;
                                                           }

                                                           if( status.isGranted == true) {
                                                             //print("Login ok");

                                                             PlatformFile? result = await FilePicker.pickFile(
                                                               //allowMultiple: false,
                                                               type: FileType.image,
                                                               //allowedExtensions: (Platform.isIOS)?null:['jpg','png','jpeg'],
                                                             );

                                                             if(result==null){
                                                               return;
                                                             }

                                                             var imageFile = result.xFile;

                                                             if (imageFile !=
                                                                 null) {
                                                               //print(
                                                               //    "imageFile.lengthSync1():${imageFile
                                                               //        .lengthSync()}");

                                                               DateTime t = DateTime.now();
                                                               Directory tempDir = await getTemporaryDirectory();
                                                               var tempDirPath = tempDir.path;
                                                               final myAppPath = '$tempDirPath/威寶通/Student';
                                                               final res = await Directory(myAppPath).create(recursive: true);
                                                               String filePath = '${myAppPath}/${DateFormat('yyyyMMddHHmmss').format(t)}.jpg';

                                                               //壓縮image
                                                               EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].PICTURE_LINK_xfile = await FlutterImageCompress
                                                                   .compressAndGetFile(
                                                                 imageFile.path, filePath,
                                                                 minWidth: FlutterImageCompress_width,
                                                                 minHeight: FlutterImageCompress_height,
                                                                 quality: FlutterImageCompress_quality,
                                                                 rotate: 0,
                                                               );

                                                               setState(() {

                                                               });

                                                               upload_PICTURE_LINK_CUSTOMER_db_sub(index:index);

                                                             }
                                                             else {
                                                               Navigator
                                                                   .pop(
                                                                   showModalBottomSheet_image_context!);
                                                             }

                                                           }
                                                           else {
                                                             return;
                                                           }

                                                         }
                                                         else{
                                                           //print("相簿-2");
                                                           PlatformFile? result = await FilePicker.pickFile(
                                                             //allowMultiple: false,
                                                             type: FileType.image,
                                                             //allowedExtensions: (Platform.isIOS)?null:['jpg','png','jpeg'],
                                                           );

                                                           if(result==null){
                                                             return;
                                                           }

                                                           var imageFile = result.xFile;

                                                           if (imageFile !=
                                                               null) {
                                                             //print(
                                                             //    "imageFile.lengthSync1():${imageFile
                                                             //        .lengthSync()}");

                                                             DateTime t = DateTime.now();
                                                             Directory tempDir = await getTemporaryDirectory();
                                                             var tempDirPath = tempDir.path;
                                                             final myAppPath = '$tempDirPath/威寶通/Student';
                                                             final res = await Directory(myAppPath).create(recursive: true);
                                                             String filePath = '${myAppPath}/${DateFormat('yyyyMMddHHmmss').format(t)}.jpg';

                                                             //壓縮image
                                                             EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].PICTURE_LINK_xfile = await FlutterImageCompress
                                                                 .compressAndGetFile(
                                                               imageFile.path, filePath,
                                                               minWidth: FlutterImageCompress_width,
                                                               minHeight: FlutterImageCompress_height,
                                                               quality: FlutterImageCompress_quality,
                                                               rotate: 0,
                                                             );

                                                             setState(() {

                                                             });

                                                             upload_PICTURE_LINK_CUSTOMER_db_sub(index:index);

                                                           }
                                                           else {
                                                             Navigator
                                                                 .pop(
                                                                 showModalBottomSheet_image_context!);
                                                           }
                                                         }




                                                       }
                                                       else {
                                                         PlatformFile? result = await FilePicker.pickFile(
                                                           //allowMultiple: false,
                                                           type: FileType.image,
                                                           //allowedExtensions: (Platform.isIOS)?null:['jpg','png','jpeg'],
                                                         );

                                                         if(result==null){
                                                           return;
                                                         }

                                                         var imageFile = result.xFile;

                                                         if (imageFile !=
                                                             null) {
                                                           //print(
                                                           //    "imageFile.lengthSync1():${imageFile
                                                           //        .lengthSync()}");

                                                           DateTime t = DateTime.now();
                                                           Directory tempDir = await getTemporaryDirectory();
                                                           var tempDirPath = tempDir.path;
                                                           final myAppPath = '$tempDirPath/威寶通/Student';
                                                           final res = await Directory(myAppPath).create(recursive: true);
                                                           String filePath = '${myAppPath}/${DateFormat('yyyyMMddHHmmss').format(t)}.jpg';

                                                           //壓縮image
                                                           EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].PICTURE_LINK_xfile = await FlutterImageCompress
                                                               .compressAndGetFile(
                                                             imageFile.path, filePath,
                                                             minWidth: FlutterImageCompress_width,
                                                             minHeight: FlutterImageCompress_height,
                                                             quality: FlutterImageCompress_quality,
                                                             rotate: 0,
                                                           );

                                                           setState(() {

                                                           });

                                                           upload_PICTURE_LINK_CUSTOMER_db_sub(index:index);

                                                         }
                                                         else {
                                                           Navigator
                                                               .pop(
                                                               showModalBottomSheet_image_context!);
                                                         }



                                                       }


                                                     },
                                                   ),
                                                 ],
                                               );
                                             });

                                      },
                                      child:
                                      Container(color: Color(0x01000000),width: 40.w,child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [

                                          CircleAvatar(
                                            radius: 20.w,
                                            backgroundImage: (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].PICTURE_LINK_xfile==null)?
                                            NetworkImage("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].PICTURE_LINK}"):
                                            FileImage(File(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].PICTURE_LINK_xfile!.path),scale: 0.9)
                                        ),
                                          /// 右上角的小圖 (例如相機)
                                          (end_ROLLCALL.length>0 || (start_ROLLCALL.length==0 && end_ROLLCALL.length==0))?
                                          Container()
                                          :
                                          Positioned(
                                            right: -15.w,
                                            top: -12.w,
                                            child: Image.asset(
                                              "assets/images/提示旗幟-03.png", // 你的小圖
                                              width: 26.w,
                                              height: 26.w,
                                            ),
                                          ),

                                      ],))),
                                  Container(width: 5.h,),
                                  Container(child:Row(children:[
                                    Container(width: 5.w,),
                                    Text('${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].CS_NM.replaceAll(" ", "")}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xff555555) , fontSize: 20.sp))
                                  ])),

                                  Expanded(child:Container()),

                                  Expanded(flex:2,child:Center(child:(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_DRUG_MT==true)?SvgPicture.asset("assets/images/组 29164-2.svg",width:20.w):Container())),
                                  //Text('${(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_DRUG_MT==true)?"(餵藥委託)":""}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.red , fontSize: 16.sp)))),

                                  Expanded(flex:2,child:Center(child:(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_ENTRUSTED==true)?SvgPicture.asset("assets/images/Icon fa-solid-car-side.svg",width:20.w,colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)):Container())),
                                  /*
                                    Expanded(flex:2,child:Center(child:
                                    Text('${(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_ENTRUSTED==true)?"(接送委託)":""}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.red , fontSize: 16.sp)))),

                                     */
                                  Expanded(flex:2,child:Center(child:(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_EXCUSED==true)?SvgPicture.asset("assets/images/Icon material-access-time.svg",width:20.w,colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)):Container())),
                                  /*
                                    Expanded(flex:1,child:Center(child:
                                    Text('${(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_EXCUSED==true)?"(請假)":""}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.red , fontSize: 16.sp)))),

                                     */

                                  Expanded(flex:2,child:Center(child:(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_DAILY_PRS==true)?SvgPicture.asset("assets/images/menu_book_24dp_5F6368_FILL0_wght400_GRAD0_opsz24.svg",width:22.w,colorFilter: ColorFilter.mode(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_STATUS==true?Colors.lightGreen:Colors.red, BlendMode.srcIn)):Container())),



                                  /*
                                    Expanded(flex:1,child:Center(child:
                                    Text('${start_time}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.blue , fontSize: 16.sp)))),
                                    Expanded(flex:1,child:Center(child:
                                    Text('${end_time}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.blue , fontSize: 16.sp)))),

                                     */
                                  //Expanded(child:Container()),

                                ],),
                                Container(height: 10.h,),
                                Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                              ],)));
                        })))

                  ],)),
                  /*
                Container(
                  width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                  child:Column(children: [
                    Expanded(child: Container()),
                    Row(children: [
                      Expanded(child: Container()),
                      GestureDetector(
                          //key: btnKey,
                          onTap: (){

                            /*
                  centerStarMenuController.openMenu!();
                  is_show=true;
                  setState(() {

                  });

                   */

                            menu = PopupMenu(
                              context: context,
                              config: MenuConfig(
                                  type: MenuType.grid,
                                  itemWidth:  (iPad==true)?50.w:80.w,
                                  itemHeight: (iPad==true)?60.h:90.h,
                                  //arrowHeight: (iPad==true)?70.h:90.h,
                                  maxColumn: (DAILY_MT_TYPE_ITEMs.length/4).toInt(),
                                  textStyle: TextStyle(color: Colors.white,fontSize: (iPad==true)?7.sp:14.sp),
                                  backgroundColor: Colors.black54
                              ),
                              items:DAILY_MT_TYPE_ITEMs_2.map((e){
                                return MenuItem(
                                    textStyle: TextStyle(color: Colors.white,fontSize: (iPad==true)?(e.ITEM_NO.contains("CLS"))?4.sp:7.sp:(e.ITEM_NO.contains("CLS"))?10.sp:14.sp),
                                    title: '${e.ITEM_NM}', image: e.svg_icon,userInfo: e);
                              }).toList(),
                              /*
                                   items: [
                                     MenuItem(title: 'Copy', image: Image.asset('assets/copy.png')),
                                     MenuItem(title: 'Power', image: Icon(Icons.power, color: Colors.white)),
                                     MenuItem(
                                         title: 'Setting', image: Icon(Icons.settings, color: Colors.white)),
                                     MenuItem(
                                         title: 'PopupMenu', image: Icon(Icons.menu, color: Colors.white))
                                   ],

                                    */
                              onClickMenu: (item){
                                print('Click menu -> ${item.menuTitle}');
                                if(item.menuUserInfo.ITEM_NO=="到/離校"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_ROLLCALL_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="ACT"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_ACT_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="MLK"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_MLK_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="POP"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_POP_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="CLN"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_CLN_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="CLS"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_CLS_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="EAT"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_EAT_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="DRY"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_DRY_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="TMP"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_TMP_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="SLP"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_SLP_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="RQD"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_RQD_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="CND"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_CND_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="NOT"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_NOT_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                /*
                        else if(item.menuUserInfo.ITEM_NO=="健康紀錄"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: GROWING_T_page()));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="成長曲線"){
                          showModalBottomSheet(
                              backgroundColor: Colors.white,
                              isScrollControlled:true,
                              context: context,
                              builder: (BuildContext context) {
                                showModalBottomSheet_GROWING_STANDARD_context = context;
                                return StatefulBuilder(
                                    builder: (BuildContext context, showModalBottomSheet_image_setState){
                                      this.showModalBottomSheet_GROWING_STANDARD_setState =
                                          showModalBottomSheet_image_setState;
                                      return Column(children: [

                                        Container(height: 45.h,),
                                        Row(children: [
                                          Expanded(child: Container()),
                                          GestureDetector(
                                              onTap:(){
                                                Navigator.pop(showModalBottomSheet_GROWING_STANDARD_context);
                                              },
                                              child: Icon(Icons.cancel_outlined,size: 30.sp,color: Colors.black,)),
                                          Container(width: 20.w,),
                                        ],),
                                        Container(height: 10.h,),
                                        Text("衛服部幼兒發展數據",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20.sp,
                                            color: Colors.lightBlue)),
                                        Container(height: 10.h,),
                                        Expanded(child: Container(child: Column(children: [

                                          Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(5.w),
                                              ),
                                              //width: 80.w,
                                              height: 36.h,
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  items: GROWING_STANDARD_TYPE
                                                      .map((String item) => DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item.split("-").last,
                                                      style: TextStyle(
                                                        fontSize: 18.sp,
                                                        fontWeight: FontWeight.bold,
                                                        color: const Color(0xff555555),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                                      .toList(),
                                                  value: sel_GROWING_STANDARD_TYPE,
                                                  onChanged: (value) {

                                                    Male_salesDatas_h.clear();
                                                    Female_salesDatas_h.clear();
                                                    Male_salesDatas_l.clear();
                                                    Female_salesDatas_l.clear();
                                                    sel_GROWING_STANDARD_TYPE = value!;

                                                    for(int i=0;i<GROWING_STANDARDs.length;i++){
                                                      if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="M"){
                                                        Male_salesDatas_h.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_H)));
                                                        Male_salesDatas_l.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_L)));
                                                      }
                                                      if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="F"){
                                                        Female_salesDatas_h.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_H)));
                                                        Female_salesDatas_l.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_L)));
                                                      }
                                                    }

                                                    Male_salesDatas_h.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Male_salesDatas_l.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Female_salesDatas_h.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Female_salesDatas_l.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    showModalBottomSheet_GROWING_STANDARD_setState(() {

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
                                          (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.SEX=="M")?
                                          Expanded(child: SfCartesianChart(

                                              primaryXAxis: CategoryAxis(
                                                  title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              primaryYAxis: CategoryAxis(
                                                  title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              // Chart title
                                              title: ChartTitle(text: '男生',textStyle: TextStyle(fontSize: 20.sp)),
                                              // Enable legend
                                              legend: Legend(isVisible: true),
                                              // Enable tooltip
                                              tooltipBehavior: _tooltipBehavior,

                                              series: <LineSeries<SalesData, String>>[
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_h.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據上限",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_l.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  name: "數據下限",
                                                )
                                              ]
                                          )):
                                          //Container(height: 20.h,),
                                          Expanded(child: SfCartesianChart(


                                              primaryXAxis: CategoryAxis(
                                                  title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              primaryYAxis: CategoryAxis(
                                                  title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              // Chart title
                                              title: ChartTitle(text: '女生',textStyle: TextStyle(fontSize: 20.sp)),
                                              // Enable legend
                                              legend: Legend(isVisible: true),
                                              // Enable tooltip
                                              tooltipBehavior: _tooltipBehavior,

                                              series: <LineSeries<SalesData, String>>[
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_h.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據上限",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_l.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據下限",
                                                )
                                              ]
                                          )),
                                          Container(height: 20.h,),

                                        ],))),


                                      ],);
                                    });

                              });

                          resd_GROWING_STANDARD_db_sub();
                        }
                        else if(item.menuUserInfo.ITEM_NO=="到/離校"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_ROLLCALL_page()));
                        }

                         */
                              },
                              onDismiss: (){

                              },
                            );
                            menu.show(widgetKey: btnKey);

                          },
                          child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black54.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 1), // changes position of shadow
                                  ),
                                ],
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                              child: Center(child:Icon(color: Colors.white,Icons.add,size: 30.sp,),))),
                      Container(width: 10.w,)
                    ],),
                    Container(height: 10.h,)
                  ],)
                )

                 */
                ],),

                Container(
                  width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                  padding: EdgeInsets.only(left:12.w,right: 12.w),child:Column(children: [

                  /*
                Container(
                    width: ScreenUtil().screenWidth,
                    height: 55.h,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                          surfaceTintColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.w),
                                  side: BorderSide(color: Color(0xff707070))
                              )
                          )
                      ),
                      onPressed: () async{
                      },
                      child: Row(children: [

                        Container(width: 15.w,),
                        SvgPicture.asset("assets/images/Icon-fa-solid-school-flag.svg",width: 12.sp),
                        Container(width: 15.w,),
                        Text("${user.DEPM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp)),
                        Expanded(child: Container()),
                      ],),
                    )),
                Container(height: 15.h,),

                 */
                  Container(height: 15.h,),
                  Container(width:ScreenUtil().screenWidth,height: 50.h,child:
                  Row(
                    children: [
                      Expanded(child:GestureDetector(
                          onTap: ()async{

                            page_notify_menu2="活動花絮";
                            setState(() {

                            });

                            BLOG_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");

                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 5.w),
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                                color: page_notify_menu2=="活動花絮"?Color(0xffF9AA88):Color(0xffffffff),
                                borderRadius: BorderRadius.circular(10.w),
                                border: Border.all(
                                  width: 1,
                                  color: Color(0xff555555),
                                )),
                            child: Center(child:Text("活動花絮",textScaler: TextScaler.linear(1),style: TextStyle(
                                fontFamily: "GenJyuuGothic",
                                fontWeight: FontWeight.normal,
                                fontSize: 16.sp,
                                color: Color(0xff555555)))),
                          ))),
                      Container(width: 8.w,),
                      Expanded(child:GestureDetector(
                          onTap: ()async{

                            page_notify_menu2="通知單";
                            setState(() {

                            });
                            await View_SURVEY_db_sub();
                            await SURVEY_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");

                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 5.w),
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                                color: page_notify_menu2=="通知單"?Color(0xffF9AA88):Color(0xffffffff),
                                borderRadius: BorderRadius.circular(10.w),
                                border: Border.all(
                                  width: 1,
                                  color: Color(0xff555555),
                                )),
                            child: Center(child:Text("通知單/問卷",style: TextStyle(
                                fontFamily: "GenJyuuGothic",
                                fontWeight: FontWeight.normal,
                                fontSize: 16.sp,
                                color: Color(0xff555555)))),
                          ))),
                    ],)),
                  Container(height: 10.h,),
                  (page_notify_menu2=="活動花絮")?
                  Expanded(child: Stack(children: [
                    Container(
                        color: Colors.white,
                        width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                        padding: EdgeInsets.only(left:0.w,right: 0.w),child:
                    Column(children: [

                      Row(children: [
                        Expanded(child:
                        GestureDetector(
                            onTap: ()async{


                              showMonthPicker(
                                context: context,
                                //locale: const Locale('zh'),
                                initialDate: DateTime.now(),
                                lastDate: DateTime.now(),
                                monthPickerDialogSettings: const MonthPickerDialogSettings(
                                  headerSettings: PickerHeaderSettings(
                                      headerBackgroundColor:Color(0xff004ea2)
                                  ),
                                ),
                              ).then((date) async{
                                if (date != null) {
                                  setState(() {
                                    sel_datetime_2 = date;
                                  });
                                  BLOG_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");
                                }
                              });


                            },
                            child: Column(children: [
                              Container(
                                  width: ScreenUtil().screenWidth,
                                  height: 50.w,
                                  padding: EdgeInsets.all(5.w),
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(20.w),
                                      border: Border.all(
                                        width: 1,
                                        color: Color(0xff555555),
                                      )),
                                  child:Row(children: [
                                    Container(width: 5.w,),
                                    Icon(Icons.calendar_today,color: Color(0xff555555),size: 28.sp,),
                                    Container(width: 5.w,),
                                    Text("${DateFormat('yyyy-MM').format(sel_datetime_2)}",style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                        color: Color(0xff292929))),
                                    Expanded(child: Container()),
                                    Icon(Icons.keyboard_arrow_down,color: Color(0xff555555),size: 24.sp,),
                                    Container(width: 5.w,),

                                  ],)
                              ),

                            ],))),
                        Container(width: 10.w,),
                        GestureDetector(
                            onTap: (){

                              BLOG_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");

                            },
                            child: Column(children: [
                              Container(
                                  width: 50.w,
                                  height: 50.w,
                                  padding: EdgeInsets.all(5.w),
                                  decoration: BoxDecoration(
                                      color: Color(0xffe7e8f5),
                                      borderRadius: BorderRadius.circular(20.w),
                                      border: Border.all(
                                        width: 1,
                                        color: Color(0xff555555),
                                      )),
                                  child:Center(child: Icon(Icons.search,size: 30.sp,),)
                              ),
                            ],)),
                      ],),
                      Container(height: 8.h,),
                      /*
                          GestureDetector(
                              onTap: (){



                              },
                              child: Container(color: Color(0x01000000),child:
                          Row(children: [
                            Expanded(child: Container()),
                            Container(child:Text("新增活動花絮",style: TextStyle(color: Colors.black,fontSize: 16.sp),)),
                            Icon(Icons.add_circle_outline,size: 24.sp,)
                          ],))),

                           */
                      Expanded(child:Container(width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                        child: ListView.builder(
                            padding: EdgeInsets.all(0.w),
                            itemCount: BLOG_list.length,
                            itemBuilder:(c,index){

                              return Container(
                                  margin: EdgeInsets.only(bottom: 5.h),
                                  width: ScreenUtil().screenWidth,
                                  //height: 55.w,
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                      color: BLOG_list[index].isExpanded==false?Colors.white:Color(0xfffff6dc),
                                      borderRadius: BorderRadius.circular(20.w),
                                      border: Border.all(
                                        width: 1,
                                        color: Color(0xff555555),
                                      )),
                                  child:Theme(
                                      data: ThemeData().copyWith(dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                          key: UniqueKey(),
                                          initiallyExpanded: BLOG_list[index].isExpanded,
                                          onExpansionChanged: (v){
                                            BLOG_list[index].isExpanded = v;
                                            setState(() {

                                            });
                                          },
                                          backgroundColor: Color(0xfffff6dc),
                                          iconColor: Color(0xff555555),
                                          collapsedIconColor: Color(0xff555555),
                                          tilePadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 0,top: 0),
                                          childrenPadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 10.h),
                                          title: Container(width: ScreenUtil().screenWidth,
                                            child: Column(children: [

                                              Row(children: [
                                                Text("活動日期:${BLOG_list[index].BLTN_DT_str}",style: TextStyle(
                                                    fontFamily: "GenJyuuGothic",
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.sp,
                                                    color: Color(0xff555555))),

                                                Expanded(child: Container()),
                                                GestureDetector(
                                                    onTap: (){


                                                      Navigator.push(context, PageTransition(
                                                          type: PageTransitionType.rightToLeft, child: EDIT_BLOG_page(bLOG:BLOG_list[index])));


                                                    },
                                                    child: Icon(Icons.edit,color: Colors.blueAccent,size: 24.sp,)),
                                                Container(width: 20.w,),
                                                GestureDetector(
                                                    onTap: (){

                                                      showCupertinoDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return Scaffold(
                                                                backgroundColor: Color(0x20000000),
                                                                body: StatefulBuilder(
                                                                    builder: (context, state) {
                                                                      return CupertinoAlertDialog(
                                                                        title: Text('確定刪除?', maxLines: 2,
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.red,
                                                                              fontSize: 18.0.sp),),
                                                                        content: Text('',
                                                                          textScaleFactor: 1,
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Colors.black54,
                                                                              fontSize: 16.0.sp),),
                                                                        actions: <Widget>[
                                                                          TextButton(
                                                                            child: Text('取消',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp)),
                                                                            onPressed: () {
                                                                              Navigator.of(context).pop();

                                                                            },
                                                                          ),


                                                                          TextButton(
                                                                            child: Text('刪除',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                                                            onPressed: () async{
                                                                              Navigator.of(context).pop();
                                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                                              SmartDialog.showLoading(msg: "處理中...");
                                                                              await Future.delayed(const Duration(milliseconds: 500), () {});
                                                                              await delete_BLOG_db_sub(BLOG_NO:BLOG_list[index].BLOG_NO);
                                                                              await delete_BLOG_DL_db_sub(BLOG_NO:BLOG_list[index].BLOG_NO);
                                                                              await BLOG_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");
                                                                              SmartDialog.dismiss();
                                                                              SmartDialog.showToast("處理成功");

                                                                            },
                                                                          ),

                                                                        ],
                                                                      );
                                                                    }));
                                                          });

                                                    },
                                                    child: Icon(Icons.delete_forever,color: Colors.red,size: 24.sp,)),

                                              ],),
                                              Container(
                                                  width: ScreenUtil().screenWidth,
                                                  child: Text("${BLOG_list[index].TITLE}",
                                                      maxLines: null,
                                                      style: TextStyle(
                                                          fontFamily: "GenJyuuGothic",
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 18.sp,
                                                          color: Color(0xff555555)))),

                                            ],),),
                                          children:[

                                            Container(
                                              width: ScreenUtil().screenWidth,
                                              child:Text("${BLOG_list[index].DETAIL}",style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16.sp,
                                                  color: Color(0xff555555))),
                                            ),
                                            GridView.builder(
                                              physics: const NeverScrollableScrollPhysics(),
                                              shrinkWrap:true,
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisSpacing: 4.w,
                                                mainAxisSpacing: 4.w,
                                                crossAxisCount: 2,
                                              ),
                                              itemCount: BLOG_list[index].LINK.length,
                                              itemBuilder: (context, index1) {

                                                return GestureDetector(
                                                    onTap: (){



                                                      showGeneralDialog(
                                                          context: context,
                                                          barrierDismissible: true,
                                                          barrierLabel:
                                                          MaterialLocalizations.of(context).modalBarrierDismissLabel,
                                                          barrierColor: Colors.black45,
                                                          transitionDuration: const Duration(milliseconds: 200),
                                                          pageBuilder: (BuildContext buildContext, Animation animation,
                                                              Animation secondaryAnimation) {
                                                            dev.log('${BLOG_list[index].LINK[index1]}');

                                                            final pageController = PageController();

                                                            // 確保跳轉在畫面建構完畢後
                                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                                              pageController.jumpToPage(index1);
                                                            });

                                                            return Center(
                                                              child: Container(
                                                                width: MediaQuery.of(context).size.width,
                                                                height: MediaQuery.of(context).size.height,
                                                                padding: const EdgeInsets.all(0),
                                                                color: Colors.white,
                                                                child: Stack(children: [

                                                                  PageView(
                                                                      controller:pageController,
                                                                      children: BLOG_list[index].LINK.map((e)=>
                                                                          WidgetZoom(
                                                                              heroAnimationTag: '${e}',
                                                                              zoomWidget: Image.network("${e}",
                                                                                errorBuilder: (BuildContext context, Object exception,
                                                                                    StackTrace? stackTrace) {
                                                                                  return  Icon(Icons.error,size: 30.sp,);
                                                                                },
                                                                              ))).toList()),
                                                                  Column(children: [
                                                                    Container(height: 45.h,),
                                                                    Row(children: [

                                                                      Container(width: 20.w,),
                                                                      GestureDetector(
                                                                          onTap:(){

                                                                          },
                                                                          child: Container(
                                                                              padding:EdgeInsets.all(2.w),
                                                                              decoration:BoxDecoration(
                                                                                color: Colors.white.withOpacity(0.5),
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child:Icon(Icons.cancel,color: Colors.transparent,size: 30.sp,))),

                                                                      Expanded(child:Text("點一下圖片可縮放",softWrap: true,textAlign: TextAlign.center,style: TextStyle(
                                                                          fontFamily: "GenJyuuGothic",
                                                                          fontWeight: FontWeight.normal,
                                                                          fontSize: 20.sp,
                                                                          color: Colors.lightBlue)), ),
                                                                      GestureDetector(
                                                                          onTap:(){
                                                                            Navigator.pop(buildContext);
                                                                          },
                                                                          child: Container(
                                                                              padding:EdgeInsets.all(2.w),
                                                                              decoration:BoxDecoration(
                                                                                color: Colors.white.withOpacity(0.5),
                                                                                shape: BoxShape.circle,
                                                                              ),
                                                                              child:Icon(Icons.cancel,color: Colors.black,size: 30.sp,))),
                                                                      Container(width: 20.w,),

                                                                    ],),

                                                                  ],)

                                                                ],),
                                                              ),
                                                            );
                                                          });

                                                    },
                                                    child: Container(

                                                        decoration: BoxDecoration(
                                                            border: Border.all(color: Colors.black87),
                                                            borderRadius: BorderRadius.circular(10.w)),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.all(Radius.circular(10.w)),
                                                          child: CachedNetworkImage(
                                                            imageUrl:'${BLOG_list[index].LINK[index1]}',
                                                            placeholder: (context, url) => Center(
                                                              child: SizedBox(
                                                                width: 30.0.w,
                                                                height: 30.0.w,
                                                                child: CircularProgressIndicator(),
                                                              ),
                                                            ),
                                                            errorWidget: (context, error, stackTrace){
                                                              return Container(
                                                                  child: Icon(Icons.photo,color: Colors.grey,size: 36.sp,),
                                                                  color: Colors.white54);
                                                            },
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )));
                                              },
                                            ),

                                          ])));
                            } ),))



                    ],)),
                    Container(

                        width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                        padding: EdgeInsets.only(left:0.w,right: 0.w),child:Column(children: [

                      Expanded(child:Container()),
                      Row(children: [
                        Expanded(child:Container()),
                        GestureDetector(
                          //key: btnKey,
                            onTap: (){

                              Navigator.push(context, PageTransition(
                                  type: PageTransitionType.rightToLeft, child: ADD_BLOG_page()));

                            },
                            child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black54.withOpacity(0.5),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(0, 1), // changes position of shadow
                                    ),
                                  ],
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                child: Center(child:Icon(color: Colors.white,Icons.add,size: 30.sp,),))),
                        Container(width: 8.w,)
                      ],),
                      Container(height: 15.h,)

                    ],))
                  ],))

                      :
                  (page_notify_menu2=="通知單")?
                  Expanded(child: Column(children: [

                    Row(children: [
                      Expanded(child:
                      GestureDetector(
                          onTap: ()async{


                            showMonthPicker(
                              context: context,
                              //locale: const Locale('zh'),
                              initialDate: DateTime.now(),
                              lastDate: DateTime.now(),
                              monthPickerDialogSettings: const MonthPickerDialogSettings(
                                headerSettings: PickerHeaderSettings(
                                    headerBackgroundColor:Color(0xff004ea2)
                                ),
                              ),
                            ).then((date) async{
                              if (date != null) {
                                setState(() {
                                  sel_datetime_2 = date;
                                });
                                await View_SURVEY_db_sub();
                                await SURVEY_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");
                              }
                            });


                          },
                          child: Column(children: [
                            Container(
                                width: ScreenUtil().screenWidth,
                                height: 50.w,
                                padding: EdgeInsets.all(5.w),
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(20.w),
                                    border: Border.all(
                                      width: 1,
                                      color: Color(0xff555555),
                                    )),
                                child:Row(children: [
                                  Container(width: 5.w,),
                                  Icon(Icons.calendar_today,color: Color(0xff555555),size: 28.sp,),
                                  Container(width: 5.w,),
                                  Text("${DateFormat('yyyy-MM').format(sel_datetime_2)}",style: TextStyle(
                                      fontFamily: "GenJyuuGothic",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      color: Color(0xff292929))),
                                  Expanded(child: Container()),
                                  Icon(Icons.keyboard_arrow_down,color: Color(0xff555555),size: 24.sp,),
                                  Container(width: 5.w,),

                                ],)
                            ),

                          ],))),
                      Container(width: 10.w,),
                      GestureDetector(
                          onTap: ()async{

                            await View_SURVEY_db_sub();
                            await SURVEY_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");

                          },
                          child: Column(children: [
                            Container(
                                width: 50.w,
                                height: 50.w,
                                padding: EdgeInsets.all(5.w),
                                decoration: BoxDecoration(
                                    color: Color(0xffe7e8f5),
                                    borderRadius: BorderRadius.circular(20.w),
                                    border: Border.all(
                                      width: 1,
                                      color: Color(0xff555555),
                                    )),
                                child:Center(child: Icon(Icons.search,size: 30.sp,),)
                            ),
                          ],)),
                    ],),
                    Container(height: 5.h,),
                    Expanded(child:Container(width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                      child: ListView.builder(
                          padding: EdgeInsets.all(5.w),
                          itemCount: SURVEY_list.length,
                          itemBuilder:(c,index){

                            List<String> headers = [];
                            List<List<String>> dataLists = [];


                            for(int i=0;i<SURVEY_list[index].survey_dl_list.length;i++){
                              headers.add("(${SURVEY_list[index].survey_dl_list[i].SR}).${SURVEY_list[index].survey_dl_list[i].NOTE}");

                              dev.log("i=${i}");
                              List<String> strs = [];
                              for(int j=0;j<View_SURVEY_list.length;j++){
                                if(View_SURVEY_list[j].NO==SURVEY_list[index].NO){
                                  if(SURVEY_list[index].survey_dl_list[i].SR==View_SURVEY_list[j].ANSWER){
                                    dev.log("i=${i},${View_SURVEY_list[j].NO},${j},${SURVEY_list[index].TITLE},ANSWER:${View_SURVEY_list[j].ANSWER},SR:${SURVEY_list[index].survey_dl_list[i].SR}");
                                    strs.add(View_SURVEY_list[j].KIDS_NM);
                                  }
                                  else{
                                    strs.add("");
                                  }
                                }
                              }
                              dataLists.add(strs);
                              dev.log("-------------------------------");
                            }



                            Map<String, List<String>> columnData = buildColumnData(headers, dataLists);

                            return Container(
                                margin: EdgeInsets.only(bottom: 5.h),
                                width: ScreenUtil().screenWidth,
                                //height: 55.w,
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                    color: Color(0xfffbf7f3),
                                    borderRadius: BorderRadius.circular(20.w),
                                    border: Border.all(
                                      width: 1,
                                      color: Color(0xff555555),
                                    )),
                                child:Container(width: ScreenUtil().screenWidth,
                                    child:Column(children: [

                                      Container(
                                          padding: EdgeInsets.only(top: 5.w,bottom: 5.w,left:15.w,right: 15.w),
                                          width: ScreenUtil().screenWidth,child: Text("${DateFormat("yyyy年MM月dd日").format(DateTime.parse(SURVEY_list[index].ADD_DATE))}",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                          fontFamily: "GenJyuuGothic",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                          color: Color(0xff555555)))),
                                      ("${SURVEY_list[index].LINK}".contains("null"))?Container():
                                      Container(
                                          padding: EdgeInsets.only(top: 5.w,bottom: 5.w,left:15.w,right: 15.w),
                                          width: ScreenUtil().screenWidth,child:
                                      Image.network(
                                        "${SURVEY_list[index].LINK}",fit: BoxFit.fitWidth,
                                        errorBuilder: (BuildContext context, Object exception,
                                            StackTrace? stackTrace) {
                                          return  Container();
                                        },
                                      )),
                                      Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xffEEE9E0),
                                              borderRadius: BorderRadius.circular(20.w),
                                              border: Border.all(
                                                width: 1,
                                                color: Color(0xffEEE9E0),
                                              )),
                                          padding: EdgeInsets.only(top: 5.w,bottom: 5.w,left:15.w,right: 15.w),
                                          width: ScreenUtil().screenWidth,child: Text("${SURVEY_list[index].TITLE}",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                          fontFamily: "GenJyuuGothic",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                          color: Color(0xff555555)))),
                                      Container(height: 5.h,),

                                      Container(
                                          width: ScreenUtil().screenWidth,child:Column(children: [

                                        Row(children: [

                                          Expanded(child: Text("統計結果:",style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 18.sp,
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.w400,
                                          ),)),

                                          Expanded(child: Text.rich(
                                            softWrap: true,
                                            maxLines:null,
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: '送出 ',
                                                  style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w400,color: Colors.blue),
                                                ),
                                                TextSpan(
                                                  text: '${SURVEY_list[index].View_SURVEY_COUNTS_SentCount}',
                                                  style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.bold,color: Colors.red),
                                                ),
                                                TextSpan(
                                                  text: ' 人',
                                                  style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w400,color: Colors.blue),
                                                ),
                                              ],
                                            ),
                                          )),
                                          Expanded(child: Text.rich(
                                            softWrap: true,
                                            maxLines:null,
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: '回復 ',
                                                  style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w400,color: Colors.blue),
                                                ),
                                                TextSpan(
                                                  text: '${SURVEY_list[index].View_SURVEY_COUNTS_ReceivedCount}',
                                                  style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.bold,color: Colors.red),
                                                ),
                                                TextSpan(
                                                  text: ' 人',
                                                  style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w400,color: Colors.blue),
                                                ),
                                              ],
                                            ),
                                          )),

                                        ],),
                                        Container(width: ScreenUtil().screenWidth,child:Wrap(
                                            children:SURVEY_list[index].survey_dl_list.map((e) {


                                              String AnswerCount = "0";
                                              for(int i=0;i<SURVEY_list[index].View_SURVEY_ANSWER_STATS_list.length;i++){
                                                if(SURVEY_list[index].View_SURVEY_ANSWER_STATS_list[i].ANSWER.trim()==e.SR.trim()){
                                                  AnswerCount = SURVEY_list[index].View_SURVEY_ANSWER_STATS_list[i].AnswerCount;
                                                }
                                              }

                                              dev.log('${SURVEY_list[index].View_SURVEY_COUNTS_SentCount},${AnswerCount}');

                                              return Row(children: [

                                                Expanded(child: Text.rich(
                                                  softWrap: true,
                                                  maxLines:null,
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: '(${e.SR.trim()}).',
                                                        style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w400,color: Colors.blue),
                                                      ),
                                                      TextSpan(
                                                        text: '${AnswerCount.isEmpty?0:AnswerCount}',
                                                        style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.bold,color: Colors.red),
                                                      ),
                                                      TextSpan(
                                                        text: '人  ',
                                                        style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w400,color: Colors.blue),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                                Expanded(flex: 3,child: Container(
                                                  margin: EdgeInsets.only(top: 5.h,bottom: 5.h),
                                                  //width: ScreenUtil().screenWidth,
                                                  height: 20.h,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: FractionallySizedBox(
                                                    alignment: Alignment.centerLeft, // 關鍵：靠左對齊
                                                    widthFactor:(SURVEY_list[index].View_SURVEY_COUNTS_SentCount.isEmpty)?0:getWidthFactor(
                                                        SURVEY_list[index].View_SURVEY_COUNTS_SentCount,
                                                        AnswerCount.toString(),
                                                      ),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                  ),
                                                ))

                                              ],);

                                            }

                                            ).toList())),

                                      ],)),
                                      Container(height: 5.h,),

                                      (SURVEY_list[index].survey_dl_list.length==0)?Container():
                                      DynamicTableWidget(
                                          columnData: columnData,
                                          textStyle: TextStyle(fontSize: 14.sp, color: Colors.black87),
                                      ),

                                      Container(height: 5.h,),
                                      /*
                                      (View_SURVEY_list.length==0)?Container():Column(children: View_SURVEY_list.map((e){
                                        dev.log("View_SURVEY_list(${e.NO}):${e.KIDS_NM}/${e.ANSWER.trim()}/${e.NOTE}/${e.ADD_DATE}");
                                        return (e.NO.trim()!=SURVEY_list[index].NO.trim())?Container():Container(width: ScreenUtil().screenWidth,child:
                                        Column(children: [

                                          Row(children: [

                                            Expanded(child:
                                            Text("${e.KIDS_NM}/${e.ANSWER.trim()}/${e.NOTE}/${e.ADD_DATE}",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w400,
                                                fontSize: 16.sp,
                                                color: Color(0xff555555)))),


                                          ],),
                                          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,)

                                        ],));
                                      }).toList()),
                                      Container(height: 5.h,),

                                       */


                                    ],)));
                          } ),)),

                  ],))
                      :
                  Expanded(child:Container())


                ],),),

                Column(children: [
                  Container(height: 15.h,),
                  Expanded(child: ChatPage_T_all())
                ]),

                Container(
                    width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                    padding: EdgeInsets.only(left:12.w,right: 12.w),child:Column(children: [

                  Container(height: 15.h,),
                  Container(
                      width: ScreenUtil().screenWidth,
                      height: 55.h,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                            surfaceTintColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                            padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32.w),
                                    side: BorderSide(color: Color(0xff707070))
                                )
                            )
                        ),
                        onPressed: () async{
                        },
                        child: Row(children: [

                          Container(width: 15.w,),
                          SvgPicture.asset("assets/images/Icon-fa-solid-school-flag.svg",width: 12.sp),
                          Container(width: 15.w,),
                          Text("${user.DEPM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp)),
                          Expanded(child: Container()),
                        ],),
                      )),
                  Container(height: 15.h,),
                  Expanded(child:Container(child:ListView(
                    padding: EdgeInsets.zero,
                    children: [

                      (EMPLOYEE_teacher.RANK=="M")?
                      Row(children: [
                        Expanded(child: Container(
                          width:ScreenUtil().screenWidth,
                          height: 50.h,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<Teacher_CUSTOMER>(
                              isExpanded: true,
                              items: EMPLOYEE_teacher.Teacher_CUSTOMERs
                                  .map((Teacher_CUSTOMER item) => DropdownMenuItem<Teacher_CUSTOMER>(
                                value: item,
                                child: Text(
                                  item.cLASS.CLASS_NM,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.normal,
                                    color: const Color(0xff555555),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                                  .toList(),
                              value: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue,
                              onChanged: (value) async{

                                dev.log("切換班級");
                                setState(() {
                                  EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue = value!;
                                });


                                if(page_notify_menu2=="活動花絮"){
                                  BLOG_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");
                                }
                                else{
                                  await View_SURVEY_db_sub();
                                  await SURVEY_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");
                                }

                                //切換班級當下初始化聊天室
                                ChatPage_T_all_fun2!();


                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50.h,
                                width: 160.w,
                                padding: const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.w),
                                  border: Border.all(
                                    color: Colors.black26,
                                  ),
                                  color: const Color(0xffffffff),
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: IconStyleData(
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                ),
                                iconSize: 30.sp,
                                iconEnabledColor: const Color(0xff555555),
                                iconDisabledColor: const Color(0xff555555),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 200.h,
                                width: 200.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: const Color(0xfffff5dd),
                                ),
                                offset: const Offset(0, 0),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(40),
                                  thickness: MaterialStateProperty.all(6),
                                  thumbVisibility: MaterialStateProperty.all(true),
                                ),
                              ),
                              menuItemStyleData: MenuItemStyleData(
                                height: 40.h,
                                padding: EdgeInsets.only(left: 14.w, right: 14.w),
                              ),
                            ),
                          ),
                        )),
                      ],)
                          :
                      Row(children: [
                        Expanded(child: Container(
                          width:ScreenUtil().screenWidth,
                          height: 50.h,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<Teacher_CUSTOMER>(
                              isExpanded: true,
                              items: EMPLOYEE_teacher.Teacher_CUSTOMERs
                                  .map((Teacher_CUSTOMER item) => DropdownMenuItem<Teacher_CUSTOMER>(
                                value: item,
                                child: Text(
                                  item.cLASS.CLASS_NM,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.normal,
                                    color: const Color(0xff555555),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                                  .toList(),
                              value: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue,
                              onChanged: (value) {


                                setState(() {
                                  EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue = value!;
                                });


                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50.h,
                                width: 160.w,
                                padding: const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.w),
                                  border: Border.all(
                                    color: Colors.black26,
                                  ),
                                  color: const Color(0xffffffff),
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: IconStyleData(
                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                ),
                                iconSize: 30.sp,
                                iconEnabledColor: const Color(0xff555555),
                                iconDisabledColor: const Color(0xff555555),
                              ),
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 200.h,
                                width: 200.w,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: const Color(0xfffff5dd),
                                ),
                                offset: const Offset(0, 0),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(40),
                                  thickness: MaterialStateProperty.all(6),
                                  thumbVisibility: MaterialStateProperty.all(true),
                                ),
                              ),
                              menuItemStyleData: MenuItemStyleData(
                                height: 40.h,
                                padding: EdgeInsets.only(left: 14.w, right: 14.w),
                              ),
                            ),
                          ),
                        )),
                      ],),

                      Container(height: 15.h,),
                      Container(width: ScreenUtil().screenWidth,height: 0.8,color: Colors.grey,),
                      Container(height: 15.h,),

                      Row(children: [

                        //帳號
                        Expanded(child:
                        Container(width: ScreenUtil().screenWidth,child: Column(children: [
                          Container(padding: EdgeInsets.only(left: 16.w),width: ScreenUtil().screenWidth,child:Text("帳號",textScaler: TextScaler.linear(1.0),style: TextStyle(color: Color(0xff555555),fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,fontSize: 16.sp))),
                          Container(
                              padding: EdgeInsets.only( left:16.w,right: 16.w),
                              width: ScreenUtil().screenWidth,
                              height: 62.h,
                              decoration: BoxDecoration(
                                color: Color(0xffFFFFFF),
                                borderRadius: BorderRadius.circular(18.w),
                                border: Border.all(
                                  color: Color(0xffB5B5B5),
                                ),
                              ),
                              child: Column(children: [

                                Expanded(child: Container()),
                                Form(
                                    child: TextFormField(
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        color: Color(0xff555555),
                                      ),
                                      enabled: false,
                                      controller: EMPLOYEE_teacher.admin_TextEditingController,
                                      keyboardType: TextInputType.phone,
                                      inputFormatters: [
                                        //RemoveEmojiInputFormatter()
                                      ],
                                      autofocus: false,
                                      //obscureText: !_adminVisible,
                                      //obscureText: !_accountVisible,//This will obscure text dynamically
                                      //maxLength: 50,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      //initialValue: 'edu_test010@ncku.com',
                                      //inputFormatters: [EmailLimitFormatter()],
                                      //validator: (value) => validateEmail(value!),
                                      decoration: InputDecoration(
                                        filled: true, //<-- SEE HERE
                                        fillColor: Colors.transparent, //<-- SEE HERE
                                        hintText: '${EMPLOYEE_teacher.ACCOUNT}',
                                        hintStyle: TextStyle(fontWeight: FontWeight.bold,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
                                        contentPadding:  EdgeInsets.only(left: 0,right: 0),
                                        /*
              suffixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  _adminVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Color(0xffB5B5B5),
                  size: 24.sp,
                ),
                onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  setState(() {
                    _adminVisible = !_adminVisible;
                  });
                },
              ),

               */
                                        border: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                            borderRadius: BorderRadius.circular(0.0)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                            borderRadius: BorderRadius.circular(0.0)),
                                        focusedBorder:OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                            borderRadius: BorderRadius.circular(0.0)),
                                        disabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                            borderRadius: BorderRadius.circular(0.0)),
                                      ),
                                    )),
                                Expanded(child: Container()),

                              ],)
                          )
                        ],))),
                        Container(width: 10.w,),
                        //密碼
                        Expanded(child:
                        Container(width: ScreenUtil().screenWidth,child: Column(children: [
                          Container(padding: EdgeInsets.only(left: 16.w),width: ScreenUtil().screenWidth,child:Text("密碼",textScaler: TextScaler.linear(1.0),style: TextStyle(color: Color(0xff555555),fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,fontSize: 16.sp))),
                          Container(
                              padding: EdgeInsets.only( left:16.w,right: 16.w),
                              width: ScreenUtil().screenWidth,
                              height: 62.h,
                              decoration: BoxDecoration(
                                color: Color(0xffffffff),
                                borderRadius: BorderRadius.circular(18.w),
                                border: Border.all(
                                  color: Color(0xffB5B5B5),
                                ),
                              ),
                              child: Column(children: [

                                Expanded(child: Container()),
                                Form(
                                    child: TextFormField(
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        color: Color(0xff555555),
                                      ),
                                      controller: EMPLOYEE_teacher.password_TextEditingController,
                                      keyboardType: TextInputType.text,
                                      autofocus: false,
                                      enabled: false,
                                      obscureText:true,
                                      //obscureText: !_passVisible,//This will obscure text dynamically
                                      //maxLength: 50,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      //initialValue: 'edu_test010@ncku.com',
                                      inputFormatters: [
                                        //RemoveEmojiInputFormatter()
                                      ],
                                      //validator: (value) => validateEmail(value!),
                                      decoration: InputDecoration(
                                        filled: true, //<-- SEE HERE
                                        fillColor: Colors.transparent, //<-- SEE HERE
                                        hintText: '${EMPLOYEE_teacher.PASSWORD}',
                                        hintStyle: TextStyle(fontWeight: FontWeight.bold,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
                                        contentPadding:  EdgeInsets.only(left: 0,right: 0),
                                        /*
              suffixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  _passVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Color(0xffB5B5B5),
                  size: 24.sp,
                ),


                onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  setState(() {
                    _passVisible = !_passVisible;
                  });
                },
              ),

               */


                                        border: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                            borderRadius: BorderRadius.circular(0.0)),
                                        enabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                            borderRadius: BorderRadius.circular(0.0)),
                                        focusedBorder:OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                            borderRadius: BorderRadius.circular(0.0)),
                                        disabledBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                            borderRadius: BorderRadius.circular(0.0)),
                                      ),
                                    )),
                                Expanded(child: Container()),

                              ],)
                          )
                        ],))),
                        Container(width: 10.w,),

                      ],),
                      Container(height: 10.h,),

                      //修改密碼
                      Container(width: ScreenUtil().screenWidth,child: Column(children: [
                        Container(padding: EdgeInsets.only(left: 16.w),width: ScreenUtil().screenWidth,child:Text("修改密碼",textScaler: TextScaler.linear(1.0),style: TextStyle(color: Color(0xff555555),fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,fontSize: 16.sp))),
                        Container(
                            padding: EdgeInsets.only( left:16.w,right: 16.w),
                            width: ScreenUtil().screenWidth,
                            height: 62.h,
                            decoration: BoxDecoration(
                              color: Color(0xffffffff),
                              borderRadius: BorderRadius.circular(18.w),
                              border: Border.all(
                                color: Color(0xffB5B5B5),
                              ),
                            ),
                            child: Column(children: [

                              Expanded(child: Container()),
                              Form(
                                  child: TextFormField(
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      color: Color(0xff555555),
                                    ),
                                    controller: EMPLOYEE_teacher.new_password_TextEditingController,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    //obscureText: !_passVisible,//This will obscure text dynamically
                                    //maxLength: 50,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    //initialValue: 'edu_test010@ncku.com',
                                    inputFormatters: [
                                      //RemoveEmojiInputFormatter()
                                    ],
                                    //validator: (value) => validateEmail(value!),
                                    decoration: InputDecoration(
                                      filled: true, //<-- SEE HERE
                                      fillColor: Colors.transparent, //<-- SEE HERE
                                      hintText: '請輸入...',
                                      hintStyle: TextStyle(fontWeight: FontWeight.bold,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
                                      contentPadding:  EdgeInsets.only(left: 0,right: 0),
                                      /*
              suffixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  _passVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Color(0xffB5B5B5),
                  size: 24.sp,
                ),


                onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  setState(() {
                    _passVisible = !_passVisible;
                  });
                },
              ),

               */


                                      border: OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                          borderRadius: BorderRadius.circular(0.0)),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                          borderRadius: BorderRadius.circular(0.0)),
                                      focusedBorder:OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                          borderRadius: BorderRadius.circular(0.0)),
                                      disabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                          borderRadius: BorderRadius.circular(0.0)),
                                    ),
                                  )),
                              Expanded(child: Container()),

                            ],)
                        )
                      ],)),
                      Container(height: 20.h,),

                      //日常用語設定
                      Container(
                          padding: EdgeInsets.only( left:0.w,right: 0.w),
                          width: ScreenUtil().screenWidth,
                          height: 55.h,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Color(0xffBDE187)),
                                surfaceTintColor: MaterialStateProperty.all(Color(0xffBDE187)),
                                padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28.w),
                                        side: BorderSide(color: Color(0xff555555))
                                    )
                                )
                            ),
                            onPressed: () async{

                              Navigator.push(context, PageTransition(
                                  type: PageTransitionType.rightToLeft, child: Daily_language_settings()));

                            },
                            child: Row(children: [
                              Expanded(child: Container()),
                              Text('日常用語設定', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                              Expanded(child: Container()),
                            ],),
                          )),
                      Container(height: 20.h,),

                      //預設簽名
                      Container(width: ScreenUtil().screenWidth,child: Column(children: [
                        Container(padding: EdgeInsets.only(left: 16.w),width: ScreenUtil().screenWidth,child:Text("預設簽名",textScaler: TextScaler.linear(1.0),style: TextStyle(color: Color(0xff555555),fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,fontSize: 16.sp))),
                        Container(
                            padding: EdgeInsets.all(16.w),
                            width: ScreenUtil().screenWidth,
                            height: 150.h,
                            decoration: BoxDecoration(
                              color: Color(0xffffffff),
                              borderRadius: BorderRadius.circular(18.w),
                              border: Border.all(
                                color: Color(0xffB5B5B5),
                              ),
                            ),
                            child: (EMPLOYEE_teacher.signaturebytes!=null)?Image.memory(EMPLOYEE_teacher.signaturebytes!):(EMPLOYEE_teacher.SIGN_LINK.isEmpty)?Container():Image.network("${EMPLOYEE_teacher.SIGN_LINK}",errorBuilder: (BuildContext context, Object exception,
                                StackTrace? stackTrace) {
                              return Container();
                            },)
                        ),
                        Container(height: 10.h,),
                        Row(children: [
                          Container(
                              padding: EdgeInsets.only( left:0.w,right: 0.w),
                              width: 90.w,
                              height: 40.h,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Color(0xffBDE187)),
                                    surfaceTintColor: MaterialStateProperty.all(Color(0xffBDE187)),
                                    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14.w),
                                            side: BorderSide(color: Color(0xff555555))
                                        )
                                    )
                                ),
                                onPressed: () async{
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: SignaturePage_teacher()));
                                },
                                child: Row(children: [
                                  Expanded(child: Container()),
                                  Text('修改簽名', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xff555555) , fontSize: 14.sp)),
                                  Expanded(child: Container()),
                                ],),
                              )),
                        ],),

                      ],)),
                      Container(height: 30.h,),
                      Container(
                          padding: EdgeInsets.only( left:0.w,right: 0.w),
                          width: ScreenUtil().screenWidth,
                          height: 55.h,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(Color(0xffF9AA88)),
                                surfaceTintColor: MaterialStateProperty.all(Color(0xffF9AA88)),
                                padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(28.w),
                                        side: BorderSide(color: Color(0xff555555))
                                    )
                                )
                            ),
                            onPressed: () async{

                              FocusScope.of(context).unfocus();
                              //if(cUSTOMERs[0].cUSTOMER_DL!.new_password_TextEditingController.text.isEmpty){
                              //  EasyLoading.showToast("請輸入新密碼");
                              //  return;
                              //}
                              FocusManager.instance.primaryFocus?.unfocus();
                              SmartDialog.showLoading(msg: "處理中...");


                              try {
                                String _token = await FirebaseMessaging.instance.getToken() ?? "";
                                dev.log("FirebaseMessaging token:${_token}");
                                if(DEBUG_MODE==false) {
                                  await updata_fcm_token_sub(TOKEN_ID: base64.encode(utf8.encode(_token)));
                                  user.TOKEN_ID = "${_token}";
                                }
                              }
                              catch(e){
                                dev.log("e:${e}");
                              }

                              if(EMPLOYEE_teacher.signaturebytes!=null){
                                String file_name = "${EMPLOYEE_teacher.ACCOUNT}_${DateTime.now().microsecondsSinceEpoch}";
                                await upload_image(img: EMPLOYEE_teacher.signaturebytes,file_name: file_name,folder: "Sign");
                                String SIGN_LINK = "~/School/Images/Sign/${file_name}.jpg";//簽名
                                await upload_xxx_from_EMPLOYEE_db(
                                  SIGN_LINK:SIGN_LINK,
                                  //PASSWORD:cUSTOMERs[0].cUSTOMER_DL!.new_password_TextEditingController.text,
                                  ACCOUNT:EMPLOYEE_teacher.ACCOUNT,
                                );//
                              }
                              if(EMPLOYEE_teacher.new_password_TextEditingController.text.isNotEmpty){
                                await upload_xxx_from_EMPLOYEE_db(
                                  PASSWORD:EMPLOYEE_teacher.new_password_TextEditingController.text,
                                  ACCOUNT:EMPLOYEE_teacher.ACCOUNT,
                                );//
                              }
                              SmartDialog.dismiss();
                              SmartDialog.showToast("處理成功");
                              checkPasswordChangeAndShowDialog(context, EMPLOYEE_teacher.new_password_TextEditingController);


                            },
                            child: Row(children: [
                              Expanded(child: Container()),
                              Text('儲存', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                              Expanded(child: Container()),
                            ],),
                          )),
                      Container(height: 30.h,),
                      /*
                    GestureDetector(
                        onTap: (){
                          sendPushNotification(token: user.TOKEN_ID);
                        },
                        child: Container(width: ScreenUtil().screenWidth,child: Center(child:Text("fcm推播測試", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xff292929) , fontSize: 22.sp))))),
                    Container(height: 30.h,),

                     */
                      GestureDetector(
                          onTap: ()async{

                            SmartDialog.showLoading(msg:"登出中...");


                            Timer _timer = Timer.periodic(Duration(seconds: 1), (timer) async{

                              if(is_finish_load==false){

                              }
                              else{

                                timer.cancel();

                                if(ChatPage_T_all_timer!=null) {
                                  ChatPage_T_all_timer!.cancel();
                                  ChatPage_T_all_timer=null;
                                }

                                //先清掉推播token
                                dev.log("先清掉推播token");
                                try{
                                 if(DEBUG_MODE==false) {
                                   String comm = "UPDATE EMPLOYEE SET FCM='' WHERE ACCOUNT='${EMPLOYEE_teacher
                                       .ACCOUNT}';";
                                   String result = await sql_command("${comm}");
                                 }
                                }
                                catch(e){

                                }


                                if(Platform.isIOS){
                                  await platform.invokeMethod("下斷線");
                                }

                                is_login_main = false;
                                user_is_login = false;
                                in_chat = false;
                                user = User();
                                EMPLOYEE_teacher = EMPLOYEE();//單一老師登入帳號
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setString('is_login', 'false');

                                Future.delayed(const Duration(milliseconds: 100), () {

                                  SmartDialog.dismiss();
                                  // 呼叫重啟
                                  Phoenix.rebirth(context);
                                  /*
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => MyApp()),
                                        (Route<dynamic> route) => route ==null ,
                                  );

                                   */

                                });


                              }
                              // 你可以根據狀態停止 loop
                              // if (某個條件) timer.cancel();
                            });


                          },
                          child: Container(width: ScreenUtil().screenWidth,child: Center(child:Text("登出", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xff292929) , fontSize: 22.sp))))),

                      Container(height: 20.h,),
                      Center(child:Text('版本:${packageInfo.version}(${packageInfo.buildNumber})', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 16.sp))),
                      Container(height: 50.h,),


                    ],)))
                ],))

              ])),

          /*
          Container(height: 44.h,)
          Expanded(child:
          (page=="設定")?
              Container(
              width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
              padding: EdgeInsets.only(left:12.w,right: 12.w),child:Column(children: [

                Container(height: 15.h,),
                Container(
                    width: ScreenUtil().screenWidth,
                    height: 55.h,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                          surfaceTintColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.w),
                                  side: BorderSide(color: Color(0xff707070))
                              )
                          )
                      ),
                      onPressed: () async{
                      },
                      child: Row(children: [

                        Container(width: 15.w,),
                        SvgPicture.asset("assets/images/Icon-fa-solid-school-flag.svg",width: 12.sp),
                        Container(width: 15.w,),
                        Text("${user.DEPM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp)),
                        Expanded(child: Container()),
                      ],),
                    )),
                Container(height: 15.h,),
                Expanded(child:Container(child:ListView(
                  padding: EdgeInsets.zero,
                  children: [

                    (EMPLOYEE_teacher.RANK=="M")?
                    Row(children: [
                      Expanded(child: Container(
                        width:ScreenUtil().screenWidth,
                        height: 50.h,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<Teacher_CUSTOMER>(
                            isExpanded: true,
                            items: EMPLOYEE_teacher.Teacher_CUSTOMERs
                                .map((Teacher_CUSTOMER item) => DropdownMenuItem<Teacher_CUSTOMER>(
                              value: item,
                              child: Text(
                                item.cLASS.CLASS_NM,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xff555555),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                                .toList(),
                            value: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue,
                            onChanged: (value) async{

                              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue = value!;
                              user.CLASS_NO = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO;
                              user.DEPM_NO = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO;
                              EMPLOYEE_teacher.CLASS_NO = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO;

                              if(page_notify_menu2=="活動花絮"){
                                await BLOG_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");
                              }
                              else if(page_notify_menu2=="通知單"){
                                await View_SURVEY_db_sub();
                                await SURVEY_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");
                              }

                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_ENTRUSTED=false;
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DRUG_MT=false;
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_EXCUSED=false;
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DAILY_PRS=false;
                              }
                              setState(() {

                              });

                              /*
                            檢查每位學生是否有用藥委託
                             */
                              await read_for_DRUG_MT_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                for(int k=0;k<DRUG_MT_list.length;k++){
                                  if(DRUG_MT_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DRUG_MT=true;
                                  }
                                }
                              }


                              /*
                            檢查每位學生是否有請假委託
                             */
                              await read_for_EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                for(int k=0;k<EXCUSED_list.length;k++){
                                  if(EXCUSED_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_EXCUSED=true;
                                  }
                                }
                              }


                              /*
                            檢查每位學生是否有接送委託
                             */
                              await read_for_ENTRUSTED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                for(int k=0;k<entrusted_pick_and_drop_list.length;k++){
                                  if(entrusted_pick_and_drop_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_ENTRUSTED=true;
                                  }
                                }
                              }



                              /*
                            檢查每位學生家長聯絡簿是否已回簽
                             */
                              await read_for_DAILY_PRS_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                for(int k=0;k<DAILY_PRSs.length;k++){
                                  if(DAILY_PRSs[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DAILY_PRS=true;
                                  }
                                }
                              }

                              setState(() {

                              });
                            },
                            buttonStyleData: ButtonStyleData(
                              height: 50.h,
                              width: 160.w,
                              padding: const EdgeInsets.only(left: 14, right: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.w),
                                border: Border.all(
                                  color: Colors.black26,
                                ),
                                color: const Color(0xffffffff),
                              ),
                              elevation: 2,
                            ),
                            iconStyleData: IconStyleData(
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                              ),
                              iconSize: 30.sp,
                              iconEnabledColor: const Color(0xff555555),
                              iconDisabledColor: const Color(0xff555555),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200.h,
                              width: 200.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: const Color(0xfffff5dd),
                              ),
                              offset: const Offset(0, 0),
                              scrollbarTheme: ScrollbarThemeData(
                                radius: const Radius.circular(40),
                                thickness: MaterialStateProperty.all(6),
                                thumbVisibility: MaterialStateProperty.all(true),
                              ),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              height: 40.h,
                              padding: EdgeInsets.only(left: 14.w, right: 14.w),
                            ),
                          ),
                        ),
                      )),
                    ],)
                        :
                    Row(children: [
                      Expanded(child: Container(
                        width:ScreenUtil().screenWidth,
                        height: 50.h,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton2<Teacher_CUSTOMER>(
                            isExpanded: true,
                            items: EMPLOYEE_teacher.Teacher_CUSTOMERs
                                .map((Teacher_CUSTOMER item) => DropdownMenuItem<Teacher_CUSTOMER>(
                              value: item,
                              child: Text(
                                item.cLASS.CLASS_NM,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xff555555),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ))
                                .toList(),
                            value: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue,
                            onChanged: (value) async{

                              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue = value!;
                              user.CLASS_NO = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO;
                              user.DEPM_NO = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO;
                              EMPLOYEE_teacher.CLASS_NO = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO;

                              if(page_notify_menu2=="活動花絮"){
                                await BLOG_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");
                              }
                              else if(page_notify_menu2=="通知單"){
                                await View_SURVEY_db_sub();
                                await SURVEY_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");
                              }

                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_ENTRUSTED=false;
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DRUG_MT=false;
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_EXCUSED=false;
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DAILY_PRS=false;
                              }
                              setState(() {

                              });

                              /*
                            檢查每位學生是否有用藥委託
                             */
                              await read_for_DRUG_MT_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                for(int k=0;k<DRUG_MT_list.length;k++){
                                  if(DRUG_MT_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DRUG_MT=true;
                                  }
                                }
                              }


                              /*
                            檢查每位學生是否有請假委託
                             */
                              await read_for_EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                for(int k=0;k<EXCUSED_list.length;k++){
                                  if(EXCUSED_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_EXCUSED=true;
                                  }
                                }
                              }


                              /*
                            檢查每位學生是否有接送委託
                             */
                              await read_for_ENTRUSTED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                for(int k=0;k<entrusted_pick_and_drop_list.length;k++){
                                  if(entrusted_pick_and_drop_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_ENTRUSTED=true;
                                  }
                                }
                              }



                              /*
                            檢查每位學生家長聯絡簿是否已回簽
                             */
                              await read_for_DAILY_PRS_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                              for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                for(int k=0;k<DAILY_PRSs.length;k++){
                                  if(DAILY_PRSs[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DAILY_PRS=true;
                                  }
                                }
                              }

                              setState(() {

                              });
                            },
                            buttonStyleData: ButtonStyleData(
                              height: 50.h,
                              width: 160.w,
                              padding: const EdgeInsets.only(left: 14, right: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.w),
                                border: Border.all(
                                  color: Colors.black26,
                                ),
                                color: const Color(0xffffffff),
                              ),
                              elevation: 2,
                            ),
                            iconStyleData: IconStyleData(
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                              ),
                              iconSize: 30.sp,
                              iconEnabledColor: const Color(0xff555555),
                              iconDisabledColor: const Color(0xff555555),
                            ),
                            dropdownStyleData: DropdownStyleData(
                              maxHeight: 200.h,
                              width: 200.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: const Color(0xfffff5dd),
                              ),
                              offset: const Offset(0, 0),
                              scrollbarTheme: ScrollbarThemeData(
                                radius: const Radius.circular(40),
                                thickness: MaterialStateProperty.all(6),
                                thumbVisibility: MaterialStateProperty.all(true),
                              ),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              height: 40.h,
                              padding: EdgeInsets.only(left: 14.w, right: 14.w),
                            ),
                          ),
                        ),
                      )),
                    ],),

                    Container(height: 15.h,),
                    Container(width: ScreenUtil().screenWidth,height: 0.8,color: Colors.grey,),
                    Container(height: 15.h,),

                    //帳號
                    Container(width: ScreenUtil().screenWidth,child: Column(children: [
                      Container(padding: EdgeInsets.only(left: 16.w),width: ScreenUtil().screenWidth,child:Text("帳號",textScaler: TextScaler.linear(1.0),style: TextStyle(color: Color(0xff555555),fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,fontSize: 16.sp))),
                      Container(
                          padding: EdgeInsets.only( left:16.w,right: 16.w),
                          width: ScreenUtil().screenWidth,
                          height: 62.h,
                          decoration: BoxDecoration(
                            color: Color(0xffFFFFFF),
                            borderRadius: BorderRadius.circular(18.w),
                            border: Border.all(
                              color: Color(0xffB5B5B5),
                            ),
                          ),
                          child: Column(children: [

                            Expanded(child: Container()),
                            Form(
                                child: TextFormField(
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Color(0xff555555),
                                  ),
                                  enabled: false,
                                  controller: EMPLOYEE_teacher.admin_TextEditingController,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [
                                    //RemoveEmojiInputFormatter()
                                  ],
                                  autofocus: false,
                                  //obscureText: !_adminVisible,
                                  //obscureText: !_accountVisible,//This will obscure text dynamically
                                  //maxLength: 50,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  //initialValue: 'edu_test010@ncku.com',
                                  //inputFormatters: [EmailLimitFormatter()],
                                  //validator: (value) => validateEmail(value!),
                                  decoration: InputDecoration(
                                    filled: true, //<-- SEE HERE
                                    fillColor: Colors.transparent, //<-- SEE HERE
                                    hintText: '${EMPLOYEE_teacher.ACCOUNT}',
                                    hintStyle: TextStyle(fontWeight: FontWeight.bold,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
                                    contentPadding:  EdgeInsets.only(left: 0,right: 0),
                                    /*
              suffixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  _adminVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Color(0xffB5B5B5),
                  size: 24.sp,
                ),
                onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  setState(() {
                    _adminVisible = !_adminVisible;
                  });
                },
              ),

               */
                                    border: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                        borderRadius: BorderRadius.circular(0.0)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                        borderRadius: BorderRadius.circular(0.0)),
                                    focusedBorder:OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                        borderRadius: BorderRadius.circular(0.0)),
                                    disabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                        borderRadius: BorderRadius.circular(0.0)),
                                  ),
                                )),
                            Expanded(child: Container()),

                          ],)
                      )
                    ],)),
                    Container(height: 10.h,),
                    //密碼
                    Container(width: ScreenUtil().screenWidth,child: Column(children: [
                      Container(padding: EdgeInsets.only(left: 16.w),width: ScreenUtil().screenWidth,child:Text("密碼",textScaler: TextScaler.linear(1.0),style: TextStyle(color: Color(0xff555555),fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,fontSize: 16.sp))),
                      Container(
                          padding: EdgeInsets.only( left:16.w,right: 16.w),
                          width: ScreenUtil().screenWidth,
                          height: 62.h,
                          decoration: BoxDecoration(
                            color: Color(0xffffffff),
                            borderRadius: BorderRadius.circular(18.w),
                            border: Border.all(
                              color: Color(0xffB5B5B5),
                            ),
                          ),
                          child: Column(children: [

                            Expanded(child: Container()),
                            Form(
                                child: TextFormField(
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Color(0xff555555),
                                  ),
                                  controller: EMPLOYEE_teacher.password_TextEditingController,
                                  keyboardType: TextInputType.text,
                                  autofocus: false,
                                  enabled: false,
                                  obscureText:true,
                                  //obscureText: !_passVisible,//This will obscure text dynamically
                                  //maxLength: 50,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  //initialValue: 'edu_test010@ncku.com',
                                  inputFormatters: [
                                    //RemoveEmojiInputFormatter()
                                  ],
                                  //validator: (value) => validateEmail(value!),
                                  decoration: InputDecoration(
                                    filled: true, //<-- SEE HERE
                                    fillColor: Colors.transparent, //<-- SEE HERE
                                    hintText: '${EMPLOYEE_teacher.PASSWORD}',
                                    hintStyle: TextStyle(fontWeight: FontWeight.bold,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
                                    contentPadding:  EdgeInsets.only(left: 0,right: 0),
                                    /*
              suffixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  _passVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Color(0xffB5B5B5),
                  size: 24.sp,
                ),


                onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  setState(() {
                    _passVisible = !_passVisible;
                  });
                },
              ),

               */


                                    border: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                        borderRadius: BorderRadius.circular(0.0)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                        borderRadius: BorderRadius.circular(0.0)),
                                    focusedBorder:OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                        borderRadius: BorderRadius.circular(0.0)),
                                    disabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                        borderRadius: BorderRadius.circular(0.0)),
                                  ),
                                )),
                            Expanded(child: Container()),

                          ],)
                      )
                    ],)),
                    Container(height: 10.h,),
                    //修改密碼
                    Container(width: ScreenUtil().screenWidth,child: Column(children: [
                      Container(padding: EdgeInsets.only(left: 16.w),width: ScreenUtil().screenWidth,child:Text("修改密碼",textScaler: TextScaler.linear(1.0),style: TextStyle(color: Color(0xff555555),fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,fontSize: 16.sp))),
                      Container(
                          padding: EdgeInsets.only( left:16.w,right: 16.w),
                          width: ScreenUtil().screenWidth,
                          height: 62.h,
                          decoration: BoxDecoration(
                            color: Color(0xffffffff),
                            borderRadius: BorderRadius.circular(18.w),
                            border: Border.all(
                              color: Color(0xffB5B5B5),
                            ),
                          ),
                          child: Column(children: [

                            Expanded(child: Container()),
                            Form(
                                child: TextFormField(
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Color(0xff555555),
                                  ),
                                  controller: EMPLOYEE_teacher.new_password_TextEditingController,
                                  keyboardType: TextInputType.text,
                                  autofocus: false,
                                  //obscureText: !_passVisible,//This will obscure text dynamically
                                  //maxLength: 50,
                                  autovalidateMode: AutovalidateMode.onUserInteraction,
                                  //initialValue: 'edu_test010@ncku.com',
                                  inputFormatters: [
                                    //RemoveEmojiInputFormatter()
                                  ],
                                  //validator: (value) => validateEmail(value!),
                                  decoration: InputDecoration(
                                    filled: true, //<-- SEE HERE
                                    fillColor: Colors.transparent, //<-- SEE HERE
                                    hintText: '請輸入...',
                                    hintStyle: TextStyle(fontWeight: FontWeight.bold,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
                                    contentPadding:  EdgeInsets.only(left: 0,right: 0),
                                    /*
              suffixIcon: IconButton(
                icon: Icon(
                  // Based on passwordVisible state choose the icon
                  _passVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Color(0xffB5B5B5),
                  size: 24.sp,
                ),


                onPressed: () {
                  // Update the state i.e. toogle the state of passwordVisible variable
                  setState(() {
                    _passVisible = !_passVisible;
                  });
                },
              ),

               */


                                    border: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                        borderRadius: BorderRadius.circular(0.0)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                        borderRadius: BorderRadius.circular(0.0)),
                                    focusedBorder:OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                        borderRadius: BorderRadius.circular(0.0)),
                                    disabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                        borderRadius: BorderRadius.circular(0.0)),
                                  ),
                                )),
                            Expanded(child: Container()),

                          ],)
                      )
                    ],)),
                    Container(height: 10.h,),
                    //預設簽名
                    Container(width: ScreenUtil().screenWidth,child: Column(children: [
                      Container(padding: EdgeInsets.only(left: 16.w),width: ScreenUtil().screenWidth,child:Text("預設簽名",textScaler: TextScaler.linear(1.0),style: TextStyle(color: Color(0xff555555),fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,fontSize: 16.sp))),
                      Container(
                          padding: EdgeInsets.all(16.w),
                          width: ScreenUtil().screenWidth,
                          height: 150.h,
                          decoration: BoxDecoration(
                            color: Color(0xffffffff),
                            borderRadius: BorderRadius.circular(18.w),
                            border: Border.all(
                              color: Color(0xffB5B5B5),
                            ),
                          ),
                          child: (EMPLOYEE_teacher.signaturebytes!=null)?Image.memory(EMPLOYEE_teacher.signaturebytes!):(EMPLOYEE_teacher.SIGN_LINK.isEmpty)?Container():Image.network("${EMPLOYEE_teacher.SIGN_LINK}",errorBuilder: (BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return Container();
                          },)
                      ),
                      Container(height: 10.h,),
                      Row(children: [
                        Container(
                            padding: EdgeInsets.only( left:0.w,right: 0.w),
                            width: 90.w,
                            height: 40.h,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Color(0xffBDE187)),
                                  surfaceTintColor: MaterialStateProperty.all(Color(0xffBDE187)),
                                  padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14.w),
                                          side: BorderSide(color: Color(0xff555555))
                                      )
                                  )
                              ),
                              onPressed: () async{
                                Navigator.push(context, PageTransition(
                                    type: PageTransitionType.rightToLeft, child: SignaturePage_teacher()));
                              },
                              child: Row(children: [
                                Expanded(child: Container()),
                                Text('修改簽名', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xff555555) , fontSize: 14.sp)),
                                Expanded(child: Container()),
                              ],),
                            )),
                      ],),

                    ],)),
                    Container(height: 30.h,),
                    Container(
                        padding: EdgeInsets.only( left:0.w,right: 0.w),
                        width: ScreenUtil().screenWidth,
                        height: 55.h,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Color(0xffF9AA88)),
                              surfaceTintColor: MaterialStateProperty.all(Color(0xffF9AA88)),
                              padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28.w),
                                      side: BorderSide(color: Color(0xff555555))
                                  )
                              )
                          ),
                          onPressed: () async{

                            FocusScope.of(context).unfocus();
                            //if(cUSTOMERs[0].cUSTOMER_DL!.new_password_TextEditingController.text.isEmpty){
                            //  EasyLoading.showToast("請輸入新密碼");
                            //  return;
                            //}

                            if(EMPLOYEE_teacher.signaturebytes!=null){
                              String file_name = "${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}";
                              await upload_image(img: EMPLOYEE_teacher.signaturebytes,file_name: file_name,folder: "Sign");
                              String SIGN_LINK = "~/School/Images/Sign/${file_name}.jpg";//簽名
                              await upload_xxx_from_EMPLOYEE_db(
                                 SIGN_LINK:SIGN_LINK,
                                 //PASSWORD:cUSTOMERs[0].cUSTOMER_DL!.new_password_TextEditingController.text,
                                 ACCOUNT:EMPLOYEE_teacher.ACCOUNT,
                              );//
                            }
                            if(EMPLOYEE_teacher.new_password_TextEditingController.text.isNotEmpty){
                              await upload_xxx_from_EMPLOYEE_db(
                                PASSWORD:EMPLOYEE_teacher.new_password_TextEditingController.text,
                                ACCOUNT:EMPLOYEE_teacher.ACCOUNT,
                              );//
                            }


                          },
                          child: Row(children: [
                            Expanded(child: Container()),
                            Text('儲存', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                            Expanded(child: Container()),
                          ],),
                        )),
                    Container(height: 30.h,),
                    /*
                    GestureDetector(
                        onTap: (){
                          sendPushNotification(token: user.TOKEN_ID);
                        },
                        child: Container(width: ScreenUtil().screenWidth,child: Center(child:Text("fcm推播測試", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xff292929) , fontSize: 22.sp))))),
                    Container(height: 30.h,),

                     */
                    GestureDetector(
                        onTap: ()async{
                          if(Platform.isIOS){
                            await platform.invokeMethod("下斷線");
                          }
                          is_login_main = false;
                          user_is_login = false;
                          in_chat = false;
                          user = User();
                          EMPLOYEE_teacher = EMPLOYEE();//單一老師登入帳號
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('is_login', 'false');
                          SmartDialog.dismiss();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => MyApp()),
                                (Route<dynamic> route) => route ==null ,
                          );
                        },
                        child: Container(width: ScreenUtil().screenWidth,child: Center(child:Text("登出", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xff292929) , fontSize: 22.sp))))),

                    Container(height: 20.h,),
                    Center(child:Text('版本:${packageInfo.version}(${packageInfo.buildNumber})', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 16.sp))),
                    Container(height: 50.h,),


                ],)))
              ],))
              :
          (page=="通知")?
              Container(
              width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
              padding: EdgeInsets.only(left:12.w,right: 12.w),child:Column(children: [

                Container(
                width: ScreenUtil().screenWidth,
                height: 55.h,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                      surfaceTintColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                      padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.w),
                              side: BorderSide(color: Color(0xff707070))
                          )
                      )
                  ),
                  onPressed: () async{
                  },
                  child: Row(children: [

                    Container(width: 15.w,),
                    SvgPicture.asset("assets/images/Icon-fa-solid-school-flag.svg",width: 12.sp),
                    Container(width: 15.w,),
                    Text("${user.DEPM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp)),
                    Expanded(child: Container()),
                  ],),
                )),
                Container(height: 15.h,),
                Expanded(child: Container())

                ],))
              :
          (page=="公告")?
              Container(
              width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
              padding: EdgeInsets.only(left:12.w,right: 12.w),child:Column(children: [

                /*
                Container(
                    width: ScreenUtil().screenWidth,
                    height: 55.h,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                          surfaceTintColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32.w),
                                  side: BorderSide(color: Color(0xff707070))
                              )
                          )
                      ),
                      onPressed: () async{
                      },
                      child: Row(children: [

                        Container(width: 15.w,),
                        SvgPicture.asset("assets/images/Icon-fa-solid-school-flag.svg",width: 12.sp),
                        Container(width: 15.w,),
                        Text("${user.DEPM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp)),
                        Expanded(child: Container()),
                      ],),
                    )),
                Container(height: 15.h,),

                 */
                Container(height: 15.h,),
                Container(width:ScreenUtil().screenWidth,height: 50.h,child:
                Row(
                  children: [
                  Expanded(child:GestureDetector(
                      onTap: ()async{

                        page_notify_menu2="活動花絮";
                        setState(() {

                        });

                        BLOG_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");

                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 5.w),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                            color: page_notify_menu2=="活動花絮"?Color(0xffF9AA88):Color(0xffffffff),
                            borderRadius: BorderRadius.circular(10.w),
                            border: Border.all(
                              width: 1,
                              color: Color(0xff555555),
                            )),
                        child: Center(child:Text("活動花絮",textScaler: TextScaler.linear(1),style: TextStyle(
                            fontFamily: "GenJyuuGothic",
                            fontWeight: FontWeight.normal,
                            fontSize: 16.sp,
                            color: Color(0xff555555)))),
                      ))),
                  Container(width: 8.w,),
                  Expanded(child:GestureDetector(
                      onTap: ()async{

                        page_notify_menu2="通知單";
                        setState(() {

                        });
                        await View_SURVEY_db_sub();
                        await SURVEY_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");

                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 5.w),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                            color: page_notify_menu2=="通知單"?Color(0xffF9AA88):Color(0xffffffff),
                            borderRadius: BorderRadius.circular(10.w),
                            border: Border.all(
                              width: 1,
                              color: Color(0xff555555),
                            )),
                        child: Center(child:Text("通知單/問卷",style: TextStyle(
                            fontFamily: "GenJyuuGothic",
                            fontWeight: FontWeight.normal,
                            fontSize: 16.sp,
                            color: Color(0xff555555)))),
                      ))),
                ],)),
                Container(height: 10.h,),
                (page_notify_menu2=="活動花絮")?
                Expanded(child: Stack(children: [
                  Container(
                      color: Colors.white,
                      width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                      padding: EdgeInsets.only(left:0.w,right: 0.w),child:
                      Column(children: [

                    Row(children: [
                      Expanded(child:
                      GestureDetector(
                          onTap: ()async{


                            showMonthPicker(
                              context: context,
                              //locale: const Locale('zh'),
                              initialDate: DateTime.now(),
                              lastDate: DateTime.now(),
                              monthPickerDialogSettings: const MonthPickerDialogSettings(
                                headerSettings: PickerHeaderSettings(
                                    headerBackgroundColor:Color(0xff004ea2)
                                ),
                              ),
                            ).then((date) async{
                              if (date != null) {
                                setState(() {
                                  sel_datetime_2 = date;
                                });
                                BLOG_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");
                              }
                            });


                          },
                          child: Column(children: [
                            Container(
                                width: ScreenUtil().screenWidth,
                                height: 50.w,
                                padding: EdgeInsets.all(5.w),
                                decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(20.w),
                                    border: Border.all(
                                      width: 1,
                                      color: Color(0xff555555),
                                    )),
                                child:Row(children: [
                                  Container(width: 5.w,),
                                  Icon(Icons.calendar_today,color: Color(0xff555555),size: 28.sp,),
                                  Container(width: 5.w,),
                                  Text("${DateFormat('yyyy-MM').format(sel_datetime_2)}",style: TextStyle(
                                      fontFamily: "GenJyuuGothic",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      color: Color(0xff292929))),
                                  Expanded(child: Container()),
                                  Icon(Icons.keyboard_arrow_down,color: Color(0xff555555),size: 24.sp,),
                                  Container(width: 5.w,),

                                ],)
                            ),

                          ],))),
                      Container(width: 10.w,),
                      GestureDetector(
                          onTap: (){

                            BLOG_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");

                          },
                          child: Column(children: [
                            Container(
                                width: 50.w,
                                height: 50.w,
                                padding: EdgeInsets.all(5.w),
                                decoration: BoxDecoration(
                                    color: Color(0xffe7e8f5),
                                    borderRadius: BorderRadius.circular(20.w),
                                    border: Border.all(
                                      width: 1,
                                      color: Color(0xff555555),
                                    )),
                                child:Center(child: Icon(Icons.search,size: 30.sp,),)
                            ),
                          ],)),
                    ],),
                    Container(height: 8.h,),
                    /*
                          GestureDetector(
                              onTap: (){



                              },
                              child: Container(color: Color(0x01000000),child:
                          Row(children: [
                            Expanded(child: Container()),
                            Container(child:Text("新增活動花絮",style: TextStyle(color: Colors.black,fontSize: 16.sp),)),
                            Icon(Icons.add_circle_outline,size: 24.sp,)
                          ],))),

                           */
                    Expanded(child:Container(width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                      child: ListView.builder(
                          padding: EdgeInsets.all(0.w),
                          itemCount: BLOG_list.length,
                          itemBuilder:(c,index){



                            return Container(
                                margin: EdgeInsets.only(bottom: 5.h),
                                width: ScreenUtil().screenWidth,
                                //height: 55.w,
                                padding: EdgeInsets.all(3.w),
                                decoration: BoxDecoration(
                                    color: BLOG_list[index].isExpanded==false?Colors.white:Color(0xfffff6dc),
                                    borderRadius: BorderRadius.circular(20.w),
                                    border: Border.all(
                                      width: 1,
                                      color: Color(0xff555555),
                                    )),
                                child:Theme(
                                    data: ThemeData().copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                        key: UniqueKey(),
                                        initiallyExpanded: BLOG_list[index].isExpanded,
                                        onExpansionChanged: (v){
                                          BLOG_list[index].isExpanded = v;
                                          setState(() {

                                          });
                                        },
                                        backgroundColor: Color(0xfffff6dc),
                                        iconColor: Color(0xff555555),
                                        collapsedIconColor: Color(0xff555555),
                                        tilePadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 0,top: 0),
                                        childrenPadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 10.h),
                                        title: Container(width: ScreenUtil().screenWidth,
                                          child: Column(children: [

                                            Row(children: [
                                              Text("活動日期:${BLOG_list[index].BLTN_DT_str}",style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                  color: Color(0xff555555))),

                                              Expanded(child: Container()),
                                              GestureDetector(
                                                  onTap: (){


                                                    Navigator.push(context, PageTransition(
                                                        type: PageTransitionType.rightToLeft, child: EDIT_BLOG_page(bLOG:BLOG_list[index])));


                                                  },
                                                  child: Icon(Icons.edit,color: Colors.blueAccent,size: 24.sp,)),
                                              Container(width: 20.w,),
                                              GestureDetector(
                                                  onTap: (){

                                                    showCupertinoDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return Scaffold(
                                                              backgroundColor: Color(0x20000000),
                                                              body: StatefulBuilder(
                                                                  builder: (context, state) {
                                                                    return CupertinoAlertDialog(
                                                                      title: Text('確定刪除?', maxLines: 2,
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            color: Colors.red,
                                                                            fontSize: 18.0.sp),),
                                                                      content: Text('',
                                                                        textScaleFactor: 1,
                                                                        style: TextStyle(
                                                                            fontWeight: FontWeight.bold,
                                                                            color: Colors.black54,
                                                                            fontSize: 16.0.sp),),
                                                                      actions: <Widget>[
                                                                        TextButton(
                                                                          child: Text('取消',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp)),
                                                                          onPressed: () {
                                                                            Navigator.of(context).pop();

                                                                          },
                                                                        ),


                                                                        TextButton(
                                                                          child: Text('刪除',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                                                          onPressed: () async{
                                                                            Navigator.of(context).pop();

                                                                            SmartDialog.showLoading(msg: "處理中...");
                                                                            await Future.delayed(const Duration(milliseconds: 500), () {});
                                                                            await delete_BLOG_db_sub(BLOG_NO:BLOG_list[index].BLOG_NO);
                                                                            await delete_BLOG_DL_db_sub(BLOG_NO:BLOG_list[index].BLOG_NO);
                                                                            await BLOG_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");
                                                                            SmartDialog.dismiss();
                                                                            SmartDialog.showToast("處理成功");

                                                                          },
                                                                        ),

                                                                      ],
                                                                    );
                                                                  }));
                                                        });

                                                  },
                                                  child: Icon(Icons.delete_forever,color: Colors.red,size: 24.sp,)),

                                            ],),
                                            Container(
                                                width: ScreenUtil().screenWidth,
                                                child: Text("${BLOG_list[index].TITLE}",
                                                    maxLines: null,
                                                    style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 18.sp,
                                                        color: Color(0xff555555)))),

                                          ],),),
                                        children:[

                                          Container(
                                            width: ScreenUtil().screenWidth,
                                            child:Text("${BLOG_list[index].DETAIL}",style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16.sp,
                                                color: Color(0xff555555))),
                                          ),
                                          GridView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap:true,
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisSpacing: 4.w,
                                              mainAxisSpacing: 4.w,
                                              crossAxisCount: 2,
                                            ),
                                            itemCount: BLOG_list[index].LINK.length,
                                            itemBuilder: (context, index1) {
                                              dev.log('${BLOG_list[index].LINK[index1]}');
                                              return GestureDetector(
                                                  onTap: (){

                                                    PageController pageController = PageController(initialPage: index1);
                                                showGeneralDialog(
                                                    context: context,
                                                    barrierDismissible: true,
                                                    barrierLabel:
                                                    MaterialLocalizations.of(context).modalBarrierDismissLabel,
                                                    barrierColor: Colors.black45,
                                                    transitionDuration: const Duration(milliseconds: 200),
                                                    pageBuilder: (BuildContext buildContext, Animation animation,
                                                        Animation secondaryAnimation) {
                                                      return Center(
                                                        child: Container(
                                                          width: MediaQuery.of(context).size.width,
                                                          height: MediaQuery.of(context).size.height,
                                                          padding: EdgeInsets.all(0),
                                                          color: Colors.white,
                                                          child: Stack(children: [

                                                            PageView(
                                                                controller:pageController,
                                                                children: BLOG_list[index].LINK.map((e)=>
                                                                    WidgetZoom(
                                                                        heroAnimationTag: '${e}',
                                                                        zoomWidget: Image.network("${e}",
                                                                          errorBuilder: (BuildContext context, Object exception,
                                                                              StackTrace? stackTrace) {
                                                                            return  Icon(Icons.error,size: 30.sp,);
                                                                          },
                                                                        ))).toList()),
                                                            Column(children: [
                                                              Container(height: 45.h,),
                                                              Row(children: [

                                                                Expanded(child:Container() ),
                                                                GestureDetector(
                                                                    onTap:(){
                                                                      Navigator.pop(buildContext);
                                                                    },
                                                                    child: Container(
                                                                        padding:EdgeInsets.all(2.w),
                                                                        decoration:BoxDecoration(
                                                                          color: Colors.white.withOpacity(0.5),
                                                                          shape: BoxShape.circle,
                                                                        ),
                                                                        child:Icon(Icons.cancel,color: Colors.black,size: 30.sp,))),
                                                                Container(width: 20.w,),

                                                              ],),
                                                              Text("點一下圖片可縮放",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                                  fontFamily: "GenJyuuGothic",
                                                                  fontWeight: FontWeight.normal,
                                                                  fontSize: 20.sp,
                                                                  color: Colors.lightBlue)),
                                                            ],)

                                                          ],),
                                                        ),
                                                      );
                                                    });

                                              },
                                              child: Container(

                                                  decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.black87),
                                                      borderRadius: BorderRadius.circular(10.w)),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.all(Radius.circular(10.w)),
                                                    child: CachedNetworkImage(
                                                      imageUrl:'${BLOG_list[index].LINK[index1]}',
                                                      placeholder: (context, url) => Center(
                                                        child: SizedBox(
                                                          width: 30.0.w,
                                                          height: 30.0.w,
                                                          child: CircularProgressIndicator(),
                                                        ),
                                                      ),
                                                      errorWidget: (context, error, stackTrace){
                                                        return Container(
                                                            child: Icon(Icons.photo,color: Colors.grey,size: 36.sp,),
                                                            color: Colors.white54);
                                                      },
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )));
                                            },
                                          ),

                                        ])));
                          } ),))



                  ],)),
                  Container(

                      width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                      padding: EdgeInsets.only(left:0.w,right: 0.w),child:Column(children: [

                        Expanded(child:Container()),
                        Row(children: [
                          Expanded(child:Container()),
                          GestureDetector(
                              //key: btnKey,
                              onTap: (){

                                Navigator.push(context, PageTransition(
                                    type: PageTransitionType.rightToLeft, child: ADD_BLOG_page()));

                              },
                              child: Container(
                                  padding: EdgeInsets.all(8.w),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black54.withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 2,
                                        offset: Offset(0, 1), // changes position of shadow
                                      ),
                                    ],
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                  child: Center(child:Icon(color: Colors.white,Icons.add,size: 30.sp,),))),
                          Container(width: 8.w,)
                        ],),
                        Container(height: 15.h,)

                  ],))
                ],))

                    :
                (page_notify_menu2=="通知單")?
                Expanded(child: Column(children: [

                  Row(children: [
                    Expanded(child:
                    GestureDetector(
                        onTap: ()async{


                          showMonthPicker(
                            context: context,
                            //locale: const Locale('zh'),
                            initialDate: DateTime.now(),
                            lastDate: DateTime.now(),
                            monthPickerDialogSettings: const MonthPickerDialogSettings(
                              headerSettings: PickerHeaderSettings(
                                  headerBackgroundColor:Color(0xff004ea2)
                              ),
                            ),
                          ).then((date) async{
                            if (date != null) {
                              setState(() {
                                sel_datetime_2 = date;
                              });
                              await View_SURVEY_db_sub();
                              await SURVEY_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");
                            }
                          });


                        },
                        child: Column(children: [
                          Container(
                              width: ScreenUtil().screenWidth,
                              height: 50.w,
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20.w),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xff555555),
                                  )),
                              child:Row(children: [
                                Container(width: 5.w,),
                                Icon(Icons.calendar_today,color: Color(0xff555555),size: 28.sp,),
                                Container(width: 5.w,),
                                Text("${DateFormat('yyyy-MM').format(sel_datetime_2)}",style: TextStyle(
                                    fontFamily: "GenJyuuGothic",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: Color(0xff292929))),
                                Expanded(child: Container()),
                                Icon(Icons.keyboard_arrow_down,color: Color(0xff555555),size: 24.sp,),
                                Container(width: 5.w,),

                              ],)
                          ),

                        ],))),
                    Container(width: 10.w,),
                    GestureDetector(
                        onTap: ()async{

                          await View_SURVEY_db_sub();
                          await SURVEY_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_2)}");

                        },
                        child: Column(children: [
                          Container(
                              width: 50.w,
                              height: 50.w,
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                  color: Color(0xffe7e8f5),
                                  borderRadius: BorderRadius.circular(20.w),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xff555555),
                                  )),
                              child:Center(child: Icon(Icons.search,size: 30.sp,),)
                          ),
                        ],)),
                  ],),
                  Container(height: 5.h,),
                  Expanded(child:Container(width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                    child: ListView.builder(
                        padding: EdgeInsets.all(5.w),
                        itemCount: SURVEY_list.length,
                        itemBuilder:(c,index){

                          return Container(
                              margin: EdgeInsets.only(bottom: 5.h),
                              width: ScreenUtil().screenWidth,
                              //height: 55.w,
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                  color: Color(0xfffbf7f3),
                                  borderRadius: BorderRadius.circular(20.w),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xff555555),
                                  )),
                              child:Container(width: ScreenUtil().screenWidth,
                                  child:Column(children: [

                                    Container(
                                        padding: EdgeInsets.only(top: 5.w,bottom: 5.w,left:15.w,right: 15.w),
                                        width: ScreenUtil().screenWidth,child: Text("${DateFormat("yyyy年MM月dd日").format(DateTime.parse(SURVEY_list[index].ADD_DATE))}",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                        color: Color(0xff555555)))),
                                    ("${SURVEY_list[index].LINK}".contains("null"))?Container():
                                    Container(
                                        padding: EdgeInsets.only(top: 5.w,bottom: 5.w,left:15.w,right: 15.w),
                                        width: ScreenUtil().screenWidth,child:
                                    Image.network(
                                      "${SURVEY_list[index].LINK}",fit: BoxFit.fitWidth,
                                      errorBuilder: (BuildContext context, Object exception,
                                          StackTrace? stackTrace) {
                                        return  Container();
                                      },
                                    )),
                                    Container(
                                        decoration: BoxDecoration(
                                            color: Color(0xffEEE9E0),
                                            borderRadius: BorderRadius.circular(20.w),
                                            border: Border.all(
                                              width: 1,
                                              color: Color(0xffEEE9E0),
                                            )),
                                        padding: EdgeInsets.only(top: 5.w,bottom: 5.w,left:15.w,right: 15.w),
                                        width: ScreenUtil().screenWidth,child: Text("問卷內容",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                        color: Color(0xff555555)))),
                                    Container(height: 5.h,),
                                    Container(
                                        padding: EdgeInsets.only(top: 0.w,bottom: 0.w,left:12.w,right: 12.w),
                                        width: ScreenUtil().screenWidth,child:
                                    Text("${SURVEY_list[index].TITLE}",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16.sp,
                                        color: Color(0xff555555)))),

                                    (SURVEY_list[index].survey_dl_list.length==0)?Container():
                                    Column(children: SURVEY_list[index].survey_dl_list.map((e) =>
                                    Row(children: [
                                      Container(width: 12.w,),
                                      Text("${e.SR.trim()}. ${e.NOTE}",style: TextStyle(
                                        color: Color(0xff555555),
                                        fontSize: 18.sp,
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.bold,
                                      ),)
                                    ],)).toList(),),
                                    Container(height: 5.h,),
                                    (View_SURVEY_list.length==0)?Container():Column(children: View_SURVEY_list.map((e){
                                      return (e.NO.trim()!=SURVEY_list[index].NO.trim())?Container():Container(width: ScreenUtil().screenWidth,child:
                                      Column(children: [

                                        Row(children: [

                                          Expanded(child:
                                          Text("${e.KIDS_NM}/${e.ANSWER.trim()}/${e.NOTE}/${e.ADD_DATE}",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                              fontFamily: "GenJyuuGothic",
                                              fontWeight: FontWeight.w400,
                                              fontSize: 16.sp,
                                              color: Color(0xff555555)))),


                                        ],),
                                        Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,)

                                      ],));
                                    }).toList()),
                                    Container(height: 5.h,),
                                    Container(
                                        width: ScreenUtil().screenWidth,child:Column(children: [

                                          Row(children: [

                                            Expanded(child: Text("統計結果:",style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 18.sp,
                                              fontFamily: "GenJyuuGothic",
                                              fontWeight: FontWeight.w400,
                                            ),)),

                                            Expanded(child: Text.rich(
                                              softWrap: true,
                                              maxLines:null,
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: '送出 ',
                                                    style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w400,color: Colors.blue),
                                                  ),
                                                  TextSpan(
                                                    text: '${SURVEY_list[index].View_SURVEY_COUNTS_SentCount}',
                                                    style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.bold,color: Colors.red),
                                                  ),
                                                  TextSpan(
                                                    text: ' 人',
                                                    style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w400,color: Colors.blue),
                                                  ),
                                                ],
                                              ),
                                            )),
                                            Expanded(child: Text.rich(
                                              softWrap: true,
                                              maxLines:null,
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: '回復 ',
                                                    style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w400,color: Colors.blue),
                                                  ),
                                                  TextSpan(
                                                    text: '${SURVEY_list[index].View_SURVEY_COUNTS_ReceivedCount}',
                                                    style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.bold,color: Colors.red),
                                                  ),
                                                  TextSpan(
                                                    text: ' 人',
                                                    style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w400,color: Colors.blue),
                                                  ),
                                                ],
                                              ),
                                            )),

                                          ],),
                                          Container(width: ScreenUtil().screenWidth,child:Wrap(
                                              children:SURVEY_list[index].survey_dl_list.map((e) {


                                            String AnswerCount = "0";
                                            for(int i=0;i<SURVEY_list[index].View_SURVEY_ANSWER_STATS_list.length;i++){
                                              if(SURVEY_list[index].View_SURVEY_ANSWER_STATS_list[i].ANSWER.trim()==e.SR.trim()){
                                                AnswerCount = SURVEY_list[index].View_SURVEY_ANSWER_STATS_list[i].AnswerCount;
                                              }
                                            }

                                            return Text.rich(
                                              softWrap: true,
                                              maxLines:null,
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: '(${e.SR.trim()}).',
                                                    style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w400,color: Colors.blue),
                                                  ),
                                                  TextSpan(
                                                    text: '${AnswerCount.isEmpty?0:AnswerCount}',
                                                    style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.bold,color: Colors.red),
                                                  ),
                                                  TextSpan(
                                                    text: '人  ',
                                                    style: TextStyle(fontSize: 18.sp,fontWeight: FontWeight.w400,color: Colors.blue),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                          ).toList())),

                                        ],)),
                                    Container(height: 5.h,),

                                  ],)));
                        } ),)),

                ],))
                    :
                Expanded(child:Container())


              ],),)
              :
          (page=="聯絡")?
              Column(children: [
                Container(height: 15.h,),
                Expanded(child: ChatPage_T_all())
              ],)
              :
          (page=="訊息")?

              Container(
              width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
              padding: EdgeInsets.only(left:12.w,right: 12.w),child:Column(children: [

                /*
                Container(
                width: ScreenUtil().screenWidth,
                height: 55.h,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                      surfaceTintColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                      padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.w),
                              side: BorderSide(color: Color(0xff707070))
                          )
                      )
                  ),
                  onPressed: () async{
                  },
                  child: Row(children: [

                    Container(width: 15.w,),
                    SvgPicture.asset("assets/images/Icon-fa-solid-school-flag.svg",width: 12.sp),
                    Container(width: 15.w,),
                    Text("${user.DEPM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp)),
                    Expanded(child: Container()),
                  ],),
                )),
                Container(height: 15.h,),

                 */
                Container(width:ScreenUtil().screenWidth,height: 40.h,child:
                ListView(
                  padding: EdgeInsets.zero,
                  scrollDirection:Axis.horizontal,children: [
                  GestureDetector(
                      onTap: (){

                        page_notify_menu4="託藥訊息";
                        setState(() {

                        });

                        read_for_DRUG_MT_db_sub();

                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 5.w),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                            color: page_notify_menu4=="託藥訊息"?Color(0xffF9AA88):Color(0xffffffff),
                            borderRadius: BorderRadius.circular(14.w),
                            border: Border.all(
                              width: 1,
                              color: Color(0xff555555),
                            )),
                        child: Center(child:Text("託藥訊息",textScaler: TextScaler.linear(1),style: TextStyle(
                            fontFamily: "GenJyuuGothic",
                            fontWeight: FontWeight.normal,
                            fontSize: 12.sp,
                            color: Color(0xff555555)))),
                      )),
                  GestureDetector(
                      onTap: (){

                        page_notify_menu4="請假紀錄";
                        setState(() {

                        });
                        read_for_EXCUSED_db_sub();

                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 5.w),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                            color: page_notify_menu4=="請假紀錄"?Color(0xffF9AA88):Color(0xffffffff),
                            borderRadius: BorderRadius.circular(14.w),
                            border: Border.all(
                              width: 1,
                              color: Color(0xff555555),
                            )),
                        child: Center(child:Text("請假紀錄",style: TextStyle(
                            fontFamily: "GenJyuuGothic",
                            fontWeight: FontWeight.normal,
                            fontSize: 12.sp,
                            color: Color(0xff555555)))),
                      )),
                  GestureDetector(
                      onTap: (){

                        page_notify_menu4="聯絡簿";
                        setState(() {

                        });
                        read_for_DAILY_PRS_db_sub();

                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 5.w),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                            color: page_notify_menu4=="聯絡簿"?Color(0xffF9AA88):Color(0xffffffff),
                            borderRadius: BorderRadius.circular(14.w),
                            border: Border.all(
                              width: 1,
                              color: Color(0xff555555),
                            )),
                        child: Center(child:Text(" 聯 絡 簿 ",style: TextStyle(
                            fontFamily: "GenJyuuGothic",
                            fontWeight: FontWeight.normal,
                            fontSize: 12.sp,
                            color: Color(0xff555555)))),
                      )),
                ],)),
                Container(height: 10.h,),
                (page_notify_menu4=="託藥訊息")?
                Expanded(child: Column(children: [

                  /*
                  Row(children: [
                    Expanded(child:
                    GestureDetector(
                        onTap: ()async{


                          showMonthPicker(
                            context: context,
                            //locale: const Locale('zh'),
                            initialDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 90)),
                          ).then((date) {
                            if (date != null) {
                              setState(() {
                                sel_datetime_4 = date;
                              });
                              read_for_month_DRUG_MT_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_4)}");
                            }
                          });


                        },
                        child: Column(children: [
                          Container(
                              width: ScreenUtil().screenWidth,
                              height: 50.w,
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20.w),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xff555555),
                                  )),
                              child:Row(children: [
                                Container(width: 5.w,),
                                Icon(Icons.calendar_today,color: Color(0xff555555),size: 28.sp,),
                                Container(width: 5.w,),
                                Text("${DateFormat('yyyy-MM').format(sel_datetime_4)} 託藥訊息",style: TextStyle(
                                    fontFamily: "GenJyuuGothic",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: Color(0xff292929))),
                                Expanded(child: Container()),
                                Icon(Icons.keyboard_arrow_down,color: Color(0xff555555),size: 24.sp,),
                                Container(width: 5.w,),

                              ],)
                          ),

                        ],))),
                    Container(width: 10.w,),
                    GestureDetector(
                        onTap: (){

                          read_for_month_DRUG_MT_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_4)}");

                        },
                        child: Column(children: [
                          Container(
                              width: 50.w,
                              height: 50.w,
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                  color: Color(0xffe7e8f5),
                                  borderRadius: BorderRadius.circular(20.w),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xff555555),
                                  )),
                              child:Center(child: Icon(Icons.search,size: 30.sp,),)
                          ),
                        ],)),
                  ],),

                  Row(children: [

                    Container(width: 5.w,),
                    Text("學生:",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Color(0xff292929))),
                    Container(width: 5.w,),
                    Row(children: [
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5.w),
                          ),
                          //width: 80.w,
                          height: 36.h,
                          child:
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<CUSTOMER>(
                              isExpanded: true,
                              items: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs
                                  .map((CUSTOMER item) => DropdownMenuItem<CUSTOMER>(
                                value: item,
                                child: Text(
                                  item.CS_NM,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff555555),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                                  .toList(),
                              value: CUSTOMER_selectedValue,
                              onChanged: (value) {

                                setState(() {
                                  CUSTOMER_selectedValue = value!;
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
                    ],),
                    Expanded(child: Container()),


                  ],),
                  Container(height: 5.h,),

                   */
                  Row(children: [
                    Text("${DateFormat('yyyy-MM-dd').format(sel_datetime_4)}(${WEEK_DAY[sel_datetime_4.weekday-1]}) 今日託藥訊息",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Color(0xff292929))),

                    Expanded(child:Container()),

                    GestureDetector(onTap: (){
                      read_for_DRUG_MT_db_sub();
                    },child:Text("(重新整理)",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Color(0xff292929)))),

                  ],),
                  Container(height: 8.h,),
                  Expanded(child:Container(width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                    child: ListView.builder(
                        padding: EdgeInsets.all(5.w),
                        itemCount: DRUG_MT_list.length,
                        itemBuilder:(c,index){

                          //找出學生名字
                          String student_name = "";
                          for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
                            if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO==DRUG_MT_list[index].CS_NO){
                              student_name = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NM;
                              break;
                            }
                          }

                          return Container(
                              margin: EdgeInsets.only(bottom: 5.h),
                              width: ScreenUtil().screenWidth,
                              //height: 55.w,
                              padding: EdgeInsets.all(3.w),
                              decoration: BoxDecoration(
                                  color: DRUG_MT_list[index].isExpanded==false?Colors.white:Color(0xfffff6dc),
                                  borderRadius: BorderRadius.circular(20.w),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xff555555),
                                  )),
                              child:Theme(
                                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                      key: UniqueKey(),
                                      initiallyExpanded: DRUG_MT_list[index].isExpanded,
                                      onExpansionChanged: (v){
                                        DRUG_MT_list[index].isExpanded = v;
                                        setState(() {

                                        });
                                      },
                                      backgroundColor: Color(0xfffff6dc),
                                      iconColor: Color(0xff555555),
                                      collapsedIconColor: Color(0xff555555),
                                      tilePadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 0,top: 0),
                                      childrenPadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 10.h),
                                      title: Container(width: ScreenUtil().screenWidth,
                                        child: Column(children: [

                                          Row(children: [
                                            Container(
                                              width:40.w,
                                              height: 40.w,
                                              padding: EdgeInsets.all(4.w),
                                              decoration: BoxDecoration(
                                                  color: Color(0xffEEE9E0),
                                                  borderRadius: BorderRadius.circular(10.w),
                                                  border: Border.all(
                                                    width: 1,
                                                    color: Color(0xffEEE9E0),
                                                  )),child: SvgPicture.asset("assets/images/组 29164.svg"),),
                                            Container(width: 6.w,),
                                            Expanded(child:Column(children: [

                                               Row(children: [
                                                 Text("${student_name}",style: TextStyle(
                                                   fontFamily: "GenJyuuGothic",
                                                   fontWeight: FontWeight.bold,
                                                   fontSize: 16.sp,
                                                   color: Color(0xffE8885E))),
                                                 Expanded(child: Container()),
                                                 GestureDetector(
                                                  onTap: (){

                                                    dev.log("用藥委託");
                                                    dRUG_MT=DRUG_MT_list[index];
                                                    Navigator.push(context, PageTransition(
                                                        type: PageTransitionType.rightToLeft, child: DRUG_MT_T_page()));

                                                  },child:
                                                 Icon(Icons.edit,color: Colors.blue,size: 30.sp,))
                                               ]),

                                              Row(children: [
                                                Text("${DRUG_MT_list[index].REASON}",style: TextStyle(
                                                    fontFamily: "GenJyuuGothic",
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 18.sp,
                                                    color: Color(0xff555555)))
                                              ]),



                                            ],)),
                                          ],),

                                        ],),),
                                      children:[


                                        Row(children: [
                                          Expanded(child:
                                          Text("用藥日期:${DRUG_MT_list[index].DATE}",style: TextStyle(
                                              fontFamily: "GenJyuuGothic",
                                              fontWeight: FontWeight.w400,
                                              fontSize: 18.sp,
                                              color: Colors.blue))),
                                        ]),
                                        Container(height: 6.h,),
                                        Container(width: ScreenUtil().screenWidth,height: 1,color: Color(0xff555555),),
                                        Container(height: 6.h,),
                                        Row(children: [
                                          Expanded(child:
                                          Text("藥單封面:",style: TextStyle(
                                              fontFamily: "GenJyuuGothic",
                                              fontWeight: FontWeight.w400,
                                              fontSize: 18.sp,
                                              color: Colors.blue))),
                                        ]),
                                        Container(height: 3.h,),
                                        Container(width: ScreenUtil().screenWidth,height: 250.h,child:
                                        Image.network("${DRUG_MT_list[index].DRUG_LINK}",
                                          errorBuilder: (BuildContext context, Object exception,
                                              StackTrace? stackTrace) {
                                            return  Icon(Icons.error,size: 30.sp,);
                                          },
                                        )),
                                        Container(height: 6.h,),
                                        Container(width: ScreenUtil().screenWidth,height: 1,color: Color(0xff555555),),
                                        Container(height: 6.h,),
                                        Row(children: [
                                          Expanded(child:
                                          Text("我委託幼兒園依照上述明細用藥，並對此用藥明細負起全部責任(同意簽名)",style: TextStyle(
                                              fontFamily: "GenJyuuGothic",
                                              fontWeight: FontWeight.w400,
                                              fontSize: 18.sp,
                                              color: Colors.blue))),
                                        ]),
                                        Container(height: 3.h,),
                                        Container(width: ScreenUtil().screenWidth,height: 250.h,child:
                                        Image.network(
                                          "${DRUG_MT_list[index].SIGN_LINK}",
                                          errorBuilder: (BuildContext context, Object exception,
                                              StackTrace? stackTrace) {
                                            return  Icon(Icons.error,size: 30.sp,);
                                          },
                                        )),
                                        Container(height: 6.h,),
                                        Container(width: ScreenUtil().screenWidth,height: 1,color: Color(0xff555555),),
                                        Container(height: 6.h,),
                                        (DRUG_MT_list[index].DRUG_DL_list.length==0)?Container():
                                        Column(children: DRUG_MT_list[index].DRUG_DL_list.map((e) {

                                          String _STORE = dRUG_STORE.DRUG_STORE_ITEM_list.firstWhere((element) => element.ITEM_NO==e.STORE).ITEM_NM;
                                          String _MODE = dRUG_MODE.DRUG_MODE_ITEM_list.firstWhere((element) => element.ITEM_NO==e.MODE).ITEM_NM;
                                          String _UNIT = DRUG_UNIT_ITEM_list.firstWhere((element) => element.ITEM_NO==e.UNIT).ITEM_NM;
                                          String _DOSAGE = e.DOSAGE.replaceAll("\n", "").replaceAll("\r", "").replaceAll(" ", "");

                                          var timeOfDay1;
                                          var timeOfDay2;
                                          var timeOfDay3;
                                          var timeOfDay4;
                                          var timeOfDay5;
                                          var timeOfDay6;
                                          try{
                                            List<String> t1 = e.TIME1.split(":");
                                            timeOfDay1 = TimeOfDay(hour: int.parse(t1[0]),minute: int.parse(t1[1]));
                                          }
                                          catch(e){

                                          }

                                          try{
                                            List<String> t2 = e.TIME2.split(":");
                                            timeOfDay2 = TimeOfDay(hour: int.parse(t2[0]),minute: int.parse(t2[1]));
                                          }
                                          catch(e){

                                          }

                                          try{
                                            List<String> t3 = e.TIME3.split(":");
                                            timeOfDay3 = TimeOfDay(hour: int.parse(t3[0]),minute: int.parse(t3[1]));
                                          }
                                          catch(e){

                                          }

                                          try{
                                            List<String> t4 = e.CMPT_Time1.split(":");
                                            timeOfDay4 = TimeOfDay(hour: int.parse(t4[0]),minute: int.parse(t4[1]));
                                          }
                                          catch(e){

                                          }

                                          try{
                                            List<String> t5 = e.CMPT_Time2.split(":");
                                            timeOfDay5 = TimeOfDay(hour: int.parse(t5[0]),minute: int.parse(t5[1]));
                                          }
                                          catch(e){

                                          }

                                          try{
                                            List<String> t6 = e.CMPT_Time3.split(":");
                                            timeOfDay6 = TimeOfDay(hour: int.parse(t6[0]),minute: int.parse(t6[1]));
                                          }
                                          catch(e){

                                          }


                                          return Column(children: [
                                            Row(children: [
                                              Expanded(child:
                                              Text("用藥委託明細(${DRUG_MT_list[index].DRUG_DL_list.indexOf(e)+1})",style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 18.sp,
                                                  color: Colors.blue))),
                                            ]),
                                            Row(children: [

                                              Expanded(child:
                                              RichText(
                                                text: TextSpan(
                                                  text: '藥品名稱:',
                                                  style: TextStyle(
                                                      fontFamily: 'GenJyuuGothic',
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 17.sp,
                                                      color: Color(0xff555555)
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: ' ${e.DETAIL}',
                                                      style: TextStyle(
                                                          fontFamily: "GenJyuuGothic",
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                          color: Colors.red
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),


                                            ],),
                                            Row(children: [

                                              Expanded(child:
                                              RichText(
                                                text: TextSpan(
                                                  text: '用藥保存:',
                                                  style: TextStyle(
                                                      fontFamily: 'GenJyuuGothic',
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 17.sp,
                                                      color: Color(0xff555555)
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: ' ${_STORE}',
                                                      style: TextStyle(
                                                          fontFamily: "GenJyuuGothic",
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                          color: Colors.red
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),


                                            ],),
                                            Row(children: [

                                              Expanded(child:
                                              RichText(
                                                text: TextSpan(
                                                  text: '用藥方式:',
                                                  style: TextStyle(
                                                      fontFamily: 'GenJyuuGothic',
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 17.sp,
                                                      color: Color(0xff555555)
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: ' ${_MODE}',
                                                      style: TextStyle(
                                                          fontFamily: "GenJyuuGothic",
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                          color: Colors.red
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),


                                            ],),
                                            Row(children: [

                                              Expanded(child:
                                              RichText(
                                                text: TextSpan(
                                                  text: '用量:',
                                                  style: TextStyle(
                                                      fontFamily: 'GenJyuuGothic',
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 17.sp,
                                                      color: Color(0xff555555)
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: ' ${_DOSAGE}${_UNIT}/次',
                                                      style: TextStyle(
                                                          fontFamily: "GenJyuuGothic",
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                          color: Colors.red
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),


                                            ],),

                                            Row(children: [

                                              Expanded(child:
                                              RichText(
                                                text: TextSpan(
                                                  text: '藥品照片(說明):',
                                                  style: TextStyle(
                                                      fontFamily: 'GenJyuuGothic',
                                                      fontWeight: FontWeight.w400,
                                                      fontSize: 17.sp,
                                                      color: Color(0xff555555)
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: ' ${e.NOTE}',
                                                      style: TextStyle(
                                                          fontFamily: "GenJyuuGothic",
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                          color: Colors.red
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )),


                                            ],),
                                            Container(width: ScreenUtil().screenWidth,height: 180.h,child: Image.network("${e.DRUG_LINK}",errorBuilder: (BuildContext context, Object exception,
                                                StackTrace? stackTrace) {
                                              return  Icon(Icons.error,size: 30.sp,);
                                            },),),


                                            Container(
                                              child: Column(children: [
                                                Row(children: [

                                                  Expanded(child:
                                                  RichText(
                                                    text: TextSpan(
                                                      text: '第1次給藥:',
                                                      style: TextStyle(
                                                          fontFamily: 'GenJyuuGothic',
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                          color: Color(0xff555555)
                                                      ),
                                                      children: [
                                                        (timeOfDay1==null)?TextSpan(text:""):
                                                        TextSpan(
                                                          text: ' ${"${timeOfDay1.period==DayPeriod.am?"上午":"下午"}${timeOfDay1.hourOfPeriod}:${timeOfDay1.minute.toString().padLeft(2,"0")}"}',
                                                          style: TextStyle(
                                                              fontFamily: "GenJyuuGothic",
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 17.sp,
                                                              color: Colors.red
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),


                                                ],),
                                                Row(children: [

                                                  Expanded(child:
                                                  RichText(
                                                    text: TextSpan(
                                                      text: '完成時間:',
                                                      style: TextStyle(
                                                          fontFamily: 'GenJyuuGothic',
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                          color: Color(0xff555555)
                                                      ),
                                                      children: [
                                                        (timeOfDay4==null)?TextSpan(text:""):
                                                        TextSpan(
                                                          text: ' ${"${timeOfDay4.period==DayPeriod.am?"上午":"下午"}${timeOfDay4.hourOfPeriod}:${timeOfDay4.minute.toString().padLeft(2,"0")}"}',
                                                          style: TextStyle(
                                                              fontFamily: "GenJyuuGothic",
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 17.sp,
                                                              color: Colors.red
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),


                                                ],),
                                                Row(children: [

                                                  Expanded(child:
                                                  RichText(
                                                    text: TextSpan(
                                                      text: '給藥者(老師)簽名',
                                                      style: TextStyle(
                                                          fontFamily: 'GenJyuuGothic',
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                          color: Color(0xff555555)
                                                      ),
                                                      children: [
                                                      ],
                                                    ),
                                                  )),


                                                ],),
                                                Container(width: ScreenUtil().screenWidth,height:150.h,child:
                                                Image.network(
                                                  "${e.CMPT_SIGN1}",
                                                  errorBuilder: (BuildContext context, Object exception,
                                                      StackTrace? stackTrace) {
                                                    return  Icon(Icons.error,size: 30.sp,);
                                                  },
                                                ),),
                                              ]),
                                              padding:EdgeInsets.all(4.w),
                                              decoration: BoxDecoration(
                                                  color: Color(0xffEEE9E0),
                                                  borderRadius: BorderRadius.circular(10.w),
                                                  border: Border.all(
                                                    width: 1,
                                                    color: Color(0xffEEE9E0),
                                                  )),
                                            ),
                                            Container(height: 5.h,),
                                            Container(
                                              child: Column(children: [
                                                Row(children: [

                                                  Expanded(child:
                                                  RichText(
                                                    text: TextSpan(
                                                      text: '第2次給藥:',
                                                      style: TextStyle(
                                                          fontFamily: 'GenJyuuGothic',
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                          color: Color(0xff555555)
                                                      ),
                                                      children: [
                                                        (timeOfDay2==null)?TextSpan(text:""):
                                                        TextSpan(
                                                          text: ' ${"${timeOfDay2.period==DayPeriod.am?"上午":"下午"}${timeOfDay2.hourOfPeriod}:${timeOfDay2.minute.toString().padLeft(2,"0")}"}',
                                                          style: TextStyle(
                                                              fontFamily: "GenJyuuGothic",
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 17.sp,
                                                              color: Colors.red
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),

                                                ],),
                                                Row(children: [

                                                  Expanded(child:
                                                  RichText(
                                                    text: TextSpan(
                                                      text: '完成時間:',
                                                      style: TextStyle(
                                                          fontFamily: 'GenJyuuGothic',
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                          color: Color(0xff555555)
                                                      ),
                                                      children: [
                                                        (timeOfDay5==null)?TextSpan(text:""):
                                                        TextSpan(
                                                          text: ' ${"${timeOfDay5.period==DayPeriod.am?"上午":"下午"}${timeOfDay5.hourOfPeriod}:${timeOfDay5.minute.toString().padLeft(2,"0")}"}',
                                                          style: TextStyle(
                                                              fontFamily: "GenJyuuGothic",
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 17.sp,
                                                              color: Colors.red
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),

                                                ],),
                                                Row(children: [

                                                  Expanded(child:
                                                  RichText(
                                                    text: TextSpan(
                                                      text: '給藥者(老師)簽名',
                                                      style: TextStyle(
                                                          fontFamily: 'GenJyuuGothic',
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                          color: Color(0xff555555)
                                                      ),
                                                      children: [
                                                      ],
                                                    ),
                                                  )),


                                                ],),
                                                Container(width: ScreenUtil().screenWidth,height:150.h,child:
                                                Image.network(
                                                  "${e.CMPT_SIGN2}",
                                                  errorBuilder: (BuildContext context, Object exception,
                                                      StackTrace? stackTrace) {
                                                    return  Icon(Icons.error,size: 30.sp,);
                                                  },
                                                ),),
                                              ]),
                                              padding:EdgeInsets.all(4.w),
                                              decoration: BoxDecoration(
                                                  color: Color(0xffEEE9E0),
                                                  borderRadius: BorderRadius.circular(10.w),
                                                  border: Border.all(
                                                    width: 1,
                                                    color: Color(0xffEEE9E0),
                                                  )),
                                            ),
                                            Container(height: 5.h,),
                                            Container(
                                              child: Column(children: [
                                                Row(children: [

                                                  Expanded(child:
                                                  RichText(
                                                    text: TextSpan(
                                                      text: '第3次給藥:',
                                                      style: TextStyle(
                                                          fontFamily: 'GenJyuuGothic',
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                          color: Color(0xff555555)
                                                      ),
                                                      children: [
                                                        (timeOfDay3==null)?TextSpan(text:""):
                                                        TextSpan(
                                                          text: ' ${"${timeOfDay3.period==DayPeriod.am?"上午":"下午"}${timeOfDay3.hourOfPeriod}:${timeOfDay3.minute.toString().padLeft(2,"0")}"}',
                                                          style: TextStyle(
                                                              fontFamily: "GenJyuuGothic",
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 17.sp,
                                                              color: Colors.red
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),

                                                ],),
                                                Row(children: [

                                                  Expanded(child:
                                                  RichText(
                                                    text: TextSpan(
                                                      text: '完成時間:',
                                                      style: TextStyle(
                                                          fontFamily: 'GenJyuuGothic',
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                          color: Color(0xff555555)
                                                      ),
                                                      children: [
                                                        (timeOfDay6==null)?TextSpan(text:""):
                                                        TextSpan(
                                                          text: ' ${"${timeOfDay6.period==DayPeriod.am?"上午":"下午"}${timeOfDay6.hourOfPeriod}:${timeOfDay6.minute.toString().padLeft(2,"0")}"}',
                                                          style: TextStyle(
                                                              fontFamily: "GenJyuuGothic",
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 17.sp,
                                                              color: Colors.red
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )),

                                                ],),
                                                Row(children: [

                                                  Expanded(child:
                                                  RichText(
                                                    text: TextSpan(
                                                      text: '給藥者(老師)簽名',
                                                      style: TextStyle(
                                                          fontFamily: 'GenJyuuGothic',
                                                          fontWeight: FontWeight.w400,
                                                          fontSize: 17.sp,
                                                          color: Color(0xff555555)
                                                      ),
                                                      children: [
                                                      ],
                                                    ),
                                                  )),


                                                ],),
                                                Container(width: ScreenUtil().screenWidth,height:150.h,child:
                                                Image.network("${e.CMPT_SIGN3}",
                                                  errorBuilder: (BuildContext context, Object exception,
                                                      StackTrace? stackTrace) {
                                                    return  Icon(Icons.error,size: 30.sp,);
                                                  },
                                                )),
                                              ]),
                                              padding:EdgeInsets.all(4.w),
                                              decoration: BoxDecoration(
                                                  color: Color(0xffEEE9E0),
                                                  borderRadius: BorderRadius.circular(10.w),
                                                  border: Border.all(
                                                    width: 1,
                                                    color: Color(0xffEEE9E0),
                                                  )),
                                            ),
                                            Container(height: 20.h,),

                                          ]);
                                        }).toList())


                                      ])));
                        } ),))



                ],))
                    :
                (page_notify_menu4=="請假紀錄")?
                Expanded(child: Column(children: [

                  /*
                  Row(children: [
                    Expanded(child:
                    GestureDetector(
                        onTap: (){


                          showMonthPicker(
                            context: context,
                            //locale: const Locale('zh'),
                            initialDate: DateTime.now(),
                            firstDate:DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 90)),
                          ).then((date) {
                            if (date != null) {
                              setState(() {
                                sel_datetime_7 = date;
                              });
                              read_for_month_EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_7)}");
                            }
                          });

                        },
                        child: Column(children: [
                          Container(
                              width: ScreenUtil().screenWidth,
                              height: 50.w,
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20.w),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xff555555),
                                  )),
                              child:Row(children: [
                                Container(width: 5.w,),
                                Icon(Icons.calendar_today,color: Color(0xff555555),size: 28.sp,),
                                Container(width: 5.w,),
                                Text("${DateFormat('yyyy-MM').format(sel_datetime_7)} 請假紀錄",style: TextStyle(
                                    fontFamily: "GenJyuuGothic",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: Color(0xff292929))),
                                Expanded(child: Container()),
                                Icon(Icons.keyboard_arrow_down,color: Color(0xff555555),size: 24.sp,),
                                Container(width: 5.w,),

                              ],)
                          ),

                        ],))),
                    Container(width: 10.w,),
                    GestureDetector(
                        onTap: (){

                          read_for_month_EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(sel_datetime_7)}");

                        },
                        child: Column(children: [
                          Container(
                              width: 50.w,
                              height: 50.w,
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                  color: Color(0xffe7e8f5),
                                  borderRadius: BorderRadius.circular(20.w),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xff555555),
                                  )),
                              child:Center(child: Icon(Icons.search,size: 30.sp,),)
                          ),
                        ],)),
                  ],),
                  Container(height: 10.h,),
                  Row(children: [

                    Container(width: 5.w,),
                    Text("學生:",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Color(0xff292929))),
                    Container(width: 5.w,),
                    Row(children: [
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5.w),
                          ),
                          //width: 80.w,
                          height: 36.h,
                          child:
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<CUSTOMER>(
                              isExpanded: true,
                              items: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs
                                  .map((CUSTOMER item) => DropdownMenuItem<CUSTOMER>(
                                value: item,
                                child: Text(
                                  item.CS_NM,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff555555),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                                  .toList(),
                              value: CUSTOMER_selectedValue,
                              onChanged: (value) {

                                setState(() {
                                  CUSTOMER_selectedValue = value!;
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
                    ],),
                    Expanded(child: Container()),


                  ],),
                  Container(height: 10.h,),

                   */
                  Row(children: [
                    Text("${DateFormat('yyyy-MM-dd').format(sel_datetime_7)}(${WEEK_DAY[sel_datetime_7.weekday-1]}) 今日請假訊息",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Color(0xff292929))),

                    Expanded(child:Container()),

                    GestureDetector(onTap: ()async{
                      await read_for_EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                    },child:Text("(重新整理)",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Color(0xff292929)))),

                  ],),
                  Container(height: 8.h,),
                  Expanded(child:Container(width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                    child: ListView.builder(
                        padding: EdgeInsets.all(5.w),
                        itemCount: EXCUSED_list.length,
                        itemBuilder:(c,index){

                          //學校(DEPM)
                          DEPM _DEPM = dEPMs.firstWhere((element) => element.DEPM_NO==EXCUSED_list[index].DEPM_NO);
                          CLASS _CLASS = cLASSs.firstWhere((element) => element.CLASS_NO==EXCUSED_list[index].CLASS_NO);

                          EXCUSED_HOURS_ITEM _EXCUSED_HOURS_ITEM = EXCUSED_HOURS_ITEM();
                          if(EXCUSED_HOURS_ITEM_list.length>0) {
                            _EXCUSED_HOURS_ITEM = EXCUSED_HOURS_ITEM_list
                                .firstWhere((element) =>
                            element.ITEM_NO == EXCUSED_list[index].HOURS_NO);
                          }
                          EXCUSED_REASON_ITEM _EXCUSED_REASON_ITEM = EXCUSED_REASON_ITEM_list.firstWhere((element) => element.ITEM_NO==EXCUSED_list[index].REASON_NO);
                          //CFM_ITEM CFM_ITEM_selectedValue = CFM_ITEM_list.firstWhere((element) => element.CFM_NO==EXCUSED_list[index].CFM_NO);

                          //老師名字
                          String teacher_name = "";
                          for(int i=0;i<eMPLOYEEs.length;i++){
                            if(eMPLOYEEs[i].EMP_NO==EXCUSED_list[index].CFM_USER){
                              teacher_name = eMPLOYEEs[i].EMP_NM;
                              break;
                            }
                          }

                          String student_name = "";
                          for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
                            if(EXCUSED_list[index].CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO){
                              student_name = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NM;
                              break;
                            }
                          }

                          return Container(
                              width: ScreenUtil().screenWidth,
                              //height: 55.w,
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                  color: EXCUSED_list[index].isExpanded==false?Colors.white:Color(0xfffff6dc),
                                  borderRadius: BorderRadius.circular(20.w),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xff555555),
                                  )),
                              child:Theme(
                                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                      key: UniqueKey(),
                                      initiallyExpanded: EXCUSED_list[index].isExpanded,
                                      onExpansionChanged: (v){
                                        EXCUSED_list[index].isExpanded = v;
                                        setState(() {

                                        });
                                      },
                                      backgroundColor: Color(0xfffff6dc),
                                      iconColor: Color(0xff555555),
                                      collapsedIconColor: Color(0xff555555),
                                      tilePadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 0,top: 0),
                                      childrenPadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 10.h),
                                      title: Container(width: ScreenUtil().screenWidth,
                                        child: Column(children: [

                                          Row(children: [
                                            //Text('${_DEPM==null?"":_DEPM.DEPM_NM}-${_CLASS==null?"":_CLASS.CLASS_NM}-${CUSTOMER_selectedValue.CS_NM}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 15.sp)),
                                            Text('${_CLASS==null?"":_CLASS.CLASS_NM}-${student_name}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 15.sp)),
                                          ],),
                                          /*
                                          Row(children: [
                                            Container(
                                              //width: ScreenUtil().screenWidth,
                                                child: Text("${EXCUSED_list[index].DateStr}",
                                                    maxLines: null,
                                                    style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 16.sp,
                                                        color: Color(0xff555555)))),
                                          ],),

                                           */
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

                                        ],),),
                                      children:[

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
                                          Text("${EXCUSED_list[index].NOTE}",
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
                                        Container(width: ScreenUtil().screenWidth,height: 200.h,child: Image.network(EXCUSED_list[index].SING_LINK),),
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
                                              child:(EXCUSED_list[index].CFM_ITEM_selectedValue.CFM_NO.isEmpty)?Container():
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
                                                  value: EXCUSED_list[index].CFM_ITEM_selectedValue,
                                                  onChanged: (value) {

                                                    setState(() {
                                                      EXCUSED_list[index].CFM_ITEM_selectedValue = value!;
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
                                          Text((EXCUSED_list[index].CFM_DT.isEmpty)?"":"${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(EXCUSED_list[index].CFM_DT))}",
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
                                                    NO:"${EXCUSED_list[index].NO}",
                                                    CS_NO:"${EXCUSED_list[index].CS_NO}",
                                                    CFM_NO:EXCUSED_list[index].CFM_ITEM_selectedValue.CFM_NO,
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

                                      ])));

                        } ),))


                ],))
                    :
                (page_notify_menu4=="聯絡簿")?
                Expanded(child: Column(children: [

                  /*
                  Row(children: [
                    Expanded(child:
                    GestureDetector(
                        onTap: (){


                          showMonthPicker(
                            context: context,
                            //locale: const Locale('zh'),
                            initialDate: DateTime.now(),
                            firstDate:DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 90)),
                          ).then((date) {
                            if (date != null) {
                              setState(() {
                                sel_datetime_7 = date;
                              });
                              read_for_month_EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM').format(sel_datetime_7)}");
                            }
                          });

                        },
                        child: Column(children: [
                          Container(
                              width: ScreenUtil().screenWidth,
                              height: 50.w,
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20.w),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xff555555),
                                  )),
                              child:Row(children: [
                                Container(width: 5.w,),
                                Icon(Icons.calendar_today,color: Color(0xff555555),size: 28.sp,),
                                Container(width: 5.w,),
                                Text("${DateFormat('yyyy-MM').format(sel_datetime_7)} 請假紀錄",style: TextStyle(
                                    fontFamily: "GenJyuuGothic",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.sp,
                                    color: Color(0xff292929))),
                                Expanded(child: Container()),
                                Icon(Icons.keyboard_arrow_down,color: Color(0xff555555),size: 24.sp,),
                                Container(width: 5.w,),

                              ],)
                          ),

                        ],))),
                    Container(width: 10.w,),
                    GestureDetector(
                        onTap: (){

                          read_for_month_EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(sel_datetime_7)}");

                        },
                        child: Column(children: [
                          Container(
                              width: 50.w,
                              height: 50.w,
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                  color: Color(0xffe7e8f5),
                                  borderRadius: BorderRadius.circular(20.w),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xff555555),
                                  )),
                              child:Center(child: Icon(Icons.search,size: 30.sp,),)
                          ),
                        ],)),
                  ],),
                  Container(height: 10.h,),
                  Row(children: [

                    Container(width: 5.w,),
                    Text("學生:",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Color(0xff292929))),
                    Container(width: 5.w,),
                    Row(children: [
                      Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5.w),
                          ),
                          //width: 80.w,
                          height: 36.h,
                          child:
                          DropdownButtonHideUnderline(
                            child: DropdownButton2<CUSTOMER>(
                              isExpanded: true,
                              items: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs
                                  .map((CUSTOMER item) => DropdownMenuItem<CUSTOMER>(
                                value: item,
                                child: Text(
                                  item.CS_NM,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff555555),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                                  .toList(),
                              value: CUSTOMER_selectedValue,
                              onChanged: (value) {

                                setState(() {
                                  CUSTOMER_selectedValue = value!;
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
                    ],),
                    Expanded(child: Container()),


                  ],),
                  Container(height: 10.h,),

                   */
                  Row(children: [
                    Text("${DateFormat('yyyy-MM-dd').format(sel_datetime_7)}(${WEEK_DAY[sel_datetime_7.weekday-1]}) 今日聯絡簿",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Color(0xff292929))),

                    Expanded(child:Container()),

                    GestureDetector(onTap: (){
                      read_for_DAILY_PRS_db_sub();
                    },child:Text("(重新整理)",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Color(0xff292929)))),

                  ],),
                  Container(height: 8.h,),
                  Expanded(child:Container(width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                    child: ListView.builder(
                        padding: EdgeInsets.all(5.w),
                        itemCount: DAILY_PRSs.length,
                        itemBuilder:(c,index){

                          //學校(DEPM)
                          DEPM _DEPM = DEPM();
                          CLASS _CLASS = CLASS();
                          try {
                            _DEPM = dEPMs.firstWhere((element) =>
                            element.DEPM_NO == DAILY_PRSs[index].DEPM_NO);
                            _CLASS = cLASSs.firstWhere((element) =>
                            element.CLASS_NO == DAILY_PRSs[index].CLASS_NO);
                          }
                          catch(e){

                          }

                          String student_name = "";
                          for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
                            if(DAILY_PRSs[index].CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO){
                              student_name = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NM;
                              break;
                            }
                          }

                          return Container(
                              width: ScreenUtil().screenWidth,
                              //height: 55.w,
                              margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                  color: DAILY_PRSs[index].isExpanded==false?Colors.white:Color(0xfffff6dc),
                                  borderRadius: BorderRadius.circular(20.w),
                                  border: Border.all(
                                    width: 1,
                                    color: Color(0xff555555),
                                  )),
                              child:Theme(
                                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                      key: UniqueKey(),
                                      initiallyExpanded: DAILY_PRSs[index].isExpanded,
                                      onExpansionChanged: (v){
                                        DAILY_PRSs[index].isExpanded = v;
                                        setState(() {

                                        });
                                      },
                                      backgroundColor: Color(0xfffff6dc),
                                      iconColor: Color(0xff555555),
                                      collapsedIconColor: Color(0xff555555),
                                      tilePadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 0,top: 0),
                                      childrenPadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 10.h),
                                      title: Container(width: ScreenUtil().screenWidth,
                                        child: Column(children: [

                                          Row(children: [
                                            //Text('${_DEPM==null?"":_DEPM.DEPM_NM}-${_CLASS==null?"":_CLASS.CLASS_NM}-${CUSTOMER_selectedValue.CS_NM}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 15.sp)),
                                            Text('${_CLASS==null?"":_CLASS.CLASS_NM}-${student_name}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 17.sp)),
                                          ],),
                                          /*
                                          Row(children: [
                                            Container(
                                              //width: ScreenUtil().screenWidth,
                                                child: Text("${EXCUSED_list[index].DateStr}",
                                                    maxLines: null,
                                                    style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 16.sp,
                                                        color: Color(0xff555555)))),
                                          ],),

                                           */

                                        ],),),
                                      children:[

                                        Container(height: 5.h,),
                                        Row(children: [
                                          Text("備註:",
                                              maxLines: null,
                                              style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16.sp,
                                                  color: Color(0xff555555))),
                                        ],),
                                        Row(children: [
                                          Expanded(child:
                                          Text("${DAILY_PRSs[index].NOTE}",
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
                                        Container(width: ScreenUtil().screenWidth,height: 200.h,child: Image.network(DAILY_PRSs[index].SIGN_LINK),),
                                        Container(height: 5.h,),

                                      ])));

                        } ),))
                ],))
                    :
                Container()

          ],))

              :
          (page=="班級")?


              Stack(children: [
                Container(
                    color: Colors.white,
                    width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                    padding: EdgeInsets.only(left:12.w,right: 12.w),child:Column(children: [

                  /*
                Container(
                width: ScreenUtil().screenWidth,
                height: 55.h,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                      surfaceTintColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                      padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.w),
                              side: BorderSide(color: Color(0xff707070))
                          )
                      )
                  ),
                  onPressed: () async{
                  },
                  child: Row(children: [

                    Container(width: 15.w,),
                    SvgPicture.asset("assets/images/Icon-fa-solid-school-flag.svg",width: 12.sp,),
                    Container(width: 15.w,),
                    Text("${user.DEPM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp)),
                    Expanded(child: Container()),
                  ],),
                )),

                 */
                  //Container(height: 15.h,),
                  //Container(width: ScreenUtil().screenWidth,child:
                  //Text("班級選單", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp))),
                  Container(height: 15.h,),
                  Container(width: ScreenUtil().screenWidth,child:Row(children: [
                    Expanded(child:GestureDetector(
                        onTap: (){

                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: BarcodeScannerPageView()));

                        },
                        child: Container(
                          width: 70.w,
                          padding: EdgeInsets.all(4.sp),
                          decoration: BoxDecoration(
                              color: Color(0x01000000),
                              borderRadius: BorderRadius.circular(10.w),
                              border: Border.all(
                                width: 1,
                                color: Colors.black,
                              )),
                          child: Row(children: [

                            Expanded(child:Container()),
                            Icon(Icons.qr_code,size: 20.sp,),
                            Text('點名', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,color: Color(0xff555555) , fontSize: 16.sp)),
                            Expanded(child:Container()),

                          ],),))),
                    Container(width: 10.w,),
                    Expanded(flex:3,child:GestureDetector(
                        onTap: ()async{
                          List<DateTime?>? results = await showCalendarDatePicker2Dialog(
                            context: context,
                            config: CalendarDatePicker2WithActionButtonsConfig(
                                selectedDayHighlightColor:Color(0xff004ea2),
                            ),
                            dialogSize: const Size(325, 400),
                            value: [dateTime],
                            borderRadius: BorderRadius.circular(15),
                          )??[];

                          if(results.length>0){

                            dateTime = results[0]!;
                            //ROLLCALL_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

                            for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_ENTRUSTED=false;
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DRUG_MT=false;
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_EXCUSED=false;
                                EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DAILY_PRS=false;
                            }
                            setState(() {

                            });

                            /*
                            檢查每位學生是否有用藥委託
                             */
                            await read_for_DRUG_MT_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                            for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                              for(int k=0;k<DRUG_MT_list.length;k++){
                                if(DRUG_MT_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                  EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DRUG_MT=true;
                                }
                              }
                            }


                            /*
                            檢查每位學生是否有請假委託
                             */
                            await read_for_EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                            for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                              for(int k=0;k<EXCUSED_list.length;k++){
                                if(EXCUSED_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                  EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_EXCUSED=true;
                                }
                              }
                            }


                            /*
                            檢查每位學生是否有接送委託
                             */
                            await read_for_ENTRUSTED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                            for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                              for(int k=0;k<entrusted_pick_and_drop_list.length;k++){
                                if(entrusted_pick_and_drop_list[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                  EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_ENTRUSTED=true;
                                }
                              }
                            }



                            /*
                            檢查每位學生家長聯絡簿是否已回簽
                             */
                            await read_for_DAILY_PRS_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                            for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
                              for(int k=0;k<DAILY_PRSs.length;k++){
                                if(DAILY_PRSs[k].CS_NO.trim()==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].CS_NO){
                                  EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[j].is_DAILY_PRS=true;
                                }
                              }
                            }

                          }

                          setState(() {

                          });



                        },
                        child: Container(color:Color(0x01000000),child:Row(children: [

                          Expanded(child: Container()),
                          Icon(Icons.date_range,size: 24.sp,),
                          Container(width: 5.w,),
                          Text("${DateFormat("MM月dd日").format(dateTime)} (${WEEK_DAY[dateTime.weekday-1]})", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 17.sp)),
                          Icon(Icons.arrow_forward_ios,size: 24.sp,),
                          Expanded(child: Container()),

                        ],)))),
                    Container(width: 10.w,),
                    Expanded(child:Row(children: [
                      Container(width: 5.w,),
                      Container(
                          width:20.w,
                          height: 20.w,
                          child: Checkbox(
                              checkColor: Colors.white,
                              value: checkbox, onChanged: (v){
                            checkbox=v!;
                            for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
                              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].is_sel = v;
                            }
                            setState(() {

                            });
                          })),
                      Container(width: 5.w,),
                      Text("全選",
                        style: TextStyle(
                            fontFamily: "GenJyuuGothic",
                            fontWeight: FontWeight.bold,
                            fontSize: 17.sp,
                            color: Color(0xff292929)),),
                    ],))
                  ],)
                  ),
                  Container(height: 5.h,),
                  Container(width: ScreenUtil().screenWidth,height: 2,color: Colors.black,),
                  Container(height: 5.h,),
                  /*
                Container(
                    width: ScreenUtil().screenWidth,child:Row(children: [
                    Container(width: 3.h,),

                    Text("學生", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp)),
                    Expanded(flex:1,child: Center(child:Text('姓名', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 16.sp)))),
                    Expanded(child: Center(child:Text('到校', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 16.sp)))),
                    Expanded(child: Center(child:Text('離校', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 16.sp)))),
                    Expanded(child: Center(child:Text('狀態', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 16.sp)))),

                ],)),

                 */
                  Expanded(child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length,
                      itemBuilder: (c,index){


                        List<ROLLCALL> start_ROLLCALL = ROLLCALL_list.where((element) =>
                        (element.CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].CS_NO && element.STATUS=="1")
                        ).toList();
                        List<ROLLCALL> end_ROLLCALL = ROLLCALL_list.where((element) =>
                        (element.CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].CS_NO && element.STATUS=="2")
                        ).toList();

                        String start_time = start_ROLLCALL.isEmpty?"":"${start_ROLLCALL[0].DateStr1}";
                        String end_time = end_ROLLCALL.isEmpty?"":"${end_ROLLCALL[0].DateStr1}";


                        return GestureDetector(

                            onLongPress: (){

                              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_sel = !EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_sel;
                              setState(() {

                              });

                            },
                            onTap: (){

                              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index];
                              Navigator.push(context, PageTransition(
                                  type: PageTransitionType.rightToLeft, child: Student_T_page(dateTime:dateTime,key: Student_T_page_WidgetKey)));

                            },
                            child: Container(color: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_sel==true?Color(0xff91d9d5):Color(0x01000000),width: ScreenUtil().screenWidth,child:Column(children: [
                              Container(height: 10.h,),
                              Row(children: [
                                Container(width: 3.h,),
                                Container(width: 40.w,child:
                                CircleAvatar(
                                  radius: 20.w,
                                  backgroundImage: NetworkImage("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].PICTURE_LINK}"),
                                )),
                                Container(width: 5.h,),
                                Container(child:Row(children:[
                                  Container(width: 5.w,),
                                  Text('${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].CS_NM.replaceAll(" ", "")}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xff555555) , fontSize: 20.sp))
                                ])),

                                Expanded(child:Container()),

                                Expanded(flex:2,child:Center(child:(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_DRUG_MT==true)?SvgPicture.asset("assets/images/组 29164-2.svg",width:20.w):Container())),
                                //Text('${(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_DRUG_MT==true)?"(餵藥委託)":""}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.red , fontSize: 16.sp)))),

                                Expanded(flex:2,child:Center(child:(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_ENTRUSTED==true)?SvgPicture.asset("assets/images/Icon fa-solid-car-side.svg",width:20.w,colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)):Container())),
                                /*
                                    Expanded(flex:2,child:Center(child:
                                    Text('${(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_ENTRUSTED==true)?"(接送委託)":""}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.red , fontSize: 16.sp)))),

                                     */
                                Expanded(flex:2,child:Center(child:(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_EXCUSED==true)?SvgPicture.asset("assets/images/Icon material-access-time.svg",width:20.w,colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)):Container())),
                                /*
                                    Expanded(flex:1,child:Center(child:
                                    Text('${(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_EXCUSED==true)?"(請假)":""}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.red , fontSize: 16.sp)))),

                                     */

                                Expanded(flex:2,child:Center(child:(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_DAILY_PRS==true)?SvgPicture.asset("assets/images/menu_book_24dp_5F6368_FILL0_wght400_GRAD0_opsz24.svg",width:22.w,colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)):Container())),



                                /*
                                    Expanded(flex:1,child:Center(child:
                                    Text('${start_time}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.blue , fontSize: 16.sp)))),
                                    Expanded(flex:1,child:Center(child:
                                    Text('${end_time}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.blue , fontSize: 16.sp)))),

                                     */
                                //Expanded(child:Container()),

                              ],),
                              Container(height: 10.h,),
                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                            ],)));
                      }))

                ],)),
                /*
                Container(
                  width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                  child:Column(children: [
                    Expanded(child: Container()),
                    Row(children: [
                      Expanded(child: Container()),
                      GestureDetector(
                          //key: btnKey,
                          onTap: (){

                            /*
                  centerStarMenuController.openMenu!();
                  is_show=true;
                  setState(() {

                  });

                   */

                            menu = PopupMenu(
                              context: context,
                              config: MenuConfig(
                                  type: MenuType.grid,
                                  itemWidth:  (iPad==true)?50.w:80.w,
                                  itemHeight: (iPad==true)?60.h:90.h,
                                  //arrowHeight: (iPad==true)?70.h:90.h,
                                  maxColumn: (DAILY_MT_TYPE_ITEMs.length/4).toInt(),
                                  textStyle: TextStyle(color: Colors.white,fontSize: (iPad==true)?7.sp:14.sp),
                                  backgroundColor: Colors.black54
                              ),
                              items:DAILY_MT_TYPE_ITEMs_2.map((e){
                                return MenuItem(
                                    textStyle: TextStyle(color: Colors.white,fontSize: (iPad==true)?(e.ITEM_NO.contains("CLS"))?4.sp:7.sp:(e.ITEM_NO.contains("CLS"))?10.sp:14.sp),
                                    title: '${e.ITEM_NM}', image: e.svg_icon,userInfo: e);
                              }).toList(),
                              /*
                                   items: [
                                     MenuItem(title: 'Copy', image: Image.asset('assets/copy.png')),
                                     MenuItem(title: 'Power', image: Icon(Icons.power, color: Colors.white)),
                                     MenuItem(
                                         title: 'Setting', image: Icon(Icons.settings, color: Colors.white)),
                                     MenuItem(
                                         title: 'PopupMenu', image: Icon(Icons.menu, color: Colors.white))
                                   ],

                                    */
                              onClickMenu: (item){
                                print('Click menu -> ${item.menuTitle}');
                                if(item.menuUserInfo.ITEM_NO=="到/離校"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_ROLLCALL_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="ACT"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_ACT_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="MLK"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_MLK_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="POP"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_POP_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="CLN"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_CLN_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="CLS"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_CLS_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="EAT"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_EAT_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="DRY"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_DRY_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="TMP"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_TMP_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="SLP"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_SLP_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="RQD"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_RQD_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="CND"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_CND_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                else if(item.menuUserInfo.ITEM_NO=="NOT"){
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: ADD_DAILY_NOT_page(type:"寫入全班",dateTime:dateTime)));
                                }
                                /*
                        else if(item.menuUserInfo.ITEM_NO=="健康紀錄"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: GROWING_T_page()));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="成長曲線"){
                          showModalBottomSheet(
                              backgroundColor: Colors.white,
                              isScrollControlled:true,
                              context: context,
                              builder: (BuildContext context) {
                                showModalBottomSheet_GROWING_STANDARD_context = context;
                                return StatefulBuilder(
                                    builder: (BuildContext context, showModalBottomSheet_image_setState){
                                      this.showModalBottomSheet_GROWING_STANDARD_setState =
                                          showModalBottomSheet_image_setState;
                                      return Column(children: [

                                        Container(height: 45.h,),
                                        Row(children: [
                                          Expanded(child: Container()),
                                          GestureDetector(
                                              onTap:(){
                                                Navigator.pop(showModalBottomSheet_GROWING_STANDARD_context);
                                              },
                                              child: Icon(Icons.cancel_outlined,size: 30.sp,color: Colors.black,)),
                                          Container(width: 20.w,),
                                        ],),
                                        Container(height: 10.h,),
                                        Text("衛服部幼兒發展數據",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20.sp,
                                            color: Colors.lightBlue)),
                                        Container(height: 10.h,),
                                        Expanded(child: Container(child: Column(children: [

                                          Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(5.w),
                                              ),
                                              //width: 80.w,
                                              height: 36.h,
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  items: GROWING_STANDARD_TYPE
                                                      .map((String item) => DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item.split("-").last,
                                                      style: TextStyle(
                                                        fontSize: 18.sp,
                                                        fontWeight: FontWeight.bold,
                                                        color: const Color(0xff555555),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                                      .toList(),
                                                  value: sel_GROWING_STANDARD_TYPE,
                                                  onChanged: (value) {

                                                    Male_salesDatas_h.clear();
                                                    Female_salesDatas_h.clear();
                                                    Male_salesDatas_l.clear();
                                                    Female_salesDatas_l.clear();
                                                    sel_GROWING_STANDARD_TYPE = value!;

                                                    for(int i=0;i<GROWING_STANDARDs.length;i++){
                                                      if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="M"){
                                                        Male_salesDatas_h.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_H)));
                                                        Male_salesDatas_l.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_L)));
                                                      }
                                                      if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="F"){
                                                        Female_salesDatas_h.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_H)));
                                                        Female_salesDatas_l.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_L)));
                                                      }
                                                    }

                                                    Male_salesDatas_h.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Male_salesDatas_l.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Female_salesDatas_h.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Female_salesDatas_l.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    showModalBottomSheet_GROWING_STANDARD_setState(() {

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
                                          (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.SEX=="M")?
                                          Expanded(child: SfCartesianChart(

                                              primaryXAxis: CategoryAxis(
                                                  title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              primaryYAxis: CategoryAxis(
                                                  title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              // Chart title
                                              title: ChartTitle(text: '男生',textStyle: TextStyle(fontSize: 20.sp)),
                                              // Enable legend
                                              legend: Legend(isVisible: true),
                                              // Enable tooltip
                                              tooltipBehavior: _tooltipBehavior,

                                              series: <LineSeries<SalesData, String>>[
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_h.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據上限",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_l.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  name: "數據下限",
                                                )
                                              ]
                                          )):
                                          //Container(height: 20.h,),
                                          Expanded(child: SfCartesianChart(


                                              primaryXAxis: CategoryAxis(
                                                  title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              primaryYAxis: CategoryAxis(
                                                  title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              // Chart title
                                              title: ChartTitle(text: '女生',textStyle: TextStyle(fontSize: 20.sp)),
                                              // Enable legend
                                              legend: Legend(isVisible: true),
                                              // Enable tooltip
                                              tooltipBehavior: _tooltipBehavior,

                                              series: <LineSeries<SalesData, String>>[
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_h.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據上限",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_l.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據下限",
                                                )
                                              ]
                                          )),
                                          Container(height: 20.h,),

                                        ],))),


                                      ],);
                                    });

                              });

                          resd_GROWING_STANDARD_db_sub();
                        }
                        else if(item.menuUserInfo.ITEM_NO=="到/離校"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_ROLLCALL_page()));
                        }

                         */
                              },
                              onDismiss: (){

                              },
                            );
                            menu.show(widgetKey: btnKey);

                          },
                          child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black54.withOpacity(0.5),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(0, 1), // changes position of shadow
                                  ),
                                ],
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                              child: Center(child:Icon(color: Colors.white,Icons.add,size: 30.sp,),))),
                      Container(width: 10.w,)
                    ],),
                    Container(height: 10.h,)
                  ],)
                )

                 */
              ],)
              /*
              FloatingDraggableWidget(
              floatingWidgetHeight: 55.sp,
              floatingWidgetWidth: 55.sp, deleteWidgetHeight:0,
                  isCollidingDeleteWidgetHeight:0,
              //screenHeight: ScreenUtil().screenHeight-150.h,
              floatingWidget: GestureDetector(
                  key: btnKey,
                  onTap: (){

                    /*
                  centerStarMenuController.openMenu!();
                  is_show=true;
                  setState(() {

                  });

                   */

                    menu = PopupMenu(
                      context: context,
                      config: MenuConfig(
                          type: MenuType.grid,
                          itemWidth: 80.w,
                          itemHeight:90.h,
                          maxColumn: 3,
                          textStyle: TextStyle(color: Colors.white,fontSize: 15.sp),
                          backgroundColor: Colors.black54
                      ),
                      items:DAILY_MT_TYPE_ITEMs_2.map((e){
                        return MenuItem(title: '${e.ITEM_NM}', image: e.svg_icon,userInfo: e);
                      }).toList(),
                      /*
                                   items: [
                                     MenuItem(title: 'Copy', image: Image.asset('assets/copy.png')),
                                     MenuItem(title: 'Power', image: Icon(Icons.power, color: Colors.white)),
                                     MenuItem(
                                         title: 'Setting', image: Icon(Icons.settings, color: Colors.white)),
                                     MenuItem(
                                         title: 'PopupMenu', image: Icon(Icons.menu, color: Colors.white))
                                   ],

                                    */
                      onClickMenu: (item){
                        print('Click menu -> ${item.menuTitle}');
                        if(item.menuUserInfo.ITEM_NO=="到/離校"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_ROLLCALL_page(type:"寫入全班")));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="ACT"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_ACT_page(type:"寫入全班")));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="MLK"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_MLK_page(type:"寫入全班")));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="POP"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_POP_page(type:"寫入全班")));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="CLN"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_CLN_page(type:"寫入全班")));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="CLS"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_CLS_page(type:"寫入全班")));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="EAT"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_EAT_page(type:"寫入全班")));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="DRY"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_DRY_page(type:"寫入全班")));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="TMP"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_TMP_page(type:"寫入全班")));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="SLP"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_SLP_page(type:"寫入全班")));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="RQD"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_RQD_page(type:"寫入全班")));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="CND"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_CND_page(type:"寫入全班")));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="NOT"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_NOT_page(type:"寫入全班")));
                        }
                        /*
                        else if(item.menuUserInfo.ITEM_NO=="健康紀錄"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: GROWING_T_page()));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="成長曲線"){
                          showModalBottomSheet(
                              backgroundColor: Colors.white,
                              isScrollControlled:true,
                              context: context,
                              builder: (BuildContext context) {
                                showModalBottomSheet_GROWING_STANDARD_context = context;
                                return StatefulBuilder(
                                    builder: (BuildContext context, showModalBottomSheet_image_setState){
                                      this.showModalBottomSheet_GROWING_STANDARD_setState =
                                          showModalBottomSheet_image_setState;
                                      return Column(children: [

                                        Container(height: 45.h,),
                                        Row(children: [
                                          Expanded(child: Container()),
                                          GestureDetector(
                                              onTap:(){
                                                Navigator.pop(showModalBottomSheet_GROWING_STANDARD_context);
                                              },
                                              child: Icon(Icons.cancel_outlined,size: 30.sp,color: Colors.black,)),
                                          Container(width: 20.w,),
                                        ],),
                                        Container(height: 10.h,),
                                        Text("衛服部幼兒發展數據",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20.sp,
                                            color: Colors.lightBlue)),
                                        Container(height: 10.h,),
                                        Expanded(child: Container(child: Column(children: [

                                          Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(5.w),
                                              ),
                                              //width: 80.w,
                                              height: 36.h,
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  items: GROWING_STANDARD_TYPE
                                                      .map((String item) => DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item.split("-").last,
                                                      style: TextStyle(
                                                        fontSize: 18.sp,
                                                        fontWeight: FontWeight.bold,
                                                        color: const Color(0xff555555),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                                      .toList(),
                                                  value: sel_GROWING_STANDARD_TYPE,
                                                  onChanged: (value) {

                                                    Male_salesDatas_h.clear();
                                                    Female_salesDatas_h.clear();
                                                    Male_salesDatas_l.clear();
                                                    Female_salesDatas_l.clear();
                                                    sel_GROWING_STANDARD_TYPE = value!;

                                                    for(int i=0;i<GROWING_STANDARDs.length;i++){
                                                      if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="M"){
                                                        Male_salesDatas_h.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_H)));
                                                        Male_salesDatas_l.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_L)));
                                                      }
                                                      if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="F"){
                                                        Female_salesDatas_h.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_H)));
                                                        Female_salesDatas_l.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_L)));
                                                      }
                                                    }

                                                    Male_salesDatas_h.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Male_salesDatas_l.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Female_salesDatas_h.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Female_salesDatas_l.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    showModalBottomSheet_GROWING_STANDARD_setState(() {

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
                                          (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.SEX=="M")?
                                          Expanded(child: SfCartesianChart(

                                              primaryXAxis: CategoryAxis(
                                                  title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              primaryYAxis: CategoryAxis(
                                                  title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              // Chart title
                                              title: ChartTitle(text: '男生',textStyle: TextStyle(fontSize: 20.sp)),
                                              // Enable legend
                                              legend: Legend(isVisible: true),
                                              // Enable tooltip
                                              tooltipBehavior: _tooltipBehavior,

                                              series: <LineSeries<SalesData, String>>[
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_h.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據上限",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_l.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  name: "數據下限",
                                                )
                                              ]
                                          )):
                                          //Container(height: 20.h,),
                                          Expanded(child: SfCartesianChart(


                                              primaryXAxis: CategoryAxis(
                                                  title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              primaryYAxis: CategoryAxis(
                                                  title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              // Chart title
                                              title: ChartTitle(text: '女生',textStyle: TextStyle(fontSize: 20.sp)),
                                              // Enable legend
                                              legend: Legend(isVisible: true),
                                              // Enable tooltip
                                              tooltipBehavior: _tooltipBehavior,

                                              series: <LineSeries<SalesData, String>>[
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_h.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據上限",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_l.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據下限",
                                                )
                                              ]
                                          )),
                                          Container(height: 20.h,),

                                        ],))),


                                      ],);
                                    });

                              });

                          resd_GROWING_STANDARD_db_sub();
                        }
                        else if(item.menuUserInfo.ITEM_NO=="到/離校"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_ROLLCALL_page()));
                        }

                         */
                      },
                      onDismiss: (){

                      },
                    );
                    menu.show(widgetKey: btnKey);



                  },
                  child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: Center(child:Icon(color: Colors.white,Icons.add,size: 30.sp,),))),
                  mainScreenWidget:Container(
                  color: Colors.white,
              width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
              padding: EdgeInsets.only(left:12.w,right: 12.w),child:Column(children: [

                /*
                Container(
                width: ScreenUtil().screenWidth,
                height: 55.h,
                child: ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                      surfaceTintColor: MaterialStateProperty.all(Color(0xffB8D7E9)),
                      padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.w),
                              side: BorderSide(color: Color(0xff707070))
                          )
                      )
                  ),
                  onPressed: () async{
                  },
                  child: Row(children: [

                    Container(width: 15.w,),
                    SvgPicture.asset("assets/images/Icon-fa-solid-school-flag.svg",width: 12.sp,),
                    Container(width: 15.w,),
                    Text("${user.DEPM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp)),
                    Expanded(child: Container()),
                  ],),
                )),

                 */
                //Container(height: 15.h,),
                //Container(width: ScreenUtil().screenWidth,child:
                //Text("班級選單", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp))),

                Container(width: ScreenUtil().screenWidth,child:Row(children: [
                  GestureDetector(
                    onTap: ()async{
                      List<DateTime?>? results = await showCalendarDatePicker2Dialog(
                        context: context,
                        config: CalendarDatePicker2WithActionButtonsConfig(),
                        dialogSize: const Size(325, 400),
                        value: [dateTime],
                        borderRadius: BorderRadius.circular(15),
                      )??[];

                      if(results.length>0){
                        dateTime = results[0]!;
                        ROLLCALL_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                      }


                    },
                      child: Row(children: [

                        Icon(Icons.date_range,size: 24.sp,),
                        Container(width: 5.w,),
                        Text("${DateFormat("MM月dd日").format(dateTime)} (${WEEK_DAY[dateTime.weekday-1]})", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 17.sp)),

                      ],)),
                  Expanded(child: Container()),
                  GestureDetector(
                      onTap: (){

                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: BarcodeScannerPageView()));

                      },
                      child: Container(
                        width: 100.w,
                        padding: EdgeInsets.all(4.sp),
                        decoration: BoxDecoration(
                            color: Color(0x01000000),
                            borderRadius: BorderRadius.circular(10.w),
                            border: Border.all(
                              width: 1,
                              color: Colors.black,
                            )),
                        child: Row(children: [

                          Expanded(child:Container()),
                          Icon(Icons.qr_code,size: 20.sp,),
                          Text('掃描點名', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,color: Color(0xff555555) , fontSize: 16.sp)),
                          Expanded(child:Container()),

                        ],),)),
                  ],)
                ),
                Container(height: 5.h,),
                /*
                Container(
                    width: ScreenUtil().screenWidth,child:Row(children: [
                    Container(width: 3.h,),

                    Text("學生", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp)),
                    Expanded(flex:1,child: Center(child:Text('姓名', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 16.sp)))),
                    Expanded(child: Center(child:Text('到校', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 16.sp)))),
                    Expanded(child: Center(child:Text('離校', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 16.sp)))),
                    Expanded(child: Center(child:Text('狀態', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 16.sp)))),

                ],)),

                 */
                Expanded(child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length,
                          itemBuilder: (c,index){


                            List<ROLLCALL> start_ROLLCALL = ROLLCALL_list.where((element) =>
                               (element.CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].CS_NO && element.STATUS=="1")
                            ).toList();
                            List<ROLLCALL> end_ROLLCALL = ROLLCALL_list.where((element) =>
                            (element.CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].CS_NO && element.STATUS=="2")
                            ).toList();

                            String start_time = start_ROLLCALL.isEmpty?"":"${start_ROLLCALL[0].DateStr1}";
                            String end_time = end_ROLLCALL.isEmpty?"":"${end_ROLLCALL[0].DateStr1}";


                            return GestureDetector(
                                onTap: (){

                                  EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index];
                                  Navigator.push(context, PageTransition(
                                      type: PageTransitionType.rightToLeft, child: Student_T_page()));

                                },
                                child: Container(color: Color(0x01000000),width: ScreenUtil().screenWidth,child:Column(children: [
                                  Container(height: 10.h,),
                                  Row(children: [
                                    Container(width: 3.h,),
                                    Container(width: 40.w,child:
                                    CircleAvatar(
                                        backgroundImage: NetworkImage("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].PICTURE_LINK}"),
                                        )),
                                    Container(width: 5.h,),
                                    Container(child:Row(children:[
                                       Container(width: 5.w,),
                                       Text('${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].CS_NM.replaceAll(" ", "")}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xff555555) , fontSize: 20.sp))
                                    ])),

                                    Expanded(child:Container()),

                                    Expanded(flex:2,child:Center(child:(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_DRUG_MT==true)?SvgPicture.asset("assets/images/组 29164-2.svg",):Container())),
                                    //Text('${(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_DRUG_MT==true)?"(餵藥委託)":""}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.red , fontSize: 16.sp)))),

                                    Expanded(flex:2,child:Center(child:(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_ENTRUSTED==true)?SvgPicture.asset("assets/images/Icon fa-solid-car-side.svg",colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)):Container())),
                                    /*
                                    Expanded(flex:2,child:Center(child:
                                    Text('${(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_ENTRUSTED==true)?"(接送委託)":""}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.red , fontSize: 16.sp)))),

                                     */
                                    Expanded(flex:2,child:Center(child:(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_EXCUSED==true)?SvgPicture.asset("assets/images/Icon material-access-time.svg",colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)):Container())),
                                    /*
                                    Expanded(flex:1,child:Center(child:
                                    Text('${(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[index].is_EXCUSED==true)?"(請假)":""}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.red , fontSize: 16.sp)))),

                                     */


                                    /*
                                    Expanded(flex:1,child:Center(child:
                                    Text('${start_time}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.blue , fontSize: 16.sp)))),
                                    Expanded(flex:1,child:Center(child:
                                    Text('${end_time}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.blue , fontSize: 16.sp)))),

                                     */
                                    //Expanded(child:Container()),

                                  ],),
                                  Container(height: 10.h,),
                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                                ],)));
                      }))

                ],)))

               */
              :
              Container(
              width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
              padding: EdgeInsets.only(left:33.w,right: 33.w),child:Column(children: [

              ],))
          )
           */
          Container(width: ScreenUtil().screenWidth,height: 65.h,color: Color(0xffF9AA88),child: Row(children: [

              Expanded(child: GestureDetector(
                  onTap:(){
                    _selectedIndex=0;
                    page="班級";
                    setState(() {

                    });
                  },
                  child: Column(children: [
                    Expanded(child: Container(),),
                    Container(
                        width: 40.w,
                        height: 24.h,
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                            color: page=="班級"?Color(0xff49c2bc):Color(0xffF9AA88),
                            borderRadius: BorderRadius.circular(5.w),
                            border: Border.all(
                              width: 1,
                              color: page=="班級"?Colors.black:Colors.transparent,
                            )),
                        child:Center(child: SvgPicture.asset("assets/images/Icon core-baby.svg",width: 14.sp,color: Colors.white,))
                    ),
                    Text('學生', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.white , fontSize: 16.sp)),
                    Expanded(child: Container(),),
                  ],))),
              Expanded(child: GestureDetector(
                  onTap:(){
                    page="公告";
                    _selectedIndex=1;
                    setState(() {

                    });

                  },
                  child: Column(children: [
                Expanded(child: Container(),),
                  Container(
                      width: 40.w,
                      height: 24.h,
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                          color: page=="公告"?Color(0xff49c2bc):Color(0xffF9AA88),
                          borderRadius: BorderRadius.circular(5.w),
                          border: Border.all(
                            width: 1,
                            color: page=="公告"?Colors.black:Colors.transparent,
                          )),
                      child:Center(child: SvgPicture.asset("assets/images/Icon fa-regular-pen-to-square.svg",width: 14.sp,color: Colors.white))),
                Text('公告', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.white , fontSize: 16.sp)),
                Expanded(child: Container(),),
              ],))),
              /*
              Expanded(child: GestureDetector(
                  onTap:(){
                    page="通知";
                    page_notify_menu="公佈欄";
                    setState(() {

                    });
                  },
                  child: Column(children: [
                 Expanded(child: Container(),),
                  Container(
                      width: 32.w,
                      height: 32.w,
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                          color: page=="通知"?Color(0xff49c2bc):Color(0xffF9AA88),
                          borderRadius: BorderRadius.circular(10.w),
                          border: Border.all(
                            width: 1,
                            color: page=="通知"?Colors.black:Colors.transparent,
                          )),
                      child:Center(child:SvgPicture.asset("assets/images/Icon material-notifications-none.svg"))),
                 Text('通知', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.white , fontSize: 16.sp)),
                 Expanded(child: Container(),),
               ],))),

               */
              Expanded(child: GestureDetector(
                  onTap:(){
                    _selectedIndex=2;
                    page="聯絡";
                    setState(() {

                    });

                  },
                  child: badges.Badge(
                      showBadge:'${ChatPage_T_all_unread_count}'=="0"?false:true,
                      position: badges.BadgePosition.topEnd(top: -3.h, end: 20.w),
                      badgeContent: Text('${ChatPage_T_all_unread_count}',textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 14.sp),),
                      badgeStyle: badges.BadgeStyle(
                        shape: badges.BadgeShape.circle,
                        badgeColor: Colors.red,
                        padding: EdgeInsets.all(5.w),
                        borderRadius: BorderRadius.circular(4),
                        elevation: 0,
                      ),
                      child:
                  Column(children: [
                Expanded(child: Container(),),
                  Container(
                      width: 40.w,
                      height: 24.h,
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                          color: page=="聯絡"?Color(0xff49c2bc):Color(0xffF9AA88),
                          borderRadius: BorderRadius.circular(5.w),
                          border: Border.all(
                            width: 1,
                            color: page=="聯絡"?Colors.black:Colors.transparent,
                          )),
                      child:Center(child:SvgPicture.asset("assets/images/Icon simple-googlemessages.svg",color: Colors.white,width: 14.sp))),
                Text('聯絡', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.white , fontSize: 16.sp)),
                Expanded(child: Container(),),
            ],)))),
              Expanded(child: GestureDetector(
                onTap:(){

                  page="設定";
                  _selectedIndex=3;
                  setState(() {

                  });


                },
                child: Column(children: [
                  Expanded(child: Container(),),
                  Container(
                      width: 40.w,
                      height: 24.h,
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                          color: page=="設定"?Color(0xff49c2bc):Color(0xffF9AA88),
                          borderRadius: BorderRadius.circular(5.w),
                          border: Border.all(
                            width: 1,
                            color: page=="設定"?Colors.black:Colors.transparent,
                          )),
                      child:Center(child:SvgPicture.asset("assets/images/组 29128.svg",width: 14.sp,))),
                  Text('設定', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.white , fontSize: 16.sp)),
                  Expanded(child: Container(),),
                ],))),

          ],),)

        ],),
      ),
          floatingActionButton: page!="班級"?Container():DraggableFab(
            securityBottom: 70.h,
            initPosition: Offset(ScreenUtil().screenWidth, ScreenUtil().screenHeight-70.h),
            child: GestureDetector(
                key: btnKey,
                onTap: ()async{

                  dev.log("DAILY_MT_TYPE_ITEMs_2.length:${DAILY_MT_TYPE_ITEMs_2.length}");
                  if(DAILY_MT_TYPE_ITEMs_2.isEmpty){
                    Fluttertoast.showToast(
                        msg: "處理中...",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0.sp
                    );
                    await read_DAILY_MT_TYPE_ITEM_db_sub();
                    return;
                  }


                  final RenderBox renderBox = btnKey.currentContext!.findRenderObject() as RenderBox;
                  final Offset offset = renderBox.localToGlobal(Offset.zero);
                  final Size size = renderBox.size;
                  final Rect buttonRect = offset & size;

                  List<DAILY_MT_TYPE_ITEM> specialItems = DAILY_MT_TYPE_ITEMs
                      .where((e) => (e.ITEM_NO == 'POV'||e.ITEM_NM == '到/離校'))
                      .toList(); // 例如 items.take(2)
                  List<DAILY_MT_TYPE_ITEM> gridItems = DAILY_MT_TYPE_ITEMs
                      .where((e) => !specialItems.contains(e))
                      .toList();

                  CustomGridMenu.show(
                      context: context,
                      gridItems: gridItems,
                      buttonRect: buttonRect,
                      onSelected: (item) {


                        //在沒有全選、複選、單選學生情況下 不能發布動態，即使發布了，也沒有顯示在學生內容內。
                        List<CUSTOMER> _cUSTOMERs = [];
                        for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
                          if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].is_sel==true){
                            _cUSTOMERs.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i]);
                          }
                        }
                        if(_cUSTOMERs.length==0){
                          Fluttertoast.showToast(
                              msg: "請先選擇學生",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                          return;
                        }

                        if(item.ITEM_NO=="到/離校"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_ROLLCALL_page(type:"寫入全班",dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="ACT"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_ACT_page(type:"寫入全班",dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="MLK"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_MLK_page(type:"寫入全班",dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="POP"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_POP_page(type:"寫入全班",dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="CLN"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_CLN_page(type:"寫入全班",dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="CLS"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_CLS_page(type:"寫入全班",dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="EAT"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_EAT_page(type:"寫入全班",dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="DRY"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_DRY_page(type:"寫入全班",dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="TMP"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_TMP_page(type:"寫入全班",dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="SLP"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_SLP_page(type:"寫入全班",dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="RQD"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_RQD_page(type:"寫入全班",dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="CND"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_CND_page(type:"寫入全班",dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="NOT"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_NOT_page(type:"寫入全班",dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="POV"){

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Text('提醒',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 18.sp),),
                                content: Text('確定(全班)聯絡簿送出？',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 18.sp),),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // 關閉對話框
                                    },
                                    child: Text('取消',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 15.sp),),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async{
                                      Navigator.of(context).pop(); // 關閉對話框
                                      add_all_DAILY_MT_db_sub2();
                                    },
                                    child: Text('確定',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 15.sp),),
                                  ),
                                ],
                              );
                            },
                          );


                        }


                      },
                      columns: 4,
                      itemWidth: 72,
                      itemHeight: 72,
                      specialItems:specialItems
                  );

                  /*
                  menu = PopupMenu(
                    context: context,
                    config: MenuConfig(
                        type: MenuType.grid,
                        itemWidth:  (iPad==true)?50.w:80.w,
                        itemHeight: (iPad==true)?60.h:90.h,
                        //arrowHeight: (iPad==true)?70.h:90.h,
                        maxColumn: (DAILY_MT_TYPE_ITEMs_2.length/4).toInt(),
                        //textStyle: TextStyle(color: Colors.white,fontSize: (iPad==true)?7.sp:14.sp),
                        backgroundColor: Colors.black54
                    ),
                    items:DAILY_MT_TYPE_ITEMs_2.map((e){
                      return MenuItem(
                          textStyle: TextStyle(color: Colors.white,fontSize: (iPad==true)?(e.ITEM_NO.contains("CLS"))?4.sp:7.sp:(e.ITEM_NO.contains("CLS"))?10.sp:14.sp),
                          title: '${e.ITEM_NM}', image: e.svg_icon,userInfo: e);
                    }).toList(),
                    /*
                                   items: [
                                     MenuItem(title: 'Copy', image: Image.asset('assets/copy.png')),
                                     MenuItem(title: 'Power', image: Icon(Icons.power, color: Colors.white)),
                                     MenuItem(
                                         title: 'Setting', image: Icon(Icons.settings, color: Colors.white)),
                                     MenuItem(
                                         title: 'PopupMenu', image: Icon(Icons.menu, color: Colors.white))
                                   ],

                                    */
                    onClickMenu: (item){
                      dev.log('Click menu -> ${item.menuTitle}');

                      //在沒有全選、複選、單選學生情況下 不能發布動態，即使發布了，也沒有顯示在學生內容內。
                      List<CUSTOMER> _cUSTOMERs = [];
                      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
                        if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].is_sel==true){
                          _cUSTOMERs.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i]);
                        }
                      }
                      if(_cUSTOMERs.length==0){
                        Fluttertoast.showToast(
                            msg: "請先選擇學生",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                        return;
                      }

                      if(item.menuUserInfo.ITEM_NO=="到/離校"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_ROLLCALL_page(type:"寫入全班",dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="ACT"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_ACT_page(type:"寫入全班",dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="MLK"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_MLK_page(type:"寫入全班",dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="POP"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_POP_page(type:"寫入全班",dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="CLN"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_CLN_page(type:"寫入全班",dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="CLS"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_CLS_page(type:"寫入全班",dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="EAT"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_EAT_page(type:"寫入全班",dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="DRY"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_DRY_page(type:"寫入全班",dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="TMP"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_TMP_page(type:"寫入全班",dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="SLP"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_SLP_page(type:"寫入全班",dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="RQD"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_RQD_page(type:"寫入全班",dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="CND"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_CND_page(type:"寫入全班",dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="NOT"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_NOT_page(type:"寫入全班",dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="POV"){

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Text('提醒',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 18.sp),),
                              content: Text('確定(全班)聯絡簿送出？',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 18.sp),),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // 關閉對話框
                                  },
                                  child: Text('取消',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 15.sp),),
                                ),
                                ElevatedButton(
                                  onPressed: () async{
                                    Navigator.of(context).pop(); // 關閉對話框
                                    add_all_DAILY_MT_db_sub();
                                  },
                                  child: Text('確定',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 15.sp),),
                                ),
                              ],
                            );
                          },
                        );


                      }

                      /*
                        else if(item.menuUserInfo.ITEM_NO=="健康紀錄"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: GROWING_T_page()));
                        }
                        else if(item.menuUserInfo.ITEM_NO=="成長曲線"){
                          showModalBottomSheet(
                              backgroundColor: Colors.white,
                              isScrollControlled:true,
                              context: context,
                              builder: (BuildContext context) {
                                showModalBottomSheet_GROWING_STANDARD_context = context;
                                return StatefulBuilder(
                                    builder: (BuildContext context, showModalBottomSheet_image_setState){
                                      this.showModalBottomSheet_GROWING_STANDARD_setState =
                                          showModalBottomSheet_image_setState;
                                      return Column(children: [

                                        Container(height: 45.h,),
                                        Row(children: [
                                          Expanded(child: Container()),
                                          GestureDetector(
                                              onTap:(){
                                                Navigator.pop(showModalBottomSheet_GROWING_STANDARD_context);
                                              },
                                              child: Icon(Icons.cancel_outlined,size: 30.sp,color: Colors.black,)),
                                          Container(width: 20.w,),
                                        ],),
                                        Container(height: 10.h,),
                                        Text("衛服部幼兒發展數據",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20.sp,
                                            color: Colors.lightBlue)),
                                        Container(height: 10.h,),
                                        Expanded(child: Container(child: Column(children: [

                                          Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(5.w),
                                              ),
                                              //width: 80.w,
                                              height: 36.h,
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  items: GROWING_STANDARD_TYPE
                                                      .map((String item) => DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item.split("-").last,
                                                      style: TextStyle(
                                                        fontSize: 18.sp,
                                                        fontWeight: FontWeight.bold,
                                                        color: const Color(0xff555555),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                                      .toList(),
                                                  value: sel_GROWING_STANDARD_TYPE,
                                                  onChanged: (value) {

                                                    Male_salesDatas_h.clear();
                                                    Female_salesDatas_h.clear();
                                                    Male_salesDatas_l.clear();
                                                    Female_salesDatas_l.clear();
                                                    sel_GROWING_STANDARD_TYPE = value!;

                                                    for(int i=0;i<GROWING_STANDARDs.length;i++){
                                                      if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="M"){
                                                        Male_salesDatas_h.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_H)));
                                                        Male_salesDatas_l.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_L)));
                                                      }
                                                      if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="F"){
                                                        Female_salesDatas_h.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_H)));
                                                        Female_salesDatas_l.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_L)));
                                                      }
                                                    }

                                                    Male_salesDatas_h.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Male_salesDatas_l.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Female_salesDatas_h.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Female_salesDatas_l.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    showModalBottomSheet_GROWING_STANDARD_setState(() {

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
                                          (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.SEX=="M")?
                                          Expanded(child: SfCartesianChart(

                                              primaryXAxis: CategoryAxis(
                                                  title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              primaryYAxis: CategoryAxis(
                                                  title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              // Chart title
                                              title: ChartTitle(text: '男生',textStyle: TextStyle(fontSize: 20.sp)),
                                              // Enable legend
                                              legend: Legend(isVisible: true),
                                              // Enable tooltip
                                              tooltipBehavior: _tooltipBehavior,

                                              series: <LineSeries<SalesData, String>>[
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_h.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據上限",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_l.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  name: "數據下限",
                                                )
                                              ]
                                          )):
                                          //Container(height: 20.h,),
                                          Expanded(child: SfCartesianChart(


                                              primaryXAxis: CategoryAxis(
                                                  title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              primaryYAxis: CategoryAxis(
                                                  title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              // Chart title
                                              title: ChartTitle(text: '女生',textStyle: TextStyle(fontSize: 20.sp)),
                                              // Enable legend
                                              legend: Legend(isVisible: true),
                                              // Enable tooltip
                                              tooltipBehavior: _tooltipBehavior,

                                              series: <LineSeries<SalesData, String>>[
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_h.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據上限",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_l.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據下限",
                                                )
                                              ]
                                          )),
                                          Container(height: 20.h,),

                                        ],))),


                                      ],);
                                    });

                              });

                          resd_GROWING_STANDARD_db_sub();
                        }
                        else if(item.menuUserInfo.ITEM_NO=="到/離校"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_ROLLCALL_page()));
                        }

                         */
                    },
                    onDismiss: (){

                    },
                  );
                  menu.show(widgetKey: btnKey);

                   */



                },
                child: Container(
                    width: 50.w,
                    height: 50.w,
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: Center(child:Icon(color: Colors.white,Icons.add,size: 30.sp,),))),



          ),
    )));
  }
}
