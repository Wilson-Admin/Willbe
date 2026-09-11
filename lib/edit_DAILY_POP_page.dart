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
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart' as ImagePicker;

import 'utils/CustomAppBar.dart';

class Edit_DAILY_POP_page extends StatefulWidget {

  View_DAILY? view_DAILY;
  Edit_DAILY_POP_page({View_DAILY? view_DAILY}){
    this.view_DAILY = view_DAILY;
  }
  @override
  State<Edit_DAILY_POP_page> createState() => Edit_DAILY_POP_pageState(view_DAILY:this.view_DAILY);
}

class Edit_DAILY_POP_pageState extends State<Edit_DAILY_POP_page> {

  TextEditingController OTHER_textEditingController = TextEditingController();//

  DateTime? dateTime;
  TimeOfDay? timeOfDay;
  var showModalBottomSheet_image_context;


  List<DAILY_PIC_DL> DAILY_PIC_DLs = [];//活動_子表

  DAILY_POP_HARD_ITEM sel_DAILY_POP_HARD_ITEM = DAILY_POP_HARD_ITEM();
  DAILY_POP_COLOR_ITEM sel_DAILY_POP_COLOR_ITEM = DAILY_POP_COLOR_ITEM();
  DAILY_POP_QUANTITY_ITEM sel_DAILY_POP_QUANTITY_ITEM = DAILY_POP_QUANTITY_ITEM();

  bool? is_RED;//紅屁股
  bool? is_SOUR;//聞起來酸
  rg.RadioGroupController is_red_radioGroup_controller = rg.RadioGroupController();
  rg.RadioGroupController is_SOUR_radioGroup_controller = rg.RadioGroupController();


  View_DAILY? view_DAILY;
  Edit_DAILY_POP_pageState({View_DAILY? view_DAILY}){
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
    await read_DAILY_POP_db_sub(NO:view_DAILY!.NO,TYPE:view_DAILY!.TYPE);
    await read_DAILY_PIC_DL_db_sub(NO:view_DAILY!.NO,TYPE:view_DAILY!.TYPE);
    SmartDialog.dismiss();
    setState(() {

    });
  }

  /*

   */
  Future<void> read_DAILY_POP_db_sub({
    String NO="",
    String TYPE="",
})async{

    String comm = "SELECT * FROM DAILY_POP WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
        for(int i=0;i<DAILY_POP_HARD_ITEMs.length;i++){
          if(DAILY_POP_HARD_ITEMs[i].ITEM_NO=="${data_list[0]["HARD"]}"){
            sel_DAILY_POP_HARD_ITEM = DAILY_POP_HARD_ITEMs[i];
            break;
          }
        }

        for(int i=0;i<DAILY_POP_COLOR_ITEMs.length;i++){
          if(DAILY_POP_COLOR_ITEMs[i].ITEM_NO=="${data_list[0]["COLOR"]}"){
            sel_DAILY_POP_COLOR_ITEM = DAILY_POP_COLOR_ITEMs[i];
            break;
          }
        }

        for(int i=0;i<DAILY_POP_QUANTITY_ITEMs.length;i++){
          if(DAILY_POP_QUANTITY_ITEMs[i].ITEM_NO=="${data_list[0]["QUANTITY"]}"){
            sel_DAILY_POP_QUANTITY_ITEM = DAILY_POP_QUANTITY_ITEMs[i];
            break;
          }
        }

        is_RED = ("${data_list[0]["RED"]}"=="true"||"${data_list[0]["RED"]}"=="1")?true:false;
        is_SOUR = ("${data_list[0]["SOUR"]}"=="true"||"${data_list[0]["SOUR"]}"=="1")?true:false;
        is_red_radioGroup_controller.selectAt(("${data_list[0]["RED"]}"=="true"||"${data_list[0]["RED"]}"=="1")?0:1);
        is_SOUR_radioGroup_controller.selectAt(("${data_list[0]["SOUR"]}"=="true"||"${data_list[0]["SOUR"]}"=="1")?0:1);

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

    String MARK = "硬度:${sel_DAILY_POP_HARD_ITEM.ITEM_NM}/顏色:${sel_DAILY_POP_COLOR_ITEM.ITEM_NM}/數量:${sel_DAILY_POP_QUANTITY_ITEM.ITEM_NM}";
    if(is_RED==true){
      MARK = "${MARK}/紅屁股";
    }
    if(is_SOUR==true){
      MARK = "${MARK}/聞起來酸";
    }
    if(OTHER_textEditingController.text.isNotEmpty){
      MARK = "${MARK}\n${OTHER_textEditingController.text}";
    }
    await updata_DAILY_MT_db_sub(
        TYPE:"POP",
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
    await updata_DAILY_POP_db_sub(
      TYPE:"POP",
      NO:view_DAILY!.NO,//編號
      HARD:"${sel_DAILY_POP_HARD_ITEM.ITEM_NO}",//
      COLOR:"${sel_DAILY_POP_COLOR_ITEM.ITEM_NO}",//
      QUANTITY:"${sel_DAILY_POP_QUANTITY_ITEM.ITEM_NO}",//
      RED:is_RED==null?null:is_RED,//
      SOUR:is_SOUR==null?null:is_SOUR,//
      OTHER:"${OTHER_textEditingController.text}",//
    );

    await delete_DAILY_PIC_DL_db_sub(NO:view_DAILY!.NO,TYPE:"POP");

    DateTime d = DateTime.now();

    /*
    [托嬰]便便 子表
     */
    if(DAILY_PIC_DLs.length==0){
      await insert_DAILY_PIC_DL_db_sub(
        TYPE:"POP",//
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
            TYPE:"POP",//
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
            TYPE:"POP",//
            NO:"${view_DAILY!.NO}",
            SR:"${i+1}",
            LINK:"~/School/Images/Daily/${img_name}.jpg",//
          );
        }
      }
    }


