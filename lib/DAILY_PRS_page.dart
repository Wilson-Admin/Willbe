import 'dart:convert';
import 'dart:io';
import 'package:code3/signature2.dart';
import 'package:code3/signature4.dart';
import 'package:code3/signature6.dart';
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
import 'fcm_notifity.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'utils/CustomAppBar.dart';


Function? DAILY_PRS_page_U_fun1;
Uint8List? DAILY_PRS_page_signaturebytes;//簽名圖檔
String DAILY_PRS_page_SING_LINK_TYPE = "";
TextEditingController DAILY_PRS_u_NOTE_textEditingController = TextEditingController();//說明
SignatureController DAILY_PRS_page_signatureController = SignatureController(
  penStrokeWidth: 5,
  penColor: Colors.black,
  exportBackgroundColor: Colors.white,
);

class DAILY_PRS_page extends StatefulWidget {

  DateTime? dateTime = DateTime.now();
  DAILY_PRS_page({DateTime? dateTime}){
    if(dateTime!=null){
      this.dateTime = dateTime;
    }
  }
  @override
  State<DAILY_PRS_page> createState() => DAILY_PRS_pageState(dateTime:this.dateTime);
}

class DAILY_PRS_pageState extends State<DAILY_PRS_page> {


  //CUSTOMER CUSTOMER_selectedValue = CUSTOMER();
  DateTime? dateTime = DateTime.now();
  CLASS _class = CLASS();
  DEPM _depm = DEPM();


  DAILY_PRS_pageState({DateTime? dateTime}){
    if(dateTime!=null){
      this.dateTime = dateTime;
    }
  }



  @override
  void initState() {
    // TODO: implement initState

    DAILY_PRS_u_NOTE_textEditingController.text="";
    DAILY_PRS_page_SING_LINK_TYPE = "";

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    DAILY_PRS_page_signaturebytes=null;
    DAILY_PRS_page_U_fun1 = (){
      setState(() {

      });
    };

    //CUSTOMER_selectedValue = cUSTOMERs[0];

    _class = cLASSs.firstWhere((element) => element.CLASS_NO==CUSTOMER_selectedValue.CLASS_NO)??CLASS();
    _depm = dEPMs.firstWhere((element) => element.DEPM_NO==CUSTOMER_selectedValue.DEPM_NO)??DEPM();

    init();

  }

  init()async{
    setState(() {

    });
  }




