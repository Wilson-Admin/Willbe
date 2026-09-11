import 'dart:convert';
import 'dart:io';
import 'package:code3/main2_T.dart';
import 'package:code3/signature2.dart';
import 'package:code3/signature4.dart';
import 'package:code3/student_T.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:radio_group_v2/radio_group_v2.dart' as rg;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'package:signature/signature.dart';
import 'package:widget_zoom/widget_zoom.dart';
import 'dart:developer' as dev;
import 'api.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'package:badges/badges.dart' as badges;
import 'package:http/http.dart' as http;

import 'utils/CustomAppBar.dart';

class See_DAILY_CND_page extends StatefulWidget {

  View_DAILY? view_DAILY;
  See_DAILY_CND_page({View_DAILY? view_DAILY}){
    this.view_DAILY = view_DAILY;
  }

  @override
  State<See_DAILY_CND_page> createState() => See_DAILY_CND_pageState(view_DAILY:this.view_DAILY);
}

class See_DAILY_CND_pageState extends State<See_DAILY_CND_page> {

  TextEditingController OTHER_textEditingController = TextEditingController();//備註

  DateTime? dateTime;
  TimeOfDay? timeOfDay;
  var showModalBottomSheet_image_context;

  List<DAILY_PIC_DL> DAILY_PIC_DLs = [];//活動_子表

  bool? is_NORMAL=false;//正常
  rg.RadioGroupController is_NORMAL_radioGroup_controller = rg.RadioGroupController();

  bool? is_FEVER=false;//發燒
  rg.RadioGroupController is_FEVER_radioGroup_controller = rg.RadioGroupController();
  TextEditingController FEVER_TEMP_textEditingController = TextEditingController();//發燒溫度
  TextEditingController FEVER_NOTE_textEditingController = TextEditingController();//發燒說明

  bool? is_NASAL=false;//鼻塞
  rg.RadioGroupController is_NASAL_radioGroup_controller = rg.RadioGroupController();
  DAILY_CND_NASAL_STATUS_ITEM sel_DAILY_CND_NASAL_STATUS_ITEM = DAILY_CND_NASAL_STATUS_ITEMs[0];
  TextEditingController NASAL_NOTE_textEditingController = TextEditingController();//鼻塞說明


  bool? is_RUNNY_NOSE=false;//流鼻涕
  rg.RadioGroupController is_RUNNY_NOSE_radioGroup_controller = rg.RadioGroupController();
  DAILY_CND_RUNNY_COLOR_ITEM sel_DAILY_CND_RUNNY_COLOR_ITEM = DAILY_CND_RUNNY_COLOR_ITEMs[0];//流鼻涕顏色
  DAILY_CND_RUNNY_TYPE_ITEM sel_DAILY_CND_RUNNY_TYPE_ITEM = DAILY_CND_RUNNY_TYPE_ITEMs[0];//流鼻涕種類
  DAILY_CND_RUNNY_QUANTITY_ITEM sel_DAILY_CND_RUNNY_QUANTITY_ITEM = DAILY_CND_RUNNY_QUANTITY_ITEMs[0];//流鼻涕數量
  TextEditingController RUNNY_NOSE_NOTE_textEditingController = TextEditingController();//流鼻涕說明


  bool? is_COUGH=false;//咳嗽
  rg.RadioGroupController is_COUGH_radioGroup_controller = rg.RadioGroupController();
  DAILY_CND_COUGH_LEVEL_ITEM sel_DAILY_CND_COUGH_LEVEL_ITEM = DAILY_CND_COUGH_LEVEL_ITEMs[0];//咳嗽程度
  DAILY_CND_COUGH_TIME_ITEM sel_DAILY_CND_COUGH_TIME_ITEM = DAILY_CND_COUGH_TIME_ITEMs[0];//咳嗽頻率
  TextEditingController COUGH_NOTE_textEditingController = TextEditingController();//咳嗽說明

  bool? is_VOMIT=false;//嘔吐
  rg.RadioGroupController is_VOMIT_radioGroup_controller = rg.RadioGroupController();

  bool? is_DIARRHEA=false;//腹瀉
  rg.RadioGroupController is_DIARRHEA_radioGroup_controller = rg.RadioGroupController();

  bool? is_HFMD=false;//手足口病
  rg.RadioGroupController is_HFMD_radioGroup_controller = rg.RadioGroupController();
  DAILY_CND_HFMD_TYPE_ITEM sel_DAILY_CND_HFMD_TYPE_ITEM = DAILY_CND_HFMD_TYPE_ITEMs[0];//手足口病種類
  TextEditingController HFMD_NOTE_textEditingController = TextEditingController();//手足口病說明


  View_DAILY? view_DAILY;
  See_DAILY_CND_pageState({View_DAILY? view_DAILY}){
    this.view_DAILY = view_DAILY;
  }

