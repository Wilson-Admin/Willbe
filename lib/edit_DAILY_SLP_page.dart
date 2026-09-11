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
import 'main2_U.dart';
import 'sql.dart';
import 'package:badges/badges.dart' as badges;
import 'package:http/http.dart' as http;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;

import 'utils/CustomAppBar.dart';


class Edit_DAILY_SLP_page extends StatefulWidget {

  View_DAILY? view_DAILY;
  Edit_DAILY_SLP_page({View_DAILY? view_DAILY}){
    this.view_DAILY = view_DAILY;
  }
  @override
  State<Edit_DAILY_SLP_page> createState() => Edit_DAILY_SLP_pageState(view_DAILY:this.view_DAILY);
}

class Edit_DAILY_SLP_pageState extends State<Edit_DAILY_SLP_page> {


  DateTime? dateTime;
  TimeOfDay? timeOfDay;
  var showModalBottomSheet_image_context;

  DAILY_SLP_STATUS_ITEM sel_DAILY_SLP_STATUS_ITEM = DAILY_SLP_STATUS_ITEM();

  //TimeOfDay? ST_TIME;
  //TimeOfDay? END_TIME;

  bool? is_RECIPIENT;//讀取回條
  RadioGroupController is_RECIPIENT_radioGroup_controller = RadioGroupController();

  View_DAILY? view_DAILY;
  Edit_DAILY_SLP_pageState({View_DAILY? view_DAILY}){
    this.view_DAILY = view_DAILY;
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

    init();
  }


  void init()async{
    SmartDialog.showLoading(msg: 'loading...');
    dateTime = DateFormat("yyyy-MM-dd").parse(view_DAILY!.DATE);
    timeOfDay = TimeOfDay(hour:int.parse(view_DAILY!.TIME.split(":")[0]),minute: int.parse(view_DAILY!.TIME.split(":")[1]));
    await read_DAILY_SLP_db_sub(NO:view_DAILY!.NO,TYPE:view_DAILY!.TYPE);
    SmartDialog.dismiss();
    setState(() {

    });
  }

  /*

   */
  Future<void> read_DAILY_SLP_db_sub({
    String NO="",
    String TYPE="",
})async{

    String comm = "SELECT * FROM DAILY_SLP WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

        is_RECIPIENT = ("${data_list[0]["RECIPIENT"]}"=="1"||"${data_list[0]["RECIPIENT"]}"=="true")?true:false;
        is_RECIPIENT_radioGroup_controller.selectAt(("${data_list[0]["RECIPIENT"]}"=="1"||"${data_list[0]["RECIPIENT"]}"=="true")?0:1);
        //List<String> str = "${data_list[0]["ST_TIME"]}".split(" ");
        //ST_TIME = TimeOfDay(hour:int.parse(str[1].split(":")[0]),minute: int.parse(str[1].split(":")[1]));
        //str = "${data_list[0]["END_TIME"]}".split(" ");
        //END_TIME = TimeOfDay(hour:int.parse(str[1].split(":")[0]),minute: int.parse(str[1].split(":")[1]));
        for(int i=0;i<DAILY_SLP_STATUS_ITEMs.length;i++){
          if(DAILY_SLP_STATUS_ITEMs[i].ITEM_NO=="${data_list[0]["STATUS"]}"){
            sel_DAILY_SLP_STATUS_ITEM = DAILY_SLP_STATUS_ITEMs[i];
            break;
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



  /*
  上傳新一筆托嬰活動
   */
  Future<void> update_DAILY_MT_db_sub()async{

    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});

    String MARK = "${sel_DAILY_SLP_STATUS_ITEM.ITEM_NM}";
    await updata_DAILY_MT_db_sub(
        TYPE:"SLP",
        NO:view_DAILY!.NO,//編號
        DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
        TIME:"${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00",//時間
        DEPM_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}",//學校
        CLASS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}",//班級
        CS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",//學生身分證字號
        USER_NO:"${EMPLOYEE_teacher.EMP_NO}",//系統自動帶入老師編號
        MARK:MARK
    );


