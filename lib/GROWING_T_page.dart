import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:code3/main2_T.dart';
import 'package:code3/signature2.dart';
import 'package:code3/signature4.dart';
import 'package:code3/student_T.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:widget_zoom/widget_zoom.dart';
import 'dart:developer' as dev;
import 'api.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'package:badges/badges.dart' as badges;
import 'package:image_picker/image_picker.dart' as ImagePicker;

import 'utils/CustomAppBar.dart';

class GROWING_T_page extends StatefulWidget {

  String operation="新增";
  DateTime dateTime = DateTime.now();
  GROWING_T_page({String operation="新增",DateTime? dateTime}){
    this.operation = operation;
    this.dateTime = dateTime!;
  }

  @override
  State<GROWING_T_page> createState() => GROWING_T_pageState(operation:this.operation,dateTime:this.dateTime);
}

class GROWING_T_pageState extends State<GROWING_T_page> {

  DateTime page_notify_menu5_sel_datetime_1 = DateTime.now();
  var showModalBottomSheet_image_context;
  var showModalBottomSheet_image_setState;
  var showModalBottomSheet_GROWING_STANDARD_setState;
  var showModalBottomSheet_GROWING_STANDARD_context;

  String page = "";

  //DateTime? dateTime = DateTime.now();
  CLASS _class = CLASS();
  DEPM _depm = DEPM();

  List<GROWING> GROWING_list = [];
  List<GROWING_TYPE_ITEM> GROWING_TYPE_ITEM_list = [];
  GROWING_TYPE_ITEM sel_GROWING_TYPE_ITEM = GROWING_TYPE_ITEM();
  TextEditingController L_DATA_textEditingController = TextEditingController();//左眼
  TextEditingController R_DATA_textEditingController = TextEditingController();//右眼
  var prescriptionsbytes_xfile;
  File? file;

  TooltipBehavior? _tooltipBehavior;

  String operation="新增";
  GROWING_T_pageState({String operation="新增",DateTime? dateTime}){
    this.operation = operation;
    //this.dateTime = dateTime!;
    this.page_notify_menu5_sel_datetime_1 = dateTime!;
  }

  @override
  void initState() {
    // TODO: implement initState

    _tooltipBehavior = TooltipBehavior(enable: true);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    init();
  }


