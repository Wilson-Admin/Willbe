import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:ui' as ui;
import 'dart:io';
//import 'package:alarm/alarm.dart' as alarm;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:code3/DAILY_PRS_page.dart';
import 'package:code3/EXCUSED_page.dart';
import 'package:code3/chat.dart';
import 'package:code3/custom_orientation_player/controls.dart';
import 'package:code3/custom_orientation_player/data_manager.dart';
import 'package:code3/entrusted_pick_and_drop.dart';
import 'package:code3/fcm_notifity.dart';
import 'package:code3/main.dart';
import 'package:code3/marquee.dart';
import 'package:code3/medication_details.dart';
import 'package:code3/medication_entrustment.dart';
import 'package:code3/scanner_error_widget.dart';
import 'package:code3/see_DAILY_NOT_page.dart';
import 'package:code3/see_DAILY_RQD_page.dart';
import 'package:code3/signature.dart';
import 'package:code3/signature3.dart';
import 'package:code3/video_fullscreen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:mime/mime.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:webdav_client/webdav_client.dart' as webdav_client;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:widget_zoom/widget_zoom.dart';
import 'dart:developer' as dev;
import 'DRUG_MT_U_page.dart';
import 'FlexiblePageView_u.dart';
import 'GROWING_u_page.dart';
import 'Jiebao_Phone_page.dart';
import 'api.dart';
import 'see_DAILY_ACT_page.dart';
import 'see_DAILY_CND_page.dart';
import 'see_DAILY_DRY_page.dart';
import 'see_DAILY_EAT_page.dart';
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
import 'package:badges/badges.dart' as badges;
import 'package:image_picker/image_picker.dart' as ImagePicker;
import 'package:html/parser.dart' show parse;

import 'utils/CustomAppBar.dart';



class MyHomePage2_C extends StatefulWidget {

  @override
  State<MyHomePage2_C> createState() => _MyHomePage2_CState();
}

class _MyHomePage2_CState extends State<MyHomePage2_C> {

  late BuildContext _safeContext;

  Timer? timer;

  BuildContext? this_context;

  bool startService = false;
  DateTime? datetime;
  List<CALL> CALL_list = [];
  List<DEPM> DEPMs = [];

  double _currentVolume = 0.5;
  double _speechRate = 1.0;

  String play_no = "";


  static const platform = MethodChannel("samples.flutter.io/sql");
  Future<void> _startService() async {
    await platform.invokeMethod("startService");
  }

  Future<void> _stopService() async {
    await platform.invokeMethod("stopService");
  }

  /*
  Future<void> speak(String message) async {
    try {
      await platform.invokeMethod('speak', {'message': message});
    } on PlatformException catch (e) {
      print("Failed to speak: '${e.message}'.");
    }
  }

   */

  Future<void> debug() async {
    await platform.invokeMethod("debug",{'is_debug': DEBUG_MODE});
  }

