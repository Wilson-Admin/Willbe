import 'dart:convert';
import 'dart:io';
import 'package:code3/signature2.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'dart:developer' as dev;
import 'api.dart';
import 'fcm_notifity.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'utils/CustomAppBar.dart';

Function? entrusted_pick_and_drop_page_U_fun1;
String Entrusted_pick_and_drop_page_SING_LINK_TYPE = "";
class Entrusted_pick_and_drop_page extends StatefulWidget {
  String mode = "新增";
  Entrusted_pick_and_drop_page({String mode = ""}){
    this.mode = mode;
  }
  @override
  State<Entrusted_pick_and_drop_page> createState() => Entrusted_pick_and_drop_pageState(mode:this.mode);
}

class Entrusted_pick_and_drop_pageState extends State<Entrusted_pick_and_drop_page> {

  TextEditingController AGENT_NM_textEditingController = TextEditingController();//代理人姓名
  TextEditingController AGENT_PHONE_textEditingController = TextEditingController();//代理人電話
  TextEditingController NOTE_textEditingController = TextEditingController();//說明
  TextEditingController RELATION_textEditingController = TextEditingController();//關係

  ENTRUSTED_TYPE_ITEM? sel_ENTRUSTED_TYPE_ITEM;

  TimeOfDay? timeOfDay1;

  //CUSTOMER CUSTOMER_selectedValue = CUSTOMER();
  CLASS _class = CLASS();
  DEPM _depm = DEPM();

  BuildContext? _context;
  List<DateTime> initialDates = [];

  String mode = "新增";
  Entrusted_pick_and_drop_pageState({String mode = ""}){
    this.mode = mode;
  }

  @override
  void initState() {
    // TODO: implement initState

    Entrusted_pick_and_drop_page_SING_LINK_TYPE = "";

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    entrusted_pick_and_drop = Entrusted_pick_and_drop();

    entrusted_pick_and_drop_page_U_fun1 = (){
      setState(() {

      });
    };

    //CUSTOMER_selectedValue = cUSTOMERs[0];
    dev.log("CUSTOMER_selectedValue.sel_cUSTOMER_DL.SIGN_LINK:${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK}");



    _class = cLASSs.firstWhere((element) => element.CLASS_NO==CUSTOMER_selectedValue.CLASS_NO)??CLASS();
    _depm = dEPMs.firstWhere((element) => element.DEPM_NO==CUSTOMER_selectedValue.DEPM_NO)??DEPM();

    init();

  }


  init()async{
    await ENTRUSTED_TYPE_ITEM_db_sub();
    setState(() {

    });
  }


  /*
  [托嬰/幼兒] 委託接送
   */
  Future<int> read_ENTRUSTED_db_sub({int index=0})async{

    int ENTRUSTED_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(initialDates[index])}";
    String comm = "SELECT * FROM ENTRUSTED WHERE DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";
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

