import 'dart:convert';
import 'dart:io';
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
import 'package:flutter_slidable/flutter_slidable.dart';
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
import 'package:badges/badges.dart' as badges;

import 'api.dart';
import 'sql.dart';
import 'utils/CustomAppBar.dart';


class Edit_DAILY_RQD_page extends StatefulWidget {

  View_DAILY? view_DAILY;
  Edit_DAILY_RQD_page({View_DAILY? view_DAILY}){
    this.view_DAILY = view_DAILY;
  }

  @override
  State<Edit_DAILY_RQD_page> createState() => Edit_DAILY_RQD_pageState(view_DAILY:this.view_DAILY);
}

class Edit_DAILY_RQD_pageState extends State<Edit_DAILY_RQD_page> {



  DateTime dateTime = DateTime.now();
  TimeOfDay? timeOfDay;
  var showModalBottomSheet_image_context;

  bool? is_RECIPIENT;//讀取回條
  RadioGroupController is_RECIPIENT_radioGroup_controller = RadioGroupController();

  String type = "";
  View_DAILY? view_DAILY;
  Edit_DAILY_RQD_pageState({View_DAILY? view_DAILY}){
    this.view_DAILY = view_DAILY;
  }

  List<SEL_DAILY_RQD> sEL_DAILY_RQDs = [];
  TextEditingController num_textEditingController = TextEditingController();//


  List<DAILY_RQD_ITEM> DAILY_RQD_ITEMs_2 = [];

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

    /*
    for(int i=0;i<DAILY_RQD_ITEMs.length;i++){
      DAILY_RQD_ITEMs[i].num_textEditingController.text="";
    }

     */

