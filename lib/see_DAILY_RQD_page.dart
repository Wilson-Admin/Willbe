import 'dart:convert';
import 'dart:io';
import 'package:code3/main2_T.dart';
import 'package:code3/signature2.dart';
import 'package:code3/signature4.dart';
import 'package:code3/signature7.dart';
import 'package:code3/signature8.dart';
import 'package:code3/student_T.dart';
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
import 'dart:developer' as dev;
import 'api.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'package:badges/badges.dart' as badges;
import 'package:http/http.dart' as http;

import 'utils/CustomAppBar.dart';


Function? See_DAILY_RQD_page_U_fun1;
Uint8List? See_DAILY_RQD_page_signaturebytes;//簽名圖檔
String See_DAILY_RQD_page_SING_LINK_TYPE = "";
SignatureController See_DAILY_RQD_page_signatureController = SignatureController(
  penStrokeWidth: 5,
  penColor: Colors.black,
  exportBackgroundColor: Colors.white,
);
class See_DAILY_RQD_page extends StatefulWidget {

  View_DAILY? view_DAILY;
  See_DAILY_RQD_page({View_DAILY? view_DAILY}){
    this.view_DAILY = view_DAILY;
  }
  @override
  State<See_DAILY_RQD_page> createState() => See_DAILY_RQD_pageState(view_DAILY:this.view_DAILY);
}

class See_DAILY_RQD_pageState extends State<See_DAILY_RQD_page> {

  TextEditingController NOTE_textEditingController = TextEditingController();//備註
  TextEditingController WEB_LINK_textEditingController = TextEditingController();//備註
  TextEditingController RCPT_IMO_textEditingController = TextEditingController();//家長意見

  DateTime? dateTime;
  TimeOfDay? timeOfDay;
  var showModalBottomSheet_image_context;
  bool RECIPIENT = false;//讀取回條

  List<DAILY_PIC_DL> DAILY_PIC_DLs = [];//活動_子表
  CLASS _class = CLASS();
  DEPM _depm = DEPM();

  View_DAILY? view_DAILY;
  See_DAILY_RQD_pageState({View_DAILY? view_DAILY}){
    this.view_DAILY = view_DAILY;
  }

  BuildContext? this_context;

  String SIGN_LINK = "";//簽名檔

  @override
  void initState() {
    // TODO: implement initState

    See_DAILY_RQD_page_SING_LINK_TYPE="";

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();


    See_DAILY_RQD_page_signaturebytes=null;
    See_DAILY_RQD_page_U_fun1 = (){
      setState(() {

      });
    };

    _class = cLASSs.firstWhere((element) => element.CLASS_NO==CUSTOMER_selectedValue.CLASS_NO)??CLASS();
    _depm = dEPMs.firstWhere((element) => element.DEPM_NO==CUSTOMER_selectedValue.DEPM_NO)??DEPM();

    init();
  }


  void init()async{
    dateTime = DateFormat("yyyy-MM-dd").parse(view_DAILY!.DATE);
    timeOfDay = TimeOfDay(hour:int.parse(view_DAILY!.TIME.split(":")[0]),minute: int.parse(view_DAILY!.TIME.split(":")[1]));
    await read_DAILY_MT_TYPE_ITEM_db_sub();
    await read_DAILY_RQD_db_sub(NO:view_DAILY!.NO,TYPE:view_DAILY!.TYPE);
    await read_DAILY_PIC_DL_db_sub(NO:view_DAILY!.NO,TYPE:view_DAILY!.TYPE);
  }



