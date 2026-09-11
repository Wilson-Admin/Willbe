import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:code3/api.dart';
import 'package:code3/main2_T.dart';
import 'package:code3/scanned_barcode_label.dart';
import 'package:code3/scanner_error_widget.dart';
import 'package:code3/sql.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'fcm_notifity.dart';
import 'student_T.dart';
import 'dart:developer' as dev;

import 'utils/CustomAppBar.dart';


class BarcodeScannerPageView extends StatefulWidget {
  const BarcodeScannerPageView({super.key});

  @override
  State<BarcodeScannerPageView> createState() => _BarcodeScannerPageViewState();
}

class _BarcodeScannerPageViewState extends State<BarcodeScannerPageView> {
  final MobileScannerController controller = MobileScannerController();
  final PageController pageController = PageController();
  DateTime __dateTime = DateTime.now();
  ROLLCALL_ITEMS? sel_ROLLCALL_ITEMS;

  bool is_proc_flag=true;
  //Barcode? old_Barcode;
  List<ROLLCALL> ROLLCALL_list = [];
  String result_str="";

  @override
  void initState() {
    // TODO: implement initState


    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    Future.delayed(const Duration(milliseconds: 500), () async{

      is_proc_flag=false;
      await ROLLCALL_ITEMS_db_sub();
      setState(() {

      });

    });



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

      if(data_list.length==0){

      }
      else{
        for(int j=0;j<data_list.length;j++){
          ROLLCALL_ITEMS ss = ROLLCALL_ITEMS();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          ROLLCALL_ITEMS_list.add(ss);
          if(j==0){
            sel_ROLLCALL_ITEMS = ROLLCALL_ITEMS_list[0];
          }
        }
      }

      setState(() {

      });

    }
    catch(e){
      log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }


