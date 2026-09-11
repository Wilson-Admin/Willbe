import 'dart:convert';
import 'dart:io';
import 'package:code3/DRUG_MT_T_page.dart';
import 'package:code3/EXCUSED_page.dart';
import 'package:code3/entrusted_pick_and_drop.dart';
import 'package:code3/student_T.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'package:signature/signature.dart';
import 'dart:developer' as dev;
import 'api.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'utils/CustomAppBar.dart';


class SignaturePage5 extends StatefulWidget {

  String CMPT_SIGNx="";
  int DRUG_DL_index=0;
  SignaturePage5({String CMPT_SIGNx="",int DRUG_DL_index=0}){
    this.CMPT_SIGNx = CMPT_SIGNx;
    this.DRUG_DL_index = DRUG_DL_index;
  }

  @override
  State<SignaturePage5> createState() => SignaturePageState(CMPT_SIGNx:this.CMPT_SIGNx,DRUG_DL_index:this.DRUG_DL_index);
}

class SignaturePageState extends State<SignaturePage5> {


  String CMPT_SIGNx="";
  int DRUG_DL_index=0;
  SignaturePageState({String CMPT_SIGNx="",int DRUG_DL_index=0}){
    this.CMPT_SIGNx = CMPT_SIGNx;
    this.DRUG_DL_index = DRUG_DL_index;
  }

  @override
  void initState() {
    // TODO: implement initState

    SystemChrome.setPreferredOrientations([
      //DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    init();
  }

  void init()async{

  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);
    super.deactivate();
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
            toolbarHeight:36.h,
            leading: GestureDetector(
                onTap: ()async{

                  //ByteData? data = await EXCUSED_page_handSignatureControl.toImage();
                  //EXCUSED_page_signaturebytes = await EXCUSED_page_signatureController.toPngBytes();
                  //EXCUSED_page_U_fun1!();
                  /*
                  if(CMPT_SIGNx=="CMPT_SIGN1"){
                    dRUG_MT.DRUG_DL_list[DRUG_DL_index].SING_LINK_TYPE1="手動簽名";
                    dRUG_MT.DRUG_DL_list[DRUG_DL_index].signaturebytes1 = await dRUG_MT.DRUG_DL_list[DRUG_DL_index].signatureController1.toPngBytes();
                  }
                  if(CMPT_SIGNx=="CMPT_SIGN2"){
                    dRUG_MT.DRUG_DL_list[DRUG_DL_index].SING_LINK_TYPE2="手動簽名";
                    dRUG_MT.DRUG_DL_list[DRUG_DL_index].signaturebytes2 = await dRUG_MT.DRUG_DL_list[DRUG_DL_index].signatureController2.toPngBytes();
                  }
                  if(CMPT_SIGNx=="CMPT_SIGN3"){
                    dRUG_MT.DRUG_DL_list[DRUG_DL_index].SING_LINK_TYPE3="手動簽名";
                    dRUG_MT.DRUG_DL_list[DRUG_DL_index].signaturebytes3 = await dRUG_MT.DRUG_DL_list[DRUG_DL_index].signatureController3.toPngBytes();
                  }
                  DRUG_MT_T_page_fun1!();

                   */
                  Navigator.pop(context);

                },
                child:Icon(Icons.arrow_back,size: 15.sp)),
            centerTitle: true,
            actions: [
              TextButton(onPressed: (){

                //entrusted_pick_and_drop.signatureController.clear();
                //EXCUSED_page_signatureController.clear();
                if(CMPT_SIGNx=="CMPT_SIGN1")dRUG_MT.DRUG_DL_list[DRUG_DL_index].signatureController1.clear();
                else if(CMPT_SIGNx=="CMPT_SIGN2")dRUG_MT.DRUG_DL_list[DRUG_DL_index].signatureController2.clear();
                else if(CMPT_SIGNx=="CMPT_SIGN3")dRUG_MT.DRUG_DL_list[DRUG_DL_index].signatureController3.clear();

              }, child: Text("清空簽名",textScaleFactor: 1, style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w400,color: Colors.white , fontSize: 10.sp))),
              Container(width: 10.w,),
            ],
            title: Text("老師簽名",textScaleFactor: 1, style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,color: Color(0xff292929) , fontSize: 12.sp)),
          ),
      body: Container(
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            borderRadius: BorderRadius.all(Radius.circular(0.w)),
            border: Border.all(
              width: 1,
              color: Color(0xffB5B5B5),
            ),
          ),
          width: ScreenUtil().screenWidth,
          height: ScreenUtil().screenHeight,
          padding: EdgeInsets.all(0.w),
          child: Stack(children: [

            Signature(
              controller: (CMPT_SIGNx=="CMPT_SIGN1")?dRUG_MT.DRUG_DL_list[DRUG_DL_index].signatureController1:(CMPT_SIGNx=="CMPT_SIGN2")?dRUG_MT.DRUG_DL_list[DRUG_DL_index].signatureController2:dRUG_MT.DRUG_DL_list[DRUG_DL_index].signatureController3,
              backgroundColor: Colors.transparent,
            ),
            Container(
                width: ScreenUtil().screenWidth,
                height: ScreenUtil().screenHeight,child: Column(children: [

              Expanded(child: Container()),
              Row(children: [

                Expanded(child: Container()),
                GestureDetector(
                    onTap: ()async{

                      //ByteData? data = await EXCUSED_page_handSignatureControl.toImage();
                      //EXCUSED_page_signaturebytes = await EXCUSED_page_signatureController.toPngBytes();
                      //EXCUSED_page_U_fun1!();
                      if(CMPT_SIGNx=="CMPT_SIGN1"){
                        dRUG_MT.DRUG_DL_list[DRUG_DL_index].SING_LINK_TYPE1="手動簽名";
                        dRUG_MT.DRUG_DL_list[DRUG_DL_index].signaturebytes1 = await dRUG_MT.DRUG_DL_list[DRUG_DL_index].signatureController1.toPngBytes();
                      }
                      if(CMPT_SIGNx=="CMPT_SIGN2"){
                        dRUG_MT.DRUG_DL_list[DRUG_DL_index].SING_LINK_TYPE2="手動簽名";
                        dRUG_MT.DRUG_DL_list[DRUG_DL_index].signaturebytes2 = await dRUG_MT.DRUG_DL_list[DRUG_DL_index].signatureController2.toPngBytes();
                      }
                      if(CMPT_SIGNx=="CMPT_SIGN3"){
                        dRUG_MT.DRUG_DL_list[DRUG_DL_index].SING_LINK_TYPE3="手動簽名";
                        dRUG_MT.DRUG_DL_list[DRUG_DL_index].signaturebytes3 = await dRUG_MT.DRUG_DL_list[DRUG_DL_index].signatureController3.toPngBytes();
                      }
                      DRUG_MT_T_page_fun1!();
                      Navigator.pop(context);

                    },
                    child: Container(
                      //width: 20.w,
                      //height: 20.w,
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child:Text("完成",style: TextStyle(fontSize: 12.sp),))),
                Container(width: 5.w,)

              ],),
              Container(height: 5.w,)

            ],)),

          ],)
          ))


    ));
  }
}