  Future<void> read_DAILY_MT_TYPE_ITEM_db_sub()async{

    DAILY_MT_TYPE_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_MT_TYPE_ITEM WHERE DEPM_NO='${CUSTOMER_selectedValue.DEPM_NO}'";
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
          DAILY_MT_TYPE_ITEM v = DAILY_MT_TYPE_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          v.VISABLE = "${data_list[i]["ITEM_NO"]}"=="null"?true:("${data_list[i]["ITEM_NO"]}".contains("0")||"${data_list[i]["ITEM_NO"]}".contains("false"))?false:true;
          if(v.ITEM_NO=="ACT"){
            v.color = Colors.cyan;
            v.svg_icon = SvgPicture.asset("assets/images/Icon material-sports-handball.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="MLK"){
            v.color = Colors.blueAccent;
            v.svg_icon = SvgPicture.asset("assets/images/Icon material-food-bank.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="POP"){
            v.color = Colors.redAccent;
            v.svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-poop.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="CLN"){
            v.color = Colors.pinkAccent;
            v.svg_icon = SvgPicture.asset("assets/images/Icon core-shower.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="CLS"){
            v.color = Colors.green;
            v.svg_icon = SvgPicture.asset("assets/images/Icon ion-shirt-sharp.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="EAT"){
            v.color = Colors.orange;
            v.svg_icon = SvgPicture.asset("assets/images/组 29134.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="DRY"){
            v.color = Colors.lightGreen;
            v.svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-file-signature.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="TMP"){
            v.color = Colors.deepPurpleAccent;
            v.svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-temperature-full.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="SLP"){
            v.color = Colors.lightBlueAccent;
            v.svg_icon = SvgPicture.asset("assets/images/组 29166.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="RQD"){
            v.color = Colors.purpleAccent;
            v.svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-basket-shopping.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="CND"){
            v.color = Colors.amber;
            v.svg_icon = SvgPicture.asset("assets/images/Icon ion-body-sharp.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="NOT"){
            v.color = Colors.pink;
            v.svg_icon = SvgPicture.asset("assets/images/Icon material-notifications-none-4.svg",color: v.color,);
          }
          DAILY_MT_TYPE_ITEMs.add(v);
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
  Future<void> read_DAILY_RQD_db_sub({
    String NO="",
    String TYPE="",
})async{

    String comm = "SELECT * FROM DAILY_RQD WHERE NO='${NO}' AND TYPE='${TYPE}'";
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
        SIGN_LINK = "${data_list[0]["SIGN_LINK"]}".contains("null")?"":"${data_list[0]["SIGN_LINK"]}";
        RECIPIENT = "${data_list[0]["RECIPIENT"]}".contains("null")||"${data_list[0]["RECIPIENT"]}".contains("0")||"${data_list[0]["RECIPIENT"]}".contains("false")?false:true;
        if(SIGN_LINK.isNotEmpty){
          SIGN_LINK = SIGN_LINK.replaceAll("~/", "");
          SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK}";
        }

        if(RECIPIENT==false && user.RANK.toLowerCase()=="u"){

          dev.log("家長上傳已讀回條");
          await updata_DAILY_RQD_db_sub(
            TYPE:"RQD",
            NO:view_DAILY!.NO,//編號
            RECIPIENT:true,//
          );

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
          d.NO = "${data_list[i]["NO"]}"=="null"?"":"${data_list[i]["NO"]}";
          d.TYPE = "${data_list[i]["TYPE"]}"=="null"?"":"${data_list[i]["TYPE"]}";
          d.SR = "${data_list[i]["SR"]}"=="null"?"":"${data_list[i]["SR"]}";
          d.LINK = "${data_list[i]["LINK"]}"=="null"?"":"${data_list[i]["LINK"]}";
          String LINK = d.LINK.replaceAll("~/", "");
          d.LINK = "${IMAGE_IP}/${LINK}";
          DAILY_PIC_DLs.add(d);
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
  Future<void> update_DAILY_RQD_db_sub()async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});

    if(See_DAILY_RQD_page_signaturebytes!=null){

      String file_name = "${cUSTOMERs[0].sel_cUSTOMER_DL!.ACCOUNT}_${DateFormat('yyyyMMddHHmmss').format(
          DateTime.now())}";

      if(See_DAILY_RQD_page_SING_LINK_TYPE!="匯入預設簽名") {
        await upload_image(img: See_DAILY_RQD_page_signaturebytes,
            file_name: file_name,
            folder: "Sign");
      }

      String SIGN_LINK = See_DAILY_RQD_page_SING_LINK_TYPE=="匯入預設簽名"?"${cUSTOMERs[0].sel_cUSTOMER_DL!.SIGN_LINK.replaceAll(IMAGE_IP,"~")}":"~/School/Images/Sign/${file_name}.jpg";//簽名
      //[托嬰/幼兒]  通知單(備註) 副表
      await updata_DAILY_RQD_db_sub(
          TYPE:"RQD",
          NO:view_DAILY!.NO,//編號
          RECIPIENT:true,//
          SIGN_LINK:"${SIGN_LINK}",//
      );
    }
    else{
      await updata_DAILY_RQD_db_sub(
          TYPE:"RQD",
          NO:view_DAILY!.NO,//編號
          RECIPIENT:true,//
          SIGN_LINK:"${SIGN_LINK}".replaceAll("${IMAGE_IP}", "~"),//
      );
    }

    See_DAILY_RQD_page_SING_LINK_TYPE="";
    SmartDialog.dismiss();
    SmartDialog.showToast("處理成功");
    MyHomePage2_U_fun1!(reflash_db:"View_DAILY");
    Navigator.pop(context);
    setState(() {

    });


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
  Future<void> updata_DAILY_RQD_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        bool RECIPIENT=false,//讀取回條
        String SIGN_LINK="",//家長簽名
      })async{

    String comm = "UPDATE DAILY_RQD SET RECIPIENT='${RECIPIENT}',SIGN_LINK='${SIGN_LINK}' WHERE NO='${NO}' AND TYPE='${TYPE}'";
    if(SIGN_LINK.isEmpty){
      comm = "UPDATE DAILY_RQD SET RECIPIENT='${RECIPIENT}' WHERE NO='${NO}' AND TYPE='${TYPE}'";
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




  /*
  生活概況
   */
  Future<int> read_View_DAILY_db_sub()async{

    int View_DAILY_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(dateTime!)}";
    String comm = "SELECT * FROM View_DAILY WHERE DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";
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
        String View_DAILY_NO = "${data_list[data_list.length-1]["NO"]}";
        dev.log("View_DAILY_NO:${View_DAILY_NO}");
        //找出流水號
        View_DAILY_NO_num = int.parse("${View_DAILY_NO.substring(View_DAILY_NO.length-7,View_DAILY_NO.length)}");
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

                  if(See_DAILY_RQD_page_signaturebytes!=null){
                    check=true;
                  }
                  if(RCPT_IMO_textEditingController.text.isNotEmpty){
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
                  user.RANK.toLowerCase()!="u"?Container():
                  GestureDetector(
                      onTap: (){


                        if(See_DAILY_RQD_page_signaturebytes==null && SIGN_LINK.isEmpty){
                          SmartDialog.showToast("請先簽名");
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
                                          title: Text('確定上傳回簽?', maxLines: 2,
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
                                              child: Text('回簽',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                update_DAILY_RQD_db_sub();
                                              },
                                            ),

                                          ],
                                        );
                                      }));
                            });

                      },
                      child: Text("上傳回簽", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp))),
                  Container(width: 20.w,),
                ],
                title: Text("${DAILY_MT_TYPE_ITEMs.isEmpty?"":DAILY_MT_TYPE_ITEMs.firstWhere((e)=>e.ITEM_NO=="RQD").ITEM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
              ),
          body: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              Container(height: 10.h,),
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
                Text("${_class.CLASS_NM}",style: TextStyle(
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
                Text("日期:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ],),
              GestureDetector(
                  onTap:()async{


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
              Row(children: [
                Container(width: 10.w,),
                Expanded(child:
                Text("${view_DAILY!.MARK}",
                    style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.blueAccent , fontSize: 16.sp))),
                Container(width: 10.w,),
              ],),
              Container(height: 15.h,),
              Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
              Container(height: 15.h,),

              user.RANK.toLowerCase()=="u"?Container():
              Column(children: [
                Row(children: [
                  Container(width: 10.w,),
                  Text("家長讀取狀態:",
                      style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: Color(0xff292929))),
                  Container(width: 10.w,),
                  Text((RECIPIENT==true)?"已讀":"未讀",
                      style: TextStyle(
                          fontFamily: "GenJyuuGothic",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                          color: (RECIPIENT==true)?Colors.blue:Colors.red)),
                  Container(width: 10.w,),
                ],),
                Container(height: 15.h,),
                Container(margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                Container(height: 15.h,),
              ],),


              Row(children: [
                Container(width: 10.w,),
                Text("家長回簽:",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
              ]),

              user.RANK.toLowerCase()=="u"?GestureDetector(
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
                                            if(cUSTOMERs[0].sel_cUSTOMER_DL!.SIGN_LINK.isEmpty){
                                              SmartDialog.showToast("請先至設定頁>帳號相關>輸入預設簽名");
                                              return;
                                            }
                                            See_DAILY_RQD_page_SING_LINK_TYPE = "匯入預設簽名";
                                            FocusManager.instance.primaryFocus?.unfocus();
                                            SmartDialog.showLoading(msg: "處理中...");
                                            await Future.delayed(const Duration(milliseconds: 500), () {});
                                            See_DAILY_RQD_page_signaturebytes = await get_url_image_to_byte_sub(img_url:"${cUSTOMERs[0].sel_cUSTOMER_DL!.SIGN_LINK}");
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
                                                type: PageTransitionType.rightToLeft, child: SignaturePage8()));
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
                    Center(child:(See_DAILY_RQD_page_signaturebytes==null)?
                    (SIGN_LINK.isNotEmpty)?
                    Image.network(SIGN_LINK,errorBuilder: (BuildContext context, Object exception,
                        StackTrace? stackTrace) {
                      return Icon(Icons.error,size: 30.sp,);
                    }):
                    Text("請按此處加上手寫簽名",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                        color: Color(0xff292929))):
                    Container(width: ScreenUtil().screenWidth,height: 100.h,child:
                    (See_DAILY_RQD_page_SING_LINK_TYPE=="匯入預設簽名")?
                    Image.network(cUSTOMERs[0].sel_cUSTOMER_DL!.SIGN_LINK)    
                        :
                    Image.memory(See_DAILY_RQD_page_signaturebytes!))),
                    Container(height: 10.h,),
                    Container(width: ScreenUtil().screenWidth,height: 1,color: Color(0xff292929),),
                  ],)):
              Column(children: [
                (SIGN_LINK.isNotEmpty)?
                Image.network(SIGN_LINK,errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Icon(Icons.error,size: 30.sp,);
                }):
                Text("尚未回簽",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))),
                Container(height: 10.h,),
                Container(width: ScreenUtil().screenWidth,height: 1,color: Color(0xff292929),),
              ],),

              Container(height: 15.h,),


            ],),
        )));
  }
}
