import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:widget_zoom/widget_zoom.dart';
import 'api.dart';
import 'dart:developer' as dev;

class FlexiblePageView_u extends StatefulWidget {

  List<DRUG_DL> DRUG_DL_list = [];
  int index=0;
  FlexiblePageView_u({List<DRUG_DL>? DRUG_DL_list,int index=0}){
    this.DRUG_DL_list = DRUG_DL_list!;
    this.index = index;
  }

  @override
  _FlexiblePageViewState_u createState() => _FlexiblePageViewState_u(DRUG_DL_list:this.DRUG_DL_list,index:index);
}

class _FlexiblePageViewState_u extends State<FlexiblePageView_u> {
  late PageController _pageController;
  int _currentPage = 0;
  double _pageHeight = 200; // 默认初始高度
  final List<GlobalKey> _keys = [];

  List<DRUG_DL> DRUG_DL_list = [];
  int index=0;
  _FlexiblePageViewState_u({List<DRUG_DL>? DRUG_DL_list,int index=0}){
    this.DRUG_DL_list = DRUG_DL_list!;
    this.index = index;
  }


  @override
  void initState() {
    super.initState();
    dev.log("void initState()-1");
    // 为每个页面生成 GlobalKey
    _keys.addAll(List.generate(DRUG_DL_list.length, (_) => GlobalKey()));
    // 首次渲染后测量高度
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());

