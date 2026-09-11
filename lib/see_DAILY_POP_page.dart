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

class See_DAILY_POP_page extends StatefulWidget {

  View_DAILY? view_DAILY;
  See_DAILY_POP_page({View_DAILY? view_DAILY}){
    this.view_DAILY = view_DAILY;
  }
  @override
  State<See_DAILY_POP_page> createState() => See_DAILY_POP_pageState(view_DAILY:this.view_DAILY);
}

class See_DAILY_POP_pageState extends State<See_DAILY_POP_page> {

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
  RadioGroupController is_red_radioGroup_controller = RadioGroupController();
  RadioGroupController is_SOUR_radioGroup_controller = RadioGroupController();


  View_DAILY? view_DAILY;
  See_DAILY_POP_pageState({View_DAILY? view_DAILY}){
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
    //await read_DAILY_POP_db_sub(NO:view_DAILY!.NO,TYPE:view_DAILY!.TYPE);
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

    await updata_DAILY_MT_db_sub(
        TYPE:"POP",
        NO:view_DAILY!.NO,//編號
        DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
        TIME:"${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00",//時間
        DEPM_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}",//學校
        CLASS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}",//班級
        CS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",//學生身分證字號
        USER_NO:"${EMPLOYEE_teacher.EMP_NO}",//系統自動帶入老師編號
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

    await delete_DAILY_PIC_DL_db_sub(NO:view_DAILY!.NO);

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
                  Navigator.pop(context);
                },
                child:Icon(Icons.arrow_back,size: 30.w,)),
                centerTitle: true,
                title: Text("${DAILY_MT_TYPE_ITEMs.firstWhere((e)=>e.ITEM_NO=="POP").ITEM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              ),
          body: ListView(
            controller: listScrollController,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [

              Container(height: 20.h,),
              Row(children: [
                Container(width: 10.w,),
                Expanded(child:
                Text("${view_DAILY!.MARK}",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929)))),
                Container(width: 10.w,),
              ],),
              Container(height: 20.h,),
              Column(children: DAILY_PIC_DLs.map((e){
                return Container(
                      margin: EdgeInsets.only(left:8.w,right: 8.w,top: 5.h,bottom: 5.h),
                      width: ScreenUtil().screenWidth,child:  GestureDetector(
                           onTap:(){

                             showImageViewer(this.context,e.LINK);

                           },
                           child: Container(width: ScreenUtil().screenWidth,height: 200.h,color: Colors.transparent,child:
                           Center(child:(e.prescriptionsbytes_xfile==null)?
                           (e.LINK.isNotEmpty)?
                           Image.network(e.LINK)
                               :
                           Icon(Icons.camera_alt,color: Colors.white,size: 60.sp)
                               :
                           Image.file(File(e.prescriptionsbytes_xfile!.path))
                           ))),);
              }).toList(),),


            ],),
        )));
  }
}
