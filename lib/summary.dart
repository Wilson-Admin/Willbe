import 'dart:convert';
import 'dart:io';
import 'package:code3/utils/AppLoadingDialog.dart';
import 'package:code3/utils/DynamicMonthTablePage.dart';
import 'package:code3/utils/FeedingDemoScreen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'dart:developer' as dev;
import 'DRUG_MT_U_page.dart';
import 'api.dart';
import 'main2_U.dart';
import 'sql.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart' as picker;
import 'package:image_picker/image_picker.dart' as ImagePicker;
import 'package:flutter_typeahead/flutter_typeahead.dart';

class Summary extends StatefulWidget {
  @override
  State<Summary> createState() => SummaryState();
}

class SummaryState extends State<Summary> {

  DateTime datetime = DateTime.now();
  List<View_DAILY> view_DAILYs = [];
  String weekdayText(int weekday) {
    const list = ['週一','週二','週三','週四','週五','週六','週日'];
    return list[weekday - 1];
  }
  List<DAILY_EAT_ITEM> DAILY_EAT_ITEMs = [];
  List<DAILY_MLK_ITEM> DAILY_MLK_ITEMs = [];

  @override
  void initState() {
    // TODO: implement initState

    CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index = 0;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init(); // 這裡才安全呼叫 show()
    });
  }

  @override
  void dispose() {
    super.dispose();
  }



  int daysInMonth(DateTime date) {
    // DateTime(year, month + 1, 0) → 會自動回到前一個月的最後一天
    return DateTime(date.year, date.month + 1, 0).day;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  init()async{
    AppLoadingDialog.show(message: '處理中...');
    for(int i=0;i<cUSTOMERs.length;i++){
      await read_DAILY_MT_TYPE_ITEM_db_sub(DEPM_NO:cUSTOMERs[i].DEPM_NO);
    }
    await read_DAILY_MLK_ITEM_db_sub();
    await read_DAILY_EAT_ITEM_db_sub();
    await read_View_DAILY_for_month_db_sub(datetime: datetime);
    AppLoadingDialog.dismiss();
  }

  Future<void> read_DAILY_MLK_ITEM_db_sub()async{

    DAILY_MLK_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_MLK_ITEM";
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
          DAILY_MLK_ITEM v = DAILY_MLK_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_MLK_ITEMs.add(v);
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_EAT_ITEM_db_sub()async{

    DAILY_EAT_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_EAT_ITEM";
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
          DAILY_EAT_ITEM v = DAILY_EAT_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_EAT_ITEMs.add(v);
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_MT_TYPE_ITEM_db_sub({String DEPM_NO=''})async{

    String comm = "SELECT * FROM DAILY_MT_TYPE_ITEM WHERE DEPM_NO = '${DEPM_NO}'";
    dev.log("${comm}");
    String result = await sql_command("${comm}");
    dev.log("${jsonDecode(result)}");
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
        List<DAILY_MT_TYPE_ITEM> _DAILY_MT_TYPE_ITEMs=[];
        for(int i=0;i<data_list.length;i++){
          DAILY_MT_TYPE_ITEM v = DAILY_MT_TYPE_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}".contains("null")?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}".contains("null")?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          v.VISABLE = "${data_list[i]["VISABLE"]}"=="null"?true:("${data_list[i]["VISABLE"]}".contains("0")||"${data_list[i]["VISABLE"]}".contains("false"))?false:true;

          if(v.VISABLE==true){
            if(v.ITEM_NO=="ACT"){
              v.color = Colors.cyan;
              v.svg_icon = Transform.scale(
                  scale: 1.1, // 放大 1.5 倍
                  child: SvgPicture.asset("assets/images/Icon material-sports-handball.svg",color: v.color,));
              _DAILY_MT_TYPE_ITEMs.add(v);
            }
            else if(v.ITEM_NO=="MLK"){
              v.color = Colors.blueAccent;
              v.svg_icon = SvgPicture.asset("assets/images/组 29134.svg",color: v.color,);
              _DAILY_MT_TYPE_ITEMs.add(v);
            }
            else if(v.ITEM_NO=="POP"){
              v.color = Colors.redAccent;
              v.svg_icon = Transform.scale(
                  scale: 1.5, // 放大 1.5 倍
                  child: SvgPicture.asset("assets/images/Icon fa-solid-poop.svg",color: v.color));
              _DAILY_MT_TYPE_ITEMs.add(v);
            }
            else if(v.ITEM_NO=="CLN"){
              v.color = Colors.pinkAccent;
              v.svg_icon = Transform.scale(
                  scale: 1.5, // 放大 1.5 倍
                  child: SvgPicture.asset("assets/images/Icon core-shower.svg",color: v.color,));
              _DAILY_MT_TYPE_ITEMs.add(v);
            }
            else if(v.ITEM_NO=="CLS"){
              v.color = Colors.green;
              v.svg_icon = Transform.scale(
                  scale: 1.5, // 放大 1.5 倍
                  child: SvgPicture.asset("assets/images/Icon ion-shirt-sharp.svg",color: v.color));
              _DAILY_MT_TYPE_ITEMs.add(v);
            }
            else if(v.ITEM_NO=="EAT"){
              v.color = Colors.orange;
              v.svg_icon = Transform.scale(
                  scale: 1.2, // 放大 1.5 倍
                  child: SvgPicture.asset("assets/images/Icon material-food-bank.svg",color: v.color,));
              _DAILY_MT_TYPE_ITEMs.add(v);
            }
            else if(v.ITEM_NO=="DRY"){
              v.color = Colors.lightGreen;
              v.svg_icon = Transform.scale(
                  scale: 1.5, // 放大 1.5 倍
                  child: SvgPicture.asset("assets/images/Icon fa-solid-file-signature.svg",color: v.color,));
              _DAILY_MT_TYPE_ITEMs.add(v);
            }
            else if(v.ITEM_NO=="TMP"){
              v.color = Colors.deepPurpleAccent;
              v.svg_icon = Transform.scale(
                  scale: 1.3, // 放大 1.5 倍
                  child: SvgPicture.asset("assets/images/Icon fa-solid-temperature-full.svg",color: v.color,));
              _DAILY_MT_TYPE_ITEMs.add(v);
            }
            else if(v.ITEM_NO=="SLP"){
              v.color = Colors.lightBlueAccent;
              v.svg_icon = Transform.scale(
                  scale: 0.9, // 放大 1.5 倍
                  child: SvgPicture.asset("assets/images/组 29166.svg",color: v.color,));
              _DAILY_MT_TYPE_ITEMs.add(v);
            }
            else if(v.ITEM_NO=="RQD"){
              v.color = Colors.purpleAccent;
              v.svg_icon = Transform.scale(
                  scale: 1.3, // 放大 1.5 倍
                  child: SvgPicture.asset("assets/images/Icon fa-solid-basket-shopping.svg",color: v.color,));
              _DAILY_MT_TYPE_ITEMs.add(v);
            }
            else if(v.ITEM_NO=="CND"){
              v.color = Colors.amber;
              v.svg_icon = Transform.scale(
                  scale: 1.6, // 放大 1.5 倍
                  child: SvgPicture.asset("assets/images/Icon ion-body-sharp.svg",color: v.color,));
              _DAILY_MT_TYPE_ITEMs.add(v);
            }
            else if(v.ITEM_NO=="NOT"){
              v.color = Colors.pink;
              v.svg_icon = SvgPicture.asset("assets/images/Icon material-notifications-none-4.svg",color: v.color,);
              _DAILY_MT_TYPE_ITEMs.add(v);
            }
          }

        }


        dev.log('_DAILY_MT_TYPE_ITEMs.length:${_DAILY_MT_TYPE_ITEMs.length}');

        for(int i=0;i<cUSTOMERs.length;i++){
          if(cUSTOMERs[i].DEPM_NO==DEPM_NO){
            cUSTOMERs[i].DAILY_MT_TYPE_ITEMs = _DAILY_MT_TYPE_ITEMs;
          }
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
  View_DAILY 生活概況時序查詢表(範例)
   */
  Future<void> read_View_DAILY_for_month_db_sub({DateTime? datetime,int timeout=15})async{

    //view_DAILYs.clear();
    List<String> CS_NOs = [];
    for(int i=0;i<cUSTOMERs.length;i++){
      CS_NOs.add(cUSTOMERs[i].CS_NO);
    }
    String CS_NO_json = jsonEncode(CS_NOs.toList());
    CS_NO_json = CS_NO_json.replaceAll("[", "(");
    CS_NO_json = CS_NO_json.replaceAll("]", ")");
    CS_NO_json = CS_NO_json.replaceAll("\"", "'");

    dev.log("CS_NO_json:${CS_NO_json}");
    String YEAR=  datetime!.year.toString();
    String MONTH=  datetime.month.toString();

    setState(() {

    });
    String result = await sql_command("SELECT * FROM DAILY_MT WHERE (CS_NO in ${CS_NO_json}) AND YEAR(DATE) = ${YEAR} AND MONTH(DATE) = ${MONTH}",timeout:timeout);
    dev.log("SELECT * FROM DAILY_MT(result):${result}");
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
      List<View_DAILY> _view_DAILYs=[];
      for(int i=0;i<data_list.length;i++){
        View_DAILY v = View_DAILY();
        v.TYPE = "${data_list[i]["TYPE"]}".contains("null")?"":"${data_list[i]["TYPE"]}".replaceAll(" ", "");
        v.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}".replaceAll(" ", "");
        v.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}".replaceAll(" ", "");
        v.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}".replaceAll(" ", "");
        v.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}".replaceAll(" ", "");
        v.DATE = "${data_list[i]["DATE"]}".contains("null")?"":"${data_list[i]["DATE"]}".replaceAll(" ", "");
        v.TIME = "${data_list[i]["TIME"]}".contains("null")?"":"${data_list[i]["TIME"]}".replaceAll(" ", "");
        v.MARK = "${data_list[i]["MARK"]}".contains("null")?"":"${data_list[i]["MARK"]}";
        _view_DAILYs.add(v);
      }
      view_DAILYs = _view_DAILYs;
      setState(() {

      });

    }
    catch(e){
      dev.log("err:${e}");
    }

  }


  @override
  Widget build(BuildContext context) {

    return Container(width: ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,child:Column(children: [

      Row(children: [
        Expanded(child:
        GestureDetector(
            onTap: ()async{

              showMonthPicker(
                context: context,
                //locale: const Locale('zh'),
                initialDate: datetime,
                firstDate:DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
                monthPickerDialogSettings: const MonthPickerDialogSettings(
                  headerSettings: PickerHeaderSettings(
                      headerBackgroundColor:Color(0xff004ea2)
                  ),
                ),
              ).then((date) async{
                if (date != null) {
                  datetime = date;
                  AppLoadingDialog.show(message: '處理中...');
                  await read_View_DAILY_for_month_db_sub(datetime:datetime);
                  AppLoadingDialog.dismiss();
                }
              });


            },
            child: Column(children: [
              Container(
                  width: ScreenUtil().screenWidth,
                  height: 50.h,
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20.w),
                      border: Border.all(
                        width: 1,
                        color: Color(0xff555555),
                      )),
                  child:Row(children: [
                    Container(width: 5.w,),
                    Icon(Icons.calendar_today,color: Color(0xff555555),size: (iPad)?24.sp:28.sp,),
                    Container(width: 5.w,),
                    Text('${DateFormat('yyyy-MM').format(datetime)}',style: TextStyle(
                        fontFamily: "GenJyuuGothic",
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        color: Color(0xff292929))),
                    Expanded(child: Container()),
                    Icon(Icons.keyboard_arrow_down,color: Color(0xff555555),size: 24.sp,),
                    Container(width: 5.w,),

                  ],)
              ),

            ],))),
        Container(width: 10.w,),
        Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.w),
                border: Border.all(
                  width: 1,
                  color: Color(0xff555555),
                )),
            width: 130.w,
            height: 48.h,
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
                      fontSize: (iPad)?16.sp:18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff555555),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ))
                    .toList(),
                value: CUSTOMER_selectedValue,
                onChanged: (value) {

                  setState(() {
                    CUSTOMER_selectedValue = value!;
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
      ],),
      Container(height: 8.h,),

      CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs.isEmpty?
      Container()
      :
      Expanded(child:
      Column(children: [
        // ⭐ 上方水平滑動 Tab
        SizedBox(
          height: 50.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs.length,
            itemBuilder: (context, index) {
              bool isSelected = index == CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index = index;
                  });
                  dev.log('${CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index].ITEM_NO}');

                },
                child: Container(
                  width: 50.w,
                  padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.w),
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                      color: isSelected ? const Color(0xffFFF2CE) : Colors.white,
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10))
                  ),
                  child: Center(
                      child: CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[index].svg_icon
                  ),
                ),
              );
            },
          ),
        ),
        Container(color: const Color(0xffFFF2CE),height: 8.h,),
        (CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index].ITEM_NO=='MLK')?
        Expanded(
            child: Container(
              // 設置一個明顯的背景色來測試透明度
              color: const Color(0xffFFF2CE),
              child:FeedingChart(
                  selectedMonth: datetime,
                  view_DAILYs:view_DAILYs,
                  daily_MLK_ITEMs:DAILY_MLK_ITEMs
              )
            ))
            :
        (CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index].ITEM_NO=='EAT')?
        Expanded(
          child: Container(
        color: const Color(0xffFFF2CE), // <--- 設置為紅色
        child:MonthTableWidget(
            columns: DAILY_EAT_ITEMs,
            selectedMonth: datetime,
            view_DAILYs:view_DAILYs
          ),
        ))
            :
        Expanded(child:Container(
            color: const Color(0xffFFF2CE),
            width: ScreenUtil().screenWidth,height: ScreenUtil().screenHeight,
            child:ListView.builder(
                itemCount: daysInMonth(datetime),
                padding: EdgeInsets.only(left: 8.w,right: 8.w),
                itemBuilder: (c,index){
                  final day = index + 1;

                  // 本日日期物件
                  final date = DateTime(datetime.year, datetime.month, day);

                  // 月/日（兩位數補0）
                  final md = '${date.month.toString().padLeft(2, '0')}/${day.toString().padLeft(2, '0')}';

                  // 星期（中文）
                  final week = weekdayText(date.weekday);


                  List<String> MARK = [];
                  List<String> time = [];
                  for(int i=0;i<view_DAILYs.length;i++){

                    if(view_DAILYs[i].TYPE==CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index].ITEM_NO &&
                        isSameDay(DateTime.tryParse(view_DAILYs[i].DATE)!,date) &&
                        view_DAILYs[i].CS_NO==CUSTOMER_selectedValue.CS_NO
                    ){


                      // 1. 預先整理出當月所有有 POV 紀錄的日期（YYYY-MM-DD）
                      final Set<String> povDates = {};
                      for (var item in view_DAILYs) {
                        if (item.TYPE.trim() == 'POV' && item.CS_NO==CUSTOMER_selectedValue.CS_NO) {
                          String povDateStr = item.DATE.split('T').first;
                          povDates.add(povDateStr);
                        }
                      }
                      String rawDateStr = view_DAILYs[i].DATE.split('T').first; // e.g., "2026-05-20"

                      //當天有POV才顯示每日活動
                      bool is_pov = false;
                      if (povDates.contains(rawDateStr)) {
                        dev.log("當天有POV才顯示每日活動");
                        is_pov = true;
                      }

                      // 取得今天的開始時間（不含時間）
                      final now = DateTime.now();
                      final todayStart = DateTime(now.year, now.month, now.day);
                      final modifiedDate = DateTime.parse(view_DAILYs[i].DATE);
                      if (modifiedDate.isBefore(todayStart)) {
                        dev.log("該檔案的修改日期是今天以前-2");
                        is_pov = true;
                      } else {
                        //dev.log("該檔案的修改日期是今天或之後");
                      }


                      //目前的日期時間 > 日記的日期 + 日記可讀取時間
                      DateTime now2 = DateTime.parse(view_DAILYs[i].DATE);
                      DateTime target = DateTime(
                        now2.year,
                        now2.month,
                        now2.day,
                        CUSTOMER_selectedValue.DAILY_READ_TIME!.hour,
                        CUSTOMER_selectedValue.DAILY_READ_TIME!.minute,
                        CUSTOMER_selectedValue.DAILY_READ_TIME!.second,
                      );
                      dev.log('now:${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}');
                      dev.log('target:${DateFormat('yyyy-MM-dd HH:mm:ss').format(target)}');
                      if (now.isAfter(target)) {
                        dev.log("已超過時間,日記可以給家長觀看-2");
                        is_pov = true;
                      } else {
                        dev.log("尚未到時間,日記不能給家長觀看");
                      }

                      //is_pov=true;
                      if(is_pov==true){
                        MARK.add(view_DAILYs[i].MARK);
                        final original = view_DAILYs[i].TIME;
                        final parts = original.split(':'); // ["17", "01", "46.3755859"]
                        final hm = "${parts[0]}:${parts[1]}"; // "17:01"
                        time.add(hm);
                        dev.log('time:${time}');
                      }


                    }


                  }


                  return (CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index].ITEM_NO=='NOT' ||
                      CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index].ITEM_NO=='CLN' ||
                      CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index].ITEM_NO=='CLS' ||
                      CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index].ITEM_NO=='DRY' ||
                      CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index].ITEM_NO=='RQD' ||
                      CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index].ITEM_NO=='SLP' ||
                      CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index].ITEM_NO=='ACT')?
                      Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Column(children: [
                          Text(md,textScaler: const TextScaler.linear(1), style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700,fontSize: 20.sp)),
                          Text('($week)',textScaler: const TextScaler.linear(1), style: TextStyle(fontSize: 16.sp, color: Colors.black)),
                        ],),
                        SizedBox(width: 10.w),
                        Expanded(child: Column(children: MARK.asMap().entries.map((item){
                          return Row(children: [
                            Container(width: 3.w,height: 3.w,color: Colors.black,),
                            Container(width: 5.w,),
                            Expanded(child:
                            Text('${item.value}',textScaler: const TextScaler.linear(1),maxLines: 1,overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 14.sp))),
                          ],);
                        }).toList())),
                      ],),
                      SizedBox(height: 10.h),
                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.black,),
                      SizedBox(height: 10.h),
                    ],
                  )
                      :
                  (CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index].ITEM_NO=='POP' ||
                      CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index].ITEM_NO=='CND' ||
                      CUSTOMER_selectedValue.DAILY_MT_TYPE_ITEMs[CUSTOMER_selectedValue.sel_DAILY_MT_TYPE_ITEMs_index].ITEM_NO=='TMP'
                  )?
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Column(children: [
                              Text(md,textScaler: const TextScaler.linear(1), style: TextStyle(color: Colors.black,fontWeight: FontWeight.w700,fontSize: 20.sp)),
                              Text('($week)',textScaler: const TextScaler.linear(1), style: TextStyle(fontSize: 16.sp, color: Colors.black)),
                            ],),
                            SizedBox(width: 10.w),
                            Expanded(child: Column(children: MARK.asMap().entries.map((item){
                              return Row(children: [
                                Container(width: 3.w,height: 3.w,color: Colors.red,),
                                Container(width: 5.w,),
                                Text('${time[item.key]}:',textScaler: const TextScaler.linear(1),maxLines: 1,overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.red,fontWeight: FontWeight.w500,fontSize: 14.sp)),
                                Expanded(child:
                                Text('${item.value}',textScaler: const TextScaler.linear(1),maxLines: 1,overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 14.sp))),
                              ],);
                            }).toList())),
                          ],),
                          SizedBox(height: 10.h),
                          Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.black,),
                          SizedBox(height: 10.h),
                        ],
                      )
                      :
                      Container();
                }))),
      ],))


    ],));
  }
}