        ENTRUSTED_NO_num+=1;
        ENTRUSTED_NO_num = int.parse("${DateFormat('yyyyMMdd').format(initialDates[index])}${ENTRUSTED_NO_num.toString().padLeft(4,"0")}");

      }
      else{
        data_list.sort((a,b)=> int.parse(a["NO"]).compareTo(int.parse(b["NO"])));
        String ENTRUSTED_NO = "${data_list[data_list.length-1]["NO"]}";
        dev.log("ENTRUSTED_NO:${ENTRUSTED_NO}");
        //找出流水號
        ENTRUSTED_NO_num = int.parse("${ENTRUSTED_NO}");//int.parse("${ENTRUSTED_NO.substring(ENTRUSTED_NO.length-4,ENTRUSTED_NO.length)}");
        ENTRUSTED_NO_num+=1;
        dev.log("ENTRUSTED_NO_num:${ENTRUSTED_NO_num}");
      }
      setState(() {

      });

    }
    catch(e){
      ENTRUSTED_NO_num=-1;
      dev.log("${e}");
    }

    return ENTRUSTED_NO_num;

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
  [托嬰/幼兒] 委託接送 ENTRUSTED
   */
  Future<bool> insert_ENTRUSTED_db_sub(
      {
        String NO="",//編號
        String DATE="",//日期
        String DEPM_NO="",//學校
        String CLASS_NO="",//班級
        String CS_NO="",//學生編號
        String NOTE="",//說明
        String AGENT_NM="",//代理人姓名
        String AGENT_PHONE="",//代理人電話
        String RELATION="",//關係
        String ADD_DATE="",//建立日期時間
        String SIGN_LINK="",//簽名
      })async{

    String comm = "INSERT INTO ENTRUSTED(NO,DATE,DEPM_NO,CLASS_NO,CS_NO,NOTE,AGENT_NM,AGENT_PHONE,RELATION,ADD_DATE,SIGN_LINK) VALUES ('${NO}','${DATE}','${DEPM_NO}','${CLASS_NO}','${CS_NO}','${NOTE}','${AGENT_NM}','${AGENT_PHONE}','${RELATION}','${ADD_DATE}','${SIGN_LINK}')";
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
  [托嬰/幼兒] 委託接送明細 ENTRUSTED_DL
   */
  Future<void> insert_ENTRUSTED_DL_db_sub(
      {
        String NO="",//編號
        String SR="",//序號
        String TYPE_NO="",//接送
        String TIME="",//時間
      })async{

    String comm = "INSERT INTO ENTRUSTED_DL (NO,SR,TYPE_NO,TIME) VALUES ('${NO}','${SR}','${TYPE_NO}','${TIME}')";
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
        //EasyLoading.showSuccess("用藥委託送出成功");
        //drug_reason = DRUG_REASON();
        setState(() {

        });
      }
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
  將接送委託寫入聊天室
   */
  Future<void> insert_MSDL2_db_sub({String ENTRUSTED_NO=""})async{

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
    String message="您有一筆接送委託通知\n(${ENTRUSTED_NO})";

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
                  MyHomePage2_U_fun1!();
                  Navigator.pop(context);
                },
                child:Icon(Icons.arrow_back,size: 30.w,)),
            centerTitle: true,
            actions: [
              //Text("儲存", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              Container(width: 20.w,),
            ],
            title: Text("委託接送", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
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

                  entrusted_pick_and_drop.dateTime = (await showDatePicker(
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
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 30))))!;

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
                Text((entrusted_pick_and_drop.dateTime==null)?"":"${DateFormat('yyyy年MM月dd日').format(entrusted_pick_and_drop.dateTime!)}",style: TextStyle(
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
            Text("接送",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Color(0xff292929))),
            Container(width: 10.w,),
            Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.w),
                ),
                //width: 80.w,
                height: 36.h,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2<ENTRUSTED_TYPE_ITEM>(
                    isExpanded: true,
                    hint: Text(
                      '',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    items: ENTRUSTED_TYPE_ITEM_list
                        .map((ENTRUSTED_TYPE_ITEM item) => DropdownMenuItem<ENTRUSTED_TYPE_ITEM>(
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
                    value: sel_ENTRUSTED_TYPE_ITEM,
                    onChanged: (ENTRUSTED_TYPE_ITEM? value) {
                      setState(() {
                        sel_ENTRUSTED_TYPE_ITEM = value;
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
            Expanded(child: Container()),

            Text("時間",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Color(0xff292929))),
            Container(width: 10.w,),
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
                  timeOfDay1 = TimeOfDay.fromDateTime(datetime);
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
                  timeOfDay1 = _timeOfDay;
                }
                dev.log("${timeOfDay1!.format(context)}");

                setState(() {

                });

                 */

              },
              child:
              Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.w),
              ),
              child: Center(child:Text((timeOfDay1==null)?"":"${timeOfDay1!.period==DayPeriod.am?"上午":"下午"}${timeOfDay1!.hourOfPeriod}:${timeOfDay1!.minute.toString().padLeft(2,"0")}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w700,color: Colors.blue , fontSize: 16.sp))),
              width: 80.w,
              height: 36.h,)),
            Container(width: 10.w,),
            GestureDetector(
                onTap: (){

                  if(entrusted_pick_and_drop.eNTRUSTED_DL_list.length>=9){
                    SmartDialog.showToast("已超過最大筆數9");
                    return;
                  }

                  if(sel_ENTRUSTED_TYPE_ITEM==null){
                    SmartDialog.showToast("請先選擇接送");
                    return;
                  }
                  ENTRUSTED_DL dd = ENTRUSTED_DL();
                  dd.SR = "${entrusted_pick_and_drop.eNTRUSTED_DL_list.length+1}";
                  dd.TIME = (timeOfDay1==null)?"":"${timeOfDay1!.hour.toString().padLeft(2, '0')}:${timeOfDay1!.minute.toString().padLeft(2, '0')}:00";
                  dd.TYPE_NO = sel_ENTRUSTED_TYPE_ITEM!.ITEM_NO;
                  entrusted_pick_and_drop.eNTRUSTED_DL_list.add(dd);
                  setState(() {

                  });
                },
                child: Icon(Icons.add_circle_outline,size: 24.sp,)),
            Container(width: 5.w,),
          ],),),
          Container(color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,child:
              Row(children: [
                Expanded(child: Container()),
                Text("請按+新增接送時間",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.normal,
                    fontSize: 18.sp,
                    color: Colors.red)),
                Container(width: 5.w,),
              ],)
          ),
          Column(children: entrusted_pick_and_drop.eNTRUSTED_DL_list.map((e) {
            ENTRUSTED_TYPE_ITEM _ENTRUSTED_TYPE_ITEM = ENTRUSTED_TYPE_ITEM_list.firstWhere((element) => element.ITEM_NO==e.TYPE_NO);
            return Container(padding: EdgeInsets.only(top: 5.h,bottom: 5.h),width: ScreenUtil().screenWidth,child:Row(children: [

              Container(width: 5.w,),
              Text("${e.SR}.",style: TextStyle(
                  fontFamily: "GenJyuuGothic",
                  fontWeight: FontWeight.normal,
                  fontSize: 18.sp,
                  color: Color(0xff292929))),
              Container(width: 100.w,child:
              Text("接送:${_ENTRUSTED_TYPE_ITEM==null?"":_ENTRUSTED_TYPE_ITEM.ITEM_NM}",style: TextStyle(
                  fontFamily: "GenJyuuGothic",
                  fontWeight: FontWeight.normal,
                  fontSize: 18.sp,
                  color: Color(0xff292929)))),
              Expanded(child: Container()),

              Text("時間:${e.TIME}",style: TextStyle(
                  fontFamily: "GenJyuuGothic",
                  fontWeight: FontWeight.normal,
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

                                  Row(children: [
                                    Text("接送:${_ENTRUSTED_TYPE_ITEM==null?"":_ENTRUSTED_TYPE_ITEM.ITEM_NM}",style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18.sp,
                                        color: Color(0xff292929))),
                                  ],),
                                  Row(children: [
                                    Text("時間:${e.TIME}",style: TextStyle(
                                        fontFamily: "GenJyuuGothic",
                                        fontWeight: FontWeight.normal,
                                        fontSize: 18.sp,
                                        color: Color(0xff292929))),
                                  ],),


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

                                  int _index = entrusted_pick_and_drop.eNTRUSTED_DL_list.indexOf(e);
                                  entrusted_pick_and_drop.eNTRUSTED_DL_list.removeAt(_index);
                                  for(int count=0;count<entrusted_pick_and_drop.eNTRUSTED_DL_list.length;count++){
                                    entrusted_pick_and_drop.eNTRUSTED_DL_list[count].SR="${count+1}";
                                  }
                                  setState(() {

                                  });
                                  Navigator.pop(context);
//找出答案序
                                },
                              ),
                            ],
                          );
                        });

                  },
                  child: Icon(Icons.delete_forever,size: 24.sp,color: Colors.redAccent,)),
              Container(width: 5.w,),

            ],));
          }).toList(),),
          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
          Container(color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
            Container(width: 5.w,),
            Text("代理人姓名",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Color(0xff292929))),
            Expanded(child: Container()),
            Container(width: 120.w,child:TextFormField(
              style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Colors.blue,
              ),
              textAlign: TextAlign.end,
              controller: AGENT_NM_textEditingController,
              keyboardType: TextInputType.text,
              inputFormatters: [
                //RemoveEmojiInputFormatter()
                SingleQuoteToFullQuoteFormatter(),
              ],
              autofocus: false,
              maxLines: 1,
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
                hintText: '請按此輸入',
                hintStyle: TextStyle(fontWeight: FontWeight.w400,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
                contentPadding:  EdgeInsets.only(left: 0.w,right: 0.w),
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
            )),
            Container(width: 5.w,),
          ],),),
          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
          Container(color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
            Container(width: 5.w,),
            Text("代理人電話",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Color(0xff292929))),
            Expanded(child: Container()),
            Container(width: 120.w,child:TextFormField(
              style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Colors.blue,
              ),
              textAlign: TextAlign.end,
              controller: AGENT_PHONE_textEditingController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                //RemoveEmojiInputFormatter()
              ],
              autofocus: false,
              maxLines: 1,
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
                hintText: '請按此輸入',
                hintStyle: TextStyle(fontWeight: FontWeight.w400,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
                contentPadding:  EdgeInsets.only(left: 0.w,right: 0.w),
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
            )),

            Container(width: 5.w,),
          ],),),
          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
          Container(color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: Row(children: [
            Container(width: 5.w,),
            Text("關係",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Color(0xff292929))),
            Expanded(child: Container()),
            Container(width: 120.w,child:TextFormField(
              style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Colors.blue,
              ),
              textAlign: TextAlign.end,
              controller: RELATION_textEditingController,
              keyboardType: TextInputType.text,
              inputFormatters: [
                //RemoveEmojiInputFormatter()
                SingleQuoteToFullQuoteFormatter(),
              ],
              autofocus: false,
              maxLines: 1,
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
                hintText: '請按此輸入',
                hintStyle: TextStyle(fontWeight: FontWeight.w400,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
                contentPadding:  EdgeInsets.only(left: 0.w,right: 0.w),
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
            )),

            Container(width: 5.w,),
          ],),),
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
                                      FocusManager.instance.primaryFocus?.unfocus();
                                      SmartDialog.showLoading(msg: "處理中...");
                                      await Future.delayed(const Duration(milliseconds: 500), () {});
                                      Entrusted_pick_and_drop_page_SING_LINK_TYPE = "匯入預設簽名";
                                      entrusted_pick_and_drop.signaturebytes = await get_url_image_to_byte_sub(img_url:"${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK}");
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
                                          type: PageTransitionType.rightToLeft, child: SignaturePage2()));
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
          Column(children: [
            Center(child:(entrusted_pick_and_drop.signaturebytes==null)?
            Text("請按此處加上手寫簽名",style: TextStyle(
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
                color: Color(0xff292929))):
            Container(width: ScreenUtil().screenWidth,height: 100.h,child:
            (Entrusted_pick_and_drop_page_SING_LINK_TYPE == "匯入預設簽名")?
            Image.network(CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK)
              :
            Image.memory(entrusted_pick_and_drop.signaturebytes!))),
            Container(height: 10.h,),
            Container(width: ScreenUtil().screenWidth,height: 1,color: Color(0xff292929),),
          ],)),
          Container(height: 10.h,),
          Row(children: [
            Container(width: 5.w,),
            Text("特別說明",style: TextStyle(
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
                //enableSuggestions: false,
                //autocorrect: false,
                //enableInteractiveSelection:false,
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
                      Fluttertoast.showToast(
                          msg: "請填寫委託日期",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0.sp
                      );
                      return;
                    }
                  }
                  else if(entrusted_pick_and_drop.dateTime==null){
                    Fluttertoast.showToast(
                        msg: "請填寫委託日期",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0.sp
                    );
                    return;
                  }

                  if(entrusted_pick_and_drop.signaturebytes==null){
                    Fluttertoast.showToast(
                        msg: "請手動簽名",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0.sp
                    );
                    return;
                  }

                  if(entrusted_pick_and_drop.eNTRUSTED_DL_list.isEmpty){
                    Fluttertoast.showToast(
                        msg: "請按+新增接送時間",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0.sp
                    );
                    return;
                  }

                  FocusManager.instance.primaryFocus?.unfocus();

                  SmartDialog.showLoading(msg: "處理中...");
                  await Future.delayed(const Duration(milliseconds: 500), () {});
                  /*
                  for(int iii=0;iii<initialDates.length;iii++){
                    SmartDialog.showLoading(msg: "處理中...(${iii+1})");
                    try{


                      int ENTRUSTED_NO_num = await read_ENTRUSTED_db_sub(index:iii);//先確定圖片流水號
                      dev.log("ENTRUSTED_NO_num:${ENTRUSTED_NO_num}");
                      if(ENTRUSTED_NO_num==-1){
                        SmartDialog.dismiss();
                        SmartDialog.showToast("read_ENTRUSTED_db_sub error");
                        return;
                      }
                      //ENTRUSTED_NO_num+=1;
                      String ENTRUSTED_NO = "${ENTRUSTED_NO_num}";//"${DateFormat('yyyyMMdd').format(initialDates[iii])}${ENTRUSTED_NO_num.toString().padLeft(4,"0")}";
                      dev.log("ENTRUSTED_NO:${ENTRUSTED_NO}");


                      String file_name = "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT}_${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}";

                      bool check = await insert_ENTRUSTED_db_sub(
                        NO:ENTRUSTED_NO,//編號
                        DATE:"${DateFormat('yyyy-MM-dd').format(initialDates[iii])}",//日期
                        DEPM_NO:"${CUSTOMER_selectedValue.DEPM_NO}",//學校
                        CLASS_NO:"${CUSTOMER_selectedValue.CLASS_NO}",//班級
                        CS_NO:"${CUSTOMER_selectedValue.CS_NO}",//學生編號
                        NOTE:"${NOTE_textEditingController.text}",//說明
                        AGENT_NM:"${AGENT_NM_textEditingController.text}",//代理人姓名
                        AGENT_PHONE:"${AGENT_PHONE_textEditingController.text}",//代理人電話
                        RELATION:"${RELATION_textEditingController.text}",//關係
                        ADD_DATE:"${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now())}",//建立日期時間
                        SIGN_LINK:(Entrusted_pick_and_drop_page_SING_LINK_TYPE == "匯入預設簽名")?"${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK.replaceAll(IMAGE_IP,"~")}":"~/School/Images/Sign/${file_name}.jpg",//簽名
                      );

                      if(check==false){
                        SmartDialog.dismiss();
                        SmartDialog.showToast("忙碌中，請重試");
                        return;
                      }

                      if(Entrusted_pick_and_drop_page_SING_LINK_TYPE!="匯入預設簽名") {
                        await upload_image(img: entrusted_pick_and_drop.signaturebytes,
                            file_name: file_name,
                            folder: "Sign");
                      }

                      for(int i=0;i<entrusted_pick_and_drop.eNTRUSTED_DL_list.length;i++){
                        entrusted_pick_and_drop.eNTRUSTED_DL_list[i].NO = ENTRUSTED_NO;
                      }

                      //送出明細
                      for(int i=0;i<entrusted_pick_and_drop.eNTRUSTED_DL_list.length;i++){
                        await insert_ENTRUSTED_DL_db_sub(
                          NO:"${entrusted_pick_and_drop.eNTRUSTED_DL_list[i].NO}",//編號
                          SR:"${entrusted_pick_and_drop.eNTRUSTED_DL_list[i].SR}",
                          TYPE_NO:"${entrusted_pick_and_drop.eNTRUSTED_DL_list[i].TYPE_NO}",
                          TIME:"${entrusted_pick_and_drop.eNTRUSTED_DL_list[i].TIME}",
                        );
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
                            message: "新增一筆接送委託",
                            token: cLASS_NO_for_teacher_chat[i].FCM,
                            ChatID:"接送委託",
                            CS_NO:CUSTOMER_selectedValue.CS_NO,
                            DATE:"${DateFormat('yyyy-MM-dd').format(initialDates[iii])}",//日期
                            UserAccount:'${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT.trim()}',
                            TeacherAccount:"${cLASS_NO_for_teacher_chat[i].ACCOUNT}".trim()
                        );
                      }

                      //將接送委託放入聊天室
                      insert_MSDL2_db_sub(ENTRUSTED_NO:ENTRUSTED_NO);

                      await Future.delayed(const Duration(milliseconds: 1200), () {});


                    }
                    catch(e){
                      dev.log("${e}");
                      SmartDialog.dismiss();
                      SmartDialog.showToast("委託失敗\n${e}");
                    }
                  }

                   */
                  String file_name = "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT}_${DateTime.now().microsecondsSinceEpoch}";
                  if(Entrusted_pick_and_drop_page_SING_LINK_TYPE!="匯入預設簽名") {
                    await upload_image(img: entrusted_pick_and_drop.signaturebytes,
                        file_name: file_name,
                        folder: "Sign");
                  }
                  final dateFormat = DateFormat('yyyy-MM-dd');
                  final values = initialDates
                      .map((date) => "('${dateFormat.format(date)}')") // 轉換成 yyyy-MM-dd
                      .join(",");

                  final valuesDl = <String>[];
                  for (int i = 0; i < initialDates.length; i++) {
                    final dateStr = dateFormat.format(initialDates[i]);
                    for (int j = 0; j < entrusted_pick_and_drop.eNTRUSTED_DL_list.length; j++) {
                      valuesDl.add("('$dateStr', '${entrusted_pick_and_drop.eNTRUSTED_DL_list[j].TYPE_NO}', '${entrusted_pick_and_drop.eNTRUSTED_DL_list[j].TIME}')");
                    }
                  }
                  String valuesDlStr = valuesDl.join(",");


                  //先找出目前委託接送所選日期已存在的DRUG_NO號
                  final datesSql = initialDates
                      .map((d) => "'${dateFormat.format(d)}'")
                      .join(",");
                  final comm1 = "SELECT NO FROM ENTRUSTED WHERE [DATE] IN ($datesSql) AND DEPM_NO = '${CUSTOMER_selectedValue.DEPM_NO}' AND CLASS_NO='${CUSTOMER_selectedValue.CLASS_NO}' AND CS_NO='${CUSTOMER_selectedValue.CS_NO}'";
                  String result1 = await sql_command("${comm1}");
                  List<dynamic> exists_ENTRUSTED_NOs = jsonDecode(result1);
                  dev.log("exists_ENTRUSTED_NOs:${exists_ENTRUSTED_NOs}");

                  String comm = '''
                  BEGIN TRANSACTION;

-- 1) 參數宣告
DECLARE @DEPM_NO     NCHAR(4)   = N'${CUSTOMER_selectedValue.DEPM_NO}';
DECLARE @CLASS_NO    NCHAR(10)  = N'${CUSTOMER_selectedValue.CLASS_NO}';
DECLARE @CS_NO       NCHAR(10)  = N'${CUSTOMER_selectedValue.CS_NO}';
DECLARE @REASON_NO   CHAR(1)    = N'${sel_EXCUSED_REASON_ITEM!.ITEM_NO}';
DECLARE @NOTE        NVARCHAR(255) = N'${NOTE_textEditingController.text}';
DECLARE @RELATION    NVARCHAR(255) = N'${RELATION_textEditingController.text}';
DECLARE @AGENT_NM    NVARCHAR(255) = N'${AGENT_NM_textEditingController.text}';
DECLARE @AGENT_PHONE NVARCHAR(255) = N'${AGENT_PHONE_textEditingController.text}';
DECLARE @SING_LINK   NVARCHAR(MAX) = N'${
                      (Entrusted_pick_and_drop_page_SING_LINK_TYPE == "匯入預設簽名")
                          ? "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK.replaceAll(IMAGE_IP,"~")}"
                          : "~/School/Images/Sign/${file_name}.jpg"
                  }';

-- 2) 日期清單
DECLARE @dateList TABLE (DATE_VALUE DATE);
INSERT INTO @dateList (DATE_VALUE) VALUES $values;  -- e.g. ('2025-09-01'),('2025-09-01'),('2025-09-02')

-- 3) 生成每筆 ENTRUSTED 的 NO
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
    SELECT MAX(CAST(RIGHT(NO,4) AS INT)) AS MaxSeq
    FROM [APP].[dbo].[ENTRUSTED] e WITH (UPDLOCK,HOLDLOCK)
    WHERE LEFT(e.NO,8)=CONVERT(CHAR(8), d.DATE_VALUE,112)
) MaxNo;

-- 4) 插入 ENTRUSTED 主表
INSERT INTO [APP].[dbo].[ENTRUSTED]
([NO],[DATE],DEPM_NO,CLASS_NO,CS_NO,NOTE,AGENT_NM,AGENT_PHONE,RELATION,ADD_DATE,SIGN_LINK)
SELECT 
    NEW_NO,
    DATE_VALUE,
    @DEPM_NO,
    @CLASS_NO,
    @CS_NO,
    @NOTE,
    @AGENT_NM,
    @AGENT_PHONE,
    @RELATION,
    GETDATE(),
    @SING_LINK
FROM @t;

-- 5) 子表資料
DECLARE @ENTRUSTED_DL TABLE (DATE_VALUE DATE, TYPE_NO NVARCHAR(10), TIME NVARCHAR(20));
INSERT INTO @ENTRUSTED_DL (DATE_VALUE, TYPE_NO, TIME)
VALUES $valuesDlStr;

-- 6) 插入 ENTRUSTED_DL
WITH cte AS (
    SELECT 
        dl.DATE_VALUE,
        dl.TYPE_NO,
        dl.TIME,
        ROW_NUMBER() OVER (PARTITION BY dl.DATE_VALUE ORDER BY (SELECT NULL)) AS rn  -- SR 自動 +1
    FROM @ENTRUSTED_DL dl
)
INSERT INTO [APP].[dbo].[ENTRUSTED_DL] (NO, SR, TYPE_NO, TIME)
SELECT
    t.NEW_NO,
    c.rn,  -- SR 是每日期子表序號從1開始遞增
    c.TYPE_NO,
    c.TIME
FROM cte c
JOIN @t t ON t.DATE_VALUE = c.DATE_VALUE;

COMMIT;

                  ''';
                  String result = await sql_command("${comm}");
                  dev.log("家長委託接送(回應):${result}");
                  try{
                    dynamic map = jsonDecode(result);
                    if("${map["message"]}"=="執行成功"){


                      final dateFormat = DateFormat('yyyy-MM-dd');
                      final datesSql = initialDates
                          .map((d) => "'${dateFormat.format(d)}'")
                          .join(",");

                      final comm = "SELECT NO FROM ENTRUSTED WHERE [DATE] IN ($datesSql) AND DEPM_NO = '${CUSTOMER_selectedValue.DEPM_NO}' AND CLASS_NO='${CUSTOMER_selectedValue.CLASS_NO}' AND CS_NO='${CUSTOMER_selectedValue.CS_NO}'";
                      String result = await sql_command("${comm}");
                      dynamic map = jsonDecode(result);
                      dev.log("map:${map}");

                      // 萃取出存在的 NO 值
                      List<dynamic> existingNos = exists_ENTRUSTED_NOs.map((e) => e["NO"]).toList();
                      // 過濾掉已存在的 NO
                      map.removeWhere((item) => existingNos.contains(item["NO"]));

                      for(int iii=0;iii<map.length;iii++){
                        insert_MSDL2_db_sub(ENTRUSTED_NO:map[iii]["NO"]);
                      }

                      for(int iii=0;iii<initialDates.length;iii++){

                        //找出學生的老師
                        for(int i=0;i<cLASS_NO_for_teacher_chat.length;i++){
                          if(
                          CUSTOMER_selectedValue.DEPM_NO==cLASS_NO_for_teacher_chat[i].DEPM_NO &&
                              CUSTOMER_selectedValue.CLASS_NO==cLASS_NO_for_teacher_chat[i].CLASS_NO
                          ){
                            String FCM = await search_EMPLOYEE_fcm_sub(ACCOUNT:cLASS_NO_for_teacher_chat[i].ACCOUNT);
                            await sendPushNotification(
                                title: "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.USER_NM} 家長",
                                message: "新增一筆接送委託",
                                token: FCM,//cLASS_NO_for_teacher_chat[i].FCM,
                                ChatID:"接送委託",
                                ENTRUSTED_NO:"${map[iii]["NO"]}",
                                CS_NO:CUSTOMER_selectedValue.CS_NO,
                                DATE:"${DateFormat('yyyy-MM-dd').format(initialDates[iii])}",//日期
                                UserAccount:'${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT.trim()}',
                                TeacherAccount:"${cLASS_NO_for_teacher_chat[i].ACCOUNT}".trim()
                            );
                          }

                        }

                        //將接送委託放入聊天室
                        //insert_MSDL2_db_sub(ENTRUSTED_NO:ENTRUSTED_NO);
                      }


                      Entrusted_pick_and_drop_page_SING_LINK_TYPE="";
                      AGENT_NM_textEditingController.text="";
                      NOTE_textEditingController.text="";
                      AGENT_PHONE_textEditingController.text="";
                      RELATION_textEditingController.text="";
                      sel_ENTRUSTED_TYPE_ITEM=null;
                      timeOfDay1=null;
                      SmartDialog.dismiss();
                      SmartDialog.showToast("委託接送成功");
                      MyHomePage2_U_fun1!(reflash_db:"委託接送刷新");
                      Navigator.pop(_context!);
                    }
                    else{
                      SmartDialog.dismiss();
                      SmartDialog.showToast("執行失敗,請重新嘗試");
                    }
                  }
                  catch(e){
                    SmartDialog.dismiss();
                    SmartDialog.showToast("執行失敗,請重新嘗試");
                  }




                  /*
                    entrusted_pick_and_drop = Entrusted_pick_and_drop();
                    setState(() {

                    });

                     */





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