    //送出活動_副表
    await updata_DAILY_SLP_db_sub(
      TYPE:"SLP",
      NO:view_DAILY!.NO,//編號
      ST_TIME:"",//"${ST_TIME!.hour.toString().padLeft(2, '0')}:${ST_TIME!.minute.toString().padLeft(2, '0')}:00",//時間
      END_TIME:"",//"${END_TIME!.hour.toString().padLeft(2, '0')}:${END_TIME!.minute.toString().padLeft(2, '0')}:00",//時間
      STATUS:"${sel_DAILY_SLP_STATUS_ITEM.ITEM_NO}",//
      RECIPIENT:is_RECIPIENT,//
    );

    SmartDialog.dismiss();
    SmartDialog.showToast("處理成功");
    Student_T_page_fun!(action:"新增[托嬰/幼兒]睡覺成功");
    dateTime=null;
    timeOfDay=null;
    Navigator.pop(this_context!);



  }

  Future<void>delete_DAILY_PIC_DL_db_sub({String NO=""})async{

    //await EasyLoading.show(status: "處理中...");
    String comm = "DELETE FROM DAILY_PIC_DL WHERE NO='${NO}'";
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
活動_副表
   */
  Future<void> updata_DAILY_SLP_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        String ST_TIME="",//開始時間
        String END_TIME="",//結束時間
        String STATUS="",//狀態
        bool? RECIPIENT,//讀取回條
      })async{

    String comm = "UPDATE DAILY_SLP SET ST_TIME='${ST_TIME}',END_TIME='${END_TIME}',STATUS='${STATUS}',RECIPIENT='${RECIPIENT}' WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
  活動_子表
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
    String comm = "SELECT * FROM View_DAILY WHERE DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";
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

                  bool check = false;
                  if(dateTime!=null){
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


                        if(dateTime==null){
                          SmartDialog.showToast("請輸入活動日期");
                          return;
                        }

                        if(timeOfDay==null){
                          SmartDialog.showToast("請輸入活動時間");
                          return;
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
                                                update_DAILY_MT_db_sub();
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
                title: Text("編輯${DAILY_MT_TYPE_ITEMs.firstWhere((e)=>e.ITEM_NO=="SLP").ITEM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              ),
          body:ListView(
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
                Text("請選擇狀態:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ],),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                child: (sel_DAILY_SLP_STATUS_ITEM.ITEM_NO.isEmpty)?Container():DropdownButton2<DAILY_SLP_STATUS_ITEM>(
                  isExpanded: true,
                  items: DAILY_SLP_STATUS_ITEMs
                      .map((DAILY_SLP_STATUS_ITEM item) => DropdownMenuItem<DAILY_SLP_STATUS_ITEM>(
                    value: item,
                    child: Text(
                      item.ITEM_NM,
                      style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color:  Colors.blue,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
                      .toList(),
                  value: sel_DAILY_SLP_STATUS_ITEM,
                  onChanged: (value) {

                    sel_DAILY_SLP_STATUS_ITEM = value!;
                    setState(() {

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
              ),),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 15.h,),
              /*
              Row(children: [
                Container(width: 10.w,),
                Text("開始時間:",style: TextStyle(
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

                      ST_TIME = TimeOfDay.fromDateTime(datetime);
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
                      ST_TIME = _timeOfDay;
                    }
                    dev.log("${ST_TIME!.format(context)}");

                    setState(() {

                    });

                     */

                  },
                  child:
                  Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child:Row(children: [

                    Container(width: 5.w,),
                    Text((ST_TIME==null)?"":"${ST_TIME!.period==DayPeriod.am?"上午":"下午"}${ST_TIME!.hourOfPeriod}:${ST_TIME!.minute.toString().padLeft(2,"0")}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w700,color: Colors.blue , fontSize: 16.sp)),
                    Container(width: 5.w,),

                  ],)
                  )),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 15.h,),
              Row(children: [
                Container(width: 10.w,),
                Text("結束時間:",style: TextStyle(
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

                      END_TIME = TimeOfDay.fromDateTime(datetime);
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
                      END_TIME = _timeOfDay;
                    }
                    dev.log("${END_TIME!.format(context)}");

                    setState(() {

                    });

                     */

                  },
                  child:
                  Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child:Row(children: [

                    Container(width: 5.w,),
                    Text((END_TIME==null)?"":"${END_TIME!.period==DayPeriod.am?"上午":"下午"}${END_TIME!.hourOfPeriod}:${END_TIME!.minute.toString().padLeft(2,"0")}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w700,color: Colors.blue , fontSize: 16.sp)),
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
                  },
                )),
              ],),
              Container(height: 15.h,),
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


            ],),
        )));
  }
}
