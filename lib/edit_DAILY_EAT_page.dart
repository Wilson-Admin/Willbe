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
import 'dart:developer' as dev;
import 'api.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'package:badges/badges.dart' as badges;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' as ImagePicker;

import 'utils/CustomAppBar.dart';

class Edit_DAILY_EAT_page extends StatefulWidget {

  View_DAILY? view_DAILY;
  Edit_DAILY_EAT_page({View_DAILY? view_DAILY}){
    this.view_DAILY = view_DAILY;
  }
  @override
  State<Edit_DAILY_EAT_page> createState() => Edit_DAILY_EAT_pageState(view_DAILY:this.view_DAILY);
}

class Edit_DAILY_EAT_pageState extends State<Edit_DAILY_EAT_page> {

  TextEditingController OTHER_textEditingController = TextEditingController();//
  TextEditingController SPECIAL_textEditingController = TextEditingController();//

  DateTime? dateTime;
  TimeOfDay? timeOfDay;
  var showModalBottomSheet_image_context;


  List<DAILY_PIC_DL> DAILY_PIC_DLs = [];//活動_子表

  DAILY_EAT_NOTE_ITEM sel_DAILY_EAT_NOTE_ITEM = DAILY_EAT_NOTE_ITEM();
  DAILY_EAT_ITEM sel_DAILY_EAT_ITEM = DAILY_EAT_ITEM();


  View_DAILY? view_DAILY;
  Edit_DAILY_EAT_pageState({View_DAILY? view_DAILY}){
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
    SmartDialog.showLoading(msg: 'loading...');
    dateTime = DateFormat("yyyy-MM-dd").parse(view_DAILY!.DATE);
    timeOfDay = TimeOfDay(hour:int.parse(view_DAILY!.TIME.split(":")[0]),minute: int.parse(view_DAILY!.TIME.split(":")[1]));
    await read_DAILY_EAT_db_sub(NO:view_DAILY!.NO,TYPE:view_DAILY!.TYPE);
    await read_DAILY_PIC_DL_db_sub(NO:view_DAILY!.NO,TYPE:view_DAILY!.TYPE);
    SmartDialog.dismiss();
    setState(() {

    });
  }