  /*
  [托嬰/幼兒] 點名 ROLLCALL
   */
  Future<int> get_NO_ROLLCALL_db_sub({String CS_NO=""})async{

    int ROLLCALL_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(__dateTime)}";
    log("datetime:${datetime}");
    String comm = "SELECT * FROM ROLLCALL WHERE DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";
    //if(CS_NO.isNotEmpty){
    //String comm = "SELECT * FROM ROLLCALL WHERE CS_NO='${CS_NO}' AND (DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59')";
    //}
    log("${comm}");
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
      if(data_list.length==0){
      }
      else{
        data_list.sort((a,b)=> int.parse(a["NO"]).compareTo(int.parse(b["NO"])));
        String ROLLCALL_NO = "${data_list[data_list.length-1]["NO"]}";
        log("ROLLCALL_NO:${ROLLCALL_NO}");
        //找出流水號
        ROLLCALL_NO_num = int.parse("${ROLLCALL_NO.substring(ROLLCALL_NO.length-4,ROLLCALL_NO.length)}");
        log("ROLLCALL_NO_num:${ROLLCALL_NO_num}");
      }
      setState(() {

      });

    }
    catch(e){
      ROLLCALL_NO_num=-1;
      log("${e}");
    }

    return ROLLCALL_NO_num;

  }


  /*
  [托嬰/幼兒] 點名 ROLLCALL
   */
  Future<void> get_CS_NO_ROLLCALL_db_sub({String CS_NO=""})async{

    ROLLCALL_list.clear();
    String datetime = "${DateFormat('yyyy-MM-dd').format(__dateTime)}";
    log("datetime:${datetime}");
    /*
    String comm = '''
    SELECT * FROM ROLLCALL WHERE CS_NO='${CS_NO}' AND STATUS='${sel_ROLLCALL_ITEMS!.ITEM_NO}' AND (DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59')
    ''';

     */

    String comm = '''
    SELECT * 
FROM ROLLCALL 
WHERE CS_NO = (
    SELECT CS_NO 
    FROM View_Customer_Active 
    WHERE CS_NO_HEX16 = '${CS_NO}'
) 
AND STATUS = '${sel_ROLLCALL_ITEMS!.ITEM_NO}'
AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59';
    ''';

    log("${comm}");
    String result = await sql_command("${comm}");
    log("測試回應:${result}");

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
        ROLLCALL r = ROLLCALL();
        r.NO = "${data_list[0]["NO"]}"=="null"?"":"${data_list[0]["NO"]}";
        r.DATE = "${data_list[0]["DATE"]}"=="null"?"":"${data_list[0]["DATE"]}";
        r.TIME = "${data_list[0]["TIME"]}"=="null"?"":"${data_list[0]["TIME"]}";
        r.DEPM_NO = "${data_list[0]["DEPM_NO"]}"=="null"?"":"${data_list[0]["DEPM_NO"]}";
        r.CLASS_NO = "${data_list[0]["CLASS_NO"]}"=="null"?"":"${data_list[0]["CLASS_NO"]}";
        r.CS_NO = "${data_list[0]["CS_NO"]}"=="null"?"":"${data_list[0]["CS_NO"]}";
        r.STATUS = "${data_list[0]["STATUS"]}"=="null"?"":"${data_list[0]["STATUS"]}";
        r.ADD_USER = "${data_list[0]["ADD_USER"]}"=="null"?"":"${data_list[0]["ADD_USER"]}";
        r.ADD_DATE = "${data_list[0]["ADD_DATE"]}"=="null"?"":"${data_list[0]["ADD_DATE"]}";
        ROLLCALL_list.add(r);
      }
      setState(() {

      });

    }
    catch(e){
      log("${e}");
    }

  }


  /*
  [托嬰/幼兒] 點名 ROLLCALL
   */
  Future<bool> insert_or_updata_ROLLCALL_db_sub(
  {
    String NO="",
    String CS_NO="",
    String DEPM_NO="",
    String CLASS_NO="",
  })async{

    bool check = false;
    String DATE="${DateFormat('yyyy-MM-dd').format(__dateTime)}";
    String TIME="${DateFormat('HH:mm:ss').format(__dateTime)}";
    //String DEPM_NO="${EMPLOYEE_teacher.DEPM_NO}";
    //String CLASS_NO="${EMPLOYEE_teacher.CLASS_NO}";
    String STATUS="${sel_ROLLCALL_ITEMS!.ITEM_NO}";
    String ADD_USER="${EMPLOYEE_teacher.EMP_NO}";
    String ADD_DATE="${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}";

    //String DEPM_NO = "";
    //String CLASS_NO = "";


    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMERs.length;i++){
      for(int j=0;j<EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs.length;j++){
        if(EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs[j].CS_NO==CS_NO){
          DEPM_NO = EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs[j].DEPM_NO;
          CLASS_NO = EMPLOYEE_teacher.Teacher_CUSTOMERs[i].cUSTOMERs[j].CLASS_NO;
          break;
        }
      }
    }

    String comm = "INSERT INTO ROLLCALL(NO,DATE,TIME,DEPM_NO,CLASS_NO,CS_NO,STATUS,ADD_USER,ADD_DATE) VALUES ('${NO}','${DATE}','${TIME}','${DEPM_NO}','${CLASS_NO}','${CS_NO}','${STATUS}','${ADD_USER}','${ADD_DATE}') SELECT * FROM ROLLCALL WHERE NO='${NO}'";
    if(ROLLCALL_list.length > 0){
       comm = "UPDATE ROLLCALL SET DATE='${DATE}', TIME='${TIME}',STATUS='${STATUS}',DEPM_NO='${DEPM_NO}',CLASS_NO='${CLASS_NO}' WHERE NO='${ROLLCALL_list[0].NO}' SELECT * FROM ROLLCALL WHERE NO='${ROLLCALL_list[0].NO}'";
    }
    String result = await sql_command("${comm}");

    try{

      if(result.contains("執行成功")){
        setState(() {

        });
        return true;
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
      if(data_list.length==0){
        if(comm.contains("INSERT")){
          check=true;
        }
      }
      else{
        if("${data_list[0]["TIME"]}".contains("${TIME}")){
          check=true;
        }
      }
      setState(() {

      });

       */

    }
    catch(e){
      log("${e}");
    }

    return check;

  }

  Future<Map<String,dynamic>> find_ROLLCALL_db_sub({String CS_NO=""})async{

    String CS_NM="";
    String CLASS_NO="";
    String PICTURE_LINK="";
    String DEPM_NO="";
    String _CS_NO="";
    //String comm = "SELECT * FROM CUSTOMER WHERE CS_NO='${CS_NO}'";
    String comm = "SELECT * FROM View_Customer_Active WHERE CS_NO_HEX16='${CS_NO}'";
    String result = await sql_command("${comm}");
    dev.log("學生資料:${result}");
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
        CS_NM = "${data_list[0]["CS_NM"]}".contains("null")?"":"${data_list[0]["CS_NM"]}";
        CLASS_NO = "${data_list[0]["CLASS_NO"]}".contains("null")?"":"${data_list[0]["CLASS_NO"]}";
        DEPM_NO = "${data_list[0]["DEPM_NO"]}".contains("null")?"":"${data_list[0]["DEPM_NO"]}";
        _CS_NO = "${data_list[0]["CS_NO"]}".contains("null")?"":"${data_list[0]["CS_NO"]}";
        PICTURE_LINK = "${data_list[0]["PICTURE_LINK"]}".contains("null")?"":"${data_list[0]["PICTURE_LINK"]}";
        PICTURE_LINK = PICTURE_LINK.replaceAll("~/", "");
        PICTURE_LINK = "${IMAGE_IP}/${PICTURE_LINK}";
      }
      setState(() {

      });

    }
    catch(e){
      log("${e}");
    }

    return {
      'CS_NM':CS_NM,
      'CLASS_NO':CLASS_NO,
      'DEPM_NO':DEPM_NO,
      'PICTURE_LINK':PICTURE_LINK,
      'CS_NO':_CS_NO
    };
  }

  Future<List<dynamic>> find_CUSTOMER_DL_db_sub({String CS_NO=""})async{

    List<dynamic> list = [];
    String CS_NM="";
    String CLASS_NO="";
    String PICTURE_LINK="";
    String comm = "SELECT * FROM CUSTOMER_DL WHERE CS_NO='${CS_NO}'";
    String result = await sql_command("${comm}");

    try{
      list = jsonDecode(result);
      setState(() {

      });

    }
    catch(e){
      log("${e}");
    }

    return list;
  }

  Future<void> write_ROLLCALL_db_sub({String CS_NO="",Barcode? barcode})async{

    __dateTime = DateTime.now();

    log("------------------------------------------------------");

    log("CS_NO:${CS_NO}");
    /*
    前6碼 yyMMdd
    後6碼流水號
     */
    int ROLLCALL_NO = await get_NO_ROLLCALL_db_sub();//先確定點名表單流水號
    if(ROLLCALL_NO==-1){
      //EasyLoading.showInfo("資料庫錯誤,請重新嘗試");
      //controller.start();
      //return;
      ROLLCALL_NO=0;
    }
    ROLLCALL_NO+=1;
    String _ROLLCALL_NO = "${DateFormat('yyMMdd').format(__dateTime)}${ROLLCALL_NO.toString().padLeft(6,"0")}";
    log("_ROLLCALL_NO:${_ROLLCALL_NO}");


    await get_CS_NO_ROLLCALL_db_sub(CS_NO:CS_NO);//檢查是否已建立過
    log("ROLLCALL_list.length:${ROLLCALL_list.length}");

    //找出學生的學校/姓名/照片
    Map<String,dynamic> map = await find_ROLLCALL_db_sub(CS_NO: CS_NO);

    if("${map["DEPM_NO"]}".isEmpty || "${map["CLASS_NO"]}".isEmpty){
      Fluttertoast.showToast(
          msg: "此學生的學校或是班級為空的，請重新嘗試",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0.sp
      );
      is_proc_flag=false;
      //controller.start();
      setState(() {

      });
      return;
    }

    if(ROLLCALL_list.length > 0){
      AwesomeDialog(
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        context: context,
        animType: AnimType.scale,
        dialogType: DialogType.success,
        body: Column(children: [

          Center(child: Container(width: 300.w,height: 150.h,child: Image.network("${map["PICTURE_LINK"]}",errorBuilder: (BuildContext context, Object exception,
              StackTrace? stackTrace) {
            return  Icon(Icons.error,size: 30.sp,);
          }, ),),),
          Center(child: Text("${map["CS_NM"]}".trim(),style: TextStyle(
              fontFamily: "GenJyuuGothic",
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Color(0xff292929)))),
          Center(child: Text("${ TimeOfDay(hour: __dateTime.hour,minute: __dateTime.minute).period==DayPeriod.am?"上午":"下午"}${DateFormat("HH:mm:ss").format(__dateTime)} ${sel_ROLLCALL_ITEMS!.ITEM_NM} 已點名",style: TextStyle(
              fontFamily: "GenJyuuGothic",
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Color(0xff292929)))),

          Center(child: Text("是否覆蓋?",style: TextStyle(
              fontFamily: "GenJyuuGothic",
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Color(0xff292929)))),

        ],),
        //title: 'This is Ignored',
        //desc:   'This is also Ignored',
        btnOkText: "確定覆蓋",
        btnCancelText: "取消",
        btnOkOnPress: () {

          write_ROLLCALL_db_sub2(CS_NO:CS_NO,barcode:barcode);

        },
        btnCancelOnPress: (){

          is_proc_flag=false;
          //controller.start();
          setState(() {

          });

        }
      )..show();
      return;
    }

    bool check = await insert_or_updata_ROLLCALL_db_sub(DEPM_NO:"${map["DEPM_NO"]}",CLASS_NO:"${map["CLASS_NO"]}",CS_NO:"${map["CS_NO"]}",NO:_ROLLCALL_NO);
    log("check:${check}");
    if(check==true){

      MyHomePage2_T_fun1!(type:"刷新點名紀錄");

      //找出學生的學校/姓名/照片
      Map<String,dynamic> map = await find_ROLLCALL_db_sub(CS_NO: CS_NO);
      AwesomeDialog(
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        context: context,
        animType: AnimType.scale,
        dialogType: DialogType.success,
        body: Column(children: [

          Center(child: Container(width: 300.w,height: 150.h,child: Image.network("${map["PICTURE_LINK"]}",errorBuilder: (BuildContext context, Object exception,
              StackTrace? stackTrace) {
            return  Icon(Icons.error,size: 30.sp,);
          }, ),),),
          Center(child: Text("${map["CS_NM"]}".trim(),style: TextStyle(
              fontFamily: "GenJyuuGothic",
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Color(0xff292929)))),
          Center(child: Text("${ TimeOfDay(hour: __dateTime.hour,minute: __dateTime.minute).period==DayPeriod.am?"上午":"下午"}${DateFormat("HH:mm:ss").format(__dateTime)} ${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名成功",style: TextStyle(
              fontFamily: "GenJyuuGothic",
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Color(0xff292929)))),

        ],),
        //title: 'This is Ignored',
        //desc:   'This is also Ignored',
        btnOkOnPress: () {

          is_proc_flag=false;
          //controller.start();
          setState(() {

          });

        },
      )..show();


      //到離校推播通知要不要推播給家長，以後台設定為主
      String comm = "SELECT ROLLCALL FROM NOTIF_SETTING WHERE DEPM_NO = '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}'";
      String result = await sql_command("${comm}");
      List<dynamic> maps = jsonDecode(result);

      if("${maps[0]["ROLLCALL"]}"=="true"){
        try{
          List<dynamic> map2 = await find_CUSTOMER_DL_db_sub(CS_NO: CS_NO);
          for(int i=0;i<map2.length;i++){
            await sendPushNotification(
              title: "老師",
              message: "${map["CS_NM"]} 已${sel_ROLLCALL_ITEMS!.ITEM_NM}",
              token: "${map2[i]["FCM"]}",
              ChatID:"${map["CS_NM"]} 已${sel_ROLLCALL_ITEMS!.ITEM_NM}",
              UserAccount: '${map2[i]["ACCOUNT"]}',
              TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}",
              CS_NO:CS_NO,
            );
          }
        }
        catch(e){

        }
      }


    }
    else{
      AwesomeDialog(
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        context: context,
        animType: AnimType.scale,
        dialogType: DialogType.error,
        body: Column(children: [

          Center(child: Text("${CS_NO} 點名失敗",style: TextStyle(
              fontFamily: "GenJyuuGothic",
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Color(0xff292929)))),

        ],),
        //title: 'This is Ignored',
        //desc:   'This is also Ignored',
        btnOkOnPress: () {

          is_proc_flag=false;
          //controller.start();
          setState(() {

          });

        },
      )..show();
    }
    /*
    if(check==true){


      List<CUSTOMER> cUSTOMER = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.where((element) => element.CS_NO==barcode!.displayValue).toList();

      if(cUSTOMER.length==0){
        log("找不到此學生");
        //result_str = '${cUSTOMER[0].CS_NM} ${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名失敗';
        AwesomeDialog(
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.error,
          body: Column(children: [

            Center(child: Text("${barcode!.displayValue}",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),
            Center(child: Text("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NM} 找不到此學生",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),

          ],),
          //title: 'This is Ignored',
          //desc:   'This is also Ignored',
          btnOkOnPress: () {

            is_proc_flag=false;
            controller.start();
            setState(() {

            });

          },
        )..show();

      }
      else{

        MyHomePage2_T_fun1!(type:"刷新點名紀錄");

        log("成功點名");
        //result_str = '${cUSTOMER[0].CS_NM} ${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名失敗';
        AwesomeDialog(
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.success,
          body: Column(children: [

            Center(child: Container(width: 300.w,height: 150.h,child: Image.network("${cUSTOMER[0].PICTURE_LINK}",errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return  Icon(Icons.error,size: 30.sp,);
            }, ),),),
            Center(child: Text("${cUSTOMER[0].CS_NM.replaceAll(" ", "")}",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),
            Center(child: Text("${ TimeOfDay(hour: __dateTime.hour,minute: __dateTime.minute).period==DayPeriod.am?"上午":"下午"}${DateFormat("hh:mm:ss").format(__dateTime)} ${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名成功",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),

          ],),
          //title: 'This is Ignored',
          //desc:   'This is also Ignored',
          btnOkOnPress: () {

            is_proc_flag=false;
            controller.start();
            setState(() {

            });

          },
        )..show();
      }

    }
    else{



      List<CUSTOMER> cUSTOMER = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.where((element) => element.CS_NO==barcode!.displayValue).toList();

      log("cUSTOMER.length:${cUSTOMER.length}");
      if(cUSTOMER.length==0){

        log("找不到此學生");
        AwesomeDialog(
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.error,
          body: Column(children: [

            Center(child: Text("${barcode!.displayValue}",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),
            Center(child: Text("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NM} 找不到此學生",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),

          ],),
          //title: 'This is Ignored',
          //desc:   'This is also Ignored',
          btnOkOnPress: () {

            is_proc_flag=false;
            controller.start();
            setState(() {

            });

          },
        )..show();

      }
      else{
        //result_str = '${cUSTOMER[0].CS_NM} ${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名失敗';
        log("失敗點名");
        AwesomeDialog(
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.error,
          body: Column(children: [

            Center(child: Container(width: 300.w,height: 150.h,child: Image.network("${cUSTOMER[0].PICTURE_LINK}",errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return  Icon(Icons.error,size: 30.sp,);
            }, ),),),
            Center(child: Text("${cUSTOMER[0].CS_NM}",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),
            Center(child: Text("${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名失敗",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),

          ],),
          //title: 'This is Ignored',
          //desc:   'This is also Ignored',
          btnOkOnPress: () {

            is_proc_flag=false;
            controller.start();
            setState(() {

            });

          },
        )..show();

      }



    }

     */

    setState(() {

    });
    /*
    Future.delayed(const Duration(milliseconds: 2000), () {

      try {
        is_proc_flag = false;
        setState(() {

        });
      }
      catch(e){

      }

    });

     */

  }

  Future<void> write_ROLLCALL_db_sub2({String CS_NO="",Barcode? barcode})async{

    __dateTime = DateTime.now();

    log("------------------------------------------------------");

    log("CS_NO:${CS_NO}");
    /*
    前6碼 yyMMdd
    後6碼流水號
     */
    int ROLLCALL_NO = await get_NO_ROLLCALL_db_sub();//先確定點名表單流水號
    if(ROLLCALL_NO==-1){
      //EasyLoading.showInfo("資料庫錯誤,請重新嘗試");
      //controller.start();
      //return;
      ROLLCALL_NO=0;
    }
    ROLLCALL_NO+=1;
    String _ROLLCALL_NO = "${DateFormat('yyMMdd').format(__dateTime)}${ROLLCALL_NO.toString().padLeft(6,"0")}";
    log("_ROLLCALL_NO:${_ROLLCALL_NO}");


    await get_CS_NO_ROLLCALL_db_sub(CS_NO:CS_NO);//檢查是否已建立過
    log("ROLLCALL_list.length:${ROLLCALL_list.length}");

    //找出學生的學校/姓名/照片
    Map<String,dynamic> map = await find_ROLLCALL_db_sub(CS_NO: CS_NO);

    log("CS_NO>>>>:${map["CS_NO"]}");

    bool check = await insert_or_updata_ROLLCALL_db_sub(DEPM_NO:"${map["DEPM_NO"]}",CLASS_NO:"${map["CLASS_NO"]}",CS_NO:"${map["CS_NO"]}",NO:_ROLLCALL_NO);
    log("check:${check}");
    if(check==true){

      MyHomePage2_T_fun1!(type:"刷新點名紀錄");

      AwesomeDialog(
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        context: context,
        animType: AnimType.scale,
        dialogType: DialogType.success,
        body: Column(children: [

          Center(child: Container(width: 300.w,height: 150.h,child: Image.network("${map["PICTURE_LINK"]}",errorBuilder: (BuildContext context, Object exception,
              StackTrace? stackTrace) {
            return  Icon(Icons.error,size: 30.sp,);
          }, ),),),
          Center(child: Text("${map["CS_NM"]}".trim(),style: TextStyle(
              fontFamily: "GenJyuuGothic",
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Color(0xff292929)))),
          Center(child: Text("${ TimeOfDay(hour: __dateTime.hour,minute: __dateTime.minute).period==DayPeriod.am?"上午":"下午"}${DateFormat("HH:mm:ss").format(__dateTime)} ${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名成功",style: TextStyle(
              fontFamily: "GenJyuuGothic",
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Color(0xff292929)))),

        ],),
        //title: 'This is Ignored',
        //desc:   'This is also Ignored',
        btnOkOnPress: () {

          is_proc_flag=false;
          //controller.start();
          setState(() {

          });

        },
      )..show();


      /*
      到校離校重複輸入時，不應該再次推播訊息
      ( 檢查是否有資料 New 推播  / Update 不推播 )
      //到離校推播通知要不要推播給家長，以後台設定為主
      String comm = "SELECT ROLLCALL FROM NOTIF_SETTING WHERE DEPM_NO = '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}'";
      String result = await sql_command("${comm}");
      List<dynamic> maps = jsonDecode(result);

      if("${maps[0]["ROLLCALL"]}"=="true"){
        try{
          List<dynamic> map2 = await find_CUSTOMER_DL_db_sub(CS_NO: CS_NO);
          for(int i=0;i<map2.length;i++){
            await sendPushNotification(
              title: "${EMPLOYEE_teacher.EMP_NM} 老師",
              message: "${map["CS_NM"]} 已${sel_ROLLCALL_ITEMS!.ITEM_NM}",
              token: "${map2[i]["FCM"]}",
              ChatID:"${map["CS_NM"]} 已${sel_ROLLCALL_ITEMS!.ITEM_NM}",
              UserAccount: '${map2[i]["ACCOUNT"]}',
              TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}",
              CS_NO:CS_NO,
            );
          }
        }
        catch(e){

        }
      }

       */



    }
    else{
      AwesomeDialog(
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        context: context,
        animType: AnimType.scale,
        dialogType: DialogType.error,
        body: Column(children: [

          Center(child: Text("${CS_NO} 點名失敗",style: TextStyle(
              fontFamily: "GenJyuuGothic",
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Color(0xff292929)))),

        ],),
        //title: 'This is Ignored',
        //desc:   'This is also Ignored',
        btnOkOnPress: () {

          is_proc_flag=false;
          //controller.start();
          setState(() {

          });

        },
      )..show();
    }
    /*
    if(check==true){


      List<CUSTOMER> cUSTOMER = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.where((element) => element.CS_NO==barcode!.displayValue).toList();

      if(cUSTOMER.length==0){
        log("找不到此學生");
        //result_str = '${cUSTOMER[0].CS_NM} ${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名失敗';
        AwesomeDialog(
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.error,
          body: Column(children: [

            Center(child: Text("${barcode!.displayValue}",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),
            Center(child: Text("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NM} 找不到此學生",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),

          ],),
          //title: 'This is Ignored',
          //desc:   'This is also Ignored',
          btnOkOnPress: () {

            is_proc_flag=false;
            controller.start();
            setState(() {

            });

          },
        )..show();

      }
      else{

        MyHomePage2_T_fun1!(type:"刷新點名紀錄");

        log("成功點名");
        //result_str = '${cUSTOMER[0].CS_NM} ${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名失敗';
        AwesomeDialog(
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.success,
          body: Column(children: [

            Center(child: Container(width: 300.w,height: 150.h,child: Image.network("${cUSTOMER[0].PICTURE_LINK}",errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return  Icon(Icons.error,size: 30.sp,);
            }, ),),),
            Center(child: Text("${cUSTOMER[0].CS_NM.replaceAll(" ", "")}",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),
            Center(child: Text("${ TimeOfDay(hour: __dateTime.hour,minute: __dateTime.minute).period==DayPeriod.am?"上午":"下午"}${DateFormat("hh:mm:ss").format(__dateTime)} ${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名成功",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),

          ],),
          //title: 'This is Ignored',
          //desc:   'This is also Ignored',
          btnOkOnPress: () {

            is_proc_flag=false;
            controller.start();
            setState(() {

            });

          },
        )..show();
      }

    }
    else{



      List<CUSTOMER> cUSTOMER = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.where((element) => element.CS_NO==barcode!.displayValue).toList();

      log("cUSTOMER.length:${cUSTOMER.length}");
      if(cUSTOMER.length==0){

        log("找不到此學生");
        AwesomeDialog(
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.error,
          body: Column(children: [

            Center(child: Text("${barcode!.displayValue}",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),
            Center(child: Text("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NM} 找不到此學生",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),

          ],),
          //title: 'This is Ignored',
          //desc:   'This is also Ignored',
          btnOkOnPress: () {

            is_proc_flag=false;
            controller.start();
            setState(() {

            });

          },
        )..show();

      }
      else{
        //result_str = '${cUSTOMER[0].CS_NM} ${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名失敗';
        log("失敗點名");
        AwesomeDialog(
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.error,
          body: Column(children: [

            Center(child: Container(width: 300.w,height: 150.h,child: Image.network("${cUSTOMER[0].PICTURE_LINK}",errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return  Icon(Icons.error,size: 30.sp,);
            }, ),),),
            Center(child: Text("${cUSTOMER[0].CS_NM}",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),
            Center(child: Text("${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名失敗",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),

          ],),
          //title: 'This is Ignored',
          //desc:   'This is also Ignored',
          btnOkOnPress: () {

            is_proc_flag=false;
            controller.start();
            setState(() {

            });

          },
        )..show();

      }



    }

     */

    setState(() {

    });
    /*
    Future.delayed(const Duration(milliseconds: 2000), () {

      try {
        is_proc_flag = false;
        setState(() {

        });
      }
      catch(e){

      }

    });

     */

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          backgroundColor: Color(0xffF9AA88),
          centerTitle: true,
          title: Text("掃描點名", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Color(0xff292929) , fontSize: 24.sp)),
          actions: [


            Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(5.w),
                ),
                //width: 80.w,
                height: 45.h,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<ROLLCALL_ITEMS>(
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.white,
                    ),
                    isExpanded: true,
                    hint: Text(
                      '',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: ROLLCALL_ITEMS_list
                        .map((ROLLCALL_ITEMS item) => DropdownMenuItem<ROLLCALL_ITEMS>(
                      value: item,
                      child: Text(
                        item.ITEM_NM,
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.black
                        ),
                      ),
                    ))
                        .toList(),
                    value: sel_ROLLCALL_ITEMS,
                    onChanged: (ROLLCALL_ITEMS? value) {
                      setState(() {
                        sel_ROLLCALL_ITEMS = value;
                      });
                    },
                    buttonStyleData:  ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      height: 40.h,
                      width: 100.w,
                    ),
                    menuItemStyleData:  MenuItemStyleData(
                        height: 40.h,
                        selectedMenuItemBuilder: (c,w){
                          return Container(
                              color: Color(0xffFFDAC8),
                              child:Row(children: [

                                w,
                                Icon(Icons.check,size: 24.sp,),

                              ],));

                        }
                    ),
                  ),
                )),
            Container(width: 10.w,)

          ],
      ),
      backgroundColor: Colors.black,
      body: PageView(
        physics:const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: (index) async {
          // Stop the camera view for the current page,
          // and then restart the camera for the new page.
          /*
          await controller.stop();

          // When switching pages, add a delay to the next start call.
          // Otherwise the camera will start before the next page is displayed.
          await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

          if (!mounted) {
            return;
          }

          unawaited(controller.start());

           */
        },
        children: [

          Stack(
            children: [
              MobileScanner(
                controller: controller,
                fit: BoxFit.contain,
                onDetect: (onDetect){
                  List<Barcode> scannedBarcodes = onDetect.barcodes;
                  if (scannedBarcodes.isEmpty) {
                    result_str="Scan start";
                    setState(() {

                    });
                  }

                  if(is_proc_flag==false){
                    is_proc_flag=true;
                    write_ROLLCALL_db_sub(
                        CS_NO: scannedBarcodes[0].displayValue!,
                        barcode: scannedBarcodes[0]);
                  }


                },
                errorBuilder: (context, error) {
                  return ScannerErrorWidget(error: error);
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: 200.h,
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                      child: Text(
                        result_str,
                        overflow: TextOverflow.fade,
                        style: TextStyle(color: Colors.white,fontSize: 26.sp),
                      )
                  ),
                ),
              ),
            ],
          )

        ],
      ),
    );
  }

  @override
  Future<void> dispose() async {
    pageController.dispose();
    controller.dispose();
    super.dispose();
  }
}