  @override
  void destory(){
    dev.log("MyHomePage2_U-destory()");
    if(timer!=null){
      timer!.cancel();
      timer=null;
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _safeContext = context;
  }

  @override
  void initState() {
    // TODO: implement initState

    debug();
    _startService();
    datetime = DateTime.now();

    platform.setMethodCallHandler((call) async {
      if (call.method == "notifyNo") {
        String no = call.arguments;
        dev.log("從原生接收到 NO: $no");
        play_no = no;
        setState(() {

        });
        // 你可以在這裡觸發任務，如更新 UI、查資料等
      }
    });

    sendAccountToNative(user.ACCOUNT);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);

    super.initState();

    _getCurrentVolume();
    timer = Timer.periodic(Duration(seconds: 5), (Timer t) async{

      await read_CALL_db_sub();

    });

    Future.delayed(const Duration(milliseconds: 1000), () {

      check_app_version_sub();
      is_login_main = true;

    });

    init();

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

  Future<void> _getSpeechRate() async {
    final rate = await platform.invokeMethod<double>('getSpeechRate');
    _speechRate = rate ?? 1.0;
  }

  Future<void> _setSpeechRate(double rate) async {
    await platform.invokeMethod('setSpeechRate', {'rate': rate});
    _speechRate = rate;
  }

  Future<void> _getCurrentVolume() async {
    try {
      final volume = await platform.invokeMethod<double>('getVolume');
      setState(() {
        _currentVolume = volume ?? 0.5;
      });
    } on PlatformException catch (e) {
      print("Failed to get volume: '${e.message}'.");
    }
  }

  Future<void> _setVolume(double volume) async {
    try {
      await platform.invokeMethod('setVolume', {"volume": volume});
    } on PlatformException catch (e) {
      print("Failed to set volume: '${e.message}'.");
    }
  }

  Future<void> init()async{
    SmartDialog.showLoading(msg:"初始化中...，請稍候",
      clickMaskDismiss: false, // 禁止點擊遮罩關閉
      backDismiss: false,      // 禁止按返回鍵關閉（可選）
    );
    await read_for_CUSTOMER_db_sub();
    await DEPM_db_sub();
    await CLASS_db_sub();
    await read_CALL_db_sub();
    SmartDialog.dismiss();
  }


  Future<void> _handleRefresh() async {
    await Future.delayed(Duration(seconds: 1)); // 模擬資料加載
    await read_for_CUSTOMER_db_sub();
    await CLASS_db_sub();
    await DEPM_db_sub();
    await read_CALL_db_sub();
  }

  Future<void> sendAccountToNative(String account) async {
    await platform.invokeMethod('saveAccount', {
      'account': account,
      'DEPM_NO':user.DEPM_NO
    });
  }


  Future<void>DEPM_db_sub()async{

    DEPMs.clear();
    String comm = "SELECT * FROM DEPM WHERE DEPM_NO='${user.DEPM_NO}'";
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
          DEPMs.add(ss);
        }
      }



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
    String comm = "SELECT * FROM CLASS WHERE DEPM_NO='${user.DEPM_NO}'";
    String result = await sql_command("${comm}");
    try{
      await platform.invokeMethod('saveCLASS', {'CLASS': result});
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



    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }

