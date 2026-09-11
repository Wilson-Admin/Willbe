import 'dart:convert';
import 'dart:io';
import 'package:code3/signature2.dart';
import 'package:code3/signature4.dart';
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
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'dart:developer' as dev;
import 'api.dart';
import 'fcm_notifity.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'utils/CustomAppBar.dart';

Function? EXCUSED_page_U_fun1;
Uint8List? EXCUSED_page_signaturebytes;//簽名圖檔
String EXCUSED_page_SING_LINK_TYPE = "";
SignatureController EXCUSED_page_signatureController = SignatureController(
  penStrokeWidth: 5,
  penColor: Colors.black,
  exportBackgroundColor: Colors.white,
);

class EXCUSED_page extends StatefulWidget {
  String mode = "新增";
  EXCUSED eXCUSED = EXCUSED();//
  EXCUSED_page({String mode = "",EXCUSED? eXCUSED}){
    this.mode = mode;
    if(mode=="編輯") {
      this.eXCUSED = eXCUSED!;
    }
  }

  @override
  State<EXCUSED_page> createState() => EXCUSED_pageState(mode:this.mode,eXCUSED:eXCUSED!);
}

class EXCUSED_pageState extends State<EXCUSED_page> {


  TextEditingController NOTE_textEditingController = TextEditingController();//說明

  //CUSTOMER CUSTOMER_selectedValue = CUSTOMER();
  DateTime? dateTime;
  EXCUSED_HOURS_ITEM? sel_EXCUSED_HOURS_ITEM;
  EXCUSED_REASON_ITEM? sel_EXCUSED_REASON_ITEM;
  CFM_ITEM? sel_CFM_ITEM;
  CLASS _class = CLASS();
  DEPM _depm = DEPM();
  BuildContext? _context;
  List<DateTime> initialDates = [];

