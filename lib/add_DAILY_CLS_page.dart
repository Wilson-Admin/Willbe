import 'dart:convert';
import 'dart:io';
import 'package:code3/main2_T.dart';
import 'package:code3/signature2.dart';
import 'package:code3/signature4.dart';
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

class ADD_DAILY_CLS_page extends StatefulWidget {

  String type = "";
  DateTime dateTime = DateTime.now();
  ADD_DAILY_CLS_page({String type="",DateTime? dateTime}){
    this.type = type;
    this.dateTime = dateTime!;
  }

  @override
  State<ADD_DAILY_CLS_page> createState() => ADD_DAILY_CLS_pageState(type:this.type,dateTime:this.dateTime);
}

class ADD_DAILY_CLS_pageState extends State<ADD_DAILY_CLS_page> {

  TextEditingController OTHER_textEditingController = TextEditingController();//

  DateTime dateTime = DateTime.now();
  TimeOfDay? timeOfDay;
  var showModalBottomSheet_image_context;

  List<DAILY_PIC_DL> DAILY_PIC_DLs = [];//[托嬰]便便 子表

  bool? is_WETTING;//尿濕
  bool? is_GET_WET;//弄濕
  bool? is_GOT_SHIT;//沾到大便
  bool? is_WEATHER;//天氣變化
  bool? is_BATH;//洗澡
  bool? is_GET_BACK;//從診所回中心
  bool? is_OUT_DOOR;//戶外活動
  rg.RadioGroupController is_WETTING_radioGroup_controller = rg.RadioGroupController();
  rg.RadioGroupController is_GET_WET_radioGroup_controller = rg.RadioGroupController();
  rg.RadioGroupController is_GOT_SHIT_radioGroup_controller = rg.RadioGroupController();
  rg.RadioGroupController is_SOUR_radioGroup_controller = rg.RadioGroupController();
  rg.RadioGroupController is_WEATHER_radioGroup_controller = rg.RadioGroupController();
  rg.RadioGroupController is_BATH_radioGroup_controller = rg.RadioGroupController();
  rg.RadioGroupController is_GET_BACK_radioGroup_controller = rg.RadioGroupController();
  rg.RadioGroupController is_OUT_DOOR_radioGroup_controller = rg.RadioGroupController();

  ScrollController listScrollController = ScrollController();