    init();

  }


  void init()async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    dateTime = DateFormat("yyyy-MM-dd").parse(view_DAILY!.DATE);
    timeOfDay = TimeOfDay(hour:int.parse(view_DAILY!.TIME.split(":")[0]),minute: int.parse(view_DAILY!.TIME.split(":")[1]));
    await read_DAILY_RQD_ITEM_db_sub();
    await read_DAILY_RQD_db_sub(NO:view_DAILY!.NO,TYPE:view_DAILY!.TYPE);
    SmartDialog.dismiss();
  }



  Future<void> read_DAILY_RQD_db_sub({
    String NO="",
    String TYPE="",
  })async{

    String comm = "SELECT * FROM DAILY_RQD WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
        sEL_DAILY_RQDs.clear();
        List<String> lists = [];
        try{
          lists = "${data_list[0]["ITEM_NOTE"]}".split(",");
          for(int i=0;i<lists.length;i++){
            List<String> lists2 = "${lists[i]}".split("數量");
            for(int j=0;j<DAILY_RQD_ITEMs.length;j++){
              if("${lists2[0]}".trim()==DAILY_RQD_ITEMs[j].ITEM_NM){
                SEL_DAILY_RQD s = SEL_DAILY_RQD();
                s.ITEM_NO = DAILY_RQD_ITEMs[j].ITEM_NO;
                s.ITEM_NM = DAILY_RQD_ITEMs[j].ITEM_NM;
                s.num = "${lists2[1]}".trim().replaceAll(":", "");
                sEL_DAILY_RQDs.add(s);
              }
            }
          }

          bool check = false;
          DAILY_RQD_ITEMs_2.clear();
          for(int i=0;i<DAILY_RQD_ITEMs.length;i++){
            check = false;
            for(int j=0;j<sEL_DAILY_RQDs.length;j++){
              if(DAILY_RQD_ITEMs[i].ITEM_NO==sEL_DAILY_RQDs[j].ITEM_NO){
                check = true;
                break;
              }
            }

            if(check==false){
              DAILY_RQD_ITEMs_2.add(DAILY_RQD_ITEMs[i]);
            }

          }

          if(DAILY_RQD_ITEMs_2.length>0){
            sel_DAILY_RQD_ITEM = DAILY_RQD_ITEMs_2[0];
          }

        }
        catch(e){
        }


      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_RQD_ITEM_db_sub()async{

    DAILY_RQD_ITEMs.clear();
    DAILY_RQD_ITEMs_2.clear();
    String comm = "SELECT * FROM DAILY_RQD_ITEM WHERE DEMP='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}'";
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
          DAILY_RQD_ITEM v = DAILY_RQD_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          v.DEMP = "${data_list[i]["DEMP"]}"=="null"?"":"${data_list[i]["DEMP"]}".replaceAll(" ", "");
          DAILY_RQD_ITEMs.add(v);
          sel_DAILY_RQD_ITEM = DAILY_RQD_ITEMs[0];
        }

        DAILY_RQD_ITEMs_2.addAll(DAILY_RQD_ITEMs);

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }


  /*
  上傳全班新一筆托嬰活動
   */
  Future<void> add_all_DAILY_MT_db_sub()async{
    FocusManager.instance.primaryFocus?.unfocus();
    dev.log("班級人數:${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length}");
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){

      SmartDialog.showLoading(msg: "處理中...(${i+1}/${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length})");

      int View_DAILY_NO_num = await read_View_DAILY_db_sub();
      dev.log("View_DAILY_NO_num:${View_DAILY_NO_num}");
      if(View_DAILY_NO_num==-1){
        SmartDialog.dismiss();
        SmartDialog.showToast("read_View_DAILY_db_sub error");
        return;
      }

      //await EasyLoading.show(status: "處理中...");
      View_DAILY_NO_num+=1;
      String View_DAILY_NO = "${DateFormat('yyyyMMdd').format(dateTime)}${View_DAILY_NO_num.toString().padLeft(7,"0")}";
      View_DAILY_NO = View_DAILY_NO.substring(2,View_DAILY_NO.length);
      dev.log("View_DAILY_NO:${View_DAILY_NO}");

      await insert_DAILY_MT_db_sub(
        TYPE:"RQD",
        NO:View_DAILY_NO,//編號
        DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
        TIME:"${DateFormat('HH:mm').format(dateTime!)}",//"${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00",//時間
        DEPM_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}",//學校
        CLASS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}",//班級
        CS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO}",//學生身分證字號
        USER_NO:"${EMPLOYEE_teacher.EMP_NO}",//系統自動帶入老師編號
      );

      /*
    將選單轉為文字並以逗號隔開 例如：衛生紙:數量1 , 替換衣物: 數量 3  (DAILY_RQD_ITEM)
     */
      String ITEM_NOTE="";
      for(int i=0;i<sEL_DAILY_RQDs.length;i++){
          if(ITEM_NOTE.isEmpty){
            ITEM_NOTE='${sEL_DAILY_RQDs[i].ITEM_NM} ${sEL_DAILY_RQDs[i].ITEM_NM.contains("其他")?"":"數量"}:${sEL_DAILY_RQDs[i].num}';
          }
          else{
            ITEM_NOTE="${ITEM_NOTE},${sEL_DAILY_RQDs[i].ITEM_NM} ${sEL_DAILY_RQDs[i].ITEM_NM.contains("其他")?"":"數量"}:${sEL_DAILY_RQDs[i].num}";
          }
      }

      //送出須備物品
      await insert_DAILY_RQD_db_sub(
          TYPE:"RQD",
          NO:View_DAILY_NO,//編號
          ITEM_NOTE:ITEM_NOTE,//
          SIGN_LINK:""
      );

    }

    SmartDialog.dismiss();
    SmartDialog.showToast("處理成功");
    //Student_T_page_fun!(action:"新增須備物品成功");
    //dateTime=null;
    timeOfDay=null;
    Navigator.pop(this_context!);


  }


  /*
  上傳新一筆托嬰活動
   */
  Future<void> add_DAILY_MT_db_sub()async{
    int View_DAILY_NO_num = await read_View_DAILY_db_sub();
    dev.log("View_DAILY_NO_num:${View_DAILY_NO_num}");
    if(View_DAILY_NO_num==-1){
      SmartDialog.showToast("read_View_DAILY_db_sub error");
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    View_DAILY_NO_num+=1;
    String View_DAILY_NO = "${DateFormat('yyyyMMdd').format(dateTime)}${View_DAILY_NO_num.toString().padLeft(7,"0")}";
    View_DAILY_NO = View_DAILY_NO.substring(2,View_DAILY_NO.length);
    dev.log("View_DAILY_NO:${View_DAILY_NO}");

    await insert_DAILY_MT_db_sub(
        TYPE:"RQD",
        NO:View_DAILY_NO,//編號
        DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
        TIME:"${DateFormat('HH:mm').format(dateTime!)}",//"${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00",//時間
        DEPM_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}",//學校
        CLASS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}",//班級
        CS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",//學生身分證字號
        USER_NO:"${EMPLOYEE_teacher.EMP_NO}",//系統自動帶入老師編號
    );

    /*
    將選單轉為文字並以逗號隔開 例如：衛生紙:數量1 , 替換衣物: 數量 3  (DAILY_RQD_ITEM)
     */
    String ITEM_NOTE="";
    for(int i=0;i<sEL_DAILY_RQDs.length;i++){
      if(ITEM_NOTE.isEmpty){
        ITEM_NOTE='${sEL_DAILY_RQDs[i].ITEM_NM} ${sEL_DAILY_RQDs[i].ITEM_NM.contains("其他")?"":"數量:"}${sEL_DAILY_RQDs[i].num}';
      }
      else{
        ITEM_NOTE="${ITEM_NOTE},${sEL_DAILY_RQDs[i].ITEM_NM} ${sEL_DAILY_RQDs[i].ITEM_NM.contains("其他")?"":"數量:"}:${sEL_DAILY_RQDs[i].num}";
      }
    }

    //送出須備物品
    await insert_DAILY_RQD_db_sub(
        TYPE:"RQD",
        NO:View_DAILY_NO,//編號
        ITEM_NOTE:ITEM_NOTE,//
        SIGN_LINK:""
    );

    SmartDialog.dismiss();
    SmartDialog.showToast("處理成功");
    Student_T_page_fun!(action:"新增須備物品成功");
    //dateTime=null;
    timeOfDay=null;
    Navigator.pop(this_context!);



  }


  Future<void> update_DAILY_MT_db_sub()async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});


    /*
    將選單轉為文字並以逗號隔開 例如：衛生紙:數量1 , 替換衣物: 數量 3  (DAILY_RQD_ITEM)
     */
    String ITEM_NOTE="";
    for(int i=0;i<sEL_DAILY_RQDs.length;i++){
      if(ITEM_NOTE.isEmpty){
        ITEM_NOTE='${sEL_DAILY_RQDs[i].ITEM_NM} ${sEL_DAILY_RQDs[i].ITEM_NM.contains("其他")?"":"數量:"}${sEL_DAILY_RQDs[i].num}';
      }
      else{
        ITEM_NOTE="${ITEM_NOTE},${sEL_DAILY_RQDs[i].ITEM_NM} ${sEL_DAILY_RQDs[i].ITEM_NM.contains("其他")?"":"數量:"}:${sEL_DAILY_RQDs[i].num}";
      }
    }

    await updata_DAILY_MT_db_sub(
      TYPE:"RQD",
      NO:view_DAILY!.NO,//編號
      DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
      TIME:"${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00",//時間
      DEPM_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}",//學校
      CLASS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}",//班級
      CS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",//學生身分證字號
      USER_NO:"${EMPLOYEE_teacher.EMP_NO}",//系統自動帶入老師編號
        MARK:ITEM_NOTE
    );




    //[托嬰/幼兒]  通知單(備註) 副表
    await updata_DAILY_RQD_db_sub(
      TYPE:"RQD",
      NO:view_DAILY!.NO,//編號
      ITEM_NOTE:ITEM_NOTE,//
    );


    SmartDialog.dismiss();
    SmartDialog.showToast("處理成功");
    Student_T_page_fun!(action:"新增[托嬰/幼兒]  通知單(備註) 副表成功");
    timeOfDay=null;
    Navigator.pop(this_context!);


  }


  Future<void> updata_DAILY_RQD_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        String ITEM_NOTE="",//須備物品說明
      })async{

    String comm = "UPDATE DAILY_RQD SET ITEM_NOTE='${ITEM_NOTE}',RECIPIENT='false' WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }


  }


  Future<void> updata_DAILY_MT_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        String DATE="",//日期
        String TIME="",//時間
        String DEPM_NO="",//學校編號
        String CLASS_NO="",//班級編號
        String CS_NO="",//學生編號
        String USER_NO="",//
        String MARK=""
      })async{

    String comm = "UPDATE DAILY_MT SET DATE='${DATE}',TIME='${TIME}',MARK='${MARK}' WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }


  }


  /*

   */
  Future<void> insert_DAILY_MT_db_sub(
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

    }
    catch(e){
      dev.log("${e}");
    }


  }


  /*

   */
  Future<void> insert_DAILY_RQD_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        String ITEM_NOTE="",//須備物品說明
        bool? RECIPIENT,//讀取回條
        String SIGN_LINK="",//家長簽名
      })async{

    String comm = "INSERT INTO DAILY_RQD(TYPE,NO,ITEM_NOTE) VALUES ('${TYPE}','${NO}','${ITEM_NOTE}')";
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
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }


  }


  /*
  生活花絮
   */
  Future<void> insert_DAILY_PIC_DL_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        String SR="",//序號
        String LINK="",//照片
      })async{

    String comm = "INSERT INTO DAILY_PIC_DL(TYPE,NO,SR,LINK) VALUES ('${TYPE}','${NO}','${SR}','${LINK}')";
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
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }


  }




  /*
  生活概況
   */
  Future<int> read_View_DAILY_db_sub()async{

    int View_DAILY_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(dateTime!)}";
    String comm = "SELECT * FROM View_DAILY WHERE TYPE='RQD' AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";
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
        String View_DAILY_NO = "${data_list[data_list.length-1]["NO"]}";
        dev.log("View_DAILY_NO:${View_DAILY_NO}");
        //找出流水號
        View_DAILY_NO_num = int.parse("${View_DAILY_NO.substring(View_DAILY_NO.length-7,View_DAILY_NO.length)}");
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




  @override
  Widget build(BuildContext context) {

    this_context = context;

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

                  bool check = true;
                  /*
                  if(dateTime!=null){
                    check=true;
                  }

                   */

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
                                            Navigator.of(this_context!).pop();
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
                centerTitle: true,
                actions: [
                  GestureDetector(
                      onTap: (){


                        /*
                        if(dateTime==null){
                          EasyLoading.showToast("請輸入日期");
                          return;
                        }

                        if(timeOfDay==null){
                          EasyLoading.showToast("請輸入時間");
                          return;
                        }

                         */

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
                                                  //add_all_DAILY_MT_db_sub();
                                                }
                                                else{
                                                  update_DAILY_MT_db_sub();
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
                title: Text("${DAILY_MT_TYPE_ITEMs.firstWhere((e)=>e.ITEM_NO=="RQD").ITEM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              ),
          body: Column(
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

                    dateTime = (await showDatePicker(
                        locale: Locale("zh","TW"),
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now()))!;

                    setState(() {

                    });

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

               */
              /*
              Row(children: [
                Container(width: 10.w,),
                Expanded(child:Text("讀取回條:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929)))),
                Expanded(flex:3,child: RadioGroup(
                  controller: is_RECIPIENT_radioGroup_controller,
                  orientation: RadioGroupOrientation.horizontal,
                  values: ["是", "否",],
                  indexOfDefault: (is_RECIPIENT==null)?-1:(is_RECIPIENT==true)?0:1,
                  decoration: RadioGroupDecoration(
                    spacing: 40.0.w,
                    labelStyle: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.sp
                    ),
                    activeColor: Colors.lightBlue,
                  ),
                  onChanged: (newValue){

                    if("${newValue}"=="是"){
                      is_RECIPIENT = true;
                    }
                    else{
                      is_RECIPIENT = false;
                    }
                    setState(() {

                    });

                  },
                )),
              ],),
              Container(height: 15.h,),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

               */

              //Container(height: 15.h,),
              Row(children: [
                Container(width: 10.w,),
                Text("請選擇須備物品:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ],),
              Container(height: 10.h,),

              Container(margin: EdgeInsets.only(left:10.w,right: 10.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                child: (DAILY_RQD_ITEMs_2.length==0 || sel_DAILY_RQD_ITEM.ITEM_NO=="")?Container():DropdownButton2<DAILY_RQD_ITEM>(
                  isExpanded: true,
                  items: DAILY_RQD_ITEMs_2
                      .map((DAILY_RQD_ITEM item) {
                        return DropdownMenuItem<DAILY_RQD_ITEM>(value: item, child: Text(
                      item.ITEM_NM,
                      style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      //overflow: TextOverflow.ellipsis,
                    ));
                      }
                  ).toList(),
                  value: sel_DAILY_RQD_ITEM,
                  onChanged: (value) {

                    sel_DAILY_RQD_ITEM = value!;
                    setState(() {

                    });

                  },
                  buttonStyleData:  ButtonStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    //height: 40.h,
                    width: 110.w,
                  ),
                  menuItemStyleData: MenuItemStyleData(
                    //height: 40.h,
                    padding: EdgeInsets.only(left: 14.w, right: 14.w),
                  ),
                ),
              ),),

              Container(height: 10.h,),
              /*
              Column(children: DAILY_RQD_ITEMs.map((e){

                return (e!=sel_DAILY_RQD_ITEM)?Container():Column(children: [

                  /*
                  Row(children: [

                    Container(width: 10.w,),
                    Expanded(child: Text("${e.ITEM_NM}",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: Color(0xff292929)))),
                    Container(width: 10.w,),

                  ],),

                   */
                  Row(children: [

                    Container(width: 10.w,),
                    Expanded(child: Container(
                        color: Color(0xffEEEEEE),
                        padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                        margin: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 0.h),
                        width:ScreenUtil().screenWidth,child: Form(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.blue,
                          ),
                          controller: e.num_textEditingController,
                          keyboardType: (e.ITEM_NM.contains("其他"))?TextInputType.text:TextInputType.number,
                          inputFormatters: (e.ITEM_NM.contains("其他"))?[]:[FilteringTextInputFormatter.digitsOnly],
                          autofocus: false,
                          maxLines: null,
                          //obscureText: !_adminVisible,
                          //obscureText: !_accountVisible,//This will obscure text dynamically
                          maxLength: (e.ITEM_NM.contains("其他"))?20:2,
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
                            hintText: (e.ITEM_NM.contains("其他"))?'':"請輸入數量",
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
                        )))),
                    Container(width: 10.w,),

                  ],),

                ],);

              }).toList(),),

               */
              Column(children: [

                /*
                  Row(children: [

                    Container(width: 10.w,),
                    Expanded(child: Text("${e.ITEM_NM}",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: Color(0xff292929)))),
                    Container(width: 10.w,),

                  ],),

                   */
                Row(children: [

                  Container(width: 10.w,),
                  Expanded(child: Container(
                      color: Color(0xffEEEEEE),
                      padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                      margin: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 0.h),
                      width:ScreenUtil().screenWidth,child: Form(
                      child: TextFormField(
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Colors.blue,
                        ),
                        controller: num_textEditingController,
                        keyboardType: (sel_DAILY_RQD_ITEM.ITEM_NM.contains("其他"))?TextInputType.text:TextInputType.number,
                        inputFormatters: (sel_DAILY_RQD_ITEM.ITEM_NM.contains("其他"))?[]:[
                          FilteringTextInputFormatter.digitsOnly,
                          //RemoveEmojiInputFormatter()
                        ],
                        autofocus: false,
                        maxLines: null,
                        //obscureText: !_adminVisible,
                        //obscureText: !_accountVisible,//This will obscure text dynamically
                        maxLength: (sel_DAILY_RQD_ITEM.ITEM_NM.contains("其他"))?20:2,
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
                          hintText: (sel_DAILY_RQD_ITEM.ITEM_NM.contains("其他"))?'':"請輸入數量",
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
                      )))),
                  Container(width: 10.w,),

                ],),

              ],),
              Container(height: 15.h,),
              Container(width: ScreenUtil().screenWidth,child: Row(children: [

                Expanded(child: Container()),
                Container(
                    padding: EdgeInsets.only( left:0.w,right: 0.w),
                    width: 62.w,
                    height: 45.h,
                    child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Color(0xffF9AA88)),
                          surfaceTintColor: MaterialStateProperty.all(Color(0xffF9AA88)),
                          padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6.w),
                                  side: BorderSide(color: Colors.transparent)
                              )
                          )
                      ),
                      onPressed: () async{

                        if(num_textEditingController.text.trim().isEmpty){
                          SmartDialog.showToast((sel_DAILY_RQD_ITEM.ITEM_NM.contains("其他"))?"請先輸入":"請先輸入數量");
                          return;
                        }

                        FocusScope.of(context).unfocus();
                        SEL_DAILY_RQD s = SEL_DAILY_RQD();
                        s.ITEM_NO = sel_DAILY_RQD_ITEM.ITEM_NO;
                        s.ITEM_NM = sel_DAILY_RQD_ITEM.ITEM_NM;
                        s.num = num_textEditingController.text;
                        sEL_DAILY_RQDs.add(s);

                        bool check = false;
                        DAILY_RQD_ITEMs_2.clear();
                        for(int i=0;i<DAILY_RQD_ITEMs.length;i++){
                          check = false;
                          for(int j=0;j<sEL_DAILY_RQDs.length;j++){
                             if(DAILY_RQD_ITEMs[i].ITEM_NO==sEL_DAILY_RQDs[j].ITEM_NO){
                               check = true;
                               break;
                             }
                          }

                          if(check==false){
                            DAILY_RQD_ITEMs_2.add(DAILY_RQD_ITEMs[i]);
                          }

                        }

                        if(DAILY_RQD_ITEMs_2.length>0){
                          sel_DAILY_RQD_ITEM = DAILY_RQD_ITEMs_2[0];
                        }


                        num_textEditingController.text="";
                        setState(() {

                        });

                      },
                      child: Row(children: [
                        Expanded(child: Container()),
                        Text('新增', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                        Expanded(child: Container()),
                      ],),
                    )),
                Container(width: 10.w,),

              ],),),
              Container(height: 15.h,),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 5.h,),
              Container(
                  padding: EdgeInsets.all(5.w),
                  width: ScreenUtil().screenWidth,child:Row(children: [

                    Text('*新增項目可左滑刪除', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 16.sp)),
                    Expanded(child: Container()),
                    Text('(數量)', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 16.sp)),

              ])),
              Expanded(child: ListView.builder(
                  padding: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
                  itemCount: sEL_DAILY_RQDs.length,
                  itemBuilder: (c,index){


                    return Column(children: [

                      Slidable(
                        // Specify a key if the Slidable is dismissible.
                        //key: ValueKey(0),

                        // The end action pane is the one at the right or the bottom side.
                          endActionPane:  ActionPane(
                            motion: ScrollMotion(),
                            extentRatio:0.25,
                            children: [
                              CustomSlidableAction(
                                autoClose: true,
                                backgroundColor: Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                onPressed: (BuildContext context) {
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
                                                        onPressed: () async{
                                                          Navigator.of(context).pop();
                                                        },
                                                      ),


                                                      TextButton(
                                                        child: Text('刪除',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                                        onPressed: () async{
                                                          Navigator.of(context).pop();
                                                          sEL_DAILY_RQDs.removeAt(index);

                                                          bool check = false;
                                                          DAILY_RQD_ITEMs_2.clear();
                                                          for(int i=0;i<DAILY_RQD_ITEMs.length;i++){
                                                            check = false;
                                                            for(int j=0;j<sEL_DAILY_RQDs.length;j++){
                                                              if(DAILY_RQD_ITEMs[i].ITEM_NO==sEL_DAILY_RQDs[j].ITEM_NO){
                                                                check = true;
                                                                break;
                                                              }
                                                            }

                                                            if(check==false){
                                                              DAILY_RQD_ITEMs_2.add(DAILY_RQD_ITEMs[i]);
                                                            }

                                                          }

                                                          if(DAILY_RQD_ITEMs_2.length>0){
                                                            sel_DAILY_RQD_ITEM = DAILY_RQD_ITEMs_2[0];
                                                          }

                                                          setState(() {

                                                          });
                                                        },
                                                      ),

                                                    ],
                                                  );
                                                }));
                                      });
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('刪除',textScaler: TextScaler.linear(1), style: TextStyle(fontSize: 18.sp)),
                                  ],
                                ),
                              ),

                            ],
                          ),

                          // The child of the Slidable is what the user sees when the
                          // component is not dragged.
                          child:Container(
                              color: Colors.lightBlueAccent.withOpacity(0.25),
                              padding: EdgeInsets.all(5.w),
                              width: ScreenUtil().screenWidth,child:Row(children: [

                                 Expanded(child:
                                 Text('${sEL_DAILY_RQDs[index].ITEM_NM}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp))),
                                 Container(width: 20.w,),
                                 Text('${sEL_DAILY_RQDs[index].num}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Colors.purple , fontSize: 18.sp)),
                                 Container(width: 10.w,),

                          ]))),
                      Container(height: 5.h,)

                    ],);


                  })),



            ],),
        )));
  }
}



class SEL_DAILY_RQD{
   String ITEM_NO="";
   String ITEM_NM="";
   String num = "";
}