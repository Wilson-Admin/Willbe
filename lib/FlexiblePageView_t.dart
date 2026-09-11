import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:widget_zoom/widget_zoom.dart';
import 'DRUG_MT_T_page.dart';
import 'api.dart';
import 'dart:developer' as dev;
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;

import 'signature5.dart';
import 'sql.dart';
import 'student_T.dart';


class FlexiblePageView_t extends StatefulWidget {

  @override
  _FlexiblePageViewState_t createState() => _FlexiblePageViewState_t();
}

class _FlexiblePageViewState_t extends State<FlexiblePageView_t> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _pageHeight = 200; // 默认初始高度
  final List<GlobalKey> _keys = [];
  TextEditingController CMPT_NOTE_textEditingController = TextEditingController();//老師給藥說明

  @override
  void initState() {
    super.initState();

    // 为每个页面生成 GlobalKey
    _keys.addAll(List.generate(dRUG_MT.DRUG_DL_list.length, (_) => GlobalKey()));
    // 首次渲染后测量高度
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
  }

  // 通过 GlobalKey 获取当前页面的高度
  void _updateHeight() {
    final context = _keys[_currentPage].currentContext;
    //dev.log("newHeight:");
    if (context != null) {
      //dev.log("newHeight2:");
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final size = renderBox.size;
      final newHeight = size.height;
      //dev.log("newHeight:${newHeight}");
      //dev.log("_pageHeight:${_pageHeight}");
      //dev.log("context.size?.height:${context.size?.height}");
      setState(() {
        _pageHeight = newHeight + drugTilesHeight;
      });
      /*
      if (newHeight > _pageHeight) {
        setState(() {
          _pageHeight = newHeight;
        });
      }

       */
    }
  }

  Future<void> upload_xxx_from_DRUG_DL_db(
      {
        String CMPT_SIGNx="",
        String CMPT_SIGN_img="",
        String CMPT_Time="",
        int index=0,
        String CMPT_NOTEx="",
        String CMPT_NOTEx_text =""
      })async{
    String comm="";
    if(CMPT_SIGN_img.isNotEmpty){
      comm = "UPDATE DRUG_DL SET ${CMPT_SIGNx}='${CMPT_SIGN_img}',${CMPT_NOTEx}='${CMPT_NOTEx_text}' WHERE DRUG_NO='${dRUG_MT.DRUG_DL_list[index].DRUG_NO}' AND DRUG_SR='${dRUG_MT.DRUG_DL_list[index].DRUG_SR}'";
    }
    if(CMPT_Time.isNotEmpty){
      comm = "UPDATE DRUG_DL SET ${CMPT_SIGNx}='${CMPT_Time}',${CMPT_NOTEx}='${CMPT_NOTEx_text}' WHERE DRUG_NO='${dRUG_MT.DRUG_DL_list[index].DRUG_NO}' AND DRUG_SR='${dRUG_MT.DRUG_DL_list[index].DRUG_SR}'";
    }


    dev.log("${comm}");
    String result = await sql_command("${comm}");

  }


  Future<bool> upload_xxx_from_DRUG_DL_db2(
      {
        String CMPT_SIGNx="",
        String CMPT_SIGN_img="",
        String CMPT_NOTEx="",
        String NOTEx="",
        int index=0,
      })async{

    bool check = false;

    String comm="";
    if(CMPT_SIGN_img.isNotEmpty){
      comm = "UPDATE DRUG_DL SET ${CMPT_SIGNx}='${CMPT_SIGN_img}',${CMPT_NOTEx}='${NOTEx}' WHERE DRUG_NO='${dRUG_MT.DRUG_DL_list[index].DRUG_NO}' AND DRUG_SR='${dRUG_MT.DRUG_DL_list[index].DRUG_SR}'";
    }


    dev.log("${comm}");
    String result = await sql_command("${comm}");
    dev.log("result:${result}");

    try{
      dynamic map = jsonDecode(result);
      check = true;
    }
    catch(e){

    }

    return check;
  }


  Future<bool> upload_xxx_from_DRUG_DL_db3(
      {
        String CMPT_NOTEx="",
        String NOTEx="",
        int index=0,
      })async{

    bool check = false;

    String comm = "UPDATE DRUG_DL SET ${CMPT_NOTEx}='${NOTEx}' WHERE DRUG_NO='${dRUG_MT.DRUG_DL_list[index].DRUG_NO}' AND DRUG_SR='${dRUG_MT.DRUG_DL_list[index].DRUG_SR}'";

    dev.log("${comm}");
    String result = await sql_command("${comm}");
    dev.log("result:${result}");

    try{
      dynamic map = jsonDecode(result);
      check = true;
    }
    catch(e){

    }

    return check;
  }

  void _showCupertinoDialog(
      BuildContext context,
      {
        int index=0,
        String CMPT_SIGNx="",
        String CMPT_NOTEx="",
        DRUG_DL? e
      }) {


    CMPT_NOTE_textEditingController.text = "";
    bool is_other = false;
    double height = 250.h;

    for (var i in DRUG_CANCEL_REASONs) {
      i.sel = false;
    }

    showCupertinoDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CupertinoAlertDialog(
              title: Text(
                '請選擇操作',
                textScaler: const TextScaler.linear(1),
                style: TextStyle(color: Colors.black, fontSize: 20.sp),
              ),
              content: SizedBox(
                height: height,
                child: CupertinoScrollbar(
                  child: Column(children: [

                    Container(height: 10.h,),
                    Expanded(child: ListView.builder(
                      itemCount: DRUG_CANCEL_REASONs.length,
                      itemBuilder: (context, index) {
                        final item = DRUG_CANCEL_REASONs[index];
                        return GestureDetector(
                            onTap: () {
                              if(item.ITEM_NM.contains("其他")){
                                is_other = true;
                                height = 250.h;
                              }
                              else{
                                height = 250.h;
                              }
                              setState(() {
                                for (var i in DRUG_CANCEL_REASONs) {
                                  i.sel = false;
                                }
                                item.sel = true;
                              });
                            },
                            child: Container(
                              color: const Color(0x01000000), // 必須設背景，否則 GestureDetector 點不到
                              child:Column(
                                children: [
                                  SizedBox(height: 4.h),
                                  Text(
                                    item.ITEM_NM,
                                    textScaler: const TextScaler.linear(1),
                                    style: TextStyle(
                                      color: item.sel ? Colors.red : Colors.blue,
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Container(
                                    width: ScreenUtil().screenWidth,
                                    height: 0.8.h,
                                    color: Colors.black12,
                                  ),
                                ],
                              ),
                            ));
                      },
                    )),
                    /*
                    (is_other==false)?
                    Container()
                        :
                    Container(
                        color: Color(0xffEEEEEE),
                        padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 0.h),
                        margin: EdgeInsets.only(left:3.w,right: 3.w,top: 10.h,bottom: 0.h),
                        width:ScreenUtil().screenWidth,height: 100.h,child: Form(
                        child: TextFormField(
                          style: TextStyle(
                            fontSize: 20.sp,
                            color: Colors.black,
                          ),
                          controller: CMPT_NOTE_textEditingController,
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
                            setState(() {
                            });
                          },
                          decoration: InputDecoration(
                            //labelStyle: TextStyle(fontSize: 20.sp,color: Colors.blueAccent),
                            //labelText: '標題',
                            filled: true, //<-- SEE HERE
                            fillColor: Colors.transparent, //<-- SEE HERE
                            hintText: '其他說明',
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

                     */

                  ],),
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  child:  Text('取消',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 20.sp),),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child:  Text('確定',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 20.sp),),
                  onPressed: () async{

                    Navigator.of(context).pop();

                    String LINK="";
                    for (var i in DRUG_CANCEL_REASONs) {
                      if(i.sel == true){
                        LINK = i.LINK;
                        break;
                      }
                    }

                    bool check = await upload_xxx_from_DRUG_DL_db2(
                        CMPT_SIGNx: CMPT_SIGNx,
                        CMPT_SIGN_img:LINK.replaceAll(IMAGE_IP,"~"),//老師簽名,
                        index:dRUG_MT.DRUG_DL_list.indexOf(e!),
                        CMPT_NOTEx:CMPT_NOTEx,
                        NOTEx:CMPT_NOTE_textEditingController.text,
                    );//上傳老師委藥(簽名檔)

                    if(check==true){
                      Fluttertoast.showToast(
                          msg: "送出成功",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0.sp
                      );
                      if(CMPT_SIGNx=="CMPT_SIGN1"){

                        dRUG_MT.DRUG_DL_list[index].CMPT_SIGN1 = LINK;
                        dRUG_MT.DRUG_DL_list[index].CMPT_NOTE1 = CMPT_NOTE_textEditingController.text;
                      }
                      else if(CMPT_SIGNx=="CMPT_SIGN2"){
                        dRUG_MT.DRUG_DL_list[index].CMPT_SIGN2 = LINK;
                        dRUG_MT.DRUG_DL_list[index].CMPT_NOTE2 = CMPT_NOTE_textEditingController.text;
                      }
                      else if(CMPT_SIGNx=="CMPT_SIGN3"){
                        dRUG_MT.DRUG_DL_list[index].CMPT_SIGN3 = LINK;
                        dRUG_MT.DRUG_DL_list[index].CMPT_NOTE3 = CMPT_NOTE_textEditingController.text;
                      }
                      setState(() {

                      });
                    }
                    else{
                      Fluttertoast.showToast(
                          msg: "送出失敗，請重新嘗試",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 16.0.sp
                      );
                    }

                    /*
                    Future.delayed(const Duration(milliseconds: 50), () {

                      DRUG_MT_T_page_fun2!();

                    });

                     */
                  }
                ),
              ],
            );
          },
        );
      },
    );


  }

  Widget drugTiles() {
    final mainGap = 8.w;         // 垂直間距
    final crossGap = 8.w;       // 水平間距

    Widget tile(int index) {
      final isActive = index == _currentPage;
      return GestureDetector(
        key: ValueKey('drug-$index'),
        onTap: () => _pageController.jumpToPage(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xff46c3bc) : const Color(0xffffb11f),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: AutoSizeText(
              dRUG_MT.DRUG_DL_list[index].DETAIL,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    }

    final rows = <Widget>[];
    for (int i = 0; i < dRUG_MT.DRUG_DL_list.length; i += 2) {
      final isLastOdd = (i == dRUG_MT.DRUG_DL_list.length - 1);
      if (isLastOdd) {
        // ✅ 最後一個 → 滿版，讓高度隨內容
        rows.add(tile(i));
      } else {
        // ✅ 一列兩個 → Expanded 平均分
        rows.add(
          Row(
            children: [
              Expanded(child: tile(i)),
              SizedBox(width: crossGap),
              Expanded(child: tile(i + 1)),
            ],
          ),
        );
      }
      if (i + 2 < dRUG_MT.DRUG_DL_list.length) rows.add(SizedBox(height: mainGap));
    }

    return Column(children: rows);
  }

  // 計算 drugTiles 總高度
  double get drugTilesHeight {
    final mainGap = 8.w;   // 垂直間距
    final tileHeight = 60.w; // 你 tile 大約的高度 (自己調整)

    final count = dRUG_MT.DRUG_DL_list.length;
    final rowCount = (count / 2).ceil(); // 每列兩個，算出總列數
    final totalGap = (rowCount - 1) * mainGap;

    return rowCount * tileHeight + totalGap;
  }

  @override
  Widget build(BuildContext context) {


    return Container(
      height: _pageHeight,
      child: Column(children: [

        /*
        SmoothPageIndicator(
          controller: _pageController,
          count: dRUG_MT.DRUG_DL_list.length,
          effect: WormEffect(
            dotHeight: 10.w,
            dotWidth: 10.w,
            type: WormType.thinUnderground,
          ),
        ),

         */
        Container(height: 5.h,),
        /*
        GridView.count(
          shrinkWrap: true, padding: EdgeInsets.zero, // 移除預設 padding
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2, // 每列 2 個
          mainAxisSpacing: 8.w,
          crossAxisSpacing: 16.w,
          childAspectRatio: 3.5, // 長方形比例，可調整
          children: List.generate(dRUG_MT.DRUG_DL_list.length, (index) {
            bool isActive = index == _currentPage;
            return GestureDetector(
              onTap: (){
                _pageController.jumpToPage(index);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isActive ? Color(0xff46c3bc) : Color(0xffffb11f),
                  borderRadius: BorderRadius.circular(12), // 四角圓弧
                ),
                child: Center(
                  child: AutoSizeText(
                    dRUG_MT.DRUG_DL_list[index].DETAIL,
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

         */
        SizedBox(
          height: drugTilesHeight,
          child: drugTiles(),
        ),
        Container(height: 5.h,),
        Expanded(child:
        PageView(
          controller: _pageController,
          onPageChanged: (index) {
            _currentPage = index;
            // 延后测量，确保页面渲染完成
            WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
          },
          children: dRUG_MT.DRUG_DL_list.asMap().entries.map((ee) {


            String _STORE = "";
            String _MODE = "";
            String _UNIT = "";
            String _DOSAGE = "";

            try{
              _STORE = dRUG_STORE.DRUG_STORE_ITEM_list.firstWhere((element) => element.ITEM_NO==ee.value.STORE).ITEM_NM;
            }
            catch(e){

            }
            try{
              _MODE = dRUG_MODE.DRUG_MODE_ITEM_list.firstWhere((element) => element.ITEM_NO==ee.value.MODE).ITEM_NM;
            }
            catch(e){

            }
            try{
              _UNIT = DRUG_UNIT_ITEM_list.firstWhere((element) => element.ITEM_NO==ee.value.UNIT).ITEM_NM;
            }
            catch(e){

            }
            try{
              _DOSAGE = ee.value.DOSAGE.replaceAll("\n", "").replaceAll("\r", "").replaceAll(" ", "");
            }
            catch(e){

            }


            var timeOfDay1;
            var timeOfDay2;
            var timeOfDay3;
            var timeOfDay4;
            var timeOfDay5;
            var timeOfDay6;
            try{
              List<String> t1 = ee.value.TIME1.split(":");
              timeOfDay1 = TimeOfDay(hour: int.parse(t1[0]),minute: int.parse(t1[1]));
            }
            catch(e){

            }

            try{
              List<String> t2 = ee.value.TIME2.split(":");
              timeOfDay2 = TimeOfDay(hour: int.parse(t2[0]),minute: int.parse(t2[1]));
            }
            catch(e){

            }

            try{
              List<String> t3 = ee.value.TIME3.split(":");
              timeOfDay3 = TimeOfDay(hour: int.parse(t3[0]),minute: int.parse(t3[1]));
            }
            catch(e){

            }

            try{
              List<String> t4 = ee.value.CMPT_Time1.split(":");
              timeOfDay4 = TimeOfDay(hour: int.parse(t4[0]),minute: int.parse(t4[1]));
            }
            catch(e){

            }

            try{
              List<String> t5 = ee.value.CMPT_Time2.split(":");
              timeOfDay5 = TimeOfDay(hour: int.parse(t5[0]),minute: int.parse(t5[1]));
            }
            catch(e){

            }

            try{
              List<String> t6 = ee.value.CMPT_Time3.split(":");
              timeOfDay6 = TimeOfDay(hour: int.parse(t6[0]),minute: int.parse(t6[1]));
            }
            catch(e){

            }



            int idx = ee.key;
            var e = ee.value;

            //dev.log("e.CMPT_SIGN1:${e.CMPT_SIGN1}");

            Widget page = Column(
                key: _keys[idx],
                children: [

                  Container(
                      padding:EdgeInsets.all(10.w),
                      decoration:BoxDecoration(
                        color: Color(0xffffe38e),
                        borderRadius: BorderRadius.circular(10.w),
                      ),child:
                  Column(children: [
                    Container(width: ScreenUtil().screenWidth,height: 150.h,child: WidgetZoom(
                        heroAnimationTag: "${e.DRUG_LINK}",
                        zoomWidget:Image.network(
                          "${e.DRUG_LINK}",
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              // 圖片加載完成後觸發
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _updateHeight();
                              });
                            }
                            return child;
                          },
                          errorBuilder: (BuildContext context, Object exception,
                            StackTrace? stackTrace) {
                          return  Icon(Icons.error,size: 30.sp,);
                        },))),
                    /*
                    Container(height: 10.h,),
                    Container(
                      //margin:EdgeInsets.only(left:10.w,right: 10.w),
                        padding:EdgeInsets.only(top:8.w,bottom: 8.w),
                        decoration:BoxDecoration(
                          color: Color(0xfffefce2),
                          borderRadius: BorderRadius.circular(30.w),
                        ),
                        width: ScreenUtil().screenWidth,child:Center(child:Text("明細(${dRUG_MT.DRUG_DL_list.indexOf(e)+1})",style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.w400,
                        fontSize: 18.sp,
                        color: Colors.black)))),

                     */
                    Container(height: 10.h,),
                    Row(children: [

                      Expanded(child:
                      RichText(
                        text: TextSpan(
                          text: '藥品名稱:',
                          style: TextStyle(
                              fontFamily: 'GenJyuuGothic',
                              fontWeight: FontWeight.w400,
                              fontSize: 17.sp,
                              color: Color(0xff555555)
                          ),
                          children: [
                            TextSpan(
                              text: ' ${e.DETAIL}',
                              style: TextStyle(
                                  fontFamily: "GenJyuuGothic",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 17.sp,
                                  color: Colors.red
                              ),
                            ),
                          ],
                        ),
                      )),


                    ],),
                    Row(children: [

                      Expanded(child:
                      RichText(
                        text: TextSpan(
                          text: '用藥保存:',
                          style: TextStyle(
                              fontFamily: 'GenJyuuGothic',
                              fontWeight: FontWeight.w400,
                              fontSize: 17.sp,
                              color: Color(0xff555555)
                          ),
                          children: [
                            TextSpan(
                              text: ' ${_STORE}',
                              style: TextStyle(
                                  fontFamily: "GenJyuuGothic",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 17.sp,
                                  color: Colors.red
                              ),
                            ),
                          ],
                        ),
                      )),


                    ],),
                    Row(children: [

                      Expanded(child:
                      RichText(
                        text: TextSpan(
                          text: '用藥方式:',
                          style: TextStyle(
                              fontFamily: 'GenJyuuGothic',
                              fontWeight: FontWeight.w400,
                              fontSize: 17.sp,
                              color: Color(0xff555555)
                          ),
                          children: [
                            TextSpan(
                              text: ' ${_MODE}',
                              style: TextStyle(
                                  fontFamily: "GenJyuuGothic",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 17.sp,
                                  color: Colors.red
                              ),
                            ),
                          ],
                        ),
                      )),


                    ],),
                    Row(children: [

                      Expanded(child:
                      RichText(
                        text: TextSpan(
                          text: '用量:',
                          style: TextStyle(
                              fontFamily: 'GenJyuuGothic',
                              fontWeight: FontWeight.w400,
                              fontSize: 17.sp,
                              color: Color(0xff555555)
                          ),
                          children: [
                            TextSpan(
                              text: ' ${_DOSAGE}${_UNIT}/次',
                              style: TextStyle(
                                  fontFamily: "GenJyuuGothic",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 17.sp,
                                  color: Colors.red
                              ),
                            ),
                          ],
                        ),
                      )),


                    ],),
                    Row(children: [

                      Expanded(child:
                      RichText(
                        text: TextSpan(
                          text: '藥品照片(說明):',
                          style: TextStyle(
                              fontFamily: 'GenJyuuGothic',
                              fontWeight: FontWeight.w400,
                              fontSize: 17.sp,
                              color: Color(0xff555555)
                          ),
                          children: [
                            TextSpan(
                              text: ' ${e.NOTE}',
                              style: TextStyle(
                                  fontFamily: "GenJyuuGothic",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 17.sp,
                                  color: Colors.red
                              ),
                            ),
                          ],
                        ),
                      )),


                    ],),
                  ],)),

                  Container(height: 20.h,),
                  Container(
                    child: Column(children: [
                      RichText(
                        text: TextSpan(
                          text: '第1次給藥:',
                          style: TextStyle(
                              fontFamily: 'GenJyuuGothic',
                              fontWeight: FontWeight.w400,
                              fontSize: 20.sp,
                              color: Color(0xff555555)
                          ),
                          children: [
                            (timeOfDay1==null)?TextSpan(text:""):
                            TextSpan(
                              text: ' ${"${timeOfDay1.period==DayPeriod.am?"上午":"下午"}${timeOfDay1.hourOfPeriod}:${timeOfDay1.minute.toString().padLeft(2,"0")}"}',
                              style: TextStyle(
                                  fontFamily: "GenJyuuGothic",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20.sp,
                                  color: Colors.red
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 20.h,),

                      (timeOfDay4==null && e.CMPT_SIGN1.contains("CancelReason"))?
                      Column(children: [
                        Image.network(
                          "${e.CMPT_SIGN1}",
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              // 圖片加載完成後觸發
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _updateHeight();
                              });
                            }
                            return child;
                          },
                        ),
                        Container(height: 10.h,),
                        Container(width: ScreenUtil().screenWidth,child: Row(children: [
                          Expanded(child: Container()),
                          Text('用藥說明:',textScaleFactor: 1,style: TextStyle(color: Colors.black,fontSize: 18.sp,fontWeight: FontWeight.w400),),
                          Expanded(child: Container()),
                        ],),),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                          margin: EdgeInsets.only(left: 3.w, right: 3.w, top: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: Colors.black, // 邊框顏色
                              width: 1,            // 邊框寬度
                            ),
                            borderRadius: BorderRadius.circular(6), // 一點圓角
                          ),
                          width: ScreenUtil().screenWidth,
                          child: Form(
                            child: TextFormField(
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: Colors.black,
                              ),
                              controller: e.CMPT1_NOTE_textEditingController,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              inputFormatters: [],
                              autofocus: false,
                              minLines: 3,   // ✅ 預設最少 3 行 → 大約等於 100.h 高度
                              maxLines: null, // ✅ 讓它可以隨輸入文字自動撐高
                              maxLength: 255,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (v) => setState(() {}),
                              decoration: InputDecoration(
                                filled: false,
                                fillColor: Colors.transparent,
                                contentPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                                border: InputBorder.none, // ✅ 移除 TextFormField 自帶邊框
                              ),
                            ),
                          ),
                        ),
                        Container(height: 10.h,),
                        Container(
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

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title: Container(width: ScreenUtil().screenWidth,
                                            child: Text("確定送出?",
                                              textScaler: TextScaler.linear(
                                                  1.0), style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16.sp,
                                                  color: Color(0xff373737)),)),
                                        content: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            Container(
                                                padding: EdgeInsets.only(left:10.w,right: 10.w,top: 7.h,bottom: 7.h),
                                                width: ScreenUtil().screenWidth,child:Row(children: [


                                              Expanded(child:
                                              Text("用藥前必須三讀五對。\n三讀：取藥時、用藥時、歸藥時必須核對。\n五對：藥名、病人名稱、用藥時間、用藥方式、劑量。", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp))),


                                            ],)),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            child: Text(
                                                "取消", textScaler: TextScaler
                                                .linear(1.0), style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff373737))),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          CupertinoDialogAction(
                                            child: Text(
                                                "送出", textScaler: TextScaler
                                                .linear(1.0), style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff373737))),
                                            onPressed: () async {

                                              Navigator.pop(context);

                                              await upload_xxx_from_DRUG_DL_db3(
                                                  index:dRUG_MT.DRUG_DL_list.indexOf(e),
                                                  CMPT_NOTEx:"CMPT_NOTE1",
                                                  NOTEx: e.CMPT1_NOTE_textEditingController.text
                                              );//上傳老師委藥(簽名檔)

                                              Fluttertoast.showToast(
                                                  msg: "送出成功",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.black,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0.sp
                                              );

                                              Future.delayed(const Duration(milliseconds: 50), () {

                                                DRUG_MT_T_page_fun2!();

                                              });



                                            },
                                          ),
                                        ],
                                      );
                                    });

                              },
                              child: Row(children: [
                                Expanded(child: Container()),
                                Text('送出', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                                Expanded(child: Container()),
                              ],),
                            )),
                        Container(height: 10.h,),
                      ],)
                          :
                      Column(children: [
                        Container(height: 100.h,child:
                        Row(children: [
                          Expanded(child:
                          GestureDetector(
                              onTap: ()async{

                                DateTime? datetime = await picker.DatePicker.showTimePicker(context,
                                    showTitleActions: true,
                                    showSecondsColumn: false,
                                    /*
                            theme: picker.DatePickerTheme(
                                headerColor: Color(0xff5CADAD),
                                backgroundColor: Color(0xff5CADAD),
                                itemStyle: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22.sp),
                                cancelStyle: TextStyle(color: Colors.black, fontSize: 20.sp),
                                doneStyle: TextStyle(color: Colors.black, fontSize: 20.sp)),

                             */
                                    onChanged: (date) {
                                      print('change $date');
                                    }, onConfirm: (date) {
                                      print('confirm $date');
                                    }, currentTime: DateTime.now(), locale: picker.LocaleType.tw);

                                if(datetime!=null){
                                  timeOfDay4 = TimeOfDay.fromDateTime(datetime);
                                  e.CMPT_Time1 = "${timeOfDay4!.hour.toString().padLeft(2, '0')}:${timeOfDay4!.minute.toString().padLeft(2, '0')}:00";

                                }

                                setState(() {

                                });

                                /*
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
                            timeOfDay4 = _timeOfDay;
                            e.CMPT_Time1 = "${timeOfDay4!.hour.toString().padLeft(2, '0')}:${timeOfDay4!.minute.toString().padLeft(2, '0')}:00";
                          }
                          dev.log("${timeOfDay4!.format(context)}");


                          setState(() {

                          });

                         */

                              },
                              child: Column(children: [

                                Expanded(child:Row(children: [
                                  Container(width: 30.w,),
                                  RichText(
                                    text: TextSpan(
                                      text: '完成時間:',
                                      style: TextStyle(
                                          fontFamily: 'GenJyuuGothic',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17.sp,
                                          color: Color(0xff555555)
                                      ),
                                      children: [],
                                    ),
                                  ),
                                ],)),
                                (timeOfDay4==null)?Expanded(child:Row(children: [

                                  Expanded(child: Container(),),
                                  Container(
                                      width:100.w,
                                      height:50.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5.w),
                                      )),
                                  Container(width: 10.w,),
                                  GestureDetector(
                                      onTap:(){

                                        _showCupertinoDialog(
                                            context,
                                            index:idx,
                                            CMPT_SIGNx:"CMPT_SIGN1",
                                            CMPT_NOTEx:"CMPT_NOTE1",
                                            e:e);

                                      },
                                      child: Image.asset("assets/images/warning_15104436_0.png")),
                                  Expanded(child: Container(),),

                                ],),
                                ):Expanded(child:Container(width:100.w,
                                    height:50.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5.w),
                                    ),child:Center(child:RichText(
                                        text: TextSpan(
                                          text: '',
                                          style: TextStyle(
                                              fontFamily: 'GenJyuuGothic',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 17.sp,
                                              color: Color(0xff555555)
                                          ),
                                          children: [
                                            (timeOfDay4==null)?TextSpan(text:""):
                                            TextSpan(
                                              text: ' ${"${timeOfDay4.period==DayPeriod.am?"上午":"下午"}${timeOfDay4.hourOfPeriod}:${timeOfDay4.minute.toString().padLeft(2,"0")}"}',
                                              style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 17.sp,
                                                  color: Colors.red
                                              ),
                                            ),
                                          ],
                                        )),
                                    )))

                              ],))),

                          Expanded(child:
                          Column(children: [

                            Expanded(child:
                            Row(children: [
                              Expanded(child: Container()),
                              RichText(
                                text: TextSpan(
                                  text: '給藥者(老師)簽名',
                                  style: TextStyle(
                                      fontFamily: 'GenJyuuGothic',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 17.sp,
                                      color: Color(0xff555555)
                                  ),
                                  children: [
                                  ],
                                ),
                              ),
                              Expanded(child: Container()),

                            ],)),
                            Expanded(child:
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
                                                          if(EMPLOYEE_teacher.SIGN_LINK.isEmpty){
                                                            SmartDialog.showToast("請先至設定頁>帳號相關>輸入預設簽名");
                                                            return;
                                                          }
                                                          e.SING_LINK_TYPE1="匯入預設簽名";
                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                          SmartDialog.showLoading(msg: "處理中...");
                                                          await Future.delayed(const Duration(milliseconds: 500), () {});
                                                          e.signaturebytes1 = await get_url_image_to_byte_sub(img_url:"${EMPLOYEE_teacher.SIGN_LINK}");
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
                                                              type: PageTransitionType.rightToLeft, child: SignaturePage5(CMPT_SIGNx:"CMPT_SIGN1",DRUG_DL_index:dRUG_MT.DRUG_DL_list.indexOf(e))));
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
                                Container(
                                  width:150.w,
                                  height:40.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5.w),
                                  ),child:
                                (e.signaturebytes1!=null)?
                                Container(
                                    width:100.w,
                                    height:40.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5.w),
                                    ),child:
                                Image.memory(e.signaturebytes1!))
                                    :
                                Image.network(
                                  "${e.CMPT_SIGN1}",
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      // 圖片加載完成後觸發
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _updateHeight();
                                      });
                                    }
                                    return child;
                                  },
                                  errorBuilder: (BuildContext context, Object exception,
                                      StackTrace? stackTrace) {
                                    return Container();

                                  },
                                ),))),

                          ],)),
                        ],)),
                        Container(height: 10.h,),
                        Container(width: ScreenUtil().screenWidth,child: Row(children: [
                          Expanded(child: Container()),
                          Text('用藥說明:',textScaleFactor: 1,style: TextStyle(color: Colors.black,fontSize: 18.sp,fontWeight: FontWeight.w400),),
                          Expanded(child: Container()),
                        ],),),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                          margin: EdgeInsets.only(left: 3.w, right: 3.w, top: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: Colors.black, // 邊框顏色
                              width: 1,            // 邊框寬度
                            ),
                            borderRadius: BorderRadius.circular(6), // 一點圓角
                          ),
                          width: ScreenUtil().screenWidth,
                          child: Form(
                            child: TextFormField(
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: Colors.black,
                              ),
                              controller: e.CMPT1_NOTE_textEditingController,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              inputFormatters: [],
                              autofocus: false,
                              minLines: 3,   // ✅ 預設最少 3 行 → 大約等於 100.h 高度
                              maxLines: null, // ✅ 讓它可以隨輸入文字自動撐高
                              maxLength: 255,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (v) => setState(() {}),
                              decoration: InputDecoration(
                                filled: false,
                                fillColor: Colors.transparent,
                                contentPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                                border: InputBorder.none, // ✅ 移除 TextFormField 自帶邊框
                              ),
                            ),
                          ),
                        ),
                        Container(height: 10.h,),
                        Container(
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

                                if(e.signaturebytes1==null && e.CMPT_SIGN1.isEmpty){
                                  SmartDialog.showToast("請先簽名");
                                  return;
                                }

                                if(e.CMPT_Time1.isEmpty){
                                  SmartDialog.showToast("請填寫完成時間");
                                  return;
                                }

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title: Container(width: ScreenUtil().screenWidth,
                                            child: Text("確定送出?",
                                              textScaler: TextScaler.linear(
                                                  1.0), style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16.sp,
                                                  color: Color(0xff373737)),)),
                                        content: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            Container(
                                                padding: EdgeInsets.only(left:10.w,right: 10.w,top: 7.h,bottom: 7.h),
                                                width: ScreenUtil().screenWidth,child:Row(children: [


                                              Expanded(child:
                                              Text("用藥前必須三讀五對。\n三讀：取藥時、用藥時、歸藥時必須核對。\n五對：藥名、病人名稱、用藥時間、用藥方式、劑量。", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp))),


                                            ],)),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            child: Text(
                                                "取消", textScaler: TextScaler
                                                .linear(1.0), style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff373737))),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          CupertinoDialogAction(
                                            child: Text(
                                                "送出", textScaler: TextScaler
                                                .linear(1.0), style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff373737))),
                                            onPressed: () async {

                                              Navigator.pop(context);

                                              if(e.signaturebytes1!=null){
                                                if(e.SING_LINK_TYPE1=="匯入預設簽名"){
                                                  await upload_xxx_from_DRUG_DL_db(
                                                      CMPT_SIGNx: "CMPT_SIGN1",
                                                      CMPT_SIGN_img:EMPLOYEE_teacher.SIGN_LINK.replaceAll(IMAGE_IP,"~"),//老師簽名,
                                                      index:dRUG_MT.DRUG_DL_list.indexOf(e),
                                                      CMPT_NOTEx:"CMPT_NOTE1",
                                                      CMPT_NOTEx_text: e.CMPT1_NOTE_textEditingController.text
                                                  );//上傳老師委藥(簽名檔)
                                                }
                                                else{
                                                  String file_name = "${EMPLOYEE_teacher.ACCOUNT}_${DateTime.now().microsecondsSinceEpoch}";
                                                  await upload_image(img: e.signaturebytes1,file_name: file_name,folder: "Sign");
                                                  String SIGN_LINK = "~/School/Images/Sign/${file_name}.jpg";//老師簽名
                                                  await upload_xxx_from_DRUG_DL_db(
                                                      CMPT_SIGNx: "CMPT_SIGN1",
                                                      CMPT_SIGN_img:SIGN_LINK,
                                                      index:dRUG_MT.DRUG_DL_list.indexOf(e),
                                                      CMPT_NOTEx:"CMPT_NOTE1",
                                                      CMPT_NOTEx_text: e.CMPT1_NOTE_textEditingController.text
                                                  );//上傳老師委藥(簽名檔)
                                                }
                                              }

                                              if(e.CMPT_Time1.isNotEmpty){
                                                await upload_xxx_from_DRUG_DL_db(
                                                    CMPT_SIGNx: "CMPT_Time1",
                                                    CMPT_Time:e.CMPT_Time1,
                                                    index:dRUG_MT.DRUG_DL_list.indexOf(e),
                                                    CMPT_NOTEx:"CMPT_NOTE1",
                                                    CMPT_NOTEx_text: e.CMPT1_NOTE_textEditingController.text
                                                );//上傳老師委藥(簽名檔)
                                              }

                                              Fluttertoast.showToast(
                                                  msg: "送出成功",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.black,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0.sp
                                              );

                                              Future.delayed(const Duration(milliseconds: 50), () {

                                                DRUG_MT_T_page_fun2!();

                                              });



                                            },
                                          ),
                                        ],
                                      );
                                    });



                              },
                              child: Row(children: [
                                Expanded(child: Container()),
                                Text('送出', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                                Expanded(child: Container()),
                              ],),
                            )),
                        Container(height: 10.h,),
                      ],),

                      /*
                      (e.CMPT_NOTE1.isEmpty)?Container():
                      Column(children: [

                        Container(height: 20.h,),
                        Container(width: ScreenUtil().screenWidth,child:
                        Text('其他說明:', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 20.sp))),
                        Container(width: ScreenUtil().screenWidth,child:
                        Text("${e.CMPT_NOTE1}", style: TextStyle(decoration: TextDecoration.underline,fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 20.sp))),
                        Container(height: 20.h,),

                      ],)

                       */
                      
                    ]),
                    padding:EdgeInsets.all(8.w),
                  ),
                  Container(height: 10.h,),

                  (timeOfDay2==null)?Container():
                  Container(
                    child: Column(children: [
                      RichText(
                        text: TextSpan(
                          text: '第2次給藥:',
                          style: TextStyle(
                              fontFamily: 'GenJyuuGothic',
                              fontWeight: FontWeight.w400,
                              fontSize: 20.sp,
                              color: Color(0xff555555)
                          ),
                          children: [
                            (timeOfDay2==null)?TextSpan(text:""):
                            TextSpan(
                              text: ' ${"${timeOfDay2.period==DayPeriod.am?"上午":"下午"}${timeOfDay2.hourOfPeriod}:${timeOfDay2.minute.toString().padLeft(2,"0")}"}',
                              style: TextStyle(
                                  fontFamily: "GenJyuuGothic",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20.sp,
                                  color: Colors.red
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 20.h,),

                      (timeOfDay5==null && e.CMPT_SIGN2.contains("CancelReason"))?
                      Column(children: [

                        Image.network(
                          "${e.CMPT_SIGN2}",
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              // 圖片加載完成後觸發
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _updateHeight();
                              });
                            }
                            return child;
                          },
                        ),
                        Container(height: 10.h,),
                        Container(width: ScreenUtil().screenWidth,child: Row(children: [
                          Expanded(child: Container()),
                          Text('用藥說明:',textScaleFactor: 1,style: TextStyle(color: Colors.black,fontSize: 18.sp,fontWeight: FontWeight.w400),),
                          Expanded(child: Container()),
                        ],),),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                          margin: EdgeInsets.only(left: 3.w, right: 3.w, top: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: Colors.black, // 邊框顏色
                              width: 1,            // 邊框寬度
                            ),
                            borderRadius: BorderRadius.circular(6), // 一點圓角
                          ),
                          width: ScreenUtil().screenWidth,
                          child: Form(
                            child: TextFormField(
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: Colors.black,
                              ),
                              controller: e.CMPT2_NOTE_textEditingController,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              inputFormatters: [],
                              autofocus: false,
                              minLines: 3,   // ✅ 預設最少 3 行 → 大約等於 100.h 高度
                              maxLines: null, // ✅ 讓它可以隨輸入文字自動撐高
                              maxLength: 255,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (v) => setState(() {}),
                              decoration: InputDecoration(
                                filled: false,
                                fillColor: Colors.transparent,
                                contentPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                                border: InputBorder.none, // ✅ 移除 TextFormField 自帶邊框
                              ),
                            ),
                          ),
                        ),
                        Container(height: 10.h,),
                        Container(
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

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title: Container(width: ScreenUtil().screenWidth,
                                            child: Text("確定送出?",
                                              textScaler: TextScaler.linear(
                                                  1.0), style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16.sp,
                                                  color: Color(0xff373737)),)),
                                        content: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            Container(
                                                padding: EdgeInsets.only(left:10.w,right: 10.w,top: 7.h,bottom: 7.h),
                                                width: ScreenUtil().screenWidth,child:Row(children: [


                                              Expanded(child:
                                              Text("用藥前必須三讀五對。\n三讀：取藥時、用藥時、歸藥時必須核對。\n五對：藥名、病人名稱、用藥時間、用藥方式、劑量。", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp))),


                                            ],)),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            child: Text(
                                                "取消", textScaler: TextScaler
                                                .linear(1.0), style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff373737))),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          CupertinoDialogAction(
                                            child: Text(
                                                "送出", textScaler: TextScaler
                                                .linear(1.0), style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff373737))),
                                            onPressed: () async {

                                              Navigator.pop(context);

                                              await upload_xxx_from_DRUG_DL_db3(
                                                  index:dRUG_MT.DRUG_DL_list.indexOf(e),
                                                  CMPT_NOTEx:"CMPT_NOTE2",
                                                  NOTEx: e.CMPT2_NOTE_textEditingController.text
                                              );//上傳老師委藥(簽名檔)

                                              Fluttertoast.showToast(
                                                  msg: "送出成功",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.black,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0.sp
                                              );

                                              Future.delayed(const Duration(milliseconds: 50), () {

                                                DRUG_MT_T_page_fun2!();

                                              });



                                            },
                                          ),
                                        ],
                                      );
                                    });

                              },
                              child: Row(children: [
                                Expanded(child: Container()),
                                Text('送出', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                                Expanded(child: Container()),
                              ],),
                            )),
                        Container(height: 10.h,),

                      ],)
                          :
                      Column(children: [
                        Container(height: 100.h,child:
                        Row(children: [
                          Expanded(child:
                          GestureDetector(
                              onTap: ()async{

                                DateTime? datetime = await picker.DatePicker.showTimePicker(context,
                                    showTitleActions: true,
                                    showSecondsColumn: false,
                                    /*
                            theme: picker.DatePickerTheme(
                                headerColor: Color(0xff5CADAD),
                                backgroundColor: Color(0xff5CADAD),
                                itemStyle: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22.sp),
                                cancelStyle: TextStyle(color: Colors.black, fontSize: 20.sp),
                                doneStyle: TextStyle(color: Colors.black, fontSize: 20.sp)),

                             */
                                    onChanged: (date) {
                                      print('change $date');
                                    }, onConfirm: (date) {
                                      print('confirm $date');
                                    }, currentTime: DateTime.now(), locale: picker.LocaleType.tw);

                                if(datetime!=null){
                                  timeOfDay5 = TimeOfDay.fromDateTime(datetime);
                                  e.CMPT_Time2 = "${timeOfDay5!.hour.toString().padLeft(2, '0')}:${timeOfDay5!.minute.toString().padLeft(2, '0')}:00";

                                }

                                setState(() {

                                });

                                /*
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
                            timeOfDay4 = _timeOfDay;
                            e.CMPT_Time1 = "${timeOfDay4!.hour.toString().padLeft(2, '0')}:${timeOfDay4!.minute.toString().padLeft(2, '0')}:00";
                          }
                          dev.log("${timeOfDay4!.format(context)}");


                          setState(() {

                          });

                         */

                              },
                              child: Column(children: [

                                Expanded(child:Row(children: [
                                  Container(width: 30.w,),
                                  RichText(
                                    text: TextSpan(
                                      text: '完成時間:',
                                      style: TextStyle(
                                          fontFamily: 'GenJyuuGothic',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17.sp,
                                          color: Color(0xff555555)
                                      ),
                                      children: [],
                                    ),
                                  ),
                                ],)),
                                (timeOfDay5==null)?Expanded(child:Row(children: [

                                  Expanded(child: Container(),),
                                  Container(
                                      width:100.w,
                                      height:50.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5.w),
                                      )),
                                  Container(width: 10.w,),
                                  GestureDetector(
                                      onTap:(){

                                        _showCupertinoDialog(
                                            context,
                                            index:idx,
                                            CMPT_SIGNx:"CMPT_SIGN2",
                                            CMPT_NOTEx:"CMPT_NOTE2",
                                            e:e);

                                      },
                                      child: Image.asset("assets/images/warning_15104436_0.png")),
                                  Expanded(child: Container(),),

                                ],),
                                ):Expanded(child:Container(width:100.w,
                                    height:40.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5.w),
                                    ),child:Center(child:RichText(
                                        text: TextSpan(
                                          text: '',
                                          style: TextStyle(
                                              fontFamily: 'GenJyuuGothic',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 17.sp,
                                              color: Color(0xff555555)
                                          ),
                                          children: [
                                            (timeOfDay5==null)?TextSpan(text:""):
                                            TextSpan(
                                              text: ' ${"${timeOfDay5.period==DayPeriod.am?"上午":"下午"}${timeOfDay5.hourOfPeriod}:${timeOfDay5.minute.toString().padLeft(2,"0")}"}',
                                              style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 17.sp,
                                                  color: Colors.red
                                              ),
                                            ),
                                          ],
                                        )),
                                    )))

                              ],))),
                          Expanded(child: Column(children: [

                            Expanded(child:
                            Row(children: [
                              Expanded(child: Container()),
                              RichText(
                                text: TextSpan(
                                  text: '給藥者(老師)簽名',
                                  style: TextStyle(
                                      fontFamily: 'GenJyuuGothic',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 17.sp,
                                      color: Color(0xff555555)
                                  ),
                                  children: [
                                  ],
                                ),
                              ),
                              Expanded(child: Container()),

                            ],)),
                            Expanded(child: GestureDetector(
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
                                                          if(EMPLOYEE_teacher.SIGN_LINK.isEmpty){
                                                            SmartDialog.showToast("請先至設定頁>帳號相關>輸入預設簽名");
                                                            return;
                                                          }
                                                          e.SING_LINK_TYPE2="匯入預設簽名";
                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                          SmartDialog.showLoading(msg: "處理中...");
                                                          await Future.delayed(const Duration(milliseconds: 500), () {});
                                                          e.signaturebytes2 = await get_url_image_to_byte_sub(img_url:"${EMPLOYEE_teacher.SIGN_LINK}");
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
                                                              type: PageTransitionType.rightToLeft, child: SignaturePage5(CMPT_SIGNx:"CMPT_SIGN2",DRUG_DL_index:dRUG_MT.DRUG_DL_list.indexOf(e))));
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
                                Container(
                                  width:150.w,
                                  height:50.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5.w),
                                  ),child:
                                (e.signaturebytes2!=null)?
                                Container(
                                    width:100.w,
                                    height:40.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5.w),
                                    ),child:
                                Image.memory(e.signaturebytes2!))
                                    :
                                Image.network(
                                  "${e.CMPT_SIGN2}",
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      // 圖片加載完成後觸發
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _updateHeight();
                                      });
                                    }
                                    return child;
                                  },
                                  errorBuilder: (BuildContext context, Object exception,
                                      StackTrace? stackTrace) {
                                    return Container();

                                  },
                                ),))),

                          ],)),
                        ],)),

                        Container(height: 10.h,),
                        Container(width: ScreenUtil().screenWidth,child: Row(children: [
                          Expanded(child: Container()),
                          Text('用藥說明:',textScaleFactor: 1,style: TextStyle(color: Colors.black,fontSize: 18.sp,fontWeight: FontWeight.w400),),
                          Expanded(child: Container()),
                        ],),),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                          margin: EdgeInsets.only(left: 3.w, right: 3.w, top: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: Colors.black, // 邊框顏色
                              width: 1,            // 邊框寬度
                            ),
                            borderRadius: BorderRadius.circular(6), // 一點圓角
                          ),
                          width: ScreenUtil().screenWidth,
                          child: Form(
                            child: TextFormField(
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: Colors.black,
                              ),
                              controller: e.CMPT2_NOTE_textEditingController,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              inputFormatters: [],
                              autofocus: false,
                              minLines: 3,   // ✅ 預設最少 3 行 → 大約等於 100.h 高度
                              maxLines: null, // ✅ 讓它可以隨輸入文字自動撐高
                              maxLength: 255,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (v) => setState(() {}),
                              decoration: InputDecoration(
                                filled: false,
                                fillColor: Colors.transparent,
                                contentPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                                border: InputBorder.none, // ✅ 移除 TextFormField 自帶邊框
                              ),
                            ),
                          ),
                        ),
                        Container(height: 10.h,),
                        Container(
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

                                if(e.signaturebytes2==null && e.CMPT_SIGN2.isEmpty){
                                  SmartDialog.showToast("請先簽名");
                                  return;
                                }

                                if(e.CMPT_Time2.isEmpty){
                                  SmartDialog.showToast("請填寫完成時間");
                                  return;
                                }

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title: Container(width: ScreenUtil().screenWidth,
                                            child: Text("確定送出?",
                                              textScaler: TextScaler.linear(
                                                  1.0), style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16.sp,
                                                  color: Color(0xff373737)),)),
                                        content: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            Container(
                                                padding: EdgeInsets.only(left:10.w,right: 10.w,top: 7.h,bottom: 7.h),
                                                width: ScreenUtil().screenWidth,child:Row(children: [


                                              Expanded(child:
                                              Text("用藥前必須三讀五對。\n三讀：取藥時、用藥時、歸藥時必須核對。\n五對：藥名、病人名稱、用藥時間、用藥方式、劑量。", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp))),


                                            ],)),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            child: Text(
                                                "取消", textScaler: TextScaler
                                                .linear(1.0), style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff373737))),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          CupertinoDialogAction(
                                            child: Text(
                                                "送出", textScaler: TextScaler
                                                .linear(1.0), style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff373737))),
                                            onPressed: () async {

                                              Navigator.pop(context);

                                              if(e.signaturebytes2!=null){
                                                if(e.SING_LINK_TYPE2=="匯入預設簽名"){
                                                  await upload_xxx_from_DRUG_DL_db(
                                                      CMPT_SIGNx: "CMPT_SIGN2",
                                                      CMPT_SIGN_img:EMPLOYEE_teacher.SIGN_LINK.replaceAll(IMAGE_IP,"~"),//老師簽名,
                                                      index:dRUG_MT.DRUG_DL_list.indexOf(e),
                                                      CMPT_NOTEx:"CMPT_NOTE2",
                                                      CMPT_NOTEx_text: e.CMPT2_NOTE_textEditingController.text
                                                  );//上傳老師委藥(簽名檔)
                                                }
                                                else{
                                                  String file_name = "${EMPLOYEE_teacher.ACCOUNT}_${DateTime.now().microsecondsSinceEpoch}";
                                                  await upload_image(img: e.signaturebytes2,file_name: file_name,folder: "Sign");
                                                  String SIGN_LINK = "~/School/Images/Sign/${file_name}.jpg";//老師簽名
                                                  await upload_xxx_from_DRUG_DL_db(
                                                      CMPT_SIGNx: "CMPT_SIGN2",
                                                      CMPT_SIGN_img:SIGN_LINK,
                                                      index:dRUG_MT.DRUG_DL_list.indexOf(e),
                                                      CMPT_NOTEx:"CMPT_NOTE2",
                                                      CMPT_NOTEx_text: e.CMPT2_NOTE_textEditingController.text
                                                  );//上傳老師委藥(簽名檔)
                                                }

                                              }

                                              if(e.CMPT_Time2.isNotEmpty){
                                                await upload_xxx_from_DRUG_DL_db(
                                                    CMPT_SIGNx: "CMPT_Time2",
                                                    CMPT_Time:e.CMPT_Time2,
                                                    index:dRUG_MT.DRUG_DL_list.indexOf(e),
                                                    CMPT_NOTEx:"CMPT_NOTE2",
                                                    CMPT_NOTEx_text: e.CMPT2_NOTE_textEditingController.text
                                                );//上傳老師委藥(簽名檔)
                                              }

                                              Fluttertoast.showToast(
                                                  msg: "送出成功",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.black,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0.sp
                                              );

                                              Future.delayed(const Duration(milliseconds: 50), () {

                                                DRUG_MT_T_page_fun2!();

                                              });



                                            },
                                          ),
                                        ],
                                      );
                                    });



                              },
                              child: Row(children: [
                                Expanded(child: Container()),
                                Text('送出', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                                Expanded(child: Container()),
                              ],),
                            )),
                        Container(height: 10.h,),
                      ],),


                      /*
                      (e.CMPT_NOTE2.isEmpty)?Container():
                      Column(children: [

                        Container(height: 20.h,),
                        Container(width: ScreenUtil().screenWidth,child:
                        Text('其他說明:', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 20.sp))),
                        Container(width: ScreenUtil().screenWidth,child:
                        Text("${e.CMPT_NOTE2}", style: TextStyle(decoration: TextDecoration.underline,fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 20.sp))),
                        Container(height: 20.h,),

                      ],)

                       */


                    ]),
                    padding:EdgeInsets.all(8.w),
                  ),

                  Container(height: 10.h,),
                  (timeOfDay3==null)?Container():
                  Container(
                    child: Column(children: [
                      RichText(
                        text: TextSpan(
                          text: '第3次給藥:',
                          style: TextStyle(
                              fontFamily: 'GenJyuuGothic',
                              fontWeight: FontWeight.w400,
                              fontSize: 20.sp,
                              color: Color(0xff555555)
                          ),
                          children: [
                            (timeOfDay3==null)?TextSpan(text:""):
                            TextSpan(
                              text: ' ${"${timeOfDay3.period==DayPeriod.am?"上午":"下午"}${timeOfDay3.hourOfPeriod}:${timeOfDay3.minute.toString().padLeft(2,"0")}"}',
                              style: TextStyle(
                                  fontFamily: "GenJyuuGothic",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20.sp,
                                  color: Colors.red
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(height: 20.h,),

                      (timeOfDay6==null && e.CMPT_SIGN3.contains("CancelReason"))?
                        Column(children: [
                          Image.network(
                            "${e.CMPT_SIGN3}",
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                // 圖片加載完成後觸發
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  _updateHeight();
                                });
                              }
                              return child;
                            },
                          ),
                          Container(height: 10.h,),
                          Container(width: ScreenUtil().screenWidth,child: Row(children: [
                            Expanded(child: Container()),
                            Text('用藥說明:',textScaleFactor: 1,style: TextStyle(color: Colors.black,fontSize: 18.sp,fontWeight: FontWeight.w400),),
                            Expanded(child: Container()),
                          ],),),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                            margin: EdgeInsets.only(left: 3.w, right: 3.w, top: 10.h),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                color: Colors.black, // 邊框顏色
                                width: 1,            // 邊框寬度
                              ),
                              borderRadius: BorderRadius.circular(6), // 一點圓角
                            ),
                            width: ScreenUtil().screenWidth,
                            child: Form(
                              child: TextFormField(
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  color: Colors.black,
                                ),
                                controller: e.CMPT3_NOTE_textEditingController,
                                keyboardType: TextInputType.multiline,
                                textInputAction: TextInputAction.newline,
                                inputFormatters: [],
                                autofocus: false,
                                minLines: 3,   // ✅ 預設最少 3 行 → 大約等於 100.h 高度
                                maxLines: null, // ✅ 讓它可以隨輸入文字自動撐高
                                maxLength: 255,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                onChanged: (v) => setState(() {}),
                                decoration: InputDecoration(
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                                  border: InputBorder.none, // ✅ 移除 TextFormField 自帶邊框
                                ),
                              ),
                            ),
                          ),
                          Container(height: 10.h,),
                          Container(
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

                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CupertinoAlertDialog(
                                          title: Container(width: ScreenUtil().screenWidth,
                                              child: Text("確定送出?",
                                                textScaler: TextScaler.linear(
                                                    1.0), style: TextStyle(
                                                    fontFamily: "GenJyuuGothic",
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16.sp,
                                                    color: Color(0xff373737)),)),
                                          content: Column(
                                            children: <Widget>[
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              Container(
                                                  padding: EdgeInsets.only(left:10.w,right: 10.w,top: 7.h,bottom: 7.h),
                                                  width: ScreenUtil().screenWidth,child:Row(children: [


                                                Expanded(child:
                                                Text("用藥前必須三讀五對。\n三讀：取藥時、用藥時、歸藥時必須核對。\n五對：藥名、病人名稱、用藥時間、用藥方式、劑量。", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp))),


                                              ],)),
                                            ],
                                          ),
                                          actions: <Widget>[
                                            CupertinoDialogAction(
                                              child: Text(
                                                  "取消", textScaler: TextScaler
                                                  .linear(1.0), style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16.sp,
                                                  color: Color(0xff373737))),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                            CupertinoDialogAction(
                                              child: Text(
                                                  "送出", textScaler: TextScaler
                                                  .linear(1.0), style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16.sp,
                                                  color: Color(0xff373737))),
                                              onPressed: () async {

                                                Navigator.pop(context);

                                                await upload_xxx_from_DRUG_DL_db3(
                                                    index:dRUG_MT.DRUG_DL_list.indexOf(e),
                                                    CMPT_NOTEx:"CMPT_NOTE3",
                                                    NOTEx: e.CMPT3_NOTE_textEditingController.text
                                                );//上傳老師委藥(簽名檔)

                                                Fluttertoast.showToast(
                                                    msg: "送出成功",
                                                    toastLength: Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.CENTER,
                                                    timeInSecForIosWeb: 1,
                                                    backgroundColor: Colors.black,
                                                    textColor: Colors.white,
                                                    fontSize: 16.0.sp
                                                );

                                                Future.delayed(const Duration(milliseconds: 50), () {

                                                  DRUG_MT_T_page_fun2!();

                                                });



                                              },
                                            ),
                                          ],
                                        );
                                      });

                                },
                                child: Row(children: [
                                  Expanded(child: Container()),
                                  Text('送出', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                                  Expanded(child: Container()),
                                ],),
                              )),
                          Container(height: 10.h,),
                        ],)
                          :
                       Column(children: [
                        Container(height: 100.h,child:
                        Row(children: [
                          Expanded(child:
                          GestureDetector(
                              onTap: ()async{

                                DateTime? datetime = await picker.DatePicker.showTimePicker(context,
                                    showTitleActions: true,
                                    showSecondsColumn: false,
                                    /*
                            theme: picker.DatePickerTheme(
                                headerColor: Color(0xff5CADAD),
                                backgroundColor: Color(0xff5CADAD),
                                itemStyle: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22.sp),
                                cancelStyle: TextStyle(color: Colors.black, fontSize: 20.sp),
                                doneStyle: TextStyle(color: Colors.black, fontSize: 20.sp)),

                             */
                                    onChanged: (date) {
                                      print('change $date');
                                    }, onConfirm: (date) {
                                      print('confirm $date');
                                    }, currentTime: DateTime.now(), locale: picker.LocaleType.tw);

                                if(datetime!=null){
                                  timeOfDay6 = TimeOfDay.fromDateTime(datetime);
                                  e.CMPT_Time3 = "${timeOfDay6!.hour.toString().padLeft(2, '0')}:${timeOfDay6!.minute.toString().padLeft(2, '0')}:00";

                                }

                                setState(() {

                                });

                                /*
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
                            timeOfDay4 = _timeOfDay;
                            e.CMPT_Time1 = "${timeOfDay4!.hour.toString().padLeft(2, '0')}:${timeOfDay4!.minute.toString().padLeft(2, '0')}:00";
                          }
                          dev.log("${timeOfDay4!.format(context)}");


                          setState(() {

                          });

                         */

                              },
                              child: Column(children: [

                                Expanded(child:Row(children: [
                                  Container(width: 30.w,),
                                  RichText(
                                    text: TextSpan(
                                      text: '完成時間:',
                                      style: TextStyle(
                                          fontFamily: 'GenJyuuGothic',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 17.sp,
                                          color: Color(0xff555555)
                                      ),
                                      children: [],
                                    ),
                                  ),
                                ],)),
                                (timeOfDay6==null)?Expanded(child:Row(children: [

                                  Expanded(child: Container(),),
                                  Container(
                                      width:100.w,
                                      height:50.h,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(5.w),
                                      )),
                                  Container(width: 10.w,),
                                  GestureDetector(
                                      onTap:(){

                                        _showCupertinoDialog(
                                            context,
                                            index:idx,
                                            CMPT_SIGNx:"CMPT_SIGN3",
                                            CMPT_NOTEx:"CMPT_NOTE3",
                                            e:e);

                                      },
                                      child: Image.asset("assets/images/warning_15104436_0.png")),
                                  Expanded(child: Container(),),

                                ],),
                                ):Expanded(child:Container(width:100.w,
                                    height:40.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5.w),
                                    ),child:Center(child:RichText(
                                        text: TextSpan(
                                          text: '',
                                          style: TextStyle(
                                              fontFamily: 'GenJyuuGothic',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 17.sp,
                                              color: Color(0xff555555)
                                          ),
                                          children: [
                                            (timeOfDay6==null)?TextSpan(text:""):
                                            TextSpan(
                                              text: ' ${"${timeOfDay6.period==DayPeriod.am?"上午":"下午"}${timeOfDay6.hourOfPeriod}:${timeOfDay6.minute.toString().padLeft(2,"0")}"}',
                                              style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 17.sp,
                                                  color: Colors.red
                                              ),
                                            ),
                                          ],
                                        )),
                                    )))

                              ],))),
                          Expanded(child:
                          Column(children: [

                            Expanded(child:
                            Row(children: [
                              Expanded(child: Container()),
                              RichText(
                                text: TextSpan(
                                  text: '給藥者(老師)簽名',
                                  style: TextStyle(
                                      fontFamily: 'GenJyuuGothic',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 17.sp,
                                      color: Color(0xff555555)
                                  ),
                                  children: [
                                  ],
                                ),
                              ),
                              Expanded(child: Container()),

                            ],)),
                            Expanded(child:
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
                                                          if(EMPLOYEE_teacher.SIGN_LINK.isEmpty){
                                                            SmartDialog.showToast("請先至設定頁>帳號相關>輸入預設簽名");
                                                            return;
                                                          }
                                                          e.SING_LINK_TYPE3="匯入預設簽名";
                                                          FocusManager.instance.primaryFocus?.unfocus();
                                                          SmartDialog.showLoading(msg: "處理中...");
                                                          await Future.delayed(const Duration(milliseconds: 500), () {});
                                                          e.signaturebytes3 = await get_url_image_to_byte_sub(img_url:"${EMPLOYEE_teacher.SIGN_LINK}");
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
                                                              type: PageTransitionType.rightToLeft, child: SignaturePage5(CMPT_SIGNx:"CMPT_SIGN3",DRUG_DL_index:dRUG_MT.DRUG_DL_list.indexOf(e))));
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
                                Container(
                                  width:150.w,
                                  height:40.h,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(5.w),
                                  ),child:
                                (e.signaturebytes3!=null)?
                                Container(
                                    width:100.w,
                                    height:40.h,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5.w),
                                    ),child:
                                Image.memory(e.signaturebytes3!))
                                    :
                                Image.network(
                                  "${e.CMPT_SIGN3}",
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      // 圖片加載完成後觸發
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        _updateHeight();
                                      });
                                    }
                                    return child;
                                  },
                                  errorBuilder: (BuildContext context, Object exception,
                                      StackTrace? stackTrace) {
                                    return Container();

                                  },
                                ),))),

                          ],)),
                        ],)),

                        Container(height: 10.h,),
                        Container(width: ScreenUtil().screenWidth,child: Row(children: [
                          Expanded(child: Container()),
                          Text('用藥說明:',textScaleFactor: 1,style: TextStyle(color: Colors.black,fontSize: 18.sp,fontWeight: FontWeight.w400),),
                          Expanded(child: Container()),
                        ],),),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                          margin: EdgeInsets.only(left: 3.w, right: 3.w, top: 10.h),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: Colors.black, // 邊框顏色
                              width: 1,            // 邊框寬度
                            ),
                            borderRadius: BorderRadius.circular(6), // 一點圓角
                          ),
                          width: ScreenUtil().screenWidth,
                          child: Form(
                            child: TextFormField(
                              style: TextStyle(
                                fontSize: 20.sp,
                                color: Colors.black,
                              ),
                              controller: e.CMPT3_NOTE_textEditingController,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                              inputFormatters: [],
                              autofocus: false,
                              minLines: 3,   // ✅ 預設最少 3 行 → 大約等於 100.h 高度
                              maxLines: null, // ✅ 讓它可以隨輸入文字自動撐高
                              maxLength: 255,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              onChanged: (v) => setState(() {}),
                              decoration: InputDecoration(
                                filled: false,
                                fillColor: Colors.transparent,
                                contentPadding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 10.h),
                                border: InputBorder.none, // ✅ 移除 TextFormField 自帶邊框
                              ),
                            ),
                          ),
                        ),
                        Container(height: 10.h,),
                        Container(
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

                                if(e.signaturebytes3==null && e.CMPT_SIGN3.isEmpty){
                                  SmartDialog.showToast("請先簽名");
                                  return;
                                }

                                if(e.CMPT_Time3.isEmpty){
                                  SmartDialog.showToast("請填寫完成時間");
                                  return;
                                }

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CupertinoAlertDialog(
                                        title: Container(width: ScreenUtil().screenWidth,
                                            child: Text("確定送出?",
                                              textScaler: TextScaler.linear(
                                                  1.0), style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16.sp,
                                                  color: Color(0xff373737)),)),
                                        content: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            Container(
                                                padding: EdgeInsets.only(left:10.w,right: 10.w,top: 7.h,bottom: 7.h),
                                                width: ScreenUtil().screenWidth,child:Row(children: [


                                              Expanded(child:
                                              Text("用藥前必須三讀五對。\n三讀：取藥時、用藥時、歸藥時必須核對。\n五對：藥名、病人名稱、用藥時間、用藥方式、劑量。", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp))),


                                            ],)),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            child: Text(
                                                "取消", textScaler: TextScaler
                                                .linear(1.0), style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff373737))),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          CupertinoDialogAction(
                                            child: Text(
                                                "送出", textScaler: TextScaler
                                                .linear(1.0), style: TextStyle(
                                                fontFamily: "GenJyuuGothic",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16.sp,
                                                color: Color(0xff373737))),
                                            onPressed: () async {

                                              Navigator.pop(context);

                                              if(e.signaturebytes3!=null){
                                                if(e.SING_LINK_TYPE3=="匯入預設簽名"){
                                                  await upload_xxx_from_DRUG_DL_db(
                                                      CMPT_SIGNx: "CMPT_SIGN3",
                                                      CMPT_SIGN_img:EMPLOYEE_teacher.SIGN_LINK.replaceAll(IMAGE_IP,"~"),//老師簽名,
                                                      index:dRUG_MT.DRUG_DL_list.indexOf(e),
                                                      CMPT_NOTEx:"CMPT_NOTE3",
                                                      CMPT_NOTEx_text: e.CMPT3_NOTE_textEditingController.text
                                                  );//上傳老師委藥(簽名檔)
                                                }
                                                else{
                                                  String file_name = "${EMPLOYEE_teacher.ACCOUNT}_${DateTime.now().microsecondsSinceEpoch}";
                                                  await upload_image(img: e.signaturebytes3,file_name: file_name,folder: "Sign");
                                                  String SIGN_LINK = "~/School/Images/Sign/${file_name}.jpg";//老師簽名
                                                  await upload_xxx_from_DRUG_DL_db(
                                                      CMPT_SIGNx: "CMPT_SIGN3",
                                                      CMPT_SIGN_img:SIGN_LINK,
                                                      index:dRUG_MT.DRUG_DL_list.indexOf(e),
                                                      CMPT_NOTEx:"CMPT_NOTE3",
                                                      CMPT_NOTEx_text: e.CMPT3_NOTE_textEditingController.text
                                                  );//上傳老師委藥(簽名檔)
                                                }

                                              }

                                              if(e.CMPT_Time3.isNotEmpty){
                                                await upload_xxx_from_DRUG_DL_db(
                                                    CMPT_SIGNx: "CMPT_Time3",
                                                    CMPT_Time:e.CMPT_Time3,
                                                    index:dRUG_MT.DRUG_DL_list.indexOf(e),
                                                    CMPT_NOTEx:"CMPT_NOTE3",
                                                    CMPT_NOTEx_text: e.CMPT3_NOTE_textEditingController.text
                                                );//上傳老師委藥(簽名檔)
                                              }

                                              Fluttertoast.showToast(
                                                  msg: "送出成功",
                                                  toastLength: Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.CENTER,
                                                  timeInSecForIosWeb: 1,
                                                  backgroundColor: Colors.black,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0.sp
                                              );

                                              Future.delayed(const Duration(milliseconds: 50), () {

                                                DRUG_MT_T_page_fun2!();

                                              });



                                            },
                                          ),
                                        ],
                                      );
                                    });



                              },
                              child: Row(children: [
                                Expanded(child: Container()),
                                Text('送出', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                                Expanded(child: Container()),
                              ],),
                            )),
                        Container(height: 10.h,),
                      ],),

                      /*
                      (e.CMPT_NOTE3.isEmpty)?Container():
                      Column(children: [

                        Container(height: 20.h,),
                        Container(width: ScreenUtil().screenWidth,child:
                        Text('其他說明:', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 20.sp))),
                        Container(width: ScreenUtil().screenWidth,child:
                        Text("${e.CMPT_NOTE3}", style: TextStyle(decoration: TextDecoration.underline,fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 20.sp))),
                        Container(height: 20.h,),

                      ],)

                       */


                    ]),
                    padding:EdgeInsets.all(8.w),
                  ),
                  Container(height: 20.h,),

            ]);



            // 为每个页面指定 GlobalKey 以便测量高度
            return ListView(
              padding: EdgeInsets.zero,
              physics:NeverScrollableScrollPhysics(),
              children: [
                page,
              ],);
          }).toList(),
        ))

      ],),
    );
  }
}


class MeasurableWidget extends StatefulWidget {
  const MeasurableWidget({
    Key? key,
    required this.child,
    required this.onSized,
  }) : super(key: key);
  final Widget child;
  final void Function(Size size) onSized;

  @override
  _MeasurableWidgetState createState() => _MeasurableWidgetState();
}

class _MeasurableWidgetState extends State<MeasurableWidget> {
  bool _hasMeasured = false;

  @override
  Widget build(BuildContext context) {
    Size size = (context.findRenderObject() as RenderBox?)?.size ?? Size.zero;
    if (size != Size.zero) {
      widget.onSized.call(size);
    } else if (!_hasMeasured) {
      // Need to build twice in order to get size
      scheduleMicrotask(() => setState(() => _hasMeasured = true));
    }
    return widget.child;
  }
}
