import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';


import 'student_T.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:radio_group_v2/radio_group_v2.dart' as rg;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'package:signature/signature.dart';
import 'dart:developer' as dev;
import 'api.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'package:badges/badges.dart' as badges;
import 'package:image_picker/image_picker.dart' as ImagePicker;

import 'utils/CustomAppBar.dart';

class ADD_DAILY_CND_page extends StatefulWidget {

  String type = "";
  DateTime dateTime = DateTime.now();
  ADD_DAILY_CND_page({String type="",DateTime? dateTime}){
    this.type = type;
    this.dateTime = dateTime!;
  }

  @override
  State<ADD_DAILY_CND_page> createState() => ADD_DAILY_CND_pageState(type:this.type,dateTime:this.dateTime);
}

class ADD_DAILY_CND_pageState extends State<ADD_DAILY_CND_page> {

  TextEditingController OTHER_textEditingController = TextEditingController();//備註

  DateTime? dateTime = DateTime.now();
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
  DAILY_CND_NASAL_STATUS_ITEM sel_DAILY_CND_NASAL_STATUS_ITEM = DAILY_CND_NASAL_STATUS_ITEM(); //= DAILY_CND_NASAL_STATUS_ITEMs[0];
  TextEditingController NASAL_NOTE_textEditingController = TextEditingController();//鼻塞說明


  bool? is_RUNNY_NOSE=false;//流鼻涕
  rg.RadioGroupController is_RUNNY_NOSE_radioGroup_controller = rg.RadioGroupController();
  DAILY_CND_RUNNY_COLOR_ITEM sel_DAILY_CND_RUNNY_COLOR_ITEM = DAILY_CND_RUNNY_COLOR_ITEM(); //= DAILY_CND_RUNNY_COLOR_ITEMs[0];//流鼻涕顏色
  DAILY_CND_RUNNY_TYPE_ITEM sel_DAILY_CND_RUNNY_TYPE_ITEM = DAILY_CND_RUNNY_TYPE_ITEM();// = DAILY_CND_RUNNY_TYPE_ITEMs[0];//流鼻涕種類
  DAILY_CND_RUNNY_QUANTITY_ITEM sel_DAILY_CND_RUNNY_QUANTITY_ITEM = DAILY_CND_RUNNY_QUANTITY_ITEM();// = DAILY_CND_RUNNY_QUANTITY_ITEMs[0];//流鼻涕數量
  TextEditingController RUNNY_NOSE_NOTE_textEditingController = TextEditingController();//流鼻涕說明


  bool? is_COUGH=false;//咳嗽
  rg.RadioGroupController is_COUGH_radioGroup_controller = rg.RadioGroupController();
  DAILY_CND_COUGH_LEVEL_ITEM sel_DAILY_CND_COUGH_LEVEL_ITEM = DAILY_CND_COUGH_LEVEL_ITEM();// = DAILY_CND_COUGH_LEVEL_ITEMs[0];//咳嗽程度
  DAILY_CND_COUGH_TIME_ITEM sel_DAILY_CND_COUGH_TIME_ITEM = DAILY_CND_COUGH_TIME_ITEM();// = DAILY_CND_COUGH_TIME_ITEMs[0];//咳嗽頻率
  TextEditingController COUGH_NOTE_textEditingController = TextEditingController();//咳嗽說明

  bool? is_VOMIT=false;//嘔吐
  rg.RadioGroupController is_VOMIT_radioGroup_controller = rg.RadioGroupController();

  bool? is_DIARRHEA=false;//腹瀉
  rg.RadioGroupController is_DIARRHEA_radioGroup_controller = rg.RadioGroupController();

  bool? is_HFMD=false;//手足口病
  rg.RadioGroupController is_HFMD_radioGroup_controller = rg.RadioGroupController();
  DAILY_CND_HFMD_TYPE_ITEM sel_DAILY_CND_HFMD_TYPE_ITEM = DAILY_CND_HFMD_TYPE_ITEM();// = DAILY_CND_HFMD_TYPE_ITEMs[0];//手足口病種類
  TextEditingController HFMD_NOTE_textEditingController = TextEditingController();//手足口病說明

  ScrollController listScrollController = ScrollController();

  String type = "";
  ADD_DAILY_CND_pageState({String type="",DateTime? dateTime}){
    this.type = type;
    this.dateTime = dateTime!;
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
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    await read_DAILY_CND_NASAL_STATUS_ITEM_db_sub();
    await read_DAILY_CND_RUNNY_COLOR_ITEM_db_sub();
    await read_DAILY_CND_RUNNY_QUANTITY_ITEM_db_sub();
    await read_DAILY_CND_COUGH_LEVEL_ITEM_db_sub();
    await read_DAILY_CND_COUGH_TIME_ITEM_db_sub();
    await read_DAILY_CND_HFMD_TYPE_ITEM_db_sub();
    await read_DAILY_CND_RUNNY_TYPE_ITEM_db_sub();
    SmartDialog.dismiss();
  }

