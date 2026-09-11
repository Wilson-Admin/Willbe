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
import 'utils/CustomAppBar.dart';

Function? DAILY_PRS_page_U_fun1;
Uint8List? DAILY_PRS_page_signaturebytes;//簽名圖檔
SignatureController DAILY_PRS_page_signatureController = SignatureController(
  penStrokeWidth: 5,
  penColor: Colors.black,
  exportBackgroundColor: Colors.white,
);

class DAILY_PRS_T_page extends StatefulWidget {

  @override
  State<DAILY_PRS_T_page> createState() => DAILY_PRS_T_pageState();
}

class DAILY_PRS_T_pageState extends State<DAILY_PRS_T_page> {


  TextEditingController NOTE_textEditingController = TextEditingController();//說明

  CUSTOMER CUSTOMER_selectedValue = CUSTOMER();
  DateTime? dateTime = DateTime.now();
  CLASS _class = CLASS();
  DEPM _depm = DEPM();





  @override
  void initState() {
    // TODO: implement initState

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

    //_class = cLASSs.firstWhere((element) => element.CLASS_NO==CUSTOMER_selectedValue.CLASS_NO)??CLASS();
    //_depm = dEPMs.firstWhere((element) => element.DEPM_NO==CUSTOMER_selectedValue.DEPM_NO)??DEPM();

    //init();

  }

  init()async{
    setState(() {

    });
  }




  /*
  [托嬰/幼兒]  家長回簽
   */
  /*
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

   */


  /*
  [托嬰/幼兒] 請假  EXCUSED
   */
  /*
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
      data_list = trim_proc(data_list);
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

   */



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
            title: Text("今日回簽", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
          ),
      body: ListView.builder(
          padding: EdgeInsets.all(5.w),
          itemCount: DAILY_PRSs.length,
          itemBuilder:(c,index){

            //學校(DEPM)
            DEPM _DEPM = DEPM();
            CLASS _CLASS = CLASS();
            try {
              _DEPM = dEPMs.firstWhere((element) =>
              element.DEPM_NO == DAILY_PRSs[index].DEPM_NO);
              _CLASS = cLASSs.firstWhere((element) =>
              element.CLASS_NO == DAILY_PRSs[index].CLASS_NO);
            }
            catch(e){

            }

            String student_name = "";
            for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
              if(DAILY_PRSs[index].CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO){
                student_name = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NM;
                break;
              }
            }

            return Container(
                width: ScreenUtil().screenWidth,
                //height: 55.w,
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                    color: DAILY_PRSs[index].isExpanded==false?Colors.white:Color(0xfffff6dc),
                    borderRadius: BorderRadius.circular(20.w),
                    border: Border.all(
                      width: 1,
                      color: Color(0xff555555),
                    )),
                child:Theme(
                    data: ThemeData().copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                        key: UniqueKey(),
                        initiallyExpanded: DAILY_PRSs[index].isExpanded,
                        onExpansionChanged: (v){
                          DAILY_PRSs[index].isExpanded = v;
                          setState(() {

                          });
                        },
                        backgroundColor: Color(0xfffff6dc),
                        iconColor: Color(0xff555555),
                        collapsedIconColor: Color(0xff555555),
                        tilePadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 0,top: 0),
                        childrenPadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 10.h),
                        title: Container(width: ScreenUtil().screenWidth,
                          child: Column(children: [

                            Row(children: [
                              //Text('${_DEPM==null?"":_DEPM.DEPM_NM}-${_CLASS==null?"":_CLASS.CLASS_NM}-${CUSTOMER_selectedValue.CS_NM}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 15.sp)),
                              Text('${_CLASS==null?"":_CLASS.CLASS_NM}-${student_name}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff555555) , fontSize: 17.sp)),
                            ],),
                            /*
                                          Row(children: [
                                            Container(
                                              //width: ScreenUtil().screenWidth,
                                                child: Text("${EXCUSED_list[index].DateStr}",
                                                    maxLines: null,
                                                    style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 16.sp,
                                                        color: Color(0xff555555)))),
                                          ],),

                                           */

                          ],),),
                        children:[

                          Container(height: 5.h,),
                          Row(children: [
                            Text("備註:",
                                maxLines: null,
                                style: TextStyle(
                                    fontFamily: "GenJyuuGothic",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                    color: Color(0xff555555))),
                          ],),
                          Row(children: [
                            Expanded(child:
                            Text("${DAILY_PRSs[index].NOTE}",
                                maxLines: null,
                                style: TextStyle(
                                    fontFamily: "GenJyuuGothic",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                    color: Colors.blue))),
                          ],),
                          Container(height: 5.h,),
                          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                          Container(height: 5.h,),
                          Row(children: [
                            Expanded(child:
                            Text("家長簽名",
                                maxLines: null,
                                style: TextStyle(
                                    fontFamily: "GenJyuuGothic",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                    color: Color(0xff555555)))),
                          ],),
                          Container(width: ScreenUtil().screenWidth,height: 200.h,child: Image.network(DAILY_PRSs[index].SIGN_LINK),),
                          Container(height: 5.h,),

                        ])));

          } ),
    )));
  }
}