  /*
  學生資料 CUSTOMER
   */
  Future<void> read_for_CUSTOMER_db_sub()async{
    //await EasyLoading.show(status: "處理中...");
    cUSTOMERs.clear();
    String result = await sql_command("SELECT * FROM CUSTOMER WHERE DEPM_NO='${user.DEPM_NO}'");

    //SmartDialog.dismiss();
    try{
      await platform.invokeMethod('saveCUSTOMER', {'CUSTOMER': result});
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
          cUSTOMERs.add(b);
        }

        cUSTOMERs = removeDuplicateCSNO(cUSTOMERs);

      }



    }
    catch(e){
      dev.log("${e}");
      //SmartDialog.showToast("網路異常");
    }
  }

  Future<void> read_CALL_db_sub()async{

    CALL_list.clear();
    String _datetime = "${DateFormat('yyyy-MM-dd').format(datetime!)}";
    String result = await sql_command('''
    SELECT * 
    FROM View_CALL 
    WHERE DEPM_NO = '${user.DEPM_NO}' 
      AND CONVERT(DATE, ARRIVAL_TIME) = CONVERT(DATE, GETDATE())
    ORDER BY ARRIVAL_TIME ASC;
    ''');
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
          CALL b = CALL();
          b.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
          b.DATE_TIME = "${data_list[i]["DATE_TIME"]}".contains("null")?"":"${data_list[i]["DATE_TIME"]}";
          b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
          b.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}";
          b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}";
          b.ACCOUNT = "${data_list[i]["ACCOUNT"]}".contains("null")?"":"${data_list[i]["ACCOUNT"]}";
          b.MINUTE = "${data_list[i]["MINUTE"]}".contains("null")?"":"${data_list[i]["MINUTE"]}";
          b.ARRIVAL_TIME = "${data_list[i]["ARRIVAL_TIME"]}".contains("null")?null:DateTime.parse("${data_list[i]["ARRIVAL_TIME"]}");
          b.COMPLETE = data_list[i]["COMPLETE"];
          CALL_list.add(b);
        }

        CALL_list.sort((a,b) => b.DATE_TIME.compareTo(a.DATE_TIME));

        setState(() {

        });

      }
    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("網路異常");
    }
  }


  void _showVolumeDialog() async {
    await _getCurrentVolume(); // 確保 _currentVolume 有初始值
    await _getSpeechRate();  // 假設你也要先取得目前語音速度

    showDialog(
      context: context,
      builder: (context) {
        double tempVolume = _currentVolume;
        double tempSpeed = _speechRate;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                '語音設定',
                textScaler: TextScaler.linear(1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20.sp,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.volume_up, size: 48.sp, color: Colors.black87),
                  SizedBox(height: 12),
                  Text(
                    '音量：${(tempVolume * 100).round()}%',
                    textScaler: TextScaler.linear(1),
                    style: TextStyle(fontSize: 18.sp, color: Colors.black87),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.blueAccent,
                      inactiveTrackColor: Colors.grey[300],
                      trackHeight: 4.0,
                      thumbColor: Colors.blueAccent,
                      overlayColor: Colors.blue.withAlpha(32),
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
                    ),
                    child: Slider(
                      value: tempVolume,
                      min: 0,
                      max: 1,
                      divisions: 100,
                      onChanged: (value) {
                        setState(() {
                          tempVolume = value;
                        });
                        _setVolume(value);
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                  Icon(Icons.speed, size: 48.sp, color: Colors.black87),
                  SizedBox(height: 12),
                  Text(
                    '語速：${tempSpeed.toStringAsFixed(1)}x',
                    textScaler: TextScaler.linear(1),
                    style: TextStyle(fontSize: 18.sp, color: Colors.black87),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.green,
                      inactiveTrackColor: Colors.grey[300],
                      trackHeight: 4.0,
                      thumbColor: Colors.green,
                      overlayColor: Colors.green.withAlpha(32),
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.0),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 14.0),
                    ),
                    child: Slider(
                      value: tempSpeed,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      onChanged: (value) {
                        setState(() {
                          tempSpeed = value;
                        });
                        _setSpeechRate(value);
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    '關閉',
                    textScaler: TextScaler.linear(1),
                    style: TextStyle(color: Colors.black54, fontSize: 20.sp),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {

    this_context = context;

    setAdaptiveSystemUI(context);

    dev.log("CALL_list.length:${CALL_list.length}");

    String _datetime = "${DateFormat('yyyy-MM-dd').format(datetime!)}";
    List<String> list =_datetime.split("-");
    String DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[datetime!.weekday-1]})";


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
      appBar: CustomAppBar(
        //toolbarHeight: 34.h,
        leading: Container(), // 或 null
        leadingWidth: 0,      // 重點：取消預設的 leading 寬度
        backgroundColor: Color(0xffF9AA88),
        centerTitle: false,
        title: Row(children: [

          Text("GO HOME",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 16.sp),),

          Expanded(child: Text("-${DEPMs.firstWhere(
                (element) => element.DEPM_NO==user.DEPM_NO,
            orElse: () => DEPM(),
          ).DEPM_NM}",textScaler: TextScaler.linear(1),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16.sp),),),

        ],),
        actions: [

          GestureDetector(
            onTap: (){

              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: Container(width: ScreenUtil().screenWidth,
                          child: Text("登出",
                            textScaler: TextScaler.linear(
                                1.0), style: TextStyle(
                                fontFamily: "GenJyuuGothic",
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                                color: Color(0xff373737)),)),
                      content: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10.h,
                          ),
                          Container(
                              width: ScreenUtil().screenWidth, child: Column(children: [

                               Text("確定要登出?",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 20.sp),)

                          ],)),
                        ],
                      ),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          child: Text(
                              "取消", textScaler: TextScaler
                              .linear(1.0), style: TextStyle(
                              fontFamily: "GenJyuuGothic",
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              color: Color(0xff373737))),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        CupertinoDialogAction(
                          child: Text(
                              "確定", textScaler: TextScaler
                              .linear(1.0), style: TextStyle(
                              fontFamily: "GenJyuuGothic",
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              color: Color(0xff373737))),
                          onPressed: () async {

                            Navigator.pop(context);
                            if(timer!=null){
                              timer!.cancel();
                              timer=null;
                            }
                            SmartDialog.showLoading(msg:"登出中...");
                            await _stopService();
                            //先清掉推播token
                            dev.log("先清掉推播token");
                            try{
                              if(DEBUG_MODE==false){
                                String comm = "UPDATE EMPLOYEE SET FCM='' WHERE ACCOUNT='${EMPLOYEE_teacher.ACCOUNT}';";
                                String result = await sql_command("${comm}");
                              }
                            }
                            catch(e){

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
                              /*
                              Navigator.pushAndRemoveUntil(
                                this_context!,
                                MaterialPageRoute(builder: (this_context) => MyApp()),
                                    (Route<dynamic> route) => route ==null ,
                              );

                               */
                              // 呼叫重啟
                              Phoenix.rebirth(_safeContext); // 使用安全的 context

                            });

                          },
                        ),
                      ],
                    );
                  });

            },
            child: Text("登出",textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
          ),
          Container(width: 15.w,)
        ],
      ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showVolumeDialog,
            tooltip: '調整音量',
            child: const Icon(Icons.volume_up),
          ),
      body: Container(
        color: Color(0xffF8F8F8),
        padding: EdgeInsets.only(left:0.w,right: 0.w),width: ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
        child: Column(children: [

          Container(height: 10.h,),
          Text("${DateStr}",textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
          Container(height: 10.h,),
          Row(children: [
            Container(width: 10.w,),
            Expanded(flex:1,child:Center(child:Text("班級",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 18.sp,color: Colors.black)))),
            Expanded(flex:2,child:Center(child:Text("學生",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 18.sp,color: Colors.black)))),
            Expanded(flex:2,child:Center(child:Text("預計時間",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 18.sp,color: Colors.black)))),
            Expanded(flex:1,child:Text("完成",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 15.sp,color: Colors.transparent))),
            Container(width: 40.w,),
          ],),
          Container(height: 5.h,),
          Container(
            margin: EdgeInsets.only(left:10.w,right: 10.w),
            width: ScreenUtil().screenWidth,height: 1,color: Colors.black,),
          Container(height: 5.h,),
          Expanded(child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(), // 關鍵設定
                  itemCount: CALL_list.length,
                  shrinkWrap: false,
                  padding: EdgeInsets.zero,
                  itemBuilder: (c,index){

                   CLASS _CLASS = cLASSs.firstWhere(
                           (element) => element.CLASS_NO==CALL_list[index].CLASS_NO,
                     orElse: () => CLASS(),
                   );
                   CUSTOMER _CUSTOMER = cUSTOMERs.firstWhere(
                           (element) => element.CS_NO==CALL_list[index].CS_NO,
                     orElse: () => CUSTOMER(),
                   );
                   bool is_COMPLETE = CALL_list[index].COMPLETE;

                return Column(children: [

              Container(color: (play_no==CALL_list[index].NO)?Colors.yellow:Colors.transparent,child: Row(children: [
                Container(width: 10.w,),
                Expanded(flex:1,child:Center(child:Text("${_CLASS.CLASS_NM}",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 17.sp,color: Colors.black)))),
                Expanded(flex:2,child:Center(child:Text("${_CUSTOMER.CS_NM}",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 17.sp,color: Colors.black)))),
                Expanded(flex:2,child:Center(child:Text("${DateFormat('HH:mm:ss').format(CALL_list[index].ARRIVAL_TIME!)}",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 17.sp,color: Colors.black)))),
                (is_COMPLETE==true)?
                Expanded(flex:1,child:Center(child:Text("完成",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 15.sp,color: Colors.green))))
                :
                (play_no==CALL_list[index].NO)?
                Expanded(flex:1,child:Center(child:Text("播放中",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 15.sp,color: Colors.red))))
                :
                Expanded(flex:1,child:Center(child:Text("未播報",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 15.sp,color: Colors.red)))),
                Container(width: 40.w,),
              ],)),
              Container(height: 5.h,),
              Container(
                margin: EdgeInsets.only(left:10.w,right: 10.w),
                width: ScreenUtil().screenWidth,height: 1,color: Colors.black26,),
              Container(height: 5.h,),

            ],);
          }))),

        ],),
      ),
        )));
  }
}