  Future<void> read_DAILY_CND_RUNNY_TYPE_ITEM_db_sub()async{

    DAILY_CND_RUNNY_TYPE_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_CND_RUNNY_TYPE_ITEM";
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
          DAILY_CND_RUNNY_TYPE_ITEM v = DAILY_CND_RUNNY_TYPE_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}".contains("null")?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}".contains("null")?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_CND_RUNNY_TYPE_ITEMs.add(v);
          sel_DAILY_CND_RUNNY_TYPE_ITEM = DAILY_CND_RUNNY_TYPE_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_CND_HFMD_TYPE_ITEM_db_sub()async{

    DAILY_CND_HFMD_TYPE_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_CND_HFMD_TYPE_ITEM";
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
          DAILY_CND_HFMD_TYPE_ITEM v = DAILY_CND_HFMD_TYPE_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}".contains("null")?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}".contains("null")?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_CND_HFMD_TYPE_ITEMs.add(v);
          sel_DAILY_CND_HFMD_TYPE_ITEM = DAILY_CND_HFMD_TYPE_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_CND_COUGH_TIME_ITEM_db_sub()async{

    DAILY_CND_COUGH_TIME_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_CND_COUGH_TIME_ITEM";
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
          DAILY_CND_COUGH_TIME_ITEM v = DAILY_CND_COUGH_TIME_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}".contains("null")?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}".contains("null")?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_CND_COUGH_TIME_ITEMs.add(v);
          sel_DAILY_CND_COUGH_TIME_ITEM = DAILY_CND_COUGH_TIME_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_CND_COUGH_LEVEL_ITEM_db_sub()async{

    DAILY_CND_COUGH_LEVEL_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_CND_COUGH_LEVEL_ITEM";
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
          DAILY_CND_COUGH_LEVEL_ITEM v = DAILY_CND_COUGH_LEVEL_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}".contains("null")?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}".contains("null")?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_CND_COUGH_LEVEL_ITEMs.add(v);
          sel_DAILY_CND_COUGH_LEVEL_ITEM = DAILY_CND_COUGH_LEVEL_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_CND_RUNNY_QUANTITY_ITEM_db_sub()async{

    DAILY_CND_RUNNY_QUANTITY_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_CND_RUNNY_QUANTITY_ITEM";
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
          DAILY_CND_RUNNY_QUANTITY_ITEM v = DAILY_CND_RUNNY_QUANTITY_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}".contains("null")?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}".contains("null")?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_CND_RUNNY_QUANTITY_ITEMs.add(v);
          sel_DAILY_CND_RUNNY_QUANTITY_ITEM = DAILY_CND_RUNNY_QUANTITY_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_CND_RUNNY_COLOR_ITEM_db_sub()async{

    DAILY_CND_RUNNY_COLOR_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_CND_RUNNY_COLOR_ITEM";
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
          DAILY_CND_RUNNY_COLOR_ITEM v = DAILY_CND_RUNNY_COLOR_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}".contains("null")?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}".contains("null")?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_CND_RUNNY_COLOR_ITEMs.add(v);
          sel_DAILY_CND_RUNNY_COLOR_ITEM = DAILY_CND_RUNNY_COLOR_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }
  Future<void> read_DAILY_CND_NASAL_STATUS_ITEM_db_sub()async{

    DAILY_CND_NASAL_STATUS_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_CND_NASAL_STATUS_ITEM";
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
          DAILY_CND_NASAL_STATUS_ITEM v = DAILY_CND_NASAL_STATUS_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}".contains("null")?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}".contains("null")?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_CND_NASAL_STATUS_ITEMs.add(v);
          sel_DAILY_CND_NASAL_STATUS_ITEM = DAILY_CND_NASAL_STATUS_ITEMs[0];
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
  上傳全班新一筆托嬰活動
   */
  Future<void> add_all_DAILY_MT_db_sub2()async{

    FocusManager.instance.primaryFocus?.unfocus();

    SmartDialog.showLoading(msg: "處理中...");

    dev.log("班級人數:${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length}");

    List<CUSTOMER> _cUSTOMERs = [];
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].is_sel==true){
        _cUSTOMERs.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i]);
      }
    }

    String datetime = "${DateFormat('yyyy-MM-dd').format(dateTime!)}";
    String TYPE = "CND";
    int cUSTOMERs_length = _cUSTOMERs.length;

    dev.log("datetime:(${datetime})");

    String MARK = "";
    if(is_NORMAL==true){
      MARK = '正常';
    }
    if(is_FEVER==true){
      MARK = '${MARK}\n發燒:${FEVER_TEMP_textEditingController.text}°C${FEVER_NOTE_textEditingController.text.isEmpty?"":"\n${FEVER_NOTE_textEditingController.text}"}';
    }
    if(is_NASAL==true){
      MARK = '${MARK}\n鼻塞:${sel_DAILY_CND_NASAL_STATUS_ITEM.ITEM_NM}${NASAL_NOTE_textEditingController.text.isEmpty?"":"\n${NASAL_NOTE_textEditingController.text}"}';
    }
    if(is_RUNNY_NOSE==true){
      MARK = '${MARK}\n流鼻涕:${sel_DAILY_CND_RUNNY_COLOR_ITEM.ITEM_NM}/${sel_DAILY_CND_RUNNY_TYPE_ITEM.ITEM_NM}/${sel_DAILY_CND_RUNNY_QUANTITY_ITEM.ITEM_NM}${RUNNY_NOSE_NOTE_textEditingController.text.isEmpty?"":"\n${RUNNY_NOSE_NOTE_textEditingController.text}"}';
    }
    if(is_COUGH==true){
      MARK = '${MARK}\n咳嗽:${sel_DAILY_CND_COUGH_LEVEL_ITEM.ITEM_NM}/${sel_DAILY_CND_COUGH_TIME_ITEM.ITEM_NM}${COUGH_NOTE_textEditingController.text.isEmpty?"":"\n${COUGH_NOTE_textEditingController.text}"}';
    }
    if(is_VOMIT==true){
      MARK = '${MARK}\n嘔吐';
    }
    if(is_DIARRHEA==true){
      MARK = '${MARK}\n腹瀉';
    }
    if(is_HFMD==true){
      MARK = '${MARK}\n咳嗽:${sel_DAILY_CND_HFMD_TYPE_ITEM.ITEM_NM}${HFMD_NOTE_textEditingController.text.isEmpty?"":"\n${HFMD_NOTE_textEditingController.text}"}';
    }
    if(OTHER_textEditingController.text.isNotEmpty){
      MARK = '${MARK}\n${OTHER_textEditingController.text}';
    }
    final jsonCustomers = jsonEncode(_cUSTOMERs.map((c) => {
      'DEPM_NO': c.DEPM_NO,
      'CLASS_NO': c.CLASS_NO,
      'CS_NO': c.CS_NO,
      'USER_NO': EMPLOYEE_teacher.EMP_NO,
      'MARK':MARK
    }).toList());

    dev.log("jsonCustomers:${jsonCustomers}");
    final escapedJson = jsonCustomers.replaceAll("'", "''");
    dev.log("escapedJson:${escapedJson}");

    String comm = '''
    
BEGIN TRANSACTION;
SET NOCOUNT ON;

-- 1. 傳入參數（Flutter 傳來）
DECLARE @json NVARCHAR(MAX) = N'${escapedJson}';
DECLARE @Count INT = ${cUSTOMERs_length};                         -- 學生人數
DECLARE @PicPerStudent INT = ${DAILY_PIC_DLs.length};                -- 每人圖片數
DECLARE @OTHER NVARCHAR(255) = N'${OTHER_textEditingController.text}';   -- 備註內容
DECLARE @Date DATE = '${datetime}';
DECLARE @Type CHAR(4) = '${TYPE}';
DECLARE @NORMAL BIT = '${is_NORMAL!?"1":"0"}';
DECLARE @FEVER BIT = '${is_FEVER!?"1":"0"}';
DECLARE @NASAL BIT = '${is_NASAL!?"1":"0"}';
DECLARE @RUNNY_NOSE BIT = '${is_RUNNY_NOSE!?"1":"0"}';
DECLARE @COUGH BIT = '${is_COUGH!?"1":"0"}';
DECLARE @VOMIT BIT = '${is_VOMIT!?"1":"0"}';
DECLARE @DIARRHEA BIT = '${is_DIARRHEA!?"1":"0"}';
DECLARE @HFMD BIT = '${is_HFMD!?"1":"0"}';
DECLARE @FEVER_TEMP DECIMAL(4,1) = CAST(NULLIF('${FEVER_TEMP_textEditingController.text}', '') AS DECIMAL(4,1));
DECLARE @FEVER_NOTE NVARCHAR(255) = N'${FEVER_NOTE_textEditingController.text}';
DECLARE @NASAL_STATUS CHAR(1) = N'${sel_DAILY_CND_NASAL_STATUS_ITEM.ITEM_NO}';
DECLARE @NASAL_NOTE NVARCHAR(255) = N'${NASAL_NOTE_textEditingController.text}';
DECLARE @RUNNY_COLOR CHAR(1) = N'${sel_DAILY_CND_RUNNY_COLOR_ITEM.ITEM_NO}';
DECLARE @RUNNY_TYPE CHAR(1) = N'${sel_DAILY_CND_RUNNY_TYPE_ITEM.ITEM_NO}';
DECLARE @RUNNY_QUANTITY CHAR(1) = N'${sel_DAILY_CND_RUNNY_QUANTITY_ITEM.ITEM_NO}';
DECLARE @RUNNY_NOSE_NOTE NVARCHAR(255) = N'${RUNNY_NOSE_NOTE_textEditingController.text}';
DECLARE @COUGH_LEVEL CHAR(1) = N'${sel_DAILY_CND_COUGH_LEVEL_ITEM.ITEM_NO}';
DECLARE @COUGH_TIME CHAR(1) = N'${sel_DAILY_CND_COUGH_TIME_ITEM.ITEM_NO}';
DECLARE @COUGH_NOTE NVARCHAR(255) = N'${COUGH_NOTE_textEditingController.text}';
DECLARE @HFMD_TYPE CHAR(1) = N'${sel_DAILY_CND_HFMD_TYPE_ITEM.ITEM_NO}';
DECLARE @HFMD_NOTE NVARCHAR(255) = N'${HFMD_NOTE_textEditingController.text}';


-- 2. 編號處理
DECLARE @Prefix NVARCHAR(6);
DECLARE @StartNo INT;
DECLARE @BaseNO NVARCHAR(13) = '';              -- 第一筆 NO（圖片命名用）

SET @Prefix = RIGHT(CONVERT(CHAR(8), @Date, 112), 6);

SELECT @StartNo = ISNULL(MAX(CAST(RIGHT(NO, 7) AS INT)), 0)
FROM DAILY_MT WITH (UPDLOCK, HOLDLOCK)
WHERE TYPE = @Type AND DATE = @Date AND LEFT(NO, 6) = @Prefix;

-- 3. 建立 #NewNOs 暫存表
IF OBJECT_ID('tempdb..#NewNOs') IS NOT NULL DELETE FROM #NewNOs;
ELSE CREATE TABLE #NewNOs (Seq INT, NO NVARCHAR(13));

WITH NewNOs AS (
    SELECT 1 AS Seq, @Prefix + RIGHT('0000000' + CAST(@StartNo + 1 AS VARCHAR), 7) AS NO
    UNION ALL
    SELECT Seq + 1, @Prefix + RIGHT('0000000' + CAST(@StartNo + Seq + 1 AS VARCHAR), 7) AS NO
    FROM NewNOs
    WHERE Seq < @Count
)
INSERT INTO #NewNOs
SELECT * FROM NewNOs;

-- 4. 建立 #CustomerData 暫存表
IF OBJECT_ID('tempdb..#CustomerData') IS NOT NULL DELETE FROM #CustomerData;

SELECT
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Seq,
    DEPM_NO,
    CLASS_NO,
    CS_NO,
    USER_NO,
    MARK
INTO #CustomerData
FROM OPENJSON(@json)
WITH (
    DEPM_NO NVARCHAR(50),
    CLASS_NO NVARCHAR(50),
    CS_NO NVARCHAR(50),
    USER_NO NVARCHAR(50),
    MARK NVARCHAR(MAX)
);

-- 5. 建立 #PictureSR 暫存表
IF @PicPerStudent > 0
BEGIN
    IF OBJECT_ID('tempdb..#PictureSR') IS NOT NULL DELETE FROM #PictureSR;
    ELSE CREATE TABLE #PictureSR (SR INT);
    
    WITH Numbers AS (
        SELECT 1 AS SR
        UNION ALL
        SELECT SR + 1 FROM Numbers WHERE SR + 1 <= @PicPerStudent
    )
    INSERT INTO #PictureSR
    SELECT SR FROM Numbers OPTION (MAXRECURSION 0);
END

-- 6. 取得第一筆 NO（圖片命名用）
SELECT TOP 1 @BaseNO = NO FROM #NewNOs ORDER BY Seq;

-- 7. 寫入 DAILY_MT（基本資料）
INSERT INTO DAILY_MT (TYPE, NO, DATE, TIME, DEPM_NO, CLASS_NO, CS_NO, USER_NO,MARK)
SELECT
    @Type,
    n.NO,
    @Date,
    SYSDATETIME(),
    c.DEPM_NO,
    c.CLASS_NO,
    c.CS_NO,
    c.USER_NO,
    c.MARK
FROM #NewNOs n
INNER JOIN #CustomerData c ON n.Seq = c.Seq;

-- 8. 寫入 DAILY_CND（備註）
INSERT INTO DAILY_CND (TYPE, NO,NORMAL,FEVER,FEVER_TEMP,FEVER_NOTE,NASAL,NASAL_STATUS,NASAL_NOTE, RUNNY_NOSE,RUNNY_COLOR,RUNNY_TYPE,RUNNY_QUANTITY,RUNNY_NOSE_NOTE,COUGH,COUGH_LEVEL,COUGH_TIME,COUGH_NOTE,VOMIT,DIARRHEA,HFMD,HFMD_TYPE,HFMD_NOTE,OTHER)
SELECT @Type, NO,@NORMAL,@FEVER,@FEVER_TEMP,@FEVER_NOTE,@NASAL,@NASAL_STATUS,@NASAL_NOTE, @RUNNY_NOSE,@RUNNY_COLOR,@RUNNY_TYPE,@RUNNY_QUANTITY,@RUNNY_NOSE_NOTE,@COUGH,@COUGH_LEVEL,@COUGH_TIME,@COUGH_NOTE,@VOMIT,@DIARRHEA,@HFMD,@HFMD_TYPE,@HFMD_NOTE,@OTHER
FROM #NewNOs;

-- 9. 寫入 DAILY_PIC_DL（每筆 @PicPerStudent 張圖）
IF @PicPerStudent > 0
BEGIN
    INSERT INTO DAILY_PIC_DL (TYPE, NO, SR, LINK)
    SELECT 
        @Type,
        n.NO,
        p.SR,
        '~/School/Images/Daily/'+@BaseNO + '_' + CAST(p.SR AS NVARCHAR)+'_' + c.USER_NO + '.jpg'
    FROM #NewNOs n
    INNER JOIN #CustomerData c ON n.Seq = c.Seq
    CROSS JOIN #PictureSR p;
END

-- 10. 回傳 JSON 結果
DECLARE @Result TABLE (
    message NVARCHAR(20),
    affectedRows INT,
    FirstNO NVARCHAR(13)
);

INSERT INTO @Result
SELECT N'執行成功', @Count * (1 + 1 + @PicPerStudent), @BaseNO;

-- 提交交易
COMMIT;

-- 輸出 JSON 結果（欄位加上別名避免錯誤）
SELECT 
    message AS message,
    affectedRows AS affectedRows,
    FirstNO AS FirstNO
FROM @Result
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    ''';

    String result = await sql_command2("${comm}");
    dev.log("全班寫入生理狀況(回應):${result}");

    try{
      Map<String,dynamic> map = jsonDecode(result);
      if("${map["message"]}"=="執行成功"){

        String View_DAILY_NO = "${map["FirstNO"]}";
        for(int i=0;i<DAILY_PIC_DLs.length;i++){

          if(DAILY_PIC_DLs[i].prescriptionsbytes_xfile!=null){
            //圖片檔名(NO+序號+使用者+日期時間),日期時間 (yyyyMMddHHmmsss)
            String img_name = "${View_DAILY_NO}_${i+1}_${EMPLOYEE_teacher.EMP_NO}";
            dev.log("img_name[${i}]:${img_name}");
            await upload_image(image_path: DAILY_PIC_DLs[i].prescriptionsbytes_xfile!.path,file_name: img_name,folder: "Daily");
          }

        }

        SmartDialog.dismiss();
        SmartDialog.showToast("處理成功");
        //Student_T_page_fun!(action:"新增[托嬰/幼兒]健康 生理狀況成功");
        DAILY_PIC_DLs.clear();
        dateTime=null;
        timeOfDay=null;
        Navigator.pop(this_context!);



      }
      else{

        SmartDialog.dismiss();

        showDialog(
          context: context,
          barrierDismissible: false, // 點外面不關閉 dialog
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('⚠️ 警告',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
              content: Text('上傳失敗，請重試',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
              actions: <Widget>[
                TextButton(
                  child:  Text('關閉',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
                  onPressed: () {
                    Navigator.of(context).pop(); // 關閉 Dialog
                  },
                ),
              ],
            );
          },
        );


      }
    }
    catch(e){

      SmartDialog.dismiss();

      showDialog(
        context: context,
        barrierDismissible: false, // 點外面不關閉 dialog
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('⚠️ 警告',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
            content: Text('上傳失敗，請重試',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
            actions: <Widget>[
              TextButton(
                child:  Text('關閉',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
                onPressed: () {
                  Navigator.of(context).pop(); // 關閉 Dialog
                },
              ),
            ],
          );
        },
      );

    }




  }

  /*
  上傳全班新一筆托嬰活動
   */
  /*
  Future<void> add_all_DAILY_MT_db_sub()async{

    FocusManager.instance.primaryFocus?.unfocus();

    dev.log("班級人數:${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length}");

    List<CUSTOMER> _cUSTOMERs = [];
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].is_sel==true){
        _cUSTOMERs.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i]);
      }
    }

    for(int i=0;i<_cUSTOMERs.length;i++){


      int View_DAILY_NO_num = await read_View_DAILY_db_sub();
      dev.log("View_DAILY_NO_num:${View_DAILY_NO_num}");
      if(View_DAILY_NO_num==-1){
        SmartDialog.dismiss();
        SmartDialog.showToast("read_View_DAILY_db_sub error");
        return;
      }

      SmartDialog.showLoading(msg: "處理中...(${i+1}/${_cUSTOMERs.length})");
      await Future.delayed(const Duration(milliseconds: 300), () {});

      //await EasyLoading.show(status: "處理中...");
      //View_DAILY_NO_num+=1;
      String View_DAILY_NO = "${View_DAILY_NO_num}";//"${DateFormat('yyyyMMdd').format(dateTime!)}${View_DAILY_NO_num.toString().padLeft(7,"0")}";
      //View_DAILY_NO = View_DAILY_NO.substring(2,View_DAILY_NO.length);
      dev.log("View_DAILY_NO:${View_DAILY_NO}");

      //dev.log("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NM}");

      bool check = await insert_DAILY_MT_db_sub(
        TYPE:"CND",
        NO:View_DAILY_NO,//編號
        DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
        TIME:"${DateFormat('HH:mm').format(DateTime.now())}",//"${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00",//時間
        DEPM_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}",//學校
        CLASS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}",//班級
        CS_NO:"${_cUSTOMERs[i].CS_NO}",//學生身分證字號
        USER_NO:"${EMPLOYEE_teacher.EMP_NO}",//系統自動帶入老師編號
      );

      if(check==false){
        SmartDialog.dismiss();
        SmartDialog.showToast("忙碌中，請重試");
        return;
      }

      //送出活動_副表
      await insert_DAILY_CND_db_sub(
        TYPE:"CND",
        NO:View_DAILY_NO,//編號
        NORMAL:is_NORMAL,//
        FEVER:is_FEVER,
        FEVER_TEMP:is_FEVER==false?"":FEVER_TEMP_textEditingController.text,
        FEVER_NOTE:is_FEVER==false?"":FEVER_NOTE_textEditingController.text,
        NASAL:is_NASAL,
        NASAL_STATUS:is_NASAL==false?"":sel_DAILY_CND_NASAL_STATUS_ITEM.ITEM_NO,
        NASAL_NOTE:is_NASAL==false?"":NASAL_NOTE_textEditingController.text,
        RUNNY_NOSE:is_RUNNY_NOSE,
        RUNNY_COLOR:is_RUNNY_NOSE==false?"":sel_DAILY_CND_RUNNY_COLOR_ITEM.ITEM_NO,
        RUNNY_TYPE:is_RUNNY_NOSE==false?"":sel_DAILY_CND_RUNNY_TYPE_ITEM.ITEM_NO,
        RUNNY_QUANTITY:is_RUNNY_NOSE==false?"":sel_DAILY_CND_RUNNY_QUANTITY_ITEM.ITEM_NO,
        RUNNY_NOSE_NOTE:is_RUNNY_NOSE==false?"":RUNNY_NOSE_NOTE_textEditingController.text,
        COUGH:is_COUGH,
        COUGH_LEVEL:is_COUGH==false?"":sel_DAILY_CND_COUGH_LEVEL_ITEM.ITEM_NO,
        COUGH_TIME:is_COUGH==false?"":sel_DAILY_CND_COUGH_TIME_ITEM.ITEM_NO,
        COUGH_NOTE:is_COUGH==false?"":COUGH_NOTE_textEditingController.text,
        VOMIT:is_VOMIT,
        DIARRHEA:is_DIARRHEA,
        HFMD:is_HFMD,
        HFMD_TYPE:is_HFMD==false?"":sel_DAILY_CND_HFMD_TYPE_ITEM.ITEM_NO,
        HFMD_NOTE:is_HFMD==false?"":HFMD_NOTE_textEditingController.text,
        OTHER:OTHER_textEditingController.text,
      );

      if(DAILY_PIC_DLs.length==0){
        await insert_DAILY_PIC_DL_db_sub(
          TYPE:"CND",//
          NO:"${View_DAILY_NO}",
          SR:"${1}",
          LINK:"",//照片

        );
      }
      else{
        for(int i=0;i<DAILY_PIC_DLs.length;i++){

          if(DAILY_PIC_DLs[i].prescriptionsbytes_xfile!=null){
            String img_name = "${View_DAILY_NO}_${i+1}_${user.ACCOUNT}_${DateFormat("yyyyMMddHHmmsss").format(DateTime.now())}";
            await upload_image(image_path: DAILY_PIC_DLs[i].prescriptionsbytes_xfile!.path,file_name: img_name,folder: "Daily");
            await insert_DAILY_PIC_DL_db_sub(
              TYPE:"CND",//
              NO:"${View_DAILY_NO}",
              SR:"${i+1}",
              LINK:(DAILY_PIC_DLs[i].prescriptionsbytes_xfile==null)?"":"~/School/Images/Daily/${img_name}.jpg",//照片

            );
          }

        }
      }


    }

    SmartDialog.dismiss();
    SmartDialog.showToast("處理成功");
    //Student_T_page_fun!(action:"新增[托嬰/幼兒]健康 生理狀況成功");
    DAILY_PIC_DLs.clear();
    dateTime=null;
    timeOfDay=null;
    Navigator.pop(this_context!);


  }

   */

  /*
  上傳新一筆托嬰活動
   */

  Future<void> add_DAILY_MT_db_sub2()async{

    FocusManager.instance.primaryFocus?.unfocus();

    SmartDialog.showLoading(msg: "處理中...");

    dev.log("班級人數:${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length}");

    List<CUSTOMER> _cUSTOMERs = [];
    _cUSTOMERs.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue);


    String datetime = "${DateFormat('yyyy-MM-dd').format(dateTime!)}";
    String TYPE = "CND";
    int cUSTOMERs_length = _cUSTOMERs.length;

    dev.log("datetime:(${datetime})");

    String MARK = "";
    if(is_NORMAL==true){
      MARK = '正常';
    }
    if(is_FEVER==true){
      MARK = '${MARK}\n發燒:${FEVER_TEMP_textEditingController.text}°C${FEVER_NOTE_textEditingController.text.isEmpty?"":"\n${FEVER_NOTE_textEditingController.text}"}';
    }
    if(is_NASAL==true){
      MARK = '${MARK}\n鼻塞:${sel_DAILY_CND_NASAL_STATUS_ITEM.ITEM_NM}${NASAL_NOTE_textEditingController.text.isEmpty?"":"\n${NASAL_NOTE_textEditingController.text}"}';
    }
    if(is_RUNNY_NOSE==true){
      MARK = '${MARK}\n流鼻涕:${sel_DAILY_CND_RUNNY_COLOR_ITEM.ITEM_NM}/${sel_DAILY_CND_RUNNY_TYPE_ITEM.ITEM_NM}/${sel_DAILY_CND_RUNNY_QUANTITY_ITEM.ITEM_NM}${RUNNY_NOSE_NOTE_textEditingController.text.isEmpty?"":"\n${RUNNY_NOSE_NOTE_textEditingController.text}"}';
    }
    if(is_COUGH==true){
      MARK = '${MARK}\n咳嗽:${sel_DAILY_CND_COUGH_LEVEL_ITEM.ITEM_NM}/${sel_DAILY_CND_COUGH_TIME_ITEM.ITEM_NM}${COUGH_NOTE_textEditingController.text.isEmpty?"":"\n${COUGH_NOTE_textEditingController.text}"}';
    }
    if(is_VOMIT==true){
      MARK = '${MARK}\n嘔吐';
    }
    if(is_DIARRHEA==true){
      MARK = '${MARK}\n腹瀉';
    }
    if(is_HFMD==true){
      MARK = '${MARK}\n咳嗽:${sel_DAILY_CND_HFMD_TYPE_ITEM.ITEM_NM}${HFMD_NOTE_textEditingController.text.isEmpty?"":"\n${HFMD_NOTE_textEditingController.text}"}';
    }
    if(OTHER_textEditingController.text.isNotEmpty){
      MARK = '${MARK}\n${OTHER_textEditingController.text}';
    }
    final jsonCustomers = jsonEncode(_cUSTOMERs.map((c) => {
      'DEPM_NO': c.DEPM_NO,
      'CLASS_NO': c.CLASS_NO,
      'CS_NO': c.CS_NO,
      'USER_NO': EMPLOYEE_teacher.EMP_NO,
      'MARK':MARK
    }).toList());

    dev.log("jsonCustomers:${jsonCustomers}");
    final escapedJson = jsonCustomers.replaceAll("'", "''");
    dev.log("escapedJson:${escapedJson}");

    String comm = '''
    
BEGIN TRANSACTION;
SET NOCOUNT ON;

-- 1. 傳入參數（Flutter 傳來）
DECLARE @json NVARCHAR(MAX) = N'${escapedJson}';
DECLARE @Count INT = ${cUSTOMERs_length};                         -- 學生人數
DECLARE @PicPerStudent INT = ${DAILY_PIC_DLs.length};                -- 每人圖片數
DECLARE @OTHER NVARCHAR(255) = N'${OTHER_textEditingController.text}';   -- 備註內容
DECLARE @Date DATE = '${datetime}';
DECLARE @Type CHAR(4) = '${TYPE}';
DECLARE @NORMAL BIT = '${is_NORMAL!?"1":"0"}';
DECLARE @FEVER BIT = '${is_FEVER!?"1":"0"}';
DECLARE @NASAL BIT = '${is_NASAL!?"1":"0"}';
DECLARE @RUNNY_NOSE BIT = '${is_RUNNY_NOSE!?"1":"0"}';
DECLARE @COUGH BIT = '${is_COUGH!?"1":"0"}';
DECLARE @VOMIT BIT = '${is_VOMIT!?"1":"0"}';
DECLARE @DIARRHEA BIT = '${is_DIARRHEA!?"1":"0"}';
DECLARE @HFMD BIT = '${is_HFMD!?"1":"0"}';
DECLARE @FEVER_TEMP DECIMAL(4,1) = CAST(NULLIF('${FEVER_TEMP_textEditingController.text}', '') AS DECIMAL(4,1));
DECLARE @FEVER_NOTE NVARCHAR(255) = N'${FEVER_NOTE_textEditingController.text}';
DECLARE @NASAL_STATUS CHAR(1) = N'${sel_DAILY_CND_NASAL_STATUS_ITEM.ITEM_NO}';
DECLARE @NASAL_NOTE NVARCHAR(255) = N'${NASAL_NOTE_textEditingController.text}';
DECLARE @RUNNY_COLOR CHAR(1) = N'${sel_DAILY_CND_RUNNY_COLOR_ITEM.ITEM_NO}';
DECLARE @RUNNY_TYPE CHAR(1) = N'${sel_DAILY_CND_RUNNY_TYPE_ITEM.ITEM_NO}';
DECLARE @RUNNY_QUANTITY CHAR(1) = N'${sel_DAILY_CND_RUNNY_QUANTITY_ITEM.ITEM_NO}';
DECLARE @RUNNY_NOSE_NOTE NVARCHAR(255) = N'${RUNNY_NOSE_NOTE_textEditingController.text}';
DECLARE @COUGH_LEVEL CHAR(1) = N'${sel_DAILY_CND_COUGH_LEVEL_ITEM.ITEM_NO}';
DECLARE @COUGH_TIME CHAR(1) = N'${sel_DAILY_CND_COUGH_TIME_ITEM.ITEM_NO}';
DECLARE @COUGH_NOTE NVARCHAR(255) = N'${COUGH_NOTE_textEditingController.text}';
DECLARE @HFMD_TYPE CHAR(1) = N'${sel_DAILY_CND_HFMD_TYPE_ITEM.ITEM_NO}';
DECLARE @HFMD_NOTE NVARCHAR(255) = N'${HFMD_NOTE_textEditingController.text}';


-- 2. 編號處理
DECLARE @Prefix NVARCHAR(6);
DECLARE @StartNo INT;
DECLARE @BaseNO NVARCHAR(13) = '';              -- 第一筆 NO（圖片命名用）

SET @Prefix = RIGHT(CONVERT(CHAR(8), @Date, 112), 6);

SELECT @StartNo = ISNULL(MAX(CAST(RIGHT(NO, 7) AS INT)), 0)
FROM DAILY_MT WITH (UPDLOCK, HOLDLOCK)
WHERE TYPE = @Type AND DATE = @Date AND LEFT(NO, 6) = @Prefix;

-- 3. 建立 #NewNOs 暫存表
IF OBJECT_ID('tempdb..#NewNOs') IS NOT NULL DELETE FROM #NewNOs;
ELSE CREATE TABLE #NewNOs (Seq INT, NO NVARCHAR(13));

WITH NewNOs AS (
    SELECT 1 AS Seq, @Prefix + RIGHT('0000000' + CAST(@StartNo + 1 AS VARCHAR), 7) AS NO
    UNION ALL
    SELECT Seq + 1, @Prefix + RIGHT('0000000' + CAST(@StartNo + Seq + 1 AS VARCHAR), 7) AS NO
    FROM NewNOs
    WHERE Seq < @Count
)
INSERT INTO #NewNOs
SELECT * FROM NewNOs;

-- 4. 建立 #CustomerData 暫存表
IF OBJECT_ID('tempdb..#CustomerData') IS NOT NULL DELETE FROM #CustomerData;

SELECT
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS Seq,
    DEPM_NO,
    CLASS_NO,
    CS_NO,
    USER_NO,
    MARK
INTO #CustomerData
FROM OPENJSON(@json)
WITH (
    DEPM_NO NVARCHAR(50),
    CLASS_NO NVARCHAR(50),
    CS_NO NVARCHAR(50),
    USER_NO NVARCHAR(50),
    MARK NVARCHAR(MAX)
);

-- 5. 建立 #PictureSR 暫存表
IF @PicPerStudent > 0
BEGIN
    IF OBJECT_ID('tempdb..#PictureSR') IS NOT NULL DELETE FROM #PictureSR;
    ELSE CREATE TABLE #PictureSR (SR INT);
    
    WITH Numbers AS (
        SELECT 1 AS SR
        UNION ALL
        SELECT SR + 1 FROM Numbers WHERE SR + 1 <= @PicPerStudent
    )
    INSERT INTO #PictureSR
    SELECT SR FROM Numbers OPTION (MAXRECURSION 0);
END

-- 6. 取得第一筆 NO（圖片命名用）
SELECT TOP 1 @BaseNO = NO FROM #NewNOs ORDER BY Seq;

-- 7. 寫入 DAILY_MT（基本資料）
INSERT INTO DAILY_MT (TYPE, NO, DATE, TIME, DEPM_NO, CLASS_NO, CS_NO, USER_NO,MARK)
SELECT
    @Type,
    n.NO,
    @Date,
    SYSDATETIME(),
    c.DEPM_NO,
    c.CLASS_NO,
    c.CS_NO,
    c.USER_NO,
    c.MARK
FROM #NewNOs n
INNER JOIN #CustomerData c ON n.Seq = c.Seq;

-- 8. 寫入 DAILY_CND（備註）
INSERT INTO DAILY_CND (TYPE, NO,NORMAL,FEVER,FEVER_TEMP,FEVER_NOTE,NASAL,NASAL_STATUS,NASAL_NOTE, RUNNY_NOSE,RUNNY_COLOR,RUNNY_TYPE,RUNNY_QUANTITY,RUNNY_NOSE_NOTE,COUGH,COUGH_LEVEL,COUGH_TIME,COUGH_NOTE,VOMIT,DIARRHEA,HFMD,HFMD_TYPE,HFMD_NOTE,OTHER)
SELECT @Type, NO,@NORMAL,@FEVER,@FEVER_TEMP,@FEVER_NOTE,@NASAL,@NASAL_STATUS,@NASAL_NOTE, @RUNNY_NOSE,@RUNNY_COLOR,@RUNNY_TYPE,@RUNNY_QUANTITY,@RUNNY_NOSE_NOTE,@COUGH,@COUGH_LEVEL,@COUGH_TIME,@COUGH_NOTE,@VOMIT,@DIARRHEA,@HFMD,@HFMD_TYPE,@HFMD_NOTE,@OTHER
FROM #NewNOs;

-- 9. 寫入 DAILY_PIC_DL（每筆 @PicPerStudent 張圖）
IF @PicPerStudent > 0
BEGIN
    INSERT INTO DAILY_PIC_DL (TYPE, NO, SR, LINK)
    SELECT 
        @Type,
        n.NO,
        p.SR,
        '~/School/Images/Daily/'+@BaseNO + '_' + CAST(p.SR AS NVARCHAR)+'_' + c.USER_NO + '.jpg'
    FROM #NewNOs n
    INNER JOIN #CustomerData c ON n.Seq = c.Seq
    CROSS JOIN #PictureSR p;
END

-- 10. 回傳 JSON 結果
DECLARE @Result TABLE (
    message NVARCHAR(20),
    affectedRows INT,
    FirstNO NVARCHAR(13)
);

INSERT INTO @Result
SELECT N'執行成功', @Count * (1 + 1 + @PicPerStudent), @BaseNO;

-- 提交交易
COMMIT;

-- 輸出 JSON 結果（欄位加上別名避免錯誤）
SELECT 
    message AS message,
    affectedRows AS affectedRows,
    FirstNO AS FirstNO
FROM @Result
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    ''';

    String result = await sql_command2("${comm}");
    dev.log("全班寫入生理狀況(回應):${result}");

    try{
      Map<String,dynamic> map = jsonDecode(result);
      if("${map["message"]}"=="執行成功"){

        String View_DAILY_NO = "${map["FirstNO"]}";
        for(int i=0;i<DAILY_PIC_DLs.length;i++){

          if(DAILY_PIC_DLs[i].prescriptionsbytes_xfile!=null){
            //圖片檔名(NO+序號+使用者+日期時間),日期時間 (yyyyMMddHHmmsss)
            String img_name = "${View_DAILY_NO}_${i+1}_${EMPLOYEE_teacher.EMP_NO}";
            dev.log("img_name[${i}]:${img_name}");
            await upload_image(image_path: DAILY_PIC_DLs[i].prescriptionsbytes_xfile!.path,file_name: img_name,folder: "Daily");
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
      else{

        SmartDialog.dismiss();

        showDialog(
          context: context,
          barrierDismissible: false, // 點外面不關閉 dialog
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('⚠️ 警告',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
              content: Text('上傳失敗，請重試',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
              actions: <Widget>[
                TextButton(
                  child:  Text('關閉',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
                  onPressed: () {
                    Navigator.of(context).pop(); // 關閉 Dialog
                  },
                ),
              ],
            );
          },
        );


      }
    }
    catch(e){

      SmartDialog.dismiss();

      showDialog(
        context: context,
        barrierDismissible: false, // 點外面不關閉 dialog
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('⚠️ 警告',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
            content: Text('上傳失敗，請重試',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
            actions: <Widget>[
              TextButton(
                child:  Text('關閉',textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
                onPressed: () {
                  Navigator.of(context).pop(); // 關閉 Dialog
                },
              ),
            ],
          );
        },
      );

    }




  }
  /*
  Future<void> add_DAILY_MT_db_sub()async{
    int View_DAILY_NO_num = await read_View_DAILY_db_sub();
    dev.log("View_DAILY_NO_num:${View_DAILY_NO_num}");
    if(View_DAILY_NO_num==-1){
      SmartDialog.showToast("read_View_DAILY_db_sub error");
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 300), () {});
    //View_DAILY_NO_num+=1;
    String View_DAILY_NO = "${View_DAILY_NO_num}";//"${DateFormat('yyyyMMdd').format(dateTime!)}${View_DAILY_NO_num.toString().padLeft(7,"0")}";
    //View_DAILY_NO = View_DAILY_NO.substring(2,View_DAILY_NO.length);
    dev.log("View_DAILY_NO:${View_DAILY_NO}");

    dev.log("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NM}");

    bool check = await insert_DAILY_MT_db_sub(
        TYPE:"CND",
        NO:View_DAILY_NO,//編號
        DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
        TIME:"${DateFormat('HH:mm').format(DateTime.now())}",//"${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00",//時間
        DEPM_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}",//學校
        CLASS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}",//班級
        CS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",//學生身分證字號
        USER_NO:"${EMPLOYEE_teacher.EMP_NO}",//系統自動帶入老師編號
    );

    if(check==false){
      SmartDialog.dismiss();
      SmartDialog.showToast("忙碌中，請重試");
      return;
    }


    //送出活動_副表
    await insert_DAILY_CND_db_sub(
      TYPE:"CND",
      NO:View_DAILY_NO,//編號
      NORMAL:is_NORMAL,//
      FEVER:is_FEVER,
      FEVER_TEMP:is_FEVER==false?"":FEVER_TEMP_textEditingController.text,
      FEVER_NOTE:is_FEVER==false?"":FEVER_NOTE_textEditingController.text,
      NASAL:is_NASAL,
      NASAL_STATUS:is_NASAL==false?"":sel_DAILY_CND_NASAL_STATUS_ITEM.ITEM_NO,
      NASAL_NOTE:is_NASAL==false?"":NASAL_NOTE_textEditingController.text,
      RUNNY_NOSE:is_RUNNY_NOSE,
      RUNNY_COLOR:is_RUNNY_NOSE==false?"":sel_DAILY_CND_RUNNY_COLOR_ITEM.ITEM_NO,
      RUNNY_TYPE:is_RUNNY_NOSE==false?"":sel_DAILY_CND_RUNNY_TYPE_ITEM.ITEM_NO,
      RUNNY_QUANTITY:is_RUNNY_NOSE==false?"":sel_DAILY_CND_RUNNY_QUANTITY_ITEM.ITEM_NO,
      RUNNY_NOSE_NOTE:is_RUNNY_NOSE==false?"":RUNNY_NOSE_NOTE_textEditingController.text,
      COUGH:is_COUGH,
      COUGH_LEVEL:is_COUGH==false?"":sel_DAILY_CND_COUGH_LEVEL_ITEM.ITEM_NO,
      COUGH_TIME:is_COUGH==false?"":sel_DAILY_CND_COUGH_TIME_ITEM.ITEM_NO,
      COUGH_NOTE:is_COUGH==false?"":COUGH_NOTE_textEditingController.text,
      VOMIT:is_VOMIT,
      DIARRHEA:is_DIARRHEA,
      HFMD:is_HFMD,
      HFMD_TYPE:is_HFMD==false?"":sel_DAILY_CND_HFMD_TYPE_ITEM.ITEM_NO,
      HFMD_NOTE:is_HFMD==false?"":HFMD_NOTE_textEditingController.text,
      OTHER:OTHER_textEditingController.text,
    );


    if(DAILY_PIC_DLs.length==0){
      await insert_DAILY_PIC_DL_db_sub(
        TYPE:"CND",//
        NO:"${View_DAILY_NO}",
        SR:"${1}",
        LINK:"",//照片
      );
    }
    else{
      for(int i=0;i<DAILY_PIC_DLs.length;i++){

        if(DAILY_PIC_DLs[i].prescriptionsbytes_xfile!=null){
          String img_name = "${View_DAILY_NO}_${i+1}_${user.ACCOUNT}_${DateFormat("yyyyMMddHHmmsss").format(DateTime.now())}";
          await upload_image(image_path: DAILY_PIC_DLs[i].prescriptionsbytes_xfile!.path,file_name: img_name,folder: "Daily");
          await insert_DAILY_PIC_DL_db_sub(
            TYPE:"CND",//
            NO:"${View_DAILY_NO}",
            SR:"${i+1}",
            LINK:(DAILY_PIC_DLs[i].prescriptionsbytes_xfile==null)?"":"~/School/Images/Daily/${img_name}.jpg",//照片

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

   */


  /*

   */
  Future<bool> insert_DAILY_MT_db_sub(
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


  /*

   */
  Future<void> insert_DAILY_CND_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        bool? NORMAL,//正常
        bool? FEVER,//發燒
        String? FEVER_TEMP="",//發燒溫度
        String? FEVER_NOTE="",//發燒說明
        bool? NASAL,//鼻塞
        String? NASAL_STATUS="",//鼻塞
        String? NASAL_NOTE="",//鼻塞說明
        bool? RUNNY_NOSE,//流鼻涕
        String? RUNNY_COLOR="",//流鼻涕顏色
        String? RUNNY_TYPE="",//流鼻涕種類
        String? RUNNY_QUANTITY="",//流鼻涕數量
        String? RUNNY_NOSE_NOTE="",//流鼻涕說明
        bool? COUGH,//咳嗽
        String? COUGH_LEVEL="",//咳嗽程度
        String? COUGH_TIME="",//咳嗽頻率
        String? COUGH_NOTE="",//咳嗽說明
        bool? VOMIT,//嘔吐
        bool? DIARRHEA,//腹瀉
        bool? HFMD,//手足口病
        String? HFMD_TYPE="",//手足口病種類
        String? HFMD_NOTE="",//手足口病說明
        String? OTHER="",//其他

      })async{

    String comm = "INSERT INTO DAILY_CND("
        "TYPE,NO,NORMAL,FEVER,FEVER_TEMP,FEVER_NOTE,NASAL,NASAL_STATUS,NASAL_NOTE,RUNNY_NOSE,RUNNY_COLOR,RUNNY_TYPE,RUNNY_QUANTITY,RUNNY_NOSE_NOTE,COUGH,COUGH_LEVEL,COUGH_TIME,COUGH_NOTE,VOMIT,DIARRHEA,HFMD,HFMD_TYPE,HFMD_NOTE,OTHER) "
        "VALUES ('${TYPE}','${NO}','${NORMAL}','${FEVER}','${FEVER_TEMP}','${FEVER_NOTE}','${NASAL}','${NASAL_STATUS}','${NASAL_NOTE}','${RUNNY_NOSE}','${RUNNY_COLOR}','${RUNNY_TYPE}','${RUNNY_QUANTITY}','${RUNNY_NOSE_NOTE}','${COUGH}','${COUGH_LEVEL}','${COUGH_TIME}','${COUGH_NOTE}','${VOMIT}','${DIARRHEA}','${HFMD}','${HFMD_TYPE}','${HFMD_NOTE}','${OTHER}')";
    if(FEVER_TEMP!.isEmpty){
      comm = "INSERT INTO DAILY_CND("
          "TYPE,NO,NORMAL,FEVER,FEVER_NOTE,NASAL,NASAL_STATUS,NASAL_NOTE,RUNNY_NOSE,RUNNY_COLOR,RUNNY_TYPE,RUNNY_QUANTITY,RUNNY_NOSE_NOTE,COUGH,COUGH_LEVEL,COUGH_TIME,COUGH_NOTE,VOMIT,DIARRHEA,HFMD,HFMD_TYPE,HFMD_NOTE,OTHER) "
          "VALUES ('${TYPE}','${NO}','${NORMAL}','${FEVER}','${FEVER_NOTE}','${NASAL}','${NASAL_STATUS}','${NASAL_NOTE}','${RUNNY_NOSE}','${RUNNY_COLOR}','${RUNNY_TYPE}','${RUNNY_QUANTITY}','${RUNNY_NOSE_NOTE}','${COUGH}','${COUGH_LEVEL}','${COUGH_TIME}','${COUGH_NOTE}','${VOMIT}','${DIARRHEA}','${HFMD}','${HFMD_TYPE}','${HFMD_NOTE}','${OTHER}')";
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
    //String comm = "SELECT * FROM DAILY_MT WHERE TYPE='CND' AND  DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";
    String comm = '''SELECT *
    FROM DAILY_MT
    WHERE TYPE = 'CND'
      AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'
      AND NO = (
        SELECT MAX(NO)
        FROM DAILY_MT
        WHERE TYPE = 'CND'
          AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'
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

        View_DAILY_NO_num+=1;
        String ss = "${DateFormat('yyyyMMdd').format(dateTime!)}";
        View_DAILY_NO_num = int.parse("${ss.substring(2,ss.length)}${View_DAILY_NO_num.toString().padLeft(7,"0")}");

      }
      else{
        data_list.sort((a,b)=> int.parse(a["NO"]).compareTo(int.parse(b["NO"])));
        String View_DAILY_NO = "${data_list[data_list.length-1]["NO"]}";
        dev.log("View_DAILY_NO:${View_DAILY_NO}");
        //找出流水號
        View_DAILY_NO_num = int.parse("${View_DAILY_NO}");
        View_DAILY_NO_num+=1;
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
                  /*
                  if(dateTime!=null){
                    check=true;
                  }

                   */
                  if(DAILY_PIC_DLs.length>0){
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


                        /*
                        生理狀況，需要假設一個狀況是，勾選否，但老師並無勾選，比如:發燒/是，或是沒有在其他填寫症狀的話，讓他無法發布(防呆)，避免生理狀況的狀態列空白
                         */
                        if(is_NORMAL==false &&
                            is_FEVER==false &&
                            is_NASAL==false &&
                            is_RUNNY_NOSE==false &&
                            is_COUGH==false &&
                            is_VOMIT==false &&
                            is_DIARRHEA==false &&
                            is_HFMD==false &&
                            OTHER_textEditingController.text.isEmpty
                        ){

                          showCupertinoDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CupertinoAlertDialog(
                                title: Text('溫馨提醒',textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 20.sp),),
                                content: Text('因為您點選正常為(否)，\n因此您還需要點選至少一種症狀\n或是填寫其他原因',textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 20.sp),),
                                actions: <Widget>[
                                  CupertinoDialogAction(
                                    child: Text('好的',textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 20.sp),),
                                    onPressed: () {
                                      Navigator.of(context).pop(); // 關閉 dialog
                                    },
                                  ),
                                ],
                              );
                            },
                          );

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
                                          title: Text('確定上傳?', maxLines: 2,
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
                                              child: Text('上傳',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                if(type=="寫入全班"){
                                                  add_all_DAILY_MT_db_sub2();
                                                }
                                                else{
                                                  add_DAILY_MT_db_sub2();
                                                }
                                              },
                                            ),

                                          ],
                                        );
                                      }));
                            });

                      },
                      child: Text("上傳", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp))),
                  Container(width: 20.w,),
                ],
                title: Text("新增${DAILY_MT_TYPE_ITEMs.firstWhere((e)=>e.ITEM_NO=="CND").ITEM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
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
                Expanded(flex:3,child: rg.RadioGroup(
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
                  onChanged: (newValue){

                    if("${newValue}"=="是"){
                      is_NORMAL = true;
                    }
                    else{
                      is_NORMAL = false;
                    }
                    setState(() {

                    });
                  },
                )),
              ],),
              Container(height: 15.h,),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

              Opacity(
                opacity: is_NORMAL!?0.4:1.0,
                child: IgnorePointer(
                  ignoring: is_NORMAL!,
                  child: Column(children: [
                    Container(height: 15.h,),
                    Row(children: [
                      Container(width: 10.w,),
                      Expanded(child:Text("發燒:",style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Color(0xff292929)))),
                      Expanded(flex:3,child: rg.RadioGroup(
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
                        onChanged: (newValue){

                          if("${newValue}"=="是"){
                            is_FEVER = true;
                          }
                          else{
                            is_FEVER = false;
                          }
                          setState(() {

                          });
                        },
                      )),
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
                            )),


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
                        width:ScreenUtil().screenWidth,child: Form(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Color(0xff555555),
                          ),
                          controller: FEVER_NOTE_textEditingController,
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
                    Container(height: 15.h,),
                    Row(children: [
                      Container(width: 10.w,),
                      Container(
                          margin: EdgeInsets.only(right: 5.w),
                          padding: EdgeInsets.only( left:0.w,right: 0.w),
                          width: 90.w,
                          height: 40.h,
                          child: PopupMenuButton<String>(
                              onSelected: (value) {
                                dev.log('你選了 $value');
                                FEVER_NOTE_textEditingController.text = value;
                                setState(() {

                                });
                              },
                              itemBuilder: (BuildContext context) => sel_teacher_Daily_language_menu.menu[1].contants.map((e)=>PopupMenuItem<String>(
                                  value: '${e}',
                                  child: Column(children: [
                                    Row(children: [
                                      Expanded(child:
                                      Text('${e}',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 12.sp,color: Colors.black),)),
                                    ],),
                                    Container(height: 5.h,),
                                    Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.black54,),
                                    Container(height: 5.h,),
                                  ],)
                              ),).toList(),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Color(0xffc0e088)),
                                    surfaceTintColor: MaterialStateProperty.all(Color(0xffc0e088)),
                                    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14.w),
                                            side: BorderSide(color: Color(0xff555555))
                                        )
                                    )
                                ),
                                onPressed: (sel_teacher_Daily_language_menu.menu[1].contants.isEmpty)?(){

                                  Fluttertoast.showToast(
                                      msg: "請先新增常用片語",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );

                                }:null,
                                child: Row(children: [
                                  Expanded(child: Container()),
                                  Text('常用片語', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.black , fontSize: 16.sp)),
                                  Expanded(child: Container()),
                                ],),
                              ))),
                      Expanded(child: Container()),

                    ]),
                    Container(height: 15.h,),
                    Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                    //鼻塞
                    Container(height: 15.h,),
                    Row(children: [
                      Container(width: 10.w,),
                      Expanded(child:Text("鼻塞:",style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Color(0xff292929)))),
                      Expanded(flex:3,child: rg.RadioGroup(
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
                        onChanged: (newValue){

                          if("${newValue}"=="是"){
                            is_NASAL = true;
                          }
                          else{
                            is_NASAL = false;
                          }
                          setState(() {

                          });
                        },
                      )),
                    ],),
                    Row(children: [
                      Container(width: 10.w,),
                      Expanded(child:Text("鼻塞:",style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Color(0xff292929)))),
                      Expanded(flex:3,child: Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                        child: (DAILY_CND_NASAL_STATUS_ITEMs.isEmpty || sel_DAILY_CND_NASAL_STATUS_ITEM.ITEM_NO.isEmpty)?Container():DropdownButton2<DAILY_CND_NASAL_STATUS_ITEM>(
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
                        ),
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
                        width:ScreenUtil().screenWidth,child: Form(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Color(0xff555555),
                          ),
                          controller: NASAL_NOTE_textEditingController,
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
                    Container(height: 15.h,),
                    Row(children: [
                      Container(width: 10.w,),
                      Container(
                          margin: EdgeInsets.only(right: 5.w),
                          padding: EdgeInsets.only( left:0.w,right: 0.w),
                          width: 90.w,
                          height: 40.h,
                          child: PopupMenuButton<String>(
                              onSelected: (value) {
                                dev.log('你選了 $value');
                                NASAL_NOTE_textEditingController.text = value;
                                setState(() {

                                });
                              },
                              itemBuilder: (BuildContext context) => sel_teacher_Daily_language_menu.menu[1].contants.map((e)=>PopupMenuItem<String>(
                                  value: '${e}',
                                  child: Column(children: [
                                    Row(children: [
                                      Expanded(child:
                                      Text('${e}',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 12.sp,color: Colors.black),)),
                                    ],),
                                    Container(height: 5.h,),
                                    Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.black54,),
                                    Container(height: 5.h,),
                                  ],)
                              ),).toList(),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Color(0xffc0e088)),
                                    surfaceTintColor: MaterialStateProperty.all(Color(0xffc0e088)),
                                    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14.w),
                                            side: BorderSide(color: Color(0xff555555))
                                        )
                                    )
                                ),
                                onPressed: (sel_teacher_Daily_language_menu.menu[1].contants.isEmpty)?(){

                                  Fluttertoast.showToast(
                                      msg: "請先新增常用片語",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );

                                }:null,
                                child: Row(children: [
                                  Expanded(child: Container()),
                                  Text('常用片語', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.black , fontSize: 16.sp)),
                                  Expanded(child: Container()),
                                ],),
                              ))),
                      Expanded(child: Container()),

                    ]),
                    Container(height: 15.h,),
                    Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                    //流鼻涕
                    Container(height: 15.h,),
                    Row(children: [
                      Container(width: 10.w,),
                      Expanded(child:Text("流鼻涕:",style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Color(0xff292929)))),
                      Expanded(flex:3,child: rg.RadioGroup(
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
                        onChanged: (newValue){

                          if("${newValue}"=="是"){
                            is_RUNNY_NOSE = true;
                          }
                          else{
                            is_RUNNY_NOSE = false;
                          }
                          setState(() {

                          });
                        },
                      )),
                    ],),
                    Row(children: [
                      Container(width: 10.w,),
                      Expanded(child:Text("流鼻涕顏色:",style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          color: Color(0xff292929)))),
                      Expanded(flex:3,child: Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                        child: (DAILY_CND_RUNNY_COLOR_ITEMs.isEmpty || sel_DAILY_CND_RUNNY_COLOR_ITEM.ITEM_NO.isEmpty)?Container():DropdownButton2<DAILY_CND_RUNNY_COLOR_ITEM>(
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
                        ),
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
                        child: (DAILY_CND_RUNNY_TYPE_ITEMs.isEmpty || sel_DAILY_CND_RUNNY_TYPE_ITEM.ITEM_NO.isEmpty)?Container():DropdownButton2<DAILY_CND_RUNNY_TYPE_ITEM>(
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
                        ),
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
                        child: (DAILY_CND_RUNNY_QUANTITY_ITEMs.isEmpty || sel_DAILY_CND_RUNNY_QUANTITY_ITEM.ITEM_NO.isEmpty)?Container():DropdownButton2<DAILY_CND_RUNNY_QUANTITY_ITEM>(
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
                        ),
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
                        width:ScreenUtil().screenWidth,child: Form(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Color(0xff555555),
                          ),
                          controller: RUNNY_NOSE_NOTE_textEditingController,
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
                    Container(height: 15.h,),
                    Row(children: [
                      Container(width: 10.w,),
                      Container(
                          margin: EdgeInsets.only(right: 5.w),
                          padding: EdgeInsets.only( left:0.w,right: 0.w),
                          width: 90.w,
                          height: 40.h,
                          child: PopupMenuButton<String>(
                              onSelected: (value) {
                                dev.log('你選了 $value');
                                RUNNY_NOSE_NOTE_textEditingController.text = value;
                                setState(() {

                                });
                              },
                              itemBuilder: (BuildContext context) => sel_teacher_Daily_language_menu.menu[1].contants.map((e)=>PopupMenuItem<String>(
                                  value: '${e}',
                                  child: Column(children: [
                                    Row(children: [
                                      Expanded(child:
                                      Text('${e}',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 12.sp,color: Colors.black),)),
                                    ],),
                                    Container(height: 5.h,),
                                    Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.black54,),
                                    Container(height: 5.h,),
                                  ],)
                              ),).toList(),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Color(0xffc0e088)),
                                    surfaceTintColor: MaterialStateProperty.all(Color(0xffc0e088)),
                                    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14.w),
                                            side: BorderSide(color: Color(0xff555555))
                                        )
                                    )
                                ),
                                onPressed: (sel_teacher_Daily_language_menu.menu[1].contants.isEmpty)?(){

                                  Fluttertoast.showToast(
                                      msg: "請先新增常用片語",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );

                                }:null,
                                child: Row(children: [
                                  Expanded(child: Container()),
                                  Text('常用片語', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.black , fontSize: 16.sp)),
                                  Expanded(child: Container()),
                                ],),
                              ))),
                      Expanded(child: Container()),

                    ]),
                    Container(height: 15.h,),
                    Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                    //咳嗽
                    Container(height: 15.h,),
                    Row(children: [
                      Container(width: 10.w,),
                      Expanded(child:Text("咳嗽:",style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Color(0xff292929)))),
                      Expanded(flex:3,child: rg.RadioGroup(
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
                        onChanged: (newValue){

                          if("${newValue}"=="是"){
                            is_COUGH = true;
                          }
                          else{
                            is_COUGH = false;
                          }
                          setState(() {

                          });
                        },
                      )),
                    ],),
                    Row(children: [
                      Container(width: 10.w,),
                      Expanded(child:Text("咳嗽程度:",style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          color: Color(0xff292929)))),
                      Expanded(flex:3,child: Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                        child: (DAILY_CND_COUGH_LEVEL_ITEMs.isEmpty || sel_DAILY_CND_COUGH_LEVEL_ITEM.ITEM_NO.isEmpty)?Container():DropdownButton2<DAILY_CND_COUGH_LEVEL_ITEM>(
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
                        ),
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
                        child: (DAILY_CND_COUGH_TIME_ITEMs.isEmpty || sel_DAILY_CND_COUGH_TIME_ITEM.ITEM_NO.isEmpty)?Container():DropdownButton2<DAILY_CND_COUGH_TIME_ITEM>(
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
                        ),
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
                        width:ScreenUtil().screenWidth,child: Form(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Color(0xff555555),
                          ),
                          controller: COUGH_NOTE_textEditingController,
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
                    Container(height: 15.h,),
                    Row(children: [
                      Container(width: 10.w,),
                      Container(
                          margin: EdgeInsets.only(right: 5.w),
                          padding: EdgeInsets.only( left:0.w,right: 0.w),
                          width: 90.w,
                          height: 40.h,
                          child: PopupMenuButton<String>(
                              onSelected: (value) {
                                dev.log('你選了 $value');
                                COUGH_NOTE_textEditingController.text = value;
                                setState(() {

                                });
                              },
                              itemBuilder: (BuildContext context) => sel_teacher_Daily_language_menu.menu[1].contants.map((e)=>PopupMenuItem<String>(
                                  value: '${e}',
                                  child: Column(children: [
                                    Row(children: [
                                      Expanded(child:
                                      Text('${e}',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 12.sp,color: Colors.black),)),
                                    ],),
                                    Container(height: 5.h,),
                                    Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.black54,),
                                    Container(height: 5.h,),
                                  ],)
                              ),).toList(),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Color(0xffc0e088)),
                                    surfaceTintColor: MaterialStateProperty.all(Color(0xffc0e088)),
                                    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14.w),
                                            side: BorderSide(color: Color(0xff555555))
                                        )
                                    )
                                ),
                                onPressed: (sel_teacher_Daily_language_menu.menu[1].contants.isEmpty)?(){

                                  Fluttertoast.showToast(
                                      msg: "請先新增常用片語",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );

                                }:null,
                                child: Row(children: [
                                  Expanded(child: Container()),
                                  Text('常用片語', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.black , fontSize: 16.sp)),
                                  Expanded(child: Container()),
                                ],),
                              ))),
                      Expanded(child: Container()),

                    ]),
                    Container(height: 15.h,),
                    Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                    //嘔吐
                    Container(height: 15.h,),
                    Row(children: [
                      Container(width: 10.w,),
                      Expanded(child:Text("嘔吐:",style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Color(0xff292929)))),
                      Expanded(flex:3,child: rg.RadioGroup(
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
                        onChanged: (newValue){

                          if("${newValue}"=="是"){
                            is_VOMIT = true;
                          }
                          else{
                            is_VOMIT = false;
                          }
                          setState(() {

                          });
                        },
                      )),
                    ],),
                    Container(height: 15.h,),
                    Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                    //腹瀉
                    Container(height: 15.h,),
                    Row(children: [
                      Container(width: 10.w,),
                      Expanded(child:Text("腹瀉:",style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Color(0xff292929)))),
                      Expanded(flex:3,child: rg.RadioGroup(
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
                        onChanged: (newValue){

                          if("${newValue}"=="是"){
                            is_DIARRHEA = true;
                          }
                          else{
                            is_DIARRHEA = false;
                          }
                          setState(() {

                          });
                        },
                      )),
                    ],),
                    Container(height: 15.h,),
                    Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                    //手足口病
                    Container(height: 15.h,),
                    Row(children: [
                      Container(width: 10.w,),
                      Expanded(child:Text("手足口病:",style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Color(0xff292929)))),
                      Expanded(flex:3,child: rg.RadioGroup(
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
                        onChanged: (newValue){

                          if("${newValue}"=="是"){
                            is_HFMD = true;
                          }
                          else{
                            is_HFMD = false;
                          }
                          setState(() {

                          });
                        },
                      )),
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
                        child: (DAILY_CND_HFMD_TYPE_ITEMs.isEmpty || sel_DAILY_CND_HFMD_TYPE_ITEM.ITEM_NO.isEmpty)?Container():DropdownButton2<DAILY_CND_HFMD_TYPE_ITEM>(
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
                        ),
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
                        width:ScreenUtil().screenWidth,child: Form(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Color(0xff555555),
                          ),
                          controller: HFMD_NOTE_textEditingController,
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
                    Container(height: 15.h,),
                    Row(children: [
                      Container(width: 10.w,),
                      Container(
                          margin: EdgeInsets.only(right: 5.w),
                          padding: EdgeInsets.only( left:0.w,right: 0.w),
                          width: 90.w,
                          height: 40.h,
                          child: PopupMenuButton<String>(
                              onSelected: (value) {
                                dev.log('你選了 $value');
                                HFMD_NOTE_textEditingController.text = value;
                                setState(() {

                                });
                              },
                              itemBuilder: (BuildContext context) => sel_teacher_Daily_language_menu.menu[1].contants.map((e)=>PopupMenuItem<String>(
                                  value: '${e}',
                                  child: Column(children: [
                                    Row(children: [
                                      Expanded(child:
                                      Text('${e}',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 12.sp,color: Colors.black),)),
                                    ],),
                                    Container(height: 5.h,),
                                    Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.black54,),
                                    Container(height: 5.h,),
                                  ],)
                              ),).toList(),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(Color(0xffc0e088)),
                                    surfaceTintColor: MaterialStateProperty.all(Color(0xffc0e088)),
                                    padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14.w),
                                            side: BorderSide(color: Color(0xff555555))
                                        )
                                    )
                                ),
                                onPressed: (sel_teacher_Daily_language_menu.menu[1].contants.isEmpty)?(){

                                  Fluttertoast.showToast(
                                      msg: "請先新增常用片語",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0
                                  );

                                }:null,
                                child: Row(children: [
                                  Expanded(child: Container()),
                                  Text('常用片語', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.black , fontSize: 16.sp)),
                                  Expanded(child: Container()),
                                ],),
                              ))),
                      Expanded(child: Container()),

                    ]),
                    Container(height: 15.h,),
                    Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),


                  ],),
                ),
              ),





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
                  width:ScreenUtil().screenWidth,child: Form(
                  child: TextFormField(
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Color(0xff555555),
                    ),
                    controller: OTHER_textEditingController,
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

              Container(height: 15.h,),
              GestureDetector(
              onTap: (){
                /*
                DAILY_PIC_DL b = DAILY_PIC_DL();
                DAILY_PIC_DLs.insert(0,b);
                setState(() {

                });
                Future.delayed(const Duration(milliseconds: 100), () {

                  listScrollController.animateTo(
                      listScrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 1),
                      curve: Curves.fastOutSlowIn);

                });

                 */


                showModalBottomSheet(
                    context: context,
                    builder: (
                        BuildContext context) {
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
                                final myAppPath = '$tempDirPath/威寶通/Daily';
                                final res = await Directory(myAppPath).create(recursive: true);
                                String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                //var decodedImage = await imageFile.readAsBytes();
                                //print(decodedImage.length);

                                DAILY_PIC_DL b = DAILY_PIC_DL();
                                DAILY_PIC_DLs.insert(0,b);

                                //壓縮image
                                DAILY_PIC_DLs[0].prescriptionsbytes_xfile = await FlutterImageCompress.compressAndGetFile(
                                  imageFile.path, filePath,
                                  minWidth: FlutterImageCompress_width,
                                  minHeight: FlutterImageCompress_height,
                                  quality: blogFlutterImageCompress_quality,
                                  rotate: 0,
                                );

                                //var decodedImage2 = File(filePath).readAsBytesSync();
                                //print(decodedImage2.length);

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

                                    List<PlatformFile> result = await FilePicker.pickFiles(
                                      //allowMultiple: true,
                                      type: FileType.image,
                                      //allowedExtensions: (Platform.isIOS)?null:['jpg','png','jpeg'],
                                    );

                                    if(result==null){
                                      return;
                                    }

                                    // 確保過濾掉可能為 null 的 path（例如 Web 端或未提供本地路徑時）
                                    List<File> listImagePaths = result
                                        .where((file) => file.path != null)
                                        .map((file) => File(file.path!))
                                        .toList();

                                    dev.log("listImagePaths.length:${listImagePaths.length}");
                                    for(int i=0;i<listImagePaths.length;i++){
                                      DAILY_PIC_DL b = DAILY_PIC_DL();
                                      DAILY_PIC_DLs.insert(0,b);

                                      DateTime t = DateTime.now();
                                      Directory tempDir = await getTemporaryDirectory();
                                      var tempDirPath = tempDir.path;
                                      final myAppPath = '$tempDirPath/威寶通/Daily';
                                      final res = await Directory(myAppPath).create(recursive: true);
                                      String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                      //String? path2 = await LecleFlutterAbsolutePath.getAbsolutePath(uri:images[i].identifier);
                                      //壓縮image
                                      DAILY_PIC_DLs[0].prescriptionsbytes_xfile = await FlutterImageCompress
                                          .compressAndGetFile(
                                        listImagePaths[i].path!, filePath,
                                        minWidth: FlutterImageCompress_width,
                                        minHeight: FlutterImageCompress_height,
                                        quality: blogFlutterImageCompress_quality,
                                        rotate: 0,
                                      );

                                    }
                                    setState(() {

                                    });

                                    /*
                                    var imageFile = await ImagePicker.ImagePicker().pickImage(
                                        source: ImagePicker.ImageSource.gallery);

                                    if (imageFile != null) {
                                      //print(
                                      //    "imageFile.lengthSync1():${imageFile
                                      //        .lengthSync()}");

                                      DateTime t = DateTime.now();
                                      Directory tempDir = await getTemporaryDirectory();
                                      var tempDirPath = tempDir.path;
                                      final myAppPath = '$tempDirPath/威寶通/Daily';
                                      final res = await Directory(myAppPath).create(recursive: true);
                                      String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                      //壓縮image
                                      e.prescriptionsbytes_xfile = await FlutterImageCompress
                                          .compressAndGetFile(
                                        imageFile.path, filePath,
                                        quality: 20,
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

                                     */

                                  }
                                  else {
                                    return;
                                  }

                                }
                                else{
                                  //print("相簿-2");

                                  List<PlatformFile> result = await FilePicker.pickFiles(
                                    //allowMultiple: true,
                                    type: FileType.image,
                                    //allowedExtensions: (Platform.isIOS)?null:['jpg','png','jpeg'],
                                  );

                                  if(result==null){
                                    return;
                                  }

                                  // 確保過濾掉可能為 null 的 path（例如 Web 端或未提供本地路徑時）
                                  List<File> listImagePaths = result
                                      .where((file) => file.path != null)
                                      .map((file) => File(file.path!))
                                      .toList();

                                  dev.log("listImagePaths.length:${listImagePaths.length}");
                                  for(int i=0;i<listImagePaths.length;i++){
                                    DAILY_PIC_DL b = DAILY_PIC_DL();
                                    DAILY_PIC_DLs.insert(0,b);

                                    DateTime t = DateTime.now();
                                    Directory tempDir = await getTemporaryDirectory();
                                    var tempDirPath = tempDir.path;
                                    final myAppPath = '$tempDirPath/威寶通/Daily';
                                    final res = await Directory(myAppPath).create(recursive: true);
                                    String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                    //String? path2 = await LecleFlutterAbsolutePath.getAbsolutePath(uri:images[i].identifier);
                                    //壓縮image
                                    DAILY_PIC_DLs[0].prescriptionsbytes_xfile = await FlutterImageCompress
                                        .compressAndGetFile(
                                      listImagePaths[i].path!, filePath,
                                      minWidth: FlutterImageCompress_width,
                                      minHeight: FlutterImageCompress_height,
                                      quality: blogFlutterImageCompress_quality,
                                      rotate: 0,
                                    );

                                  }
                                  setState(() {

                                  });

                                  /*
                                  var imageFile = await ImagePicker.ImagePicker().pickImage(
                                      source: ImagePicker.ImageSource.gallery);

                                  if (imageFile !=
                                      null) {
                                    //print(
                                    //    "imageFile.lengthSync1():${imageFile
                                    //        .lengthSync()}");

                                    DateTime t = DateTime.now();
                                    Directory tempDir = await getTemporaryDirectory();
                                    var tempDirPath = tempDir.path;
                                    final myAppPath = '$tempDirPath/威寶通/Daily';
                                    final res = await Directory(myAppPath).create(recursive: true);
                                    String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                    //壓縮image
                                    e.prescriptionsbytes_xfile = await FlutterImageCompress
                                        .compressAndGetFile(
                                      imageFile.path, filePath,
                                      quality: 20,
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

                                   */
                                }




                              }
                              else {

                                /*
                                List<Media>? listImagePaths = await ImagePickers.pickerPaths(
                                    galleryMode: GalleryMode.image,
                                    selectCount: 15,
                                    showGif: false,
                                    showCamera: true,
                                    compressSize: 500,
                                    uiConfig: UIConfig(uiThemeColor: Color(0xffff0f50)),
                                    cropConfig: CropConfig(enableCrop: false, width: 2, height: 1));

                                 */

                                List<PlatformFile> result = await FilePicker.pickFiles(
                                  allowMultiple: true,
                                  type: FileType.image,
                                  //allowedExtensions: (Platform.isIOS)?null:['jpg','png','jpeg'],
                                );

                                if(result==null){
                                  return;
                                }

                                // 確保過濾掉可能為 null 的 path（例如 Web 端或未提供本地路徑時）
                                List<File> listImagePaths = result
                                    .where((file) => file.path != null)
                                    .map((file) => File(file.path!))
                                    .toList();


                                dev.log("listImagePaths.length:${listImagePaths.length}");
                                for(int i=0;i<listImagePaths.length;i++){
                                  DAILY_PIC_DL b = DAILY_PIC_DL();
                                  DAILY_PIC_DLs.insert(0,b);

                                  DateTime t = DateTime.now();
                                  Directory tempDir = await getTemporaryDirectory();
                                  var tempDirPath = tempDir.path;
                                  final myAppPath = '$tempDirPath/威寶通/Daily';
                                  final res = await Directory(myAppPath).create(recursive: true);
                                  String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                  //String? path2 = await LecleFlutterAbsolutePath.getAbsolutePath(uri:images[i].identifier);
                                  //壓縮image
                                  DAILY_PIC_DLs[0].prescriptionsbytes_xfile = await FlutterImageCompress
                                      .compressAndGetFile(
                                    listImagePaths[i].path!, filePath,
                                    minWidth: FlutterImageCompress_width,
                                    minHeight: FlutterImageCompress_height,
                                    quality: blogFlutterImageCompress_quality,
                                    rotate: 0,
                                  );

                                }
                                setState(() {

                                });

                                /*
                                var imageFile = await ImagePicker.ImagePicker().pickImage(
                                    source: ImagePicker.ImageSource
                                        .gallery);

                                if (imageFile !=
                                    null) {
                                  //print(
                                  //    "imageFile.lengthSync1():${imageFile
                                  //        .lengthSync()}");

                                  DateTime t = DateTime.now();
                                  Directory tempDir = await getTemporaryDirectory();
                                  var tempDirPath = tempDir.path;
                                  final myAppPath = '$tempDirPath/威寶通/Daily';
                                  final res = await Directory(myAppPath).create(recursive: true);
                                  String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                  //壓縮image
                                  e.prescriptionsbytes_xfile = await FlutterImageCompress
                                      .compressAndGetFile(
                                    imageFile.path, filePath,
                                    quality: 20,
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

                                 */



                              }


                            },
                          ),
                        ],
                      );
                    });

              },
              child:Container(color: Color(0x01000000),child:
              Row(children: [
                    Container(width: 10.w,),
                    Container(
                        margin: EdgeInsets.only(right: 5.w),
                        padding: EdgeInsets.only( left:0.w,right: 0.w),
                        width: 90.w,
                        height: 40.h,
                        child: PopupMenuButton<String>(
                            onSelected: (value) {
                              dev.log('你選了 $value');
                              OTHER_textEditingController.text = value;
                              setState(() {

                              });
                            },
                            itemBuilder: (BuildContext context) => sel_teacher_Daily_language_menu.menu[1].contants.map((e)=>PopupMenuItem<String>(
                                value: '${e}',
                                child: Column(children: [
                                  Row(children: [
                                    Expanded(child:
                                    Text('${e}',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 12.sp,color: Colors.black),)),
                                  ],),
                                  Container(height: 5.h,),
                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.black54,),
                                  Container(height: 5.h,),
                                ],)
                            ),).toList(),
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(Color(0xffc0e088)),
                                  surfaceTintColor: MaterialStateProperty.all(Color(0xffc0e088)),
                                  padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14.w),
                                          side: BorderSide(color: Color(0xff555555))
                                      )
                                  )
                              ),
                              onPressed: (sel_teacher_Daily_language_menu.menu[1].contants.isEmpty)?(){

                                Fluttertoast.showToast(
                                    msg: "請先新增常用片語",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0
                                );

                              }:null,
                              child: Row(children: [
                                Expanded(child: Container()),
                                Text('常用片語', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.black , fontSize: 16.sp)),
                                Expanded(child: Container()),
                              ],),
                            ))),
                    Expanded(child: Container()),
                    Container(child:Text("新增照片",style: TextStyle(color: Colors.black,fontSize: 16.sp),)),
                    Icon(Icons.add_circle_outline,size: 24.sp,),
                    Container(width: 10.w,),
                  ],))),
              Container(height: 15.h,),
              Column(children: DAILY_PIC_DLs.map((e){
                return badges.Badge(
                       onTap: () {


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
                                               onPressed: () {
                                                 Navigator.of(context).pop();

                                               },
                                             ),


                                             TextButton(
                                               child: Text('刪除',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                               onPressed: () {
                                                 Navigator.of(context).pop();

                                                 DAILY_PIC_DLs.remove(e);
                                                 setState(() {

                                                 });
                                               },
                                             ),

                                           ],
                                         );
                                       }));
                             });


                       },
                       position: badges.BadgePosition.topEnd(top: 0, end: 10.w),
                       badgeContent: Icon(Icons.cancel,color: Colors.red,size: 24.sp,),
                        badgeStyle: badges.BadgeStyle(
                          badgeColor: Colors.white,
                          padding: EdgeInsets.all(0.w),
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.white, width: 1),
                          elevation: 0,
                        ),
                       child: Container(
                      margin: EdgeInsets.only(left:8.w,right: 8.w,top: 5.h,bottom: 5.h),
                      width: ScreenUtil().screenWidth,child:  GestureDetector(
                           onTap:(){
                             showModalBottomSheet(
                                 context: context,
                                 builder: (
                                     BuildContext context) {
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
                                             final myAppPath = '$tempDirPath/威寶通/Daily';
                                             final res = await Directory(myAppPath).create(recursive: true);
                                             String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                             //var decodedImage = await imageFile.readAsBytes();
                                             //print(decodedImage.length);

                                             //壓縮image
                                             e.prescriptionsbytes_xfile = await FlutterImageCompress.compressAndGetFile(
                                               imageFile.path, filePath,
                                               minWidth: FlutterImageCompress_width,
                                               minHeight: FlutterImageCompress_height,
                                               quality: blogFlutterImageCompress_quality,
                                               rotate: 0,
                                             );

                                             //var decodedImage2 = File(filePath).readAsBytesSync();
                                             //print(decodedImage2.length);

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
                                                   final myAppPath = '$tempDirPath/威寶通/Daily';
                                                   final res = await Directory(myAppPath).create(recursive: true);
                                                   String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                                   //壓縮image
                                                   e.prescriptionsbytes_xfile = await FlutterImageCompress
                                                       .compressAndGetFile(
                                                     imageFile.path, filePath,
                                                     minWidth: FlutterImageCompress_width,
                                                     minHeight: FlutterImageCompress_height,
                                                     quality: blogFlutterImageCompress_quality,
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
                                                 final myAppPath = '$tempDirPath/威寶通/Daily';
                                                 final res = await Directory(myAppPath).create(recursive: true);
                                                 String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                                 //壓縮image
                                                 e.prescriptionsbytes_xfile = await FlutterImageCompress
                                                     .compressAndGetFile(
                                                   imageFile.path, filePath,
                                                   minWidth: FlutterImageCompress_width,
                                                   minHeight: FlutterImageCompress_height,
                                                   quality: blogFlutterImageCompress_quality,
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

                                             /*
                                             var imageFile = await ImagePicker.ImagePicker().pickImage(
                                                 source: ImagePicker.ImageSource
                                                     .gallery);

                                              */

                                             PlatformFile? result = await FilePicker.pickFile(
                                               //allowMultiple: false,
                                               type: FileType.image,
                                               //allowedExtensions: (Platform.isIOS)?null:['jpg','png','jpeg'],
                                             );

                                             if(result==null){
                                               return;
                                             }

                                             var imageFile = result.xFile;

                                             if (imageFile != null) {
                                               //print(
                                               //    "imageFile.lengthSync1():${imageFile
                                               //        .lengthSync()}");

                                               DateTime t = DateTime.now();
                                               Directory tempDir = await getTemporaryDirectory();
                                               var tempDirPath = tempDir.path;
                                               final myAppPath = '$tempDirPath/威寶通/Daily';
                                               final res = await Directory(myAppPath).create(recursive: true);
                                               String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                               //壓縮image
                                               e.prescriptionsbytes_xfile = await FlutterImageCompress
                                                   .compressAndGetFile(
                                                 imageFile.path, filePath,
                                                 minWidth: FlutterImageCompress_width,
                                                 minHeight: FlutterImageCompress_height,
                                                 quality: blogFlutterImageCompress_quality,
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


                                         },
                                       ),
                                     ],
                                   );
                                 });
                           },
                           child: Container(width: ScreenUtil().screenWidth,height: 200.h,color: Colors.grey,child:
                           Center(child:(e.prescriptionsbytes_xfile==null)?
                           Icon(Icons.camera_alt,color: Colors.white,size: 60.sp)
                               :
                           Image.file(File(e.prescriptionsbytes_xfile!.path))
                           ))),),);
              }).toList(),),


            ],),
        )));
  }
}
