import 'dart:convert';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'dart:developer' as dev;
import 'DRUG_MT_U_page.dart';
import 'api.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'utils/CustomAppBar.dart';


class MedicationEntrustment extends StatefulWidget {

  @override
  State<MedicationEntrustment> createState() => MedicationEntrustmentState();
}

class MedicationEntrustmentState extends State<MedicationEntrustment> {

  TextEditingController textEditingController = TextEditingController();//其他理由

  @override
  void initState() {
    // TODO: implement initState

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    textEditingController.text = "${drug_reason.reason}";

    init();
  }

  void init()async{
    if(drug_reason.DRUG_REASON_ITEM_list.length==0) {
      await DRUG_REASON_ITEM_db_sub();
    }
  }


  /*
  DRUG_REASON_ITEM
   */
  Future<void> DRUG_REASON_ITEM_db_sub()async{

    String comm = "SELECT * FROM DRUG_REASON_ITEM";
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
        List<DRUG_REASON_ITEM>  _DRUG_REASON_ITEM_list = [];
        for(int j=0;j<data_list.length;j++){
          DRUG_REASON_ITEM ss = DRUG_REASON_ITEM();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          _DRUG_REASON_ITEM_list.add(ss);
        }
        drug_reason.DRUG_REASON_ITEM_list = _DRUG_REASON_ITEM_list;
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
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
                  DRUG_MT_U_page_fun1!();
                  Navigator.pop(context);
                },
                child:Icon(Icons.arrow_back,size: 30.w,)),
            centerTitle: true,
            actions: [
              GestureDetector(
                  onTap: (){
                    DRUG_MT_U_page_fun1!();
                    Navigator.pop(context);
                  },
                  child: Text("完成", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp))),
              Container(width: 20.w,),
            ],
            title: Text("用藥委託", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
          ),
      body: //page 0
      ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          Column(children: drug_reason.DRUG_REASON_ITEM_list.map((e) {
            return (e.ITEM_NM=="其他")?
            Container(width:ScreenUtil().screenWidth,child:
            Form(
                child: TextFormField(
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Color(0xff555555),
                  ),
                  controller: textEditingController,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    //RemoveEmojiInputFormatter()
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
                    drug_reason.reason = v;
                  },
                  decoration: InputDecoration(
                    filled: true, //<-- SEE HERE
                    fillColor: Colors.transparent, //<-- SEE HERE
                    hintText: '其他',
                    hintStyle: TextStyle(fontWeight: FontWeight.bold,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 20.sp),
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
                )))
                :
            GestureDetector(
                onTap: (){
                  e.is_sel=!e.is_sel;
                  setState(() {

                  });
                },
                child: Container(color: Color(0x01000000),child:Column(children:[
                  Container(height: 10.h,),
                  Row(children: [
                    Container(width: 10.w,),
                    Text("${e.ITEM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: (e.is_sel==false)?Color(0xff292929):Colors.cyan, fontSize: 20.sp)),
                    Expanded(child: Container()),
                    (e.is_sel==false)?Container():Icon(Icons.check,size: 24.sp,color: Colors.cyan,),
                    Container(width: 10.w,),
                  ],),
                  Container(height: 10.h,),
                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                ])));
          }).toList())
        ],),
    )));
  }
}
