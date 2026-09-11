import 'dart:convert';
import 'dart:io';
import 'package:code3/main2_T.dart';
import 'package:code3/signature2.dart';
import 'package:code3/signature4.dart';
import 'package:code3/signature5.dart';
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
import 'package:widget_zoom/widget_zoom.dart';
import 'dart:developer' as dev;
import 'FlexiblePageView_t.dart';
import 'api.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;

import 'utils/CustomAppBar.dart';

Function? DRUG_MT_T_page_fun1;
Function? DRUG_MT_T_page_fun2;
class DRUG_MT_T_page extends StatefulWidget {

  //DRUG_MT dRUG_MT = DRUG_MT();//用藥委託主表單(個人)
  //DRUG_MT_T_page({DRUG_MT? dRUG_MT}){
  //  this.dRUG_MT = dRUG_MT!;
  //}

  @override
  State<DRUG_MT_T_page> createState() => DRUG_MT_T_pageState();
}

class DRUG_MT_T_pageState extends State<DRUG_MT_T_page> {


  //DRUG_MT dRUG_MT = DRUG_MT();//用藥委託主表單(個人)
  //DRUG_MT_T_pageState({DRUG_MT? dRUG_MT}){
  //  this.dRUG_MT = dRUG_MT!;
  //}


  @override
  void initState() {
    // TODO: implement initState

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    DRUG_MT_T_page_fun1=(){
      setState(() {

      });
    };

    DRUG_MT_T_page_fun2=(){
      init(show_toast:false);
    };

    init();

  }

  void init({bool show_toast=true})async{

    MyHomePage2_T_fun1!(type:"刷新託藥訊息",show_toast:show_toast);
    //dRUG_MT.DRUG_DL_list.clear();
    await read_for_DRUG_DL_db_sub(DRUG_NO:dRUG_MT.DRUG_NO,show_toast:show_toast);
    setState(() {

    });

  }

