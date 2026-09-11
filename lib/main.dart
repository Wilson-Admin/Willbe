import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
//import 'package:alarm/alarm.dart' as alarm;
import 'package:another_flushbar/flushbar.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:code3/chat_T_all.dart';
import 'package:code3/firebase_messaging/message.dart';
import 'package:code3/main2_T.dart';
import 'package:code3/student_T.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:developer' as dev;
import 'DRUG_MT_T_page.dart';
import 'api.dart';
import 'fcm_notifity.dart';
import 'firebase_messaging/firebase_options.dart';
import 'main2_C.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
RemoteMessage? pendingMessage;
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();
  //showFlutterNotification(message);
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}



/// Initialize the [FlutterLocalNotificationsPlugin] package.
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


// Toggle this to cause an async error to be thrown during initialization
// and to test that runZonedGuarded() catches the error
const _kShouldTestAsyncErrorOnInit = false;

// Toggle this for testing Crashlytics in your app locally.
const _kTestingCrashlytics = true;

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  _clearBadge(); // 清除小紅點
  packageInfo = await PackageInfo.fromPlatform();

  if(Platform.isAndroid) {
    await Firebase.initializeApp(
      //name: "威寶通",
        options: DefaultFirebaseOptions.currentPlatform);
  }
  else{
    await Firebase.initializeApp(
        name: "威寶通",
        options: DefaultFirebaseOptions.currentPlatform);
  }
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    await setupFlutterNotifications();
  }

  //await alarm.Alarm.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  const fatalError = true;
  // Non-async exceptions
  FlutterError.onError = (errorDetails) {
    if (fatalError) {
      // If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      // ignore: dead_code
    } else {
      // If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
    }
  };
  // Async exceptions
  PlatformDispatcher.instance.onError = (error, stack) {
    if (fatalError) {
      // If you want to record a "fatal" exception
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      // ignore: dead_code
    } else {
      // If you want to record a "non-fatal" exception
      FirebaseCrashlytics.instance.recordError(error, stack);
    }
    return true;
  };

  runApp(
      Phoenix(
         child:const MyApp()
      )
  );
}