  String type = "";
  ADD_DAILY_CLS_pageState({String type="",DateTime? dateTime}){
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
    String TYPE = "CLS";
    int cUSTOMERs_length = _cUSTOMERs.length;

    dev.log("datetime:(${datetime})");

    String MARK = "";
    if(is_WETTING==true){
      MARK="尿濕";
    }
    if(is_GET_WET==true){
      MARK="${MARK}/弄濕";
    }
    if(is_GOT_SHIT==true){
      MARK="${MARK}/沾到大便";
    }
    if(is_WEATHER==true){
      MARK="${MARK}/天氣變化";
    }
    if(is_BATH==true){
      MARK="${MARK}/洗澡";
    }
    if(is_GET_BACK==true){
      MARK="${MARK}/從診所回中心";
    }
    if(is_OUT_DOOR==true){
      MARK="${MARK}/戶外活動";
    }
    if(OTHER_textEditingController.text.isNotEmpty){
      MARK="${MARK}\n${OTHER_textEditingController.text}";
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
DECLARE @WETTING BIT = '${is_WETTING==null?"0":is_WETTING!?"1":"0"}';
DECLARE @GET_WET BIT = '${is_GET_WET==null?"0":is_GET_WET!?"1":"0"}';
DECLARE @GOT_SHIT BIT = '${is_GOT_SHIT==null?"0":is_GOT_SHIT!?"1":"0"}';
DECLARE @WEATHER BIT = '${is_WEATHER==null?"0":is_WEATHER!?"1":"0"}';
DECLARE @BATH BIT = '${is_BATH==null?"0":is_BATH!?"1":"0"}';
DECLARE @GET_BACK BIT = '${is_GET_BACK==null?"0":is_GET_BACK!?"1":"0"}';
DECLARE @OUT_DOOR BIT = '${is_OUT_DOOR==null?"0":is_OUT_DOOR!?"1":"0"}';

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

-- 8. 寫入 DAILY_CLS（備註）
INSERT INTO DAILY_CLS (TYPE, NO,WETTING,GET_WET,GOT_SHIT,WEATHER,BATH,GET_BACK,OUT_DOOR, OTHER)
SELECT @Type, NO,@WETTING,@GET_WET,@GOT_SHIT,@WEATHER,@BATH,@GET_BACK,@OUT_DOOR, @OTHER
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
    dev.log("全班寫入更換衣物(回應):${result}");

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
        //Student_T_page_fun!(action:"新增更換衣物成功");
        DAILY_PIC_DLs.clear();
        OTHER_textEditingController.text="";
        //dateTime=null;
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
        TYPE:"CLS",
        NO:View_DAILY_NO,//編號
        DATE:"${DateFormat('yyyy-MM-dd').format(dateTime)}",//日期
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


      //更換衣物
      await insert_DAILY_CLS_db_sub(
        TYPE:"CLS",
        NO:View_DAILY_NO,//編號
        WETTING:is_WETTING==null?null:is_WETTING,//
        GET_WET:is_GET_WET==null?null:is_GET_WET,//
        GOT_SHIT:is_GOT_SHIT==null?null:is_GOT_SHIT,//
        WEATHER:is_WEATHER==null?null:is_WEATHER,//
        BATH:is_BATH==null?null:is_BATH,//
        GET_BACK:is_GET_BACK==null?null:is_GET_BACK,//
        OUT_DOOR:is_OUT_DOOR==null?null:is_OUT_DOOR,//
        OTHER:"${OTHER_textEditingController.text}",//
      );

      DateTime d = DateTime.now();

      /*
    更換衣物 子表
     */
      if(DAILY_PIC_DLs.length==0){
        await insert_DAILY_PIC_DL_db_sub(
          TYPE:"CLS",//
          NO:"${View_DAILY_NO}",
          SR:"${1}",
          LINK:"",//照片
        );
      }
      else{
        for(int i=0;i<DAILY_PIC_DLs.length;i++){


          if(DAILY_PIC_DLs[i].prescriptionsbytes_xfile!=null){
            await upload_image(image_path: DAILY_PIC_DLs[i].prescriptionsbytes_xfile!.path,file_name: "${View_DAILY_NO}_${i+1}_${d.microsecondsSinceEpoch}",folder: "Daily");
            await insert_DAILY_PIC_DL_db_sub(
              TYPE:"CLS",//
              NO:"${View_DAILY_NO}",
              SR:"${i+1}",
              LINK:(DAILY_PIC_DLs[i].prescriptionsbytes_xfile==null)?"":"~/School/Images/Daily/${View_DAILY_NO}_${i+1}_${d.microsecondsSinceEpoch}.jpg",//照片

            );
          }

        }
      }


    }

    SmartDialog.dismiss();
    SmartDialog.showToast("處理成功");
    //Student_T_page_fun!(action:"新增更換衣物成功");
    DAILY_PIC_DLs.clear();
    OTHER_textEditingController.text="";
    //dateTime=null;
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
    String TYPE = "CLS";
    int cUSTOMERs_length = _cUSTOMERs.length;

    dev.log("datetime:(${datetime})");


    String MARK = "";
    if(is_WETTING==true){
      MARK="尿濕";
    }
    if(is_GET_WET==true){
      MARK="${MARK}/弄濕";
    }
    if(is_GOT_SHIT==true){
      MARK="${MARK}/沾到大便";
    }
    if(is_WEATHER==true){
      MARK="${MARK}/天氣變化";
    }
    if(is_BATH==true){
      MARK="${MARK}/洗澡";
    }
    if(is_GET_BACK==true){
      MARK="${MARK}/從診所回中心";
    }
    if(is_OUT_DOOR==true){
      MARK="${MARK}/戶外活動";
    }
    if(OTHER_textEditingController.text.isNotEmpty){
      MARK="${MARK}\n${OTHER_textEditingController.text}";
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
DECLARE @WETTING BIT = '${is_WETTING==null?"0":is_WETTING!?"1":"0"}';
DECLARE @GET_WET BIT = '${is_GET_WET==null?"0":is_GET_WET!?"1":"0"}';
DECLARE @GOT_SHIT BIT = '${is_GOT_SHIT==null?"0":is_GOT_SHIT!?"1":"0"}';
DECLARE @WEATHER BIT = '${is_WEATHER==null?"0":is_WEATHER!?"1":"0"}';
DECLARE @BATH BIT = '${is_BATH==null?"0":is_BATH!?"1":"0"}';
DECLARE @GET_BACK BIT = '${is_GET_BACK==null?"0":is_GET_BACK!?"1":"0"}';
DECLARE @OUT_DOOR BIT = '${is_OUT_DOOR==null?"0":is_OUT_DOOR!?"1":"0"}';

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

-- 8. 寫入 DAILY_CLS（備註）
INSERT INTO DAILY_CLS (TYPE, NO,WETTING,GET_WET,GOT_SHIT,WEATHER,BATH,GET_BACK,OUT_DOOR, OTHER)
SELECT @Type, NO,@WETTING,@GET_WET,@GOT_SHIT,@WEATHER,@BATH,@GET_BACK,@OUT_DOOR, @OTHER
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
    dev.log("單個寫入更換衣物(回應):${result}");

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
        Student_T_page_fun!(action:"新增更換衣物成功");
        DAILY_PIC_DLs.clear();
        OTHER_textEditingController.text="";
        //dateTime=null;
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
        TYPE:"CLS",
        NO:View_DAILY_NO,//編號
        DATE:"${DateFormat('yyyy-MM-dd').format(dateTime)}",//日期
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


    //更換衣物
    await insert_DAILY_CLS_db_sub(
      TYPE:"CLS",
      NO:View_DAILY_NO,//編號
      WETTING:is_WETTING==null?false:is_WETTING,//
      GET_WET:is_GET_WET==null?false:is_GET_WET,//
      GOT_SHIT:is_GOT_SHIT==null?false:is_GOT_SHIT,//
      WEATHER:is_WEATHER==null?false:is_WEATHER,//
      BATH:is_BATH==null?false:is_BATH,//
      GET_BACK:is_GET_BACK==null?false:is_GET_BACK,//
      OUT_DOOR:is_OUT_DOOR==null?false:is_OUT_DOOR,//
      OTHER:"${OTHER_textEditingController.text}",//
    );

    DateTime d = DateTime.now();

    /*
    更換衣物 子表
     */
    if(DAILY_PIC_DLs.length==0){
      await insert_DAILY_PIC_DL_db_sub(
        TYPE:"CLS",//
        NO:"${View_DAILY_NO}",
        SR:"${1}",
        LINK:"",//照片
      );
    }
    else{
      for(int i=0;i<DAILY_PIC_DLs.length;i++){


        if(DAILY_PIC_DLs[i].prescriptionsbytes_xfile!=null){
          await upload_image(image_path: DAILY_PIC_DLs[i].prescriptionsbytes_xfile!.path,file_name: "${View_DAILY_NO}_${i+1}_${d.microsecondsSinceEpoch}",folder: "Daily");
          await insert_DAILY_PIC_DL_db_sub(
            TYPE:"CLS",//
            NO:"${View_DAILY_NO}",
            SR:"${i+1}",
            LINK:(DAILY_PIC_DLs[i].prescriptionsbytes_xfile==null)?"":"~/School/Images/Daily/${View_DAILY_NO}_${i+1}_${d.microsecondsSinceEpoch}.jpg",//照片

          );
        }

      }
    }


    SmartDialog.dismiss();
    SmartDialog.showToast("處理成功");
    Student_T_page_fun!(action:"新增更換衣物成功");
    DAILY_PIC_DLs.clear();
    OTHER_textEditingController.text="";
    //dateTime=null;
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
  Future<void> insert_DAILY_CLS_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        bool? WETTING,//尿濕
        bool? GET_WET,//弄濕
        bool? GOT_SHIT,//沾到大便
        bool? WEATHER,//天氣變化
        bool? BATH,//洗澡
        bool? GET_BACK,//從診所回中心
        bool? OUT_DOOR,//戶外活動
        String OTHER="",//其他
      })async{

    String comm = "INSERT INTO DAILY_CLS(TYPE,NO,WETTING,GET_WET,GOT_SHIT,WEATHER,BATH,GET_BACK,OUT_DOOR,OTHER) VALUES ('${TYPE}','${NO}','${WETTING}','${GET_WET}','${GOT_SHIT}','${WEATHER}','${BATH}','${GET_BACK}','${OUT_DOOR}','${OTHER}')";
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
    //String comm = "SELECT * FROM DAILY_MT WHERE TYPE='CLS' AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";
    String comm = '''SELECT *
    FROM DAILY_MT
    WHERE TYPE = 'CLS'
      AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'
      AND NO = (
        SELECT MAX(NO)
        FROM DAILY_MT
        WHERE TYPE = 'CLS'
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


                        if(
                         (is_WETTING_radioGroup_controller.value=="否" || is_WETTING_radioGroup_controller.value==null)&&
                             (is_GET_WET_radioGroup_controller.value=="否" || is_GET_WET_radioGroup_controller.value==null)&&
                             (is_GOT_SHIT_radioGroup_controller.value=="否" || is_GOT_SHIT_radioGroup_controller.value==null)&&
                             (is_WEATHER_radioGroup_controller.value=="否" || is_WEATHER_radioGroup_controller.value==null)&&
                             (is_BATH_radioGroup_controller.value=="否" || is_BATH_radioGroup_controller.value==null)&&
                             (is_GET_BACK_radioGroup_controller.value=="否" || is_GET_BACK_radioGroup_controller.value==null)&&
                             (is_OUT_DOOR_radioGroup_controller.value=="否" || is_OUT_DOOR_radioGroup_controller.value==null)&&
                             OTHER_textEditingController.text.isEmpty
                        ){

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('提醒',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
                                content: Text('全部點選否或是無點選，上傳前需填寫其他',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      // 執行刪除動作
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('確定',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 18.sp),),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }

                        /*
                        if(dateTime==null){
                          EasyLoading.showToast("請輸入活動日期");
                          return;
                        }

                        if(timeOfDay==null){
                          EasyLoading.showToast("請輸入活動時間");
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
                title: Text("新增${DAILY_MT_TYPE_ITEMs.firstWhere((e)=>e.ITEM_NO=="CLS").ITEM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
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
              Row(children: [
                Container(width: 10.w,),
                Expanded(child:Text("尿濕:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929)))),
                Expanded(flex:3,child: rg.RadioGroup(
                  controller: is_WETTING_radioGroup_controller,
                  orientation: rg.RadioGroupOrientation.horizontal,
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
                      is_WETTING = true;
                    }
                    else{
                      is_WETTING = false;
                    }
                  },
                )),
              ],),
              Container(height: 15.h,),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 15.h,),
              Row(children: [
                Container(width: 10.w,),
                Expanded(child: Text("弄濕:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929)))),
                Expanded(flex:3,child: rg.RadioGroup(
                  controller: is_GET_WET_radioGroup_controller,
                  orientation: rg.RadioGroupOrientation.horizontal,
                  values: ["是", "否",],
                  //indexOfDefault: 0,
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
                      is_GET_WET = true;
                    }
                    else{
                      is_GET_WET = false;
                    }
                  },
                )),
              ],),
              Container(height: 15.h,),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 15.h,),
              Row(children: [
                Container(width: 10.w,),
                Expanded(child: Text("沾到大便:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929)))),
                Expanded(flex:3,child: rg.RadioGroup(
                  controller: is_GOT_SHIT_radioGroup_controller,
                  orientation: rg.RadioGroupOrientation.horizontal,
                  values: ["是", "否",],
                  //indexOfDefault: 0,
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
                      is_GOT_SHIT = true;
                    }
                    else{
                      is_GOT_SHIT = false;
                    }
                  },
                )),
              ],),
              Container(height: 15.h,),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 15.h,),
              Row(children: [
                Container(width: 10.w,),
                Expanded(child: Text("天氣變化:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929)))),
                Expanded(flex:3,child: rg.RadioGroup(
                  controller: is_WEATHER_radioGroup_controller,
                  orientation: rg.RadioGroupOrientation.horizontal,
                  values: ["是", "否",],
                  //indexOfDefault: 0,
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
                      is_WEATHER = true;
                    }
                    else{
                      is_WEATHER = false;
                    }
                  },
                )),
              ],),
              Container(height: 15.h,),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 15.h,),
              Row(children: [
                Container(width: 10.w,),
                Expanded(child: Text("洗澡:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929)))),
                Expanded(flex:3,child: rg.RadioGroup(
                  controller: is_BATH_radioGroup_controller,
                  orientation: rg.RadioGroupOrientation.horizontal,
                  values: ["是", "否",],
                  //indexOfDefault: 0,
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
                      is_BATH = true;
                    }
                    else{
                      is_BATH = false;
                    }
                  },
                )),
              ],),
              Container(height: 15.h,),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 15.h,),
              Row(children: [
                Container(width: 10.w,),
                Expanded(child: Text("從診所回中心:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929)))),
                Expanded(flex:3,child: rg.RadioGroup(
                  controller: is_GET_BACK_radioGroup_controller,
                  orientation: rg.RadioGroupOrientation.horizontal,
                  values: ["是", "否",],
                  //indexOfDefault: 0,
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
                      is_GET_BACK = true;
                    }
                    else{
                      is_GET_BACK = false;
                    }
                  },
                )),
              ],),
              Container(height: 15.h,),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 15.h,),
              Row(children: [
                Container(width: 10.w,),
                Expanded(child: Text("戶外活動:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929)))),
                Expanded(flex:3,child: rg.RadioGroup(
                  controller: is_OUT_DOOR_radioGroup_controller,
                  orientation: rg.RadioGroupOrientation.horizontal,
                  values: ["是", "否",],
                  //indexOfDefault: 0,
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
                      is_OUT_DOOR = true;
                    }
                    else{
                      is_OUT_DOOR = false;
                    }
                  },
                )),
              ],),
              Container(height: 15.h,),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
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
