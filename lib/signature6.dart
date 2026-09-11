import 'dart:convert';
import 'dart:io';
import 'package:code3/DAILY_PRS_page.dart';
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



class Signature6Page extends StatefulWidget {

  @override
  State<Signature6Page> createState() => Signature6PageState();
}

class Signature6PageState extends State<Signature6Page> {



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
            toolbarHeight:(Platform.isAndroid)?36.h:42.h,
            leading: GestureDetector(
                onTap: ()async{

                  //DAILY_PRS_page_signaturebytes = await DAILY_PRS_page_signatureController.toPngBytes();
                  //DAILY_PRS_page_U_fun1!();
                  Navigator.pop(context);

                },
                child:Icon(Icons.arrow_back,size: 15.sp,)),
            centerTitle: true,
            actions: [
              TextButton(onPressed: (){
                DAILY_PRS_page_signatureController.clear();
              }, child: Text("清空簽名",textScaleFactor: 1, style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w400,color: Colors.white , fontSize: 10.sp))),
              Container(width: 10.w,),
            ],
            title: Text("家長簽名",textScaleFactor: 1, style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,color: Color(0xff292929) , fontSize: 12.sp)),
          ),
      body: Container(
          margin: EdgeInsets.zero,
          width: ScreenUtil().screenWidth,
          height: ScreenUtil().screenHeight,
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            borderRadius: BorderRadius.all(Radius.circular(0.w)),
            border: Border.all(
              width: 1,
              color: Color(0xffB5B5B5),
            ),
          ),
          padding: EdgeInsets.all(0.w),
          child: Stack(children: [

            Signature(
              controller: DAILY_PRS_page_signatureController,
              backgroundColor: Colors.transparent,
            ),
            Container(
                width: ScreenUtil().screenWidth,
                height: ScreenUtil().screenHeight,child:  Column(children: [

              Expanded(child: Container()),
              Row(children: [

                Expanded(child: Container()),
                GestureDetector(
                    onTap: ()async{

                      DAILY_PRS_page_SING_LINK_TYPE="手動簽名";
                      DAILY_PRS_page_signaturebytes = await DAILY_PRS_page_signatureController.toPngBytes();
                      DAILY_PRS_page_U_fun1!();
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

          ],))


    )));
  }
}