void _clearBadge() {
  // Remove badge
  AppBadgePlus.updateBadge(0);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(screen_width, screen_height),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_ , child) {
        return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
            child: MaterialApp(
          debugShowCheckedModeBanner: false,
                navigatorKey: navigatorKey, // ✅ 必須正確傳入這裡
          title: '威寶通',
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const <Locale>[
              Locale('en'),
              Locale.fromSubtags(
                  languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
              Locale('fr'),
              Locale('es'),
              Locale('de'),
              Locale('ru'),
              Locale('ja'),
              Locale('ar'),
              Locale('fa'),
              Locale('es'),
              Locale('it'),
            ],
          // You can use the library anywhere in the app even in theme
          theme: ThemeData(
            // 1. 如果需要完全還原舊版視覺比例與行高，可將 useMaterial3 設為 false
            useMaterial3: false,
            // 2. 全域設定原本使用的字體名稱
            fontFamily: 'GenJyuuGothic',
            primarySwatch: Colors.blue,
            // 2. 🔥 全域修改所有 ListTile 的間距與寬度 🔥
            listTileTheme: const ListTileThemeData(
              dense: true,               // 整體更緊湊
              minLeadingWidth: 0,        // 取消 leading 圖示預設佔用的最小寬度 (預設是 40)
              horizontalTitleGap: 8,     // 設定圖示與文字之間的間距 (可依視覺需求調整為 6~10)
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0), // 左右內邊距 (可選)
            ),
            // 保留原有字體縮放
            textTheme: Typography.englishLike2018.apply(
              bodyColor: Colors.black,
              displayColor: Colors.black,
              fontSizeFactor: 1.sp,
              fontFamily: 'GenJyuuGothic',
            ),
            // 🔥 全域設定 AppBar 上的 Icon 尺寸與顏色 🔥
            appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(
                size: 30, // 全域 AppBar 圖示大小
                color: Colors.black, // 可順便統一顏色
              ),
            ),
          ),
          home: child,
          builder: FlutterSmartDialog.init(builder: (context, child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(textScaler: TextScaler.linear(1),),
              child: child!,
            );
          },
        )));
      },
      child: const MyHomePage(title: '威寶通'),

    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {


  List<DAILY_PRS> DAILY_PRSs = [];
  int page = 0;
  PageController? pageController;

  TextEditingController _admin_TextEditingController = TextEditingController();
  TextEditingController _password_TextEditingController = TextEditingController();
  bool _adminVisible = false;
  bool _passVisible = false;
  bool checkbox_value = false;


  bool checkbox1 = false;

  String _token="";
  String initialMessage="";
  bool _resolved = false;
  bool check_box = false;

  BuildContext? _context;

  int ios_connect_count=0;
  var showDialog_setState;
  EXCUSED eXCUSED = EXCUSED();



  void _incrementCounter() async{

    String result = await sql_command("SELECT * FROM [CUSTOMER_DL]");

  }

  void showFlutterNotification(RemoteMessage message) {
    /*
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  if (notification != null && android != null && !kIsWeb) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: 'notification_icon',
        ),
      ),
    );
  }

   */

    if(user_is_login==true && in_chat == false){

      dev.log("showFlutterNotification:${message.data}");

      if(message.notification!.title!.contains("老師")){

        if("${message.data["ChatID"]}".contains("已讀聯絡簿")||
            "${message.data["ChatID"]}".contains("已回覆聯絡簿")||
            "${message.data["ChatID"]}".contains("到校")||
            "${message.data["ChatID"]}".contains("離校")||
            "${message.data["ChatID"]}".contains("電子聯絡簿已完成上傳")
        ){

          MyHomePage2_U_fun2!(
            reflash_db:"前往生活概況",
            ChatID:"${message.data["ChatID"]}",
            TeacherAccount:"${message.data["TeacherAccount"]}",
            UserAccount:"${message.data["TeacherAccount"]}",
          );

        }
        else if("${message.data["ChatID"]}".contains("老師已將請假委託變更為")){
          MyHomePage2_U_fun1!(reflash_db:"EXCUSED");
        }

      }
      else{
        if("${message.data["ChatID"]}"=="用藥委託"){
          MyHomePage2_T_fun2!(type:"前往用藥委託",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
        }
        else if("${message.data["ChatID"]}"=="用藥委託刪除"){
          MyHomePage2_T_fun2!(type:"前往用藥委託(刪除)",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
        }
        else if("${message.data["ChatID"]}"=="接送委託"){
          MyHomePage2_T_fun2!(type:"前往接送委託",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
        }
        else if("${message.data["ChatID"]}"=="接送委託刪除"){
          MyHomePage2_T_fun2!(type:"前往接送委託(刪除)",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
        }
        else if("${message.data["ChatID"]}"=="請假委託"){
          MyHomePage2_T_fun2!(type:"前往請假委託",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
        }
        else if("${message.data["ChatID"]}"=="請假委託刪除"){
          MyHomePage2_T_fun2!(type:"前往請假委託(刪除)",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
        }
        else if("${message.data["ChatID"]}".contains("聯絡簿回簽有備註")){
          MyHomePage2_T_fun2!(type:"前往聯絡簿回簽有備註",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
        }
        else if("${message.data["ChatID"]}".contains("家長已回簽通知單")){
          MyHomePage2_T_fun1!(type:"前往家長已回簽通知單",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
        }
      }


      Flushbar(
        title:  "${message.notification!.title}",
        message:  "${message.notification!.body}",
        flushbarPosition: FlushbarPosition.BOTTOM,
        flushbarStyle: FlushbarStyle.FLOATING,
        mainButton: TextButton(
          onPressed: () async{

            if(message.notification!.title!.contains("老師")){

              dev.log("${message.data["ChatID"]}");

              if("${message.data["ChatID"]}".contains("已讀聯絡簿")||
                  "${message.data["ChatID"]}".contains("已回覆聯絡簿")||
                  "${message.data["ChatID"]}".contains("電子聯絡簿已完成上傳")
              ){

                MyHomePage2_U_fun1!(
                  reflash_db:"前往生活概況",
                  ChatID:"${message.data["ChatID"]}",
                  TeacherAccount:"${message.data["TeacherAccount"]}",
                  UserAccount:"${message.data["TeacherAccount"]}",
                );

              }
              else if("${message.data["ChatID"]}".contains("老師已將請假委託變更為")){
                MyHomePage2_U_fun2!(reflash_db:"前往請假申請");
              }
              else{

                if(MyHomePage2_U_fun1!=null){
                  MyHomePage2_U_fun1!(
                    reflash_db:"點推播進入聊天室列表",
                    ChatID:"${message.data["ChatID"]}",
                    TeacherAccount:"${message.data["TeacherAccount"]}",
                    UserAccount:"${message.data["TeacherAccount"]}",
                  );
                }

              }


            }
            else{

              if("${message.data["ChatID"]}".contains("用藥委託")){
                MyHomePage2_T_fun1!(type:"前往用藥委託",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
                await read_DRUG_MT_db_sub(DRUG_NO: "${message.data["DRUG_NO"]}");
                navigatorKey.currentState?.push(
                  PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: DRUG_MT_T_page(),
                  ),
                );
              }
              else if("${message.data["ChatID"]}".contains("接送委託")){
                MyHomePage2_T_fun1!(type:"前往接送委託",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
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
                ENTRUSTED_db_sub(NO:"${message.data["ENTRUSTED_NO"]}");
              }
              else if("${message.data["ChatID"]}".contains("請假委託")){
                MyHomePage2_T_fun1!(type:"前往請假委託",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
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
                EXCUSED_db_sub(NO:"${message.data["EXCUSED_NO"]}");
              }
              else if("${message.data["ChatID"]}".contains("聯絡簿回簽有備註")){
                MyHomePage2_T_fun1!(type:"前往聯絡簿回簽有備註",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
              }
              else if("${message.data["ChatID"]}".contains("家長已回簽通知單")){
                MyHomePage2_T_fun2!(type:"前往家長已回簽通知單",DAILY_NOT_NO:"${message.data["DAILY_NOT_NO"]}",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
              }
              else{
                MyHomePage2_T_fun1!(type:"前往聊天室");
              }

              /*
              if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DL==null){
                EasyLoading.showInfo("尚未建立家長資訊");
              }
              else{
                Navigator.push(context, PageTransition(
                    type: PageTransitionType.rightToLeft, child: ChatPage_T_all()));
              }

               */

            }

          },
          child: Text(
            "前往",
            textScaler: TextScaler.linear(1.0),
            style: TextStyle(color: Colors.amber,fontFamily: "PingFangMedium",fontSize: 14.sp),
          ),
        ),
        titleText: Text(
          user.RANK.toLowerCase()=="u"?
          ((message.notification!.title!.contains("老師"))?"老師":"${message.notification!.title}")
          :"${message.notification!.title}",
          textScaler: TextScaler.linear(1.0),
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16.0.sp, color: Colors.yellow[600], fontFamily: "PingFangMedium"),
        ),
        messageText: Text(
          "${message.notification!.body}",
          textScaler: TextScaler.linear(1.0),
          style: TextStyle(fontSize: 14.0.sp, color: Colors.green, fontFamily: "PingFangMedium"),
        ),
        duration:  Duration(seconds: 5),
      )..show(_context!);


    }
  }

  Future<void> login_db_sub({String admin="",String pass=""})async{
    is_finish_load = false;
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    
    if(Platform.isIOS){
      if(admin.contains("0999000010")||admin.contains("0999000011")){
        if(ios_connect_count==0){
          SQL_IP = SQL_IP_IPV6;
        }
        else{
          SQL_IP = SQL_IP_IPV4;
        }
      }
    }
    
    await Future.delayed(const Duration(milliseconds: 500), () {});
    DateTime dd1 = DateTime.now();
    String result = await sql_command("SELECT * FROM [View_LOGIN] WHERE ACCOUNT = '${admin}' AND PASSWORD = '${pass}'");
    DateTime dd2 = DateTime.now();

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
        SmartDialog.showToast("請確認帳號密碼是否正確");
        page=1;
        setState(() {

        });
      }
      else{
        ios_connect_count=0;

        dev.log("data_list.length:${data_list.length}");

        //檢查是否身份都是家長
        int u_count=0;
        for(int i=0;i<data_list.length;i++){
          if(data_list[i]["RANK"].toString().toLowerCase().contains("u")){
            u_count+=1;
          }
        }

        if(data_list.length>1 && (u_count!=data_list.length)){
          dev.log("登入者同時有兩個身份,彈出視窗選擇身份登入");

          Set<dynamic> seenRanks = {};
          data_list = data_list.where((item) {
            final rank = item['RANK'];
            return seenRanks.add(rank); // 只會保留第一次出現的 RANK
          }).toList();

          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('請選擇身份登入',textScaler: TextScaler.linear(1),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 20.sp),),
                  content: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4, // 最多佔螢幕高度 40%
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: data_list.map((e){
                          return TextButton(
                            child: Text('${e["RANK"].toString().toLowerCase().contains("u")?"家長":e["RANK"].toString().toLowerCase().contains("t")?"老師":"管理員"}',textScaler: TextScaler.linear(1),
                              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue,fontSize: 20.sp),),
                            onPressed: () {
                              Navigator.of(context).pop();
                              init_user_sub(item:e);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text('取消',textScaler: TextScaler.linear(1),style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 16.sp),),
                      onPressed: () {
                        // 可在此處加入確認後的處理邏輯
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        }
        else{
          init_user_sub(item:data_list[0]);
        }

      }

    }
    catch(e){
      dev.log("${e}");
      SmartDialog.dismiss();
      if(Platform.isIOS){
        if(ios_connect_count==0){
          ios_connect_count+=1;
          login_db_sub(admin: admin,pass: pass);
        }
        else{
          ios_connect_count=0;
          if("${result}".contains("null") || result.isEmpty){

            dev.log("錯誤-1");
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('請檢查設備網路是否正常',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                    content: Text('連線起始時間:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd1)}\n連線起始結束:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd2)}\n\n資訊:\n${e}',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                    actions: <Widget>[

                      TextButton(
                        child: Text('確認',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                        onPressed: () {
                          // 可在此處加入確認後的處理邏輯
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });


          }
          else{

            dev.log("錯誤-2");
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return
                    AlertDialog(
                      title: Text('請檢查設備網路是否正常',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                      content: Text('連線起始時間:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd1)}\n連線起始結束:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd2)}\n\n資訊:\n${result}',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                      actions: <Widget>[

                        TextButton(
                          child: Text('確認',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                          onPressed: () {
                            // 可在此處加入確認後的處理邏輯
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );});
          }
        }
      }
      else{
        if("${result}".contains("null") || result.isEmpty){

          dev.log("錯誤-1");
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('請檢查設備網路是否正常',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                  content: Text('連線起始時間:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd1)}\n連線起始結束:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd2)}\n\n資訊:\n${e}',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                  actions: <Widget>[

                    TextButton(
                      child: Text('確認',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                      onPressed: () {
                        // 可在此處加入確認後的處理邏輯
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });


        }
        else{

          dev.log("錯誤-2");
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return
                  AlertDialog(
                    title: Text('請檢查設備網路是否正常',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                    content: Text('連線起始時間:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd1)}\n連線起始結束:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd2)}\n\n資訊:\n${result}',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                    actions: <Widget>[

                      TextButton(
                        child: Text('確認',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                        onPressed: () {
                          // 可在此處加入確認後的處理邏輯
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );});
        }
      }

      page=1;
      setState(() {

      });

    }
  }

  Future<void> login_db_sub2({String admin="",String pass=""})async{

    dev.log("login_db_sub2");

    is_finish_load = false;
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");

    if(Platform.isIOS){
      if(admin.contains("0999000010")||admin.contains("0999000011")){
        if(ios_connect_count==0){
          SQL_IP = SQL_IP_IPV6;
        }
        else{
          SQL_IP = SQL_IP_IPV4;
        }
      }
    }

    await Future.delayed(const Duration(milliseconds: 500), () {});
    DateTime dd1 = DateTime.now();
    String result = await sql_command("SELECT * FROM [View_LOGIN] WHERE ACCOUNT = '${admin}' AND PASSWORD = '${pass}'");
    DateTime dd2 = DateTime.now();

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
        SmartDialog.showToast("請確認帳號密碼是否正確");
        page=1;
        setState(() {

        });
      }
      else{
        ios_connect_count=0;

        dev.log("data_list.length:${data_list.length}");
        if(data_list.length>1){
          //找出上次登入身份權限
          dev.log("找出上次登入身份權限");
          SharedPreferences prefs = await SharedPreferences.getInstance();
          bool check = false;
          for(int i=0;i<data_list.length;i++){
            String RANK = prefs.getString('RANK')??"";
            if("${data_list[i]["RANK"]}".toLowerCase().contains(RANK.toLowerCase())){
              init_user_sub(item: data_list[i]);
              check = true;
              break;
            }
          }

          if(check==false){
            page=1;
            setState(() {

            });
          }

        }
        else{

          init_user_sub(item:data_list[0]);

        }


      }

    }
    catch(e){
      dev.log("${e}");
      SmartDialog.dismiss();
      if(Platform.isIOS){
        if(ios_connect_count==0){
          ios_connect_count+=1;
          login_db_sub(admin: admin,pass: pass);
        }
        else{
          ios_connect_count=0;
          if("${result}".contains("null") || result.isEmpty){

            dev.log("錯誤-1");
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('請檢查設備網路是否正常',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                    content: Text('連線起始時間:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd1)}\n連線起始結束:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd2)}\n\n資訊:\n${e}',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                    actions: <Widget>[

                      TextButton(
                        child: Text('確認',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                        onPressed: () {
                          // 可在此處加入確認後的處理邏輯
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });


          }
          else{

            dev.log("錯誤-2");
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return
                    AlertDialog(
                      title: Text('請檢查設備網路是否正常',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                      content: Text('連線起始時間:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd1)}\n連線起始結束:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd2)}\n\n資訊:\n${result}',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                      actions: <Widget>[

                        TextButton(
                          child: Text('確認',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                          onPressed: () {
                            // 可在此處加入確認後的處理邏輯
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );});
          }
        }
      }
      else{
        if("${result}".contains("null") || result.isEmpty){

          dev.log("錯誤-1");
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('請檢查設備網路是否正常',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                  content: Text('連線起始時間:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd1)}\n連線起始結束:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd2)}\n\n資訊:\n${e}',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                  actions: <Widget>[

                    TextButton(
                      child: Text('確認',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                      onPressed: () {
                        // 可在此處加入確認後的處理邏輯
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });


        }
        else{

          dev.log("錯誤-2");
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return
                  AlertDialog(
                    title: Text('請檢查設備網路是否正常',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                    content: Text('連線起始時間:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd1)}\n連線起始結束:${DateFormat("yyyy-MM-dd HH:mm:ss").format(dd2)}\n\n資訊:\n${result}',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                    actions: <Widget>[

                      TextButton(
                        child: Text('確認',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 16.sp),),
                        onPressed: () {
                          // 可在此處加入確認後的處理邏輯
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );});
        }
      }

      page=1;
      setState(() {

      });

    }
  }

  init_user_sub({dynamic item})async{
    user.ACCOUNT = "${item["ACCOUNT"]}".contains("null")?"":"${item["ACCOUNT"]}";
    user.RANK = "${item["RANK"]}".contains("null")?"":"${item["RANK"]}";
    user.KIDS_NO = "${item["KIDS_NO"]}".contains("null")?"":"${item["KIDS_NO"]}";
    user.PASSWORD = "${item["PASSWORD"]}".contains("null")?"":"${item["PASSWORD"]}";
    user.DEPM_NM = "${item["DEPM_NM"]}".contains("null")?"":"${item["DEPM_NM"]}";
    user.CLASS_NM = "${item["CLASS_NM"]}".contains("null")?"":"${item["CLASS_NM"]}";
    user.DEPM_NO = "${item["DEPM_NO"]}".contains("null")?"":"${item["DEPM_NO"]}";
    user.CLASS_TY = "${item["CLASS_TY"]}".contains("null")?"":"${item["CLASS_TY"]}";
    user.CLASS_NO = "${item["CLASS_NO"]}".contains("null")?"":"${item["CLASS_NO"]}";
    user.CLASS_TYNM = "${item["CLASS_TYNM"]}".contains("null")?"":"${item["CLASS_TYNM"]}";
    user.KIDS_NM = "${item["KIDS_NM"]}".contains("null")?"":"${item["KIDS_NM"]}";
    user.USER_NM = "${item["USER_NM"]}".contains("null")?"":"${item["USER_NM"]}";
    user.TOKEN_ID = "${item["TOKEN_ID"]}".contains("null")?"":"${item["TOKEN_ID"]}";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(checkbox1==true){

      await prefs.setString('admin', '${_admin_TextEditingController.text}');
      await prefs.setString('pass', '${_password_TextEditingController.text}');
    }
    else{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin', '');
      await prefs.setString('pass', '');
    }
    await prefs.setString('is_login', 'true');
    await prefs.setString('RANK', "${item["RANK"]}");

    try {
      _token = await FirebaseMessaging.instance.getToken() ?? "";
      dev.log("FirebaseMessaging token:${_token}");
      if(DEBUG_MODE==false) {
        //await updata_fcm_token_sub(TOKEN_ID: _token);
        user.TOKEN_ID = "${_token}";
      }
    }
    catch(e){
      dev.log("e:${e}");
    }
    SmartDialog.showToast("登入成功");


    if(user.RANK.toLowerCase()=="u") {
      dev.log("身份:家長");
      Navigator.push(_context!, PageTransition(
          type: PageTransitionType.rightToLeft, child: MyHomePage2_U()));

    }
    else if(user.RANK.toLowerCase()=="t" || user.RANK.toLowerCase()=="m") {

      //先讀取本地端的日常用語
      String str = prefs.getString('日常用語_${user.ACCOUNT}')??"";
      dev.log("讀取本地端的日常用語-1,${str}");
      if(str.isEmpty){
        sel_teacher_Daily_language_menu.account = user.ACCOUNT;
        sel_teacher_Daily_language_menu.menu = [
          Daily_language_menu(title: "活動",is_sel: true),
          Daily_language_menu(title: "生理狀況"),
          Daily_language_menu(title: "日記"),
          Daily_language_menu(title: "用餐"),
          Daily_language_menu(title: "通知單"),
        ];
        prefs.setString('日常用語',jsonEncode(sel_teacher_Daily_language_menu.toJson()));
      }
      else{

        dynamic teacher_Daily_language_menu = jsonDecode(str);
        sel_teacher_Daily_language_menu.account = user.ACCOUNT;
        sel_teacher_Daily_language_menu.menu = [
          Daily_language_menu(title: "活動",is_sel: true,contants: teacher_Daily_language_menu["活動"]),
          Daily_language_menu(title: "生理狀況",contants: teacher_Daily_language_menu["生理狀況"]),
          Daily_language_menu(title: "日記",contants: teacher_Daily_language_menu["日記"]),
          Daily_language_menu(title: "用餐",contants: teacher_Daily_language_menu["用餐"]),
          Daily_language_menu(title: "通知單",contants: teacher_Daily_language_menu["通知單"]),
        ];
        prefs.setString('日常用語_${user.ACCOUNT}',jsonEncode(sel_teacher_Daily_language_menu.toJson()));

      }

      dev.log("身份:老師 or 主管");
      Navigator.push(_context!, PageTransition(
          type: PageTransitionType.rightToLeft, child: MyHomePage2_T()));
    }
    else if(user.RANK.toLowerCase()=="c") {
      dev.log("身份:go home");
      if(Platform.isAndroid){
        Navigator.push(_context!, PageTransition(
            type: PageTransitionType.rightToLeft, child: MyHomePage2_C()));
      }
      else{
        Fluttertoast.showToast(
            msg: "接送廣播功能只支援android系統",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }


    }
  }


  Future<void> updata_fcm_token_sub({String TOKEN_ID=""})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});

    String result = "";
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


    SmartDialog.dismiss();
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


  late Future<void> _initializeFlutterFireFuture;

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      dev.log("${list[150]}");
    });
  }

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }


  @override
  void initState() {
    // TODO: implement initState

    _initializeFlutterFireFuture = _initializeFlutterFire();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    WidgetsBinding.instance.addObserver(this); // ✅ 註冊觀察器


    fcm_init();

    dev.log("啟動");

    //_admin_TextEditingController.text="0988080080";
    //_password_TextEditingController.text="080080";

    pageController = PageController(
      //用来配置PageView中默认显示的页面 从0开始
      initialPage: 0,
      //为true是保持加载的每个页面的状态
      keepPage: true,
    );

    Future.delayed(const Duration(milliseconds: 2500), () {

      init();

    });


  }

  @override
  void dispose() {

    WidgetsBinding.instance.removeObserver(this); // ✅ 移除觀察器
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    setState(() {
      switch (state) {
        case AppLifecycleState.resumed:
          dev.log('前台 (resumed)');
          if(is_login_main == true && user_is_login == true) {
             check_app_version_sub();
             checkShouldShowDialog(context:context);
          }
          break;
        case AppLifecycleState.inactive:
          dev.log('非活動 (inactive)');
          break;
        case AppLifecycleState.paused:
          dev.log('背景 (paused)');
          break;
        case AppLifecycleState.detached:
          dev.log('已終止 (detached)');
          break;
        case AppLifecycleState.hidden:
          // TODO: Handle this case.
          dev.log('應用程式進入多工模式且「不再可見」時');
          break;
      }
    });
  }



  Future<void> check_app_version_sub()async{
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
                  _showVersionDialog(_context!,
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
          _showVersionDialog(_context!,
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
    Navigator.pop(_context!);
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  /*
  [托嬰/幼兒]用藥委託主表單(個人) DRUG_MT
   */
  Future<DRUG_MT> read_DRUG_MT_db_sub({String DRUG_NO=""})async{

    dRUG_MT = DRUG_MT();
    String comm = "SELECT * FROM DRUG_MT WHERE DRUG_NO='${DRUG_NO}'";
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
        }



      }


    }
    catch(e){
      dev.log("${e}");
    }

    return dRUG_MT;

  }


  /*
  [托嬰/幼兒] DAILY_PRS
   */
  Future<void> read_for_DAILY_PRS_db_sub({String NO="",String TYPE=""})async{

    DAILY_PRSs.clear();
    setState(() {

    });
    String comm = "SELECT * FROM DAILY_PRS WHERE NO='${NO}' AND TYPE='${TYPE}'";
    dev.log("comm:${comm}");
    String result = await sql_command(comm);
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

        b.REPLY = "${data_list[i]["REPLY"]}".contains("null")?"":"${data_list[i]["REPLY"]}";
        b.REPLY_textEditingController.text = b.REPLY;

        b.REPLY_USER_NO = "${data_list[i]["REPLY_USER_NO"]}".contains("null")?"":"${data_list[i]["REPLY_USER_NO"]}";
        b.STATUS = "${data_list[i]["STATUS"]}".contains("null")?"":"${data_list[i]["STATUS"]}";
        String SIGN_LINK = "${data_list[i]["SIGN_LINK"]}".replaceAll("~/", "");
        b.SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK}";

        b.DATE = DateFormat('yyyy-MM-dd').format(DateTime.parse(b.DATE));
        List<String> list = b.DATE.split("-");
        b.DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[DateTime(int.parse(list[0]),int.parse(list[1]),int.parse(list[2])).weekday-1]})";

        if(b.STATUS!="老師已讀"){
          dev.log("聯絡簿上傳老師已讀");
          bool check = await updata_DAILY_PRS_db_sub(
            TYPE:b.TYPE,
            NO:b.NO,//編號
            STATUS:"老師已讀",//
          );
          if(check==true){
            b.STATUS="老師已讀";
          }
        }

        _DAILY_PRSs.add(b);

      }
      DAILY_PRSs=_DAILY_PRSs;
      DAILY_PRSs.sort((a,b) => b.DATE.compareTo(a.DATE));

      showDialog_setState(() {

      });


    }
    catch(e){
      dev.log("${e}");
    }
  }

  /*
   */
  Future<bool> updata_DAILY_PRS_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        String STATUS="",//消息的狀態
      })async{

    String comm = "UPDATE DAILY_PRS SET STATUS='${STATUS}' WHERE NO='${NO}' AND TYPE='${TYPE}'";
    dev.log("${comm}");


    String result = await sql_command("${comm}");
    dev.log("result:${result}");
    try{

      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs.length;i++){
        String FCM = await search_CUSTOMER_DL_fcm_sub(ACCOUNT:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.ACCOUNT);
        await sendPushNotification(
            title: "老師",
            message: "已讀聯絡簿",
            token: FCM,//EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.FCM,
            ChatID:"已讀聯絡簿",
            CS_NO:CUSTOMER_selectedValue.CS_NO,
            DATE:"${DateFormat("yyyy-MM-dd").format(DateTime.now())}",//日期
            UserAccount:'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.ACCOUNT}',
            TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}".trim()
        );
      }
      return true;

    }
    catch(e){
      dev.log("${e}");
      return false;
    }


  }


  /*
  老師端-學生-今日聯絡簿，老師想要有回覆的功能。
   */
  Future<void> write_REPLY_to_DAILY_PRS_db_sub({
    String REPLY="",
    String REPLY_USER_NO="",
    String TYPE="",
    String NO=""
  }
      )async{

    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 800), () {});

    String comm = "UPDATE DAILY_PRS SET REPLY='${REPLY}' WHERE TYPE='${TYPE}' AND NO='${NO}'";
    dev.log("${comm}");


    String result = await sql_command("${comm}");
    SmartDialog.dismiss();

    dev.log("result:${result}");
    try{

      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs.length;i++){
        String FCM = await search_CUSTOMER_DL_fcm_sub(ACCOUNT:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.ACCOUNT);
        await sendPushNotification(
            title: "老師",
            message: "已回覆聯絡簿",
            token: FCM,//EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.FCM,
            ChatID:"已回覆聯絡簿",
            CS_NO:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO,
            DATE:"${DateFormat("yyyy-MM-dd").format(DateTime.now())}",//日期
            UserAccount:'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.ACCOUNT}',
            TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}".trim()
        );
      }
      SmartDialog.showToast("送出成功");

    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("送出失敗");
    }

  }

  Future<void> handleNotification(RemoteMessage message) async {

    dev.log("1.handleNotification:${message.data}");
    if(message.notification!.title!.contains("老師")){

      if("${message.data["ChatID"]}".contains("已讀聯絡簿")||
          "${message.data["ChatID"]}".contains("已回覆聯絡簿")||
          "${message.data["ChatID"]}".contains("到校")||
          "${message.data["ChatID"]}".contains("離校")||
          "${message.data["ChatID"]}".contains("電子聯絡簿已完成上傳")
      ){

        MyHomePage2_U_fun2!(
          reflash_db:"前往生活概況",
          ChatID:"${message.data["ChatID"]}",
          TeacherAccount:"${message.data["TeacherAccount"]}",
          UserAccount:"${message.data["TeacherAccount"]}",
        );

      }
      else if("${message.data["ChatID"]}".contains("老師已將請假委託變更為")){
        MyHomePage2_U_fun1!(reflash_db:"EXCUSED");
      }

    }
    else{

      if("${message.data["ChatID"]}"=="用藥委託"){
        //MyHomePage2_T_fun2!(type:"前往用藥委託",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
        await read_DRUG_MT_db_sub(DRUG_NO: "${message.data["DRUG_NO"]}");

        navigatorKey.currentState?.push(
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: DRUG_MT_T_page(),
          ),
        );


        /*
          Navigator.push(context, PageTransition(
              type: PageTransitionType.rightToLeft, child: DRUG_MT_T_page()));

         */


      }
      else if("${message.data["ChatID"]}"=="用藥委託刪除"){
        //MyHomePage2_T_fun2!(type:"前往用藥委託(刪除)",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");

        await read_DRUG_MT_db_sub(DRUG_NO: "${message.data["DRUG_NO"]}");
        navigatorKey.currentState?.push(
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: DRUG_MT_T_page(),
          ),
        );
        /*
          Navigator.push(context, PageTransition(
              type: PageTransitionType.rightToLeft, child: DRUG_MT_T_page()));

           */
      }
      else if("${message.data["ChatID"]}"=="接送委託刪除"){
        MyHomePage2_T_fun2!(type:"前往接送委託(刪除)",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
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
        ENTRUSTED_db_sub(NO:"${message.data["ENTRUSTED_NO"]}");
      }
      else if("${message.data["ChatID"]}"=="接送委託"){
        MyHomePage2_T_fun2!(type:"前往接送委託",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
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
        ENTRUSTED_db_sub(NO:"${message.data["ENTRUSTED_NO"]}");
      }
      else if("${message.data["ChatID"]}"=="請假委託"){
        MyHomePage2_T_fun2!(type:"前往請假委託",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
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
        await EXCUSED_db_sub(NO:"${message.data["EXCUSED_NO"]}");
      }
      else if("${message.data["ChatID"]}"=="請假委託刪除"){
        MyHomePage2_T_fun2!(type:"前往請假委託(刪除)",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
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
        await EXCUSED_db_sub(NO:"${message.data["EXCUSED_NO"]}");
      }
      else if("${message.data["ChatID"]}".contains("聯絡簿回簽有備註")){
        MyHomePage2_T_fun2!(type:"前往聯絡簿回簽有備註",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
        DAILY_PRSs.clear();
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                showDialog_setState = setState;

                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // 取消圓角
                  backgroundColor: Colors.white,
                  insetPadding: EdgeInsets.all(0),
                  child: DAILY_PRSs.length==0?
                  ListView(
                    padding: EdgeInsets.all(10),
                    children: [
                      Row(children: [
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.transparent,size: 30.sp,),
                          onPressed: (){},
                        ),
                        Expanded(child: Center(child:Text("聯絡簿",style: TextStyle(
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
                      Text("此聯絡簿不存在",textAlign: TextAlign.center,style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          color: Color(0xff555555)))
                    ],)
                      :
                  ListView(
                    padding: EdgeInsets.all(10),
                    children: [

                      Column(children: DAILY_PRSs.map((e){

                        //學校(DEPM)
                        DEPM _DEPM = DEPM();
                        CLASS _CLASS = CLASS();
                        try {
                          _DEPM = dEPMs.firstWhere((element) =>
                          element.DEPM_NO == e.DEPM_NO);
                          _CLASS = cLASSs.firstWhere((element) =>
                          element.CLASS_NO == e.CLASS_NO);
                        }
                        catch(e){

                        }

                        String student_name = "";
                        for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
                          if(e.CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO){
                            student_name = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NM;
                            break;
                          }
                        }

                        return Column(children: [

                          Row(children: [
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.transparent,size: 30.sp,),
                              onPressed: (){},
                            ),
                            Expanded(child: Center(child:Text("聯絡簿",style: TextStyle(
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
                            Text("${student_name}\n(${e.DateStr})",textScaler: TextScaler.linear(1),style: TextStyle(
                                fontFamily: "GenJyuuGothic",
                                fontWeight: FontWeight.w700,
                                color: Colors.red , fontSize: 20.sp),),
                          ],),
                          Container(
                              width: ScreenUtil().screenWidth,
                              //height: 55.w,
                              //margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                color: Color(0xfffff6dc),
                                borderRadius: BorderRadius.circular(0.w),
                              ),
                              child:Column(children: [
                                GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap:(){
                                      //e.REPLY_FocusNode.unfocus();
                                    },
                                    child: Column(children: [
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
                                        Text("${e.NOTE}",
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

                                      Container(height: 5.h,),
                                      Row(children: [
                                        Text("老師回覆:",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff555555))),
                                      ],),
                                      Container(
                                          color: Color(0xffEEEEEE),
                                          padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                                          margin: EdgeInsets.only(left:0.w,right: 8.w,top: 0.h,bottom: 0.h),
                                          width:ScreenUtil().screenWidth,child: Form(
                                          child: TextFormField(
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              color: Color(0xff555555),
                                            ),
                                            controller: e.REPLY_textEditingController,
                                            //focusNode: e.REPLY_FocusNode,
                                            //textInputAction: TextInputAction.newline, // ✅ iOS 不要預設為「完成」
                                            scrollPhysics: const NeverScrollableScrollPhysics(), // ✅ 禁止滾動
                                            keyboardType: TextInputType.text,
                                            inputFormatters: [
                                              //RemoveEmojiInputFormatter()
                                            ],
                                            autofocus: false,
                                            maxLines: null,
                                            //obscureText: !_adminVisible,
                                            //obscureText: !_accountVisible,//This will obscure text dynamically
                                            maxLength: 255,
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            //initialValue: 'edu_test010@ncku.com',
                                            //inputFormatters: [EmailLimitFormatter()],
                                            //validator: (value) => validateEmail(value!),
                                            onChanged: (v){
                                              //drug_reason.reason = v;
                                            },
                                            decoration: InputDecoration(
                                              //labelStyle: TextStyle(fontSize: 20.sp,color: Colors.blueAccent),
                                              //labelText: '標題',
                                              filled: true, //<-- SEE HERE
                                              fillColor: Colors.transparent, //<-- SEE HERE
                                              hintText: '',
                                              hintStyle: TextStyle(fontWeight: FontWeight.w400,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
                                              contentPadding:  EdgeInsets.only(left: 5.w,right: 5.w,top: 10.h,bottom: 10.h),
                                              border: OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                                  borderRadius: BorderRadius.circular(0.0.w)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                                  borderRadius: BorderRadius.circular(0.0.w)),
                                              focusedBorder:OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                                  borderRadius: BorderRadius.circular(0.0.w)),
                                              disabledBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                                  borderRadius: BorderRadius.circular(0.0.w)),
                                            ),
                                          ))),
                                      Container(height: 3.h,),
                                      Row(children: [

                                        Expanded(child: Container()),
                                        ElevatedButton(
                                          onPressed: () {
                                            // 按下按鍵要執行的動作

                                            if(e.REPLY_textEditingController.text.isEmpty){
                                              Fluttertoast.showToast(
                                                  msg: "請先輸入文字",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0.sp
                                              );
                                              return;
                                            }

                                            showCupertinoDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CupertinoAlertDialog(
                                                  title: Text('確定送出?',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 16.sp),),
                                                  content: Text('${e.REPLY_textEditingController.text}',textAlign: TextAlign.left,textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 16.sp),),
                                                  actions: <Widget>[
                                                    CupertinoDialogAction(
                                                      child: Text('取消',textScaler:const TextScaler.linear(1),style: TextStyle(fontSize: 16.sp),),
                                                      onPressed: () {
                                                        Navigator.of(context).pop(); // 關閉 dialog
                                                      },
                                                    ),
                                                    CupertinoDialogAction(
                                                      isDestructiveAction: true,
                                                      child: Text('送出',textScaler:const TextScaler.linear(1),style: TextStyle(color: Colors.blue,fontSize: 16.sp),),
                                                      onPressed: () {
                                                        Navigator.of(context).pop(); // 關閉 dialog
                                                        // 執行送出動作
                                                        write_REPLY_to_DAILY_PRS_db_sub(
                                                          NO:e.NO,
                                                          TYPE: e.TYPE,
                                                          REPLY:e.REPLY_textEditingController.text,
                                                          REPLY_USER_NO:EMPLOYEE_teacher.ACCOUNT,
                                                        );

                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8), // 四角圓弧，數值越大越圓
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
                                            backgroundColor: Colors.blue, // 按鈕背景色
                                            foregroundColor: Colors.white, // 文字顏色
                                          ),
                                          child: Text(
                                            '送出',
                                            textScaler: const TextScaler.linear(1),
                                            style: TextStyle(fontSize: 16.sp),
                                          ),
                                        )

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
                                      Container(width: ScreenUtil().screenWidth,height: 200.h,child: Image.network(e.SIGN_LINK),),
                                      Container(height: 5.h,),
                                    ],)),
                              ],)),
                          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                        ]);


                      }).toList(),),

                    ],),
                );
              },
            );
          },
        );
        read_for_DAILY_PRS_db_sub(NO:"${message.data["DAILY_PRS_NO"]}",TYPE:'PRS');
      }
      else if("${message.data["ChatID"]}".contains("家長已回簽通知單")){
        MyHomePage2_T_fun2!(type:"前往家長已回簽通知單",DAILY_NOT_NO:"${message.data["DAILY_NOT_NO"]}",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
      }
      else{

        final chatId = message.data["ChatID"]?.toString() ?? "";

        final isNumeric = int.tryParse(chatId) != null;

        if (isNumeric) {
          dev.log("ChatID 是純數字,前往對應聊天室");
          //檢查聊天室ID
          try{
            ChatPage_T_all_fun3!(ChatID:chatId);
          }
          catch(e){

          }

        } else {
          dev.log("ChatID 不是純數字,不理會");
        }

      }
    }

  }
  Future<void> handleNotification2(RemoteMessage message) async {

    dev.log("2.handleNotification:${message.data}");
    if("${message.data["title"]}".contains("老師")){

      if("${message.data["ChatID"]}".contains("已讀聯絡簿")||
          "${message.data["ChatID"]}".contains("已回覆聯絡簿")||
          "${message.data["ChatID"]}".contains("到校")||
          "${message.data["ChatID"]}".contains("離校")||
          "${message.data["ChatID"]}".contains("電子聯絡簿已完成上傳")
      ){

        MyHomePage2_U_fun2!(
          reflash_db:"前往生活概況",
          ChatID:"${message.data["ChatID"]}",
          TeacherAccount:"${message.data["TeacherAccount"]}",
          UserAccount:"${message.data["TeacherAccount"]}",
        );

      }
      else if("${message.data["ChatID"]}".contains("老師已將請假委託變更為")){
        MyHomePage2_U_fun1!(reflash_db:"EXCUSED");
      }
      pendingMessage = null;

    }
    else{
      if("${message.data["ChatID"]}"=="用藥委託"){
        //MyHomePage2_T_fun2!(type:"前往用藥委託",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
        await read_DRUG_MT_db_sub(DRUG_NO: "${message.data["DRUG_NO"]}");


        navigatorKey.currentState?.push(
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: DRUG_MT_T_page(),
          ),
        );


        /*
        Navigator.push(context, PageTransition(
            type: PageTransitionType.rightToLeft, child: DRUG_MT_T_page()));

         */
        pendingMessage = null;


      }
      else if("${message.data["ChatID"]}"=="用藥委託刪除"){
        //MyHomePage2_T_fun2!(type:"前往用藥委託(刪除)",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
        await read_DRUG_MT_db_sub(DRUG_NO: "${message.data["DRUG_NO"]}");
        navigatorKey.currentState?.push(
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: DRUG_MT_T_page(),
          ),
        );
        /*
          Navigator.push(context, PageTransition(
              type: PageTransitionType.rightToLeft, child: DRUG_MT_T_page()));

           */
        pendingMessage = null;
      }
      else if("${message.data["ChatID"]}"=="接送委託"){
        MyHomePage2_T_fun2!(type:"前往接送委託",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
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
        ENTRUSTED_db_sub(NO:"${message.data["ENTRUSTED_NO"]}");
        pendingMessage = null;

      }
      else if("${message.data["ChatID"]}"=="接送委託刪除"){
        MyHomePage2_T_fun2!(type:"前往接送委託(刪除)",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
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
        ENTRUSTED_db_sub(NO:"${message.data["ENTRUSTED_NO"]}");
        pendingMessage = null;
      }
      else if("${message.data["ChatID"]}"=="請假委託"){
        MyHomePage2_T_fun2!(type:"前往請假委託",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
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
        await EXCUSED_db_sub(NO:"${message.data["EXCUSED_NO"]}");
        pendingMessage = null;
      }
      else if("${message.data["ChatID"]}"=="請假委託刪除"){
        MyHomePage2_T_fun2!(type:"前往請假委託(刪除)",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
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
        await EXCUSED_db_sub(NO:"${message.data["EXCUSED_NO"]}");
        pendingMessage = null;
      }
      else if("${message.data["ChatID"]}".contains("聯絡簿回簽有備註")){
        MyHomePage2_T_fun2!(type:"前往聯絡簿回簽有備註",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
        DAILY_PRSs.clear();
        showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                showDialog_setState = setState;

                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero), // 取消圓角
                  backgroundColor: Colors.white,
                  insetPadding: EdgeInsets.all(0),
                  child: DAILY_PRSs.length==0?
                  ListView(
                    padding: EdgeInsets.all(10),
                    children: [
                      Row(children: [
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.transparent,size: 30.sp,),
                          onPressed: (){},
                        ),
                        Expanded(child: Center(child:Text("聯絡簿",style: TextStyle(
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
                      Text("此聯絡簿不存在",textAlign: TextAlign.center,style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          color: Color(0xff555555)))
                    ],)
                      :
                  ListView(
                    padding: EdgeInsets.all(10),
                    children: [

                      Column(children: DAILY_PRSs.map((e){

                        //學校(DEPM)
                        DEPM _DEPM = DEPM();
                        CLASS _CLASS = CLASS();
                        try {
                          _DEPM = dEPMs.firstWhere((element) =>
                          element.DEPM_NO == e.DEPM_NO);
                          _CLASS = cLASSs.firstWhere((element) =>
                          element.CLASS_NO == e.CLASS_NO);
                        }
                        catch(e){

                        }

                        String student_name = "";
                        for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
                          if(e.CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO){
                            student_name = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NM;
                            break;
                          }
                        }

                        return Column(children: [

                          Row(children: [
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.transparent,size: 30.sp,),
                              onPressed: (){},
                            ),
                            Expanded(child: Center(child:Text("聯絡簿",style: TextStyle(
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
                            Text("${student_name}\n(${e.DateStr})",textScaler: TextScaler.linear(1),style: TextStyle(
                                fontFamily: "GenJyuuGothic",
                                fontWeight: FontWeight.w700,
                                color: Colors.red , fontSize: 20.sp),),
                          ],),
                          Container(
                              width: ScreenUtil().screenWidth,
                              //height: 55.w,
                              //margin: EdgeInsets.only(bottom: 8.h),
                              padding: EdgeInsets.all(5.w),
                              decoration: BoxDecoration(
                                color: Color(0xfffff6dc),
                                borderRadius: BorderRadius.circular(0.w),
                              ),
                              child:Column(children: [
                                GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap:(){
                                      //e.REPLY_FocusNode.unfocus();
                                    },
                                    child: Column(children: [
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
                                        Text("${e.NOTE}",
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

                                      Container(height: 5.h,),
                                      Row(children: [
                                        Text("老師回覆:",
                                            maxLines: null,
                                            style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff555555))),
                                      ],),
                                      Container(
                                          color: Color(0xffEEEEEE),
                                          padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                                          margin: EdgeInsets.only(left:0.w,right: 8.w,top: 0.h,bottom: 0.h),
                                          width:ScreenUtil().screenWidth,child: Form(
                                          child: TextFormField(
                                            style: TextStyle(
                                              fontSize: 20.sp,
                                              color: Color(0xff555555),
                                            ),
                                            controller: e.REPLY_textEditingController,
                                            //focusNode: e.REPLY_FocusNode,
                                            //textInputAction: TextInputAction.newline, // ✅ iOS 不要預設為「完成」
                                            scrollPhysics: const NeverScrollableScrollPhysics(), // ✅ 禁止滾動
                                            keyboardType: TextInputType.text,
                                            inputFormatters: [
                                              //RemoveEmojiInputFormatter()
                                            ],
                                            autofocus: false,
                                            maxLines: null,
                                            //obscureText: !_adminVisible,
                                            //obscureText: !_accountVisible,//This will obscure text dynamically
                                            maxLength: 255,
                                            autovalidateMode: AutovalidateMode.onUserInteraction,
                                            //initialValue: 'edu_test010@ncku.com',
                                            //inputFormatters: [EmailLimitFormatter()],
                                            //validator: (value) => validateEmail(value!),
                                            onChanged: (v){
                                              //drug_reason.reason = v;
                                            },
                                            decoration: InputDecoration(
                                              //labelStyle: TextStyle(fontSize: 20.sp,color: Colors.blueAccent),
                                              //labelText: '標題',
                                              filled: true, //<-- SEE HERE
                                              fillColor: Colors.transparent, //<-- SEE HERE
                                              hintText: '',
                                              hintStyle: TextStyle(fontWeight: FontWeight.w400,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
                                              contentPadding:  EdgeInsets.only(left: 5.w,right: 5.w,top: 10.h,bottom: 10.h),
                                              border: OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                                  borderRadius: BorderRadius.circular(0.0.w)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                                  borderRadius: BorderRadius.circular(0.0.w)),
                                              focusedBorder:OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                                  borderRadius: BorderRadius.circular(0.0.w)),
                                              disabledBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
                                                  borderRadius: BorderRadius.circular(0.0.w)),
                                            ),
                                          ))),
                                      Container(height: 3.h,),
                                      Row(children: [

                                        Expanded(child: Container()),
                                        ElevatedButton(
                                          onPressed: () {
                                            // 按下按鍵要執行的動作

                                            if(e.REPLY_textEditingController.text.isEmpty){
                                              Fluttertoast.showToast(
                                                  msg: "請先輸入文字",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.red,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0.sp
                                              );
                                              return;
                                            }

                                            showCupertinoDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CupertinoAlertDialog(
                                                  title: Text('確定送出?',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 16.sp),),
                                                  content: Text('${e.REPLY_textEditingController.text}',textAlign: TextAlign.left,textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 16.sp),),
                                                  actions: <Widget>[
                                                    CupertinoDialogAction(
                                                      child: Text('取消',textScaler:const TextScaler.linear(1),style: TextStyle(fontSize: 16.sp),),
                                                      onPressed: () {
                                                        Navigator.of(context).pop(); // 關閉 dialog
                                                      },
                                                    ),
                                                    CupertinoDialogAction(
                                                      isDestructiveAction: true,
                                                      child: Text('送出',textScaler:const TextScaler.linear(1),style: TextStyle(color: Colors.blue,fontSize: 16.sp),),
                                                      onPressed: () {
                                                        Navigator.of(context).pop(); // 關閉 dialog
                                                        // 執行送出動作
                                                        write_REPLY_to_DAILY_PRS_db_sub(
                                                          NO:e.NO,
                                                          TYPE: e.TYPE,
                                                          REPLY:e.REPLY_textEditingController.text,
                                                          REPLY_USER_NO:EMPLOYEE_teacher.ACCOUNT,
                                                        );

                                                      },
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8), // 四角圓弧，數值越大越圓
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
                                            backgroundColor: Colors.blue, // 按鈕背景色
                                            foregroundColor: Colors.white, // 文字顏色
                                          ),
                                          child: Text(
                                            '送出',
                                            textScaler: const TextScaler.linear(1),
                                            style: TextStyle(fontSize: 16.sp),
                                          ),
                                        )

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
                                      Container(width: ScreenUtil().screenWidth,height: 200.h,child: Image.network(e.SIGN_LINK),),
                                      Container(height: 5.h,),
                                    ],)),
                              ],)),
                          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                        ]);


                      }).toList(),),

                    ],),
                );
              },
            );
          },
        );
        read_for_DAILY_PRS_db_sub(NO:"${message.data["DAILY_PRS_NO"]}",TYPE:'PRS');
        pendingMessage = null;
      }
      else if("${message.data["ChatID"]}".contains("家長已回簽通知單")){
        MyHomePage2_T_fun2!(type:"前往家長已回簽通知單",DAILY_NOT_NO:"${message.data["DAILY_NOT_NO"]}",CS_NO:"${message.data["CS_NO"]}",DATE:"${message.data["DATE"]}");
        pendingMessage = null;
      }
      else{


        final chatId = message.data["ChatID"]?.toString() ?? "";

        final isNumeric = int.tryParse(chatId) != null;

        if (isNumeric) {
          dev.log("ChatID 是純數字,前往對應聊天室");
          //檢查聊天室ID
          try{
            if(ChatPage_T_all_init_finish == false){
              //如果聊天室還在初始化,pendingMessage就賦予一個值給畫面繼續顯示推播打開中
              pendingMessage = RemoteMessage();
              MyHomePage2_T_fun3!();
            }
            else{
              pendingMessage = null;
            }

            ChatPage_T_all_fun3!(ChatID:chatId);
          }
          catch(e){

          }

        } else {
          dev.log("ChatID 不是純數字,不理會");
        }

      }
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

      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
        if(CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO){
          for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;j++){
            String FCM = await search_CUSTOMER_DL_fcm_sub(ACCOUNT:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].cUSTOMER_DLs[j]!.ACCOUNT);
            await sendPushNotification(
                title: "老師",
                message: "老師已將請假委託變更為${eXCUSED.CFM_ITEM_selectedValue.CFM_NM}",
                token: FCM,//EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[sel_chat_index].cUSTOMER_DLs[i]!.FCM,
                ChatID:"老師已將請假委託變更為${eXCUSED.CFM_ITEM_selectedValue.CFM_NM}",
                UserAccount: '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].cUSTOMER_DLs[j]!.ACCOUNT}',
                TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}",
                CS_NO:CS_NO,
                CFM_NO:CFM_NO,
                EXCUSED_NO:NO
            );
          }

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



  Future<void> ENTRUSTED_db_sub({String NO=""})async{
    //dev.log("SELECT * FROM ENTRUSTED WHERE NO='${NO}'");
    String result = await sql_command("SELECT * FROM ENTRUSTED WHERE NO='${NO}'");
    SmartDialog.dismiss();
    try{
      //dev.log("result:${result}");
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

  Future<void> EXCUSED_db_sub({String NO=""})async{

    String result = await sql_command("SELECT * FROM EXCUSED WHERE NO='${NO}'");
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
          eXCUSED = b;
        }
      }

      showDialog_setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }
  }


  void fcm_init()async{



    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );



    FirebaseMessaging.instance.getInitialMessage().then(
          (value) async{

            /*
            Fluttertoast.showToast(
                msg: "value:${value!.data}",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );

             */

            SharedPreferences prefs = await SharedPreferences.getInstance();
            String is_login = prefs.getString('is_login')??"";
            if(is_login=="true"){
              pendingMessage ??= value;


              if (pendingMessage != null) {


                int retry = 0;
                const maxRetry = 30;
                Timer.periodic(Duration(seconds: 1), (timer) async{
                  retry++;

                  if (is_finish_load==true) {
                    timer.cancel();
                    await handleNotification2(pendingMessage!);
                  }

                  if (retry >= maxRetry) {
                    timer.cancel();
                    dev.log("navigatorKey 仍然為 null，放棄處理推播訊息");
                  }
                });



              }
            }

            /*
            try {
              _resolved = true;
              initialMessage = value!.data.toString();
              dev.log(initialMessage);
            }
            catch(e){

            }

             */

          }
    );

    FirebaseMessaging.onMessage.listen(showFlutterNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async{
      // 點擊通知時清除徽章
      dev.log("點擊通知時清除徽章");
      // Remove badge
      AppBadgePlus.updateBadge(0);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String is_login = prefs.getString('is_login')??"";
      if(is_login=="true"){

        dev.log("onMessageOpenedApp:${message.data}");
        pendingMessage = message;
        if (pendingMessage != null) {
          await handleNotification(pendingMessage!);
          pendingMessage = null;
        }
      }

    });


    try {
      _token = await FirebaseMessaging.instance.getToken() ?? "";
    }
    catch(e){
      dev.log("FirebaseMessaging token:${_token}");
    }


    // subscribe to topic on each app start-up

    //FirebaseMessaging.instance.subscribeToTopic((Platform.isAndroid)?'cateringservice-fcm-android':'cateringservice-fcm-ios');
    //FirebaseMessaging.instance.unsubscribeFromTopic(topic)
  }

  void init()async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _admin_TextEditingController.text = prefs.getString('admin')??"";
    _password_TextEditingController.text = prefs.getString('pass')??"";
    if(_admin_TextEditingController.text.isNotEmpty){
      checkbox1=true;
    }

    String is_login = prefs.getString('is_login')??"";
    if(is_login=="true"){
      login_db_sub2(admin:"${_admin_TextEditingController.text}",pass:"${_password_TextEditingController.text}");
    }
    else{
      page=1;
      check_app_version_sub();
      checkShouldShowDialog(context: context);
    }
    setState(() {

    });
  }

  void init_isTablet_sub(BuildContext context)async{
    iPad = await isTablet(context);
  }



  @override
  Widget build(BuildContext context) {

    _context = context;

    init_isTablet_sub(context);


    setAdaptiveSystemUI(context);

    //_incrementCounter();

    //dev.log("width:${MediaQuery.of(context).size.width}");
    //dev.log("height:${MediaQuery.of(context).size.height}");
    //dev.log("width:${ScreenUtil().screenWidth}");
    //dev.log("height:${ScreenUtil().screenHeight}");

    final _admin = Form(
        child: TextFormField(
          style: TextStyle(
              fontSize: 18.sp,
              color: Color(0xff555555),
          ),
          controller: _admin_TextEditingController,
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
            hintText: '請輸入...',
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
        ));
    final _pass = Form(
        child: TextFormField(
          style: TextStyle(
              fontSize: 18.sp,
              color: Color(0xff555555),
          ),
          controller: _password_TextEditingController,
          keyboardType: TextInputType.text,
          autofocus: false,
          obscureText: !_passVisible,//This will obscure text dynamically
          //maxLength: 50,
          inputFormatters: [
            //RemoveEmojiInputFormatter()
          ],
          autovalidateMode: AutovalidateMode.onUserInteraction,
          //initialValue: 'edu_test010@ncku.com',
          //inputFormatters: [EmailLimitFormatter()],
          //validator: (value) => validateEmail(value!),
          decoration: InputDecoration(
            filled: true, //<-- SEE HERE
            fillColor: Colors.transparent, //<-- SEE HERE
            hintText: '請輸入...',
            hintStyle: TextStyle(fontWeight: FontWeight.bold,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
            contentPadding:  EdgeInsets.only(left: 0,right: 0),

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
        ));



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
          /*
          floatingActionButton: Stack(
              children: <Widget>[
                // 第一個 FAB（例如：Start / Stop）
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      _startService();
                    },
                    tooltip: 'Start/Stop Service',
                    child: Icon(Icons.play_arrow),
                  ),
                ),

                // 第二個 FAB（例如：做其他事）
                Positioned(
                  bottom: 80, // 與第一個按鈕垂直間隔
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: () {
                      _stopService();
                    },
                    tooltip: '其他功能',
                    child: Icon(Icons.settings),
                  ),
                ),
              ]),

           */
          body:
    //page 0
          (page==0)?
          Container(width: ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
          child:Image.network("${IMAGE_IP}/images/Cover.gif",fit: BoxFit.cover,))
          :
          ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              Container(padding: EdgeInsets.only(left:0.w,right: 0.w),width: ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
                  color: Color(0xffF8F8F8),
                  child:PageView(
                    controller: pageController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [

                      Container(width: ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,child:
                      Stack(children: [

                        Column(children: [

                          Expanded(flex:1,child: Container(padding: EdgeInsets.all(40.w),child:Image.asset("assets/images/Wilson_0.png"))),
                          Expanded(flex:2,child: Container(
                              padding: EdgeInsets.only(top: 20.h,left:44.w,right: 44.w,bottom: 20.h),
                              decoration: BoxDecoration(
                                color: Color(0xffF9AA88),
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(18.w) ,topRight: Radius.circular(18.w)),
                                border: Border.all(
                                  width: 1,
                                  color: Colors.black,
                                ),
                              ),
                              child:Column(children: [


                                Expanded(child:Container()),
                                //帳號
                                Container(width: ScreenUtil().screenWidth,child: Column(children: [
                                  Container(padding: EdgeInsets.only(left: 16.w),width: ScreenUtil().screenWidth,child:Text("帳號",textScaler: TextScaler.linear(1.0),style: TextStyle(color: Color(0xff555555),fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,fontSize: 22.sp))),
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
                                        _admin,
                                        Expanded(child: Container()),

                                      ],)
                                  )
                                ],)),
                                Container(height: 10.h,),

                                //密碼
                                Container(width: ScreenUtil().screenWidth,child: Column(children: [
                                  Container(padding: EdgeInsets.only(left: 16.w),width: ScreenUtil().screenWidth,child:Text("密碼",textScaler: TextScaler.linear(1.0),style: TextStyle(color: Color(0xff555555),fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,fontSize: 22.sp))),
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
                                        _pass,
                                        Expanded(child: Container()),

                                      ],)
                                  )
                                ],)),

                                Container(height: 20.h,),
                                Row(children: [
                                  Container(width: 5.w,),
                                  Container(
                                      width:20.w,
                                      height: 20.w,
                                      child: Checkbox(
                                          checkColor: Colors.white,
                                          value: checkbox1, onChanged: (v){
                                        checkbox1=v!;
                                        setState(() {

                                        });
                                      })),
                                  Container(width: 5.w,),
                                  Text("記住密碼",
                                    style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                        color: Color(0xff292929)),),
                                ],),
                                Container(height: 20.h,),
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

                                        FocusScope.of(context).unfocus();

                                        if(_admin_TextEditingController.text.isEmpty){
                                          SmartDialog.showToast("請輸入帳號");
                                          return;
                                        }

                                        if(_password_TextEditingController.text.isEmpty){
                                          SmartDialog.showToast("請輸入密碼");
                                          return;
                                        }

                                        login_db_sub(admin:"${_admin_TextEditingController.text}",pass:"${_password_TextEditingController.text}");
                                        //Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: MyHomePage2()));
                                        //page=1;
                                        //pageController!.animateToPage(page, duration: Duration(milliseconds: 200), curve: Curves.ease);

                                      },
                                      child: Row(children: [
                                        Expanded(child: Container()),
                                        Text('登 入', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                                        Expanded(child: Container()),
                                      ],),
                                    )),
                                Row(children: [


                                  /*
                                  Expanded(child:Container()),
                                  Container(
                                      width: 135.w,
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

                                          FocusScope.of(context).unfocus();
                                          //page=2;
                                          //pageController!.animateToPage(page, duration: Duration(milliseconds: 200), curve: Curves.ease);


                                        },
                                        child: Row(children: [
                                          Expanded(child: Container()),
                                          Text('註 冊', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                                          Expanded(child: Container()),
                                        ],),
                                      )),

                                   */

                                ],),
                                /*
                                Expanded(flex:1,child:Container()),
                                Text("忘記密碼?",
                                  style: TextStyle(
                                      fontFamily: "GenJyuuGothic",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.sp,
                                      color: Color(0xff292929)),),
                                Expanded(flex:1,child:Container()),
                                Row(children: [

                                  Expanded(child: Container()),
                                  (Platform.isIOS)?
                                  Container(width: 43.w,height: 43.w,child:
                                  SvgPicture.asset(
                                      "assets/images/组件 71 – 4.svg",
                                      semanticsLabel: 'Acme Logo'
                                  )):Container(),
                                  (Platform.isIOS)?
                                  Expanded(child: Container()):Container(),
                                  Container(width: 43.w,height: 43.w,child:
                                  SvgPicture.asset(
                                      "assets/images/组件 69 – 1.svg",
                                      semanticsLabel: 'Acme Logo'
                                  )),
                                  Expanded(child: Container()),
                                  Container(width: 43.w,height: 43.w,child:
                                  SvgPicture.asset(
                                      "assets/images/组件 70 – 1.svg",
                                      semanticsLabel: 'Acme Logo'
                                  )),
                                  Expanded(child: Container()),
                                  Container(width: 43.w,height: 43.w,child:
                                  SvgPicture.asset(
                                      "assets/images/组件 68 – 1.svg",
                                      semanticsLabel: 'Acme Logo'
                                  )),
                                  Expanded(child: Container()),

                                ],),

                                 */
                                Expanded(child:Container(child: Column(children: [

                                  Expanded(child: Container(),),
                                  Text("${packageInfo.version}",style: TextStyle(
                                      fontFamily: "GenJyuuGothic",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      color: Color(0xff292929))),
                                  Container(height: 5.h,)

                                ],),)),
                                Expanded(child:Container()),

                              ],))),

                        ],),


                        Column(children: [

                          Expanded(child: Container(width: ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,child: Column(children: [

                            Expanded(child: Stack(children: [

                              /*
                              Positioned(
                                  right: 5.w, // distance between this child's left edge & left edge of stack
                                  top: 20.h, // distance between this child's top edge & top edge of stack
                                  child:
                                  Container(child: SvgPicture.asset(
                                      "assets/images/组 29146.svg",
                                      semanticsLabel: 'Acme Logo'
                                  ),))

                               */

                            ],)),
                            Expanded(child: Stack(children: [

                              Positioned(
                                  left: 20.w, // distance between this child's left edge & left edge of stack
                                  top: 20.h, // distance between this child's top edge & top edge of stack
                                  child:Container(child: SvgPicture.asset(
                                      "assets/images/组 29137.svg",
                                      semanticsLabel: 'Acme Logo'
                                  ),))

                            ],)),

                          ],),)),
                          Expanded(child: Container()),

                        ],),



                      ],)),


                    ],)
              ),
            ],),
    )));
  }
}
