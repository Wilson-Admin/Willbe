import 'dart:convert';
import 'dart:io';
import 'package:code3/main2_T.dart';
import 'package:code3/signature2.dart';
import 'package:code3/signature4.dart';
import 'package:code3/signature5.dart';
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
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'package:signature/signature.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'dart:developer' as dev;
import 'api.dart';
import 'fcm_notifity.dart';
import 'main2_U.dart';
import 'medication_details.dart';
import 'medication_entrustment.dart';
import 'signature.dart';
import 'sql.dart';
import 'package:image_picker/image_picker.dart' as ImagePicker;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'utils/CustomAppBar.dart';

Function? DRUG_MT_U_page_fun1;
String DRUG_MT_U_page_SING_LINK_TYPE = "";
class DRUG_MT_U_page extends StatefulWidget {

  DRUG_MT dRUG_MT = DRUG_MT();//用藥委託主表單(個人)
  String mode = "新增";
  DRUG_MT_U_page({String mode = "",DRUG_MT? dRUG_MT}){
    this.mode = mode;
    if(mode=="編輯"){
      this.dRUG_MT = dRUG_MT!;
    }
  }

  @override
  State<DRUG_MT_U_page> createState() => DRUG_MT_U_pageState(mode:this.mode,dRUG_MT:this.dRUG_MT);
}

class DRUG_MT_U_pageState extends State<DRUG_MT_U_page> {


  //DRUG_MT dRUG_MT = DRUG_MT();//用藥委託主表單(個人)
  //DRUG_MT_T_pageState({DRUG_MT? dRUG_MT}){
  //  this.dRUG_MT = dRUG_MT!;
  //}

  CLASS _class = CLASS();
  DEPM _depm = DEPM();
  var showModalBottomSheet_image_context;

  BuildContext? _context;

  String mode = "";
  DRUG_MT dRUG_MT = DRUG_MT();//用藥委託主表單(個人)
  DRUG_MT_U_pageState({String mode = "",DRUG_MT? dRUG_MT}){
    this.mode = mode;
    if(mode=="編輯"){
      this.dRUG_MT = dRUG_MT!;
    }
  }


  @override
  void initState() {
    // TODO: implement initState

    DRUG_MT_U_page_SING_LINK_TYPE = "";
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    _class = cLASSs.firstWhere((element) => element.CLASS_NO==CUSTOMER_selectedValue.CLASS_NO)??CLASS();
    _depm = dEPMs.firstWhere((element) => element.DEPM_NO==CUSTOMER_selectedValue.DEPM_NO)??DEPM();


    DRUG_MT_U_page_fun1=(){
      setState(() {

      });
    };

    init();

  }

  void init()async{

    try {
      MyHomePage2_U_fun1!(type: "刷新託藥訊息");
    }
    catch(e){

    }
    drug_reason = DRUG_REASON();
    if(mode=="新增"){
      dRUG_MT = DRUG_MT();//用藥委託主表單(個人)
      drug_reason = DRUG_REASON();
    }
    else{
      drug_reason.DRUG_NO = dRUG_MT.DRUG_NO;
      drug_reason.dateTime = DateTime.parse(dRUG_MT.DATE);
      drug_reason.DRUG_LINK = dRUG_MT.DRUG_LINK;
      drug_reason.SIGN_LINK = dRUG_MT.SIGN_LINK;
      drug_reason.DRUG_REASON_ITEM_list.clear();
      await DRUG_REASON_ITEM_db_sub();
      dev.log("用藥原因:${dRUG_MT.REASON}");
      List<String> str = dRUG_MT.REASON.split(",");

      for(int i=0;i<str.length;i++){
        bool matched = false;
        for(int j=0;j<drug_reason.DRUG_REASON_ITEM_list.length;j++){
           if(str[i].contains(drug_reason.DRUG_REASON_ITEM_list[j].ITEM_NM)){
             drug_reason.DRUG_REASON_ITEM_list[j].is_sel=true;
             matched = true;
           }
        }
        if (!matched) {
          // 沒有比對到任何項目，就歸類到 "其他"
          drug_reason.reason = str[i];
        }
      }
      drug_reason.DRUG_DL_list.addAll(dRUG_MT.DRUG_DL_list);


    }

    //dRUG_MT.DRUG_DL_list.clear();
    //await read_for_DRUG_DL_db_sub(DRUG_NO:dRUG_MT.DRUG_NO);
    setState(() {

    });

  }


  /*
  DRUG_REASON_ITEM
   */
  Future<void> DRUG_REASON_ITEM_db_sub()async{

    String comm = "SELECT * FROM DRUG_REASON_ITEM";
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
          DRUG_REASON_ITEM ss = DRUG_REASON_ITEM();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          drug_reason.DRUG_REASON_ITEM_list.add(ss);
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

  /*
  [托嬰/幼兒]用藥委託明細(個人) DRUG_DL
   */
  Future<void> read_for_DRUG_DL_db_sub({String DRUG_NO=""})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
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

          dRUG_MT.DRUG_DL_list.add(b);
        }

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


  /*
  [托嬰/幼兒]用藥委託主表單(個人) DRUG_MT
   */
  Future<int> read_DRUG_MT_db_sub({int index=0})async{

    int DRUG_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(drug_reason.initialDates[index])}";
    //String comm = "SELECT * FROM DRUG_MT WHERE DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";
    String comm = '''SELECT *
    FROM DRUG_MT
      WHERE DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'
      AND DRUG_NO = (
        SELECT MAX(DRUG_NO)
        FROM DRUG_MT
          WHERE DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'
      );''';
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