  /*
  [托嬰/幼兒]用藥委託明細(個人) DRUG_DL
   */
  Future<void> read_for_DRUG_DL_db_sub({String DRUG_NO="",bool show_toast=true})async{
    FocusManager.instance.primaryFocus?.unfocus();
    if(show_toast==true) {
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
      if(data_list.length==0){
      }
      else{
        List<DRUG_DL> _DRUG_DL_lis = [];
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

          b.CMPT_NOTE1 = "${data_list[i]["CMPT_NOTE1"]}".contains("null")?"":"${data_list[i]["CMPT_NOTE1"]}";
          b.CMPT_NOTE2 = "${data_list[i]["CMPT_NOTE2"]}".contains("null")?"":"${data_list[i]["CMPT_NOTE2"]}";
          b.CMPT_NOTE3 = "${data_list[i]["CMPT_NOTE3"]}".contains("null")?"":"${data_list[i]["CMPT_NOTE3"]}";

          b.CMPT1_NOTE_textEditingController.text = b.CMPT_NOTE1;
          b.CMPT2_NOTE_textEditingController.text = b.CMPT_NOTE2;
          b.CMPT3_NOTE_textEditingController.text = b.CMPT_NOTE3;

          b.DRUG_LINK = "${data_list[i]["DRUG_LINK"]}".contains("null")?"":"${data_list[i]["DRUG_LINK"]}";
          b.NOTE = "${data_list[i]["NOTE"]}".contains("null")?"":"${data_list[i]["NOTE"]}";
          b.CMPT_SIGN1 = "${data_list[i]["CMPT_SIGN1"]}".contains("null")?"":"${data_list[i]["CMPT_SIGN1"]}";
          b.CMPT_SIGN2 = "${data_list[i]["CMPT_SIGN2"]}".contains("null")?"":"${data_list[i]["CMPT_SIGN2"]}";
          b.CMPT_SIGN3 = "${data_list[i]["CMPT_SIGN3"]}".contains("null")?"":"${data_list[i]["CMPT_SIGN3"]}";
          b.CMPT_Time1 = "${data_list[i]["CMPT_Time1"]}".contains("null")?"":"${data_list[i]["CMPT_Time1"]}";
          b.CMPT_Time2 = "${data_list[i]["CMPT_Time2"]}".contains("null")?"":"${data_list[i]["CMPT_Time2"]}";
          b.CMPT_Time3 = "${data_list[i]["CMPT_Time3"]}".contains("null")?"":"${data_list[i]["CMPT_Time3"]}";
          String DRUG_LINK = b.DRUG_LINK.replaceAll("~/", "");
          b.DRUG_LINK = "${IMAGE_IP}/${DRUG_LINK}";

          String CMPT_SIGN1 = b.CMPT_SIGN1.replaceAll("~/", "");
          b.CMPT_SIGN1 = "${IMAGE_IP}/${CMPT_SIGN1}";

          String CMPT_SIGN2 = b.CMPT_SIGN2.replaceAll("~/", "");
          b.CMPT_SIGN2 = "${IMAGE_IP}/${CMPT_SIGN2}";

          String CMPT_SIGN3 = b.CMPT_SIGN3.replaceAll("~/", "");
          b.CMPT_SIGN3 = "${IMAGE_IP}/${CMPT_SIGN3}";

          _DRUG_DL_lis.add(b);

        }

        dRUG_MT.DRUG_DL_list = _DRUG_DL_lis;

        setState(() {

        });




      }



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.dismiss();
      SmartDialog.showToast("網路異常");
    }
  }


  Future<void> upload_xxx_from_DRUG_DL_db({String CMPT_SIGNx="",String CMPT_SIGN_img="",String CMPT_Time=""})async{
    String comm="";
    if(CMPT_SIGN_img.isNotEmpty){
      comm = "UPDATE DRUG_DL SET ${CMPT_SIGNx}='${CMPT_SIGN_img}' WHERE DRUG_NO='${dRUG_MT.DRUG_DL_list[0].DRUG_NO}' AND DRUG_SR='${dRUG_MT.DRUG_DL_list[0].DRUG_SR}'";
    }
    if(CMPT_Time.isNotEmpty){
      comm = "UPDATE DRUG_DL SET ${CMPT_SIGNx}='${CMPT_Time}' WHERE DRUG_NO='${dRUG_MT.DRUG_DL_list[0].DRUG_NO}' AND DRUG_SR='${dRUG_MT.DRUG_DL_list[0].DRUG_SR}'";
    }

    dev.log("${comm}");
    String result = await sql_command("${comm}");

  }



  @override
  Widget build(BuildContext context) {


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
          backgroundColor: Color(0xfffff6dc),
          appBar: CustomAppBar(
            backgroundColor: Color(0xffF9AA88),
            toolbarHeight:42.h,
            leading: GestureDetector(
                onTap: (){
                  //MyHomePage2_U_fun1!();
                  Navigator.pop(context);
                },
                child:Icon(Icons.arrow_back,size: 30.w,)),
            centerTitle: true,
            actions: [
              //Text("儲存", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              Container(width: 20.w,),
            ],
            title: Text("用藥委託", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
          ),
      body: dRUG_MT.DRUG_NO==""?
      ListView(
        padding: EdgeInsets.all(10),
        children: [
          Container(height: 100.h,),
          Text("此委託不存在\n或被家長收回",textAlign: TextAlign.center,style: TextStyle(
              fontFamily: "GenJyuuGothic",
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
              color: Color(0xff555555)))
        ],)
          :
      ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(left:10.w,right: 10.w),
        children: [

          Container(width: ScreenUtil().screenWidth,
            child: Column(children: [

              Container(height: 10.h,),
              Row(children: [
                Expanded(child: Container()),
                Text("${dRUG_MT.DateStr}",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                    color: Color(0xffE8885E))),
                Expanded(child: Container()),
              ],),
              Container(height: 6.h,),
              Row(children: [
                Expanded(child: Container()),
                Text("用藥日期:${dRUG_MT.DATE}",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.w400,
                    fontSize: 18.sp,
                    color: Colors.blue)),
                Expanded(child: Container()),
              ]),
              Container(height: 10.h,),
              Row(children: [
                Container(width: 10.w,),
                Container(
                  width:60.w,
                  height: 60.w,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                      color: Color(0xffEEE9E0),
                      borderRadius: BorderRadius.circular(10.w),
                      border: Border.all(
                        width: 1,
                        color: Color(0xffEEE9E0),
                      )),child: SvgPicture.asset("assets/images/组 29164.svg"),),
                Container(width: 6.w,),
                Expanded(child:Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                        color: Color(0xffffe38e),
                        borderRadius: BorderRadius.circular(10.w),
                        ),
                    child:Center(child:Text("${dRUG_MT.REASON}",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.w400,
                    fontSize: 18.sp,
                    color: Color(0xff555555)))))),
                Container(width: 10.w,),
              ],),

            ],),),

          Container(height: 10.h,),


          Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.w),
                border: Border.all(color: Colors.grey)
              ),
              child:Column(children: [
            Container(width: ScreenUtil().screenWidth,height: 250.h,child:WidgetZoom(
              heroAnimationTag: "${dRUG_MT.DRUG_LINK}",
              zoomWidget:
            Image.network("${dRUG_MT.DRUG_LINK}",
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return  Icon(Icons.error,size: 30.sp,);
              },
            ))),
            Container(height: 3.h,),
            Container(
              width: 200.w,
              padding: EdgeInsets.only(top: 10.w,bottom: 10.w),
              decoration: BoxDecoration(
                color: Color(0xffffe38e),
                borderRadius: BorderRadius.circular(30.w),
              ),
              child:Center(child:Text("藥單封面",style: TextStyle(
                  fontFamily: "GenJyuuGothic",
                  fontWeight: FontWeight.w400,
                  fontSize: 18.sp,
                  color: Colors.black)))),

          ],)),

          Container(height: 15.h,),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
                color: Color(0xffffe38e),
                borderRadius: BorderRadius.circular(0.w),
            ),
            child:Column(children: [

              Row(children: [
                Expanded(child:
                Text("我委託幼兒園依照上述明細用藥，並對此用藥明細負起全部責任(同意簽名)",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.w400,
                    fontSize: 18.sp,
                    color: Colors.black))),
              ]),
              Container(height: 3.h,),
              Container(width: ScreenUtil().screenWidth,height: 120.h,child:
              Image.network(
                "${dRUG_MT.SIGN_LINK}",
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return  Icon(Icons.error,size: 30.sp,);
                },
              )),

            ],)),
          Container(height: 15.h,),
          Container(width: ScreenUtil().screenWidth,height: 1,color: Color(0xff555555),),
          Container(height: 6.h,),

          (dRUG_MT.DRUG_DL_list.length==0)?Container():
          FlexiblePageView_t(),

          /*
          (dRUG_MT.DRUG_DL_list.length==0)?Container():
          Column(children: dRUG_MT.DRUG_DL_list.map((e) {

            String _STORE = "";
            String _MODE = "";
            String _UNIT = "";
            String _DOSAGE = "";

            try{
              _STORE = dRUG_STORE.DRUG_STORE_ITEM_list.firstWhere((element) => element.ITEM_NO==e.STORE).ITEM_NM;
            }
            catch(e){

            }
            try{
              _MODE = dRUG_MODE.DRUG_MODE_ITEM_list.firstWhere((element) => element.ITEM_NO==e.MODE).ITEM_NM;
            }
            catch(e){

            }
            try{
              _UNIT = DRUG_UNIT_ITEM_list.firstWhere((element) => element.ITEM_NO==e.UNIT).ITEM_NM;
            }
            catch(e){

            }
            try{
              _DOSAGE = e.DOSAGE.replaceAll("\n", "").replaceAll("\r", "").replaceAll(" ", "");
            }
            catch(e){

            }


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
                Text("用藥委託明細(${dRUG_MT.DRUG_DL_list.indexOf(e)+1})",style: TextStyle(
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
              Container(height: 20.h,),
              Container(width: ScreenUtil().screenWidth,height: 180.h,child: Image.network("${e.DRUG_LINK}",errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return  Icon(Icons.error,size: 30.sp,);
              },),),
              Container(height: 20.h,),
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
                      timeOfDay4 = TimeOfDay.fromDateTime(datetime);
                      e.CMPT_Time1 = "${timeOfDay4!.hour.toString().padLeft(2, '0')}:${timeOfDay4!.minute.toString().padLeft(2, '0')}:00";

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
                        timeOfDay4 = _timeOfDay;
                        e.CMPT_Time1 = "${timeOfDay4!.hour.toString().padLeft(2, '0')}:${timeOfDay4!.minute.toString().padLeft(2, '0')}:00";
                      }
                      dev.log("${timeOfDay4!.format(context)}");


                      setState(() {

                      });

                     */

                  },
                  child: Row(children: [

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
                  ),
                  Container(width: 5.w,),
                  (timeOfDay4==null)?Container(
                    width:100.w,
                    height:40.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.w),
                    ),
                  ):Container()

                ],)),
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
                  GestureDetector(
                      onTap:(){


                        showCupertinoDialog(
                            context: context,
                            builder: (context) {
                              return Scaffold(
                                  backgroundColor: Color(0x20000000),
                                  body: StatefulBuilder(
                                      builder: (context, state) {
                                        return CupertinoAlertDialog(
                                          title: Text('請選擇操作', maxLines: 2,
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
                                              child: Text('匯入預設簽名',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp)),
                                              onPressed: () async{
                                                Navigator.of(context).pop();
                                                if(EMPLOYEE_teacher.SIGN_LINK.isEmpty){
                                                  SmartDialog.showToast("請先至設定頁>帳號相關>輸入預設簽名");
                                                  return;
                                                }
                                                SmartDialog.showLoading(msg: "處理中...");
                                                await Future.delayed(const Duration(milliseconds: 500), () {});
                                                e.signaturebytes1 = await get_url_image_to_byte_sub(img_url:"${EMPLOYEE_teacher.SIGN_LINK}");
                                                SmartDialog.dismiss();
                                                SmartDialog.showToast("處理成功");
                                                setState(() {

                                                });
                                              },
                                            ),

                                            TextButton(
                                              child: Text('手動簽名',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator.push(context, PageTransition(
                                                    type: PageTransitionType.rightToLeft, child: SignaturePage5(CMPT_SIGNx:"CMPT_SIGN1")));
                                              },
                                            ),

                                            TextButton(
                                              child: Text('取消',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                              onPressed: () async{
                                                Navigator.of(context).pop();
                                              },
                                            ),

                                          ],
                                        );
                                      }));
                            });

                      },
                      child:
                      Container(width: ScreenUtil().screenWidth,height: 150.h,child:
                      (e.signaturebytes1!=null)?
                      Container(width: ScreenUtil().screenWidth,height: 100.h,child:
                      Image.memory(e.signaturebytes1!))
                          :
                      Image.network(
                        "${e.CMPT_SIGN1}",
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return
                          Container(padding: EdgeInsets.only(top: 10.h,bottom: 10.h),color: Color(0x01000000),width: ScreenUtil().screenWidth,child:Center(child:Text("老師請按此簽名",style: TextStyle(decoration: TextDecoration.underline,fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w700,color: Color(0xff292929) , fontSize: 18.sp))));

                        },
                      ),)),
                  Container(height: 10.h,),
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

                          if(e.signaturebytes1==null && e.CMPT_SIGN1.isEmpty){
                            SmartDialog.showToast("請先簽名");
                            return;
                          }

                          if(e.CMPT_Time1.isEmpty){
                            SmartDialog.showToast("請填寫完成時間");
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
                                      Container(
                                          width: ScreenUtil().screenWidth, child: Column(children: [


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

                                        if(e.signaturebytes1!=null){
                                          String file_name = "${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}";
                                          await upload_image(img: e.signaturebytes1,file_name: file_name,folder: "Sign");
                                          String SIGN_LINK = "~/School/Images/Sign/${file_name}.jpg";//老師簽名
                                          await upload_xxx_from_DRUG_DL_db(
                                            CMPT_SIGNx: "CMPT_SIGN1",
                                            CMPT_SIGN_img:SIGN_LINK,
                                          );//上傳老師委藥(簽名檔)
                                        }

                                        if(e.CMPT_Time1.isNotEmpty){
                                          await upload_xxx_from_DRUG_DL_db(
                                            CMPT_SIGNx: "CMPT_Time1",
                                            CMPT_Time:e.CMPT_Time1,
                                          );//上傳老師委藥(簽名檔)
                                        }

                                        Fluttertoast.showToast(
                                            msg: "送出成功",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.black,
                                            textColor: Colors.white,
                                            fontSize: 16.0.sp
                                        );

                                        Future.delayed(const Duration(milliseconds: 50), () {

                                          init(show_toast:false);

                                        });



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
                ]),
                padding:EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                    color: Color(0xffEEE9E0),
                    borderRadius: BorderRadius.circular(10.w),
                    border: Border.all(
                      width: 1,
                      color: Color(0xffEEE9E0),
                    )),
              ),
              Container(height: 10.h,),
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
                      timeOfDay5 = TimeOfDay.fromDateTime(datetime);
                      e.CMPT_Time2 = "${timeOfDay5!.hour.toString().padLeft(2, '0')}:${timeOfDay5!.minute.toString().padLeft(2, '0')}:00";
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
                    timeOfDay5 = _timeOfDay;
                    e.CMPT_Time2 = "${timeOfDay5!.hour.toString().padLeft(2, '0')}:${timeOfDay5!.minute.toString().padLeft(2, '0')}:00";
                  }
                  dev.log("${timeOfDay5!.format(context)}");

                  setState(() {

                  });

                     */

                  },
                  child: Row(children: [


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
                          ),
                          Container(width: 5.w,),
                          (timeOfDay5==null)?Container(
                            width:100.w,
                            height:40.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5.w),
                            ),
                          ):Container()

                        ],)),
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
                  GestureDetector(
                      onTap:(){


                        showCupertinoDialog(
                            context: context,
                            builder: (context) {
                              return Scaffold(
                                  backgroundColor: Color(0x20000000),
                                  body: StatefulBuilder(
                                      builder: (context, state) {
                                        return CupertinoAlertDialog(
                                          title: Text('請選擇操作', maxLines: 2,
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
                                              child: Text('匯入預設簽名',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp)),
                                              onPressed: () async{
                                                Navigator.of(context).pop();
                                                if(EMPLOYEE_teacher.SIGN_LINK.isEmpty){
                                                  SmartDialog.showToast("請先至設定頁>帳號相關>輸入預設簽名");
                                                  return;
                                                }
                                                SmartDialog.showLoading(msg: "處理中...");
                                                e.signaturebytes2 = await get_url_image_to_byte_sub(img_url:"${EMPLOYEE_teacher.SIGN_LINK}");
                                                SmartDialog.dismiss();
                                                SmartDialog.showToast("處理成功");
                                                setState(() {

                                                });
                                              },
                                            ),

                                            TextButton(
                                              child: Text('手動簽名',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator.push(context, PageTransition(
                                                    type: PageTransitionType.rightToLeft, child: SignaturePage5(CMPT_SIGNx:"CMPT_SIGN2")));
                                              },
                                            ),

                                            TextButton(
                                              child: Text('取消',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                              onPressed: () async{
                                                Navigator.of(context).pop();
                                              },
                                            ),

                                          ],
                                        );
                                      }));
                            });

                      },
                      child:
                  Container(width: ScreenUtil().screenWidth,height: 150.h,child:(e.signaturebytes2!=null)?
                  Container(width: ScreenUtil().screenWidth,height: 100.h,child:
                  Image.memory(e.signaturebytes2!))
                      :
                  Image.network(
                    "${e.CMPT_SIGN2}",
                    errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return
                      Container(padding: EdgeInsets.only(top: 10.h,bottom: 10.h),color: Color(0x01000000),width: ScreenUtil().screenWidth,child:Center(child:Text("老師請按此簽名",style: TextStyle(decoration: TextDecoration.underline,fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w700,color: Color(0xff292929) , fontSize: 18.sp))));

                    },
                  ),)),
                  Container(height: 10.h,),
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

                          if(e.signaturebytes2==null && e.CMPT_SIGN2.isEmpty){
                            SmartDialog.showToast("請先簽名");
                            return;
                          }

                          if(e.CMPT_Time2.isEmpty){
                            SmartDialog.showToast("請填寫完成時間");
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
                                      Container(
                                          width: ScreenUtil().screenWidth, child: Column(children: [


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

                                        if(e.signaturebytes2!=null){
                                          String file_name = "${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}";
                                          await upload_image(img: e.signaturebytes2,file_name: file_name,folder: "Sign");
                                          String SIGN_LINK = "~/School/Images/Sign/${file_name}.jpg";//老師簽名
                                          await upload_xxx_from_DRUG_DL_db(
                                            CMPT_SIGNx: "CMPT_SIGN2",
                                            CMPT_SIGN_img:SIGN_LINK,
                                          );//上傳老師委藥(簽名檔)
                                        }

                                        if(e.CMPT_Time2.isNotEmpty){
                                          await upload_xxx_from_DRUG_DL_db(
                                            CMPT_SIGNx: "CMPT_Time2",
                                            CMPT_Time:e.CMPT_Time2,
                                          );//上傳老師委藥(簽名檔)
                                        }

                                        Fluttertoast.showToast(
                                            msg: "送出成功",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.black,
                                            textColor: Colors.white,
                                            fontSize: 16.0.sp
                                        );

                                        Future.delayed(const Duration(milliseconds: 50), () {

                                          init(show_toast:false);

                                        });



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
              Container(height: 10.h,),
              (timeOfDay3==null)?Container():
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
                      timeOfDay6 = TimeOfDay.fromDateTime(datetime);
                      e.CMPT_Time3 = "${timeOfDay6!.hour.toString().padLeft(2, '0')}:${timeOfDay6!.minute.toString().padLeft(2, '0')}:00";

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
                    timeOfDay6 = _timeOfDay;
                    e.CMPT_Time3 = "${timeOfDay6!.hour.toString().padLeft(2, '0')}:${timeOfDay6!.minute.toString().padLeft(2, '0')}:00";
                  }
                  dev.log("${timeOfDay6!.format(context)}");

                  setState(() {

                  });

                     */

                  },
                  child:
                  Row(children: [

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
                          ),
                          Container(width: 5.w,),
                          (timeOfDay6==null)?Container(
                            width:100.w,
                            height:40.h,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5.w),
                            ),
                          ):Container()

                        ],)),
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
                  GestureDetector(
                      onTap:(){

                        showCupertinoDialog(
                            context: context,
                            builder: (context) {
                              return Scaffold(
                                  backgroundColor: Color(0x20000000),
                                  body: StatefulBuilder(
                                      builder: (context, state) {
                                        return CupertinoAlertDialog(
                                          title: Text('請選擇操作', maxLines: 2,
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
                                              child: Text('匯入預設簽名',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp)),
                                              onPressed: () async{
                                                Navigator.of(context).pop();
                                                if(EMPLOYEE_teacher.SIGN_LINK.isEmpty){
                                                  SmartDialog.showToast("請先至設定頁>帳號相關>輸入預設簽名");
                                                  return;
                                                }
                                                SmartDialog.showLoading(msg: "處理中...");
                                                e.signaturebytes3 = await get_url_image_to_byte_sub(img_url:"${EMPLOYEE_teacher.SIGN_LINK}");
                                                SmartDialog.dismiss();
                                                SmartDialog.showToast("處理成功");
                                                setState(() {

                                                });
                                              },
                                            ),

                                            TextButton(
                                              child: Text('手動簽名',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp)),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator.push(context, PageTransition(
                                                    type: PageTransitionType.rightToLeft, child: SignaturePage5(CMPT_SIGNx:"CMPT_SIGN3")));

                                              },
                                            ),

                                            TextButton(
                                              child: Text('取消',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                              onPressed: () async{
                                                Navigator.of(context).pop();
                                              },
                                            ),

                                          ],
                                        );
                                      }));
                            });

                      },
                      child:
                      Container(width: ScreenUtil().screenWidth,height: 150.h,child:
                      (e.signaturebytes3!=null)?
                      Container(width: ScreenUtil().screenWidth,height: 100.h,child:
                      Image.memory(e.signaturebytes3!))
                          :
                      Image.network(
                        "${e.CMPT_SIGN3}",
                        errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return
                          Container(padding: EdgeInsets.only(top: 10.h,bottom: 10.h),color: Color(0x01000000),width: ScreenUtil().screenWidth,child:Center(child:Text("老師請按此簽名",style: TextStyle(decoration: TextDecoration.underline,fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w700,color: Color(0xff292929) , fontSize: 18.sp))));

                        },
                      ),)),
                  Container(height: 10.h,),
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


                          if(e.signaturebytes3==null && e.CMPT_SIGN3.isEmpty){
                            SmartDialog.showToast("請先簽名");
                            return;
                          }

                          if(e.CMPT_Time3.isEmpty){
                            SmartDialog.showToast("請填寫完成時間");
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
                                      Container(
                                          width: ScreenUtil().screenWidth, child: Column(children: [


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

                                        if(e.signaturebytes3!=null){
                                          String file_name = "${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}";
                                          await upload_image(img: e.signaturebytes3,file_name: file_name,folder: "Sign");
                                          String SIGN_LINK = "~/School/Images/Sign/${file_name}.jpg";//老師簽名
                                          await upload_xxx_from_DRUG_DL_db(
                                            CMPT_SIGNx: "CMPT_SIGN3",
                                            CMPT_SIGN_img:SIGN_LINK,
                                          );//上傳老師委藥(簽名檔)
                                        }

                                        if(e.CMPT_Time3.isNotEmpty){
                                          await upload_xxx_from_DRUG_DL_db(
                                            CMPT_SIGNx: "CMPT_Time3",
                                            CMPT_Time:e.CMPT_Time3,
                                          );//上傳老師委藥(簽名檔)
                                        }

                                        Fluttertoast.showToast(
                                            msg: "送出成功",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.black,
                                            textColor: Colors.white,
                                            fontSize: 16.0.sp
                                        );

                                        Future.delayed(const Duration(milliseconds: 50), () {

                                          init(show_toast:false);

                                        });



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

           */


        ],),
    )));
  }
}