  /*

   */
  Future<void> read_DAILY_EAT_db_sub({
    String NO="",
    String TYPE="",
})async{

    String comm = "SELECT * FROM DAILY_EAT WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
        OTHER_textEditingController.text = "${data_list[0]["OTHER"]}";
        SPECIAL_textEditingController.text = "${data_list[0]["SPECIAL"]}";
        for(int i=0;i<DAILY_EAT_ITEMs.length;i++){
          if(DAILY_EAT_ITEMs[i].ITEM_NO=="${data_list[0]["ITEM"]}"){
            sel_DAILY_EAT_ITEM = DAILY_EAT_ITEMs[i];
            break;
          }
        }

        for(int i=0;i<DAILY_EAT_NOTE_ITEMs.length;i++){
          if(DAILY_EAT_NOTE_ITEMs[i].ITEM_NO=="${data_list[0]["NOTE"]}"){
            sel_DAILY_EAT_NOTE_ITEM = DAILY_EAT_NOTE_ITEMs[i];
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
          if(LINK.isNotEmpty) {
            DAILY_PIC_DLs.add(d);
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

    String MARK = "${sel_DAILY_EAT_ITEM.ITEM_NM}/${sel_DAILY_EAT_NOTE_ITEM.ITEM_NM}";
    if(OTHER_textEditingController.text.isNotEmpty){
      MARK = '${MARK}\n${OTHER_textEditingController.text}';
    }
    if(SPECIAL_textEditingController.text.isNotEmpty){
      MARK = '${MARK}\n${SPECIAL_textEditingController.text}';
    }
    await updata_DAILY_MT_db_sub(
        TYPE:"EAT",
        NO:view_DAILY!.NO,//編號
        DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
        TIME:"${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00",//時間
        DEPM_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}",//學校
        CLASS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}",//班級
        CS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",//學生身分證字號
        USER_NO:"${EMPLOYEE_teacher.EMP_NO}",//系統自動帶入老師編號
        MARK:MARK
    );


    //送出[托嬰]便便
    await updata_DAILY_EAT_db_sub(
      TYPE:"EAT",
      NO:view_DAILY!.NO,//編號
      ITEM:"${sel_DAILY_EAT_ITEM.ITEM_NO}",
      NOTE:"${sel_DAILY_EAT_NOTE_ITEM.ITEM_NO}",
      OTHER:"${OTHER_textEditingController.text}",
      SPECIAL:"${SPECIAL_textEditingController.text}",//
    );

    await delete_DAILY_PIC_DL_db_sub(NO:view_DAILY!.NO,TYPE:"EAT");

    DateTime d = DateTime.now();

    /*
    [托嬰]便便 子表
     */
    if(DAILY_PIC_DLs.length==0){
      await insert_DAILY_PIC_DL_db_sub(
        TYPE:"EAT",//
        NO:"${view_DAILY!.NO}",
        SR:"${1}",
        LINK:"",//照片
      );
    }
    else{
      for(int i=0;i<DAILY_PIC_DLs.length;i++){
        if(DAILY_PIC_DLs[i].prescriptionsbytes_xfile!=null){
          //圖片檔名(NO+序號+使用者+日期時間),日期時間 (yyyyMMddHHmmsss)
          String img_name = "${view_DAILY!.NO}_${i+1}_${user.ACCOUNT}_${DateFormat("yyyyMMddHHmmsss").format(DateTime.now())}";

          await upload_image(image_path: DAILY_PIC_DLs[i].prescriptionsbytes_xfile!.path,file_name: img_name,folder: "Daily");
          await insert_DAILY_PIC_DL_db_sub(
            TYPE:"EAT",//
            NO:"${view_DAILY!.NO}",
            SR:"${i+1}",
            LINK:(DAILY_PIC_DLs[i].prescriptionsbytes_xfile==null)?"":"~/School/Images/Daily/${img_name}.jpg",//照片

          );
        }
        else if(DAILY_PIC_DLs[i].LINK.isNotEmpty){
          http.Response response = await http.get(Uri.parse(DAILY_PIC_DLs[i].LINK));//Uint8List
          //圖片檔名(NO+序號+使用者+日期時間),日期時間 (yyyyMMddHHmmsss)
          String img_name = "${DAILY_PIC_DLs[i].NO}_${i+1}_${user.ACCOUNT}_${DateFormat("yyyyMMddHHmmsss").format(DateTime.now())}";

          await upload_image(img: response.bodyBytes,file_name: img_name,folder: "Daily");
          await insert_DAILY_PIC_DL_db_sub(
            TYPE:"EAT",//
            NO:"${view_DAILY!.NO}",
            SR:"${i+1}",
            LINK:"~/School/Images/Daily/${img_name}.jpg",//
          );
        }
      }
    }


    SmartDialog.dismiss();
    SmartDialog.showToast("處理成功");
    Student_T_page_fun!(action:"新增[托嬰/幼兒] 飲食(用餐) 副表 成功");
    DAILY_PIC_DLs.clear();
    OTHER_textEditingController.text="";
    SPECIAL_textEditingController.text="";
    dateTime=null;
    timeOfDay=null;
    Navigator.pop(this_context!);



  }

  Future<void>delete_DAILY_PIC_DL_db_sub({String NO="",String TYPE=""})async{

    //await EasyLoading.show(status: "處理中...");
    String comm = "DELETE FROM DAILY_PIC_DL WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
        String MARK="",//
      })async{

    String comm = "UPDATE DAILY_MT SET DATE='${DATE}',TIME='${TIME}',MARK='${MARK}' WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
  Future<void> updata_DAILY_EAT_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        String ITEM="",//項目
        String NOTE="",//內容
        String OTHER="",//其他
        String SPECIAL="",//特別說明 呈現紅字
      })async{

    String comm = "UPDATE DAILY_EAT SET ITEM='${ITEM}',NOTE='${NOTE}',OTHER='${OTHER}',SPECIAL='${SPECIAL}' WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
  活動_子表
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


                        if(dateTime==null){
                          SmartDialog.showToast("請輸入活動日期");
                          return;
                        }

                        if(timeOfDay==null){
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
                                          title: Text('確定更新?', maxLines: 2,
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
                                              child: Text('更新',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                update_DAILY_MT_db_sub();
                                              },
                                            ),

                                          ],
                                        );
                                      }));
                            });

                      },
                      child: Text("更新", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp))),
                  Container(width: 20.w,),
                ],
                title: Text("編輯${DAILY_MT_TYPE_ITEMs.firstWhere((e)=>e.ITEM_NO=="EAT").ITEM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
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
                Text("項目:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ],),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                child: (DAILY_EAT_ITEMs.length==0 || sel_DAILY_EAT_ITEM.ITEM_NO.isEmpty)?Container():DropdownButton2<DAILY_EAT_ITEM>(
                  isExpanded: true,
                  items: DAILY_EAT_ITEMs
                      .map((DAILY_EAT_ITEM item) => DropdownMenuItem<DAILY_EAT_ITEM>(
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
                  value: sel_DAILY_EAT_ITEM,
                  onChanged: (value) {

                    sel_DAILY_EAT_ITEM = value!;
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
                Text("內容:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ],),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                child: (DAILY_EAT_NOTE_ITEMs.length==0 || sel_DAILY_EAT_NOTE_ITEM.ITEM_NO.isEmpty)?Container():DropdownButton2<DAILY_EAT_NOTE_ITEM>(
                  isExpanded: true,
                  items: DAILY_EAT_NOTE_ITEMs
                      .map((DAILY_EAT_NOTE_ITEM item) => DropdownMenuItem<DAILY_EAT_NOTE_ITEM>(
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
                  value: sel_DAILY_EAT_NOTE_ITEM,
                  onChanged: (value) {

                    sel_DAILY_EAT_NOTE_ITEM = value!;
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
                Text("特別說明:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Colors.red)),
              ],),
              Container(
                  color: Color(0xffEEEEEE),
                  padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                  margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
                  width:ScreenUtil().screenWidth,child: Form(
                  child: TextFormField(
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.red,
                    ),
                    controller: SPECIAL_textEditingController,
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
                            itemBuilder: (BuildContext context) => sel_teacher_Daily_language_menu.menu[3].contants.map((e)=>PopupMenuItem<String>(
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
                              onPressed: (sel_teacher_Daily_language_menu.menu[3].contants.isEmpty)?(){

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
                      (e.LINK.isNotEmpty)?
                      Image.network(e.LINK)
                          :
                      Icon(Icons.camera_alt,color: Colors.white,size: 60.sp)
                          :
                      Image.file(File(e.prescriptionsbytes_xfile!.path))
                      ))),),);
              }).toList(),),


            ],),
        )));
  }
}
