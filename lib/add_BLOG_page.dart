import 'dart:convert';
import 'dart:io';
import 'package:code3/main2_T.dart';
import 'package:code3/signature2.dart';
import 'package:code3/signature4.dart';
import 'package:code3/utils/CustomAppBar.dart';
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
import 'dart:developer' as dev;
import 'api.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'package:badges/badges.dart' as badges;
import 'package:image_picker/image_picker.dart' as ImagePicker;

class ADD_BLOG_page extends StatefulWidget {

  @override
  State<ADD_BLOG_page> createState() => ADD_BLOG_pageState();
}

class ADD_BLOG_pageState extends State<ADD_BLOG_page> {


  TextEditingController TITLE_textEditingController = TextEditingController();//標題
  TextEditingController DETAIL_textEditingController = TextEditingController();//內容
  TextEditingController NOTE_textEditingController = TextEditingController();//備註

  DateTime? dateTime;
  DateTime? add_dateTime = DateTime.now();

  var showModalBottomSheet_image_context;

  List<BLOG_DL> bLOG_DL = [];//生活花絮子表單

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


  Future<void> add_BLOG_db_sub2()async{



    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});

    String datetime = "${DateFormat('yyyy-MM-dd').format(dateTime!)}";

    dev.log('datetime:${datetime}');

    // 將 bLOG_DL 轉成 [{SR:1, NOTE:"..."}, {SR:2, NOTE:"..."}] 格式
    List<Map<String, dynamic>> blogNotes = bLOG_DL.asMap().entries.map((entry) {
      final index = entry.key;      // 索引 (0,1,2,...)
      final item = entry.value;     // BLOG_DL 物件
      return {
        "SR": index + 1, // 自動從 1 開始
        "LINK":"~/School/Images/Blog/${index+1}_${user.ACCOUNT}_${DateTime.now().microsecondsSinceEpoch}.jpg",
        "NOTE": item.NOTE_textEditingController.text.trim(),
      };
    }).toList();
    String blogNotesJson = jsonEncode(blogNotes);

    String comm = '''
BEGIN TRANSACTION;
SET NOCOUNT ON;

-- 1. 傳入參數（Flutter 傳來）
DECLARE @Count INT = ${1};                         
DECLARE @PicPerStudent INT = ${bLOG_DL.length};    
DECLARE @Note NVARCHAR(MAX) = N'${NOTE_textEditingController.text}';
DECLARE @Date DATE = '${datetime}';
DECLARE @TITLE NVARCHAR(50) = N'${TITLE_textEditingController.text}';
DECLARE @DETAIL NVARCHAR(MAX) = N'${DETAIL_textEditingController.text}';
DECLARE @DEPM_NO NCHAR(4) = N'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}';
DECLARE @CLASS_NO NCHAR(10) = N'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}';
DECLARE @BLTN_DT DATE = '${DateFormat('yyyy-MM-dd').format(dateTime!)}';
DECLARE @ADD_USER NCHAR(30) = N'${EMPLOYEE_teacher.EMP_NM}';
DECLARE @BlogNotesJson NVARCHAR(MAX) = N'${blogNotesJson}';

-- 建立 #BlogNotes 暫存表
SELECT  
    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS SR,
    LINK,
    NOTE
INTO #BlogNotes
FROM OPENJSON(@BlogNotesJson)
WITH (
    LINK NVARCHAR(MAX),
    NOTE NVARCHAR(MAX)
);

-- 2. 編號處理
DECLARE @Prefix NVARCHAR(8);
DECLARE @StartNo INT;
DECLARE @BaseNO NVARCHAR(13) = '';

SET @Prefix = CONVERT(CHAR(8), @Date, 112);

SELECT @StartNo = ISNULL(MAX(CAST(RIGHT(BLOG_NO, 4) AS INT)), 0)
FROM BLOG WITH (UPDLOCK, HOLDLOCK)
WHERE BLTN_DT = @Date 
  AND LEFT(BLOG_NO, 8) = @Prefix;

-- 3. 建立 #NewNOs 暫存表
IF OBJECT_ID('tempdb..#NewNOs') IS NOT NULL 
    DELETE FROM #NewNOs;
ELSE 
    CREATE TABLE #NewNOs (Seq INT, BLOG_NO NVARCHAR(12));

WITH NewNOs AS (
    SELECT 1 AS Seq, @Prefix + RIGHT('0000' + CAST(@StartNo + 1 AS VARCHAR), 4) AS BLOG_NO
    UNION ALL
    SELECT Seq + 1, @Prefix + RIGHT('0000' + CAST(@StartNo + Seq + 1 AS VARCHAR), 4) AS BLOG_NO
    FROM NewNOs
    WHERE Seq < @Count
)
INSERT INTO #NewNOs
SELECT * FROM NewNOs;

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

-- 6. 取得第一筆 NO
SELECT TOP 1 @BaseNO = BLOG_NO FROM #NewNOs ORDER BY Seq;

-- 7. 寫入 BLOG（基本資料）
INSERT INTO BLOG (BLOG_NO,TITLE,DETAIL, BLTN_DT, DEPM_NO, CLASS_NO, ADD_USER, ADD_DATE, NOTE)
SELECT
    n.BLOG_NO,
    @TITLE,
    @DETAIL,
    @BLTN_DT,
    @DEPM_NO,
    @CLASS_NO,
    @ADD_USER,
    SYSDATETIME(),
    @NOTE
FROM #NewNOs n;

-- 9. 寫入 BLOG_DL
IF @PicPerStudent > 0
BEGIN
    INSERT INTO BLOG_DL (BLOG_NO, BLOG_SR, LINK, NOTE)
    SELECT 
        n.BLOG_NO,
        p.SR,
        bn.LINK,
        bn.NOTE
    FROM #NewNOs n
    CROSS JOIN #PictureSR p
    LEFT JOIN #BlogNotes bn ON p.SR = bn.SR;
END

-- 10. 回傳 JSON
DECLARE @Result TABLE (
    message NVARCHAR(20),
    affectedRows INT,
    FirstNO NVARCHAR(13)
);

INSERT INTO @Result
SELECT N'執行成功', @Count * (1 + 1 + @PicPerStudent), @BaseNO;

COMMIT;

SELECT 
    message AS message,
    affectedRows AS affectedRows,
    FirstNO AS FirstNO
FROM @Result
FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
''';

    String result = await sql_command2("${comm}");
    dev.log("寫入花絮(回應):${result}");

    try{
      Map<String,dynamic> map = jsonDecode(result);
      if("${map["message"]}"=="執行成功"){

        //String FirstNO = "${map["FirstNO"]}";

        for(int i=0;i<blogNotes.length;i++){
          SmartDialog.showLoading(msg: "上傳圖片...(${i+1}/${blogNotes.length})");
          String fullPath = blogNotes[i]["LINK"];
          String fileName = fullPath.split('/').last; // 含副檔名
          String nameWithoutExt = fileName.split('.').first; // 不含副檔名
          await upload_image(image_path: bLOG_DL[i].prescriptionsbytes_xfile!.path,file_name: nameWithoutExt,folder: "Blog");
        }


        SmartDialog.dismiss();
        SmartDialog.showToast("處理成功");

        bLOG_DL.clear();
        TITLE_textEditingController.text="";
        DETAIL_textEditingController.text="";
        NOTE_textEditingController.text="";
        dateTime=null;
        MyHomePage2_T_fun1!(type:"刷新活動花絮");
        setState(() {

        });

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
  上傳新一筆活動花絮
   */
  Future<void> add_BLOG_db_sub()async{
    int BLOG_NO_num = await read_BLOG_db_sub();
    dev.log("BLOG_NO_num:${BLOG_NO_num}");
    if(BLOG_NO_num==-1){
      SmartDialog.showToast('read_DRUG_MT_db_sub error');
      //EasyLoading.showInfo("read_DRUG_MT_db_sub error");
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});

    String BLOG_NO = "${BLOG_NO_num}";

    await insert_BLOG_db_sub(
        BLOG_NO:BLOG_NO,//生活花絮編號
        TITLE:"${TITLE_textEditingController.text}",
        DETAIL:"${DETAIL_textEditingController.text}",
        BLTN_DT:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
        DEPM_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}",
        CLASS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}",
        ADD_USER:"${EMPLOYEE_teacher.EMP_NM}",//建立者
        ADD_DATE:"${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}",//建立日期
        NOTE:"${NOTE_textEditingController.text}",//建立者
    );

    //送出生活花絮子表單
    for(int i=0;i<bLOG_DL.length;i++){

      String img_name = "${BLOG_NO}_${i+1}_${user.ACCOUNT}_${DateFormat("yyyyMMddHHmmsss").format(DateTime.now())}";
      if(bLOG_DL[i].prescriptionsbytes_xfile!=null){
        await upload_image(image_path: bLOG_DL[i].prescriptionsbytes_xfile!.path,file_name: img_name,folder: "Blog");
      }

      await insert_BLOG_DL_db_sub(
        BLOG_NO:BLOG_NO,//生活花絮編號
        BLOG_SR:"${i+1}",
        LINK:(bLOG_DL[i].prescriptionsbytes_xfile==null)?"":"~/School/Images/Blog/${img_name}.jpg",//藥品照片
        NOTE:"${bLOG_DL[i].NOTE_textEditingController.text}"
      );

    }

    SmartDialog.dismiss();
    SmartDialog.showToast("處理成功");

    bLOG_DL.clear();
    TITLE_textEditingController.text="";
    DETAIL_textEditingController.text="";
    NOTE_textEditingController.text="";
    dateTime=null;
    MyHomePage2_T_fun1!(type:"刷新活動花絮");
    setState(() {

    });


  }


  /*
  生活花絮
   */
  Future<void> insert_BLOG_db_sub(
      {
        String BLOG_NO="",//生活花絮編號
        String TITLE="",//標題
        String DETAIL="",//內容
        String BLTN_DT="",//顯示日期
        String DEPM_NO="",//學校編號
        String CLASS_NO="",//班級編號
        String ADD_USER="",//建立者
        String ADD_DATE="",//建立日期
        String NOTE=""//備註
      })async{

    String comm = "INSERT INTO BLOG(BLOG_NO,TITLE,DETAIL,BLTN_DT,DEPM_NO,CLASS_NO,ADD_USER,ADD_DATE,NOTE) VALUES ('${BLOG_NO}','${TITLE}','${DETAIL}','${BLTN_DT}','${DEPM_NO}','${CLASS_NO}','${ADD_USER}','${ADD_DATE}','${NOTE}')";
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
  Future<void> insert_BLOG_DL_db_sub(
      {
        String BLOG_NO="",//生活花絮編號
        String BLOG_SR="",//標題
        String LINK="",//內容
        String NOTE="",//顯示日期
      })async{

    String comm = "INSERT INTO BLOG_DL(BLOG_NO,BLOG_SR,LINK,NOTE) VALUES ('${BLOG_NO}','${BLOG_SR}','${LINK}','${NOTE}')";
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
  Future<int> read_BLOG_db_sub()async{

    int BLOG_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(add_dateTime!)}";

    //String comm = "SELECT * FROM BLOG WHERE BLTN_DT BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";

    String comm = '''SELECT *
    FROM BLOG
    WHERE ADD_DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'
      AND BLOG_NO = (
        SELECT MAX(BLOG_NO)
        FROM BLOG
        WHERE ADD_DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'
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
        BLOG_NO_num + 1;
        BLOG_NO_num = int.parse("${DateFormat('yyyyMMdd').format(add_dateTime!)}${BLOG_NO_num.toString().padLeft(4,"0")}");
      }
      else{
        String BLOG_NO = "${data_list[data_list.length-1]["BLOG_NO"]}";
        dev.log("BLOG_NO:${BLOG_NO}");
        //找出流水號
        //BLOG_NO_num = int.parse("${BLOG_NO.substring(BLOG_NO.length-4,BLOG_NO.length)}");
        //dev.log("BLOG_NO_num:${BLOG_NO_num}");
        BLOG_NO_num = int.parse("${BLOG_NO}");
        BLOG_NO_num+=1;

      }
      setState(() {

      });

    }
    catch(e){
      BLOG_NO_num=-1;
      dev.log("${e}");
    }

    return BLOG_NO_num;

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
                  if(bLOG_DL.length>0){
                    check=true;
                  }

                  if(TITLE_textEditingController.text.isNotEmpty){
                    check=true;
                  }

                  if(DETAIL_textEditingController.text.isNotEmpty){
                    check=true;
                  }

                  if(NOTE_textEditingController.text.isNotEmpty){
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


                    if(TITLE_textEditingController.text.isEmpty){
                      SmartDialog.showToast("請輸入標題");
                      return;
                    }

                    if(TITLE_textEditingController.text.isEmpty){
                      SmartDialog.showToast("請輸入標題");
                      return;
                    }

                    if(dateTime==null){
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
                                            add_BLOG_db_sub2();
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
            title: Text("新增活動花絮", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
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

           */
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
            Text("標題:",style: TextStyle(
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
                controller: TITLE_textEditingController,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  //RemoveEmojiInputFormatter()
                  SingleQuoteToFullQuoteFormatter(),
                ],
                autofocus: false,
                maxLines: null,
                //obscureText: !_adminVisible,
                //obscureText: !_accountVisible,//This will obscure text dynamically
                maxLength: 50,
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
          Row(children: [
            Container(width: 10.w,),
            Text("內容:",style: TextStyle(
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
                controller: DETAIL_textEditingController,
                keyboardType: TextInputType.text,
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
          Row(children: [
            Container(width: 10.w,),
            Text("活動日期:",style: TextStyle(
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
            Text("備註:",style: TextStyle(
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
                controller: NOTE_textEditingController,
                keyboardType: TextInputType.text,
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
          Row(children: [
                Expanded(child: Container()),
                GestureDetector(
                  onTap: ()async{
                    /*
                    BLOG_DL b = BLOG_DL();
                    bLOG_DL.insert(0,b);
                    setState(() {

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
                                    final myAppPath = '$tempDirPath/威寶通/Drug';
                                    final res = await Directory(myAppPath).create(recursive: true);
                                    String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                    //var decodedImage = await imageFile.readAsBytes();
                                    //print(decodedImage.length);

                                    BLOG_DL b = BLOG_DL();
                                    bLOG_DL.insert(0,b);

                                    //壓縮image
                                    bLOG_DL[0].prescriptionsbytes_xfile = await FlutterImageCompress.compressAndGetFile(
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
                                          BLOG_DL b = BLOG_DL();
                                          bLOG_DL.insert(0,b);

                                          DateTime t = DateTime.now();
                                          Directory tempDir = await getTemporaryDirectory();
                                          var tempDirPath = tempDir.path;
                                          final myAppPath = '$tempDirPath/威寶通/Drug';
                                          final res = await Directory(myAppPath).create(recursive: true);
                                          String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                          //String? path2 = await LecleFlutterAbsolutePath.getAbsolutePath(uri:images[i].identifier);
                                          //壓縮image
                                          bLOG_DL[0].prescriptionsbytes_xfile = await FlutterImageCompress
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

                                          /*
                                          DateTime t = DateTime.now();
                                          Directory tempDir = await getTemporaryDirectory();
                                          var tempDirPath = tempDir.path;
                                          final myAppPath = '$tempDirPath/威寶通/Drug';
                                          final res = await Directory(myAppPath).create(recursive: true);
                                          String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                          //壓縮image
                                          e.prescriptionsbytes_xfile = await FlutterImageCompress
                                              .compressAndGetFile(
                                            imageFile.path, filePath,
                                            quality: 20,
                                            rotate: 0,
                                          );

                                           */

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
                                        BLOG_DL b = BLOG_DL();
                                        bLOG_DL.insert(0,b);

                                        DateTime t = DateTime.now();
                                        Directory tempDir = await getTemporaryDirectory();
                                        var tempDirPath = tempDir.path;
                                        final myAppPath = '$tempDirPath/威寶通/Drug';
                                        final res = await Directory(myAppPath).create(recursive: true);
                                        String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                        //String? path2 = await LecleFlutterAbsolutePath.getAbsolutePath(uri:images[i].identifier);
                                        //壓縮image
                                        bLOG_DL[0].prescriptionsbytes_xfile = await FlutterImageCompress
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
                                      List<Asset> resultList = await MultiImagePicker.pickImages(
                                        selectedAssets: <Asset>[],
                                        iosOptions: IOSOptions(
                                          doneButton:
                                          UIBarButtonItem(title: 'Confirm', tintColor: colorScheme.primary),
                                          cancelButton:
                                          UIBarButtonItem(title: 'Cancel', tintColor: colorScheme.primary),
                                          albumButtonColor: colorScheme.primary,
                                          settings: iosSettings,
                                        ),
                                        androidOptions: AndroidOptions(
                                          actionBarColor: colorScheme.surface,
                                          actionBarTitleColor: colorScheme.onSurface,
                                          statusBarColor: colorScheme.surface,
                                          actionBarTitle: "Select Photo",
                                          allViewTitle: "All Photos",
                                          useDetailsView: false,
                                          selectCircleStrokeColor: colorScheme.primary,
                                        ),
                                      );
                                      images = resultList;
                                      dev.log("${resultList[0]}");
                                      for(int i=0;i>images.length;i++){
                                        BLOG_DL b = BLOG_DL();
                                        bLOG_DL.insert(0,b);

                                        DateTime t = DateTime.now();
                                        Directory tempDir = await getTemporaryDirectory();
                                        var tempDirPath = tempDir.path;
                                        final myAppPath = '$tempDirPath/威寶通/Drug';
                                        final res = await Directory(myAppPath).create(recursive: true);
                                        String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';
                                        String? path2 = await LecleFlutterAbsolutePath.getAbsolutePath(uri:images[i].identifier);
                                        //壓縮image
                                        bLOG_DL[0].prescriptionsbytes_xfile = await FlutterImageCompress
                                            .compressAndGetFile(
                                          path2!, filePath,
                                          quality: 20,
                                          rotate: 0,
                                        );

                                      }

                                       */

                                      //print("相簿-2");
                                      /*
                                      var imageFile = await ImagePicker.ImagePicker().pickImage(
                                          source: ImagePicker.ImageSource.gallery);

                                      if (imageFile !=
                                          null) {
                                        //print(
                                        //    "imageFile.lengthSync1():${imageFile
                                        //        .lengthSync()}");

                                        /*
                                        DateTime t = DateTime.now();
                                        Directory tempDir = await getTemporaryDirectory();
                                        var tempDirPath = tempDir.path;
                                        final myAppPath = '$tempDirPath/威寶通/Drug';
                                        final res = await Directory(myAppPath).create(recursive: true);
                                        String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                        //壓縮image
                                        e.prescriptionsbytes_xfile = await FlutterImageCompress
                                            .compressAndGetFile(
                                          imageFile.path, filePath,
                                          quality: 20,
                                          rotate: 0,
                                        );

                                         */

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
                                      BLOG_DL b = BLOG_DL();
                                      bLOG_DL.insert(0,b);

                                      DateTime t = DateTime.now();
                                      Directory tempDir = await getTemporaryDirectory();
                                      var tempDirPath = tempDir.path;
                                      final myAppPath = '$tempDirPath/威寶通/Drug';
                                      final res = await Directory(myAppPath).create(recursive: true);
                                      String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                                      //String? path2 = await LecleFlutterAbsolutePath.getAbsolutePath(uri:images[i].identifier);
                                      //壓縮image
                                      bLOG_DL[0].prescriptionsbytes_xfile = await FlutterImageCompress
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
                                    List<Asset> resultList = await MultiImagePicker.pickImages(
                                      selectedAssets: <Asset>[],
                                      iosOptions: IOSOptions(
                                        doneButton:
                                        UIBarButtonItem(title: 'Confirm', tintColor: colorScheme.primary),
                                        cancelButton:
                                        UIBarButtonItem(title: 'Cancel', tintColor: colorScheme.primary),
                                        albumButtonColor: colorScheme.primary,
                                        settings: iosSettings,
                                      ),
                                      androidOptions: AndroidOptions(
                                        actionBarColor: colorScheme.surface,
                                        actionBarTitleColor: colorScheme.onSurface,
                                        statusBarColor: colorScheme.surface,
                                        actionBarTitle: "Select Photo",
                                        allViewTitle: "All Photos",
                                        useDetailsView: false,
                                        selectCircleStrokeColor: colorScheme.primary,
                                      ),
                                    );
                                    images = resultList;
                                    dev.log("images.length:${images.length}");
                                    for(int i=0;i<images.length;i++){
                                      BLOG_DL b = BLOG_DL();
                                      bLOG_DL.insert(0,b);
                                      dev.log("path2:>>>");
                                      DateTime t = DateTime.now();
                                      Directory tempDir = await getTemporaryDirectory();
                                      var tempDirPath = tempDir.path;
                                      final myAppPath = '$tempDirPath/威寶通/Drug';
                                      final res = await Directory(myAppPath).create(recursive: true);
                                      String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';
                                      dev.log("path2:>>");
                                      String? path2 = await LecleFlutterAbsolutePath.getAbsolutePath(uri:images[i].identifier);
                                      dev.log("path2:${path2}");
                                      //壓縮image
                                      bLOG_DL[0].prescriptionsbytes_xfile = await FlutterImageCompress
                                          .compressAndGetFile(
                                        path2!, filePath,
                                        quality: 20,
                                        rotate: 0,
                                      );

                                    }
                                    setState(() {

                                    });

                                     */

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
                                          final myAppPath = '$tempDirPath/威寶通/Drug';
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
                  child:
                  Container(child:Text("新增活動圖片",style: TextStyle(color: Colors.black,fontSize: 16.sp),))),
                Icon(Icons.add_circle_outline,size: 24.sp,),
                Container(width: 10.w,),
              ],),
          Container(height: 15.h,),
          Column(children: bLOG_DL.map((e){
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

                                             bLOG_DL.remove(e);
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
                  width: ScreenUtil().screenWidth,child: Row(children: [

                  GestureDetector(
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
                                        final myAppPath = '$tempDirPath/威寶通/Drug';
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

                                            if (imageFile != null) {
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
                                            final myAppPath = '$tempDirPath/威寶通/Drug';
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

                                        if (imageFile != null) {
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
                      child: Container(width: 100.w,height: 100.h,color: Colors.grey,child:
                      Center(child:(e.prescriptionsbytes_xfile==null)?
                      Icon(Icons.camera_alt,color: Colors.white,size: 60.sp)
                          :
                      Image.file(File(e.prescriptionsbytes_xfile!.path))
                      ))),

                  Expanded(child: Container(
                      height: 100.h,
                      padding: EdgeInsets.all(0.w),
                      margin: EdgeInsets.only(left:8.w,right: 8.w,top: 5.h,bottom: 5.h),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5.w),
                      ),
                      width:ScreenUtil().screenWidth,child: Form(
                      child: TextFormField(
                        style: TextStyle(
                          fontSize: 20.sp,
                          color: Color(0xff555555),
                        ),
                        controller: e.NOTE_textEditingController,
                        keyboardType: TextInputType.text,
                        inputFormatters: [
                          //RemoveEmojiInputFormatter()
                        ],
                        autofocus: false,
                        maxLines: null,
                        //obscureText: !_adminVisible,
                        //obscureText: !_accountVisible,//This will obscure text dynamically
                        maxLength: 50,
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
                          hintText: '備註',
                          hintStyle: TextStyle(fontWeight: FontWeight.w400,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
                          contentPadding:  EdgeInsets.only(left: 10.w,right: 10.w,top: 0.h,bottom: 0.h),
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
                      )))),

                ],),));
          }).toList(),),
          /*
          GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics:NeverScrollableScrollPhysics(),
              scrollDirection:Axis.vertical,
              children: List.generate(images.length, (index) {
                Asset asset = images[index];
                return AssetThumb(
                  asset: asset,
                  width: 300,
                  height: 300,
                );
              }),
            ),

           */




        ],),
    )));
  }
}
