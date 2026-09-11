import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:code3/main2_T.dart';
import 'package:code3/signature2.dart';
import 'package:code3/signature4.dart';
import 'package:code3/student_T.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'fcm_notifity.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;

import 'utils/CustomAppBar.dart';


class EDIT_ROLLCALL_page extends StatefulWidget {

  String type = "";
  DateTime dateTime = DateTime.now();
  ROLLCALL rOLLCALL = ROLLCALL();
  EDIT_ROLLCALL_page({String type="",DateTime? dateTime,ROLLCALL? rOLLCALL}){
    this.type = type;
    this.dateTime = dateTime!;
    this.rOLLCALL = rOLLCALL!;
  }

  @override
  State<EDIT_ROLLCALL_page> createState() => EDIT_ROLLCALL_pageState(type:this.type,dateTime:this.dateTime,rOLLCALL:this.rOLLCALL);
}

class EDIT_ROLLCALL_pageState extends State<EDIT_ROLLCALL_page> {

  DateTime? dateTime;
  TimeOfDay? timeOfDay;
  var showModalBottomSheet_image_context;
  ROLLCALL_ITEMS? sel_ROLLCALL_ITEMS;

  BuildContext? __context;

  String type = "";
  ROLLCALL rOLLCALL = ROLLCALL();
  EDIT_ROLLCALL_pageState({String type="",DateTime? dateTime,ROLLCALL? rOLLCALL}){
    this.type = type;
    this.dateTime = dateTime!;
    this.rOLLCALL = rOLLCALL!;
  }

  BuildContext? this_context;

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
      data_list = trim_proc(data_list);
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

