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

class See_DAILY_MLK_page extends StatefulWidget {

  View_DAILY? view_DAILY;
  See_DAILY_MLK_page({View_DAILY? view_DAILY}){
    this.view_DAILY = view_DAILY;
  }
  @override
  State<See_DAILY_MLK_page> createState() => See_DAILY_MLK_pageState(view_DAILY:this.view_DAILY);
}

class See_DAILY_MLK_pageState extends State<See_DAILY_MLK_page> {

  TextEditingController CAPACITY_textEditingController = TextEditingController();//備註
  TextEditingController NOTE_textEditingController = TextEditingController();//備註

  DateTime? dateTime;
  TimeOfDay? timeOfDay;
  var showModalBottomSheet_image_context;

  DAILY_MLK_ITEM sel_DAILY_MLK_ITEM = DAILY_MLK_ITEM();

  View_DAILY? view_DAILY;
  See_DAILY_MLK_pageState({View_DAILY? view_DAILY}){
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
    await read_DAILY_MLK_ITEM_db_sub();
    dateTime = DateFormat("yyyy-MM-dd").parse(view_DAILY!.DATE);
    timeOfDay = TimeOfDay(hour:int.parse(view_DAILY!.TIME.split(":")[0]),minute: int.parse(view_DAILY!.TIME.split(":")[1]));
    await read_DAILY_MLK_db_sub(NO:view_DAILY!.NO,TYPE:view_DAILY!.TYPE);
    SmartDialog.dismiss();
    setState(() {

    });
  }

  Future<void> read_DAILY_MLK_ITEM_db_sub()async{

    DAILY_MLK_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_MLK_ITEM";
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

        List<DAILY_MLK_ITEM> _DAILY_MLK_ITEMs=[];
        for(int i=0;i<data_list.length;i++){
          DAILY_MLK_ITEM v = DAILY_MLK_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          _DAILY_MLK_ITEMs.add(v);
          //sel_DAILY_MLK_ITEM = DAILY_MLK_ITEMs[0];
        }
        DAILY_MLK_ITEMs = _DAILY_MLK_ITEMs;

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
  Future<void> read_DAILY_MLK_db_sub({
    String NO="",
    String TYPE="",
})async{

    String comm = "SELECT * FROM DAILY_MLK WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
        CAPACITY_textEditingController.text = "${data_list[0]["CAPACITY"]}";
        NOTE_textEditingController.text = "${data_list[0]["NOTE"]}";
        for(int i=0;i<DAILY_MLK_ITEMs.length;i++){
          if(DAILY_MLK_ITEMs[i].ITEM_NO=="${data_list[0]["ITEM"]}"){
            sel_DAILY_MLK_ITEM = DAILY_MLK_ITEMs[i];
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

    await updata_DAILY_MT_db_sub(
        TYPE:"MLK",
        NO:view_DAILY!.NO,//編號
        DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
        TIME:"${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00",//時間
        DEPM_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}",//學校
        CLASS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}",//班級
        CS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",//學生身分證字號
        USER_NO:"${EMPLOYEE_teacher.EMP_NO}",//系統自動帶入老師編號
    );


    //送出活動_副表
    await updata_DAILY_MLK_db_sub(
        TYPE:"MLK",
        NO:view_DAILY!.NO,//編號
        ITEM:"${sel_DAILY_MLK_ITEM.ITEM_NO}",//
        CAPACITY:"${CAPACITY_textEditingController.text}",//
        NOTE:"${NOTE_textEditingController.text}"
    );


    SmartDialog.dismiss();
    SmartDialog.showToast("處理成功");
    Student_T_page_fun!(action:"新增[托嬰]飲食(餵奶)成功");
    CAPACITY_textEditingController.text="";
    dateTime=null;
    timeOfDay=null;
    Navigator.pop(this_context!);



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
      })async{

    String comm = "UPDATE DAILY_MT SET DATE='${DATE}',TIME='${TIME}' WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
  Future<void> updata_DAILY_MLK_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        String ITEM="",//項目
        String CAPACITY="",//內容
        String NOTE="",//說明
      })async{

    String comm = "UPDATE DAILY_MLK SET ITEM='${ITEM}',CAPACITY='${CAPACITY}',NOTE='${NOTE}' WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
                  Navigator.pop(context);
                },
                child:Icon(Icons.arrow_back,size: 30.w,)),
                centerTitle: true,
                title: Text("${DAILY_MT_TYPE_ITEMs.firstWhere((e)=>e.ITEM_NO=="MLK").ITEM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              ),
          body: AbsorbPointer(
              absorbing: true, // true = 停用，false = 啟用
            child: ListView(
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
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                child: (sel_DAILY_MLK_ITEM.ITEM_NO=="")?Container():DropdownButton2<DAILY_MLK_ITEM>(
                  isExpanded: true,
                  items: DAILY_MLK_ITEMs
                      .map((DAILY_MLK_ITEM item) => DropdownMenuItem<DAILY_MLK_ITEM>(
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
                  value: sel_DAILY_MLK_ITEM,
                  onChanged: (value) {

                    sel_DAILY_MLK_ITEM = value!;
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
              Row(children: [
                Container(width: 10.w,),
                Text("容量:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ],),
              Container(
                  color: Color(0xffEEEEEE),
                  padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                  margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
                  width:ScreenUtil().screenWidth,child: Form(
                  child: TextFormField(
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.blue,
                    ),
                    controller: CAPACITY_textEditingController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      //RemoveEmojiInputFormatter()
                    ],
                    autofocus: false,
                    maxLines: null,
                    //obscureText: !_adminVisible,
                    //obscureText: !_accountVisible,//This will obscure text dynamically
                    maxLength: 3,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    //initialValue: 'edu_test010@ncku.com',
                    //inputFormatters: [EmailLimitFormatter()],
                    //validator: (value) => validateEmail(value!),
                    onChanged: (v){
                      //drug_reason.reason = v;
                    },
                    decoration: InputDecoration(
                      counterText: "",
                      filled: true, //<-- SEE HERE
                      fillColor: Colors.transparent, //<-- SEE HERE
                      hintText: '',
                      suffixText: "ml",
                      suffixStyle: TextStyle(fontSize: 20.sp,color: Colors.black),
                      hintStyle: TextStyle(fontWeight: FontWeight.bold,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
                      contentPadding:  EdgeInsets.only(left: 10.w,right: 10.w),
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
                  ))),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              //Container(height: 15.h,),
              /*
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


              //建立體溫，可選擇時間(幼兒園)
              (cLASSs.firstWhere((c) => c.CLASS_NO == '${CUSTOMER_selectedValue.CLASS_NO}',
                  orElse: () => CLASS()
              ).TYPE =="2")?
              Column(children: [
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
                Row(children: [
                  Container(width: 10.w,),
                  Text("說明:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929))),
                ],),
                Container(
                    color: Color(0xffEEEEEE),
                    padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                    margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
                    width:ScreenUtil().screenWidth,child: Form(
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Colors.blue,
                      ),
                      controller: NOTE_textEditingController,
                      keyboardType: TextInputType.multiline,
                      inputFormatters: [
                        //RemoveEmojiInputFormatter()
                        SingleQuoteToFullQuoteFormatter(),
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
                Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              ],)
                  :
              Container(),



            ],),
        ))));
  }
}