  init()async{
    await GROWING_TYPE_ITEM_db_sub();
    GROWING_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(page_notify_menu5_sel_datetime_1)}");
    setState(() {

    });
  }


  /*

   */
  Future<void>delete_GROWING_db_sub({String NO="",String TYPE=""})async{


    String comm = "DELETE FROM GROWING WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

  Future<void>delete_GROWING_DL_db_sub({String NO="",String TYPE=""})async{

    //SmartDialog.showLoading(msg: "處理中...");
    String comm = "DELETE FROM GROWING_DL WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

  Future<void>delete_GROWING_EYE_DL_db_sub({String NO="",String TYPE=""})async{

    //SmartDialog.showLoading(msg: "處理中...");
    String comm = "DELETE FROM GROWING_EYE_DL WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
  [托嬰/幼兒]成長紀錄
   */
  Future<void> GROWING_db_sub({String datetime=""})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    GROWING_list.clear();
    setState(() {

    });
    String result = await sql_command("""SELECT * FROM GROWING WHERE CS_NO = '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}' AND
        DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'
        AND
        CLASS_NO = '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CLASS_NO}'
        """);
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

        SmartDialog.showToast("無資料");

      }
      else{
        for(int i=0;i<data_list.length;i++){
          GROWING b = GROWING();
          b.TYPE = "${data_list[i]["TYPE"]}".contains("null")?"":"${data_list[i]["TYPE"]}";
          b.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
          b.DATE = "${data_list[i]["DATE"]}".contains("null")?"":"${data_list[i]["DATE"]}";
          b.DATE = DateFormat("yyyy-MM-dd").format(DateTime.parse((b.DATE.trim())));
          b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
          b.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}";
          b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}";
          b.USER_NO = "${data_list[i]["USER_NO"]}".contains("null")?"":"${data_list[i]["USER_NO"]}";
          GROWING_list.add(b);
        }

        for(int i=0;i<GROWING_list.length;i++){
          await GROWING_TYPE_ITEM_db_sub2(GROWING_list_index:i);
        }

      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }

  /*
   */
  Future<void> GROWING_TYPE_ITEM_db_sub({int GROWING_list_index=0})async{
    //await EasyLoading.show(status: "處理中...");
    GROWING_TYPE_ITEM_list.clear();
    setState(() {

    });
    String result = await sql_command("SELECT * FROM GROWING_TYPE_ITEM");
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
        for(int i=0;i<data_list.length;i++){
          GROWING_TYPE_ITEM b = GROWING_TYPE_ITEM();
          b.ITEM_NO = "${data_list[i]["ITEM_NO"]}";
          b.ITEM_NM = "${data_list[i]["ITEM_NM"]}";
          b.ITEM_ICON = "${GROWING_TYPE_ITEM_ICON["${b.ITEM_NO}"]}";
          b.ITEM_VALUE = "";
          b.ITEM_UNIT = "${GROWING_TYPE_ITEM_UNIT["${b.ITEM_NO}"]}";
          GROWING_TYPE_ITEM_list.add(b);
        }
      }


      if(operation=="新增"){
        /*
        老師帳號>每日可以新增/編輯如下
        身高/體重/頭圍/視力/塗氟/潔牙衛教/口腔檢查
         */

      }

      sel_GROWING_TYPE_ITEM = GROWING_TYPE_ITEM_list[0];

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }

  Future<void> GROWING_TYPE_ITEM_db_sub2({int GROWING_list_index=0})async{
    //await EasyLoading.show(status: "處理中...");
    GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list.clear();
    setState(() {

    });
    String result = await sql_command("SELECT * FROM GROWING_TYPE_ITEM");
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
        for(int i=0;i<data_list.length;i++){
          GROWING_TYPE_ITEM b = GROWING_TYPE_ITEM();
          b.ITEM_NO = "${data_list[i]["ITEM_NO"]}".contains("null")?"":"${data_list[i]["ITEM_NO"]}";
          b.ITEM_NM = "${data_list[i]["ITEM_NM"]}".contains("null")?"":"${data_list[i]["ITEM_NM"]}";
          b.ITEM_ICON = "${GROWING_TYPE_ITEM_ICON["${b.ITEM_NO}"]}".contains("null")?"":"${GROWING_TYPE_ITEM_ICON["${b.ITEM_NO}"]}";
          b.ITEM_VALUE = "";
          b.ITEM_UNIT = "${GROWING_TYPE_ITEM_UNIT["${b.ITEM_NO}"]}".contains("null")?"":"${GROWING_TYPE_ITEM_UNIT["${b.ITEM_NO}"]}";
          GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list.add(b);
        }

        for(int i=0;i<GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list.length;i++){

          if(GROWING_list[GROWING_list_index].TYPE==GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[i].ITEM_NO) {
            await GROWING_DL_db_sub(GROWING_list_index: GROWING_list_index,
                GROWING_TYPE_ITEM_list_index: i);
            if (GROWING_list[GROWING_list_index].is_value == true) {
              break;
            }

            await GROWING_EYE_DL_db_sub(
                GROWING_list_index: GROWING_list_index,
                GROWING_TYPE_ITEM_list_index: i);
            if (GROWING_list[GROWING_list_index].is_value == true) {
              break;
            }
          }

          /*
            String ITEM_NO = "";
            for(int j=0;j<GROWING_list.length;j++){
              for(int k=0;k<GROWING_list[j].GROWING_TYPE_ITEM_list.length;k++){
                dev.log("${GROWING_list[j].GROWING_TYPE_ITEM_list[k].ITEM_NO},${GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[i].ITEM_NO},GROWING_list[j].GROWING_TYPE_ITEM_list[k].is_value:${GROWING_list[j].GROWING_TYPE_ITEM_list[k].is_value}");
                if(GROWING_list[j].GROWING_TYPE_ITEM_list[k].is_value==true && GROWING_list[j].GROWING_TYPE_ITEM_list[k].ITEM_NO==GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[i].ITEM_NO){
                  ITEM_NO = GROWING_list[j].GROWING_TYPE_ITEM_list[k].ITEM_NO;
                }
              }
            }
            if(ITEM_NO!=GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[i].ITEM_NO){
              await GROWING_DL_db_sub(GROWING_list_index:GROWING_list_index,GROWING_TYPE_ITEM_list_index:i);
              if(GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[i].is_value==true){
                break;
              }

              await GROWING_EYE_DL_db_sub(GROWING_list_index:GROWING_list_index,GROWING_TYPE_ITEM_list_index:i);
              if(GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[i].is_value==true){
                break;
              }
            }

             */


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
  [托嬰/幼兒]成長紀錄 子表單 GROWING_DL
   */
  Future<void> GROWING_DL_db_sub({int GROWING_list_index=0,int GROWING_TYPE_ITEM_list_index=0})async{
    //await EasyLoading.show(status: "處理中...");
    String result = await sql_command("SELECT * FROM GROWING_DL WHERE TYPE='${GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].ITEM_NO}' AND NO='${GROWING_list[GROWING_list_index].NO}'");
    //String result = await sql_command("SELECT * FROM GROWING_DL WHERE TYPE='${GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].ITEM_NO}' AND NO='${GROWING_list[GROWING_list_index].NO}'");
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


        GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].ITEM_VALUE = "${data_list[0]["DATA"]}".contains("null")?"":"${data_list[0]["DATA"]}";
        String RECORD_LINK = ("${data_list[0]["RECORD_LINK"]}".contains("null") || "${data_list[0]["RECORD_LINK"]}"=="")?"":"${data_list[0]["RECORD_LINK"]}".replaceAll("~/", "");
        if(RECORD_LINK.isNotEmpty) {
          RECORD_LINK = "${IMAGE_IP}/${RECORD_LINK}";
        }
        GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].ITEM_RECORD_LINK=RECORD_LINK;
        GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].is_value=true;
        GROWING_list[GROWING_list_index].is_value=true;
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
  [托嬰/幼兒]成長紀錄 視力 子表單 GROWING_EYE_DL
   */
  Future<void> GROWING_EYE_DL_db_sub({int GROWING_list_index=0,int GROWING_TYPE_ITEM_list_index=0})async{
    //await EasyLoading.show(status: "處理中...");
    String result = await sql_command("SELECT * FROM GROWING_EYE_DL WHERE TYPE='${GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].ITEM_NO}' AND NO='${GROWING_list[GROWING_list_index].NO}'");
    //String result = await sql_command("SELECT * FROM GROWING_DL WHERE TYPE='${GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].ITEM_NO}' AND NO='${GROWING_list[GROWING_list_index].NO}'");
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

        GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].ITEM_VALUE="${data_list[0]["L_DATA"].toString().contains("null")?"":data_list[0]["L_DATA"]}-${data_list[0]["R_DATA"].toString().contains("null")?"":data_list[0]["R_DATA"]}";
        String RECORD_LINK = ("${data_list[0]["RECORD_LINK"]}".contains("null") || "${data_list[0]["RECORD_LINK"]}"=="")?"":"${data_list[0]["RECORD_LINK"]}".replaceAll("~/", "");
        if(RECORD_LINK.isNotEmpty) {
          RECORD_LINK = "${IMAGE_IP}/${RECORD_LINK}";
        }
        GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].ITEM_RECORD_LINK=RECORD_LINK;
        GROWING_list[GROWING_list_index].GROWING_TYPE_ITEM_list[GROWING_TYPE_ITEM_list_index].is_value=true;
        GROWING_list[GROWING_list_index].is_value=true;

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
  [托嬰/幼兒]成長紀錄
   */
  Future<int> read_GROWING_db_sub({String TYPE=""})async{

    int GROWING_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(page_notify_menu5_sel_datetime_1!)}";
    String comm = "SELECT * FROM GROWING WHERE DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59' AND TYPE='${TYPE}'";
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
        String GROWING_NO = "${data_list[data_list.length-1]["NO"]}";
        dev.log("GROWING_NO:${GROWING_NO}");
        //找出流水號
        GROWING_NO_num = int.parse("${GROWING_NO.substring(GROWING_NO.length-6,GROWING_NO.length)}");
        dev.log("GROWING_NO_num:${GROWING_NO_num}");
      }
      setState(() {

      });

    }
    catch(e){
      GROWING_NO_num=-1;
      dev.log("${e}");
    }

    return GROWING_NO_num;

  }


  /*
  [托嬰/幼兒] GROWING
   */
  Future<bool> insert_GROWING_db_sub(
      {
        String TYPE="",//種類
        String NO="",//編號
        String DATE="",//日期
        String DEPM_NO="",//學校
        String CLASS_NO="",//班級
        String CS_NO="",//學生
        String USER_NO="",//建立者
      })async{

    String comm = "INSERT INTO GROWING(TYPE,NO,DATE,DEPM_NO,CLASS_NO,CS_NO,USER_NO) VALUES ('${TYPE}','${NO}','${DATE}','${DEPM_NO}','${CLASS_NO}','${CS_NO}','${USER_NO}')";
    dev.log("${comm}");
    String result = await sql_command("${comm}");
    dev.log("result:${result}");
    try{
      Map<String,dynamic> map = jsonDecode(result);
      if("${map["message"]}".contains("執行成功")){
        setState(() {

        });
        return true;
      }
      else{
        setState(() {

        });
        return false;
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

      }

       */

    }
    catch(e){
      dev.log("${e}");
      return false;
    }
  }

  /*
  [托嬰/幼兒] GROWING_EYE_DL
   */
  Future<bool> insert_GROWING_EYE_DL_db_sub(
      {
        String TYPE="",//種類
        String NO="",//編號
        String L_DATA="",//數據1
        String R_DATA="",//數據2
        String RECORD_LINK="",//檢查記錄表
      })async{

    String comm = "INSERT INTO GROWING_EYE_DL(TYPE,NO,L_DATA,R_DATA,RECORD_LINK) VALUES ('${TYPE}','${NO}','${L_DATA}','${R_DATA}','${RECORD_LINK}')";
    dev.log("${comm}");
    String result = await sql_command("${comm}");
    dev.log("result:${result}");
    try{

      Map<String,dynamic> map = jsonDecode(result);
      if("${map["message"]}".contains("執行成功")){
        setState(() {

        });
        return true;
      }
      else{
        setState(() {

        });
        return false;
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

      }
      setState(() {

      });
      return true;

       */


    }
    catch(e){
      dev.log("${e}");
      return false;
    }
  }

  /*
  [托嬰/幼兒] GROWING_DL
   */
  Future<bool> insert_GROWING_DL_db_sub(
      {
        String TYPE="",//種類
        String NO="",//編號
        String DATA="",//數據
        String RECORD_LINK="",//檢查記錄表
      })async{

    String comm = "INSERT INTO GROWING_DL(TYPE,NO,DATA,RECORD_LINK) VALUES ('${TYPE}','${NO}','${DATA}','${RECORD_LINK}')";
    if(DATA.isEmpty){
      comm = "INSERT INTO GROWING_DL(TYPE,NO,RECORD_LINK) VALUES ('${TYPE}','${NO}','${RECORD_LINK}')";
    }
    dev.log("${comm}");
    String result = await sql_command("${comm}");
    dev.log("result:${result}");
    try{

      Map<String,dynamic> map = jsonDecode(result);
      if("${map["message"]}".contains("執行成功")){
        setState(() {

        });
        return true;
      }
      else{
        setState(() {

        });
        return false;
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

      }
      setState(() {

      });
      return true;

       */


    }
    catch(e){
      dev.log("${e}");
      return false;
    }
  }



  /*
  成長曲線基準
   */
  Future<void> resd_GROWING_STANDARD_db_sub({String ITEM_NO=""})async{

    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    sel_GROWING_STANDARD_TYPE = GROWING_STANDARD_TYPE[0];
    for(int i=0;i<GROWING_STANDARD_TYPE.length;i++){
      if(GROWING_STANDARD_TYPE[i].contains(ITEM_NO)){
        sel_GROWING_STANDARD_TYPE = GROWING_STANDARD_TYPE[i];
      }
    }

    showModalBottomSheet_GROWING_STANDARD_setState(() {

    });

    GROWING_STANDARDs.clear();
    String comm = "SELECT * FROM GROWING_STANDARD";
    String result = await sql_command(comm);
    SmartDialog.dismiss();
    try{
      List<dynamic> list = jsonDecode(result);
      dev.log("list.length:${list[0]}");
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

        dev.log("ITEM_NO:${ITEM_NO}");

        for(int i=0;i<data_list.length;i++){
          GROWING_STANDARD g = GROWING_STANDARD();
          g.TYPE = "${data_list[i]["TYPE"]}".contains("null")?"":"${data_list[i]["TYPE"]}".replaceAll(" ", "");
          g.SEX = "${data_list[i]["SEX"]}".contains("null")?"":"${data_list[i]["SEX"]}".replaceAll(" ", "");
          g.MONTH = "${data_list[i]["MONTH"]}".contains("null")?"":"${data_list[i]["MONTH"]}".replaceAll(" ", "");
          g.DATA_3 = "${data_list[i]["DATA_3"]}".contains("null")?"":"${data_list[i]["DATA_3"]}".replaceAll(" ", "");
          g.DATA_15 = "${data_list[i]["DATA_15"]}".contains("null")?"":"${data_list[i]["DATA_15"]}".replaceAll(" ", "");
          g.DATA_50 = "${data_list[i]["DATA_50"]}".contains("null")?"":"${data_list[i]["DATA_50"]}".replaceAll(" ", "");
          g.DATA_85 = "${data_list[i]["DATA_85"]}".contains("null")?"":"${data_list[i]["DATA_85"]}".replaceAll(" ", "");
          g.DATA_97 = "${data_list[i]["DATA_97"]}".contains("null")?"":"${data_list[i]["DATA_97"]}".replaceAll(" ", "");
          GROWING_STANDARDs.add(g);
        }

        Male_salesDatas_3.clear();
        Male_salesDatas_15.clear();
        Male_salesDatas_50.clear();
        Male_salesDatas_85.clear();
        Male_salesDatas_97.clear();
        Female_salesDatas_3.clear();
        Female_salesDatas_15.clear();
        Female_salesDatas_50.clear();
        Female_salesDatas_85.clear();
        Female_salesDatas_97.clear();



        for(int i=0;i<GROWING_STANDARDs.length;i++){
          if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="M"){
            Male_salesDatas_3.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_3)));
            Male_salesDatas_15.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_15)));
            Male_salesDatas_50.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_50)));
            Male_salesDatas_85.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_85)));
            Male_salesDatas_97.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_97)));
          }
          if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="F"){
            Female_salesDatas_3.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_3)));
            Female_salesDatas_15.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_15)));
            Female_salesDatas_50.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_50)));
            Female_salesDatas_85.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_85)));
            Female_salesDatas_97.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_97)));
          }
        }

        Male_salesDatas_3.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Male_salesDatas_15.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Male_salesDatas_50.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Male_salesDatas_85.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Male_salesDatas_97.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));

        Female_salesDatas_3.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Female_salesDatas_15.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Female_salesDatas_50.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Female_salesDatas_85.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Female_salesDatas_97.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        showModalBottomSheet_GROWING_STANDARD_setState(() {

        });

        dev.log("test-1");
        this.showModalBottomSheet_GROWING_STANDARD_setState((){});
        dev.log("test-2");
        setState(() {

        });

      }

    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }


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
          backgroundColor: Color(0xffF4F4F4),
          appBar: CustomAppBar(

            backgroundColor: Color(0xffF9AA88),
            toolbarHeight:42.h,
            leading: GestureDetector(
                onTap: (){

                  if(page==""){
                    Navigator.pop(context);
                  }
                  else{
                    page="";
                    setState(() {

                    });
                  }


                },
                child:Icon(Icons.arrow_back,size: 30.w,)),
            centerTitle: false,
            actions: [

            ],
            title: Text("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NM.replaceAll(" ", "")}(健康紀錄)", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),

          ),
          body: Container(
              padding: EdgeInsets.only(left:5.w,right: 5.w),
              width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
            child: (page=="")?Column(children: [

              Container(height: 10.h,),
              GestureDetector(
                  onTap: ()async{

                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        currentTime:page_notify_menu5_sel_datetime_1,
                        minTime: DateTime.now().subtract(Duration(days: 365)),
                        maxTime: DateTime.now(), onChanged: (date) {
                          print('change $date');
                        }, onConfirm: (date) {

                          page_notify_menu5_sel_datetime_1=date;
                          print('confirm $date');
                          GROWING_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(page_notify_menu5_sel_datetime_1)}");

                        },locale: LocaleType.tw);


                  },
                  child: Column(children: [
                    Container(
                        width: ScreenUtil().screenWidth,
                        height: 50.w,
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20.w),
                            border: Border.all(
                              width: 1,
                              color: Color(0xff555555),
                            )),
                        child:Row(children: [
                          Container(width: 5.w,),
                          Icon(Icons.calendar_today,color: Color(0xff555555),size: 28.sp,),
                          Container(width: 5.w,),
                          Text("${DateFormat('yyyy-MM-dd').format(page_notify_menu5_sel_datetime_1)}",style: TextStyle(
                              fontFamily: "GenJyuuGothic",
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: Color(0xff292929))),
                          Expanded(child: Container()),
                          Icon(Icons.keyboard_arrow_down,color: Color(0xff555555),size: 24.sp,),
                          Container(width: 5.w,),

                        ],)
                    ),

                  ],)),
              Container(height: 5.h,),
              Expanded(child:Container(width:ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
              child: Stack(children: [

                ListView.builder(
                    padding: EdgeInsets.all(5.w),
                    itemCount: GROWING_list.length,
                    itemBuilder:(c,index){

                      bool check = false;
                      for(int i=0;i<GROWING_list[index].GROWING_TYPE_ITEM_list.length;i++){
                         if(("${GROWING_list[index].GROWING_TYPE_ITEM_list[i].ITEM_NO}".contains("K5")||"${GROWING_list[index].GROWING_TYPE_ITEM_list[i].ITEM_NO}".contains("K6")||"${GROWING_list[index].GROWING_TYPE_ITEM_list[i].ITEM_NO}".contains("K7"))
                             &&(GROWING_list[index].GROWING_TYPE_ITEM_list[i].ITEM_RECORD_LINK.isNotEmpty)){
                           check = true;
                           break;
                         }
                         else if(("${GROWING_list[index].GROWING_TYPE_ITEM_list[i].ITEM_NO}".contains("K1")||"${GROWING_list[index].GROWING_TYPE_ITEM_list[i].ITEM_NO}".contains("K2")||"${GROWING_list[index].GROWING_TYPE_ITEM_list[i].ITEM_NO}".contains("K3")||"${GROWING_list[index].GROWING_TYPE_ITEM_list[i].ITEM_NO}".contains("K4"))
                             &&(GROWING_list[index].GROWING_TYPE_ITEM_list[i].ITEM_VALUE.isNotEmpty)){
                           check = true;
                           break;
                         }
                      }

                      return (check==false)?Container():Column(children: [
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
                                                            FocusManager.instance.primaryFocus?.unfocus();
                                                            SmartDialog.showLoading(msg: '處理中...');
                                                            await delete_GROWING_db_sub(NO:GROWING_list[index].NO,TYPE:GROWING_list[index].TYPE);
                                                            await delete_GROWING_DL_db_sub(NO:GROWING_list[index].NO,TYPE:GROWING_list[index].TYPE);
                                                            await delete_GROWING_EYE_DL_db_sub(NO:GROWING_list[index].NO,TYPE:GROWING_list[index].TYPE);
                                                            SmartDialog.dismiss();
                                                            await GROWING_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(page_notify_menu5_sel_datetime_1)}");
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
                                      Icon(Icons.delete_forever_outlined,size: 24.sp,),
                                      Text('刪除',textScaler: TextScaler.linear(1), style: TextStyle(fontSize: 18.sp)),
                                    ],
                                  ),
                                ),
                                /*
                                SlidableAction(
                                  borderRadius:BorderRadius.circular(5.w),
                                  spacing:6.h,
                                  onPressed: (c){

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
                                                            EasyLoading.show(status: '處理中...');
                                                            await delete_GROWING_db_sub(NO:GROWING_list[index].NO,TYPE:GROWING_list[index].TYPE);
                                                            await delete_GROWING_DL_db_sub(NO:GROWING_list[index].NO,TYPE:GROWING_list[index].TYPE);
                                                            await delete_GROWING_EYE_DL_db_sub(NO:GROWING_list[index].NO,TYPE:GROWING_list[index].TYPE);
                                                            EasyLoading.dismiss();
                                                            await GROWING_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(page_notify_menu5_sel_datetime_1)}");
                                                            setState(() {

                                                            });
                                                          },
                                                        ),

                                                      ],
                                                    );
                                                  }));
                                        });

                                  },
                                  backgroundColor: Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                  label: '刪除',
                                ),

                                 */
                              ],
                            ),

                            // The child of the Slidable is what the user sees when the
                            // component is not dragged.
                            child:Column(children: [
                              Container(
                                  margin: EdgeInsets.only(bottom: 0.h),
                                  width: ScreenUtil().screenWidth,
                                  //height: 55.h,
                                  padding: EdgeInsets.all(10.w),
                                  decoration: BoxDecoration(
                                      color: Color(0xfffbf7f3),
                                      borderRadius: BorderRadius.circular(5.w),
                                      border: Border.all(
                                        width: 1,
                                        color: Color(0xff555555),
                                      )),
                                  child:Column(children: [


                                    Container(
                                        padding: EdgeInsets.only(left:5.w,right: 5.w),
                                        width: ScreenUtil().screenWidth,
                                        child:Column(children: [

                                          /*
                                        Container(
                                            width: ScreenUtil().screenWidth,child:
                                        Text('${user.DEPM_NM}-${user.CLASS_NM}-${user.KIDS_NM}',softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18.sp,
                                            color: Color(0xff555555)))),

                                         */

                                          /*
                                      Container(
                                          width: ScreenUtil().screenWidth,child:
                                      Text("體溫測量時間 13:25",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                          fontFamily: "GenJyuuGothic",
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.sp,
                                          color: Color(0xff7D7D7D)))),

                                       */
                                          //Container(height: 15.h,),

                                          Column(children: GROWING_list[index].GROWING_TYPE_ITEM_list.map((e) {

                                            dev.log(">${e.ITEM_NO},${e.ITEM_VALUE},${e.ITEM_RECORD_LINK}");

                                            return Column(children: [

                                              Container(width: ScreenUtil().screenWidth,
                                                child:("${e.ITEM_NO}".contains("K4"))?
                                                (e.ITEM_VALUE.isEmpty)?Container():Row(children: [

                                                  Expanded(flex:3,child:Row(children: [
                                                    Container(width: 32.w,height: 32.w,decoration: BoxDecoration(
                                                        color: Color(0xffEEE9E0),
                                                        borderRadius: BorderRadius.circular(10.w),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: Color(0xffEEE9E0),
                                                        )),
                                                        child: Center(child: SvgPicture.asset("${e.ITEM_ICON.split("-")[0]}",width: 22.w,height: 22.w,),)
                                                    ),
                                                    Container(width: 10.w,),
                                                    Text("${e.ITEM_NM}",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.sp,
                                                        color: Color(0xff555555))),
                                                    Container(width: 10.w,),
                                                    Text("${e.ITEM_VALUE}".isEmpty?"":"${e.ITEM_VALUE}".split("-")[0],softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.sp,
                                                        color: Color(0xffE8885E))),
                                                    Container(width: 10.w,),
                                                    Container(width: 32.w,height: 32.w,decoration: BoxDecoration(
                                                        color: Color(0xffEEE9E0),
                                                        borderRadius: BorderRadius.circular(10.w),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: Color(0xffEEE9E0),
                                                        )),
                                                        child: Center(child: SvgPicture.asset("${e.ITEM_ICON.split("-")[1]}",width: 22.w,height: 22.w,),)
                                                    ),
                                                    Container(width: 10.w,),
                                                    Text("${e.ITEM_NM}",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.sp,
                                                        color: Color(0xff555555))),
                                                    Container(width: 10.w,),
                                                    Text("${e.ITEM_VALUE}".isEmpty?"":"${e.ITEM_VALUE}".split("-")[1],softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.sp,
                                                        color: Color(0xffE8885E))),
                                                    Container(width: 10.w,),

                                                  ],)),

                                                  e.ITEM_RECORD_LINK.isEmpty?
                                                  Container()
                                                      :
                                                  Expanded(child: Container(child:Row(children: [
                                                    Expanded(child: Container()),
                                                    GestureDetector(
                                                        onTap:()async{

                                                          showModalBottomSheet(
                                                              backgroundColor: Colors.white,
                                                              isScrollControlled:true,
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                showModalBottomSheet_image_context = context;
                                                                return StatefulBuilder(
                                                                    builder: (BuildContext context, showModalBottomSheet_image_setState){

                                                                      this.showModalBottomSheet_image_setState =
                                                                          showModalBottomSheet_image_setState;
                                                                      return Column(children: [

                                                                        Container(height: 50.h,),
                                                                        Row(children: [
                                                                          Expanded(child: Container()),
                                                                          GestureDetector(
                                                                              onTap:(){
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Icon(Icons.cancel_outlined,size: 30.sp,color: Colors.black,)),
                                                                          Container(width: 20.w,),
                                                                        ],),
                                                                        Container(height: 20.h,),
                                                                        Text("點一下圖片可縮放",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                                            fontFamily: "GenJyuuGothic",
                                                                            fontWeight: FontWeight.normal,
                                                                            fontSize: 20.sp,
                                                                            color: Colors.lightBlue)),
                                                                        Expanded(child: Container(child: WidgetZoom(
                                                                            heroAnimationTag: '${e.ITEM_RECORD_LINK}',
                                                                            zoomWidget: Image.network("${e.ITEM_RECORD_LINK}",
                                                                              errorBuilder: (BuildContext context, Object exception,
                                                                                  StackTrace? stackTrace) {
                                                                                return  Icon(Icons.error,size: 30.sp,);
                                                                              },
                                                                            )))),


                                                                      ],);
                                                                    });

                                                              });

                                                        },
                                                        child: IntrinsicWidth(
                                                          child: Column(
                                                            children: [
                                                              Text("檢查記錄表",style: TextStyle(
                                                                  fontFamily: "GenJyuuGothic",
                                                                  fontWeight: FontWeight.normal,
                                                                  fontSize: 14.sp,
                                                                  //decoration: TextDecoration.underline,
                                                                  color: Colors.lightBlue)),
                                                              Container(height: 1, color: Colors.lightBlue),
                                                            ],
                                                          ),
                                                        )),
                                                    Expanded(child: Container()),
                                                  ],),)),
                                                ],)
                                                    :
                                                (e.ITEM_NO=="K5" || e.ITEM_NO=="K6" || e.ITEM_NO=="K7")?
                                                (e.ITEM_RECORD_LINK.isEmpty)?Container():Row(children: [

                                                  Expanded(flex:3,child:
                                                  Row(children: [
                                                    Container(width: 32.w,height: 32.w,decoration: BoxDecoration(
                                                        color: Color(0xffEEE9E0),
                                                        borderRadius: BorderRadius.circular(10.w),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: Color(0xffEEE9E0),
                                                        )),
                                                        child: Center(child: SvgPicture.asset("${e.ITEM_ICON}",width: 22.w,height: 22.w,),)
                                                    ),
                                                    Container(width: 10.w,),
                                                    Text("${e.ITEM_NM}",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.sp,
                                                        color: Color(0xff555555))),
                                                    Container(width: 10.w,),
                                                    Text("${e.ITEM_VALUE}",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.sp,
                                                        color: Color(0xffE8885E))),
                                                    Container(width: 10.w,),
                                                    Column(children: [
                                                      Container(height: 5.h,),
                                                      Text("${e.ITEM_UNIT}",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                          fontFamily: "GenJyuuGothic",
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 13.sp,
                                                          color: Color(0xff555555))),
                                                    ],),
                                                  ],)),

                                                  e.ITEM_RECORD_LINK.isEmpty?
                                                  Container()
                                                      :
                                                  Expanded(child: Container(child:Row(children: [
                                                    Expanded(child: Container()),
                                                    GestureDetector(
                                                        onTap:()async{


                                                          showModalBottomSheet(
                                                              backgroundColor: Colors.white,
                                                              isScrollControlled:true,
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                showModalBottomSheet_image_context = context;
                                                                return StatefulBuilder(
                                                                    builder: (BuildContext context, showModalBottomSheet_image_setState){

                                                                      this.showModalBottomSheet_image_setState =
                                                                          showModalBottomSheet_image_setState;
                                                                      return Column(children: [

                                                                        Container(height: 50.h,),
                                                                        Row(children: [
                                                                          Expanded(child: Container()),
                                                                          GestureDetector(
                                                                              onTap:(){
                                                                                Navigator.pop(context);
                                                                              },
                                                                              child: Icon(Icons.cancel_outlined,size: 30.sp,color: Colors.black,)),
                                                                          Container(width: 20.w,),
                                                                        ],),
                                                                        Container(height: 20.h,),
                                                                        Text("點一下圖片可縮放",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                                            fontFamily: "GenJyuuGothic",
                                                                            fontWeight: FontWeight.normal,
                                                                            fontSize: 20.sp,
                                                                            color: Colors.lightBlue)),
                                                                        Expanded(child: Container(child: WidgetZoom(
                                                                            heroAnimationTag: '${e.ITEM_RECORD_LINK}',
                                                                            zoomWidget: Image.network("${e.ITEM_RECORD_LINK}",
                                                                              errorBuilder: (BuildContext context, Object exception,
                                                                                  StackTrace? stackTrace) {
                                                                                return  Icon(Icons.error,size: 30.sp,);
                                                                              },
                                                                            )))),


                                                                      ],);
                                                                    });

                                                              });



                                                        },
                                                        child: IntrinsicWidth(
                                                          child: Column(
                                                            children: [
                                                              Text("檢查記錄表",style: TextStyle(
                                                                  fontFamily: "GenJyuuGothic",
                                                                  fontWeight: FontWeight.normal,
                                                                  fontSize: 14.sp,
                                                                  //decoration: TextDecoration.underline,
                                                                  color: Colors.lightBlue)),
                                                              Container(height: 1, color: Colors.lightBlue),
                                                            ],
                                                          ),
                                                        )),
                                                    Expanded(child: Container()),
                                                  ],),)),

                                                ],)
                                                    :
                                                (e.ITEM_VALUE.isEmpty)?Container():Row(children: [

                                                  Expanded(flex:3,child:
                                                  Row(children: [
                                                    Container(width: 32.w,height: 32.w,decoration: BoxDecoration(
                                                        color: Color(0xffEEE9E0),
                                                        borderRadius: BorderRadius.circular(10.w),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: Color(0xffEEE9E0),
                                                        )),
                                                        child: Center(child: SvgPicture.asset("${e.ITEM_ICON}",width: 22.w,height: 22.w,),)
                                                    ),
                                                    Container(width: 10.w,),
                                                    Text("${e.ITEM_NM}",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.sp,
                                                        color: Color(0xff555555))),
                                                    Container(width: 10.w,),
                                                    Text("${e.ITEM_VALUE}",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16.sp,
                                                        color: Color(0xffE8885E))),
                                                    Container(width: 10.w,),
                                                    Column(children: [
                                                      Container(height: 5.h,),
                                                      Text("${e.ITEM_UNIT}",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                          fontFamily: "GenJyuuGothic",
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 13.sp,
                                                          color: Color(0xff555555))),
                                                    ],),
                                                  ],)),

                                                  Expanded(child: Container(child:Row(children: [
                                                    Expanded(child: Container()),
                                                    Column(children: [

                                                      "${e.ITEM_NO}".contains("K1") || "${e.ITEM_NO}".contains("K2") || "${e.ITEM_NO}".contains("K3")?
                                                      Column(children: [
                                                        GestureDetector(
                                                            onTap:()async{



                                                              showModalBottomSheet(
                                                                  backgroundColor: Colors.white,
                                                                  isScrollControlled:true,
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    showModalBottomSheet_GROWING_STANDARD_context = context;
                                                                    return StatefulBuilder(
                                                                        builder: (BuildContext context, showModalBottomSheet_image_setState){
                                                                          this.showModalBottomSheet_GROWING_STANDARD_setState =
                                                                              showModalBottomSheet_image_setState;
                                                                          return Column(children: [

                                                                            Container(height: 45.h,),
                                                                            Row(children: [
                                                                              Expanded(child: Container()),
                                                                              GestureDetector(
                                                                                  onTap:(){
                                                                                    Navigator.pop(showModalBottomSheet_GROWING_STANDARD_context);
                                                                                  },
                                                                                  child: Icon(Icons.cancel_outlined,size: 30.sp,color: Colors.black,)),
                                                                              Container(width: 20.w,),
                                                                            ],),
                                                                            Container(height: 10.h,),
                                                                            Text("衛服部幼兒發展數據",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                                                fontFamily: "GenJyuuGothic",
                                                                                fontWeight: FontWeight.normal,
                                                                                fontSize: 20.sp,
                                                                                color: Colors.lightBlue)),
                                                                            Container(height: 10.h,),
                                                                            Expanded(child: Container(child: Column(children: [

                                                                              Text("${sel_GROWING_STANDARD_TYPE.split("-").last}",style: TextStyle(
                                                                                fontSize: 18.sp,
                                                                                fontWeight: FontWeight.bold,
                                                                                color: const Color(0xff555555),
                                                                              ),),
                                                                              /*
                                                                                      Container(
                                                                                          decoration: BoxDecoration(
                                                                                            border: Border.all(color: Colors.grey),
                                                                                            borderRadius: BorderRadius.circular(5.w),
                                                                                          ),
                                                                                          //width: 80.w,
                                                                                          height: 36.h,
                                                                                          child: DropdownButtonHideUnderline(
                                                                                            child: DropdownButton2<String>(
                                                                                              isExpanded: true,
                                                                                              items: GROWING_STANDARD_TYPE
                                                                                                  .map((String item) => DropdownMenuItem<String>(
                                                                                                value: item,
                                                                                                child: Text(
                                                                                                  item.split("-").last,
                                                                                                  style: TextStyle(
                                                                                                    fontSize: 18.sp,
                                                                                                    fontWeight: FontWeight.bold,
                                                                                                    color: const Color(0xff555555),
                                                                                                  ),
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                ),
                                                                                              ))
                                                                                                  .toList(),
                                                                                              value: sel_GROWING_STANDARD_TYPE,
                                                                                              onChanged: (value) {

                                                                                                /*
                                                                                                Male_salesDatas_h.clear();
                                                                                                Female_salesDatas_h.clear();
                                                                                                Male_salesDatas_l.clear();
                                                                                                Female_salesDatas_l.clear();
                                                                                                sel_GROWING_STANDARD_TYPE = value!;

                                                                                                for(int i=0;i<GROWING_STANDARDs.length;i++){
                                                                                                  if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="M"){
                                                                                                    Male_salesDatas_h.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_H)));
                                                                                                    Male_salesDatas_l.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_L)));
                                                                                                  }
                                                                                                  if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="F"){
                                                                                                    Female_salesDatas_h.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_H)));
                                                                                                    Female_salesDatas_l.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_L)));
                                                                                                  }
                                                                                                }

                                                                                                Male_salesDatas_h.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                                                                Male_salesDatas_l.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                                                                Female_salesDatas_h.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                                                                Female_salesDatas_l.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                                                                showModalBottomSheet_GROWING_STANDARD_setState(() {

                                                                                                });

                                                                                                 */

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

                                                                                       */

                                                                              (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.SEX=="M")?
                                                                              Expanded(child: SfCartesianChart(

                                                                                  primaryXAxis: CategoryAxis(
                                                                                      title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                                                                  ),
                                                                                  primaryYAxis: CategoryAxis(
                                                                                      title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                                                                  ),
                                                                                  // Chart title
                                                                                  title: ChartTitle(text: '男生',textStyle: TextStyle(fontSize: 20.sp)),
                                                                                  // Enable legend
                                                                                  legend: Legend(isVisible: true),
                                                                                  // Enable tooltip
                                                                                  tooltipBehavior: _tooltipBehavior,

                                                                                  series: <LineSeries<SalesData, String>>[
                                                                                    LineSeries<SalesData, String>(
                                                                                      dataSource:  Male_salesDatas_3.toList(),
                                                                                      xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                                                      yValueMapper: (SalesData sales, _) => sales.DATA,
                                                                                      // Enable data label
                                                                                      dataLabelSettings: DataLabelSettings(isVisible: true),
                                                                                      //xAxisName: "月齡",
                                                                                      //yAxisName: "數據",
                                                                                      name: "3%",
                                                                                    ),
                                                                                    LineSeries<SalesData, String>(
                                                                                      dataSource:  Male_salesDatas_15.toList(),
                                                                                      xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                                                      yValueMapper: (SalesData sales, _) => sales.DATA,
                                                                                      // Enable data label
                                                                                      dataLabelSettings: DataLabelSettings(isVisible: true),
                                                                                      name: "15%",
                                                                                    ),
                                                                                    LineSeries<SalesData, String>(
                                                                                      dataSource:  Male_salesDatas_50.toList(),
                                                                                      xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                                                      yValueMapper: (SalesData sales, _) => sales.DATA,
                                                                                      // Enable data label
                                                                                      dataLabelSettings: DataLabelSettings(isVisible: true),
                                                                                      name: "50%",
                                                                                    ),
                                                                                    LineSeries<SalesData, String>(
                                                                                      dataSource:  Male_salesDatas_85.toList(),
                                                                                      xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                                                      yValueMapper: (SalesData sales, _) => sales.DATA,
                                                                                      // Enable data label
                                                                                      dataLabelSettings: DataLabelSettings(isVisible: true),
                                                                                      name: "85%",
                                                                                    ),
                                                                                    LineSeries<SalesData, String>(
                                                                                      dataSource:  Male_salesDatas_97.toList(),
                                                                                      xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                                                      yValueMapper: (SalesData sales, _) => sales.DATA,
                                                                                      // Enable data label
                                                                                      dataLabelSettings: DataLabelSettings(isVisible: true),
                                                                                      name: "97%",
                                                                                    ),
                                                                                  ]
                                                                              )):
                                                                              //Container(height: 20.h,),
                                                                              Expanded(child: SfCartesianChart(


                                                                                  primaryXAxis: CategoryAxis(
                                                                                      title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                                                                  ),
                                                                                  primaryYAxis: CategoryAxis(
                                                                                      title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                                                                  ),
                                                                                  // Chart title
                                                                                  title: ChartTitle(text: '女生',textStyle: TextStyle(fontSize: 20.sp)),
                                                                                  // Enable legend
                                                                                  legend: Legend(isVisible: true),
                                                                                  // Enable tooltip
                                                                                  tooltipBehavior: _tooltipBehavior,

                                                                                  series: <LineSeries<SalesData, String>>[
                                                                                    LineSeries<SalesData, String>(
                                                                                      dataSource:  Female_salesDatas_3.toList(),
                                                                                      xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                                                      yValueMapper: (SalesData sales, _) => sales.DATA,
                                                                                      // Enable data label
                                                                                      dataLabelSettings: DataLabelSettings(isVisible: true),
                                                                                      //xAxisName: "月齡",
                                                                                      //yAxisName: "數據",
                                                                                      name: "3%",
                                                                                    ),
                                                                                    LineSeries<SalesData, String>(
                                                                                      dataSource:  Female_salesDatas_15.toList(),
                                                                                      xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                                                      yValueMapper: (SalesData sales, _) => sales.DATA,
                                                                                      // Enable data label
                                                                                      dataLabelSettings: DataLabelSettings(isVisible: true),
                                                                                      //xAxisName: "月齡",
                                                                                      //yAxisName: "數據",
                                                                                      name: "15%",
                                                                                    ),
                                                                                    LineSeries<SalesData, String>(
                                                                                      dataSource:  Female_salesDatas_50.toList(),
                                                                                      xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                                                      yValueMapper: (SalesData sales, _) => sales.DATA,
                                                                                      // Enable data label
                                                                                      dataLabelSettings: DataLabelSettings(isVisible: true),
                                                                                      //xAxisName: "月齡",
                                                                                      //yAxisName: "數據",
                                                                                      name: "50%",
                                                                                    ),
                                                                                    LineSeries<SalesData, String>(
                                                                                      dataSource:  Female_salesDatas_85.toList(),
                                                                                      xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                                                      yValueMapper: (SalesData sales, _) => sales.DATA,
                                                                                      // Enable data label
                                                                                      dataLabelSettings: DataLabelSettings(isVisible: true),
                                                                                      //xAxisName: "月齡",
                                                                                      //yAxisName: "數據",
                                                                                      name: "85%",
                                                                                    ),
                                                                                    LineSeries<SalesData, String>(
                                                                                      dataSource:  Female_salesDatas_97.toList(),
                                                                                      xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                                                      yValueMapper: (SalesData sales, _) => sales.DATA,
                                                                                      // Enable data label
                                                                                      dataLabelSettings: DataLabelSettings(isVisible: true),
                                                                                      //xAxisName: "月齡",
                                                                                      //yAxisName: "數據",
                                                                                      name: "97%",
                                                                                    ),
                                                                                  ]
                                                                              )),
                                                                              Container(height: 20.h,),

                                                                            ],))),


                                                                          ],);
                                                                        });

                                                                  });

                                                              resd_GROWING_STANDARD_db_sub(ITEM_NO:e.ITEM_NO);

                                                            },
                                                            child: IntrinsicWidth(
                                                              child: Column(
                                                                children: [

                                                                  Text("成長曲線表",style: TextStyle(
                                                                      fontFamily: "GenJyuuGothic",
                                                                      fontWeight: FontWeight.normal,
                                                                      fontSize: 11.sp,
                                                                      //decoration: TextDecoration.underline,
                                                                      color: Colors.lightBlue)),
                                                                  Container(height: 1, color: Colors.lightBlue),
                                                                ],
                                                              ),
                                                            )),
                                                        Container(height: 8.h,),
                                                      ],):Container(),

                                                      e.ITEM_RECORD_LINK.isEmpty?
                                                      Container()
                                                          :
                                                      GestureDetector(
                                                          onTap:()async{


                                                            showModalBottomSheet(
                                                                backgroundColor: Colors.white,
                                                                isScrollControlled:true,
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  showModalBottomSheet_image_context = context;
                                                                  return StatefulBuilder(
                                                                      builder: (BuildContext context, showModalBottomSheet_image_setState){

                                                                        this.showModalBottomSheet_image_setState =
                                                                            showModalBottomSheet_image_setState;
                                                                        return Column(children: [

                                                                          Container(height: 50.h,),
                                                                          Row(children: [
                                                                            Expanded(child: Container()),
                                                                            GestureDetector(
                                                                                onTap:(){
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Icon(Icons.cancel_outlined,size: 30.sp,color: Colors.black,)),
                                                                            Container(width: 20.w,),
                                                                          ],),
                                                                          Container(height: 20.h,),
                                                                          Text("點一下圖片可縮放",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                                                              fontFamily: "GenJyuuGothic",
                                                                              fontWeight: FontWeight.normal,
                                                                              fontSize: 20.sp,
                                                                              color: Colors.lightBlue)),
                                                                          Expanded(child: Container(child: WidgetZoom(
                                                                              heroAnimationTag: '${e.ITEM_RECORD_LINK}',
                                                                              zoomWidget: Image.network("${e.ITEM_RECORD_LINK}",
                                                                                errorBuilder: (BuildContext context, Object exception,
                                                                                    StackTrace? stackTrace) {
                                                                                  return  Icon(Icons.error,size: 30.sp,);
                                                                                },
                                                                              )))),


                                                                        ],);
                                                                      });

                                                                });



                                                          },
                                                          child: IntrinsicWidth(
                                                            child: Column(
                                                              children: [

                                                                Text("檢查記錄表",style: TextStyle(
                                                                    fontFamily: "GenJyuuGothic",
                                                                    fontWeight: FontWeight.normal,
                                                                    fontSize: 11.sp,
                                                                    //decoration: TextDecoration.underline,
                                                                    color: Colors.lightBlue)),
                                                                Container(height: 1, color: Colors.lightBlue),
                                                              ],
                                                            ),
                                                          )),

                                                    ],),
                                                    Expanded(child: Container()),
                                                  ],),)),

                                                ],),
                                              ),
                                              //Container(height: 10.h,),

                                            ],);}).toList()),



                                        ],)),


                                  ],)),
                            ],)),
                        Container(height: 5.h,)
                      ],);
                    } ),
                Column(children: [
                  Expanded(child:Container()),
                  Row(children: [
                    Expanded(child:Container()),
                    GestureDetector(
                        onTap:()async{

                          page="建立紀錄";
                          setState(() {

                          });
                          /*
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: GROWING_u_page(operation:"新增")));

                         */

                        },child:
                    Container(

                      child:Center(child:Text("建立\n紀錄",
                          maxLines: null,
                          style: TextStyle(
                              fontFamily: "GenJyuuGothic",
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: Colors.white))),
                      width: 60.0.w,
                      height: 60.0.w,
                      decoration:  BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),)),
                    Container(width: 10.w,)
                  ],),
                  Container(height: 30.h,)
                ],),

              ],))),

            ],)
                :
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [

                GestureDetector(
                    onTap:()async{

                      /*
                dateTime = (await showDatePicker(
                    locale: Locale("zh","TW"),
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 30))))!;

                 */

                      setState(() {

                      });

                    },
                    child: Container(color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
                      Container(width: 5.w,),
                      Text("日期",style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Color(0xff292929))),
                      Expanded(child: Container()),
                      Text((page_notify_menu5_sel_datetime_1==null)?"":"${DateFormat('yyyy年MM月dd日').format(page_notify_menu5_sel_datetime_1!)}",style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Colors.blue)),
                      Container(width: 10.w,),
                    ],),)),
                Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                Container(color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
                  Container(width: 5.w,),
                  Text("種類",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929))),
                  Expanded(child: Container()),
                  (sel_GROWING_TYPE_ITEM.ITEM_NO.isEmpty)?Container():
                  Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.w),
                      ),
                      //width: 80.w,
                      height: 36.h,
                      child:
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<GROWING_TYPE_ITEM>(
                          isExpanded: true,
                          items: GROWING_TYPE_ITEM_list
                              .map((GROWING_TYPE_ITEM item) => DropdownMenuItem<GROWING_TYPE_ITEM>(
                            value: item,
                            child: Text(
                              item.ITEM_NM,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff555555),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                              .toList(),
                          value: sel_GROWING_TYPE_ITEM,
                          onChanged: (value) {

                            sel_GROWING_TYPE_ITEM = value!;
                            dev.log("${sel_GROWING_TYPE_ITEM.ITEM_NO}");
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
                      )),
                  Container(width: 5.w,),
                ],)),
                Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                Container(height: 10.h,),
                (sel_GROWING_TYPE_ITEM.ITEM_NO=="K4")?
                Row(children: [
                  Container(width: 25.w,),
                  Text("左眼:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929))),
                  Container(width: 5.w,),
                  Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.w),
                      ),
                      width: 100.w,
                      height: 36.h,child: Form(
                      child: TextFormField(
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Color(0xff555555),
                        ),
                        controller: L_DATA_textEditingController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          //RemoveEmojiInputFormatter()
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          DecimalTextInputFormatter(decimalRange: 2),
                        ],
                        autofocus: false,
                        maxLines: null,
                        //obscureText: !_adminVisible,
                        //obscureText: !_accountVisible,//This will obscure text dynamically
                        //maxLength: 50,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        //initialValue: 'edu_test010@ncku.com',
                        //inputFormatters: [EmailLimitFormatter()],
                        //validator: (value) => validateEmail(value!),
                        onChanged: (v){
                          //drug_reason.reason = v;
                        },
                        decoration: InputDecoration(
                          filled: true, //<-- SEE HERE
                          fillColor: Colors.transparent, //<-- SEE HERE
                          hintText: '',
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
                  Expanded(child: Container()),
                  Text("右眼:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929))),
                  Container(width: 5.w,),
                  Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.w),
                      ),
                      width: 100.w,
                      height: 36.h,child: Form(
                      child: TextFormField(
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Color(0xff555555),
                        ),
                        controller: R_DATA_textEditingController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          //RemoveEmojiInputFormatter()
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          DecimalTextInputFormatter(decimalRange: 2),
                        ],
                        autofocus: false,
                        maxLines: null,
                        //obscureText: !_adminVisible,
                        //obscureText: !_accountVisible,//This will obscure text dynamically
                        //maxLength: 4,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        //initialValue: 'edu_test010@ncku.com',
                        //inputFormatters: [EmailLimitFormatter()],
                        //validator: (value) => validateEmail(value!),
                        onChanged: (v){
                          //drug_reason.reason = v;
                        },
                        decoration: InputDecoration(
                          counter:null,
                          counterText: "",
                          filled: true, //<-- SEE HERE
                          fillColor: Colors.transparent, //<-- SEE HERE
                          hintText: '',
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
                  Container(width: 25.w,),
                ])
                    :
                (sel_GROWING_TYPE_ITEM.ITEM_NO=="K5" || sel_GROWING_TYPE_ITEM.ITEM_NO=="K6" || sel_GROWING_TYPE_ITEM.ITEM_NO=="K7")?Container():
                Row(children: [
                  Container(width: 5.w,),
                  Text("數據:",style: TextStyle(
                      fontFamily: "GenJyuuGothic",
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Color(0xff292929))),
                  Container(width: 5.w,),
                  Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.w),
                      ),
                      width: 100.w,
                      height: 36.h,child: Form(
                      child: TextFormField(
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Color(0xff555555),
                        ),
                        controller: L_DATA_textEditingController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          //RemoveEmojiInputFormatter()
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                          DecimalTextInputFormatter(decimalRange: 2),
                        ],
                        autofocus: false,
                        maxLines: null,
                        //obscureText: !_adminVisible,
                        //obscureText: !_accountVisible,//This will obscure text dynamically
                        //maxLength: 4,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        //initialValue: 'edu_test010@ncku.com',
                        //inputFormatters: [EmailLimitFormatter()],
                        //validator: (value) => validateEmail(value!),
                        onChanged: (v){
                          //drug_reason.reason = v;
                        },
                        decoration: InputDecoration(
                          counter:null,
                          counterText: "",
                          filled: true, //<-- SEE HERE
                          fillColor: Colors.transparent, //<-- SEE HERE
                          hintText: '',
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
                  Expanded(child: Container()),
                ]),
                (sel_GROWING_TYPE_ITEM.ITEM_NO=="K5" || sel_GROWING_TYPE_ITEM.ITEM_NO=="K6" || sel_GROWING_TYPE_ITEM.ITEM_NO=="K7")?Container():
                Column(children: [
                  Container(height: 10.h,),
                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                ],),

                Container(height: 10.h,),
                GestureDetector(
                    onTap: ()async{

                      //_handleFileSelection();
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
                                      final myAppPath = '$tempDirPath/威寶通/Record';
                                      final res = await Directory(myAppPath).create(recursive: true);
                                      String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';


                                      //壓縮image
                                      prescriptionsbytes_xfile = await FlutterImageCompress.compressAndGetFile(
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
                                            final myAppPath = '$tempDirPath/威寶通/Record';
                                            final res = await Directory(myAppPath).create(recursive: true);
                                            String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                            //壓縮image
                                            prescriptionsbytes_xfile = await FlutterImageCompress
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
                                          final myAppPath = '$tempDirPath/威寶通/Record';
                                          final res = await Directory(myAppPath).create(recursive: true);
                                          String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                          //壓縮image
                                          prescriptionsbytes_xfile = await FlutterImageCompress
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
                                        final myAppPath = '$tempDirPath/威寶通/Record';
                                        final res = await Directory(myAppPath).create(recursive: true);
                                        String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                        //壓縮image
                                        prescriptionsbytes_xfile = await FlutterImageCompress
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
                    child: Container(color: Color(0x01000000),child: Row(children: [
                      Container(width: 10.w,),
                      Text("檢查記錄表上傳",style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Color(0xff292929))),
                      Expanded(child: Container()),
                      Icon(Icons.arrow_forward_ios,size: 26.sp,),
                      Container(width: 10.w,),
                    ]))),
                Container(height: 10.h,),
                (prescriptionsbytes_xfile==null)?
                Container():
                Container(width: ScreenUtil().screenWidth,height: 250.h,decoration:  BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.contain,
                        image:  FileImage(File(prescriptionsbytes_xfile!.path),scale: 0.9)
                    )
                )),

                Container(height: 10.h,),
                Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                Container(height: 10.h,),
                (file==null)?Container():
                GestureDetector(
                    onTap: (){

                    },
                    child: Container(
                      margin: EdgeInsets.all(10.sp),
                      padding: EdgeInsets.all(10.sp),
                      decoration: BoxDecoration(
                        color: Color(0x01000000),
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.w),
                      ),
                      width: ScreenUtil().screenWidth,child:
                    Row(children: [
                      Icon(Icons.file_copy,size: 30.sp,),
                      Container(width: 5.w,),
                      Expanded(child:Text("${file!.path.split('/').last}",style: TextStyle(fontFamily: "GenJyuuGothic",fontSize: 14.sp,color: Colors.black),))
                    ],),
                    )),

                Container(height: 10.h,),

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

                        if(sel_GROWING_TYPE_ITEM.ITEM_NO=="K4"){
                          if(R_DATA_textEditingController.text.isEmpty || L_DATA_textEditingController.text.isEmpty){
                            SmartDialog.showToast('請先輸入視力');
                            return;
                          }
                        }
                        else{
                          if(sel_GROWING_TYPE_ITEM.ITEM_NO=="K5" || sel_GROWING_TYPE_ITEM.ITEM_NO=="K6" || sel_GROWING_TYPE_ITEM.ITEM_NO=="K7"){
                            if(prescriptionsbytes_xfile==null){
                              SmartDialog.showToast('請先匯入紀錄表');
                              return;
                            }
                          }
                          else{
                            if(L_DATA_textEditingController.text.isEmpty){
                              SmartDialog.showToast('請先輸入數據');
                              return;
                            }
                          }

                        }


                        FocusManager.instance.primaryFocus?.unfocus();
                        SmartDialog.showLoading(msg: "處理中...");
                        await Future.delayed(const Duration(milliseconds: 500), () {});

                        try{

                          int GROWING_NO_num = await read_GROWING_db_sub(TYPE: sel_GROWING_TYPE_ITEM.ITEM_NO);//先確定檔案流水號
                          dev.log("GROWING_NO_num:${GROWING_NO_num}");
                          if(GROWING_NO_num==-1){
                            SmartDialog.dismiss();
                            SmartDialog.showToast("read_GROWING_db_sub error");
                            return;
                          }
                          GROWING_NO_num+=1;
                          String GROWING_NO = "${DateFormat('yyMMdd').format(page_notify_menu5_sel_datetime_1!)}${GROWING_NO_num.toString().padLeft(6,"0")}";
                          dev.log("GROWING_NO:${GROWING_NO}");

                          String file_name = "${DateTime.now().microsecondsSinceEpoch}";
                          if(prescriptionsbytes_xfile!=null){
                            await upload_image(image_path: prescriptionsbytes_xfile!.path,file_name: file_name,folder: "Record");
                          }


                          bool check = await insert_GROWING_db_sub(
                            TYPE:sel_GROWING_TYPE_ITEM.ITEM_NO,//種類
                            NO:GROWING_NO,//日期
                            DATE:"${DateFormat('yyyy-MM-dd').format(page_notify_menu5_sel_datetime_1!)}",//日期
                            DEPM_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.DEPM_NO}",//學校
                            CLASS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CLASS_NO}",//班級
                            CS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",//學生編號
                            USER_NO:"${EMPLOYEE_teacher.ACCOUNT}",//建立者
                          );

                          if(check==true){

                            if(sel_GROWING_TYPE_ITEM.ITEM_NO=="K4"){

                              check = await insert_GROWING_EYE_DL_db_sub(
                                TYPE:sel_GROWING_TYPE_ITEM.ITEM_NO,//種類
                                NO:GROWING_NO,//日期
                                L_DATA:"${L_DATA_textEditingController.text}",//
                                R_DATA:"${R_DATA_textEditingController.text}",//
                                RECORD_LINK:(prescriptionsbytes_xfile==null)?"":"~/School/Images/Record/${file_name}.jpg",//
                              );

                            }
                            else{

                              check = await insert_GROWING_DL_db_sub(
                                TYPE:sel_GROWING_TYPE_ITEM.ITEM_NO,//種類
                                NO:GROWING_NO,//
                                DATA:(sel_GROWING_TYPE_ITEM.ITEM_NO=="K5" || sel_GROWING_TYPE_ITEM.ITEM_NO=="K6" || sel_GROWING_TYPE_ITEM.ITEM_NO=="K7")?"":"${L_DATA_textEditingController.text}",//
                                RECORD_LINK:(prescriptionsbytes_xfile==null)?"":"~/School/Images/Record/${file_name}.jpg",//
                              );

                            }

                            SmartDialog.dismiss();

                          }
                          else{
                            SmartDialog.dismiss();
                            SmartDialog.showToast("送出失敗");
                            return;
                          }


                          setState(() {

                          });

                          if(check==true){
                            SmartDialog.showToast("送出成功");
                            page="";
                            prescriptionsbytes_xfile=null;
                            L_DATA_textEditingController.text="";
                            R_DATA_textEditingController.text="";
                            setState(() {

                            });
                            GROWING_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(page_notify_menu5_sel_datetime_1)}");

                          }
                          else{
                            SmartDialog.showToast("送出失敗");
                          }


                        }
                        catch(e){
                          dev.log("${e}");
                          SmartDialog.showToast("失敗\n${e}");
                        }





                      },
                      child: Row(children: [
                        Expanded(child: Container()),
                        Text('送出', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                        Expanded(child: Container()),
                      ],),
                    )),



              ],)

            )
        )));
  }
}