  String mode = "新增";
  EXCUSED eXCUSED = EXCUSED();//
  EXCUSED_pageState({String mode = "",EXCUSED? eXCUSED}){
    this.mode = mode;
    if(mode=="編輯"){
      this.eXCUSED = eXCUSED!;
      dateTime = DateTime.parse(eXCUSED.DATE);
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    EXCUSED_page_signaturebytes=null;
    EXCUSED_page_SING_LINK_TYPE="";
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    EXCUSED_page_signaturebytes=null;
    EXCUSED_page_U_fun1 = (){
      setState(() {

      });
    };

    if(mode=="編輯"){
      for(int i=0;i<cUSTOMERs.length;i++){
        if(cUSTOMERs[i].CS_NO==eXCUSED.CS_NO){
          CUSTOMER_selectedValue = cUSTOMERs[i];
          break;
        }
      }
    }
    else{
      //CUSTOMER_selectedValue = cUSTOMERs[0];
    }


    _class = cLASSs.firstWhere((element) => element.CLASS_NO==CUSTOMER_selectedValue.CLASS_NO)??CLASS();
    _depm = dEPMs.firstWhere((element) => element.DEPM_NO==CUSTOMER_selectedValue.DEPM_NO)??DEPM();

    init();

  }

  init()async{
    await EXCUSED_HOURS_ITEM_db_sub();
    await EXCUSED_REASON_ITEM_db_sub();
    await CFM_ITEM_db_sub();

    if(mode=="編輯"){
      for(int i=0;i<cUSTOMERs.length;i++){
        if(cUSTOMERs[i].CS_NO==eXCUSED.CS_NO){
          CUSTOMER_selectedValue = cUSTOMERs[i];
          break;
        }
      }
      for(int i=0;i<EXCUSED_HOURS_ITEM_list.length;i++){
        if(EXCUSED_HOURS_ITEM_list[i].ITEM_NO==eXCUSED.HOURS_NO){
          sel_EXCUSED_HOURS_ITEM = EXCUSED_HOURS_ITEM_list[i];
          break;
        }
      }
      for(int i=0;i<EXCUSED_REASON_ITEM_list.length;i++){
        if(EXCUSED_REASON_ITEM_list[i].ITEM_NO==eXCUSED.REASON_NO){
          sel_EXCUSED_REASON_ITEM = EXCUSED_REASON_ITEM_list[i];
          break;
        }
      }

      NOTE_textEditingController.text = eXCUSED.NOTE;

    }

    setState(() {

    });
  }


  Future<void>EXCUSED_HOURS_ITEM_db_sub()async{

    EXCUSED_HOURS_ITEM_list.clear();
    String comm = "SELECT * FROM EXCUSED_HOURS_ITEM";
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
          EXCUSED_HOURS_ITEM ss = EXCUSED_HOURS_ITEM();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          EXCUSED_HOURS_ITEM_list.add(ss);
          sel_EXCUSED_HOURS_ITEM = EXCUSED_HOURS_ITEM_list[0];
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

  Future<void>EXCUSED_REASON_ITEM_db_sub()async{

    EXCUSED_REASON_ITEM_list.clear();
    String comm = "SELECT * FROM EXCUSED_REASON_ITEM";
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
          EXCUSED_REASON_ITEM ss = EXCUSED_REASON_ITEM();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          EXCUSED_REASON_ITEM_list.add(ss);
          sel_EXCUSED_REASON_ITEM = EXCUSED_REASON_ITEM_list[0];
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

  Future<void>CFM_ITEM_db_sub()async{

    CFM_ITEM_list.clear();
    String comm = "SELECT * FROM CFM_ITEM";
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
          CFM_ITEM ss = CFM_ITEM();
          ss.CFM_NO = "${data_list[j]["CFM_NO"]}";
          ss.CFM_NM = "${data_list[j]["CFM_NM"]}";
          CFM_ITEM_list.add(ss);
          sel_CFM_ITEM = CFM_ITEM_list[0];
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
  [托嬰/幼兒] 請假 EXCUSED
   */
  Future<int> read_EXCUSED_db_sub({int index=0})async{

    int EXCUSED_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(initialDates[index])}";

    //String comm = "SELECT * FROM EXCUSED WHERE DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";
    String comm = '''SELECT *
    FROM EXCUSED
      WHERE DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'
      AND NO = (
        SELECT MAX(NO)
        FROM EXCUSED
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

        EXCUSED_NO_num+=1;
        EXCUSED_NO_num = int.parse("${DateFormat('yyyyMMdd').format(initialDates[index])}${EXCUSED_NO_num.toString().padLeft(4,"0")}");

      }
      else{
        data_list.sort((a,b)=> int.parse(a["NO"]).compareTo(int.parse(b["NO"])));
        String EXCUSED_NO = "${data_list[data_list.length-1]["NO"]}";
        dev.log("EXCUSED_NO:${EXCUSED_NO}");
        //找出流水號
        EXCUSED_NO_num = int.parse("${EXCUSED_NO}");//int.parse("${EXCUSED_NO.substring(EXCUSED_NO.length-4,EXCUSED_NO.length)}");
        EXCUSED_NO_num+=1;
        dev.log("EXCUSED_NO_num:${EXCUSED_NO_num}");
      }
      setState(() {

      });

    }
    catch(e){
      EXCUSED_NO_num=-1;
      dev.log("${e}");
    }

    return EXCUSED_NO_num;

  }


  /*
  ENTRUSTED_TYPE_ITEM_db_sub
   */
  Future<void>ENTRUSTED_TYPE_ITEM_db_sub()async{

    ENTRUSTED_TYPE_ITEM_list.clear();
    String comm = "SELECT * FROM ENTRUSTED_TYPE_ITEM";
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
          ENTRUSTED_TYPE_ITEM ss = ENTRUSTED_TYPE_ITEM();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          ENTRUSTED_TYPE_ITEM_list.add(ss);
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
  [托嬰/幼兒] 請假  EXCUSED
   */
  Future<bool> insert_EXCUSED_db_sub(
      {
        String NO="",//編號
        String DATE="",//日期
        String DEPM_NO="",//學校
        String CLASS_NO="",//班級
        String CS_NO="",//學生編號
        String HOURS_NO="",//說明
        String REASON_NO="",//代理人姓名
        String NOTE="",//代理人電話
        String ADD_DATE="",//關係
        String SING_LINK="",//簽名
        String CFM_NO="",//確認
      })async{

    String comm = "INSERT INTO EXCUSED(NO,DATE,DEPM_NO,CLASS_NO,CS_NO,NOTE,HOURS_NO,REASON_NO,ADD_DATE,SING_LINK,CFM_NO) VALUES ('${NO}','${DATE}','${DEPM_NO}','${CLASS_NO}','${CS_NO}','${NOTE}','${HOURS_NO}','${REASON_NO}','${ADD_DATE}','${SING_LINK}','${CFM_NO}')";
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


  Future<bool> update_EXCUSED_db_sub(
      {
        String NO="",//編號
        String DATE="",//日期
        String DEPM_NO="",//學校
        String CLASS_NO="",//班級
        String CS_NO="",//學生編號
        String HOURS_NO="",//說明
        String REASON_NO="",//代理人姓名
        String NOTE="",//代理人電話
        String ADD_DATE="",//關係
        String SING_LINK="",//簽名
        String CFM_NO="",//確認
      })async{

    String comm = "UPDATE EXCUSED SET DATE='${DATE}', DEPM_NO='${DEPM_NO}', CLASS_NO='${CLASS_NO}', CS_NO='${CS_NO}',NOTE='${NOTE}',HOURS_NO='${HOURS_NO}',REASON_NO='${REASON_NO}',SING_LINK='${SING_LINK}' WHERE NO='${NO}'";
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
  將接送委託寫入聊天室
   */
  Future<void> insert_MSDL2_db_sub({String EXCUSED_NO=""})async{

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
    String message="您有一筆請假委託通知\n(${EXCUSED_NO})";

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
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            backgroundColor: Color(0xffF9AA88),
            toolbarHeight:42.h,
            leading: GestureDetector(
                onTap: (){
                  MyHomePage2_U_fun1!();
                  Navigator.pop(context);
                },
                child:Icon(Icons.arrow_back,size: 30.w,)),
            centerTitle: true,
            actions: [
              //Text("儲存", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              Container(width: 20.w,),
            ],
            title: Text("請假申請${mode=="編輯"?"(編輯)":""}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
          ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [

          GestureDetector(
              onTap:()async{


                if(mode=="新增"){

                  await showDialog(
                    context: context,
                    builder: (context) {
                      List<DateTime> tempSelectedDates = List.from(initialDates);

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
                      initialDates = result;
                      setState(() {

                      });
                    } else {
                      dev.log('未選擇任何日期');
                    }
                  });

                }
                else{

                  /*
                  日期不可編輯
                  dateTime = (await showDatePicker(
                      locale: Locale("zh","TW"),
                      context: context,
                      initialDate: DateTime.now(),
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
                Text("委託日期",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
                Expanded(child: Container()),
                Text((dateTime==null)?"":"${DateFormat('yyyy年MM月dd日').format(dateTime!)}",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Colors.blue)),
                Container(width: 10.w,),
                Icon(Icons.arrow_forward_ios,size: 20.sp,),
                Container(width: 5.w,),
              ],),)),

          (mode!="新增")?Container():
          initialDates.isEmpty?Container():
          Container(
              padding: EdgeInsets.only(left:5.w,right: 5.w),
              color: Color(0xffEEEEEE),width: ScreenUtil().screenWidth,child:Text("${(initialDates.toList()..sort())
              .map((d) => "${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}")
              .join(", ")}",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.blue,fontSize: 16.sp,),)),

          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
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
          Container(color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
            Container(width: 5.w,),
            Text("時數",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Color(0xff292929))),
            Container(width: 10.w,),
            (sel_EXCUSED_HOURS_ITEM==null)?Container():
            Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.w),
                ),
                //width: 80.w,
                height: 36.h,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<EXCUSED_HOURS_ITEM>(
                    isExpanded: true,
                    hint: Text(
                      '',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: EXCUSED_HOURS_ITEM_list
                        .map((EXCUSED_HOURS_ITEM item) => DropdownMenuItem<EXCUSED_HOURS_ITEM>(
                      value: item,
                      child: Text(
                        item.ITEM_NM,
                        style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.black
                        ),
                      ),
                    ))
                        .toList(),
                    value: sel_EXCUSED_HOURS_ITEM,
                    onChanged: (EXCUSED_HOURS_ITEM? value) {
                      setState(() {
                        sel_EXCUSED_HOURS_ITEM = value;
                      });
                    },
                    buttonStyleData:  ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      height: 40.h,
                      width: 125.w,
                    ),
                    menuItemStyleData:  MenuItemStyleData(
                        height: 40.h,
                        selectedMenuItemBuilder: (c,w){
                          return Container(
                              color: Color(0xffFFDAC8),
                              child:Row(children: [

                                w,
                                Icon(Icons.check,size: 24.sp,),

                              ],));

                        }
                    ),
                  ),
                )),
            Expanded(child: Container()),

            Text("事由",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Color(0xff292929))),
            Container(width: 10.w,),
            (sel_EXCUSED_REASON_ITEM==null)?Container():
            Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.w),
                ),
                //width: 80.w,
                height: 36.h,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<EXCUSED_REASON_ITEM>(
                    isExpanded: true,
                    hint: Text(
                      '',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: EXCUSED_REASON_ITEM_list
                        .map((EXCUSED_REASON_ITEM item) => DropdownMenuItem<EXCUSED_REASON_ITEM>(
                      value: item,
                      child: Text(
                        item.ITEM_NM,
                        style: TextStyle(
                            fontSize: 18.sp,
                            color: Colors.black
                        ),
                      ),
                    ))
                        .toList(),
                    value: sel_EXCUSED_REASON_ITEM,
                    onChanged: (EXCUSED_REASON_ITEM? value) {
                      setState(() {
                        sel_EXCUSED_REASON_ITEM = value;
                      });
                    },
                    buttonStyleData:  ButtonStyleData(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      height: 40.h,
                      width: 110.w,
                    ),
                    menuItemStyleData:  MenuItemStyleData(
                        height: 40.h,
                        selectedMenuItemBuilder: (c,w){
                          return Container(
                              color: Color(0xffFFDAC8),
                              child:Row(children: [

                                w,
                                Icon(Icons.check,size: 24.sp,),

                              ],));

                        }
                    ),
                  ),
                )),
            Container(width: 5.w,),
          ],),),
          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
          Container(height: 10.h,),
          Row(children: [
            Container(width: 5.w,),
            Text("說明",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Color(0xff292929))),
          ]),
          Container(
            //height: 100.h,
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
                  filled: true, //<-- SEE HERE
                  fillColor: Colors.transparent, //<-- SEE HERE
                  hintText: '特別說明',
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
              ))),
          Container(height: 10.h,),
          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
          Container(height: 10.h,),
          Row(children: [
            Container(width: 5.w,),
            Text("家長簽名",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Color(0xff292929))),
          ]),
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
                                        EXCUSED_page_SING_LINK_TYPE = "匯入預設簽名";
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        SmartDialog.showLoading(msg: "處理中...");
                                        EXCUSED_page_signaturebytes = await get_url_image_to_byte_sub(img_url:"${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK}");
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
                                            type: PageTransitionType.rightToLeft, child: SignaturePage4()));
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
              child:(mode=="編輯")?
              Column(children: [
                Center(child:
                (EXCUSED_page_SING_LINK_TYPE=="")?
                Container(padding:EdgeInsets.all(15.w),child:Image.network(eXCUSED.SING_LINK))
                  :
                EXCUSED_page_SING_LINK_TYPE=="匯入預設簽名"?
                Container(padding:EdgeInsets.all(15.w),child:Image.network(CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK))
                  :
                Container(padding:EdgeInsets.all(15.w),child:Image.memory(EXCUSED_page_signaturebytes!))),

                Container(width: ScreenUtil().screenWidth,height: 1,color: Color(0xff292929),),
              ],)
                  :
              Column(children: [
                Center(child:(EXCUSED_page_signaturebytes==null)?
                Text("請按此處加上手寫簽名",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))):
                Container(width: ScreenUtil().screenWidth,height: 100.h,child:
                (EXCUSED_page_SING_LINK_TYPE=="匯入預設簽名")?
                Image.network(CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK)
                    :
                Image.memory(EXCUSED_page_signaturebytes!))),
                Container(height: 10.h,),
                Container(width: ScreenUtil().screenWidth,height: 1,color: Color(0xff292929),),
              ],)),
          Container(height: 30.h,),
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

                  if(mode=="新增"){
                    if(initialDates.isEmpty){
                      SmartDialog.showToast("請填寫請假日期");
                      return;
                    }
                  }
                  else if(dateTime==null){
                    SmartDialog.showToast("請填寫請假日期");
                    return;
                  }

                  if(mode!="編輯" && EXCUSED_page_signaturebytes==null){
                    SmartDialog.showToast("請手動簽名");
                    return;
                  }
                  FocusManager.instance.primaryFocus?.unfocus();
                  SmartDialog.showLoading(msg: "處理中...");
                  await Future.delayed(Duration(milliseconds: 200)); // 模擬異步操作

                  if(mode=="編輯"){

                    try{


                      String file_name = "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT}_${DateTime.now().microsecondsSinceEpoch}";

                      bool check = await update_EXCUSED_db_sub(
                        NO:eXCUSED.NO,//編號
                        DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
                        DEPM_NO:CUSTOMER_selectedValue.DEPM_NO,//學校
                        CLASS_NO:CUSTOMER_selectedValue.CLASS_NO,//班級
                        CS_NO:CUSTOMER_selectedValue.CS_NO,//學生編號
                        NOTE:"${NOTE_textEditingController.text}",//說明
                        HOURS_NO:"${sel_EXCUSED_HOURS_ITEM!.ITEM_NO}",//時數
                        REASON_NO:"${sel_EXCUSED_REASON_ITEM!.ITEM_NO}",//事由
                        ADD_DATE:"${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now())}",//建立日期時間
                        SING_LINK:(EXCUSED_page_SING_LINK_TYPE.isEmpty)?"${eXCUSED.SING_LINK.replaceAll(IMAGE_IP,"~")}":(EXCUSED_page_SING_LINK_TYPE=="匯入預設簽名")?"${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK.replaceAll(IMAGE_IP,"~")}":"~/School/Images/Sign/${file_name}.jpg",//簽名
                        CFM_NO:eXCUSED.CFM_NO,
                      );

                      if(check==false){
                        SmartDialog.dismiss();
                        SmartDialog.showToast("忙碌中，請重試");
                        return;
                      }

                      if(EXCUSED_page_SING_LINK_TYPE=="手動簽名"){
                        await upload_image(img: EXCUSED_page_signaturebytes,file_name: file_name,folder: "Sign");
                      }




                      setState(() {

                      });

                      if(check==true){
                        EXCUSED_page_SING_LINK_TYPE="";
                        EXCUSED_page_signaturebytes=null;//簽名圖檔
                        EXCUSED_page_signatureController.clear();
                        SmartDialog.dismiss();
                        SmartDialog.showToast("編輯請假送出成功");
                        MyHomePage2_U_fun1!(reflash_db:"EXCUSED");
                        Navigator.pop(_context!);
                      }
                      else{
                        SmartDialog.dismiss();
                        SmartDialog.showToast("編輯請假送出失敗");
                      }

                      Future.delayed(const Duration(milliseconds: 500), () async{

                        //找出學生的老師
                        for(int i=0;i<cLASS_NO_for_teacher_chat.length;i++){
                          if(
                          CUSTOMER_selectedValue.DEPM_NO==cLASS_NO_for_teacher_chat[i].DEPM_NO &&
                              CUSTOMER_selectedValue.CLASS_NO==cLASS_NO_for_teacher_chat[i].CLASS_NO
                          ){

                            String FCM = await search_EMPLOYEE_fcm_sub(ACCOUNT:cLASS_NO_for_teacher_chat[i].ACCOUNT);
                            await sendPushNotification(
                                title: "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.USER_NM} 家長",
                                message: "編輯一筆請假委託",
                                token: FCM,//cLASS_NO_for_teacher_chat[i].FCM,
                                ChatID:"請假委託",
                                EXCUSED_NO:"${eXCUSED.NO}",
                                CS_NO:CUSTOMER_selectedValue.CS_NO,
                                DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
                                UserAccount:'${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT.trim()}',
                                TeacherAccount:"${cLASS_NO_for_teacher_chat[i].ACCOUNT}".trim()
                            );
                          }

                        }


                      });



                    }
                    catch(e){
                      dev.log("${e}");
                      SmartDialog.dismiss();
                      SmartDialog.showToast("委託失敗\n${e}");
                    }




                  }
                  else{

                    FocusManager.instance.primaryFocus?.unfocus();
                    String file_name = "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT}_${DateTime.now().microsecondsSinceEpoch}";
                    if(EXCUSED_page_SING_LINK_TYPE!="匯入預設簽名"){
                      await upload_image(img: EXCUSED_page_signaturebytes,file_name: file_name,folder: "Sign");
                    }
                    final dateFormat = DateFormat('yyyy-MM-dd');
                    final values = initialDates
                        .map((date) => "('${dateFormat.format(date)}')") // 轉換成 yyyy-MM-dd
                        .join(",");

                    //先找出目前委託接送所選日期已存在的DRUG_NO號
                    final datesSql = initialDates
                        .map((d) => "'${dateFormat.format(d)}'")
                        .join(",");
                    final comm1 = "SELECT NO FROM EXCUSED WHERE [DATE] IN ($datesSql) AND DEPM_NO = '${CUSTOMER_selectedValue.DEPM_NO}' AND CLASS_NO='${CUSTOMER_selectedValue.CLASS_NO}' AND CS_NO='${CUSTOMER_selectedValue.CS_NO}'";
                    String result1 = await sql_command("${comm1}");
                    List<dynamic> exists_EXCUSED_NOs = jsonDecode(result1);
                    dev.log("exists_EXCUSED_NOs:${exists_EXCUSED_NOs}");

                    String comm = '''BEGIN TRANSACTION;

DECLARE @DEPM_NO NCHAR(4) = N'${CUSTOMER_selectedValue.DEPM_NO}';
DECLARE @CLASS_NO NCHAR(10) = N'${CUSTOMER_selectedValue.CLASS_NO}';
DECLARE @CS_NO NCHAR(10) = N'${CUSTOMER_selectedValue.CS_NO}';
DECLARE @HOURS_NO CHAR(1) = '${sel_EXCUSED_HOURS_ITEM!.ITEM_NO}';
DECLARE @REASON_NO CHAR(1) = '${sel_EXCUSED_REASON_ITEM!.ITEM_NO}';
DECLARE @NOTE NVARCHAR(255) = N'${NOTE_textEditingController.text}';
DECLARE @SING_LINK NVARCHAR(MAX) = N'${(EXCUSED_page_SING_LINK_TYPE=="匯入預設簽名")?"${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK.replaceAll(IMAGE_IP,"~")}":"~/School/Images/Sign/${file_name}.jpg"}';
DECLARE @CFM_NO CHAR(1) = 'N';

DECLARE @dateList TABLE (DATE_VALUE DATE);
INSERT INTO @dateList VALUES $values;

DECLARE @t TABLE (
    DATE_VALUE DATE,
    NEW_NO NCHAR(12)
);

-- ✅ 逐日計算最大 NO，加上 UPDLOCK/HOLDLOCK
INSERT INTO @t (DATE_VALUE, NEW_NO)
SELECT 
    d.DATE_VALUE,
    CONVERT(CHAR(8), d.DATE_VALUE, 112) + 
    RIGHT('000' + CAST(
        ISNULL(CAST(RIGHT(MAX(e.NO), 4) AS INT), 0) + 1 AS VARCHAR(4)
    ), 4) AS NEW_NO
FROM @dateList d
LEFT JOIN [APP].[dbo].[EXCUSED] e WITH (UPDLOCK, HOLDLOCK)
    ON LEFT(e.NO,8) = CONVERT(CHAR(8), d.DATE_VALUE, 112)
GROUP BY d.DATE_VALUE;

-- ✅ 一次插入
INSERT INTO [APP].[dbo].[EXCUSED]
([NO], [DATE], DEPM_NO, CLASS_NO, CS_NO, NOTE, HOURS_NO, REASON_NO, ADD_DATE, SING_LINK, CFM_NO)
SELECT 
    NEW_NO,
    DATE_VALUE,
    @DEPM_NO,
    @CLASS_NO,
    @CS_NO,
    @NOTE,
    @HOURS_NO,
    @REASON_NO,
    GETDATE(),
    @SING_LINK,
    @CFM_NO
FROM @t;

COMMIT;''';
                    String result = await sql_command("${comm}");

                    dev.log("家長請假(回應):${result}");
                    dynamic map = jsonDecode(result);
                    if("${map["message"]}"=="執行成功"){

                      final dateFormat = DateFormat('yyyy-MM-dd');
                      final datesSql = initialDates
                          .map((d) => "'${dateFormat.format(d)}'")
                          .join(",");

                      final comm = "SELECT NO FROM EXCUSED WHERE [DATE] IN ($datesSql) AND DEPM_NO = '${CUSTOMER_selectedValue.DEPM_NO}' AND CLASS_NO='${CUSTOMER_selectedValue.CLASS_NO}' AND CS_NO='${CUSTOMER_selectedValue.CS_NO}'";
                      String result = await sql_command("${comm}");
                      List<dynamic> map = jsonDecode(result);
                      dev.log("map:${map}");

                      // 萃取出存在的 NO 值
                      List<dynamic> existingNos = exists_EXCUSED_NOs.map((e) => e["NO"]).toList();
                      // 過濾掉已存在的 NO
                      map.removeWhere((item) => existingNos.contains(item["NO"]));

                      for(int iii=0;iii<initialDates.length;iii++){
                        SmartDialog.showLoading(msg: "新增處理中...(推播通知${iii+1})");
                        //將接送委託放入聊天室
                        insert_MSDL2_db_sub(EXCUSED_NO:map[iii]["NO"]);
                        //找出學生的老師
                        for(int i=0;i<cLASS_NO_for_teacher_chat.length;i++){
                          if(
                          CUSTOMER_selectedValue.DEPM_NO==cLASS_NO_for_teacher_chat[i].DEPM_NO &&
                              CUSTOMER_selectedValue.CLASS_NO==cLASS_NO_for_teacher_chat[i].CLASS_NO
                          ){

                            String FCM = await search_EMPLOYEE_fcm_sub(ACCOUNT:cLASS_NO_for_teacher_chat[i].ACCOUNT);
                            await sendPushNotification(
                                title: "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.USER_NM} 家長",
                                message: "新增一筆請假委託",
                                token: FCM,//cLASS_NO_for_teacher_chat[i].FCM,
                                ChatID:"請假委託",
                                EXCUSED_NO:"${map[iii]["NO"]}",
                                CS_NO:CUSTOMER_selectedValue.CS_NO,
                                DATE:"${DateFormat('yyyy-MM-dd').format(initialDates[iii])}",//日期
                                UserAccount:'${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT.trim()}',
                                TeacherAccount:"${cLASS_NO_for_teacher_chat[i].ACCOUNT}".trim()
                            );

                          }

                        }


                      }


                      EXCUSED_page_SING_LINK_TYPE="";
                      EXCUSED_page_signaturebytes=null;//簽名圖檔
                      EXCUSED_page_signatureController.clear();
                      SmartDialog.dismiss();
                      SmartDialog.showToast("請假送出成功");
                      MyHomePage2_U_fun1!(reflash_db:"EXCUSED");
                      Navigator.pop(_context!);
                    }
                    else{
                      SmartDialog.dismiss();
                      SmartDialog.showToast("執行失敗,請重新嘗試");
                    }


                    /*
                    for(int iii=0;iii<initialDates.length;iii++){
                      SmartDialog.showLoading(msg: "處理中...(${iii+1})");
                      try{

                        int EXCUSED_NO_num = await read_EXCUSED_db_sub(index:iii);//先確定圖片流水號
                        dev.log("EXCUSED_NO_num:${EXCUSED_NO_num}");
                        if(EXCUSED_NO_num==-1){
                          SmartDialog.dismiss();
                          SmartDialog.showToast("read_EXCUSED_db_sub error");
                          return;
                        }
                        //EXCUSED_NO_num+=1;
                        String EXCUSED_NO = "${EXCUSED_NO_num}";//"${DateFormat('yyyyMMdd').format(initialDates[iii])}${EXCUSED_NO_num.toString().padLeft(4,"0")}";
                        dev.log("EXCUSED_NO:${EXCUSED_NO}");


                        String file_name = "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT}_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}";

                        bool check = await insert_EXCUSED_db_sub(
                          NO:EXCUSED_NO,//編號
                          DATE:"${DateFormat('yyyy-MM-dd').format(initialDates[iii])}",//日期
                          DEPM_NO:"${CUSTOMER_selectedValue.DEPM_NO}",//學校
                          CLASS_NO:"${CUSTOMER_selectedValue.CLASS_NO}",//班級
                          CS_NO:"${CUSTOMER_selectedValue.CS_NO}",//學生編號
                          NOTE:"${NOTE_textEditingController.text}",//說明
                          HOURS_NO:"${sel_EXCUSED_HOURS_ITEM!.ITEM_NO}",//時數
                          REASON_NO:"${sel_EXCUSED_REASON_ITEM!.ITEM_NO}",//事由
                          ADD_DATE:"${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now())}",//建立日期時間
                          SING_LINK:(EXCUSED_page_SING_LINK_TYPE=="匯入預設簽名")?"${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK.replaceAll(IMAGE_IP,"~")}":"~/School/Images/Sign/${file_name}.jpg",//簽名

                          CFM_NO:"N",
                        );

                        if(check==false){
                          SmartDialog.dismiss();
                          SmartDialog.showToast("忙碌中，請重試");
                          return;
                        }

                        if(EXCUSED_page_SING_LINK_TYPE!="匯入預設簽名"){
                          await upload_image(img: EXCUSED_page_signaturebytes,file_name: file_name,folder: "Sign");
                        }




                        setState(() {

                        });

                        if(check==true){

                        }
                        else{
                          SmartDialog.dismiss();
                          SmartDialog.showToast("請假送出失敗");
                        }

                        //找出學生的老師
                        for(int i=0;i<cLASS_NO_for_teacher_chat.length;i++){
                          if(
                          CUSTOMER_selectedValue.DEPM_NO==cLASS_NO_for_teacher_chat[i].DEPM_NO &&
                              CUSTOMER_selectedValue.CLASS_NO==cLASS_NO_for_teacher_chat[i].CLASS_NO
                          ){

                          }
                          await sendPushNotification(
                              title: "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.USER_NM} 家長",
                              message: "新增一筆請假委託",
                              token: cLASS_NO_for_teacher_chat[i].FCM,
                              ChatID:"請假委託",
                              CS_NO:CUSTOMER_selectedValue.CS_NO,
                              DATE:"${DateFormat('yyyy-MM-dd').format(initialDates[iii])}",//日期
                              UserAccount:'${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT.trim()}',
                              TeacherAccount:"${cLASS_NO_for_teacher_chat[i].ACCOUNT}".trim()
                          );
                        }

                        //將接送委託放入聊天室
                        insert_MSDL2_db_sub(EXCUSED_NO:EXCUSED_NO);

                        await Future.delayed(const Duration(milliseconds: 1200), () {});



                      }
                      catch(e){
                        dev.log("${e}");
                        SmartDialog.dismiss();
                        SmartDialog.showToast("委託失敗\n${e}");
                      }

                    }

                     */




                  }


                },
                child: Row(children: [
                  Expanded(child: Container()),
                  Text('送出', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                  Expanded(child: Container()),
                ],),
              )),
          Container(height: 100.h,),

        ],),
    )));
  }
}