    SmartDialog.dismiss();
    SmartDialog.showToast("處理成功");
    Student_T_page_fun!(action:"新增[托嬰]便便 成功");
    DAILY_PIC_DLs.clear();
    OTHER_textEditingController.text="";
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
  Future<void> updata_DAILY_POP_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        String HARD="",//硬度
        String COLOR="",//顏色
        String QUANTITY="",//數量
        bool? RED,//紅屁股
        bool? SOUR,//聞起來酸
        String OTHER="",//其他
      })async{

    String comm = "UPDATE DAILY_POP SET HARD='${HARD}',COLOR='${COLOR}',QUANTITY='${QUANTITY}',RED='${RED}',SOUR='${SOUR}',OTHER='${OTHER}' WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
                title: Text("編輯${DAILY_MT_TYPE_ITEMs.firstWhere((e)=>e.ITEM_NO=="POP").ITEM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
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
                Text("硬度:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ],),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                child: (sel_DAILY_POP_HARD_ITEM.ITEM_NM.isEmpty)?Container():DropdownButton2<DAILY_POP_HARD_ITEM>(
                  isExpanded: true,
                  items: DAILY_POP_HARD_ITEMs
                      .map((DAILY_POP_HARD_ITEM item) => DropdownMenuItem<DAILY_POP_HARD_ITEM>(
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
                  value: sel_DAILY_POP_HARD_ITEM,
                  onChanged: (value) {

                    sel_DAILY_POP_HARD_ITEM = value!;
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
                Text("顏色:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ],),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                child: (sel_DAILY_POP_COLOR_ITEM.ITEM_NM.isEmpty)?Container():DropdownButton2<DAILY_POP_COLOR_ITEM>(
                  isExpanded: true,
                  items: DAILY_POP_COLOR_ITEMs
                      .map((DAILY_POP_COLOR_ITEM item) => DropdownMenuItem<DAILY_POP_COLOR_ITEM>(
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
                  value: sel_DAILY_POP_COLOR_ITEM,
                  onChanged: (value) {

                    sel_DAILY_POP_COLOR_ITEM = value!;
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
                Text("數量:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ],),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),color: Color(0xffEEEEEE),width:ScreenUtil().screenWidth,height:50.h,child: DropdownButtonHideUnderline(
                child: (sel_DAILY_POP_QUANTITY_ITEM.ITEM_NM.isEmpty)?Container():DropdownButton2<DAILY_POP_QUANTITY_ITEM>(
                  isExpanded: true,
                  items: DAILY_POP_QUANTITY_ITEMs
                      .map((DAILY_POP_QUANTITY_ITEM item) => DropdownMenuItem<DAILY_POP_QUANTITY_ITEM>(
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
                  value: sel_DAILY_POP_QUANTITY_ITEM,
                  onChanged: (value) {

                    sel_DAILY_POP_QUANTITY_ITEM = value!;
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
                Expanded(child:Text("紅屁股:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929)))),
                Expanded(flex:3,child: rg.RadioGroup(
                  controller: is_red_radioGroup_controller,
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
                      is_RED = true;
                    }
                    else{
                      is_RED = false;
                    }
                  },
                )),
              ],),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 15.h,),
              Row(children: [
                Container(width: 10.w,),
                Expanded(child: Text("聞起來酸:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929)))),
                Expanded(flex:3,child: rg.RadioGroup(
                  controller: is_SOUR_radioGroup_controller,
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
                      is_SOUR = true;
                    }
                    else{
                      is_SOUR = false;
                    }
                  },
                )),
              ],),
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
                    textInputAction: TextInputAction.newline,
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