  ScrollController listScrollController = ScrollController();

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
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    dateTime = DateFormat("yyyy-MM-dd").parse(view_DAILY!.DATE);
    timeOfDay = TimeOfDay(hour:int.parse(view_DAILY!.TIME.split(":")[0]),minute: int.parse(view_DAILY!.TIME.split(":")[1]));
    await read_DAILY_CND_db_sub(NO:view_DAILY!.NO,TYPE:view_DAILY!.TYPE);
    await read_DAILY_PIC_DL_db_sub(NO:view_DAILY!.NO,TYPE:view_DAILY!.TYPE);
    SmartDialog.dismiss();
    setState(() {

    });
  }


  /*

   */
  Future<void> read_DAILY_CND_db_sub({
    String NO="",
    String TYPE="",
  })async{

    String comm = "SELECT * FROM DAILY_CND WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

        is_NORMAL = "${data_list[0]["NORMAL"]}".contains("null") || "${data_list[0]["NORMAL"]}".isEmpty?null:("${data_list[0]["NORMAL"]}"=="true"||"${data_list[0]["NORMAL"]}"=="1")?true:false;
        is_NORMAL_radioGroup_controller.selectAt("${data_list[0]["NORMAL"]}".contains("null") || "${data_list[0]["NORMAL"]}".isEmpty?0:("${data_list[0]["NORMAL"]}"=="true"||"${data_list[0]["NORMAL"]}"=="1")?0:1);

        is_FEVER = "${data_list[0]["FEVER"]}".contains("null") || "${data_list[0]["FEVER"]}".isEmpty?null:("${data_list[0]["FEVER"]}"=="true"||"${data_list[0]["FEVER"]}"=="1")?true:false;//發燒
        is_FEVER_radioGroup_controller.selectAt("${data_list[0]["FEVER"]}".contains("null") || "${data_list[0]["FEVER"]}".isEmpty?0:("${data_list[0]["FEVER"]}"=="true"||"${data_list[0]["FEVER"]}"=="1")?0:1);
        FEVER_TEMP_textEditingController.text = "${data_list[0]["FEVER_TEMP"]}".contains("null") || "${data_list[0]["FEVER_TEMP"]}".isEmpty?"":"${data_list[0]["FEVER_TEMP"]}";//發燒溫度
        FEVER_NOTE_textEditingController.text = "${data_list[0]["FEVER_NOTE"]}".contains("null") || "${data_list[0]["FEVER_NOTE"]}".isEmpty?"":"${data_list[0]["FEVER_NOTE"]}";//發燒說明


        is_NASAL = "${data_list[0]["NASAL"]}".contains("null") || "${data_list[0]["NASAL"]}".isEmpty?null:("${data_list[0]["NASAL"]}"=="true"||"${data_list[0]["NASAL"]}"=="1")?true:false;//
        is_NASAL_radioGroup_controller.selectAt("${data_list[0]["NASAL"]}".contains("null") || "${data_list[0]["NASAL"]}".isEmpty?0:("${data_list[0]["NASAL"]}"=="true"||"${data_list[0]["NASAL"]}"=="1")?0:1);
        for(int i=0;i<DAILY_CND_NASAL_STATUS_ITEMs.length;i++){
          if(DAILY_CND_NASAL_STATUS_ITEMs[i].ITEM_NO=="${data_list[0]["NASAL_STATUS"]}"){
            sel_DAILY_CND_NASAL_STATUS_ITEM = DAILY_CND_NASAL_STATUS_ITEMs[i];
            break;
          }
        }
        NASAL_NOTE_textEditingController.text = "${data_list[0]["NASAL_NOTE"]}".contains("null") || "${data_list[0]["NASAL_NOTE"]}".isEmpty?"":"${data_list[0]["NASAL_NOTE"]}";//



        is_RUNNY_NOSE = "${data_list[0]["RUNNY_NOSE"]}".contains("null") || "${data_list[0]["RUNNY_NOSE"]}".isEmpty?null:"${data_list[0]["RUNNY_NOSE"]}"=="true"?true:false;//
        is_RUNNY_NOSE_radioGroup_controller.selectAt("${data_list[0]["RUNNY_NOSE"]}".contains("null") || "${data_list[0]["RUNNY_NOSE"]}".isEmpty?0:("${data_list[0]["RUNNY_NOSE"]}"=="true"||"${data_list[0]["RUNNY_NOSE"]}"=="1")?0:1);
        for(int i=0;i<DAILY_CND_RUNNY_COLOR_ITEMs.length;i++){
          if(DAILY_CND_RUNNY_COLOR_ITEMs[i].ITEM_NO=="${data_list[0]["RUNNY_COLOR"]}"){
            sel_DAILY_CND_RUNNY_COLOR_ITEM = DAILY_CND_RUNNY_COLOR_ITEMs[i];
            break;
          }
        }
        for(int i=0;i<DAILY_CND_RUNNY_TYPE_ITEMs.length;i++){
          if(DAILY_CND_RUNNY_TYPE_ITEMs[i].ITEM_NO=="${data_list[0]["RUNNY_TYPE"]}"){
            sel_DAILY_CND_RUNNY_TYPE_ITEM = DAILY_CND_RUNNY_TYPE_ITEMs[i];
            break;
          }
        }
        for(int i=0;i<DAILY_CND_RUNNY_QUANTITY_ITEMs.length;i++){
          if(DAILY_CND_RUNNY_QUANTITY_ITEMs[i].ITEM_NO=="${data_list[0]["RUNNY_QUANTITY"]}"){
            sel_DAILY_CND_RUNNY_QUANTITY_ITEM = DAILY_CND_RUNNY_QUANTITY_ITEMs[i];
            break;
          }
        }
        RUNNY_NOSE_NOTE_textEditingController.text = "${data_list[0]["RUNNY_NOSE_NOTE"]}".contains("null") || "${data_list[0]["RUNNY_NOSE_NOTE"]}".isEmpty?"":"${data_list[0]["RUNNY_NOSE_NOTE"]}";//



        is_COUGH = "${data_list[0]["COUGH"]}".contains("null") || "${data_list[0]["COUGH"]}".isEmpty?null:("${data_list[0]["COUGH"]}"=="true"||"${data_list[0]["COUGH"]}"=="1")?true:false;//
        is_COUGH_radioGroup_controller.selectAt("${data_list[0]["COUGH"]}".contains("null") || "${data_list[0]["COUGH"]}".isEmpty?0:("${data_list[0]["COUGH"]}"=="true"||"${data_list[0]["COUGH"]}"=="1")?0:1);
        for(int i=0;i<DAILY_CND_COUGH_LEVEL_ITEMs.length;i++){
          if(DAILY_CND_COUGH_LEVEL_ITEMs[i].ITEM_NO=="${data_list[0]["COUGH_LEVEL"]}"){
            sel_DAILY_CND_COUGH_LEVEL_ITEM = DAILY_CND_COUGH_LEVEL_ITEMs[i];
            break;
          }
        }
        for(int i=0;i<DAILY_CND_COUGH_TIME_ITEMs.length;i++){
          if(DAILY_CND_COUGH_TIME_ITEMs[i].ITEM_NO=="${data_list[0]["COUGH_TIME"]}"){
            sel_DAILY_CND_COUGH_TIME_ITEM = DAILY_CND_COUGH_TIME_ITEMs[i];
            break;
          }
        }
        COUGH_NOTE_textEditingController.text = "${data_list[0]["COUGH_NOTE"]}".contains("null") || "${data_list[0]["COUGH_NOTE"]}".isEmpty?"":"${data_list[0]["COUGH_NOTE"]}";//



        is_VOMIT = "${data_list[0]["VOMIT"]}".contains("null") || "${data_list[0]["VOMIT"]}".isEmpty?null:("${data_list[0]["VOMIT"]}"=="true"||"${data_list[0]["VOMIT"]}"=="1")?true:false;//
        is_VOMIT_radioGroup_controller.selectAt("${data_list[0]["VOMIT"]}".contains("null") || "${data_list[0]["VOMIT"]}".isEmpty?0:("${data_list[0]["VOMIT"]}"=="true"||"${data_list[0]["VOMIT"]}"=="1")?0:1);

        is_DIARRHEA = "${data_list[0]["DIARRHEA"]}".contains("null") || "${data_list[0]["DIARRHEA"]}".isEmpty?null:("${data_list[0]["DIARRHEA"]}"=="true"||"${data_list[0]["DIARRHEA"]}"=="1")?true:false;//
        is_DIARRHEA_radioGroup_controller.selectAt("${data_list[0]["DIARRHEA"]}".contains("null") || "${data_list[0]["DIARRHEA"]}".isEmpty?0:("${data_list[0]["DIARRHEA"]}"=="true"||"${data_list[0]["DIARRHEA"]}"=="1")?0:1);

        is_HFMD = "${data_list[0]["HFMD"]}".contains("null") || "${data_list[0]["HFMD"]}".isEmpty?null:("${data_list[0]["HFMD"]}"=="true"||"${data_list[0]["HFMD"]}"=="1")?true:false;//
        is_HFMD_radioGroup_controller.selectAt("${data_list[0]["HFMD"]}".contains("null") || "${data_list[0]["HFMD"]}".isEmpty?0:("${data_list[0]["HFMD"]}"=="true"||"${data_list[0]["HFMD"]}"=="1")?0:1);
        for(int i=0;i<DAILY_CND_HFMD_TYPE_ITEMs.length;i++){
          if(DAILY_CND_HFMD_TYPE_ITEMs[i].ITEM_NO=="${data_list[0]["HFMD_TYPE"]}"){
            sel_DAILY_CND_HFMD_TYPE_ITEM = DAILY_CND_HFMD_TYPE_ITEMs[i];
            break;
          }
        }
        HFMD_NOTE_textEditingController.text = "${data_list[0]["HFMD_NOTE"]}".contains("null") || "${data_list[0]["HFMD_NOTE"]}".isEmpty?"":"${data_list[0]["HFMD_NOTE"]}";//

        OTHER_textEditingController.text = "${data_list[0]["OTHER"]}".contains("null") || "${data_list[0]["OTHER"]}".isEmpty?"":"${data_list[0]["OTHER"]}";//

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
  Future<void> read_DAILY_PIC_DL_db_sub({
    String NO="",
    String TYPE="",
  })async{

    String comm = "SELECT * FROM DAILY_PIC_DL WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
          DAILY_PIC_DL d = DAILY_PIC_DL();
          d.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
          d.TYPE = "${data_list[i]["TYPE"]}".contains("null")?"":"${data_list[i]["TYPE"]}";
          d.SR = "${data_list[i]["SR"]}".contains("null")?"":"${data_list[i]["SR"]}";
          d.LINK = "${data_list[i]["LINK"]}".contains("null")?"":"${data_list[i]["LINK"]}";
          String LINK = d.LINK.replaceAll("~/", "");
          d.LINK = "${IMAGE_IP}/${LINK}";
          DAILY_PIC_DLs.add(d);
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
      TYPE:"CND",
      NO:view_DAILY!.NO,//編號
      DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
      TIME:"${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00",//時間
      DEPM_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}",//學校
      CLASS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}",//班級
      CS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",//學生身分證字號
      USER_NO:"${EMPLOYEE_teacher.EMP_NO}",//系統自動帶入老師編號
    );


    //[托嬰/幼兒]健康 生理狀況
    await updata_DAILY_CND_db_sub(
      TYPE:"CND",
      NO:view_DAILY!.NO,//編號
      NORMAL:is_NORMAL,//
      FEVER:is_FEVER,
      FEVER_TEMP:FEVER_TEMP_textEditingController.text,
      FEVER_NOTE:FEVER_NOTE_textEditingController.text,
      NASAL:is_NASAL,
      NASAL_STATUS:sel_DAILY_CND_NASAL_STATUS_ITEM.ITEM_NO,
      NASAL_NOTE:NASAL_NOTE_textEditingController.text,
      RUNNY_NOSE:is_RUNNY_NOSE,
      RUNNY_COLOR:sel_DAILY_CND_RUNNY_COLOR_ITEM.ITEM_NO,
      RUNNY_TYPE:sel_DAILY_CND_RUNNY_TYPE_ITEM.ITEM_NO,
      RUNNY_QUANTITY:sel_DAILY_CND_RUNNY_QUANTITY_ITEM.ITEM_NO,
      RUNNY_NOSE_NOTE:RUNNY_NOSE_NOTE_textEditingController.text,
      COUGH:is_COUGH,
      COUGH_LEVEL:sel_DAILY_CND_COUGH_LEVEL_ITEM.ITEM_NO,
      COUGH_TIME:sel_DAILY_CND_COUGH_TIME_ITEM.ITEM_NO,
      COUGH_NOTE:COUGH_NOTE_textEditingController.text,
      VOMIT:is_VOMIT,
      DIARRHEA:is_DIARRHEA,
      HFMD:is_HFMD,
      HFMD_TYPE:sel_DAILY_CND_HFMD_TYPE_ITEM.ITEM_NO,
      HFMD_NOTE:HFMD_NOTE_textEditingController.text,
      OTHER:OTHER_textEditingController.text,
    );

    await delete_DAILY_PIC_DL_db_sub(NO:view_DAILY!.NO);

    DateTime d = DateTime.now();

    if(DAILY_PIC_DLs.length==0){
      await insert_DAILY_PIC_DL_db_sub(
        TYPE:"CND",//
        NO:"${view_DAILY!.NO}",
        SR:"${1}",
        LINK:"",//照片
      );
    }
    else{
      for(int i=0;i<DAILY_PIC_DLs.length;i++){
        if(DAILY_PIC_DLs[i].prescriptionsbytes_xfile!=null){
          await upload_image(image_path: DAILY_PIC_DLs[i].prescriptionsbytes_xfile!.path,file_name: "${view_DAILY!.NO}_${i+1}_${d.microsecondsSinceEpoch}",folder: "Daily");
          await insert_DAILY_PIC_DL_db_sub(
            TYPE:"CND",//
            NO:"${view_DAILY!.NO}",
            SR:"${i+1}",
            LINK:(DAILY_PIC_DLs[i].prescriptionsbytes_xfile==null)?"":"~/School/Images/Daily/${view_DAILY!.NO}_${i+1}_${d.microsecondsSinceEpoch}.jpg",//照片

          );
        }
        else if(DAILY_PIC_DLs[i].LINK.isNotEmpty){
          http.Response response = await http.get(Uri.parse(DAILY_PIC_DLs[i].LINK));//Uint8List
          await upload_image(img: response.bodyBytes,file_name: "${DAILY_PIC_DLs[i].NO}_${i+1}_${d.microsecondsSinceEpoch}",folder: "Daily");
          await insert_DAILY_PIC_DL_db_sub(
            TYPE:"CND",//
            NO:"${view_DAILY!.NO}",
            SR:"${i+1}",
            LINK:"~/School/Images/Daily/${DAILY_PIC_DLs[i].NO}_${i+1}_${d.microsecondsSinceEpoch}.jpg",//
          );
        }
      }
    }


    SmartDialog.dismiss();
    SmartDialog.showToast("處理成功");
    Student_T_page_fun!(action:"新增[托嬰/幼兒]健康 生理狀況成功");
    DAILY_PIC_DLs.clear();
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

   */
  Future<void> updata_DAILY_CND_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        bool? NORMAL,//正常
        bool? FEVER,//發燒
        String FEVER_TEMP="",//發燒溫度
        String FEVER_NOTE="",//發燒說明
        bool? NASAL,//鼻塞
        String NASAL_STATUS="",//鼻塞
        String NASAL_NOTE="",//鼻塞說明
        bool? RUNNY_NOSE,//流鼻涕
        String RUNNY_COLOR="",//流鼻涕顏色
        String RUNNY_TYPE="",//流鼻涕種類
        String RUNNY_QUANTITY="",//流鼻涕數量
        String RUNNY_NOSE_NOTE="",//流鼻涕說明
        bool? COUGH,//咳嗽
        String COUGH_LEVEL="",//咳嗽程度
        String COUGH_TIME="",//咳嗽頻率
        String COUGH_NOTE="",//咳嗽說明
        bool? VOMIT,//嘔吐
        bool? DIARRHEA,//腹瀉
        bool? HFMD,//手足口病
        String HFMD_TYPE="",//手足口病種類
        String HFMD_NOTE="",//手足口病說明
        String OTHER="",//其他

      })async{

    String comm = "UPDATE DAILY_CND SET "
        "NORMAL='${NORMAL}',"
        "FEVER='${FEVER}',"
        "FEVER_TEMP='${FEVER_TEMP}',"
        "FEVER_NOTE='${FEVER_NOTE}',"
        "NASAL='${NASAL}',"
        "NASAL_STATUS='${NASAL_STATUS}',"
        "NASAL_NOTE='${NASAL_NOTE}',"
        "RUNNY_NOSE='${RUNNY_NOSE}',"
        "RUNNY_COLOR='${RUNNY_COLOR}',"
        "RUNNY_TYPE='${RUNNY_TYPE}',"
        "RUNNY_QUANTITY='${RUNNY_QUANTITY}',"
        "RUNNY_NOSE_NOTE='${RUNNY_NOSE_NOTE}',"
        "COUGH='${COUGH}',"
        "COUGH_LEVEL='${COUGH_LEVEL}',"
        "COUGH_TIME='${COUGH_TIME}',"
        "COUGH_NOTE='${COUGH_NOTE}',"
        "VOMIT='${VOMIT}',"
        "DIARRHEA='${DIARRHEA}',"
        "HFMD='${HFMD}',"
        "HFMD_TYPE='${HFMD_TYPE}',"
        "HFMD_NOTE='${HFMD_NOTE}' "
        "WHERE NO='${NO}' AND TYPE='${TYPE}'";

    if(FEVER_TEMP.isEmpty){
      comm = "UPDATE DAILY_CND SET "
          "NORMAL='${NORMAL}',"
          "FEVER='${FEVER}',"
          "FEVER_NOTE='${FEVER_NOTE}',"
          "NASAL='${NASAL}',"
          "NASAL_STATUS='${NASAL_STATUS}',"
          "NASAL_NOTE='${NASAL_NOTE}',"
          "RUNNY_NOSE='${RUNNY_NOSE}',"
          "RUNNY_COLOR='${RUNNY_COLOR}',"
          "RUNNY_TYPE='${RUNNY_TYPE}',"
          "RUNNY_QUANTITY='${RUNNY_QUANTITY}',"
          "RUNNY_NOSE_NOTE='${RUNNY_NOSE_NOTE}',"
          "COUGH='${COUGH}',"
          "COUGH_LEVEL='${COUGH_LEVEL}',"
          "COUGH_TIME='${COUGH_TIME}',"
          "COUGH_NOTE='${COUGH_NOTE}',"
          "VOMIT='${VOMIT}',"
          "DIARRHEA='${DIARRHEA}',"
          "HFMD='${HFMD}',"
          "HFMD_TYPE='${HFMD_TYPE}',"
          "HFMD_NOTE='${HFMD_NOTE}' "
          "WHERE NO='${NO}' AND TYPE='${TYPE}'";
    }

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


  /// Captures the current screen and saves it as an image in the gallery.
  Future<void> _saveScreen({String img_url=""}) async {

    dev.log("下載圖片:${img_url}");

    try {
      final response = await Dio().get(
        img_url,
        options: Options(responseType: ResponseType.bytes),
      );
      final result = await ImageGallerySaverPlus.saveImage(
          Uint8List.fromList(response.data),
          quality: downloadImageCompress_quality,
          isReturnImagePathOfIOS: true,
          name: "${DateTime.now().microsecondsSinceEpoch}");
      Fluttertoast.showToast(msg: "下載圖片成功\n${result["filePath"]}", toastLength: Toast.LENGTH_LONG);

    } catch (e) {
      Fluttertoast.showToast(msg: "下載圖片遇到錯誤", toastLength: Toast.LENGTH_LONG);
    }
  }

  void showImageViewer(BuildContext context, String uri) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.all(8),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(child: Image.network(uri)),
            ),
            // 關閉按鈕
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black,size: 30.sp,),
                onPressed: () => Navigator.pop(_),
              ),
            ),
            // 下載按鈕
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Color(0xffF9AA88),
                child: Icon(Icons.download, color: Colors.black),
                onPressed: () async {


                  if(Platform.isAndroid){
                    if(await checkAndRequestPermissions(skipIfExists: true)==true){
                      _saveScreen(img_url:uri);
                    }
                  }
                  else{
                    _saveScreen(img_url:uri);
                  }


                },
              ),
            ),
          ],
        ),
      ),
    );
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
                actions: [
                  Container(width: 20.w,),
                ],
                title: Text("${DAILY_MT_TYPE_ITEMs.firstWhere((e)=>e.ITEM_NO=="CND").ITEM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              ),
          body: ListView(
            controller: listScrollController,
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
              Row(children: [
                Container(width: 10.w,),
                Expanded(child:Text("正常:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929)))),
                Expanded(flex:3,child: AbsorbPointer(child:rg.RadioGroup(
                  controller: is_NORMAL_radioGroup_controller,
                  orientation: rg.RadioGroupOrientation.horizontal,
                  indexOfDefault: (is_NORMAL==null)?-1:(is_NORMAL==true)?0:1,
                  values: ["是", "否",],
                  decoration: rg.RadioGroupDecoration(
                    spacing: 40.0.w,
                    labelStyle: TextStyle(
                        color: Colors.blue,
                        fontSize: 18.sp
                    ),
                    activeColor: Colors.lightBlue,
                  ),
                  onChanged: null,
                ))),
              ],),
              Container(height: 15.h,),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

              //發燒
              ((is_FEVER==null || is_FEVER==false))?
              Container()
                  :
              Column(children: [
                Container(height: 15.h,),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("發燒:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: AbsorbPointer(child:rg.RadioGroup(
                    controller: is_FEVER_radioGroup_controller,
                    orientation: rg.RadioGroupOrientation.horizontal,
                    indexOfDefault: (is_FEVER==null)?-1:(is_FEVER==true)?0:1,
                    values: ["是", "否",],
                    decoration: rg.RadioGroupDecoration(
                      spacing: 40.0.w,
                      labelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 18.sp
                      ),
                      activeColor: Colors.lightBlue,
                    ),
                    onChanged: null,
                  ))),
                ],),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("發燒溫度:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: Container(
                      color: Color(0xffEEEEEE),
                      padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                      margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
                      width:ScreenUtil().screenWidth,child: Column(children: [

                    AbsorbPointer(child:
                    Form(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Color(0xff555555),
                          ),
                          controller: FEVER_TEMP_textEditingController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true,
                              signed: false),
                          inputFormatters: [
                            //PrecisionLimitFormatter(2)
                            FilteringTextInputFormatter(RegExp("[0-9.]"), allow: true),
                            //RemoveEmojiInputFormatter()
                            //MyNumberTextInputFormatter(digit: weight_decimal_point),
                          ],
                          //inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          autofocus: false,
                          maxLines: null,
                          //obscureText: !_adminVisible,
                          //obscureText: !_accountVisible,//This will obscure text dynamically
                          maxLength: 4,
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
                            suffixText:"℃",
                            counter:Container(),
                            hintStyle: TextStyle(fontWeight: FontWeight.w400,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
                            contentPadding:  EdgeInsets.only(left:10.w,right: 10.w,top: 0.h,bottom: 0.h),
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


                  ],)),),
                ],),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("發燒說明:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child:Container()),
                ],),
                Container(
                    color: Color(0xffEEEEEE),
                    padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                    margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
                    width:ScreenUtil().screenWidth,child: AbsorbPointer(child:Form(
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Color(0xff555555),
                      ),
                      controller: FEVER_NOTE_textEditingController,
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
                    )))),
                Container(height: 15.h,),
                Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              ],),

              //鼻塞
              ((is_NASAL==null || is_NASAL==false))?
              Container()
                  :
              Column(children: [
                Container(height: 15.h,),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("鼻塞:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: AbsorbPointer(child:rg.RadioGroup(
                    controller: is_NASAL_radioGroup_controller,
                    orientation: rg.RadioGroupOrientation.horizontal,
                    indexOfDefault: (is_NASAL==null)?-1:(is_NASAL==true)?0:1,
                    values: ["是", "否",],
                    decoration: rg.RadioGroupDecoration(
                      spacing: 40.0.w,
                      labelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 18.sp
                      ),
                      activeColor: Colors.lightBlue,
                    ),
                    onChanged: null,
                  ))),
                ],),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("鼻塞:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                    child: AbsorbPointer(child:DropdownButton2<DAILY_CND_NASAL_STATUS_ITEM>(
                      isExpanded: true,
                      items: DAILY_CND_NASAL_STATUS_ITEMs
                          .map((DAILY_CND_NASAL_STATUS_ITEM item) => DropdownMenuItem<DAILY_CND_NASAL_STATUS_ITEM>(
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
                      value: sel_DAILY_CND_NASAL_STATUS_ITEM,
                      onChanged: (value) {

                        sel_DAILY_CND_NASAL_STATUS_ITEM = value!;
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
                    )),
                  ),),
                  ),
                ],),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("鼻塞說明:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child:Container()),
                ],),
                Container(
                    color: Color(0xffEEEEEE),
                    padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                    margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
                    width:ScreenUtil().screenWidth,child: AbsorbPointer(child:Form(
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Color(0xff555555),
                      ),
                      controller: NASAL_NOTE_textEditingController,
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
                    )))),
                Container(height: 15.h,),
                Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              ],),



              //流鼻涕
              ((is_RUNNY_NOSE==null || is_RUNNY_NOSE==false))?
              Container()
                  :
              Column(children: [
                Container(height: 15.h,),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("流鼻涕:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: AbsorbPointer(child:rg.RadioGroup(
                    controller: is_RUNNY_NOSE_radioGroup_controller,
                    orientation: rg.RadioGroupOrientation.horizontal,
                    indexOfDefault: (is_RUNNY_NOSE==null)?-1:(is_RUNNY_NOSE==true)?0:1,
                    values: ["是", "否",],
                    decoration: rg.RadioGroupDecoration(
                      spacing: 40.0.w,
                      labelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 18.sp
                      ),
                      activeColor: Colors.lightBlue,
                    ),
                    onChanged: null,
                  ))),
                ],),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("流鼻涕顏色:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                    child: AbsorbPointer(child:DropdownButton2<DAILY_CND_RUNNY_COLOR_ITEM>(
                      isExpanded: true,
                      items: DAILY_CND_RUNNY_COLOR_ITEMs
                          .map((DAILY_CND_RUNNY_COLOR_ITEM item) => DropdownMenuItem<DAILY_CND_RUNNY_COLOR_ITEM>(
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
                      value: sel_DAILY_CND_RUNNY_COLOR_ITEM,
                      onChanged: (value) {

                        sel_DAILY_CND_RUNNY_COLOR_ITEM = value!;
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
                    )),
                  ),),
                  ),
                ],),
                Container(height: 5.h,),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("流鼻涕種類:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                    child: AbsorbPointer(child:DropdownButton2<DAILY_CND_RUNNY_TYPE_ITEM>(
                      isExpanded: true,
                      items: DAILY_CND_RUNNY_TYPE_ITEMs
                          .map((DAILY_CND_RUNNY_TYPE_ITEM item) => DropdownMenuItem<DAILY_CND_RUNNY_TYPE_ITEM>(
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
                      value: sel_DAILY_CND_RUNNY_TYPE_ITEM,
                      onChanged: (value) {

                        sel_DAILY_CND_RUNNY_TYPE_ITEM = value!;
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
                    )),
                  ),),
                  ),
                ],),
                Container(height: 5.h,),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("流鼻涕數量:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                    child: AbsorbPointer(child:DropdownButton2<DAILY_CND_RUNNY_QUANTITY_ITEM>(
                      isExpanded: true,
                      items: DAILY_CND_RUNNY_QUANTITY_ITEMs
                          .map((DAILY_CND_RUNNY_QUANTITY_ITEM item) => DropdownMenuItem<DAILY_CND_RUNNY_QUANTITY_ITEM>(
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
                      value: sel_DAILY_CND_RUNNY_QUANTITY_ITEM,
                      onChanged: (value) {

                        sel_DAILY_CND_RUNNY_QUANTITY_ITEM = value!;
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
                    )),
                  ),),
                  ),
                ],),
                Container(height: 5.h,),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("流鼻涕說明:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child:Container()),
                ],),
                Container(height: 5.h,),
                Container(
                    color: Color(0xffEEEEEE),
                    padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                    margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
                    width:ScreenUtil().screenWidth,child: AbsorbPointer(child:Form(
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Color(0xff555555),
                      ),
                      controller: RUNNY_NOSE_NOTE_textEditingController,
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
                    )))),
                Container(height: 15.h,),
                Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              ],),




              //咳嗽
              ((is_COUGH==null || is_COUGH==false))?
              Container()
                  :
              Column(children: [
                Container(height: 15.h,),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("咳嗽:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: AbsorbPointer(child:rg.RadioGroup(
                    controller: is_COUGH_radioGroup_controller,
                    orientation: rg.RadioGroupOrientation.horizontal,
                    indexOfDefault: (is_COUGH==null)?-1:(is_COUGH==true)?0:1,
                    values: ["是", "否",],
                    decoration: rg.RadioGroupDecoration(
                      spacing: 40.0.w,
                      labelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 18.sp
                      ),
                      activeColor: Colors.lightBlue,
                    ),
                    onChanged: null,
                  ))),
                ],),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("咳嗽程度:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                    child: AbsorbPointer(child:DropdownButton2<DAILY_CND_COUGH_LEVEL_ITEM>(
                      isExpanded: true,
                      items: DAILY_CND_COUGH_LEVEL_ITEMs
                          .map((DAILY_CND_COUGH_LEVEL_ITEM item) => DropdownMenuItem<DAILY_CND_COUGH_LEVEL_ITEM>(
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
                      value: sel_DAILY_CND_COUGH_LEVEL_ITEM,
                      onChanged: (value) {

                        sel_DAILY_CND_COUGH_LEVEL_ITEM = value!;
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
                    )),
                  ),),
                  ),
                ],),
                Container(height: 5.h,),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("咳嗽頻率:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                    child: AbsorbPointer(child:DropdownButton2<DAILY_CND_COUGH_TIME_ITEM>(
                      isExpanded: true,
                      items: DAILY_CND_COUGH_TIME_ITEMs
                          .map((DAILY_CND_COUGH_TIME_ITEM item) => DropdownMenuItem<DAILY_CND_COUGH_TIME_ITEM>(
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
                      value: sel_DAILY_CND_COUGH_TIME_ITEM,
                      onChanged: (value) {

                        sel_DAILY_CND_COUGH_TIME_ITEM = value!;
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
                    )),
                  ),),
                  ),
                ],),
                Container(height: 5.h,),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("咳嗽說明:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child:Container()),
                ],),
                Container(height: 5.h,),
                Container(
                    color: Color(0xffEEEEEE),
                    padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                    margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
                    width:ScreenUtil().screenWidth,child: AbsorbPointer(child:Form(
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Color(0xff555555),
                      ),
                      controller: COUGH_NOTE_textEditingController,
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
                    )))),
                Container(height: 15.h,),
                Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              ],),




              //嘔吐
              ((is_VOMIT==null || is_VOMIT==false))?
              Container()
                  :
              Column(children: [
                Container(height: 15.h,),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("嘔吐:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: AbsorbPointer(child:rg.RadioGroup(
                    controller: is_VOMIT_radioGroup_controller,
                    orientation: rg.RadioGroupOrientation.horizontal,
                    indexOfDefault: (is_VOMIT==null)?-1:(is_VOMIT==true)?0:1,
                    values: ["是", "否",],
                    decoration: rg.RadioGroupDecoration(
                      spacing: 40.0.w,
                      labelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 18.sp
                      ),
                      activeColor: Colors.lightBlue,
                    ),
                    onChanged: null,
                  ))),
                ],),
                Container(height: 15.h,),
                Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              ],),




              //腹瀉
              ((is_DIARRHEA==null || is_DIARRHEA==false))?
              Container()
                  :
              Column(children: [
                Container(height: 15.h,),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("腹瀉:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: AbsorbPointer(child:rg.RadioGroup(
                    controller: is_DIARRHEA_radioGroup_controller,
                    orientation: rg.RadioGroupOrientation.horizontal,
                    indexOfDefault: (is_DIARRHEA==null)?-1:(is_DIARRHEA==true)?0:1,
                    values: ["是", "否",],
                    decoration: rg.RadioGroupDecoration(
                      spacing: 40.0.w,
                      labelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 18.sp
                      ),
                      activeColor: Colors.lightBlue,
                    ),
                    onChanged: null,
                  ))),
                ],),
                Container(height: 15.h,),
                Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              ],),




              //手足口病
              ((is_HFMD==null || is_HFMD==false))?
              Container()
                  :
              Column(children: [
                Container(height: 15.h,),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("手足口病:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: AbsorbPointer(child:rg.RadioGroup(
                    controller: is_HFMD_radioGroup_controller,
                    orientation: rg.RadioGroupOrientation.horizontal,
                    indexOfDefault: (is_HFMD==null)?-1:(is_HFMD==true)?0:1,
                    values: ["是", "否",],
                    decoration: rg.RadioGroupDecoration(
                      spacing: 40.0.w,
                      labelStyle: TextStyle(
                          color: Colors.blue,
                          fontSize: 18.sp
                      ),
                      activeColor: Colors.lightBlue,
                    ),
                    onChanged: null,
                  ))),
                ],),
                Container(height: 5.h,),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("手足口病種類:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:3,child: Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                    child: AbsorbPointer(child:DropdownButton2<DAILY_CND_HFMD_TYPE_ITEM>(
                      isExpanded: true,
                      items: DAILY_CND_HFMD_TYPE_ITEMs
                          .map((DAILY_CND_HFMD_TYPE_ITEM item) => DropdownMenuItem<DAILY_CND_HFMD_TYPE_ITEM>(
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
                      value: sel_DAILY_CND_HFMD_TYPE_ITEM,
                      onChanged: (value) {

                        sel_DAILY_CND_HFMD_TYPE_ITEM = value!;
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
                    )),
                  ),),
                  ),
                ],),
                Container(height: 5.h,),
                Row(children: [
                  Container(width: 10.w,),
                  Expanded(child:Text("手足口病說明:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: Color(0xff292929)))),
                  Expanded(flex:2,child:Container()),
                ],),
                Container(height: 5.h,),
                Container(
                    color: Color(0xffEEEEEE),
                    padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                    margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
                    width:ScreenUtil().screenWidth,child: AbsorbPointer(child:Form(
                    child: TextFormField(
                      style: TextStyle(
                        fontSize: 20.sp,
                        color: Color(0xff555555),
                      ),
                      controller: HFMD_NOTE_textEditingController,
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
                    )))),
                Container(height: 15.h,),
                Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              ],),


              Container(height: 15.h,),
              Row(children: [
                Container(width: 10.w,),
                Text("其他:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ],),
              Container(
                  color: Color(0xffEEEEEE),
                  padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                  margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
                  width:ScreenUtil().screenWidth,child: AbsorbPointer(child:Form(
                  child: TextFormField(
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Color(0xff555555),
                    ),
                    controller: OTHER_textEditingController,
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
                  )))),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

              Container(height: 15.h,),
              Column(children: DAILY_PIC_DLs.map((e){
                dev.log("e.LINK:${e.LINK}");
                return Container(
                  margin: EdgeInsets.only(left:8.w,right: 8.w,top: 5.h,bottom: 5.h),
                  width: ScreenUtil().screenWidth,child:  GestureDetector(
                    onTap:(){},
                    child: Container(width: ScreenUtil().screenWidth,height: 200.h,color: Colors.transparent,child:
                    Center(child:
                    (e.LINK.isNotEmpty)?
                    GestureDetector(
                               onTap: (){
                                 showImageViewer(context,e.LINK);
                               },
                               child: Image.network(e.LINK,
                                     errorBuilder: (BuildContext context, Object exception,
                                        StackTrace? stackTrace) {
                                      return Container();
                                    },))
                        :
                    Icon(Icons.photo,color: Colors.white,size: 60.sp)
                    ))),);
              }).toList(),),


            ],),
        )));
  }
}