        DRUG_NO_num+=1;
        DRUG_NO_num = int.parse("${DateFormat('yyyyMMdd').format(drug_reason.initialDates[index])}${DRUG_NO_num.toString().padLeft(4,"0")}");

      }
      else{
        String DRUG_NO = "${data_list[data_list.length-1]["DRUG_NO"]}";
        dev.log("DRUG_NO:${DRUG_NO}");
        //找出流水號
        DRUG_NO_num = int.parse("${DRUG_NO}");//int.parse("${DRUG_NO.substring(DRUG_NO.length-4,DRUG_NO.length)}");
        DRUG_NO_num+=1;
        dev.log("DRUG_NO_num:${DRUG_NO_num}");
      }
      setState(() {

      });

    }
    catch(e){
      DRUG_NO_num=-1;
      dev.log("${e}");
    }

    return DRUG_NO_num;

  }


  /*
  [托嬰/幼兒]用藥委託主表單(個人) DRUG_MT
   */
  Future<bool> insert_DRUG_MT_db_sub(
      {
        String DRUG_NO="",//編號
        String DATE="",//日期
        String DEPM_NO="",//學校
        String CLASS_NO="",//班級
        String CS_NO="",//學生編號
        String REASON="",//用藥原因
        String DRUG_LINK="",//藥單封面
        bool AGREE=true,//同意
        String SIGN_LINK="",//簽名
        String DATETIME=""//送出時間
      })async{

    String comm = "INSERT INTO DRUG_MT(DRUG_NO,DATE,DEPM_NO,CLASS_NO,CS_NO,REASON,DRUG_LINK,AGREE,SIGN_LINK,DATETIME) VALUES ('${DRUG_NO}','${DATE}','${DEPM_NO}','${CLASS_NO}','${CS_NO}','${REASON}','${DRUG_LINK}','${AGREE}','${SIGN_LINK}','${DATETIME}')";
    dev.log("${comm}");
    String result = await sql_command("${comm}");
    dev.log("result:${result}");
    try{
      if(result.contains("執行成功")){
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
      data_list = trim_proc(data_list);
      if(data_list.length==0){
        //EasyLoading.showSuccess("用藥委託送出成功");
        //drug_reason = DRUG_REASON();
        setState(() {

        });
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


  /*
  [托嬰/幼兒]用藥委託主表單(個人) DRUG_MT
   */
  Future<bool> update_DRUG_MT_db_sub(
      {
        String DRUG_NO="",//編號
        String DATE="",//日期
        String DEPM_NO="",//學校
        String CLASS_NO="",//班級
        String CS_NO="",//學生編號
        String REASON="",//用藥原因
        String DRUG_LINK="",//藥單封面
        bool AGREE=true,//同意
        String SIGN_LINK="",//簽名
        String DATETIME=""//送出時間
      })async{

    String comm = "UPDATE DRUG_MT SET DATE='${DATE}', REASON='${REASON}', DRUG_LINK='${DRUG_LINK}', SIGN_LINK='${SIGN_LINK}',DATETIME='${DATETIME}' WHERE DRUG_NO='${DRUG_NO}'";
    dev.log("${comm}");
    String result = await sql_command("${comm}");
    dev.log("result:${result}");
    try{

      Map<String,dynamic> map = jsonDecode(result);
      if("${map['message']}"=='執行成功'){
        return true;
      }
      else{
        return false;
      }

    }
    catch(e){
      dev.log("${e}");
      return false;
    }
  }


  String toSqlTime(String? t) {
    if (t == null || t.isEmpty) {
      return "NULL";
    }
    return "CAST('$t' AS TIME)";
  }


  /*
  [托嬰/幼兒]用藥委託主表單(個人) DRUG_DL
   */
  Future<bool> insert_DRUG_DL_db_sub(
      {
        String DRUG_NO="",//編號
        String DRUG_SR="",//序號
        String DETAIL="",//藥品名稱
        String STORE="",//用藥保存
        String MODE="",//用藥方式
        String UNIT="",//用量單位
        String DOSAGE="",//用量
        String TIME1="",//第1次
        dynamic TIME2="",//第2次
        dynamic TIME3="",//第3次
        String DRUG_LINK="",//藥品照片
        String NOTE="",//說明

      })async{

    dev.log("TIME2:${TIME2}");
    dev.log("TIME3:${TIME3}");

    dev.log("TIME2==null && TIME3==null:${TIME2==null && TIME3==null}");

    /*
    String comm = "INSERT INTO DRUG_DL(DRUG_NO,DRUG_SR,DETAIL,STORE,MODE,UNIT,DOSAGE,TIME1,TIME2,TIME3,DRUG_LINK,NOTE) VALUES ('${DRUG_NO}','${DRUG_SR}','${DETAIL}','${STORE}','${MODE}','${UNIT}','${DOSAGE}','${TIME1}','${TIME2}','${TIME3}','${DRUG_LINK}','${NOTE}')";
    if(TIME2==null && TIME3==null){
      comm = "INSERT INTO DRUG_DL(DRUG_NO,DRUG_SR,DETAIL,STORE,MODE,UNIT,DOSAGE,TIME1,DRUG_LINK,NOTE) VALUES ('${DRUG_NO}','${DRUG_SR}','${DETAIL}','${STORE}','${MODE}','${UNIT}','${DOSAGE}','${TIME1}','${DRUG_LINK}','${NOTE}')";
    }
    else if(TIME3==null){
      comm = "INSERT INTO DRUG_DL(DRUG_NO,DRUG_SR,DETAIL,STORE,MODE,UNIT,DOSAGE,TIME1,TIME2,DRUG_LINK,NOTE) VALUES ('${DRUG_NO}','${DRUG_SR}','${DETAIL}','${STORE}','${MODE}','${UNIT}','${DOSAGE}','${TIME1}','${TIME2}','${DRUG_LINK}','${NOTE}')";
    }

     */


    String comm = """
MERGE DRUG_DL AS target
USING (VALUES ('${DRUG_NO}','${DRUG_SR}','${DETAIL}','${STORE}','${MODE}','${UNIT}',
               '${DOSAGE}', ${toSqlTime(TIME1)}, ${toSqlTime(TIME2)}, ${toSqlTime(TIME3)},
               '${DRUG_LINK}','${NOTE}')) 
AS source (DRUG_NO, DRUG_SR, DETAIL, STORE, MODE, UNIT, DOSAGE, TIME1, TIME2, TIME3, DRUG_LINK, NOTE)
ON (target.DRUG_NO = source.DRUG_NO AND target.DRUG_SR = source.DRUG_SR)
WHEN MATCHED THEN
    UPDATE SET DETAIL=source.DETAIL,
               STORE=source.STORE,
               MODE=source.MODE,
               UNIT=source.UNIT,
               DOSAGE=source.DOSAGE,
               TIME1=source.TIME1,
               TIME2=source.TIME2,
               TIME3=source.TIME3,
               DRUG_LINK=source.DRUG_LINK,
               NOTE=source.NOTE
WHEN NOT MATCHED THEN
    INSERT (DRUG_NO, DRUG_SR, DETAIL, STORE, MODE, UNIT, DOSAGE, TIME1, TIME2, TIME3, DRUG_LINK, NOTE)
    VALUES (source.DRUG_NO, source.DRUG_SR, source.DETAIL, source.STORE, source.MODE,
            source.UNIT, source.DOSAGE, source.TIME1, source.TIME2, source.TIME3, source.DRUG_LINK, source.NOTE);
""";

    dev.log("${comm}");
    String result = await sql_command("${comm}");
    dev.log("(insert_DRUG_DL_db_sub)result:${result}");
    try{
      Map<String,dynamic> map = jsonDecode(result);
      if("${map["message"]}"=="執行成功"){
        return true;
      }
      else{
        return false;
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      return false;
    }
  }


  /*
  [托嬰/幼兒]用藥委託主表單(個人) DRUG_DL
   */
  Future<void> update_DRUG_DL_db_sub(
      {
        String DRUG_NO="",//編號
        String DRUG_SR="",//序號
        String DETAIL="",//藥品名稱
        String STORE="",//用藥保存
        String MODE="",//用藥方式
        String UNIT="",//用量單位
        String DOSAGE="",//用量
        String TIME1="",//第1次
        dynamic TIME2="",//第2次
        dynamic TIME3="",//第3次
        String DRUG_LINK="",//藥品照片
        String NOTE="",//說明

      })async{

    String comm = "INSERT INTO DRUG_DL(DRUG_NO,DRUG_SR,DETAIL,STORE,MODE,UNIT,DOSAGE,TIME1,TIME2,TIME3,DRUG_LINK,NOTE) VALUES ('${DRUG_NO}','${DRUG_SR}','${DETAIL}','${STORE}','${MODE}','${UNIT}','${DOSAGE}','${TIME1}','${TIME2}','${TIME3}','${DRUG_LINK}','${NOTE}')";
    if(TIME2==null && TIME3==null){
      comm = "INSERT INTO DRUG_DL(DRUG_NO,DRUG_SR,DETAIL,STORE,MODE,UNIT,DOSAGE,TIME1,DRUG_LINK,NOTE) VALUES ('${DRUG_NO}','${DRUG_SR}','${DETAIL}','${STORE}','${MODE}','${UNIT}','${DOSAGE}','${TIME1}','${DRUG_LINK}','${NOTE}')";
    }
    else if(TIME3==null){
      comm = "INSERT INTO DRUG_DL(DRUG_NO,DRUG_SR,DETAIL,STORE,MODE,UNIT,DOSAGE,TIME1,TIME2,DRUG_LINK,NOTE) VALUES ('${DRUG_NO}','${DRUG_SR}','${DETAIL}','${STORE}','${MODE}','${UNIT}','${DOSAGE}','${TIME1}','${TIME2}','${DRUG_LINK}','${NOTE}')";
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
      data_list = trim_proc(data_list);
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }
  }


  /*
  檢查是否已建立聊天室
   */
  Future<String>check_is_ChatID_sub(
      {
        String TeacherAccount="",
        String UserAccount="",
        String CS_NO="",
        String CLASS_NO="",
        String DEPM_NO="",
      })async{

    String ChatID = "";

    TeacherAccount = TeacherAccount.trim();
    UserAccount = UserAccount.trim();

    await Future.delayed(const Duration(milliseconds: 500), () {});
    String result = await sql_command("SELECT * FROM MSMT2 WHERE CS_NO='${CS_NO}' AND CLASS_NO='${CLASS_NO}' AND DEPM_NO='${DEPM_NO}'");
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
      if(data_list.length==0){
        dev.log("尚未建立聊天室");
      }
      else{
        dev.log("已建立聊天室");
        ChatID = data_list[0]["ChatID"];//await get_ChatID_form_MSMT2_db_sub(CS_NO:CS_NO,CLASS_NO:CLASS_NO,DEPM_NO:DEPM_NO);
      }


    }
    catch(e){
      dev.log("${e}");
    }

    return ChatID;

  }


  Future<String> get_ChatID_form_MSMT2_db_sub(
      {
        String TeacherAccount="",
        String UserAccount="",
        String CS_NO="",
        String CLASS_NO="",
        String DEPM_NO="",
      })async{
    await Future.delayed(const Duration(milliseconds: 500), () {});
    String comm = "SELECT * FROM MSMT2 WHERE CS_NO='${CS_NO}' AND CLASS_NO='${CLASS_NO}' AND DEPM_NO='${DEPM_NO}'";
    String result = await sql_command("${comm}");
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
      return data_list[0]["ChatID"].toString().trim();
    }
    catch(e){
      dev.log("${e}");
      return "";
    }
  }


  /*
  將托藥訊息寫入聊天室
   */
  Future<void> insert_MSDL2_db_sub({String DRUG_NO=""})async{

    String ChatID ="";
    for(int i=0;i<2;i++){
      ChatID = await check_is_ChatID_sub(
        //UserAccount: '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}',
        //TeacherAccount:"${_eMPLOYEEs[].ACCOUNT}",
        CS_NO:CUSTOMER_selectedValue.CS_NO,
        CLASS_NO:CUSTOMER_selectedValue.CLASS_NO,
        DEPM_NO:CUSTOMER_selectedValue.DEPM_NO,
      );//檢查是否已建立聊天室
      ChatID = ChatID.trim();
      if(ChatID.isNotEmpty){
        break;
      }
    }

    dev.log("ChatID:${ChatID}");

    if(ChatID.isEmpty){
      return;
    }

    String message="您有一筆用藥委託通知\n(${DRUG_NO})";

    final _user = types.User(
      id: '${user.ACCOUNT}',//Uuid().v5(Uuid.NAMESPACE_URL, '${cUSTOMERs[0].cUSTOMER_DL!.ACCOUNT}'),//'82091008-a484-4a89-ae75-a22bf8d6f3ac',
      lastName:'',
      firstName: '${user.USER_NM}',
    );

    DateTime dateTime = DateTime.now();
    String MessageID = "${dateTime.millisecondsSinceEpoch}";
    String AuthorID = _user.id;
    String AuthorFirstName = CUSTOMER_selectedValue.sel_cUSTOMER_DL!.USER_NM;
    String AuthorLastName="";
    String CreatedAt="${DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime)}";
    String Type="text";

    //處理群組多人已讀未讀狀態
    for(int i=0;i<CUSTOMER_selectedValue.cLASS_NO_for_teacher.length;i++){
      String ACCOUNT = CUSTOMER_selectedValue.cLASS_NO_for_teacher[i].ACCOUNT.trim();
      String comm = "INSERT INTO MSRS(ChatID,MessageID,AuthorID,Status) VALUES ('${ChatID}','${MessageID}','${ACCOUNT}','non_seen')";
      dev.log("${comm}");
      String result = await sql_command("${comm}");
      dev.log("result:${result}");
    }

    for(int i=0;i<CUSTOMER_selectedValue.cUSTOMER_DLs.length;i++){
      if(CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.ACCOUNT.trim()!=user.ACCOUNT){
        String ACCOUNT = CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.ACCOUNT.trim();
        String comm = "INSERT INTO MSRS(ChatID,MessageID,AuthorID,Status) VALUES ('${ChatID}','${MessageID}','${ACCOUNT}','non_seen')";
        dev.log("${comm}");
        String result = await sql_command("${comm}");
        dev.log("result:${result}");
      }
    }

    String Status="";
    String Text=message;

    String comm = "INSERT INTO MSDL2(ChatID,MessageID,AuthorID,AuthorFirstName,AuthorLastName,CreatedAt,Type,Status,Text) VALUES ('${ChatID}','${MessageID}','${AuthorID}','${AuthorFirstName}','${AuthorLastName}','${CreatedAt}','${Type}','${Status}','${Text}')";
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

    }
    catch(e){
      dev.log("${e}");
    }

  }



  @override
  Widget build(BuildContext context) {

    _context = context;


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
            title: Text("用藥委託${mode=="編輯"?"(編輯)":"(新增)"}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
          ),
      body:ListView(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        children: [

          /*
                      Container(color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
                        Container(width: 5.w,),
                        Text("學校",style: TextStyle(
                            fontFamily: "GenJyuuGothic",
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            color: Color(0xff292929))),
                        Expanded(child: Container()),
                        Text( _depm.DEPM_NM,style: TextStyle(
                            fontFamily: "GenJyuuGothic",
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            color: Colors.blue)),

                        Container(width: 5.w,),
                      ],),),
                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                      Container(color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
                        Container(width: 5.w,),
                        Text("班級",style: TextStyle(
                            fontFamily: "GenJyuuGothic",
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            color: Color(0xff292929))),
                        Expanded(child: Container()),
                        Text( _class.CLASS_NM,style: TextStyle(
                            fontFamily: "GenJyuuGothic",
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            color: Colors.blue)),

                        Container(width: 5.w,),
                      ],),),
                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                       */
          Container(color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
            Container(width: 5.w,),
            Text("學生",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Color(0xff292929))),
            Expanded(child: Container()),
            (CUSTOMER_selectedValue==null)?Container():
            Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.w),
                ),
                //width: 80.w,
                height: 36.h,
                child:
                DropdownButtonHideUnderline(
                  child: DropdownButton2<CUSTOMER>(
                    isExpanded: true,
                    items: cUSTOMERs
                        .map((CUSTOMER item) => DropdownMenuItem<CUSTOMER>(
                      value: item,
                      child: Text(
                        item.CS_NM,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff555555),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                        .toList(),
                    value: CUSTOMER_selectedValue,
                    onChanged: (value) {

                      CUSTOMER_selectedValue = value!;
                      _class = cLASSs.firstWhere((element) => element.CLASS_NO==CUSTOMER_selectedValue.CLASS_NO)??CLASS();
                      _depm = dEPMs.firstWhere((element) => element.DEPM_NO==CUSTOMER_selectedValue.DEPM_NO)??DEPM();
                      setState(() {

                      });

                    },
                    buttonStyleData:  ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      height: 40.h,
                      width: 130.w,
                    ),
                    menuItemStyleData: MenuItemStyleData(
                      height: 40.h,
                      padding: EdgeInsets.only(left: 14.w, right: 14.w),
                    ),
                  ),
                )),
            Container(width: 5.w,),
          ],)),
          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
          GestureDetector(
              onTap:(){
                Navigator.push(context, PageTransition(
                    type: PageTransitionType.rightToLeft, child: MedicationEntrustment()));
              },
              child: Container(color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
                Container(width: 5.w,),
                Text("用藥原因",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
                Expanded(child: Container()),
                Icon(Icons.arrow_forward_ios,size: 20.sp,),
                Container(width: 5.w,),
              ],),)),
          (drug_reason.DRUG_REASON_ITEM_list.where((e)=>e.is_sel==true).toList().length==0)?Container(padding: EdgeInsets.only(left: 5.w,right: 5.w,bottom: 10.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,child:
          Text("${drug_reason.reason}",style: TextStyle(
              fontFamily: "GenJyuuGothic",
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: Colors.blue))):
          Container(padding: EdgeInsets.only(left: 5.w,right: 5.w,bottom: 10.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,child:
          Text("${drug_reason.DRUG_REASON_ITEM_list.where((e)
          => e.is_sel==true
          ).toList().map((e) => e.ITEM_NM)},${drug_reason.reason}",style: TextStyle(
              fontFamily: "GenJyuuGothic",
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: Colors.blue))),
          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
          GestureDetector(
              onTap:()async{

                if(mode=="新增"){

                  await showDialog(
                    context: context,
                    builder: (context) {
                      List<DateTime> tempSelectedDates = List.from(drug_reason.initialDates);

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: Text('🗓️可選擇多個日期',style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,color: Color(0xff555555) , fontSize: 16.sp)),
                            content: SizedBox(
                              height: 400.h,
                              width: 320.w,
                              child: SfDateRangePicker(
                                initialSelectedDates: tempSelectedDates,
                                selectionMode: DateRangePickerSelectionMode.multiple,
                                onSelectionChanged: (args) {
                                  if (args.value is List<DateTime>) {
                                    setState(() {
                                      tempSelectedDates = args.value;
                                    });
                                  }
                                },
                                minDate: DateTime.now(),
                                maxDate: DateTime.now().add(Duration(days: 90)),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('取消', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,color: Color(0xff555555) , fontSize: 16.sp)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(tempSelectedDates),
                                child: Text('確認', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,color: Color(0xff555555) , fontSize: 16.sp)),

                              ),
                            ],
                          );
                        },
                      );
                    },
                  ).then((result) {
                    if (result != null && result is List<DateTime>) {
                      dev.log('你選的日期: $result');
                      drug_reason.initialDates = result;
                      setState(() {

                      });
                    } else {
                      dev.log('未選擇任何日期');
                    }
                  });

                }
                else{

                  /*
                  日期不能編輯
                drug_reason.dateTime = (await showDatePicker(
                    locale: Locale("zh","TW"),
                    context: context,
                    initialDate: drug_reason.dateTime??DateTime.now(),
                    firstDate: DateTime.now(),
                    builder: (BuildContext context, Widget? child) {
                      return Theme(
                        data: ThemeData.light().copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Color(0xff004ea2), // 選取日期的背景顏色
                            onPrimary: Colors.white,    // 選取日期的文字顏色
                            onSurface: Colors.black,    // 其他文字顏色
                          ),
                          dialogBackgroundColor: Colors.white, // 對話框背景顏色
                        ),
                        child: child!,
                      );
                    },
                    lastDate: DateTime.now().add(Duration(days: 30))))!;

                   */


                }






                setState(() {

                });

              },
              child: Container(color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
                Container(width: 5.w,),
                Text("用藥日期",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
                Expanded(child: Container()),
                (mode=="新增")?Container():
                Text("${DateFormat('yyyy年MM月dd日').format(drug_reason.dateTime!)}",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Colors.blue)),

                Container(width: 10.w,),
                Icon(Icons.arrow_forward_ios,size: 20.sp,),
                Container(width: 5.w,),
              ],),)),


          (mode!="新增")?Container():
          drug_reason.initialDates.isEmpty?Container():
          Container(
              padding: EdgeInsets.only(left:5.w,right: 5.w),
              color: Color(0xffEEEEEE),width: ScreenUtil().screenWidth,child:Text("${(drug_reason.initialDates.toList()..sort())
              .map((d) => "${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}")
              .join(", ")}",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue,fontSize: 16.sp,),)),


          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
          Container(color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
            Container(width: 5.w,),
            Text("用藥明細",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Color(0xff292929))),
            Expanded(child: Container()),
            GestureDetector(
                onTap:(){


                    Navigator.push(context, PageTransition(
                        type: PageTransitionType.rightToLeft, child: MedicationDetails(index:-1)));



                },
                child: Icon(Icons.add_circle_outline,size: 28.sp,)),
            Container(width: 5.w,),
          ],),),
          Container(color: Color(0xffEEEEEE),height: 5.h,),
          Container(color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,child:
          ListView.builder(
              padding: EdgeInsets.zero,
              physics:NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              //itemExtent: 28.h,
              itemCount: drug_reason.DRUG_DL_list.length,
              itemBuilder: (c,index){
                return GestureDetector(
                    onTap: (){
                      Navigator.push(context, PageTransition(
                          type: PageTransitionType.rightToLeft, child: MedicationDetails(index:index,mode:"編輯")));
                    },
                    child: Container(color: Color(0x01000000),width:ScreenUtil().screenWidth,child:
                    Column(children: [
                      Container(height: 5.h,),
                      Container(width:ScreenUtil().screenWidth,height: 28.h,child:Row(children: [
                        Container(width: 5.w,),
                        Text("${drug_reason.DRUG_DL_list[index].DETAIL}",style: TextStyle(
                            fontFamily: "GenJyuuGothic",
                            fontWeight: FontWeight.w400,
                            fontSize: 18.sp,
                            color: Color(0xff292929))),
                        Expanded(child: Container()),
                        GestureDetector(
                            onTap: (){

                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CupertinoAlertDialog(
                                      title: Container(width: ScreenUtil().screenWidth,
                                          child: Text("確定刪除?",
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

                                            Text(
                                              "${drug_reason.DRUG_DL_list[index].DETAIL}",
                                              textScaler: TextScaler.linear(
                                                  1.0),
                                              style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14.sp,
                                                  color: Color(0xff373737)),)

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
                                              "刪除", textScaler: TextScaler
                                              .linear(1.0), style: TextStyle(
                                              fontFamily: "GenJyuuGothic",
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16.sp,
                                              color: Color(0xff373737))),
                                          onPressed: () async {

                                            drug_reason.DRUG_DL_list.removeAt(index);
                                            setState(() {

                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  });

                            },
                            child: Icon(Icons.delete_forever,size: 24.sp,color: Colors.redAccent,)),
                        Container(width: 5.w,),
                      ],)),
                      Container(height: 5.h,),
                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                    ],)));
              }
          )),
          drug_reason.DRUG_DL_list.length>0?Container():
          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

          /*
          Container(height: 30.h,),
          Container(width: ScreenUtil().screenWidth,child:
          Row(children: [
            Checkbox(value: drug_reason.checkbox, onChanged: (v){
              drug_reason.checkbox=v!;
              setState(() {

              });
            }),
            Expanded(child:
            Text("我委託幼兒園依照上述明細用藥，並對此用藥明細負起全部責任。",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Color(0xff292929)))),
          ],)),

           */

          Container(height: 30.h,),

          GestureDetector(
              onTap:(){

                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      showModalBottomSheet_image_context = context;
                      return Column(
                        mainAxisSize: MainAxisSize
                            .min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.photo_camera,size: 18.sp,),
                            title: Text(
                                "拍照",textScaleFactor: 1,style:TextStyle(fontSize: 18.sp)),
                            onTap: () async {

                              Navigator.pop(showModalBottomSheet_image_context!);

                              XFile? imageFile;
                              imageFile = await ImagePicker.ImagePicker().pickImage(source: ImagePicker.ImageSource.camera);


                              if(imageFile!=null) {

                                DateTime t = DateTime.now();
                                Directory tempDir = await getTemporaryDirectory();
                                var tempDirPath = tempDir.path;
                                final myAppPath = '$tempDirPath/威寶通/Drug';
                                final res = await Directory(myAppPath).create(recursive: true);
                                String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';


                                //壓縮image
                                drug_reason.prescriptionsbytes_xfile = await FlutterImageCompress.compressAndGetFile(
                                  imageFile.path, filePath,
                                  minWidth: FlutterImageCompress_width,
                                  minHeight: FlutterImageCompress_height,
                                  quality: FlutterImageCompress_quality,
                                  rotate: 0,
                                );

                                //final path = xfile!.path;
                                //final bytes = await File(path).readAsBytes();
                                //image = img.decodeImage(bytes);



                                setState(() {

                                });

                              }
                              else
                              {
                                Navigator.pop(showModalBottomSheet_image_context!);
                              }


                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.photo_library,size: 18.sp,),
                            title: Text(
                                "相簿",textScaleFactor: 1,style:TextStyle(fontSize: 18.sp)),
                            onTap: () async {

                              Navigator.pop(showModalBottomSheet_image_context!);
                              if (Platform.isAndroid) {





                                PermissionStatus? status;

                                final androidInfo = await DeviceInfoPlugin().androidInfo;
                                if (androidInfo.version.sdkInt <= 32) {
                                  /// use [Permissions.storage.status]
                                  status = await Permission.storage.status;
                                }  else {
                                  /// use [Permissions.photos.status]
                                  //print("test-1");
                                  status = await Permission.photos.status;
                                  //print("test-2");
                                }



                                //print("相簿-1${permission[Permission.WRITE_EXTERNAL_STORAGE]}");

                                if( status.isGranted == false ) {

                                  //print("相簿-3");

                                  try {
                                    Map<Permission, PermissionStatus> statuses = await [
                                      (androidInfo.version.sdkInt <= 32)?Permission.storage:Permission.photos,
                                    ].request();
                                  } on Exception {
                                    //debugPrint("Error");
                                  }

                                  if (androidInfo.version.sdkInt <= 32) {
                                    /// use [Permissions.storage.status]
                                    status = await Permission.storage.status;
                                  }  else {
                                    /// use [Permissions.photos.status]
                                    status = await Permission.photos.status;
                                  }

                                  if( status.isGranted == true) {
                                    //print("Login ok");

                                    PlatformFile? result = await FilePicker.pickFile(
                                      //allowMultiple: false,
                                      type: FileType.image,
                                      //allowedExtensions: (Platform.isIOS)?null:['jpg','png','jpeg'],
                                    );

                                    if(result==null){
                                      return;
                                    }

                                    var imageFile = result.xFile;

                                    if (imageFile !=
                                        null) {
                                      //print(
                                      //    "imageFile.lengthSync1():${imageFile
                                      //        .lengthSync()}");

                                      DateTime t = DateTime.now();
                                      Directory tempDir = await getTemporaryDirectory();
                                      var tempDirPath = tempDir.path;
                                      final myAppPath = '$tempDirPath/威寶通/Drug';
                                      final res = await Directory(myAppPath).create(recursive: true);
                                      String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                      //壓縮image
                                      drug_reason.prescriptionsbytes_xfile = await FlutterImageCompress
                                          .compressAndGetFile(
                                        imageFile.path, filePath,
                                        minWidth: FlutterImageCompress_width,
                                        minHeight: FlutterImageCompress_height,
                                        quality: FlutterImageCompress_quality,
                                        rotate: 0,
                                      );

                                      setState(() {
                                        //_image = image;
                                      });
                                    }
                                    else {
                                      Navigator
                                          .pop(
                                          showModalBottomSheet_image_context!);
                                    }

                                  }
                                  else {
                                    return;
                                  }

                                }
                                else{
                                  //print("相簿-2");
                                  PlatformFile? result = await FilePicker.pickFile(
                                    //allowMultiple: false,
                                    type: FileType.image,
                                    //allowedExtensions: (Platform.isIOS)?null:['jpg','png','jpeg'],
                                  );

                                  if(result==null){
                                    return;
                                  }

                                  var imageFile = result.xFile;

                                  if (imageFile !=
                                      null) {
                                    //print(
                                    //    "imageFile.lengthSync1():${imageFile
                                    //        .lengthSync()}");

                                    DateTime t = DateTime.now();
                                    Directory tempDir = await getTemporaryDirectory();
                                    var tempDirPath = tempDir.path;
                                    final myAppPath = '$tempDirPath/威寶通/Drug';
                                    final res = await Directory(myAppPath).create(recursive: true);
                                    String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                    //壓縮image
                                    drug_reason.prescriptionsbytes_xfile = await FlutterImageCompress
                                        .compressAndGetFile(
                                      imageFile.path, filePath,
                                      minWidth: FlutterImageCompress_width,
                                      minHeight: FlutterImageCompress_height,
                                      quality: FlutterImageCompress_quality,
                                      rotate: 0,
                                    );

                                    setState(() {

                                    });



                                  }
                                  else {
                                    Navigator
                                        .pop(
                                        showModalBottomSheet_image_context!);
                                  }
                                }




                              }
                              else {
                                PlatformFile? result = await FilePicker.pickFile(
                                  //allowMultiple: false,
                                  type: FileType.image,
                                  //allowedExtensions: (Platform.isIOS)?null:['jpg','png','jpeg'],
                                );

                                if(result==null){
                                  return;
                                }

                                var imageFile = result.xFile;

                                if (imageFile !=
                                    null) {
                                  //print(
                                  //    "imageFile.lengthSync1():${imageFile
                                  //        .lengthSync()}");

                                  DateTime t = DateTime.now();
                                  Directory tempDir = await getTemporaryDirectory();
                                  var tempDirPath = tempDir.path;
                                  final myAppPath = '$tempDirPath/威寶通/Drug';
                                  final res = await Directory(myAppPath).create(recursive: true);
                                  String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                  //壓縮image
                                  drug_reason.prescriptionsbytes_xfile = await FlutterImageCompress
                                      .compressAndGetFile(
                                    imageFile.path, filePath,
                                    minWidth: FlutterImageCompress_width,
                                    minHeight: FlutterImageCompress_height,
                                    quality: FlutterImageCompress_quality,
                                    rotate: 0,
                                  );


                                  setState(() {

                                  });


                                  setState(() {
                                    //_image = image;
                                  });
                                }
                                else {
                                  Navigator
                                      .pop(
                                      showModalBottomSheet_image_context!);
                                }



                              }


                            },
                          ),
                        ],
                      );

                    });


              },
              child: Container(color: Color(0x01000000),width: ScreenUtil().screenWidth,child:Center(child:Column(children: [

                (mode=="編輯")?
                (drug_reason.prescriptionsbytes_xfile!=null)?
                Container(width: ScreenUtil().screenWidth,height: 150.h,decoration:  BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.contain,
                        image:  FileImage(File(drug_reason.prescriptionsbytes_xfile!.path),scale: 0.9)
                    )
                ))
                    :
                (drug_reason.DRUG_LINK.isNotEmpty)?
                    Container(width: ScreenUtil().screenWidth,height: 150.h,child:
                    Image.network("${drug_reason.DRUG_LINK}",errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      dev.log("drug_reason.DRUG_LINK:${drug_reason.DRUG_LINK}");
                      return  Icon(Icons.error,size: 30.sp,);
                    }))
                    :
                Text.rich(
                  TextSpan(
                    text: "請按此處加上藥單封面",
                    style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929),
                    ),
                    children: [
                      TextSpan(
                        text: "及處方藥籤",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ):
                (drug_reason.prescriptionsbytes_xfile==null)?
                Text.rich(
                  TextSpan(
                    text: "請按此處加上藥單封面",
                    style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929),
                    ),
                    children: [
                      TextSpan(
                        text: "及處方藥籤",
                        style: TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ):
                Container(width: ScreenUtil().screenWidth,height: 150.h,decoration:  BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.contain,
                        image:  FileImage(File(drug_reason.prescriptionsbytes_xfile!.path),scale: 0.9)
                    )
                )),

                Container(height: 10.h,),
                Container(width: ScreenUtil().screenWidth,height: 1,color: Color(0xff292929),),

              ],)))),
          Container(height: 50.h,),
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
                                        if(CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK.isEmpty){
                                          SmartDialog.showToast("請先至設定頁>帳號相關>輸入預設簽名");
                                          return;
                                        }
                                        DRUG_MT_U_page_SING_LINK_TYPE="匯入預設簽名";
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        SmartDialog.showLoading(msg: "處理中...");
                                        await Future.delayed(const Duration(milliseconds: 500), () {});
                                        drug_reason.signaturebytes = await get_url_image_to_byte_sub(img_url:"${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK}");
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
                                            type: PageTransitionType.rightToLeft, child: SignaturePage()));
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
              child: Container(color: Color(0x01000000),width: ScreenUtil().screenWidth,child:Center(child:Column(children: [

                (mode=="編輯")?
                (drug_reason.signaturebytes!=null)?
                Container(width: ScreenUtil().screenWidth,height: 100.h,child:
                (DRUG_MT_U_page_SING_LINK_TYPE=="匯入預設簽名")?
                Image.network(CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK)
                    :
                Image.memory(drug_reason.signaturebytes!))
                    :
                (drug_reason.SIGN_LINK.isNotEmpty)?
                Container(width: ScreenUtil().screenWidth,height: 150.h,child:
                Image.network("${drug_reason.SIGN_LINK}",errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return  Icon(Icons.error,size: 30.sp,);
                }))
                    :
                Text("請按此處加上手寫簽名",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929)))
                    :
                (drug_reason.signaturebytes==null)?
                Text("請按此處加上手寫簽名",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))):
                Container(width: ScreenUtil().screenWidth,height: 100.h,child:
                (DRUG_MT_U_page_SING_LINK_TYPE=="匯入預設簽名")?
                Image.network(CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK)
                    :
                Image.memory(drug_reason.signaturebytes!)),

                Container(height: 10.h,),
                Container(width: ScreenUtil().screenWidth,height: 1,color: Color(0xff292929),),
                Container(height: 50.h,),

                Container(
                    padding: EdgeInsets.only( left:10.w,right: 10.w),
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




                        if(drug_reason.DRUG_REASON_ITEM_list.length==0 && drug_reason.reason.isEmpty){
                          SmartDialog.showToast("請填寫用藥原因");
                          return;
                        }

                        if(mode=="新增"){
                          if(drug_reason.initialDates.isEmpty){
                            SmartDialog.showToast("請填寫用藥日期");
                            return;
                          }
                        }
                        else{
                          if(drug_reason.dateTime==null){
                            SmartDialog.showToast("請填寫用藥日期");
                            return;
                          }
                        }

                        if(drug_reason.DRUG_DL_list.length==0){
                          SmartDialog.showToast("請至少建立一筆明細");
                          return;
                        }

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, StateSetter setStateSB) {
                                return CupertinoAlertDialog(
                                  title: Container(
                                    width: ScreenUtil().screenWidth,
                                    child: Text(
                                      "確定送出?",
                                      textScaler: TextScaler.linear(1.0),
                                      style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.sp,
                                        color: Color(0xff373737),
                                      ),
                                    ),
                                  ),
                                  content: Column(
                                    children: <Widget>[
                                      SizedBox(height: 10.h),
                                      Container(
                                        width: ScreenUtil().screenWidth,
                                        child: Row(
                                          children: [
                                            /*
                                            Checkbox(
                                              value: drug_reason.checkbox,
                                              onChanged: (v) {
                                                setStateSB(() {
                                                  drug_reason.checkbox = v!;
                                                });
                                              },
                                            ),

                                             */
                                            Expanded(
                                              child: Text(
                                                "我委託幼兒園依照上述明細用藥，並對此用藥明細負起全部責任。",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18.sp,
                                                  color: Color(0xff292929),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: <Widget>[
                                    CupertinoDialogAction(
                                      child: Text(
                                        "取消",
                                        textScaler: TextScaler.linear(1.0),
                                        style: TextStyle(
                                          fontFamily: "GenJyuuGothic",
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16.sp,
                                          color: Color(0xff373737),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    CupertinoDialogAction(
                                      child: Text(
                                        "送出",
                                        textScaler: TextScaler.linear(1.0),
                                        style: TextStyle(
                                          fontFamily: "GenJyuuGothic",
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16.sp,
                                          color: Color(0xff373737),
                                        ),
                                      ),
                                      onPressed: () async {

                                        /*
                                        if (drug_reason.checkbox == false) {
                                          SmartDialog.showToast("請勾選同意委託");
                                          return;
                                        }

                                         */

                                        Navigator.pop(context);
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        if(mode=="編輯"){

                                          SmartDialog.showLoading(msg: "編輯處理中...");

                                          String DRUG_NO = drug_reason.DRUG_NO;
                                          String REASON = "";
                                          bool check=false;
                                          for(int i=0;i<drug_reason.DRUG_REASON_ITEM_list.length;i++){
                                            if(drug_reason.DRUG_REASON_ITEM_list[i].is_sel==true) {
                                              if(check==false){
                                                check = true;
                                                REASON = "${drug_reason.DRUG_REASON_ITEM_list[i].ITEM_NM}";
                                              }
                                              else{
                                                REASON = "${REASON},${drug_reason.DRUG_REASON_ITEM_list[i].ITEM_NM}";
                                              }
                                            }
                                          }
                                          if(drug_reason.reason.isNotEmpty){
                                            if(REASON.isEmpty){
                                              REASON = "${drug_reason.reason}";
                                            }
                                            else{
                                              REASON = "${REASON},${drug_reason.reason}";
                                            }
                                          }

                                          String file_name = "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT}_${DateTime.now().microsecondsSinceEpoch}";
                                          if(drug_reason.signaturebytes!=null){
                                            if(DRUG_MT_U_page_SING_LINK_TYPE!="匯入預設簽名"){
                                              bool is_success = await upload_image(img: drug_reason.signaturebytes,file_name: "${file_name}",folder: "Sign");
                                              if(is_success==false){
                                                SmartDialog.dismiss();
                                                SmartDialog.showToast("上傳簽名失敗,請重新嘗試");
                                                return;
                                              }
                                            }
                                          }

                                          if(drug_reason.prescriptionsbytes_xfile!=null){
                                            bool is_success = await upload_image(image_path: drug_reason.prescriptionsbytes_xfile!.path,file_name: "${DRUG_NO}_${file_name}",folder: "Drug");
                                            if(is_success==false){
                                              SmartDialog.dismiss();
                                              SmartDialog.showToast("上傳藥單封面失敗,請重新嘗試");
                                              return;
                                            }
                                          }


                                          bool is_success = await update_DRUG_MT_db_sub(
                                              DRUG_NO:DRUG_NO,//編號
                                              DATE:"${DateFormat('yyyy-MM-dd').format(drug_reason.dateTime!)}",//日期
                                              DEPM_NO:"${CUSTOMER_selectedValue.DEPM_NO}",//學校
                                              CLASS_NO:"${CUSTOMER_selectedValue.CLASS_NO}",//班級
                                              CS_NO:"${CUSTOMER_selectedValue.CS_NO}",//學生編號
                                              REASON:"${REASON}",//用藥原因
                                              DRUG_LINK:(drug_reason.prescriptionsbytes_xfile==null)?"~/School/Images/Drug/${drug_reason.DRUG_LINK.split("/").last}":"~/School/Images/Drug/${DRUG_NO}_${file_name}.jpg",//藥單封面
                                              AGREE:drug_reason.checkbox,//同意
                                              SIGN_LINK:(drug_reason.signaturebytes!=null)?(DRUG_MT_U_page_SING_LINK_TYPE=="匯入預設簽名"?"${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK.replaceAll(IMAGE_IP,"~")}":"~/School/Images/Sign/${file_name}.jpg"):"~/School/Images/Sign/${drug_reason.SIGN_LINK.split("/").last}",//簽名
                                              DATETIME:"${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}"//送出時間
                                          );
                                          if(is_success==false){
                                            SmartDialog.dismiss();
                                            SmartDialog.showToast("更新委託藥單資料失敗,請重新嘗試");
                                            return;
                                          }


                                          //先砍掉明細
                                          String comm = "DELETE FROM DRUG_DL WHERE DRUG_NO='${DRUG_NO}'";
                                          String result = await sql_command("${comm}");


                                          //送出明細
                                          dev.log("送出明細(drug_reason.DRUG_DL_list.lengt):${drug_reason.DRUG_DL_list.length}");
                                          bool check_upload_image_is_fail = false;
                                          bool check_insert_DRUG_DL_db_is_fail = false;
                                          for(int i=0;i<drug_reason.DRUG_DL_list.length;i++){

                                            String microsecondsSinceEpoch = "${DateTime.now().microsecondsSinceEpoch}";
                                            if(drug_reason.DRUG_DL_list[i].prescriptionsbytes_xfile!=null){
                                              bool is_success = await upload_image(image_path: drug_reason.DRUG_DL_list[i].prescriptionsbytes_xfile!.path,file_name: "${DRUG_NO}_${i+1}_${microsecondsSinceEpoch}",folder: "Drug");
                                              if(is_success==false){
                                                check_upload_image_is_fail=true;
                                              }
                                            }
                                            else{

                                            }
                                            bool is_success = await insert_DRUG_DL_db_sub(
                                              DRUG_NO:DRUG_NO,//編號
                                              DRUG_SR:"${i+1}",
                                              DETAIL:"${drug_reason.DRUG_DL_list[i].DETAIL}",
                                              STORE:"${drug_reason.DRUG_DL_list[i].STORE}",
                                              MODE:"${drug_reason.DRUG_DL_list[i].MODE}",
                                              UNIT:"${drug_reason.DRUG_DL_list[i].UNIT}",
                                              DOSAGE:"${drug_reason.DRUG_DL_list[i].DOSAGE}",
                                              TIME1:"${drug_reason.DRUG_DL_list[i].TIME1}",//
                                              TIME2:drug_reason.DRUG_DL_list[i].TIME2,//
                                              TIME3:drug_reason.DRUG_DL_list[i].TIME3,//
                                              DRUG_LINK:(drug_reason.DRUG_DL_list[i].prescriptionsbytes_xfile==null)?"~/School/Images/Drug/${drug_reason.DRUG_DL_list[i].DRUG_LINK.split("/").last}":"~/School/Images/Drug/${DRUG_NO}_${i+1}_${microsecondsSinceEpoch}.jpg",//藥品照片
                                              NOTE:"${drug_reason.DRUG_DL_list[i].NOTE}",//
                                            );
                                            if(is_success==false){
                                              check_insert_DRUG_DL_db_is_fail=true;
                                            }
                                          }


                                          /*
                          drug_reason = DRUG_REASON();
                          setState(() {

                          });

                           */


                                          SmartDialog.dismiss();
                                          SmartDialog.showToast("用藥委託編輯成功");
                                          MyHomePage2_U_fun1!(reflash_db:"用藥委託");
                                          Navigator.pop(_context!);


                                          Future.delayed(const Duration(milliseconds: 500), () async{

                                            if(check_upload_image_is_fail==true || check_insert_DRUG_DL_db_is_fail==true){
                                              //如果上傳用藥明細圖片有一筆失敗,就提示訊息給使用者知道
                                              String str = '';
                                              if(check_upload_image_is_fail==true){
                                                str='圖片';
                                              }
                                              if(check_insert_DRUG_DL_db_is_fail==true){
                                                str='${str},資料';
                                              }
                                              try{
                                                MyHomePage2_U_fun4!(warr_message:'委託用藥編輯成功，但有部分明細更新失敗(${str})，可透過編輯重新上傳');
                                              }
                                              catch(e){

                                              }
                                            }

                                            //找出學生的老師
                                            for(int i=0;i<cLASS_NO_for_teacher_chat.length;i++){
                                              if(CUSTOMER_selectedValue.DEPM_NO==cLASS_NO_for_teacher_chat[i].DEPM_NO && CUSTOMER_selectedValue.CLASS_NO==cLASS_NO_for_teacher_chat[i].CLASS_NO
                                              ){
                                                String FCM = await search_EMPLOYEE_fcm_sub(ACCOUNT:cLASS_NO_for_teacher_chat[i].ACCOUNT);
                                                await sendPushNotification(
                                                    title: "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.USER_NM} 家長",
                                                    message: "編輯一筆用藥委託",
                                                    token: FCM,//cLASS_NO_for_teacher_chat[i].FCM,
                                                    ChatID:"用藥委託",
                                                    DRUG_NO:"${DRUG_NO}",
                                                    CS_NO:CUSTOMER_selectedValue.CS_NO,
                                                    DATE:"${DateFormat('yyyy-MM-dd').format(drug_reason.dateTime!)}",//日期
                                                    UserAccount:'${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT.trim()}',
                                                    TeacherAccount:"${cLASS_NO_for_teacher_chat[i].ACCOUNT}".trim()
                                                );
                                              }

                                            }

                                          });




                                        }
                                        else{
                                          if(drug_reason.prescriptionsbytes_xfile==null){
                                            SmartDialog.showToast("請加上藥單封面");
                                            return;
                                          }
                                          if(drug_reason.signaturebytes==null){
                                            SmartDialog.showToast("請手動簽名");
                                            return;
                                          }

                                          FocusManager.instance.primaryFocus?.unfocus();
                                          SmartDialog.showLoading(msg: "新增處理中...");



                                          final dateFormat = DateFormat('yyyy-MM-dd');
                                          final values = drug_reason.initialDates
                                              .map((date) => "('${dateFormat.format(date)}')") // 轉換成 yyyy-MM-dd
                                              .join(",");

                                          String REASON = "";
                                          bool check=false;
                                          for(int i=0;i<drug_reason.DRUG_REASON_ITEM_list.length;i++){
                                            if(drug_reason.DRUG_REASON_ITEM_list[i].is_sel==true) {
                                              if(check==false){
                                                check = true;
                                                REASON = "${drug_reason.DRUG_REASON_ITEM_list[i].ITEM_NM}";
                                              }
                                              else{
                                                REASON = "${REASON},${drug_reason.DRUG_REASON_ITEM_list[i].ITEM_NM}";
                                              }
                                            }
                                          }
                                          if(drug_reason.reason.isNotEmpty){
                                            if(REASON.isEmpty){
                                              REASON = "${drug_reason.reason}";
                                            }
                                            else{
                                              REASON = "${REASON},${drug_reason.reason}";
                                            }

                                          }

                                          String file_name = "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT}_${DateTime.now().microsecondsSinceEpoch}";

                                          final valuesDl = <String>[];
                                          for (int i = 0; i < drug_reason.initialDates.length; i++) {
                                            final dateStr = dateFormat.format(drug_reason.initialDates[i]);
                                            for (int j = 0; j < drug_reason.DRUG_DL_list.length; j++) {
                                              String time1 = drug_reason.DRUG_DL_list[j].TIME1 == null
                                                  ? 'NULL'
                                                  : "'${drug_reason.DRUG_DL_list[j].TIME1}'";

                                              String time2 = drug_reason.DRUG_DL_list[j].TIME2 == null
                                                  ? 'NULL'
                                                  : "'${drug_reason.DRUG_DL_list[j].TIME2}'";

                                              String time3 = drug_reason.DRUG_DL_list[j].TIME3 == null
                                                  ? 'NULL'
                                                  : "'${drug_reason.DRUG_DL_list[j].TIME3}'";

                                              valuesDl.add('''
                                ('$dateStr',
                                N'${drug_reason.DRUG_DL_list[j].DETAIL}',
                                '${drug_reason.DRUG_DL_list[j].STORE}',
                                '${drug_reason.DRUG_DL_list[j].MODE}',
                                '${drug_reason.DRUG_DL_list[j].UNIT}',
                                '${drug_reason.DRUG_DL_list[j].DOSAGE}',
                                $time1,
                                $time2,
                                $time3,
                                N'${drug_reason.DRUG_DL_list[j].NOTE}',
                                '${drug_reason.DRUG_DL_list[j].DRUG_LINK}'
                                )''');
                                            }
                                          }
                                          String valuesDlStr = valuesDl.join(",");
                                          if(DRUG_MT_U_page_SING_LINK_TYPE!="匯入預設簽名"){
                                            bool is_success = await upload_image(img: drug_reason.signaturebytes,file_name: file_name,folder: "Sign");
                                            if(is_success==false){
                                              SmartDialog.dismiss();
                                              SmartDialog.showToast("上傳簽名失敗,請重新嘗試");
                                              return;
                                            }
                                          }
                                          if(drug_reason.prescriptionsbytes_xfile!=null){
                                            bool is_success = await upload_image(image_path: drug_reason.prescriptionsbytes_xfile!.path,file_name: "${file_name}",folder: "Drug");
                                            if(is_success==false){
                                              SmartDialog.dismiss();
                                              SmartDialog.showToast("上傳藥單封面失敗,請重新嘗試");
                                              return;
                                            }
                                          }

                                          //先找出目前所選日期托藥已存在的DRUG_NO號
                                          final datesSql = drug_reason.initialDates
                                              .map((d) => "'${dateFormat.format(d)}'")
                                              .join(",");
                                          final comm1 = "SELECT DRUG_NO FROM DRUG_MT WHERE [DATE] IN ($datesSql) AND DEPM_NO = '${CUSTOMER_selectedValue.DEPM_NO}' AND CLASS_NO='${CUSTOMER_selectedValue.CLASS_NO}' AND CS_NO='${CUSTOMER_selectedValue.CS_NO}'";
                                          String result1 = await sql_command("${comm1}");
                                          List<dynamic> exists_DRUG_NOs = jsonDecode(result1);
                                          dev.log("exists_DRUG_NOs:${exists_DRUG_NOs}");

                                          String comm = '''
                  BEGIN TRANSACTION;

-- 1) 參數宣告
DECLARE @DEPM_NO     NCHAR(4)   = N'${CUSTOMER_selectedValue.DEPM_NO}';
DECLARE @CLASS_NO    NCHAR(10)  = N'${CUSTOMER_selectedValue.CLASS_NO}';
DECLARE @CS_NO       NCHAR(10)  = N'${CUSTOMER_selectedValue.CS_NO}';
DECLARE @REASON      NVARCHAR(255) = N'${REASON}';
DECLARE @AGREE       bit = ${drug_reason.checkbox ? "1" : "0"};
DECLARE @DRUG_LINK   NVARCHAR(MAX) = N'${(drug_reason.prescriptionsbytes_xfile==null)?"":"~/School/Images/Drug/${file_name}.jpg"}';
DECLARE @SIGN_LINK   NVARCHAR(MAX) = N'${
                                              DRUG_MT_U_page_SING_LINK_TYPE=="匯入預設簽名"?"${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK.replaceAll(IMAGE_IP,"~")}":"~/School/Images/Sign/${file_name}.jpg"
                                          }';

-- 2) 日期清單
DECLARE @dateList TABLE (DATE_VALUE DATE);
INSERT INTO @dateList (DATE_VALUE) VALUES $values;  -- e.g. ('2025-09-01'),('2025-09-01'),('2025-09-02')

-- 3) 生成每筆 DRUG_MT  的 NO
DECLARE @t TABLE (ROW_ID INT, DATE_VALUE DATE, NEW_NO NCHAR(12));

INSERT INTO @t (ROW_ID, DATE_VALUE, NEW_NO)
SELECT
    ROW_NUMBER() OVER (ORDER BY d.DATE_VALUE, d2.rn) AS ROW_ID,
    d.DATE_VALUE,
    CONVERT(CHAR(8), d.DATE_VALUE, 112) +
    RIGHT(
        '000' + CAST(
            ISNULL(MaxNo.MaxSeq,0) + 
            ROW_NUMBER() OVER (PARTITION BY d.DATE_VALUE ORDER BY d.DATE_VALUE, d2.rn)
            AS VARCHAR(4)
        ),
        4
    ) AS NEW_NO
FROM @dateList d
CROSS APPLY (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn) d2
OUTER APPLY (
    SELECT MAX(CAST(RIGHT(DRUG_NO,4) AS INT)) AS MaxSeq
    FROM [APP].[dbo].[DRUG_MT] e WITH (UPDLOCK,HOLDLOCK)
    WHERE LEFT(e.DRUG_NO,8)=CONVERT(CHAR(8), d.DATE_VALUE,112)
) MaxNo;

-- 4) 插入 DRUG_MT 主表
INSERT INTO [APP].[dbo].[DRUG_MT]
([DRUG_NO],[DATE],DEPM_NO,CLASS_NO,CS_NO,REASON,DRUG_LINK,AGREE,SIGN_LINK,DATETIME)
SELECT 
    NEW_NO,
    DATE_VALUE,
    @DEPM_NO,
    @CLASS_NO,
    @CS_NO,
    @REASON,
    @DRUG_LINK,
    @AGREE,
    @SIGN_LINK,
    GETDATE()
FROM @t;

-- 5) 子表資料
DECLARE @DRUG_DL TABLE (
    DATE_VALUE DATE,
    DETAIL NVARCHAR(255),
    STORE NVARCHAR(50),
    MODE NVARCHAR(50),
    UNIT NVARCHAR(20),
    DOSAGE NVARCHAR(50),
    TIME1 TIME,
    TIME2 TIME,
    TIME3 TIME,
    NOTE NVARCHAR(255),
    DRUG_LINK NVARCHAR(MAX)
);

INSERT INTO @DRUG_DL (DATE_VALUE, DETAIL, STORE,MODE,UNIT,DOSAGE,TIME1,TIME2,TIME3,NOTE,DRUG_LINK)
VALUES $valuesDlStr;

-- 6) 插入 DRUG_DL
WITH cte AS (
    SELECT 
        dl.DATE_VALUE,
        dl.DETAIL,
        dl.STORE,
        dl.MODE,
        dl.UNIT,
        dl.DOSAGE,
        dl.TIME1,
        dl.TIME2,
        dl.TIME3,
        dl.NOTE,
        dl.DRUG_LINK,
        ROW_NUMBER() OVER (PARTITION BY dl.DATE_VALUE ORDER BY (SELECT NULL)) AS rn  -- SR 自動 +1
    FROM @DRUG_DL dl
)

INSERT INTO [APP].[dbo].[DRUG_DL] (
    DRUG_NO, DRUG_SR, DETAIL, STORE, MODE, UNIT, DOSAGE, TIME1, TIME2, TIME3, DRUG_LINK, NOTE
)
SELECT
    t.NEW_NO,
    CAST(c.rn AS CHAR(1)),
    c.DETAIL,
    c.STORE,
    c.MODE,
    c.UNIT,
    c.DOSAGE,
    c.TIME1,
    c.TIME2,
    c.TIME3,
    '~/School/Images/Drug/' + t.NEW_NO + '_' + CAST(c.rn AS NVARCHAR(10)) + '.jpg',
    c.NOTE
FROM cte c
JOIN @t t ON t.DATE_VALUE = c.DATE_VALUE;

-- 回傳所有產生的 NEW_NO
SELECT NEW_NO FROM @t;

COMMIT;

                  ''';
                                          dev.log("comm:${comm}");
                                          String result = await sql_command("${comm}");
                                          dev.log("家長委藥(回應):${result}");


                                          try{
                                            dynamic map = jsonDecode(result);
                                            if("${map["message"]}"=="執行成功"){


                                              final dateFormat = DateFormat('yyyy-MM-dd');
                                              final datesSql = drug_reason.initialDates
                                                  .map((d) => "'${dateFormat.format(d)}'")
                                                  .join(",");

                                              final comm = "SELECT DRUG_NO,DATE FROM DRUG_MT WHERE [DATE] IN ($datesSql) AND DEPM_NO = '${CUSTOMER_selectedValue.DEPM_NO}' AND CLASS_NO='${CUSTOMER_selectedValue.CLASS_NO}' AND CS_NO='${CUSTOMER_selectedValue.CS_NO}'";
                                              String result = await sql_command("${comm}");
                                              List<dynamic> map = jsonDecode(result);

                                              // 萃取出存在的 DRUG_NO 值
                                              List<dynamic> existingNos = exists_DRUG_NOs.map((e) => e["DRUG_NO"]).toList();
                                              // 過濾掉已存在的 DRUG_NO
                                              map.removeWhere((item) => existingNos.contains(item["DRUG_NO"]));

                                              dev.log("map:${map}");
                                              bool check_upload_image_is_fail = false;
                                              for(int iii=0;iii<map.length;iii++){
                                                SmartDialog.showLoading(msg: "新增處理中...(推播通知${iii+1})");
                                                await insert_MSDL2_db_sub(DRUG_NO:"${map[iii]["DRUG_NO"]}");
                                                for(int i=0;i<drug_reason.DRUG_DL_list.length;i++){
                                                  if(drug_reason.DRUG_DL_list[i].prescriptionsbytes_xfile!=null){
                                                    dev.log("上傳子表單圖片:${map[iii]["DRUG_NO"]}_${i+1}");
                                                    bool is_success = await upload_image(image_path: "${drug_reason.DRUG_DL_list[i].prescriptionsbytes_xfile!.path}",file_name: "${map[iii]["DRUG_NO"]}_${i+1}",folder: "Drug");
                                                    if(is_success==false){
                                                      check_upload_image_is_fail=true;
                                                    }
                                                  }
                                                }
                                                dev.log("找出學生的老師");

                                                //找出學生的老師
                                                for(int i=0;i<cLASS_NO_for_teacher_chat.length;i++){
                                                  if(CUSTOMER_selectedValue.DEPM_NO==cLASS_NO_for_teacher_chat[i].DEPM_NO &&
                                                      CUSTOMER_selectedValue.CLASS_NO==cLASS_NO_for_teacher_chat[i].CLASS_NO
                                                  ){

                                                    String FCM = await search_EMPLOYEE_fcm_sub(ACCOUNT:cLASS_NO_for_teacher_chat[i].ACCOUNT);
                                                    dev.log("FCM:${FCM}");
                                                    if(FCM.isNotEmpty){
                                                      await sendPushNotification(
                                                          title: "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.USER_NM} 家長",
                                                          message: "新增一筆用藥委託",
                                                          token: FCM,
                                                          ChatID:"用藥委託",
                                                          DRUG_NO:"${map[iii]["DRUG_NO"]}",
                                                          CS_NO:CUSTOMER_selectedValue.CS_NO,
                                                          DATE:"${DateFormat('yyyy-MM-dd').format(DateTime.parse("${map[iii]["DATE"]}"))}",//日期
                                                          UserAccount:'${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT.trim()}',
                                                          TeacherAccount:"${cLASS_NO_for_teacher_chat[i].ACCOUNT}".trim()
                                                      );
                                                    }

                                                  }
                                                }
                                              }


                                              SmartDialog.dismiss();
                                              SmartDialog.showToast("用藥委託新增成功");
                                              MyHomePage2_U_fun1!(reflash_db:"用藥委託");
                                              Navigator.pop(_context!);
                                              await Future.delayed(const Duration(milliseconds: 500),(){
                                                if(check_upload_image_is_fail==true){
                                                  //如果上傳用藥明細圖片有一筆失敗,就提示訊息給使用者知道
                                                  try{
                                                    MyHomePage2_U_fun4!(warr_message:'委託用藥新增成功，但有部分明細圖片上傳失敗，可透過編輯重新上傳');
                                                  }
                                                  catch(e){

                                                  }
                                                }
                                              });


                                            }
                                            else{
                                              SmartDialog.dismiss();
                                              SmartDialog.showToast("執行失敗,請重新嘗試");
                                            }
                                          }
                                          catch(e){
                                            dev.log('err:${e}');
                                            SmartDialog.dismiss();
                                            SmartDialog.showToast("執行失敗,請重新嘗試");
                                          }



                                          /*
                          for(int iii=0;iii<drug_reason.initialDates.length;iii++){

                            SmartDialog.showLoading(msg: "處理中...(${iii+1})");
                            int DRUG_NO_num = await read_DRUG_MT_db_sub(index:iii);//先確定圖片流水號
                            dev.log("DRUG_NO_num:${DRUG_NO_num}");
                            if(DRUG_NO_num==-1){
                              SmartDialog.showToast("read_DRUG_MT_db_sub error");
                              return;
                            }
                            //DRUG_NO_num+=1;
                            String DRUG_NO = "${DRUG_NO_num}";//"${DateFormat('yyyyMMdd').format(drug_reason.initialDates[iii])}${DRUG_NO_num.toString().padLeft(4,"0")}";
                            String REASON = "";
                            bool check=false;
                            for(int i=0;i<drug_reason.DRUG_REASON_ITEM_list.length;i++){
                              if(drug_reason.DRUG_REASON_ITEM_list[i].is_sel==true) {
                                if(check==false){
                                  check = true;
                                  REASON = "${drug_reason.DRUG_REASON_ITEM_list[i].ITEM_NM}";
                                }
                                else{
                                  REASON = "${REASON},${drug_reason.DRUG_REASON_ITEM_list[i].ITEM_NM}";
                                }
                              }
                            }
                            if(drug_reason.reason.isNotEmpty){
                              REASON = "${REASON},${drug_reason.reason}";
                            }

                            String file_name = "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT}_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}";

                            bool check2 = await insert_DRUG_MT_db_sub(
                                DRUG_NO:DRUG_NO,//編號
                                DATE:"${DateFormat('yyyy-MM-dd').format(drug_reason.initialDates[iii])}",//日期
                                DEPM_NO:"${CUSTOMER_selectedValue.DEPM_NO}",//學校
                                CLASS_NO:"${CUSTOMER_selectedValue.CLASS_NO}",//班級
                                CS_NO:"${CUSTOMER_selectedValue.CS_NO}",//學生編號
                                REASON:"${REASON}",//用藥原因
                                DRUG_LINK:(drug_reason.prescriptionsbytes_xfile==null)?"":"~/School/Images/Drug/${DRUG_NO}_${file_name}.jpg",//藥單封面
                                AGREE:drug_reason.checkbox,//同意
                                SIGN_LINK:DRUG_MT_U_page_SING_LINK_TYPE=="匯入預設簽名"?"${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK.replaceAll(IMAGE_IP,"~")}":"~/School/Images/Sign/${file_name}.jpg",//簽名
                                DATETIME:"${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}"//送出時間
                            );

                            if(check2==false){
                              SmartDialog.dismiss();
                              SmartDialog.showToast("忙碌中，請重試");
                              return;
                            }
                            if(DRUG_MT_U_page_SING_LINK_TYPE!="匯入預設簽名"){
                              await upload_image(img: drug_reason.signaturebytes,file_name: file_name,folder: "Sign");
                            }

                            if(drug_reason.prescriptionsbytes_xfile!=null){
                              await upload_image(image_path: drug_reason.prescriptionsbytes_xfile!.path,file_name: "${DRUG_NO}_${file_name}",folder: "Drug");
                            }


                            //送出明細
                            dev.log("送出明細(drug_reason.DRUG_DL_list.lengt):${drug_reason.DRUG_DL_list.length}");
                            for(int i=0;i<drug_reason.DRUG_DL_list.length;i++){
                              String microsecondsSinceEpoch = "${DateTime.now().microsecondsSinceEpoch}";
                              if(drug_reason.DRUG_DL_list[i].prescriptionsbytes_xfile!=null){
                                await upload_image(image_path: drug_reason.DRUG_DL_list[i].prescriptionsbytes_xfile!.path,file_name: "${DRUG_NO}_${i+1}_${microsecondsSinceEpoch}",folder: "Drug");
                              }
                              await insert_DRUG_DL_db_sub(
                                DRUG_NO:DRUG_NO,//編號
                                DRUG_SR:"${i+1}",
                                DETAIL:"${drug_reason.DRUG_DL_list[i].DETAIL}",
                                STORE:"${drug_reason.DRUG_DL_list[i].STORE}",
                                MODE:"${drug_reason.DRUG_DL_list[i].MODE}",
                                UNIT:"${drug_reason.DRUG_DL_list[i].UNIT}",
                                DOSAGE:"${drug_reason.DRUG_DL_list[i].DOSAGE}",
                                TIME1:"${drug_reason.DRUG_DL_list[i].TIME1}",//
                                TIME2:drug_reason.DRUG_DL_list[i].TIME2,//
                                TIME3:drug_reason.DRUG_DL_list[i].TIME3,//
                                DRUG_LINK:(drug_reason.DRUG_DL_list[i].prescriptionsbytes_xfile==null)?"":"~/School/Images/Drug/${DRUG_NO}_${i+1}_${microsecondsSinceEpoch}.jpg",//藥品照片
                                NOTE:"${drug_reason.DRUG_DL_list[i].NOTE}",//
                              );
                            }

                            //找出學生的老師
                            for(int i=0;i<cLASS_NO_for_teacher_chat.length;i++){
                              if(CUSTOMER_selectedValue.DEPM_NO==cLASS_NO_for_teacher_chat[i].DEPM_NO &&
                                  CUSTOMER_selectedValue.CLASS_NO==cLASS_NO_for_teacher_chat[i].CLASS_NO
                              ){
                                await sendPushNotification(
                                    title: "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.USER_NM} 家長",
                                    message: "新增一筆用藥委託",
                                    token: cLASS_NO_for_teacher_chat[i].FCM,
                                    ChatID:"用藥委託",
                                    CS_NO:CUSTOMER_selectedValue.CS_NO,
                                    DATE:"${DateFormat('yyyy-MM-dd').format(drug_reason.initialDates[iii])}",//日期
                                    UserAccount:'${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT.trim()}',
                                    TeacherAccount:"${cLASS_NO_for_teacher_chat[i].ACCOUNT}".trim()
                                );
                              }
                            }

                            //將用藥委託放入聊天室
                            await insert_MSDL2_db_sub(DRUG_NO:DRUG_NO);

                            await Future.delayed(const Duration(milliseconds: 1200), () {});


                          }

                           */

                                          //drug_reason = DRUG_REASON();







                                        }


                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );





                      },
                      child: Row(children: [
                        Expanded(child: Container()),
                        Text('送出', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                        Expanded(child: Container()),
                      ],),
                    )),

              ],)))),
          Container(height: 30.h,),




        ],),
    )));
  }
}
