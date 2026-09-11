import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:code3/main2_T.dart';
import 'package:code3/signature2.dart';
import 'package:code3/signature4.dart';
import 'package:code3/student_T.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'package:signature/signature.dart';
import 'dart:developer' as dev;
import 'api.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'package:badges/badges.dart' as badges;
import 'package:image_picker/image_picker.dart' as ImagePicker;

class Jiebao_Phone_page extends StatefulWidget {

  @override
  State<Jiebao_Phone_page> createState() => Jiebao_Phone_pageState();
}

class Jiebao_Phone_pageState extends State<Jiebao_Phone_page> {


  int sel_minute = -1;
  List<CALL> CALL_list = [];
  Timer? timer;
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

    timer = Timer.periodic(Duration(seconds: 3), (Timer t) async{
      if (_isRunning) return; // 正在跑，直接跳過
      if(page_notify_menu5 == "接寶Phone" && page=="委託"){
        _isRunning = true;
        try {
          await read_CALL_db_sub();
        } finally {
          _isRunning = false;
        }
      }

    });
    read_CALL_db_sub();

  }

  @override
  void destory(){
    if(timer!=null){
      timer!.cancel();
      timer=null;
    }
    super.dispose();
  }

  /*

   */
  Future<void> read_CALL_db_sub()async{



    // 動態組出 OR 條件
    String whereClause = cUSTOMERs.map((c) =>
    "(DEPM_NO = '${c.DEPM_NO}' AND CLASS_NO = '${c.CLASS_NO}' AND CS_NO = '${c.CS_NO}')"
    ).join(" OR ");

    // 組 SQL
    String sql = '''
  SELECT * 
  FROM CALL 
  WHERE ($whereClause)
    AND CONVERT(DATE, DATE_TIME) = CONVERT(DATE, GETDATE())
  ORDER BY DATE_TIME ASC;
''';

// 執行查詢
    String result = await sql_command(sql);
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
        List<CALL> _CALL_list = [];
        for(int i=0;i<data_list.length;i++){
          CALL b = CALL();
          b.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
          b.DATE_TIME = "${data_list[i]["DATE_TIME"]}".contains("null")?"":"${data_list[i]["DATE_TIME"]}";
          b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
          b.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}";
          b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}";
          b.ACCOUNT = "${data_list[i]["ACCOUNT"]}".contains("null")?"":"${data_list[i]["ACCOUNT"]}";
          b.MINUTE = "${data_list[i]["MINUTE"]}".contains("null")?"":"${data_list[i]["MINUTE"]}";
          //b.ARRIVAL_TIME = "${data_list[i]["ARRIVAL_TIME"]}".contains("null")?null:DateTime.parse("${data_list[i]["ARRIVAL_TIME"]}");
          b.COMPLETE = data_list[i]["COMPLETE"];
          _CALL_list.add(b);
        }

        _CALL_list.sort((a,b) => b.DATE_TIME.compareTo(a.DATE_TIME));
        CALL_list = _CALL_list;
        setState(() {

        });

      }
    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("網路異常");
    }
  }


  /*
  上傳新一筆接寶
   */
  Future<void> add_CALL_db_sub()async{

    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 300), () {});
    DateTime dateTime = DateTime.now();
    String comm = '''
DECLARE @dateTime DATETIME = '${DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)}';
DECLARE @depmNo NCHAR(4) = N'${CUSTOMER_selectedValue.DEPM_NO}';
DECLARE @classNo NCHAR(10) = N'${CUSTOMER_selectedValue.CLASS_NO}';
DECLARE @csNo NCHAR(10) = N'${CUSTOMER_selectedValue.CS_NO}';
DECLARE @minute CHAR(2) = '${sel_minute}';
DECLARE @account NCHAR(12) = N'${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT}';
DECLARE @complete BIT = 0;

DECLARE @todayDate CHAR(6) = CONVERT(CHAR(6), GETDATE(), 12);

BEGIN TRANSACTION;

-- 如果當天有該條件的紀錄且 COMPLETE = 0，直接更新
IF EXISTS (
    SELECT 1
    FROM CALL WITH (UPDLOCK, HOLDLOCK)
    WHERE DEPM_NO = @depmNo
      AND CLASS_NO = @classNo
      AND CS_NO = @csNo
      AND NO LIKE @todayDate + '%'
      AND COMPLETE = 0
)
BEGIN
    UPDATE CALL
    SET DATE_TIME = @dateTime,
        MINUTE = @minute,
        ACCOUNT = @account,
        COMPLETE = @complete
    WHERE DEPM_NO = @depmNo
      AND CLASS_NO = @classNo
      AND CS_NO = @csNo
      AND NO LIKE @todayDate + '%'
      AND COMPLETE = 0;
END
ELSE
BEGIN
    -- 產生新單號
    DECLARE @maxSerial INT = (
        SELECT MAX(CAST(SUBSTRING(NO, 7, 6) AS INT))
        FROM CALL WITH (UPDLOCK, HOLDLOCK)
        WHERE NO LIKE @todayDate + '%'
    );

    SET @maxSerial = ISNULL(@maxSerial, 0);
    DECLARE @nextSerial INT = @maxSerial + 1;

    DECLARE @newNo NCHAR(12) = @todayDate + RIGHT('000000' + CAST(@nextSerial AS VARCHAR(6)), 6);

    INSERT INTO CALL (NO, DATE_TIME, DEPM_NO, CLASS_NO, CS_NO, MINUTE, ACCOUNT, COMPLETE)
    VALUES (
      @newNo,
      @dateTime,
      @depmNo,
      @classNo,
      @csNo,
      @minute,
      @account,
      @complete
    );
END

COMMIT;
''';


    dev.log("${comm}");
    String result = await sql_command("${comm}");
    dev.log("上傳新一筆接寶:${result}");
    try{
      dynamic map = jsonDecode(result);
      if("${map["message"]}".contains("執行成功")){
        sel_minute=-1;
        SmartDialog.dismiss();
        SmartDialog.showToast("送出成功");
        setState(() {

        });
      }
      else{
        SmartDialog.dismiss();
        SmartDialog.showToast("送出失敗");
      }
    }
    catch(e){
      dev.log("上傳新一筆接寶err:${e}");
      SmartDialog.dismiss();
      SmartDialog.showToast("送出失敗");
    }

    /*
    int CALL_NO_num = await read_CALL_db_sub();
    dev.log("CALL_NO_num:${CALL_NO_num}");
    if(CALL_NO_num==-1){
      SmartDialog.showToast("read_CALL_db_sub error");
      return;
    }

    DateTime dateTime = DateTime.now();
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 300), () {});
    CALL_NO_num+=1;
    String CALL_NO = "${DateFormat('yyyyMMdd').format(dateTime)}${CALL_NO_num.toString().padLeft(6,"0")}";
    CALL_NO = CALL_NO.substring(2,CALL_NO.length);
    dev.log("CALL_NO:${CALL_NO}");


    bool check = await insert_CALL_db_sub(
      NO:CALL_NO,//編號
      DATE_TIME:"${DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)}",//日期
      DEPM_NO:"${CUSTOMER_selectedValue.DEPM_NO}",//學校
      CLASS_NO:"${CUSTOMER_selectedValue.CLASS_NO}",//班級
      CS_NO:"${CUSTOMER_selectedValue.CS_NO}",//學生身分證字號
      MINUTE:"${sel_minute}",//接送時間
      ACCOUNT:"${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT}",//家長發送者
      COMPLETE:false,//播放完成
    );

    if(check==false){
      SmartDialog.dismiss();
      SmartDialog.showToast("忙碌中，請重試");
      return;
    }

     */




  }


  Future<bool> insert_CALL_db_sub(
      {
        String NO="",//編號
        String DATE_TIME="",//日期
        String DEPM_NO="",//學校編號
        String CLASS_NO="",//班級編號
        String CS_NO="",//學生編號
        String MINUTE="",//
        String ACCOUNT="",//
        bool COMPLETE=false,//
      })async{

    String comm = "INSERT INTO CALL(NO,DATE_TIME,DEPM_NO,CLASS_NO,CS_NO,MINUTE,ACCOUNT,COMPLETE) VALUES ('${NO}','${DATE_TIME}','${DEPM_NO}','${CLASS_NO}','${CS_NO}','${MINUTE}','${ACCOUNT}','${COMPLETE}')";
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

  /// 顯示「發生異常，請重新嘗試」的 Dialog
  Future<void> showRetryDialog(
      BuildContext context, {
        String title = '發生異常',
        String message = '發生異常，請重新嘗試',
        VoidCallback? onRetry,
        bool barrierDismissible = false, // 點遮罩是否可關閉
      }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white, // 白底
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r), // 圓角
          ),
          titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
          contentPadding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          title: Row(
            children: [
              // 圓形 icon 背景
              Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(6.w),
                child: Icon(
                  Icons.error_outline, // 可換成 Icons.warning_amber_rounded
                  color: Colors.red,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  textScaleFactor: 1.0,
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textScaleFactor: 1.0,
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                '確定',
                textScaleFactor: 1.0,
                style: TextStyle(fontSize: 18.sp, color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(children: [

      Expanded(child: Container()),
      Container(
          margin: EdgeInsets.only( left:20.w,right: 20.w),
          padding: EdgeInsets.only(left:15.w),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.w),
              border: Border.all(
                width: 1,
                color: Color(0xff555555),
              )),
          width: ScreenUtil().screenWidth,
          height: 48.h,
          child:
          DropdownButtonHideUnderline(
            child: DropdownButton2<CUSTOMER>(
              isExpanded: true,
              items: cUSTOMERs
                  .map((CUSTOMER item) => DropdownMenuItem<CUSTOMER>(
                value: item,
                child: Center(child:Text(
                  item.CS_NM,
                  style: TextStyle(
                    fontSize: (iPad)?18.sp:20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff555555),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )))
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

      Expanded(child: Container()),
      Container(
          margin: EdgeInsets.only( left:20.w,right: 20.w),
          padding: EdgeInsets.only( left:0.w,right: 0.w),
          width: ScreenUtil().screenWidth,
          height: 55.h,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all((sel_minute==0)?Color(0xff5fd3ca):Colors.white),
                surfaceTintColor: MaterialStateProperty.all((sel_minute==0)?Color(0xff5fd3ca):Colors.white),
                padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.w),
                        side: BorderSide(color: Color(0xff555555))
                    )
                )
            ),
            onPressed: () async{

              sel_minute=0;
              setState(() {

              });

            },
            child: Row(children: [
              Expanded(child: Container()),
              Text('已到達', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              Expanded(child: Container()),
            ],),
          )),

      Expanded(child: Container()),
      Container(
          margin: EdgeInsets.only( left:20.w,right: 20.w),
          padding: EdgeInsets.only( left:0.w,right: 0.w),
          width: ScreenUtil().screenWidth,
          height: 55.h,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all((sel_minute==5)?Color(0xff5fd3ca):Colors.white),
                surfaceTintColor: MaterialStateProperty.all((sel_minute==5)?Color(0xff5fd3ca):Colors.white),
                padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.w),
                        side: BorderSide(color: Color(0xff555555))
                    )
                )
            ),
            onPressed: () async{

              sel_minute=5;
              setState(() {

              });

            },
            child: Row(children: [
              Expanded(child: Container()),
              Text('5分鐘內抵達', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              Expanded(child: Container()),
            ],),
          )),
      Expanded(child: Container()),

      Container(
          margin: EdgeInsets.only( left:20.w,right: 20.w),
          padding: EdgeInsets.only( left:0.w,right: 0.w),
          width: ScreenUtil().screenWidth,
          height: 55.h,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all((sel_minute==10)?Color(0xff5fd3ca):Colors.white),
                surfaceTintColor: MaterialStateProperty.all((sel_minute==10)?Color(0xff5fd3ca):Colors.white),
                padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.w),
                        side: BorderSide(color: Color(0xff555555))
                    )
                )
            ),
            onPressed: () async{

              sel_minute=10;
              setState(() {

              });

            },
            child: Row(children: [
              Expanded(child: Container()),
              Text('10分鐘內抵達', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              Expanded(child: Container()),
            ],),
          )),
      Expanded(child: Container()),

      Container(width: ScreenUtil().screenWidth,child: Row(children: [

        Expanded(child: Center(child:Text('廣播紀錄', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 16.sp)),)),
        Expanded(child: Center(child:Text('預計到達時間', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 16.sp)))),
        Expanded(child: Center(child:Text('狀態', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 16.sp)))),

      ],),),
      Container(height: 3.h,),
      Container(margin: EdgeInsets.only(left:15.w,right: 15.w),width: ScreenUtil().screenWidth,height: 1,color: Colors.black54,),
      Container(height: 3.h,),
      Expanded(flex: 10,child:
      Container(width: ScreenUtil().screenWidth,child:ListView.builder(
          itemCount: CALL_list.length,
          padding: EdgeInsets.zero,
          shrinkWrap: true,
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

              Container(color: Colors.transparent,child: Row(children: [
                Expanded(flex:1,child:Center(child:Text("${_CUSTOMER.CS_NM}",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 17.sp,color: Colors.black)))),
                Expanded(flex:1,child:Center(child:Text("${(CALL_list[index].MINUTE=="0")?"已到達":"${CALL_list[index].MINUTE}分內"}",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 17.sp,color: Colors.black)))),
                (is_COMPLETE==true)?
                Expanded(flex:1,child:Center(child:Text("完成",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 15.sp,color: Colors.green))))
                    :
                Expanded(flex:1,child:Center(child:Text("未播報",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 15.sp,color: Colors.red)))),
              ],)),
              Container(height: 5.h,),
              Container(
                margin: EdgeInsets.only(left:10.w,right: 10.w),
                width: ScreenUtil().screenWidth,height: 1,color: Colors.black26,),
              Container(height: 5.h,),

            ],);

      }))),

      /*
      Container(
          margin: EdgeInsets.only( left:20.w,right: 20.w),
          padding: EdgeInsets.only( left:0.w,right: 0.w),
          width: ScreenUtil().screenWidth,
          height: 55.h,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all((sel_minute==15)?Color(0xff5fd3ca):Colors.white),
                surfaceTintColor: MaterialStateProperty.all((sel_minute==15)?Color(0xff5fd3ca):Colors.white),
                padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.w),
                        side: BorderSide(color: Color(0xff555555))
                    )
                )
            ),
            onPressed: () async{

              sel_minute=15;
              setState(() {

              });

            },
            child: Row(children: [
              Expanded(child: Container()),
              Text('15分鐘內抵達', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              Expanded(child: Container()),
            ],),
          )),
      Expanded(child: Container()),

      Container(
          margin: EdgeInsets.only( left:20.w,right: 20.w),
          padding: EdgeInsets.only( left:0.w,right: 0.w),
          width: ScreenUtil().screenWidth,
          height: 55.h,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all((sel_minute==30)?Color(0xff5fd3ca):Colors.white),
                surfaceTintColor: MaterialStateProperty.all((sel_minute==30)?Color(0xff5fd3ca):Colors.white),
                padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.w),
                        side: BorderSide(color: Color(0xff555555))
                    )
                )
            ),
            onPressed: () async{

              sel_minute=30;
              setState(() {

              });

            },
            child: Row(children: [
              Expanded(child: Container()),
              Text('30分鐘內抵達', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              Expanded(child: Container()),
            ],),
          )),
      Expanded(child: Container()),

       */

      /*
      取消 60分鐘
      Container(
          margin: EdgeInsets.only( left:20.w,right: 20.w),
          padding: EdgeInsets.only( left:0.w,right: 0.w),
          width: ScreenUtil().screenWidth,
          height: 55.h,
          child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all((sel_minute==60)?Color(0xff5fd3ca):Colors.white),
                surfaceTintColor: MaterialStateProperty.all((sel_minute==60)?Color(0xff5fd3ca):Colors.white),
                padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.w),
                        side: BorderSide(color: Color(0xff555555))
                    )
                )
            ),
            onPressed: () async{

              sel_minute=60;
              setState(() {

              });

            },
            child: Row(children: [
              Expanded(child: Container()),
              Text('60分鐘內抵達', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              Expanded(child: Container()),
            ],),
          )),

       */
      Expanded(flex:1,child: Container()),

      Container(
          margin: EdgeInsets.only( left:20.w,right: 20.w),
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


              try{

                //先檢查該校使用時間才可送出
                String comm = "SELECT * FROM AVAILABILITY_TIME_SETTING WHERE DEPM_NO = '${CUSTOMER_selectedValue.DEPM_NO}'";
                dev.log("${comm}");

                String result = await sql_command("${comm}");
                dev.log("result:${result}");
                //[{"DEPM_NO":"4101","START_TIME":"07:00:00","END_TIME":"21:00:00","GOHOME_START_TIME":"16:00:00.0000000","GOHOME_END_TIME":"18:00:00.0000000"}]
                List<dynamic> maps = jsonDecode(result);
                if(maps.isNotEmpty){

                  // 轉成 TimeOfDay
                  // HH:mm:ss.SSSSSSS 格式解析 16:00:00.0000000
                  DateFormat format = DateFormat("HH:mm:ss");
                  DateTime parsed_start = format.parse(maps[0]["GOHOME_START_TIME"]);
                  DateTime parsed_end = format.parse(maps[0]["GOHOME_END_TIME"]);
                  TimeOfDay GOHOME_START_TIME = TimeOfDay(hour: parsed_start.hour, minute: parsed_start.minute);
                  TimeOfDay GOHOME_END_TIME = TimeOfDay(hour: parsed_end.hour, minute: parsed_end.minute);
                  if (!isNowInRange(GOHOME_START_TIME, GOHOME_END_TIME)) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: Colors.white, // 白底
                        title: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28), // 提醒 icon
                            SizedBox(width: 8),
                            Text(
                              "目前非使用時間",
                              textScaler: TextScaler.linear(1),
                              style: TextStyle(fontSize: 20.sp, color: Colors.black), // 黑字
                            ),
                          ],
                        ),
                        content: Text(
                          "可使用時間 ${formatTimeOfDay(GOHOME_START_TIME)} ~ ${formatTimeOfDay(GOHOME_END_TIME)}",
                          textScaler: TextScaler.linear(1),
                          style: TextStyle(fontSize: 20.sp, color: Colors.black), // 黑字
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              "確定",
                              textScaler: TextScaler.linear(1),
                              style: TextStyle(fontSize: 18.sp, color: Colors.black), // 黑字
                            ),
                          ),
                        ],
                      ),
                    );
                    return;
                  }

                }


              }
              catch(e){
                dev.log("err:${e}");
                showRetryDialog(context);
                return;
              }




              if(sel_minute==-1){
                Fluttertoast.showToast(
                    msg: "請先選擇分鐘",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0.sp
                );
                return;
              }

              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: Container(width: ScreenUtil().screenWidth,
                          child: Text("確定送出?",
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
                          (sel_minute==0)?
                          Container(
                              width: ScreenUtil().screenWidth, child: Column(children: [

                            Text("已到達",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 20.sp),)

                          ],))
                          :
                          Container(
                              width: ScreenUtil().screenWidth, child: Column(children: [

                                Text("${sel_minute}分鐘內抵達",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 20.sp),)

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
                              "送出", textScaler: TextScaler
                              .linear(1.0), style: TextStyle(
                              fontFamily: "GenJyuuGothic",
                              fontWeight: FontWeight.w700,
                              fontSize: 16.sp,
                              color: Color(0xff373737))),
                          onPressed: () async {

                            Navigator.pop(context);
                            add_CALL_db_sub();

                          },
                        ),
                      ],
                    );
                  });

            },
            child: Row(children: [
              Expanded(child: Container()),
              Text('送出', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              Expanded(child: Container()),
            ],),
          )),
      Container(height: 10.h,),
      Row(children: [

        Expanded(child: Container()),
        Text('說明：預計抵達園所前5分鐘才會自動廣播', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.red , fontSize: 16.sp))

      ],),
      Container(height: 10.h,),
      Expanded(child: Container()),

    ],);
  }
}