    _pageController = PageController(initialPage: 0);

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
        DRUG_MT_list_for_month[index].DRUG_DL_list[_currentPage].cachedFlexiblePage_pageHeight = newHeight+drugTilesHeight;
      });
      /*
      if (newHeight > DRUG_MT_list_for_month[index].DRUG_DL_list[_currentPage].cachedFlexiblePage_pageHeight) { // 加入誤差容忍
        setState(() {
          DRUG_MT_list_for_month[index].DRUG_DL_list[_currentPage].cachedFlexiblePage_pageHeight = newHeight;
        });
      }

       */
    }
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
              DRUG_DL_list[index].DETAIL,
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
    for (int i = 0; i < DRUG_DL_list.length; i += 2) {
      final isLastOdd = (i == DRUG_DL_list.length - 1);
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
      if (i + 2 < DRUG_DL_list.length) rows.add(SizedBox(height: mainGap));
    }

    return Column(children: rows);
  }

  // 計算 drugTiles 總高度
  double get drugTilesHeight {
    final mainGap = 8.w;   // 垂直間距
    final tileHeight = 60.w; // 你 tile 大約的高度 (自己調整)

    final count = DRUG_DL_list.length;
    final rowCount = (count / 2).ceil(); // 每列兩個，算出總列數
    final totalGap = (rowCount - 1) * mainGap;

    return rowCount * tileHeight + totalGap;
  }


  @override
  Widget build(BuildContext context) {

    //dev.log("DRUG_MT_list_for_month[index].DRUG_DL_list[_currentPage].cachedFlexiblePage_pageHeight:${DRUG_MT_list_for_month[index].DRUG_DL_list[_currentPage].cachedFlexiblePage_pageHeight}");

    // 檢查 List 是否為空，或是 index 是否超出了範圍
    if (DRUG_MT_list_for_month.isEmpty || index >= DRUG_MT_list_for_month.length) {
      return const Center(
        child: CircularProgressIndicator(), // 顯示轉圈圈，或者回傳 SizedBox()
      );
    }

    final currentMonthData = DRUG_MT_list_for_month[index];

    // 先判斷清單是否有資料
    if (currentMonthData.DRUG_DL_list.isEmpty) {
      return const SizedBox(height: 50, child: Center(child: Text("無資料")));
    }

    // 確保分頁索引安全
    final safePage = _currentPage < currentMonthData.DRUG_DL_list.length ? _currentPage : 0;
    final pageHeight = currentMonthData.DRUG_DL_list[safePage].cachedFlexiblePage_pageHeight;

    return Container(
      //height: DRUG_MT_list_for_month[index].DRUG_DL_list[_currentPage].cachedFlexiblePage_pageHeight,
      height: pageHeight,
      child: Column(children: [
        /*
        SmoothPageIndicator(
          controller: _pageController,
          count: DRUG_DL_list.length,
          effect: WormEffect(
            dotHeight: 10.w,
            dotWidth: 10.w,
            type: WormType.thinUnderground,
          ),
        ),

         */
        Container(height: 5.h,),
        SizedBox(
          height: drugTilesHeight,
          child: drugTiles(),
        ),
        /*
        GridView.count(
        shrinkWrap: true, padding: EdgeInsets.zero, // 移除預設 padding
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, // 每列 2 個
        mainAxisSpacing: 8.w,
        crossAxisSpacing: 16.w,
        childAspectRatio: 3.0, // 長方形比例，可調整
        children: List.generate(DRUG_DL_list.length, (index) {
          bool isActive = index == _currentPage;
          return GestureDetector(
              onTap: (){
                _pageController.jumpToPage(index);
              },
              child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? Color(0xff46c3bc) : Color(0xffffb11f),
              borderRadius: BorderRadius.circular(12), // 四角圓弧
            ),
            child: Center(
              child: AutoSizeText(
                  DRUG_DL_list[index].DETAIL,
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
        Container(height: 5.h,),
        Expanded(child:
        PageView(
          controller: _pageController,
          onPageChanged: (index) {
            _currentPage = index;
            // 延后测量，确保页面渲染完成
            WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
          },
          children: DRUG_DL_list.asMap().entries.map((e) {


            String _STORE = "";
            String _MODE = "";
            String _UNIT = "";
            String _DOSAGE = "";


            try{
              _STORE = dRUG_STORE.DRUG_STORE_ITEM_list.firstWhere((element) => element.ITEM_NO==e.value.STORE).ITEM_NM;
              _MODE = dRUG_MODE.DRUG_MODE_ITEM_list.firstWhere((element) => element.ITEM_NO==e.value.MODE).ITEM_NM;
            }
            catch(e){

            }

            try{
              _UNIT = DRUG_UNIT_ITEM_list.firstWhere((element) => element.ITEM_NO==e.value.UNIT).ITEM_NM;
            }
            catch(e){

            }

            try{
              _DOSAGE = e.value.DOSAGE.replaceAll("\n", "").replaceAll("\r", "").replaceAll(" ", "");
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
              List<String> t1 = e.value.TIME1.split(":");
              timeOfDay1 = TimeOfDay(hour: int.parse(t1[0]),minute: int.parse(t1[1]));
            }
            catch(e){

            }

            try{
              List<String> t2 = e.value.TIME2.split(":");
              timeOfDay2 = TimeOfDay(hour: int.parse(t2[0]),minute: int.parse(t2[1]));
            }
            catch(e){

            }

            try{
              List<String> t3 = e.value.TIME3.split(":");
              timeOfDay3 = TimeOfDay(hour: int.parse(t3[0]),minute: int.parse(t3[1]));
            }
            catch(e){

            }

            try{
              List<String> t4 = e.value.CMPT_Time1.split(":");
              timeOfDay4 = TimeOfDay(hour: int.parse(t4[0]),minute: int.parse(t4[1]));
            }
            catch(e){

            }

            try{
              List<String> t5 = e.value.CMPT_Time2.split(":");
              timeOfDay5 = TimeOfDay(hour: int.parse(t5[0]),minute: int.parse(t5[1]));
            }
            catch(e){

            }

            try{
              List<String> t6 = e.value.CMPT_Time3.split(":");
              timeOfDay6 = TimeOfDay(hour: int.parse(t6[0]),minute: int.parse(t6[1]));
            }
            catch(e){

            }



            int idx = e.key;
            Widget page = Column(
                key: _keys[idx],
                mainAxisAlignment: MainAxisAlignment.start,children: [

              Container(
                  padding:EdgeInsets.all(10.w),
                  decoration:BoxDecoration(
                    color: Color(0xffffe38e),
                    borderRadius: BorderRadius.circular(10.w),
                  ),child:
              Column(children: [
                Container(width: ScreenUtil().screenWidth,height: 150.h,child: WidgetZoom(
                    heroAnimationTag: "${e.value.DRUG_LINK}",
                    zoomWidget:Image.network(
                      "${e.value.DRUG_LINK}",
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
                Container(height: 10.h,),
                /*
                Container(
                  //margin:EdgeInsets.only(left:10.w,right: 10.w),
                    padding:EdgeInsets.only(top:8.w,bottom: 8.w),
                    decoration:BoxDecoration(
                      color: Color(0xfffefce2),
                      borderRadius: BorderRadius.circular(30.w),
                    ),
                    width: ScreenUtil().screenWidth,child:Center(child:Text("明細(${DRUG_MT_list_for_month[index].DRUG_DL_list.indexOf(e.value)+1})",style: TextStyle(
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
                          text: ' ${e.value.DETAIL}',
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
                          text: ' ${e.value.NOTE}',
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
                decoration:BoxDecoration(
                  color: Color(0xffffe38e),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                padding:EdgeInsets.only(top: 5.h,bottom: 5.h),
                width: ScreenUtil().screenWidth,child:Center(child:RichText(
                text: TextSpan(
                  text: '第1次給藥:',
                  style: TextStyle(
                      fontFamily: 'GenJyuuGothic',
                      fontWeight: FontWeight.w400,
                      fontSize: 17.sp,
                      color: Color(0xff555555)
                  ),
                  children: [
                    (timeOfDay1==null)?TextSpan(text:""):
                    TextSpan(
                      text: ' ${"${timeOfDay1.period==DayPeriod.am?"上午":"下午"}${timeOfDay1.hourOfPeriod}:${timeOfDay1.minute.toString().padLeft(2,"0")}"}',
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
              ),
              Container(height: 15.h,),

              (timeOfDay4==null && e.value.CMPT_SIGN1.contains("CancelReason"))?
              Image.network(
                  e.value.CMPT_SIGN1,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      // 圖片加載完成後觸發
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _updateHeight();
                      });
                    }
                    return child;
                  },
              )
                  :
              Column(children: [
                Row(children: [

                  Expanded(child:Container()),
                  RichText(
                    text: TextSpan(
                      text: '完成時間:',
                      style: TextStyle(
                          fontFamily: 'GenJyuuGothic',
                          fontWeight: FontWeight.w400,
                          fontSize: 20.sp,
                          color: Color(0xff555555)
                      ),
                      children: [],
                    ),
                  ),
                  Container(width:10.w),
                  Container(
                      width:100.w,
                      height:50.h,
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10.w),
                          border: Border.all(
                            width: 1,
                            color: Colors.black54,
                          )),
                      child:Center(child:RichText(
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
                        ),
                      ))),
                  Expanded(child:Container()),

                ],),
                Container(height: 15.h,),
                Container(
                  decoration:BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  child: Column(children: [
                    Row(children: [

                      Expanded(child:Container()),
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
                      Expanded(child:Container()),

                    ],),
                    Container(width: ScreenUtil().screenWidth,height:150.h,child:
                    Image.network(
                      "${e.value.CMPT_SIGN1}",
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
                        return  Center(child:Text("未完成",textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),));
                      },
                    ),),
                  ]),
                  padding:EdgeInsets.all(6.w),
                ),
              ],),
              (e.value.CMPT_NOTE1.isEmpty)?Container():
              Column(children: [

                Container(height: 20.h,),
                Container(width: ScreenUtil().screenWidth,child:
                Text('其他說明:', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 20.sp))),
                Container(width: ScreenUtil().screenWidth,child:
                Text("${e.value.CMPT_NOTE1}", style: TextStyle(decoration: TextDecoration.underline,fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 20.sp))),
                Container(height: 20.h,),

              ],),

              Container(height: 40.h,),


              

              (timeOfDay2==null)?Container():
              Column(children: [
                Container(
                  decoration:BoxDecoration(
                    color: Color(0xffffe38e),
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  padding:EdgeInsets.only(top: 5.h,bottom: 5.h),
                  width: ScreenUtil().screenWidth,child:Center(child:RichText(
                  text: TextSpan(
                    text: '第2次給藥:',
                    style: TextStyle(
                        fontFamily: 'GenJyuuGothic',
                        fontWeight: FontWeight.w400,
                        fontSize: 17.sp,
                        color: Color(0xff555555)
                    ),
                    children: [
                      (timeOfDay2==null)?TextSpan(text:""):
                      TextSpan(
                        text: ' ${"${timeOfDay2.period==DayPeriod.am?"上午":"下午"}${timeOfDay2.hourOfPeriod}:${timeOfDay2.minute.toString().padLeft(2,"0")}"}',
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
                ),
                Container(height: 15.h,),

                (timeOfDay5==null && e.value.CMPT_SIGN2.contains("CancelReason"))?
                Image.network(
                    e.value.CMPT_SIGN2,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        // 圖片加載完成後觸發
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _updateHeight();
                        });
                      }
                      return child;
                  },
                )
                    :
                Column(children: [
                  Row(children: [

                    Expanded(child:Container()),
                    RichText(
                      text: TextSpan(
                        text: '完成時間:',
                        style: TextStyle(
                            fontFamily: 'GenJyuuGothic',
                            fontWeight: FontWeight.w400,
                            fontSize: 20.sp,
                            color: Color(0xff555555)
                        ),
                        children: [],
                      ),
                    ),
                    Container(width:10.w),
                    Container(
                        width:100.w,
                        height:50.h,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10.w),
                            border: Border.all(
                              width: 1,
                              color: Colors.black54,
                            )),
                        child:Center(child:RichText(
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
                          ),
                        ))),
                    Expanded(child:Container()),

                  ],),
                  Container(height: 15.h,),
                  Container(
                    decoration:BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    child: Column(children: [
                      Row(children: [

                        Expanded(child:Container()),
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
                        Expanded(child:Container()),

                      ],),
                      Container(width: ScreenUtil().screenWidth,height:150.h,child:
                      Image.network(
                        "${e.value.CMPT_SIGN2}",
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
                          return  Center(child:Text("未完成",textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),));
                        },
                      )),
                    ]),
                    padding:EdgeInsets.all(6.w),
                  ),
                ],),
                (e.value.CMPT_NOTE2.isEmpty)?Container():
                Column(children: [

                  Container(height: 20.h,),
                  Container(width: ScreenUtil().screenWidth,child:
                  Text('其他說明:', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 20.sp))),
                  Container(width: ScreenUtil().screenWidth,child:
                  Text("${e.value.CMPT_NOTE2}", style: TextStyle(decoration: TextDecoration.underline,fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 20.sp))),
                  Container(height: 20.h,),

                ],),
                Container(height: 40.h,),
              ],),


              (timeOfDay3==null)?Container():
              Column(children: [
                Container(
                  decoration:BoxDecoration(
                    color: Color(0xffffe38e),
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  padding:EdgeInsets.only(top: 5.h,bottom: 5.h),
                  width: ScreenUtil().screenWidth,child:Center(child:RichText(
                  text: TextSpan(
                    text: '第3次給藥:',
                    style: TextStyle(
                        fontFamily: 'GenJyuuGothic',
                        fontWeight: FontWeight.w400,
                        fontSize: 17.sp,
                        color: Color(0xff555555)
                    ),
                    children: [
                      (timeOfDay3==null)?TextSpan(text:""):
                      TextSpan(
                        text: ' ${"${timeOfDay3.period==DayPeriod.am?"上午":"下午"}${timeOfDay3.hourOfPeriod}:${timeOfDay3.minute.toString().padLeft(2,"0")}"}',
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
                ),
                Container(height: 15.h,),

                (timeOfDay6==null && e.value.CMPT_SIGN3.contains("CancelReason"))?
                Image.network(
                    e.value.CMPT_SIGN3,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        // 圖片加載完成後觸發
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _updateHeight();
                        });
                      }
                      return child;
                    },
                )
                    :
                Column(children: [
                  Row(children: [

                    Expanded(child:Container()),
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
                    Container(width:10.w),
                    Container(
                        width:100.w,
                        height:50.h,
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10.w),
                            border: Border.all(
                              width: 1,
                              color: Colors.black54,
                            )),
                        child:Center(child:RichText(
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
                          ),
                        ))),
                    Expanded(child:Container()),

                  ],),
                  Container(height: 15.h,),
                  Container(
                    decoration:BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    child: Column(children: [
                      Row(children: [

                        Expanded(child:Container()),
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
                        Expanded(child:Container()),

                      ],),
                      Container(width: ScreenUtil().screenWidth,height:150.h,child:
                      Image.network("${e.value.CMPT_SIGN3}",
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
                          return  Center(child:Text("未完成",textScaler: TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 20.sp),));
                        },
                      )),
                    ]),
                    padding:EdgeInsets.all(6.w),
                  ),
                ],),
                (e.value.CMPT_NOTE3.isEmpty)?Container():
                Column(children: [

                  Container(height: 20.h,),
                  Container(width: ScreenUtil().screenWidth,child:
                  Text('其他說明:', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 20.sp))),
                  Container(width: ScreenUtil().screenWidth,child:
                  Text("${e.value.CMPT_NOTE3}", style: TextStyle(decoration: TextDecoration.underline,fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 20.sp))),
                  Container(height: 20.h,),

                ],),
                Container(height: 40.h,),
              ],),

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
