import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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


class Daily_language_settings extends StatefulWidget {

  @override
  State<Daily_language_settings> createState() => Daily_language_settingsState();
}

class Daily_language_settingsState extends State<Daily_language_settings> {


  PageController pageController = PageController(initialPage: 0);
  int pageController_index = 0;


  @override
  void initState() {
    // TODO: implement initState

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    for(int i=0;i<sel_teacher_Daily_language_menu.menu.length;i++){
      sel_teacher_Daily_language_menu.menu[i].is_sel = false;
    }
    sel_teacher_Daily_language_menu.menu[0].is_sel = true;

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


  Future<void> save()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('日常用語_${user.ACCOUNT}',jsonEncode(sel_teacher_Daily_language_menu));
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
            toolbarHeight:50.h,
            leading: GestureDetector(
                onTap: ()async{
                  Navigator.pop(context);
                },
                child:Icon(Icons.arrow_back,size:30.sp)),
            centerTitle: true,
            title: Text("日常用語",textScaleFactor: 1, style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w600,color: Color(0xff292929) , fontSize: 20.sp)),
          ),
      body: Container(
          color: Colors.white,
          margin: EdgeInsets.zero,
          width: ScreenUtil().screenWidth,
          height: ScreenUtil().screenHeight,
          child:Column(children: [

            Container(height: 10.h,),
            Container(width: ScreenUtil().screenWidth,height: 40.h,child: ListView.builder(
                scrollDirection:Axis.horizontal,
                padding: EdgeInsets.only(left:30.w,right: 10.w),
                shrinkWrap: true,
                itemCount: sel_teacher_Daily_language_menu.menu.length,
                itemBuilder: (c,index){
                  return Container(
                      margin: EdgeInsets.only(right: 5.w),
                      padding: EdgeInsets.only( left:0.w,right: 0.w),
                      width: 90.w,
                      height: 30.h,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all((sel_teacher_Daily_language_menu.menu[index].is_sel==true)?Color(0xff4cc0bb):Colors.white),
                            surfaceTintColor: MaterialStateProperty.all((sel_teacher_Daily_language_menu.menu[index].is_sel==true)?Color(0xff4cc0bb):Colors.white),
                            padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.w),
                                    side: BorderSide(color: Color(0xff555555))
                                )
                            )
                        ),
                        onPressed: () async{

                          FocusScope.of(context).unfocus();

                          for(int i=0;i<sel_teacher_Daily_language_menu.menu.length;i++){
                            sel_teacher_Daily_language_menu.menu[i].is_sel = false;
                          }
                          sel_teacher_Daily_language_menu.menu[index].is_sel = true;
                          pageController_index = index;
                          pageController.jumpToPage(index);
                          setState(() {

                          });

                        },
                        child: Row(children: [
                          Expanded(child: Container()),
                          Text('${sel_teacher_Daily_language_menu.menu[index].title}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: (sel_teacher_Daily_language_menu.menu[index].is_sel==true)?Colors.white:Colors.black , fontSize: 18.sp)),
                          Expanded(child: Container()),
                        ],),
                      ));
                }),),
            Container(width: ScreenUtil().screenWidth,child: Row(children: [

              Expanded(child: Container()),
              IconButton(onPressed: (){

                sel_teacher_Daily_language_menu.menu[pageController_index].contant_TextEditingControllers.insert(0,TextEditingController());
                sel_teacher_Daily_language_menu.menu[pageController_index].contants.insert(0,"");
                dev.log(">>>>${sel_teacher_Daily_language_menu.menu[pageController_index].contant_TextEditingControllers.length}");
                setState(() {

                });
                save();
              }, icon: Icon(Icons.add_circle_outline,size: 30.sp,))

            ],),),
            Expanded(child: PageView.builder(
                physics:const NeverScrollableScrollPhysics(),
                controller: pageController,
                itemCount: sel_teacher_Daily_language_menu.menu.length,
                itemBuilder: (c,index){
                return ListView.builder(
                  itemCount: sel_teacher_Daily_language_menu.menu[index].contant_TextEditingControllers.length,
                  itemBuilder: (c,index2){
                    return Container(
                        color: Colors.white,
                        padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 0.h),
                        margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
                        width:ScreenUtil().screenWidth,child:
                        Column(children: [

                          Slidable(
                            // Specify a key if the Slidable is dismissible.
                            //key: ValueKey(0),

                            // The end action pane is the one at the right or the bottom side.
                              endActionPane:  ActionPane(
                                motion: ScrollMotion(),
                                extentRatio:0.25,
                                children: [
                                  CustomSlidableAction(
                                    autoClose: true,
                                    backgroundColor: Color(0xFFFE4A49),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    onPressed: (BuildContext context) {
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
                                                            onPressed: () async{
                                                              Navigator.of(context).pop();

                                                            },
                                                          ),


                                                          TextButton(
                                                            child: Text('刪除',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                                            onPressed: () async{

                                                              Navigator.of(context).pop();
                                                              sel_teacher_Daily_language_menu.menu[index].contant_TextEditingControllers.removeAt(index2);
                                                              sel_teacher_Daily_language_menu.menu[index].contants.removeAt(index2);
                                                              setState(() {

                                                              });
                                                              FocusManager.instance.primaryFocus?.unfocus();
                                                              save();
                                                            },
                                                          ),

                                                        ],
                                                      );
                                                    }));
                                          });
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.delete_forever_outlined,size: 24.sp,),
                                        Text('刪除',textScaler: TextScaler.linear(1), style: TextStyle(fontSize: 18.sp)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // The child of the Slidable is what the user sees when the
                              // component is not dragged.
                              child:Column(children: [

                                Container(
                                  color: Color(0xffEEEEEE),
                                  padding: EdgeInsets.only(left:5.w,right: 5.w,top: 5.h,bottom: 5.h),
                                  margin: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 0.h),
                                  width:ScreenUtil().screenWidth,child: Form(
                                    child: TextFormField(
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        color: Color(0xff555555),
                                      ),
                                      controller: sel_teacher_Daily_language_menu.menu[index].contant_TextEditingControllers[index2],
                                      keyboardType: TextInputType.multiline,
                                      textInputAction: TextInputAction.newline,
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
                                        sel_teacher_Daily_language_menu.menu[index].contants[index2] = sel_teacher_Daily_language_menu.menu[index].contant_TextEditingControllers[index2].text;
                                        save();
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
                                    )),),
                                Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.black54,),

                              ],)),
                          Container(height: 10.h,),

                        ],));

                  });
            }))

          ],))

    )));
  }
}
