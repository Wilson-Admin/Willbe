import 'dart:convert';
import 'dart:io';
import 'package:code3/signature2.dart';
import 'package:code3/signature4.dart';
import 'package:code3/signature6.dart';
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
import 'package:mime/mime.dart';
//import 'package:open_file/open_file.dart';
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
import 'package:image_picker/image_picker.dart' as ImagePicker;

import 'utils/CustomAppBar.dart';

class GROWING_u_page extends StatefulWidget {

  String operation="新增";
  GROWING_u_page({String operation="新增"}){
    this.operation = operation;
  }


  @override
  State<GROWING_u_page> createState() => GROWING_u_pageState(operation:this.operation);
}

class GROWING_u_pageState extends State<GROWING_u_page> {

  /*
  老師帳號>每日可以新增/編輯如下
  身高/體重/頭圍/視力/塗氟/潔牙衛教/口腔檢查

  家長帳號>可以編輯如下
  身高/體重/頭圍/

  家長帳號>每日可以新增/編輯如下
  視力/塗氟/潔牙衛教/口腔檢查
   */

  String operation="新增";
  GROWING_u_pageState({String operation="新增"}){
    this.operation = operation;
  }

  TextEditingController L_DATA_textEditingController = TextEditingController();//左眼
  TextEditingController R_DATA_textEditingController = TextEditingController();//右眼

  //CUSTOMER CUSTOMER_selectedValue = CUSTOMER();
  DateTime? dateTime = DateTime.now();
  CLASS _class = CLASS();
  DEPM _depm = DEPM();

  List<GROWING_TYPE_ITEM> GROWING_TYPE_ITEM_list = [];
  GROWING_TYPE_ITEM sel_GROWING_TYPE_ITEM = GROWING_TYPE_ITEM();

  File? file;
  var showModalBottomSheet_image_context;
  var prescriptionsbytes_xfile;


  @override
  void initState() {
    // TODO: implement initState

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();


    //CUSTOMER_selectedValue = cUSTOMERs[0];

    _class = cLASSs.firstWhere((element) => element.CLASS_NO==CUSTOMER_selectedValue.CLASS_NO)??CLASS();
    _depm = dEPMs.firstWhere((element) => element.DEPM_NO==CUSTOMER_selectedValue.DEPM_NO)??DEPM();

    init();

  }

  init()async{
    await GROWING_TYPE_ITEM_db_sub();
    setState(() {

    });
  }


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
        家長帳號>每日可以新增/編輯如下
        視力/塗氟/潔牙衛教/口腔檢查
         */
        //GROWING_TYPE_ITEM_list.removeWhere((item) => item.ITEM_NM == '身高');
        //GROWING_TYPE_ITEM_list.removeWhere((item) => item.ITEM_NM == '體重');
        //GROWING_TYPE_ITEM_list.removeWhere((item) => item.ITEM_NM == '頭圍');
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




  /*
  [托嬰/幼兒]  家長回簽
   */
  Future<int> read_DAILY_PRS_db_sub()async{

    int DAILY_PRS_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(dateTime!)}";
    String comm = "SELECT * FROM DAILY_PRS WHERE TYPE='PRS' AND (DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59')";
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
        String DAILY_PRS_NO = "${data_list[data_list.length-1]["NO"]}";
        dev.log("DAILY_PRS_NO:${DAILY_PRS_NO}");
        //找出流水號
        DAILY_PRS_NO_num = int.parse("${DAILY_PRS_NO.substring(DAILY_PRS_NO.length-6,DAILY_PRS_NO.length)}");
        dev.log("DAILY_PRS_NO_num:${DAILY_PRS_NO_num}");
      }
      setState(() {

      });

    }
    catch(e){
      DAILY_PRS_NO_num=-1;
      dev.log("${e}");
    }

    return DAILY_PRS_NO_num;

  }


  /*
  [托嬰/幼兒] 請假  EXCUSED
   */
  Future<bool> insert_DAILY_PRS_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        String DATE="",//日期
        String TIME="",//時間
        String DEPM_NO="",//學校
        String CLASS_NO="",//班級
        String CS_NO="",//學生編號
        String NOTE="",//說明
        String SIGN_LINK="",//簽名
      })async{

    String comm = "INSERT INTO DAILY_PRS(TYPE,NO,DATE,TIME,DEPM_NO,CLASS_NO,CS_NO,NOTE,SIGN_LINK) VALUES ('${TYPE}','${NO}','${DATE}','${TIME}','${DEPM_NO}','${CLASS_NO}','${CS_NO}','${NOTE}','${SIGN_LINK}')";
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
      return true;


    }
    catch(e){
      dev.log("${e}");
      return false;
    }
  }


  /*
  void _handleFileSelection() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc','png'],
    );

    if (result != null && result.files.single.path != null) {
      file = File(result.files.single.path!);
      dev.log("lookupMimeType:${lookupMimeType(result.files.single.path!)}");
    }
    setState(() {

    });
  }

   */



  /*
  [托嬰/幼兒]成長紀錄
   */
  Future<int> read_GROWING_db_sub({String TYPE=""})async{

    int GROWING_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(dateTime!)}";
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
            title: Text("成長紀錄", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
          ),
      body: ListView(
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
                Text((dateTime==null)?"":"${DateFormat('yyyy年MM月dd日').format(dateTime!)}",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Colors.blue)),
                Container(width: 10.w,),
              ],),)),
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
            Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.w),
                ),
                width: 80.w,
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
            Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.w),
                ),
                width: 80.w,
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
                  maxLength: 4,
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

                                  /*
                                  var imageFile = await ImagePicker.ImagePicker().pickImage(
                                      source: ImagePicker.ImageSource.gallery);

                                   */

                                  if (imageFile != null) {
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
                    String GROWING_NO = "${DateFormat('yyMMdd').format(dateTime!)}${GROWING_NO_num.toString().padLeft(6,"0")}";
                    dev.log("GROWING_NO:${GROWING_NO}");

                    String file_name = "${DateTime.now().microsecondsSinceEpoch}";
                    if(prescriptionsbytes_xfile!=null){
                      await upload_image(image_path: prescriptionsbytes_xfile!.path,file_name: file_name,folder: "Record");
                    }


                    bool check = await insert_GROWING_db_sub(
                      TYPE:sel_GROWING_TYPE_ITEM.ITEM_NO,//種類
                      NO:GROWING_NO,//日期
                      DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
                      DEPM_NO:"${CUSTOMER_selectedValue.DEPM_NO}",//學校
                      CLASS_NO:"${CUSTOMER_selectedValue.CLASS_NO}",//班級
                      CS_NO:"${CUSTOMER_selectedValue.CS_NO}",//學生編號
                      USER_NO:"${user.ACCOUNT}",//建立者
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
                      SmartDialog.showToast("送出失敗");
                      return;
                    }


                    setState(() {

                    });

                    if(check==true){
                      SmartDialog.showToast("送出成功");
                      MyHomePage2_U_fun1!(reflash_db:"GROWING");
                      Navigator.pop(context);
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



        ],),
    )));
  }
}