  /*
  [托嬰/幼兒]  家長回簽
   */
  Future<int> read_DAILY_PRS_db_sub()async{

    int DAILY_PRS_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(dateTime!)}";
    String comm = "SELECT * FROM DAILY_PRS WHERE TYPE='PRS' AND (DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59')";
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
      data_list = trim_proc(data_list);
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
            title: Text("聯絡簿回簽", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
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
            Text(
                CUSTOMER_selectedValue.CS_NM,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff555555),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            Container(width: 5.w,),
          ],)),
          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
          Container(height: 10.h,),
          Row(children: [
            Container(width: 5.w,),
            Text("親師交流",style: TextStyle(
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
                controller: DAILY_PRS_u_NOTE_textEditingController,
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
                                        DAILY_PRS_page_SING_LINK_TYPE="匯入預設簽名";
                                        FocusManager.instance.primaryFocus?.unfocus();
                                        SmartDialog.showLoading(msg: "處理中...");
                                        await Future.delayed(const Duration(milliseconds: 500), () {});
                                        DAILY_PRS_page_signaturebytes = await get_url_image_to_byte_sub(img_url:"${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK}");
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
                                            type: PageTransitionType.rightToLeft, child: Signature6Page()));
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
                Center(child:(DAILY_PRS_page_signaturebytes==null)?
                Text("請按此處加上手寫簽名",style: TextStyle(
                    fontFamily: "GenJyuuGothic",
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                    color: Color(0xff292929))):
                Container(width: ScreenUtil().screenWidth,height: 100.h,child:
                (DAILY_PRS_page_SING_LINK_TYPE=="匯入預設簽名")?
                Image.network(CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK)
                    :
                Image.memory(DAILY_PRS_page_signaturebytes!))),
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


                  if(DAILY_PRS_page_signaturebytes==null){
                    SmartDialog.showToast("請手動簽名");
                    return;
                  }

                  FocusManager.instance.primaryFocus?.unfocus();
                  SmartDialog.showLoading(msg: "處理中...");
                  await Future.delayed(const Duration(milliseconds: 500), () {});

                  try{

                    int DAILY_PRS_NO_num = await read_DAILY_PRS_db_sub();//先確定圖片流水號
                    dev.log("DAILY_PRS_NO_num:${DAILY_PRS_NO_num}");
                    if(DAILY_PRS_NO_num==-1){
                      SmartDialog.dismiss();
                      SmartDialog.showToast("read_DAILY_PRS_db_sub error");
                      return;
                    }
                    DAILY_PRS_NO_num+=1;
                    String DAILY_PRS_NO = "${DateFormat('yyyyMMdd').format(dateTime!)}${DAILY_PRS_NO_num.toString().padLeft(7,"0")}";
                    DAILY_PRS_NO = DAILY_PRS_NO.substring(2,DAILY_PRS_NO.length);
                    dev.log("DAILY_PRS_NO:${DAILY_PRS_NO}");

                    //String file_name = "${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}";
                    String file_name = "${user.ACCOUNT}_${DateTime.now().microsecondsSinceEpoch}";
                    if(DAILY_PRS_page_SING_LINK_TYPE!="匯入預設簽名"){
                      await upload_image(img: DAILY_PRS_page_signaturebytes,file_name: file_name,folder: "Daily");
                    }


                    DateTime now = DateTime.now();

                    bool check = await insert_DAILY_PRS_db_sub(
                      TYPE:"PRS",
                      NO:DAILY_PRS_NO,//編號
                      DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
                      TIME: "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00",//時間,
                      DEPM_NO:"${CUSTOMER_selectedValue.DEPM_NO}",//學校
                      CLASS_NO:"${CUSTOMER_selectedValue.CLASS_NO}",//班級
                      CS_NO:"${CUSTOMER_selectedValue.CS_NO}",//學生編號
                      NOTE:"${DAILY_PRS_u_NOTE_textEditingController.text}",//說明
                      SIGN_LINK:DAILY_PRS_page_SING_LINK_TYPE=="匯入預設簽名"?"${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.SIGN_LINK.replaceAll(IMAGE_IP,"~")}":"~/School/Images/Daily/${file_name}.jpg",//簽名
                    );


                    setState(() {

                    });

                    if(check==true){
                      DAILY_PRS_page_SING_LINK_TYPE="";
                      DAILY_PRS_page_signaturebytes=null;//簽名圖檔
                      DAILY_PRS_page_signatureController.clear();
                      SmartDialog.dismiss();
                      SmartDialog.showToast("回簽送出成功");
                      MyHomePage2_U_fun1!(reflash_db:"DAILY_PRS",dateTime:"${DateFormat('yyyy-MM-dd').format(dateTime!)}");
                      Navigator.pop(context);
                    }
                    else{
                      SmartDialog.dismiss();
                      SmartDialog.showToast("回簽送出失敗");
                    }

                    if(DAILY_PRS_u_NOTE_textEditingController.text.isNotEmpty){
                      Future.delayed(const Duration(milliseconds: 200), () async{

                        //找出學生的老師
                        for(int i=0;i<cLASS_NO_for_teacher_chat.length;i++){
                          if(
                          CUSTOMER_selectedValue.DEPM_NO==cLASS_NO_for_teacher_chat[i].DEPM_NO &&
                              CUSTOMER_selectedValue.CLASS_NO==cLASS_NO_for_teacher_chat[i].CLASS_NO
                          ){

                            String FCM = await search_EMPLOYEE_fcm_sub(ACCOUNT:cLASS_NO_for_teacher_chat[i].ACCOUNT);
                            await sendPushNotification(
                                title: "${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.USER_NM} 家長",
                                message: "聯絡簿回簽有備註",
                                token: FCM,//cLASS_NO_for_teacher_chat[i].FCM,
                                ChatID:"聯絡簿回簽有備註",
                                CS_NO:CUSTOMER_selectedValue.CS_NO,
                                DAILY_PRS_NO:DAILY_PRS_NO,//編號
                                DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
                                UserAccount:'${CUSTOMER_selectedValue.sel_cUSTOMER_DL!.ACCOUNT.trim()}',
                                TeacherAccount:"${cLASS_NO_for_teacher_chat[i].ACCOUNT}".trim()
                            );

                          }

                        }


                      });
                    }



                  }
                  catch(e){
                    dev.log("${e}");
                    SmartDialog.dismiss();
                    SmartDialog.showToast("委託失敗\n${e}");
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