        //找出選了哪一個
        for(int j=0;j<ROLLCALL_ITEMS_list.length;j++){
          if(ROLLCALL_ITEMS_list[j].ITEM_NO==rOLLCALL.STATUS){
            sel_ROLLCALL_ITEMS = ROLLCALL_ITEMS_list[j];
            timeOfDay = TimeOfDay.fromDateTime(DateTime.parse("${rOLLCALL.DATE} ${rOLLCALL.TIME}"));
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


  Future<void> write_all_ROLLCALL_db_sub({String CS_NO=""})async{
    FocusManager.instance.primaryFocus?.unfocus();
    dev.log("班級人數:${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length}");
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      SmartDialog.showLoading(msg: "處理中...(${i+1}/${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length})");
      dev.log("CS_NO:${CS_NO}");
      /*
    前6碼 yyMMdd
    後6碼流水號
     */
      int ROLLCALL_NO = await get_NO_ROLLCALL_db_sub();//先確定點名表單流水號
      if(ROLLCALL_NO==-1){
        SmartDialog.dismiss();
        SmartDialog.showToast("read_DRUG_MT_db_sub error");
        return;
      }
      ROLLCALL_NO+=1;
      String _ROLLCALL_NO = "${DateFormat('yyMMdd').format(dateTime!)}${ROLLCALL_NO.toString().padLeft(6,"0")}";
      dev.log("_ROLLCALL_NO:${_ROLLCALL_NO}");

      await get_CS_NO_ROLLCALL_db_sub(CS_NO:CS_NO);//檢查是否已建立過
      dev.log("ROLLCALL_list.length:${ROLLCALL_list.length}");
      bool check = await insert_or_updata_ROLLCALL_db_sub(CS_NO:CS_NO,NO:_ROLLCALL_NO);

    }
    SmartDialog.dismiss();
    SmartDialog.showToast("處理成功");
    Navigator.pop(__context!);

  }

  Future<void> write_ROLLCALL_db_sub({String CS_NO=""})async{

    dev.log("CS_NO:${CS_NO}");
    /*
    前6碼 yyMMdd
    後6碼流水號
     */
    int ROLLCALL_NO = await get_NO_ROLLCALL_db_sub();//先確定點名表單流水號
    if(ROLLCALL_NO==-1){
      SmartDialog.showToast("read_DRUG_MT_db_sub error");
      return;
    }
    ROLLCALL_NO+=1;
    String _ROLLCALL_NO = "${DateFormat('yyMMdd').format(dateTime!)}${ROLLCALL_NO.toString().padLeft(6,"0")}";
    dev.log("_ROLLCALL_NO:${_ROLLCALL_NO}");


    await get_CS_NO_ROLLCALL_db_sub(CS_NO:CS_NO);//檢查是否已建立過
    dev.log("ROLLCALL_list.length:${ROLLCALL_list.length}");
    bool check = await insert_or_updata_ROLLCALL_db_sub(CS_NO:CS_NO,NO:_ROLLCALL_NO);

    if(check==true){


      List<CUSTOMER> cUSTOMER = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.where((element) => element.CS_NO==CS_NO).toList();

      if(cUSTOMER.length==0){
        dev.log("找不到此學生");
        //result_str = '${cUSTOMER[0].CS_NM} ${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名失敗';
        AwesomeDialog(
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.error,
          body: Column(children: [

            Center(child: Text("${CS_NO}",style: TextStyle(
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

            setState(() {

            });

          },
        )..show();

      }
      else{

        MyHomePage2_T_fun1!(type:"刷新點名紀錄");

        dev.log("成功點名");
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
            Center(child: Text("${ TimeOfDay(hour: timeOfDay!.hour,minute: timeOfDay!.minute).period==DayPeriod.am?"上午":"下午"}${"${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00"} ${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名成功",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Color(0xff292929)))),

          ],),
          //title: 'This is Ignored',
          //desc:   'This is also Ignored',
          btnOkOnPress: () {

            Navigator.pop(context);
            setState(() {

            });

            /*
            Future.delayed(const Duration(milliseconds: 500), () {
              Navigator.pop(__context!);
            });

             */

          },
        )..show();


        /*
        //到離校推播通知要不要推播給家長，以後台設定為主
        String comm = "SELECT ROLLCALL FROM NOTIF_SETTING WHERE DEPM_NO = '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}'";
        String result = await sql_command("${comm}");
        List<dynamic> maps = jsonDecode(result);

        if("${maps[0]["ROLLCALL"]}"=="true"){
          try{
            for(int i=0;i<cUSTOMER[0].cUSTOMER_DLs.length;i++){
              String FCM = await search_CUSTOMER_DL_fcm_sub(ACCOUNT:cUSTOMER[0].cUSTOMER_DLs[i]!.ACCOUNT);
              await sendPushNotification(
                title: "${EMPLOYEE_teacher.EMP_NM} 老師",
                message: "${cUSTOMER[0].CS_NM} 已${sel_ROLLCALL_ITEMS!.ITEM_NM}",
                token: FCM,//cUSTOMER[0].cUSTOMER_DLs[i]!.FCM,
                ChatID:"${cUSTOMER[0].CS_NM} 已${sel_ROLLCALL_ITEMS!.ITEM_NM}",
                UserAccount: '${cUSTOMER[0].cUSTOMER_DLs[i]!.ACCOUNT}',
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

    }
    else{



      List<CUSTOMER> cUSTOMER = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.where((element) => element.CS_NO==CS_NO).toList();

      dev.log("cUSTOMER.length:${cUSTOMER.length}");
      if(cUSTOMER.length==0){

        dev.log("找不到此學生");
        AwesomeDialog(
          dismissOnTouchOutside: false,
          dismissOnBackKeyPress: false,
          context: context,
          animType: AnimType.scale,
          dialogType: DialogType.error,
          body: Column(children: [

            Center(child: Text("${CS_NO}",style: TextStyle(
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

            setState(() {

            });

          },
        )..show();

      }
      else{
        //result_str = '${cUSTOMER[0].CS_NM} ${sel_ROLLCALL_ITEMS!.ITEM_NM} 點名失敗';
        dev.log("失敗點名");
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

            setState(() {

            });

          },
        )..show();

      }



    }

    Student_T_page_fun!(action:"到/離校");
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


  /*
  [托嬰/幼兒] 點名 ROLLCALL
   */
  Future<int> get_NO_ROLLCALL_db_sub({String CS_NO=""})async{

    int ROLLCALL_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(dateTime!)}";
    dev.log("datetime:${datetime}");
    String comm = "SELECT * FROM ROLLCALL WHERE DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";
    if(CS_NO.isNotEmpty){
      comm = "SELECT * FROM ROLLCALL WHERE CS_NO='${CS_NO}' AND (DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59')";
    }
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
        data_list.sort((a,b)=> int.parse(a["NO"]).compareTo(int.parse(b["NO"])));
        String ROLLCALL_NO = "${data_list[data_list.length-1]["NO"]}";
        dev.log("ROLLCALL_NO:${ROLLCALL_NO}");
        //找出流水號
        ROLLCALL_NO_num = int.parse("${ROLLCALL_NO.substring(ROLLCALL_NO.length-4,ROLLCALL_NO.length)}");
        dev.log("ROLLCALL_NO_num:${ROLLCALL_NO_num}");
      }
      setState(() {

      });

    }
    catch(e){
      ROLLCALL_NO_num=-1;
      dev.log("${e}");
    }

    return ROLLCALL_NO_num;

  }


  /*
  [托嬰/幼兒] 點名 ROLLCALL
   */
  Future<void> get_CS_NO_ROLLCALL_db_sub({String CS_NO=""})async{

    ROLLCALL_list.clear();
    String datetime = "${DateFormat('yyyy-MM-dd').format(dateTime!)}";
    dev.log("datetime:${datetime}");
    String comm = "SELECT * FROM ROLLCALL WHERE CS_NO='${CS_NO}' AND STATUS='${sel_ROLLCALL_ITEMS!.ITEM_NO}' AND (DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59')";
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
      dev.log("${e}");
    }

  }


  /*
  [托嬰/幼兒] 點名 ROLLCALL
   */
  Future<bool> insert_or_updata_ROLLCALL_db_sub(
      {
        String NO="",
        String CS_NO=""
      })async{

    bool check = false;
    String DATE="${DateFormat('yyyy-MM-dd').format(dateTime!)}";
    String TIME="${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00";
    //String DEPM_NO="${EMPLOYEE_teacher.DEPM_NO}";
    //String CLASS_NO="${EMPLOYEE_teacher.CLASS_NO}";
    String STATUS="${sel_ROLLCALL_ITEMS!.ITEM_NO}";
    String ADD_USER="${EMPLOYEE_teacher.EMP_NO}";
    String ADD_DATE="${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}";

    String DEPM_NO = "";
    String CLASS_NO = "";

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
      comm = "UPDATE ROLLCALL SET DATE='${DATE}', TIME='${TIME}',STATUS='${STATUS}',DEPM_NO='${DEPM_NO}' WHERE NO='${ROLLCALL_list[0].NO}' SELECT * FROM ROLLCALL WHERE NO='${ROLLCALL_list[0].NO}'";
    }
    String result = await sql_command("${comm}");

    try{
      if(result.contains("執行成功")){
        setState(() {

        });
        check=true;
        return check;
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

    }
    catch(e){
      dev.log("${e}");
    }

    return check;

  }


  @override
  Widget build(BuildContext context) {

    __context = context;

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
          backgroundColor: Color(0xffF4F4F4),
          appBar: CustomAppBar(

            backgroundColor: Color(0xffF9AA88),
            toolbarHeight:42.h,
            leading: GestureDetector(
                onTap: (){

                  bool check = false;
                  if(dateTime!=null){
                    check=true;
                  }

                  if(timeOfDay!=null){
                    check=true;
                  }

                  if(check==true){
                    showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return Scaffold(
                              backgroundColor: Color(0x20000000),
                              body: StatefulBuilder(
                                  builder: (context, state) {
                                    return CupertinoAlertDialog(
                                      title: Text('確定離開?', maxLines: 2,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                            fontSize: 18.0.sp),),
                                      content: Text('有資料尚未上傳,是否離開？',
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
                                          child: Text('離開',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(__context!).pop();
                                          },
                                        ),

                                      ],
                                    );
                                  }));
                        });
                  }
                  else{
                    Navigator.pop(context);
                  }


                },
                child:Icon(Icons.arrow_back,size: 30.w,)),
            centerTitle: false,
            actions: [
              GestureDetector(
                  onTap: (){


                    if(dateTime==null){
                      SmartDialog.showToast("請輸入日期");
                      return;
                    }

                    if(timeOfDay==null && (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.TYPE=="2")){
                      SmartDialog.showToast("請輸入時間");
                      return;
                    }

                    if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.TYPE=="1"){
                      timeOfDay = TimeOfDay.fromDateTime(DateTime.now());
                    }

                    showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return Scaffold(
                              backgroundColor: Color(0x20000000),
                              body: StatefulBuilder(
                                  builder: (context, state) {
                                    return CupertinoAlertDialog(
                                      title: Text('確定更新?', maxLines: 2,
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
                                          child: Text('更新',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                          onPressed: () {
                                            Navigator.of(context).pop();

                                            if(type=="寫入全班"){
                                              //write_all_ROLLCALL_db_sub();
                                            }
                                            else{
                                              write_ROLLCALL_db_sub(
                                                CS_NO: EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO,
                                              );
                                            }


                                          },
                                        ),

                                      ],
                                    );
                                  }));
                        });

                  },
                  child: Text("更新", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp))),
              Container(width: 20.w,),
            ],
            title: Text("${(type=="寫入全班")?"全班":EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NM.replaceAll(" ", "")}(補點名)", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),

          ),
          body: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [

              Container(height: 20.h,),
              /*
              Row(children: [
                Container(width: 10.w,),
                Text("學校:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ],),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
                    Container(width: 5.w,),
                    Text("${user.DEPM_NM}",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: Colors.blue)),
                    Container(width: 5.w,),
                  ],),),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 15.h,),
              Row(children: [
                Container(width: 10.w,),
                Text("班級:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ],),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
                Container(width: 5.w,),
                Text("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NM}",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Colors.blue)),
                Container(width: 5.w,),
              ],),),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 15.h,),

               */
              Row(children: [
                Container(width: 10.w,),
                Text("日期:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ],),
              GestureDetector(
                  onTap:()async{
                    

                  },
                  child: Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
                    Container(width: 5.w,),
                    Text((dateTime==null)?"":"${DateFormat('yyyy年MM月dd日').format(dateTime!)}",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: Colors.blue)),
                    Container(width: 5.w,),
                  ],),)),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 15.h,),

              (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.TYPE=="1")?
              Container()
                  :
              Column(children: [
                Row(children: [
                  Container(width: 10.w,),
                  Text("時間:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929))),
                ],),
                GestureDetector(
                    onTap: ()async{


                      DateTime? datetime = await picker.DatePicker.showTimePicker(context,
                          showTitleActions: true,
                          showSecondsColumn: false,
                          /*
                        theme: picker.DatePickerTheme(
                            headerColor: Color(0xff5CADAD),
                            backgroundColor: Color(0xff5CADAD),
                            itemStyle: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 22.sp),
                            cancelStyle: TextStyle(color: Colors.black, fontSize: 20.sp),
                            doneStyle: TextStyle(color: Colors.black, fontSize: 20.sp)),

                         */
                          onChanged: (date) {
                            print('change $date');
                          }, onConfirm: (date) {
                            print('confirm $date');
                          }, currentTime: DateTime.now(), locale: picker.LocaleType.tw);

                      if(datetime!=null){
                        timeOfDay = TimeOfDay.fromDateTime(datetime);
                      }

                      setState(() {

                      });

                      /*
                    TimeOfDay? _timeOfDay = await showTimePicker(
                      context: context,
                      initialEntryMode:TimePickerEntryMode.inputOnly,
                      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                      builder: (context, Widget? child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                          child: child!,
                        );
                      },
                    );

                    if(_timeOfDay!=null){
                      timeOfDay = _timeOfDay;
                    }
                    dev.log("${timeOfDay!.format(context)}");

                    setState(() {

                    });

                     */

                    },
                    child:
                    Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child:Row(children: [

                      Container(width: 5.w,),
                      Text((timeOfDay==null)?"":"${timeOfDay!.period==DayPeriod.am?"上午":"下午"}${timeOfDay!.hourOfPeriod}:${timeOfDay!.minute.toString().padLeft(2,"0")}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w700,color: Colors.blue , fontSize: 16.sp)),
                      Container(width: 5.w,),

                    ],)
                    )),
                Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                Container(height: 15.h,),
              ],),

              Row(children: [
                Container(width: 10.w,),
                Text("選擇:(到校 或 離校)",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ],),
              Container(
                  margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),
                  width:ScreenUtil().screenWidth,height:50.h,
                  child: Column(children: [

                    Expanded(child: Container()),
                    Row(children: [
                      Text(
                        (sel_ROLLCALL_ITEMS==null)?"":sel_ROLLCALL_ITEMS!.ITEM_NM,
                        style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.black
                        ),
                      )
                    ],),
                    Expanded(child: Container()),

                  ],)),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 15.h,),

            ],),
        )));
  }
}
