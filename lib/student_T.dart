import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:code3/DRUG_MT_T_page.dart';
import 'package:code3/GROWING_T_page.dart';
import 'package:code3/add_DAILY_ACT_page.dart';
import 'package:code3/add_DAILY_CLN_page.dart';
import 'package:code3/add_DAILY_CLS_page.dart';
import 'package:code3/add_DAILY_CND_page.dart';
import 'package:code3/add_DAILY_DRY_page.dart';
import 'package:code3/add_DAILY_EAT_page.dart';
import 'package:code3/add_DAILY_MLK_page.dart';
import 'package:code3/add_DAILY_NOT_page.dart';
import 'package:code3/add_DAILY_POP_page.dart';
import 'package:code3/add_DAILY_RQD_page.dart';
import 'package:code3/add_DAILY_SLP_page.dart';
import 'package:code3/add_DAILY_TMP_page.dart';
import 'package:code3/add_ROLLCALL_page.dart';
import 'package:code3/edit_DAILY_ACT_page.dart';
import 'package:code3/edit_DAILY_CLN_page.dart';
import 'package:code3/edit_DAILY_CLS_page.dart';
import 'package:code3/edit_DAILY_CND_page.dart';
import 'package:code3/edit_DAILY_DRY_page.dart';
import 'package:code3/edit_DAILY_EAT_page.dart';
import 'package:code3/edit_DAILY_MLK_page.dart';
import 'package:code3/edit_DAILY_NOT_page.dart';
import 'package:code3/edit_DAILY_POP_page.dart';
import 'package:code3/edit_DAILY_SLP_page.dart';
import 'package:code3/edit_DAILY_TMP_page.dart';
import 'package:code3/signature2.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:floating_draggable_widget/floating_draggable_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'package:star_menu/star_menu.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:developer' as dev;
import 'DAILY_PRS_T_page.dart';
import 'DAILY_PRS_page.dart';
import 'api.dart';
import 'chat.dart';
import 'edit_DAILY_RQD_page.dart';
import 'edit_ROLLCALL_page.dart';
import 'fcm_notifity.dart';
import 'main2_T.dart';
import 'main2_U.dart';
import 'see_DAILY_RQD_page.dart';
import 'sql.dart';
import 'utils/CustomAppBar.dart';



Function? Student_T_page_fun;
List<DRUG_MT> dRUG_MTs = [];//用藥委託主表單(個人)
DRUG_MT dRUG_MT = DRUG_MT();
// 定義 GlobalKey
final GlobalKey<Student_T_pageState> Student_T_page_WidgetKey = GlobalKey<Student_T_pageState>();
bool is_Student_T_page=false;
class Student_T_page extends StatefulWidget {

  DateTime dateTime = DateTime.now();
  Student_T_page({DateTime? dateTime,Key? key}):super(key: key){
    this.dateTime = dateTime!;
  }

  @override
  State<Student_T_page> createState() => Student_T_pageState(dateTime:this.dateTime);
}

class Student_T_pageState extends State<Student_T_page> {

  List<DAILY_PRS> DAILY_PRSs=[];
  List<View_DAILY> view_DAILYs = [];

  String birthday = "";
  DateTime dateTime = DateTime.now();
  Student_T_pageState({DateTime? dateTime}){
    this.dateTime = dateTime!;
  }

  var showModalBottomSheet_GROWING_STANDARD_context;
  var showModalBottomSheet_GROWING_STANDARD_setState;
  TooltipBehavior? _tooltipBehavior;
  late PopupMenu menu;
  GlobalKey btnKey = GlobalKey();
  final centerStarMenuController = StarMenuController();

  bool is_show = false;
  final containerKey = GlobalKey();
  List<ROLLCALL> ROLLCALL_list = [];
  List<Entrusted_pick_and_drop> entrusted_pick_and_drop_list = [];
  List<EXCUSED> EXCUSED_list = [];

  OverlayEntry? _overlayEntry;
  bool isLoading = true; // 是否顯示轉圈圈
  //List<DAILY_MT_TYPE_ITEM> DAILY_MT_TYPE_ITEMs = [];

  @override
  void initState() {
    // TODO: implement initState

    is_Student_T_page=true;

    _tooltipBehavior = TooltipBehavior(enable: true);

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    Student_T_page_fun = ({String action=""})async{

      if(action=="前往家長已回簽通知單" || action=="新增聯絡簿送出成功" || action=="新增托嬰活動成功" || action=="新增[托嬰]飲食(餵奶)成功" || action=="新增[托嬰]便便 成功" || action=="新增[托嬰/幼兒]洗澡成功" || action=="新增更換衣物成功" || action=="新增[托嬰/幼兒] 飲食(用餐) 副表 成功"|| action=="新增[托嬰/幼兒]日記 副表成功"|| action=="新增[托嬰/幼兒]體溫成功"|| action=="新增[托嬰/幼兒]睡覺成功"|| action=="新增須備物品成功"|| action=="新增[托嬰/幼兒]健康 生理狀況成功"|| action=="新增[托嬰/幼兒]  通知單(備註) 副表成功"){
        //生活概況時序查詢表(範例)
        setState(() => isLoading = true);
        await read_View_DAILY_db_sub(
            datetime: dateTime,
            CS_NO: "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",
            timeout:30
        );
        setState(() => isLoading = false);
      }
      else if(action=="到/離校"){
        //檢查有無點名紀錄
        setState(() => isLoading = true);
        await ROLLCALL_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
        setState(() => isLoading = false);
      }
    };



    init();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    is_Student_T_page=false;
    super.dispose();
  }

  void updateData({String newData=""}) async{

    if(newData=="更新用藥委託數據"){
      //檢查有無用藥委託
      await read_DRUG_MT_db_sub(datetime: dateTime,CS_NO: "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}");//先確定圖片流水號
    }
    else if(newData=="更新接送委託數據"){
      //檢查有無委託接送
      await ENTRUSTED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
    }
    else if(newData=="更新請假委託數據"){
      //檢查有無請假
      await EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
    }
    else if(newData=="更新接送委託數據"){
      //檢查有無委託接送
      await ENTRUSTED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
    }
    else if(newData=="更新聯絡簿是否已回簽"){
      //檢查聯絡簿
      await read_for_DAILY_PRS_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
    }


  }

  init()async{

    dRUG_MTs = [];//用藥委託主表單(個人)
    ROLLCALL_list.clear();
    entrusted_pick_and_drop_list.clear();
    EXCUSED_list.clear();
    DAILY_PRSs.clear();
    view_DAILYs.clear();

    setState(() => isLoading = true);

    //算出年齡
    if (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.BIRTHDAY.isNotEmpty) {
      final birthStr = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.BIRTHDAY;
      log("BIRTHDAY:$birthStr");

      DateTime BIRTHDAY = DateTime.parse(birthStr);
      DateTime now = DateTime.now();

      int year = now.year - BIRTHDAY.year;
      int month = now.month - BIRTHDAY.month;
      int day = now.day - BIRTHDAY.day;

      if (day < 0) {
        month -= 1;
        // 取得上個月的最後一天來補天數
        DateTime lastMonth = DateTime(now.year, now.month, 0);
        day += lastMonth.day;
      }
      if (month < 0) {
        year -= 1;
        month += 12;
      }

      log("year:$year, month:$month, day:$day");
      birthday = "(${year}歲${month}月${day}天)";
    }


    //DAILY_ACT_ITEM
    await read_DAILY_ACT_ITEM_db_sub();

    await read_DAILY_MLK_ITEM_db_sub();

    await read_DAILY_POP_HARD_ITEM_db_sub();

    await read_DAILY_POP_COLOR_ITEM_db_sub();

    await read_DAILY_POP_QUANTITY_ITEM_db_sub();

    await read_DAILY_EAT_ITEM_db_sub();

    await read_DAILY_EAT_NOTE_ITEM_db_sub();

    await read_DAILY_TMP_KIND_ITEM_db_sub();

    await read_DAILY_SLP_STATUS_ITEM_db_sub();

    await read_DAILY_RQD_ITEM_db_sub();

    await read_DAILY_CND_NASAL_STATUS_ITEM_db_sub();

    await read_DAILY_CND_RUNNY_COLOR_ITEM_db_sub();

    await read_DAILY_CND_RUNNY_TYPE_ITEM_db_sub();

    await read_DAILY_CND_RUNNY_QUANTITY_ITEM_db_sub();

    await read_DAILY_CND_COUGH_LEVEL_ITEM_db_sub();

    await read_DAILY_CND_COUGH_TIME_ITEM_db_sub();

    await read_DAILY_CND_HFMD_TYPE_ITEM_db_sub();

    await read_DAILY_MT_TYPE_ITEM_db_sub();

    //檢查有無用藥委託
    await read_DRUG_MT_db_sub(datetime: dateTime,CS_NO: "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}");//先確定圖片流水號

    //檢查有無點名紀錄
    await ROLLCALL_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

    //檢查有無委託接送
    await ENTRUSTED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

    //檢查有無請假
    await EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

    //檢查聯絡簿
    await read_for_DAILY_PRS_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

    //生活概況時序查詢表(範例)
    await read_View_DAILY_db_sub(
        datetime: dateTime,
        CS_NO: "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",
        timeout:30
    );

    setState(() => isLoading = false); // 全部 API 呼完


  }


  init2()async{

    dRUG_MTs = [];//用藥委託主表單(個人)
    ROLLCALL_list.clear();
    entrusted_pick_and_drop_list.clear();
    EXCUSED_list.clear();
    DAILY_PRSs.clear();
    view_DAILYs.clear();

    setState(() => isLoading = true);

    //算出年齡
    if (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.BIRTHDAY.isNotEmpty) {
      final birthStr = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.BIRTHDAY;
      log("BIRTHDAY:$birthStr");

      DateTime BIRTHDAY = DateTime.parse(birthStr);
      DateTime now = DateTime.now();

      int year = now.year - BIRTHDAY.year;
      int month = now.month - BIRTHDAY.month;
      int day = now.day - BIRTHDAY.day;

      if (day < 0) {
        month -= 1;
        // 取得上個月的最後一天來補天數
        DateTime lastMonth = DateTime(now.year, now.month, 0);
        day += lastMonth.day;
      }
      if (month < 0) {
        year -= 1;
        month += 12;
      }

      log("year:$year, month:$month, day:$day");
      birthday = "(${year}歲${month}月${day}天)";
    }


    //檢查有無用藥委託
    await read_DRUG_MT_db_sub(datetime: dateTime,CS_NO: "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}");//先確定圖片流水號

    //檢查有無點名紀錄
    await ROLLCALL_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

    //檢查有無委託接送
    await ENTRUSTED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

    //檢查有無請假
    await EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

    //檢查聯絡簿
    await read_for_DAILY_PRS_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

    //生活概況時序查詢表(範例)
    await read_View_DAILY_db_sub(
        datetime: dateTime,
        CS_NO: "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",
        timeout:30
    );

    setState(() => isLoading = false); // 全部 API 呼完


  }

  Future<void> EXCUSED_db_sub({String datetime=""})async{
    //SmartDialog.showLoading(msg: "處理中...");
    //await Future.delayed(const Duration(milliseconds: 500), () {});
    EXCUSED_list.clear();
    setState(() {

    });
    String result = await sql_command("SELECT * FROM EXCUSED WHERE (DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59') AND CS_NO='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}'");
    //SmartDialog.dismiss();
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
      List<EXCUSED> _EXCUSED_list=[];
      for(int i=0;i<data_list.length;i++){
        EXCUSED b = EXCUSED();
        b.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
        b.DATE = "${data_list[i]["DATE"]}".contains("null")?"":"${data_list[i]["DATE"]}";
        b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
        b.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}";
        b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}";
        b.NOTE = "${data_list[i]["NOTE"]}".contains("null")?"":"${data_list[i]["NOTE"]}";
        b.HOURS_NO = "${data_list[i]["HOURS_NO"]}".contains("null")?"":"${data_list[i]["HOURS_NO"]}";
        b.REASON_NO = "${data_list[i]["REASON_NO"]}".contains("null")?"":"${data_list[i]["REASON_NO"]}";
        b.CFM_NO = "${data_list[i]["CFM_NO"]}".contains("null")?"":"${data_list[i]["CFM_NO"]}";
        b.ADD_DATE = "${data_list[i]["ADD_DATE"]}".contains("null")?"":"${data_list[i]["ADD_DATE"]}";
        b.CFM_USER = "${data_list[i]["CFM_USER"]}".contains("null")?"":"${data_list[i]["CFM_USER"]}";
        b.CFM_DT = "${data_list[i]["CFM_DT"]}".contains("null")?"":"${data_list[i]["CFM_DT"]}";
        b.DEL = "${data_list[i]["DEL"]}".contains("null")?"":"${data_list[i]["DEL"]}";
        String SING_LINK = "${data_list[i]["SING_LINK"]}".replaceAll("~/", "");
        b.SING_LINK = "${IMAGE_IP}/${SING_LINK}";

        b.DATE = DateFormat('yyyy-MM-dd').format(DateTime.parse(b.DATE));
        List<String> list = b.DATE.split("-");
        b.DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[DateTime(int.parse(list[0]),int.parse(list[1]),int.parse(list[2])).weekday-1]})";
        b.CFM_ITEM_selectedValue = CFM_ITEM_list.firstWhere(
              (element) => element.CFM_NO == b.CFM_NO,
          orElse: () => CFM_ITEM(),
        );
        if(b.DEL.isEmpty) {
          _EXCUSED_list.add(b);
        }
      }
      EXCUSED_list=_EXCUSED_list;

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //SmartDialog.showToast("網路異常");
    }
  }

  /*
  [托嬰/幼兒] 點名 ROLLCALL
   */
  Future<void> ROLLCALL_db_sub({String datetime=""})async{
    //SmartDialog.showLoading(msg: "處理中...");
    //await Future.delayed(const Duration(milliseconds: 500), () {});
    ROLLCALL_list.clear();
    setState(() {

    });
    String result = await sql_command("SELECT * FROM ROLLCALL WHERE (DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59') AND CS_NO='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}'");
    //SmartDialog.dismiss();
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
      List<ROLLCALL> _ROLLCALL_list=[];
      for(int i=0;i<data_list.length;i++){
        ROLLCALL b = ROLLCALL();
        b.NO = "${data_list[i]["NO"]}";
        b.DATE = "${data_list[i]["DATE"]}";
        b.TIME = "${data_list[i]["TIME"]}";
        b.DEPM_NO = "${data_list[i]["DEPM_NO"]}";
        b.CLASS_NO = "${data_list[i]["CLASS_NO"]}";
        b.CS_NO = "${data_list[i]["CS_NO"]}";
        b.STATUS = "${data_list[i]["STATUS"]}";
        b.ADD_DATE = "${data_list[i]["ADD_DATE"]}";

        b.DATE = DateFormat('yyyy-MM-dd').format(DateTime.parse(b.DATE));
        List<String> list = b.DATE.split("-");

        List<String> t1 = b.TIME.split(":");
        b.timeOfDay = TimeOfDay(hour: int.parse(t1[0]),minute: int.parse(t1[1]));

        b.DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[DateTime(int.parse(list[0]),int.parse(list[1]),int.parse(list[2])).weekday-1]})";
        b.DateStr1 ='${"${b.timeOfDay.period==DayPeriod.am?"上午":"下午"}${b.timeOfDay.hourOfPeriod}:${b.timeOfDay.minute.toString().padLeft(2,"0")}"} ${ROLLCALL_ITEMS_list.firstWhere((e) => e.ITEM_NO==b.STATUS).ITEM_NM}';
        _ROLLCALL_list.add(b);
      }
      ROLLCALL_list = _ROLLCALL_list;

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //SmartDialog.showToast("網路異常");
    }
  }


  Future<void> ENTRUSTED_db_sub({String datetime=""})async{
    //SmartDialog.showLoading(msg: "處理中...");
    //await Future.delayed(const Duration(milliseconds: 500), () {});
    entrusted_pick_and_drop_list.clear();
    setState(() {

    });
    String result = await sql_command("SELECT * FROM ENTRUSTED WHERE (DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59') AND CS_NO='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}'");
    //SmartDialog.dismiss();
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
      List<Entrusted_pick_and_drop>  _entrusted_pick_and_drop_list=[];
      for(int i=0;i<data_list.length;i++){
        Entrusted_pick_and_drop b = Entrusted_pick_and_drop();
        b.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
        b.DATE = "${data_list[i]["DATE"]}".contains("null")?"":"${data_list[i]["DATE"]}";
        b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
        b.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}";
        b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}";
        b.NOTE = "${data_list[i]["NOTE"]}".contains("null")?"":"${data_list[i]["NOTE"]}";
        b.AGENT_NM = "${data_list[i]["AGENT_NM"]}".contains("null")?"":"${data_list[i]["AGENT_NM"]}";
        b.AGENT_PHONE = "${data_list[i]["AGENT_PHONE"]}".contains("null")?"":"${data_list[i]["AGENT_PHONE"]}";
        b.RELATION = "${data_list[i]["RELATION"]}".contains("null")?"":"${data_list[i]["RELATION"]}";
        b.ADD_DATE = "${data_list[i]["ADD_DATE"]}".contains("null")?"":"${data_list[i]["ADD_DATE"]}";
        String SIGN_LINK = "${data_list[i]["SIGN_LINK"]}".replaceAll("~/", "");
        b.SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK}";
        b.CFM_USER = "${data_list[i]["CFM_USER"]}".contains("null")?"":"${data_list[i]["CFM_USER"]}";
        b.CFM_DT = "${data_list[i]["CFM_DT"]}".contains("null")?"":"${data_list[i]["CFM_DT"]}";
        b.CFM_DT = "${data_list[i]["CFM_DT"]}".contains("null")?"":"${data_list[i]["CFM_DT"]}";
        b.DEL = "${data_list[i]["DEL"]}".contains("null")?"":"${data_list[i]["DEL"]}";

        b.DATE = DateFormat('yyyy-MM-dd').format(DateTime.parse(b.DATE));
        List<String> list = b.DATE.split("-");
        b.DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[DateTime(int.parse(list[0]),int.parse(list[1]),int.parse(list[2])).weekday-1]})";
        if(b.CFM_DT.isNotEmpty){
          DateTime dateTime = DateTime.parse(b.CFM_DT);
          b.CFM_DT_str = "${DateFormat("yyyy年MM月dd日 HH:mm:ss").format(dateTime)} (${WEEK_DAY[dateTime.weekday-1]})";
        }
        if(b.DEL.isEmpty){
          _entrusted_pick_and_drop_list.add(b);
        }

      }
      entrusted_pick_and_drop_list = _entrusted_pick_and_drop_list;
      entrusted_pick_and_drop_list.sort((a,b) => b.DATE.compareTo(a.DATE));

      setState(() {

      });

      /*
        明細
         */
      for(int i=0;i<entrusted_pick_and_drop_list.length;i++){
        await read_for_ENTRUSTED_DL_db_sub(NO:entrusted_pick_and_drop_list[i].NO,index: i);
      }

    }
    catch(e){
      dev.log("${e}");
      //SmartDialog.showToast("網路異常");
    }
  }


  /*
  [托嬰/幼兒] 預約接送明細 ENTRUSTED_DL
   */
  Future<void> read_for_ENTRUSTED_DL_db_sub({String NO="",int index=0})async{
    //await EasyLoading.show(status: "處理中...");

    String result = await sql_command("SELECT * FROM ENTRUSTED_DL WHERE NO='${NO}'");

    SmartDialog.dismiss();
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
          ENTRUSTED_DL b = ENTRUSTED_DL();
          b.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
          b.SR = "${data_list[i]["SR"]}".contains("null")?"":"${data_list[i]["SR"]}";
          b.TYPE_NO = "${data_list[i]["TYPE_NO"]}".contains("null")?"":"${data_list[i]["TYPE_NO"]}";
          b.TIME = "${data_list[i]["TIME"]}".contains("null")?"":"${data_list[i]["TIME"]}";
          entrusted_pick_and_drop_list[index].eNTRUSTED_DL_list.add(b);
        }

        setState(() {

        });




      }



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }


  Future<void> read_DAILY_CND_HFMD_TYPE_ITEM_db_sub()async{

    if(DAILY_CND_HFMD_TYPE_ITEMs.isNotEmpty){
      return;
    }

    DAILY_CND_HFMD_TYPE_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_CND_HFMD_TYPE_ITEM";
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
          DAILY_CND_HFMD_TYPE_ITEM v = DAILY_CND_HFMD_TYPE_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}".contains("null")?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}".contains("null")?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_CND_HFMD_TYPE_ITEMs.add(v);
          sel_DAILY_CND_HFMD_TYPE_ITEM = DAILY_CND_HFMD_TYPE_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_CND_COUGH_TIME_ITEM_db_sub()async{

    if(DAILY_CND_COUGH_TIME_ITEMs.isNotEmpty){
      return;
    }

    DAILY_CND_COUGH_TIME_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_CND_COUGH_TIME_ITEM";
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
          DAILY_CND_COUGH_TIME_ITEM v = DAILY_CND_COUGH_TIME_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}".contains("null")?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}".contains("null")?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_CND_COUGH_TIME_ITEMs.add(v);
          sel_DAILY_CND_COUGH_TIME_ITEM = DAILY_CND_COUGH_TIME_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_CND_COUGH_LEVEL_ITEM_db_sub()async{

    if(DAILY_CND_COUGH_LEVEL_ITEMs.isNotEmpty){
      return;
    }

    DAILY_CND_COUGH_LEVEL_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_CND_COUGH_LEVEL_ITEM";
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
          DAILY_CND_COUGH_LEVEL_ITEM v = DAILY_CND_COUGH_LEVEL_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}".contains("null")?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}".contains("null")?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_CND_COUGH_LEVEL_ITEMs.add(v);
          sel_DAILY_CND_COUGH_LEVEL_ITEM = DAILY_CND_COUGH_LEVEL_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_CND_RUNNY_QUANTITY_ITEM_db_sub()async{

    if(DAILY_CND_RUNNY_QUANTITY_ITEMs.isNotEmpty){
      return;
    }

    DAILY_CND_RUNNY_QUANTITY_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_CND_RUNNY_QUANTITY_ITEM";
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
          DAILY_CND_RUNNY_QUANTITY_ITEM v = DAILY_CND_RUNNY_QUANTITY_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_CND_RUNNY_QUANTITY_ITEMs.add(v);
          sel_DAILY_CND_RUNNY_QUANTITY_ITEM = DAILY_CND_RUNNY_QUANTITY_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_CND_RUNNY_TYPE_ITEM_db_sub()async{

    if(DAILY_CND_RUNNY_TYPE_ITEMs.isNotEmpty){
      return;
    }

    DAILY_CND_RUNNY_TYPE_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_CND_RUNNY_TYPE_ITEM";
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
          DAILY_CND_RUNNY_TYPE_ITEM v = DAILY_CND_RUNNY_TYPE_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_CND_RUNNY_TYPE_ITEMs.add(v);
          sel_DAILY_CND_RUNNY_TYPE_ITEM = DAILY_CND_RUNNY_TYPE_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_CND_RUNNY_COLOR_ITEM_db_sub()async{

    if(DAILY_CND_RUNNY_COLOR_ITEMs.isNotEmpty){
      return;
    }
    DAILY_CND_RUNNY_COLOR_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_CND_RUNNY_COLOR_ITEM";
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
          DAILY_CND_RUNNY_COLOR_ITEM v = DAILY_CND_RUNNY_COLOR_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_CND_RUNNY_COLOR_ITEMs.add(v);
          sel_DAILY_CND_RUNNY_COLOR_ITEM = DAILY_CND_RUNNY_COLOR_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_CND_NASAL_STATUS_ITEM_db_sub()async{
    if(DAILY_CND_NASAL_STATUS_ITEMs.isNotEmpty){
      return;
    }
    DAILY_CND_NASAL_STATUS_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_CND_NASAL_STATUS_ITEM";
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
          DAILY_CND_NASAL_STATUS_ITEM v = DAILY_CND_NASAL_STATUS_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_CND_NASAL_STATUS_ITEMs.add(v);
          sel_DAILY_CND_NASAL_STATUS_ITEM = DAILY_CND_NASAL_STATUS_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_RQD_ITEM_db_sub()async{

    DAILY_RQD_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_RQD_ITEM WHERE DEMP='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}'";
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
          DAILY_RQD_ITEM v = DAILY_RQD_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          v.DEMP = "${data_list[i]["DEMP"]}"=="null"?"":"${data_list[i]["DEMP"]}".replaceAll(" ", "");
          DAILY_RQD_ITEMs.add(v);
          sel_DAILY_RQD_ITEM = DAILY_RQD_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_SLP_STATUS_ITEM_db_sub()async{

    if(DAILY_SLP_STATUS_ITEMs.isNotEmpty){
      return;
    }

    DAILY_SLP_STATUS_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_SLP_STATUS_ITEM";
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
          DAILY_SLP_STATUS_ITEM v = DAILY_SLP_STATUS_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_SLP_STATUS_ITEMs.add(v);
          sel_DAILY_SLP_STATUS_ITEM = DAILY_SLP_STATUS_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_TMP_KIND_ITEM_db_sub()async{

    if(DAILY_TMP_KIND_ITEMs.isNotEmpty){
      return;
    }

    DAILY_TMP_KIND_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_TMP_KIND_ITEM";
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
          DAILY_TMP_KIND_ITEM v = DAILY_TMP_KIND_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_TMP_KIND_ITEMs.add(v);
          sel_DAILY_TMP_KIND_ITEM = DAILY_TMP_KIND_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_EAT_NOTE_ITEM_db_sub()async{

    if(DAILY_EAT_NOTE_ITEMs.isNotEmpty){
      return;
    }

    DAILY_EAT_NOTE_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_EAT_NOTE_ITEM";
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
          DAILY_EAT_NOTE_ITEM v = DAILY_EAT_NOTE_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_EAT_NOTE_ITEMs.add(v);
          sel_DAILY_EAT_NOTE_ITEM = DAILY_EAT_NOTE_ITEMs[0];
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

    if(DAILY_EAT_ITEMs.isNotEmpty){
      return;
    }

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
          sel_DAILY_EAT_ITEM = DAILY_EAT_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_POP_QUANTITY_ITEM_db_sub()async{

    if(DAILY_POP_QUANTITY_ITEMs.isNotEmpty){
      return;
    }

    DAILY_POP_QUANTITY_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_POP_QUANTITY_ITEM";
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
          DAILY_POP_QUANTITY_ITEM v = DAILY_POP_QUANTITY_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_POP_QUANTITY_ITEMs.add(v);
          sel_DAILY_POP_QUANTITY_ITEM = DAILY_POP_QUANTITY_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_POP_COLOR_ITEM_db_sub()async{

    if(DAILY_POP_COLOR_ITEMs.isNotEmpty){
      return;
    }

    DAILY_POP_COLOR_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_POP_COLOR_ITEM";
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
          DAILY_POP_COLOR_ITEM v = DAILY_POP_COLOR_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_POP_COLOR_ITEMs.add(v);
          sel_DAILY_POP_COLOR_ITEM = DAILY_POP_COLOR_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> read_DAILY_POP_HARD_ITEM_db_sub()async{

    if(DAILY_POP_HARD_ITEMs.isNotEmpty){
      return;
    }
    DAILY_POP_HARD_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_POP_HARD_ITEM";
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
          DAILY_POP_HARD_ITEM v = DAILY_POP_HARD_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_POP_HARD_ITEMs.add(v);
          sel_DAILY_POP_HARD_ITEM = DAILY_POP_HARD_ITEMs[0];
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

   */
  Future<void> read_DAILY_MLK_ITEM_db_sub()async{

    if(DAILY_MLK_ITEMs.isNotEmpty){
      return;
    }

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
          sel_DAILY_MLK_ITEM = DAILY_MLK_ITEMs[0];
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
  [托嬰/幼兒]用藥委託主表單(個人) DRUG_MT
   */
  Future<void> read_DRUG_MT_db_sub({DateTime? datetime,String CS_NO=""})async{


    dRUG_MTs = [];//用藥委託主表單(個人)
    setState(() {

    });
    String datetime = "${DateFormat('yyyy-MM-dd').format(dateTime)}";
    String comm = "SELECT * FROM DRUG_MT WHERE CS_NO='${CS_NO}' AND (DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59')";
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
      List<DRUG_MT> _dRUG_MTs=[];
      for(int i=0;i<data_list.length;i++){

        DRUG_MT dRUG_MT = DRUG_MT();
        dRUG_MT.REASON = "${data_list[i]["REASON"]}"=="null"?"":"${data_list[i]["REASON"]}";
        dRUG_MT.DATETIME = "${data_list[i]["DATETIME"]}"=="null"?"":"${data_list[i]["DATETIME"]}";
        dRUG_MT.CLASS_NO = "${data_list[i]["CLASS_NO"]}"=="null"?"":"${data_list[i]["CLASS_NO"]}";
        dRUG_MT.DEPM_NO = "${data_list[i]["DEPM_NO"]}"=="null"?"":"${data_list[i]["DEPM_NO"]}";
        dRUG_MT.AGREE = "${data_list[i]["AGREE"]}"=="null"?"":"${data_list[i]["AGREE"]}";
        dRUG_MT.DATE = "${data_list[i]["DATE"]}"=="null"?"":"${data_list[i]["DATE"]}";
        dRUG_MT.DRUG_NO = "${data_list[i]["DRUG_NO"]}"=="null"?"":"${data_list[i]["DRUG_NO"]}";
        dRUG_MT.DRUG_LINK = "${data_list[i]["DRUG_LINK"]}"=="null"?"":"${data_list[i]["DRUG_LINK"]}";
        dRUG_MT.SIGN_LINK = "${data_list[i]["SIGN_LINK"]}"=="null"?"":"${data_list[i]["SIGN_LINK"]}";
        dRUG_MT.CS_NO = "${data_list[i]["CS_NO"]}"=="null"?"":"${data_list[i]["CS_NO"]}";
        dRUG_MT.DEL = "${data_list[i]["DEL"]}"=="null"?"":"${data_list[i]["DEL"]}";

        if(dRUG_MT.DRUG_LINK.isNotEmpty){
          String DRUG_LINK = dRUG_MT.DRUG_LINK.replaceAll("~/", "");
          dRUG_MT.DRUG_LINK = "${IMAGE_IP}/${DRUG_LINK}";
        }

        if(dRUG_MT.SIGN_LINK.isNotEmpty){
          String SIGN_LINK = dRUG_MT.SIGN_LINK.replaceAll("~/", "");
          dRUG_MT.SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK}";
        }

        dRUG_MT.DATE = DateFormat('yyyy-MM-dd').format(DateTime.parse(dRUG_MT.DATE));
        List<String> list = dRUG_MT.DATE.split("-");
        dRUG_MT.DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[DateTime(int.parse(list[0]),int.parse(list[1]),int.parse(list[2])).weekday-1]})";

        if(dRUG_MT.DEL.isEmpty){
          _dRUG_MTs.add(dRUG_MT);
        }

      }
      dRUG_MTs = _dRUG_MTs;

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }


  /*
  成長曲線基準
   */
  Future<void> resd_GROWING_STANDARD_db_sub()async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    GROWING_STANDARDs.clear();
    String comm = "SELECT * FROM GROWING_STANDARD";
    String result = await sql_command(comm);
    SmartDialog.dismiss();
    try{
      List<dynamic> list = jsonDecode(result);
      dev.log("list.length:${list[0]}");
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
          GROWING_STANDARD g = GROWING_STANDARD();
          g.TYPE = "${data_list[i]["TYPE"]}"=="null"?"":"${data_list[i]["TYPE"]}".replaceAll(" ", "");
          g.SEX = "${data_list[i]["SEX"]}"=="null"?"":"${data_list[i]["SEX"]}".replaceAll(" ", "");
          g.MONTH = "${data_list[i]["MONTH"]}"=="null"?"":"${data_list[i]["MONTH"]}".replaceAll(" ", "");
          g.DATA_3 = "${data_list[i]["DATA_3"]}".contains("null")?"":"${data_list[i]["DATA_3"]}".replaceAll(" ", "");
          g.DATA_15 = "${data_list[i]["DATA_15"]}".contains("null")?"":"${data_list[i]["DATA_15"]}".replaceAll(" ", "");
          g.DATA_50 = "${data_list[i]["DATA_50"]}".contains("null")?"":"${data_list[i]["DATA_50"]}".replaceAll(" ", "");
          g.DATA_85 = "${data_list[i]["DATA_85"]}".contains("null")?"":"${data_list[i]["DATA_85"]}".replaceAll(" ", "");
          g.DATA_97 = "${data_list[i]["DATA_97"]}".contains("null")?"":"${data_list[i]["DATA_97"]}".replaceAll(" ", "");
          GROWING_STANDARDs.add(g);
        }

        Male_salesDatas_3.clear();
        Male_salesDatas_15.clear();
        Male_salesDatas_50.clear();
        Male_salesDatas_85.clear();
        Male_salesDatas_97.clear();
        Female_salesDatas_3.clear();
        Female_salesDatas_15.clear();
        Female_salesDatas_50.clear();
        Female_salesDatas_85.clear();
        Female_salesDatas_97.clear();
        sel_GROWING_STANDARD_TYPE = GROWING_STANDARD_TYPE[0];

        for(int i=0;i<GROWING_STANDARDs.length;i++){
          if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="M"){
            Male_salesDatas_3.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_3)));
            Male_salesDatas_15.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_15)));
            Male_salesDatas_50.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_50)));
            Male_salesDatas_85.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_85)));
            Male_salesDatas_97.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_97)));
          }
          if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="F"){
            Female_salesDatas_3.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_3)));
            Female_salesDatas_15.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_15)));
            Female_salesDatas_50.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_50)));
            Female_salesDatas_85.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_85)));
            Female_salesDatas_97.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_97)));
          }
        }

        Male_salesDatas_3.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Male_salesDatas_15.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Male_salesDatas_50.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Male_salesDatas_85.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Male_salesDatas_97.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));

        Female_salesDatas_3.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Female_salesDatas_15.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Female_salesDatas_50.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Female_salesDatas_85.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        Female_salesDatas_97.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
        showModalBottomSheet_GROWING_STANDARD_setState(() {

        });

        dev.log("test-1");
        this.showModalBottomSheet_GROWING_STANDARD_setState((){});
        dev.log("test-2");
        setState(() {

        });

      }

    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }


  }



  /*
  View_DAILY 生活概況時序查詢表(範例)
   */
  Future<void> read_View_DAILY_db_sub({DateTime? datetime,String CS_NO="",int timeout=15})async{

    dev.log("read_DAILY_MT_db_sub(開始):${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now())}");
    view_DAILYs.clear();
    String datetime_str = "${DateFormat('yyyy-MM-dd').format(datetime!)}";
    String comm = "SELECT * FROM DAILY_MT WHERE CS_NO='${CS_NO}' AND (DATE BETWEEN '${datetime_str} 00:00:00' AND '${datetime_str} 23:59:59')";
    dev.log("${comm}");
    String result = await sql_command("${comm}",timeout:timeout);

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
        v.TYPE = "${data_list[i]["TYPE"]}"=="null"?"":"${data_list[i]["TYPE"]}".replaceAll(" ", "");
        v.NO = "${data_list[i]["NO"]}"=="null"?"":"${data_list[i]["NO"]}".replaceAll(" ", "");
        v.DEPM_NO = "${data_list[i]["DEPM_NO"]}"=="null"?"":"${data_list[i]["DEPM_NO"]}".replaceAll(" ", "");
        v.CS_NO = "${data_list[i]["CS_NO"]}"=="null"?"":"${data_list[i]["CS_NO"]}".replaceAll(" ", "");
        v.CLASS_NO = "${data_list[i]["CLASS_NO"]}"=="null"?"":"${data_list[i]["CLASS_NO"]}".replaceAll(" ", "");
        v.DATE = "${data_list[i]["DATE"]}"=="null"?"":"${data_list[i]["DATE"]}".replaceAll(" ", "");
        v.TIME = "${data_list[i]["TIME"]}"=="null"?"":"${data_list[i]["TIME"]}".replaceAll(" ", "");
        v.MARK = "${data_list[i]["MARK"]}"=="null"?"":"${data_list[i]["MARK"]}";
        _view_DAILYs.add(v);
      }
      view_DAILYs = _view_DAILYs;

      for(int i=0;i<view_DAILYs.length;i++){
        if(view_DAILYs[i].TYPE.trim()=="RQD"){
          await read_DAILY_RQD_db_sub(NO:view_DAILYs[i].NO,TYPE:view_DAILYs[i].TYPE,index:i);
        }
        else if(view_DAILYs[i].TYPE.trim()=="NOT"){
          await read_DAILY_NOT_db_sub(NO:view_DAILYs[i].NO,TYPE:view_DAILYs[i].TYPE,index:i);
        }
      }

      dev.log("read_View_DAILY_db_sub(結束):${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now())}");

      setState(() {

      });

    }
    catch(e){
      dev.log("read_View_DAILY_db_sub(結束):${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now())}");
      dev.log("read_View_DAILY_db_sub(e):${e}");
    }

  }


  Future<void> read_DAILY_MT_TYPE_ITEM_db_sub()async{

    //DAILY_MT_TYPE_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_MT_TYPE_ITEM WHERE DEPM_NO='${EMPLOYEE_teacher.DEPM_NO}'";
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

        List<DAILY_MT_TYPE_ITEM> _DAILY_MT_TYPE_ITEMs = [];
        for(int i=0;i<data_list.length;i++){
          DAILY_MT_TYPE_ITEM v = DAILY_MT_TYPE_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          v.VISABLE = "${data_list[i]["VISABLE"]}"=="null"?true:("${data_list[i]["VISABLE"]}".contains("0")||"${data_list[i]["VISABLE"]}".contains("false"))?false:true;
          if(v.ITEM_NO=="ACT"){
            v.color = Colors.cyan;
            v.svg_icon = SvgPicture.asset("assets/images/Icon material-sports-handball.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="MLK"){
            v.color = Colors.blueAccent;
            v.svg_icon = SvgPicture.asset("assets/images/组 29134.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="POP"){
            v.color = Colors.redAccent;
            v.svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-poop.svg",color: v.color);
          }
          else if(v.ITEM_NO=="CLN"){
            v.color = Colors.pinkAccent;
            v.svg_icon = SvgPicture.asset("assets/images/Icon core-shower.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="CLS"){
            v.color = Colors.green;
            v.svg_icon = SvgPicture.asset("assets/images/Icon ion-shirt-sharp.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="EAT"){
            v.color = Colors.orange;
            v.svg_icon = SvgPicture.asset("assets/images/Icon material-food-bank.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="DRY"){
            v.color = Colors.lightGreen;
            v.svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-file-signature.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="TMP"){
            v.color = Colors.deepPurpleAccent;
            v.svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-temperature-full.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="SLP"){
            v.color = Colors.lightBlueAccent;
            v.svg_icon = SvgPicture.asset("assets/images/组 29166.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="RQD"){
            v.color = Colors.purpleAccent;
            v.svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-basket-shopping.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="CND"){
            v.color = Colors.amber;
            v.svg_icon = SvgPicture.asset("assets/images/Icon ion-body-sharp.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="NOT"){
            v.color = Colors.pink;
            v.svg_icon = SvgPicture.asset("assets/images/Icon material-notifications-none-4.svg",color: v.color,);
          }
          else if(v.ITEM_NO=="POV"){
            v.color = Colors.cyanAccent;
            v.svg_icon = Text("📒",textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 24.sp),);
          }
          if(v.VISABLE==true){
            _DAILY_MT_TYPE_ITEMs.add(v);
          }
        }

        DAILY_MT_TYPE_ITEM v = DAILY_MT_TYPE_ITEM();
        v.ITEM_NM = "健康紀錄";
        v.ITEM_NO = "健康紀錄";
        v.color = Colors.deepPurpleAccent;
        v.svg_icon = SvgPicture.asset("assets/images/组 29165.svg",color: v.color,);
        _DAILY_MT_TYPE_ITEMs.add(v);

        DAILY_MT_TYPE_ITEM v1 = DAILY_MT_TYPE_ITEM();
        v1.ITEM_NM = "成長曲線";
        v1.ITEM_NO = "成長曲線";
        v1.color = Colors.amber;
        v1.svg_icon = SvgPicture.asset("assets/images/Icon material-auto-stories.svg",color: v1.color,);
        _DAILY_MT_TYPE_ITEMs.add(v1);

        DAILY_MT_TYPE_ITEM v2 = DAILY_MT_TYPE_ITEM();
        v2.ITEM_NM = "到/離校";
        v2.ITEM_NO = "到/離校";
        v2.color = Colors.lightGreen;
        v2.svg_icon = SvgPicture.asset("assets/images/Icon material-access-time.svg",color: v2.color,);
        _DAILY_MT_TYPE_ITEMs.add(v2);

        DAILY_MT_TYPE_ITEMs = _DAILY_MT_TYPE_ITEMs;

        /*
        int add_count1 = 4-((DAILY_MT_TYPE_ITEMs.length % 4)==0?4:(DAILY_MT_TYPE_ITEMs.length % 4));
        DAILY_MT_TYPE_ITEM v3 = DAILY_MT_TYPE_ITEM();
        v3.ITEM_NM = "";
        v3.ITEM_NO = "";
        v3.color = Colors.transparent;
        v3.svg_icon = SvgPicture.asset("assets/images/Icon material-access-time.svg",color: v3.color,);
        for(int i=0;i<add_count1;i++){
          DAILY_MT_TYPE_ITEMs.add(v3);
        }

         */

        /*
        int index = DAILY_MT_TYPE_ITEMs.indexWhere((e)=>e.ITEM_NO=="NOT");
        DAILY_MT_TYPE_ITEM not = DAILY_MT_TYPE_ITEMs[index];
        DAILY_MT_TYPE_ITEMs.removeAt(index);
        DAILY_MT_TYPE_ITEMs.add(not);

         */


      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }


  Future<void> read_DAILY_ACT_ITEM_db_sub()async{

    if(DAILY_ACT_ITEMs.isNotEmpty){
      return;
    }
    DAILY_ACT_ITEMs.clear();
    String comm = "SELECT * FROM DAILY_ACT_ITEM";
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
          DAILY_ACT_ITEM v = DAILY_ACT_ITEM();
          v.ITEM_NM = "${data_list[i]["ITEM_NM"]}"=="null"?"":"${data_list[i]["ITEM_NM"]}".replaceAll(" ", "");
          v.ITEM_NO = "${data_list[i]["ITEM_NO"]}"=="null"?"":"${data_list[i]["ITEM_NO"]}".replaceAll(" ", "");
          DAILY_ACT_ITEMs.add(v);
          sel_DAILY_ACT_ITEM = DAILY_ACT_ITEMs[0];
        }

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }

  Future<void> delete_DAILY_MT_db_sub({String NO="",String TYPE=""})async{

    String comm = "DELETE FROM DAILY_MT WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }

  Future<void> delete_DAILY_SLP_db_sub({String NO="",String TYPE=""})async{

    String comm = "DELETE FROM DAILY_SLP WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }

  Future<void> delete_DAILY_NOT_db_sub({String NO="",String TYPE=""})async{

    String comm = "DELETE FROM DAILY_NOT WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }

  Future<void> delete_DAILY_CND_db_sub({String NO="",String TYPE=""})async{

    String comm = "DELETE FROM DAILY_CND WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }

  Future<void> delete_DAILY_RQD_db_sub({String NO="",String TYPE=""})async{

    String comm = "DELETE FROM DAILY_RQD WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }

  Future<void> delete_DAILY_DRY_db_sub({String NO="",String TYPE=""})async{

    String comm = "DELETE FROM DAILY_DRY WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }

  Future<void> delete_DAILY_ACT_db_sub({String NO="",String TYPE=""})async{

    String comm = "DELETE FROM DAILY_ACT WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }

  Future<void> delete_DAILY_TMP_db_sub({String NO="",String TYPE=""})async{

    String comm = "DELETE FROM DAILY_TMP WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }

  Future<void> delete_DAILY_POP_db_sub({String NO="",String TYPE=""})async{

    String comm = "DELETE FROM DAILY_POP WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }

  Future<void> delete_DAILY_CLS_db_sub({String NO="",String TYPE=""})async{

    String comm = "DELETE FROM DAILY_CLS WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }

  Future<void> delete_DAILY_EAT_db_sub({String NO="",String TYPE=""})async{

    String comm = "DELETE FROM DAILY_EAT WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }

  Future<void> delete_DAILY_PIC_DL_db_sub({String NO="",String TYPE=""})async{

    String comm = "DELETE FROM DAILY_PIC_DL WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }


  Future<void> delete_DAILY_MLK_db_sub({String NO="",String TYPE=""})async{

    String comm = "DELETE FROM DAILY_MLK WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }


  Future<void> delete_DAILY_CLN_db_sub({String NO="",String TYPE=""})async{

    String comm = "DELETE FROM DAILY_CLN WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }


  Future<void> delete_ROLLCALL_db_sub({String NO=""})async{

    String comm = "DELETE FROM ROLLCALL WHERE NO='${NO}'";
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

      if(data_list.length==0){

      }
      else{
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }

  }


  /*
  [托嬰/幼兒] 請假 EXCUSED
   */
  Future<void> write_EXCUSED_db_sub({String NO="",String CS_NO="",CFM_ITEM? cFM_ITEM,String CFM_USER="",})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    String datetime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    String result = await sql_command('''UPDATE EXCUSED SET CFM_DT='${datetime}', CFM_NO='${cFM_ITEM!.CFM_NO}', CFM_USER='${CFM_USER}' WHERE NO='${NO}' AND CS_NO='${CS_NO}' ''');
    SmartDialog.dismiss();
    try{

      /*
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      dev.log("data_list.length:${data_list.length}");

       */

      SmartDialog.showToast("送出成功");
      await EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
      setState(() {

      });


      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs.length;i++){
        String FCM = await search_CUSTOMER_DL_fcm_sub(ACCOUNT:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.ACCOUNT);
        await sendPushNotification(
            title: "老師",
            message: "老師已將請假委託變更為${cFM_ITEM.CFM_NM}",
            token: FCM,//EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.FCM,
            ChatID:"老師已將請假委託變更為${cFM_ITEM.CFM_NM}",
            UserAccount: '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.ACCOUNT}',
            TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}",
            CS_NO:CS_NO,
            CFM_NO:cFM_ITEM.CFM_NO,
            EXCUSED_NO:NO
        );
      }






    }
    catch(e){
      dev.log("網路異常:${e}");
      SmartDialog.showToast("網路異常");
    }
  }


  /*
  [托嬰/幼兒] 請假 EXCUSED
   */
  Future<void> write_ENTRUSTED_db_sub({String NO="",String CFM_USER="",})async{
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 500), () {});
    String datetime = DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now());
    String result = await sql_command('''UPDATE ENTRUSTED SET CFM_DT='${datetime}', CFM_USER='${CFM_USER}' WHERE NO='${NO}' ''');
    SmartDialog.dismiss();
    try{

      /*
      List<dynamic> list = jsonDecode(result);
      List<dynamic> data_list = [];
      if(Platform.isAndroid){
        data_list = list;
      }
      else if(Platform.isIOS){
        data_list = list;
      }
      dev.log("data_list.length:${data_list.length}");

       */

      SmartDialog.showToast("送出成功");
      await ENTRUSTED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
      setState(() {

      });


    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }


  /*
  [托嬰/幼兒] DAILY_PRS
   */
  Future<void> read_for_DAILY_PRS_db_sub({String datetime=""})async{

    /*
    await EasyLoading.show(status: "處理中...");

    List<String> CS_NOs = [];
    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
      CS_NOs.add(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO);
    }

    //檢查學生是否為0
    if(CS_NOs.length==0){
      await EasyLoading.showToast("目前無學生在此班級");
      return;
    }

    String CS_NO_json = jsonEncode(CS_NOs.toList());
    CS_NO_json = CS_NO_json.replaceAll("[", "(");
    CS_NO_json = CS_NO_json.replaceAll("]", ")");
    CS_NO_json = CS_NO_json.replaceAll("\"", "'");

    dev.log("CS_NO_json:${CS_NO_json}");

     */

    //datetime = DateFormat("yyyy-MM-dd").format(DateTime.now());

    DAILY_PRSs.clear();
    setState(() {

    });
    String comm = "SELECT * FROM DAILY_PRS WHERE CS_NO='${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}' AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";
    dev.log("comm:${comm}");
    String result = await sql_command(comm);
    //SmartDialog.dismiss();
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
      List<DAILY_PRS> _DAILY_PRSs=[];
      for(int i=0;i<data_list.length;i++){
        DAILY_PRS b = DAILY_PRS();
        b.TYPE = "${data_list[i]["TYPE"]}".contains("null")?"":"${data_list[i]["TYPE"]}";
        b.NO = "${data_list[i]["NO"]}".contains("null")?"":"${data_list[i]["NO"]}";
        b.DATE = "${data_list[i]["DATE"]}".contains("null")?"":"${data_list[i]["DATE"]}";
        b.TIME = "${data_list[i]["TIME"]}".contains("null")?"":"${data_list[i]["TIME"]}";
        b.DEPM_NO = "${data_list[i]["DEPM_NO"]}".contains("null")?"":"${data_list[i]["DEPM_NO"]}";
        b.CLASS_NO = "${data_list[i]["CLASS_NO"]}".contains("null")?"":"${data_list[i]["CLASS_NO"]}";
        b.CS_NO = "${data_list[i]["CS_NO"]}".contains("null")?"":"${data_list[i]["CS_NO"]}";
        b.NOTE = "${data_list[i]["NOTE"]}".contains("null")?"":"${data_list[i]["NOTE"]}";

        b.REPLY = "${data_list[i]["REPLY"]}".contains("null")?"":"${data_list[i]["REPLY"]}";
        b.REPLY_textEditingController.text = b.REPLY;

        b.REPLY_USER_NO = "${data_list[i]["REPLY_USER_NO"]}".contains("null")?"":"${data_list[i]["REPLY_USER_NO"]}";
        b.STATUS = "${data_list[i]["STATUS"]}".contains("null")?"":"${data_list[i]["STATUS"]}";
        String SIGN_LINK = "${data_list[i]["SIGN_LINK"]}".replaceAll("~/", "");
        b.SIGN_LINK = "${IMAGE_IP}/${SIGN_LINK}";

        b.DATE = DateFormat('yyyy-MM-dd').format(DateTime.parse(b.DATE));
        List<String> list = b.DATE.split("-");
        b.DateStr = "${list[0]}年${list[1]}月${list[2]}日 (${WEEK_DAY[DateTime(int.parse(list[0]),int.parse(list[1]),int.parse(list[2])).weekday-1]})";
        _DAILY_PRSs.add(b);
      }
      DAILY_PRSs=_DAILY_PRSs;
      DAILY_PRSs.sort((a,b) => b.DATE.compareTo(a.DATE));

      setState(() {

      });



    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("網路異常");
    }
  }


  Future<void> read_DAILY_RQD_db_sub({
    String NO="",
    String TYPE="",
    int index=0
  })async{

    String comm = "SELECT * FROM DAILY_RQD WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

        view_DAILYs[index].RECIPIENT = "${data_list[0]["RECIPIENT"]}".contains("null")||"${data_list[0]["RECIPIENT"]}".contains("0")||"${data_list[0]["RECIPIENT"]}".contains("false")?false:true;

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }


  Future<void> read_DAILY_NOT_db_sub({
    String NO="",
    String TYPE="",
    int index=0
  })async{

    String comm = "SELECT * FROM DAILY_NOT WHERE NO='${NO}' AND TYPE='${TYPE}'";
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

        view_DAILYs[index].RECIPIENT = "${data_list[0]["RECIPIENT"]}".contains("null")||"${data_list[0]["RECIPIENT"]}".contains("0")||"${data_list[0]["RECIPIENT"]}".contains("false")?false:true;

      }
      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
    }

  }


  /*
   */
  Future<bool> updata_DAILY_PRS_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        String STATUS="",//消息的狀態
      })async{

    String comm = "UPDATE DAILY_PRS SET STATUS='${STATUS}' WHERE NO='${NO}' AND TYPE='${TYPE}'";
    dev.log("${comm}");


    String result = await sql_command("${comm}");
    dev.log("result:${result}");
    try{

      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs.length;i++){
        String FCM = await search_CUSTOMER_DL_fcm_sub(ACCOUNT:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.ACCOUNT);
        await sendPushNotification(
            title: "老師",
            message: "已讀聯絡簿",
            token: FCM,//EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.FCM,
            ChatID:"已讀聯絡簿",
            CS_NO:CUSTOMER_selectedValue.CS_NO,
            DATE:"${DateFormat("yyyy-MM-dd").format(DateTime.now())}",//日期
            UserAccount:'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.ACCOUNT}',
            TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}".trim()
        );
      }


      return true;

    }
    catch(e){
      dev.log("${e}");
      return false;
    }


  }

  /*
  老師端-學生-今日聯絡簿，老師想要有回覆的功能。
   */
  Future<void> write_REPLY_to_DAILY_PRS_db_sub({
    String REPLY="",
    String REPLY_USER_NO="",
    String TYPE="",
    String NO=""
  }
  )async{

    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 800), () {});

    String comm = "UPDATE DAILY_PRS SET REPLY='${REPLY}' WHERE TYPE='${TYPE}' AND NO='${NO}'";
    dev.log("${comm}");


    String result = await sql_command("${comm}");
    SmartDialog.dismiss();

    dev.log("result:${result}");
    try{

      for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs.length;i++){
        String FCM = await search_CUSTOMER_DL_fcm_sub(ACCOUNT:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.ACCOUNT);
        await sendPushNotification(
            title: "老師",
            message: "已回覆聯絡簿",
            token: FCM,//EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.FCM,
            ChatID:"已回覆聯絡簿",
            CS_NO:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO,
            DATE:"${DateFormat("yyyy-MM-dd").format(DateTime.now())}",//日期
            UserAccount:'${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.ACCOUNT}',
            TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}".trim()
        );
      }
      SmartDialog.showToast("送出成功");

    }
    catch(e){
      dev.log("${e}");
      SmartDialog.showToast("送出失敗");
    }

  }


  /*
  聯絡簿送出(家長可顯示)
   */
  Future<bool> check_DAILY_MT_db_sub({String TYPE=""})async{

    bool check = false;

    String DATE="${DateFormat('yyyy-MM-dd').format(dateTime!)}";//日期
    String TIME="${DateFormat('HH:mm').format(DateTime.now())}";//"${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00",//時間
    String DEPM_NO="${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}";//學校
    String CLASS_NO="${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}";//班級
    String CS_NO="${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}";//學生身分證字號
    String USER_NO="${EMPLOYEE_teacher.EMP_NO}";//系統自動帶入老師編號

    String comm = '''
    SELECT *
FROM DAILY_MT
WHERE TYPE = '${TYPE}'
  AND DATE = '${DATE}'
  AND DEPM_NO = '${DEPM_NO}'
  AND CLASS_NO = '${CLASS_NO}'
  AND CS_NO = '${CS_NO}'
  AND USER_NO = '${USER_NO}'
    ''';
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
      else{
        check = true;
      }


    }
    catch(e){
      dev.log("${e}");
    }

    return check;

  }


  /*
  聯絡簿送出(家長可顯示)
   */
  Future<void> add_DAILY_MT_db_sub({String TYPE=""})async{

    int View_DAILY_NO_num = await read_View_DAILY_db_sub2(TYPE:TYPE);
    dev.log("View_DAILY_NO_num:${View_DAILY_NO_num}");
    if(View_DAILY_NO_num==-1){
      SmartDialog.showToast("read_View_DAILY_db_sub error");
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    SmartDialog.showLoading(msg: "處理中...");
    await Future.delayed(const Duration(milliseconds: 300), () {});
    //View_DAILY_NO_num+=1;
    String View_DAILY_NO = "${View_DAILY_NO_num}";
    //View_DAILY_NO = View_DAILY_NO.substring(2,View_DAILY_NO.length);
    dev.log("View_DAILY_NO:${View_DAILY_NO}");

    dev.log("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NM}");

    bool check = await insert_DAILY_MT_db_sub(
      TYPE:TYPE,
      NO:View_DAILY_NO,//編號
      DATE:"${DateFormat('yyyy-MM-dd').format(dateTime!)}",//日期
      TIME:"${DateFormat('HH:mm').format(DateTime.now())}",//"${timeOfDay!.hour.toString().padLeft(2, '0')}:${timeOfDay!.minute.toString().padLeft(2, '0')}:00",//時間
      DEPM_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.DEPM_NO}",//學校
      CLASS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO}",//班級
      CS_NO:"${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",//學生身分證字號
      USER_NO:"${EMPLOYEE_teacher.EMP_NO}",//系統自動帶入老師編號
    );

    if(check==false){
      SmartDialog.dismiss();
      SmartDialog.showToast("忙碌中，請重試");
      return;
    }

    Student_T_page_fun!(action:"新增聯絡簿送出成功");

    SmartDialog.dismiss();
    SmartDialog.showToast("聯絡簿送出成功");

    for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs.length;i++){
      String FCM = await search_CUSTOMER_DL_fcm_sub(ACCOUNT:EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.ACCOUNT);
      await sendPushNotification(
          title: "老師",
          message: "親愛的家長您好，今天的電子聯絡簿已完成上傳～請至系統查閱，瞭解寶貝在園的生活喔！",
          token: FCM,//EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.FCM,
          ChatID:"電子聯絡簿已完成上傳",
          UserAccount: '${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DLs[i]!.ACCOUNT}',
          TeacherAccount:"${EMPLOYEE_teacher.ACCOUNT}"
      );
    }

  }


  /*
  生活概況
   */
  Future<int> read_View_DAILY_db_sub2({String TYPE=""})async{

    int View_DAILY_NO_num=0;
    String datetime = "${DateFormat('yyyy-MM-dd').format(dateTime!)}";

    //2025/05/15修改搜尋條件
    //String comm = "SELECT * FROM DAILY_MT WHERE TYPE='ACT' AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'";
    String comm = '''SELECT *
    FROM DAILY_MT
    WHERE TYPE = '${TYPE}'
      AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'
      AND NO = (
        SELECT MAX(NO)
        FROM DAILY_MT
        WHERE TYPE = '${TYPE}'
          AND DATE BETWEEN '${datetime} 00:00:00' AND '${datetime} 23:59:59'
      );''';
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

        View_DAILY_NO_num+=1;
        String ss = "${DateFormat('yyyyMMdd').format(dateTime!)}";
        View_DAILY_NO_num = int.parse("${ss.substring(2,ss.length)}${View_DAILY_NO_num.toString().padLeft(7,"0")}");

      }
      else{
        dev.log("筆數:${data_list.length}");
        data_list.sort((a,b)=> int.parse(a["NO"]).compareTo(int.parse(b["NO"])));
        String View_DAILY_NO = "${data_list[data_list.length-1]["NO"]}";
        dev.log("View_DAILY_NO:${View_DAILY_NO}");
        //找出流水號
        //View_DAILY_NO_num = int.parse("${View_DAILY_NO.substring(View_DAILY_NO.length-7,View_DAILY_NO.length)}");
        View_DAILY_NO_num = int.parse("${View_DAILY_NO}");
        View_DAILY_NO_num+=1;
        dev.log("View_DAILY_NO_num:${View_DAILY_NO_num}");
      }
      setState(() {

      });

    }
    catch(e){
      View_DAILY_NO_num=-1;
      dev.log("${e}");
    }

    return View_DAILY_NO_num;

  }


  /*

   */
  Future<bool> insert_DAILY_MT_db_sub(
      {
        String TYPE="",//單別
        String NO="",//編號
        String DATE="",//日期
        String TIME="",//時間
        String DEPM_NO="",//學校編號
        String CLASS_NO="",//班級編號
        String CS_NO="",//學生編號
        String USER_NO="",//
      })async{

    String comm = "INSERT INTO DAILY_MT(TYPE,NO,DATE,TIME,DEPM_NO,CLASS_NO,CS_NO,USER_NO) VALUES ('${TYPE}','${NO}','${DATE}','${TIME}','${DEPM_NO}','${CLASS_NO}','${CS_NO}','${USER_NO}')";
    dev.log("${comm}");


    String result = await sql_command("${comm}");
    dev.log("result:${result}");
    try{
      if(result.contains("執行成功")){
        setState(() {

        });
        return true;
      }
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






  @override
  Widget build(BuildContext context) {

    //test();

    // other entries
    // Every items may have a sub-menu.
    // Here the sub-menus are added with [addStarMenu] extension
    final otherEntries = <Widget>[
      const FloatingActionButton(
        onPressed: null,
        backgroundColor: Colors.black,
        child: Icon(Icons.add_call),
      ),
      const FloatingActionButton(
        onPressed: null,
        backgroundColor: Colors.indigo,
        child: Icon(Icons.adb),
      ),
      const FloatingActionButton(
        onPressed: null,
        backgroundColor: Colors.purple,
        child: Icon(Icons.home),
      ),
      const FloatingActionButton(
        onPressed: null,
        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.delete),
      ),
      const FloatingActionButton(
        onPressed: null,
        backgroundColor: Colors.deepPurple,
        child: Icon(Icons.get_app),
      ),
    ];


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
        child:FloatingDraggableWidget(
            floatingWidgetHeight: 55.sp,
            floatingWidgetWidth: 55.sp,
            floatingWidget: GestureDetector(
                key: btnKey,
                onTap: ()async{

                  /*
                  centerStarMenuController.openMenu!();
                  is_show=true;
                  setState(() {

                  });

                   */


                  /*

                  menu = PopupMenu(
                    context: context,
                    config: MenuConfig(
                        type: MenuType.grid,
                        itemWidth:  (iPad==true)?50.w:80.w,
                        itemHeight: (iPad==true)?60.h:90.h,
                        maxColumn: (DAILY_MT_TYPE_ITEMs.length/4).toInt(),
                        textStyle: TextStyle(color: Colors.white,fontSize: (iPad==true)?7.sp:15.sp),
                        backgroundColor: Colors.black54
                    ),
                    items:DAILY_MT_TYPE_ITEMs.map((e){
                      return MenuItem(
                          textStyle: TextStyle(color: Colors.white,fontSize: (iPad==true)?(e.ITEM_NO.contains("CLS"))?4.sp:7.sp:(e.ITEM_NO.contains("CLS"))?10.sp:14.sp),
                          title: '${e.ITEM_NM}', image: e.svg_icon,userInfo: e);
                    }).toList(),
                    /*
                                   items: [
                                     MenuItem(title: 'Copy', image: Image.asset('assets/copy.png')),
                                     MenuItem(title: 'Power', image: Icon(Icons.power, color: Colors.white)),
                                     MenuItem(
                                         title: 'Setting', image: Icon(Icons.settings, color: Colors.white)),
                                     MenuItem(
                                         title: 'PopupMenu', image: Icon(Icons.menu, color: Colors.white))
                                   ],

                                    */
                    onClickMenu: (item){
                      print('Click menu -> ${item.menuTitle}');
                      if(item.menuUserInfo.ITEM_NO=="ACT"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_ACT_page(dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="MLK"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_MLK_page(dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="POP"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_POP_page(dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="CLN"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_CLN_page(dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="CLS"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_CLS_page(dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="EAT"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_EAT_page(dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="DRY"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_DRY_page(dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="TMP"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_TMP_page(dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="SLP"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_SLP_page(dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="RQD"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_RQD_page(dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="CND"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_CND_page(dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="NOT"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_DAILY_NOT_page(dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="健康紀錄"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: GROWING_T_page(dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="成長曲線"){
                        showModalBottomSheet(
                            backgroundColor: Colors.white,
                            isScrollControlled:true,
                            context: context,
                            builder: (BuildContext context) {
                              showModalBottomSheet_GROWING_STANDARD_context = context;
                              return StatefulBuilder(
                                  builder: (BuildContext context, showModalBottomSheet_image_setState){
                                    this.showModalBottomSheet_GROWING_STANDARD_setState =
                                        showModalBottomSheet_image_setState;
                                    return Column(children: [

                                      Container(height: 45.h,),
                                      Row(children: [
                                        Expanded(child: Container()),
                                        GestureDetector(
                                            onTap:(){
                                              Navigator.pop(showModalBottomSheet_GROWING_STANDARD_context);
                                            },
                                            child: Icon(Icons.cancel_outlined,size: 30.sp,color: Colors.black,)),
                                        Container(width: 20.w,),
                                      ],),
                                      Container(height: 10.h,),
                                      Text("衛服部幼兒發展數據",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                          fontFamily: "GenJyuuGothic",
                                          fontWeight: FontWeight.normal,
                                          fontSize: 20.sp,
                                          color: Colors.lightBlue)),
                                      Container(height: 10.h,),
                                      Expanded(child: Container(child: Column(children: [

                                        Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: Colors.grey),
                                              borderRadius: BorderRadius.circular(5.w),
                                            ),
                                            //width: 80.w,
                                            height: 36.h,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2<String>(
                                                isExpanded: true,
                                                items: GROWING_STANDARD_TYPE
                                                    .map((String item) => DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(
                                                    item.split("-").last,
                                                    style: TextStyle(
                                                      fontSize: 18.sp,
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xff555555),
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ))
                                                    .toList(),
                                                value: sel_GROWING_STANDARD_TYPE,
                                                onChanged: (value) {

                                                  Male_salesDatas_3.clear();
                                                  Male_salesDatas_15.clear();
                                                  Male_salesDatas_50.clear();
                                                  Male_salesDatas_85.clear();
                                                  Male_salesDatas_97.clear();

                                                  Female_salesDatas_3.clear();
                                                  Female_salesDatas_15.clear();
                                                  Female_salesDatas_50.clear();
                                                  Female_salesDatas_85.clear();
                                                  Female_salesDatas_97.clear();


                                                  sel_GROWING_STANDARD_TYPE = value!;

                                                  for(int i=0;i<GROWING_STANDARDs.length;i++){
                                                    if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="M"){
                                                      Male_salesDatas_3.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_3)));
                                                      Male_salesDatas_15.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_15)));
                                                      Male_salesDatas_50.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_50)));
                                                      Male_salesDatas_85.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_85)));
                                                      Male_salesDatas_97.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_97)));
                                                    }
                                                    if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="F"){
                                                      Female_salesDatas_3.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_3)));
                                                      Female_salesDatas_15.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_15)));
                                                      Female_salesDatas_50.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_50)));
                                                      Female_salesDatas_85.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_85)));
                                                      Female_salesDatas_97.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_97)));
                                                    }
                                                  }

                                                  Male_salesDatas_3.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                  Male_salesDatas_15.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                  Male_salesDatas_50.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                  Male_salesDatas_85.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                  Male_salesDatas_97.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));

                                                  Female_salesDatas_3.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                  Female_salesDatas_15.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                  Female_salesDatas_50.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                  Female_salesDatas_85.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                  Female_salesDatas_97.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                  showModalBottomSheet_GROWING_STANDARD_setState(() {

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
                                        (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.SEX=="M")?
                                        Expanded(child: SfCartesianChart(

                                            primaryXAxis: CategoryAxis(
                                                title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                            ),
                                            primaryYAxis: CategoryAxis(
                                                title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                            ),
                                            // Chart title
                                            title: ChartTitle(text: '男生',textStyle: TextStyle(fontSize: 20.sp)),
                                            // Enable legend
                                            legend: Legend(isVisible: true),
                                            // Enable tooltip
                                            tooltipBehavior: _tooltipBehavior,

                                            series: <LineSeries<SalesData, String>>[
                                              LineSeries<SalesData, String>(
                                                dataSource:  Male_salesDatas_3.toList(),
                                                xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                yValueMapper: (SalesData sales, _) => sales.DATA,
                                                // Enable data label
                                                dataLabelSettings: DataLabelSettings(isVisible: true),
                                                //xAxisName: "月齡",
                                                //yAxisName: "數據",
                                                name: "3%",
                                              ),
                                              LineSeries<SalesData, String>(
                                                dataSource:  Male_salesDatas_15.toList(),
                                                xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                yValueMapper: (SalesData sales, _) => sales.DATA,
                                                // Enable data label
                                                dataLabelSettings: DataLabelSettings(isVisible: true),
                                                name: "15%",
                                              ),
                                              LineSeries<SalesData, String>(
                                                dataSource:  Male_salesDatas_50.toList(),
                                                xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                yValueMapper: (SalesData sales, _) => sales.DATA,
                                                // Enable data label
                                                dataLabelSettings: DataLabelSettings(isVisible: true),
                                                name: "50%",
                                              ),
                                              LineSeries<SalesData, String>(
                                                dataSource:  Male_salesDatas_85.toList(),
                                                xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                yValueMapper: (SalesData sales, _) => sales.DATA,
                                                // Enable data label
                                                dataLabelSettings: DataLabelSettings(isVisible: true),
                                                name: "85%",
                                              ),
                                              LineSeries<SalesData, String>(
                                                dataSource:  Male_salesDatas_97.toList(),
                                                xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                yValueMapper: (SalesData sales, _) => sales.DATA,
                                                // Enable data label
                                                dataLabelSettings: DataLabelSettings(isVisible: true),
                                                name: "97%",
                                              )
                                            ]
                                        )):
                                        //Container(height: 20.h,),
                                        Expanded(child: SfCartesianChart(


                                            primaryXAxis: CategoryAxis(
                                                title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                            ),
                                            primaryYAxis: CategoryAxis(
                                                title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                            ),
                                            // Chart title
                                            title: ChartTitle(text: '女生',textStyle: TextStyle(fontSize: 20.sp)),
                                            // Enable legend
                                            legend: Legend(isVisible: true),
                                            // Enable tooltip
                                            tooltipBehavior: _tooltipBehavior,

                                            series: <LineSeries<SalesData, String>>[
                                              LineSeries<SalesData, String>(
                                                dataSource:  Female_salesDatas_3.toList(),
                                                xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                yValueMapper: (SalesData sales, _) => sales.DATA,
                                                // Enable data label
                                                dataLabelSettings: DataLabelSettings(isVisible: true),
                                                //xAxisName: "月齡",
                                                //yAxisName: "數據",
                                                name: "3%",
                                              ),
                                              LineSeries<SalesData, String>(
                                                dataSource:  Female_salesDatas_15.toList(),
                                                xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                yValueMapper: (SalesData sales, _) => sales.DATA,
                                                // Enable data label
                                                dataLabelSettings: DataLabelSettings(isVisible: true),
                                                //xAxisName: "月齡",
                                                //yAxisName: "數據",
                                                name: "15%",
                                              ),
                                              LineSeries<SalesData, String>(
                                                dataSource:  Female_salesDatas_50.toList(),
                                                xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                yValueMapper: (SalesData sales, _) => sales.DATA,
                                                // Enable data label
                                                dataLabelSettings: DataLabelSettings(isVisible: true),
                                                //xAxisName: "月齡",
                                                //yAxisName: "數據",
                                                name: "50%",
                                              ),
                                              LineSeries<SalesData, String>(
                                                dataSource:  Female_salesDatas_85.toList(),
                                                xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                yValueMapper: (SalesData sales, _) => sales.DATA,
                                                // Enable data label
                                                dataLabelSettings: DataLabelSettings(isVisible: true),
                                                //xAxisName: "月齡",
                                                //yAxisName: "數據",
                                                name: "85%",
                                              ),
                                              LineSeries<SalesData, String>(
                                                dataSource:  Female_salesDatas_97.toList(),
                                                xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                yValueMapper: (SalesData sales, _) => sales.DATA,
                                                // Enable data label
                                                dataLabelSettings: DataLabelSettings(isVisible: true),
                                                //xAxisName: "月齡",
                                                //yAxisName: "數據",
                                                name: "97%",
                                              ),
                                            ]
                                        )),
                                        Container(height: 20.h,),

                                      ],))),


                                    ],);
                                  });

                            });

                        resd_GROWING_STANDARD_db_sub();
                      }
                      else if(item.menuUserInfo.ITEM_NO=="到/離校"){
                        Navigator.push(context, PageTransition(
                            type: PageTransitionType.rightToLeft, child: ADD_ROLLCALL_page(dateTime:dateTime)));
                      }
                      else if(item.menuUserInfo.ITEM_NO=="POV"){

                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: Text('提醒',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 18.sp),),
                              content: Text('確定聯絡簿送出？',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 18.sp),),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(); // 關閉對話框
                                  },
                                  child: Text('取消',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 15.sp),),
                                ),
                                ElevatedButton(
                                  onPressed: () async{
                                    Navigator.of(context).pop(); // 關閉對話框
                                    //先確認是否已送出
                                    bool check = await check_DAILY_MT_db_sub(TYPE: "POV");

                                    if(check==false){
                                      dev.log('聯絡簿已送出');
                                      add_DAILY_MT_db_sub(TYPE: "POV");
                                    }
                                    else{
                                      dev.log('聯絡簿已送出');
                                      SmartDialog.showToast("聯絡簿已送出");
                                    }

                                  },
                                  child: Text('確定',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 15.sp),),
                                ),
                              ],
                            );
                          },
                        );


                      }
                    },
                    onDismiss: (){

                    },
                  );
                  menu.show(widgetKey: btnKey);

                   */

                  if(DAILY_MT_TYPE_ITEMs.isEmpty){
                    Fluttertoast.showToast(
                        msg: "處理中...",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0.sp
                    );
                    await read_DAILY_MT_TYPE_ITEM_db_sub();
                    return;
                  }


                  final RenderBox renderBox = btnKey.currentContext!.findRenderObject() as RenderBox;
                  final Offset offset = renderBox.localToGlobal(Offset.zero);
                  final Size size = renderBox.size;
                  final Rect buttonRect = offset & size;

                  List<DAILY_MT_TYPE_ITEM> specialItems = DAILY_MT_TYPE_ITEMs
                      .where((e) => (e.ITEM_NO == 'POV'||e.ITEM_NM == '到/離校'))
                      .toList(); // 例如 items.take(2)
                  List<DAILY_MT_TYPE_ITEM> gridItems = DAILY_MT_TYPE_ITEMs
                      .where((e) => !specialItems.contains(e))
                      .toList();

                  CustomGridMenu.show(
                      context: context,
                      gridItems: gridItems,
                      buttonRect: buttonRect,
                      onSelected: (item) {
                        dev.log('選中: ${item.ITEM_NM}');
                        if(item.ITEM_NO=="ACT"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_ACT_page(dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="MLK"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_MLK_page(dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="POP"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_POP_page(dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="CLN"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_CLN_page(dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="CLS"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_CLS_page(dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="EAT"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_EAT_page(dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="DRY"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_DRY_page(dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="TMP"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_TMP_page(dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="SLP"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_SLP_page(dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="RQD"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_RQD_page(dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="CND"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_CND_page(dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="NOT"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_DAILY_NOT_page(dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="健康紀錄"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: GROWING_T_page(dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="成長曲線"){
                          showModalBottomSheet(
                              backgroundColor: Colors.white,
                              isScrollControlled:true,
                              context: context,
                              builder: (BuildContext context) {
                                showModalBottomSheet_GROWING_STANDARD_context = context;
                                return StatefulBuilder(
                                    builder: (BuildContext context, showModalBottomSheet_image_setState){
                                      this.showModalBottomSheet_GROWING_STANDARD_setState =
                                          showModalBottomSheet_image_setState;
                                      return Column(children: [

                                        Container(height: 45.h,),
                                        Row(children: [
                                          Expanded(child: Container()),
                                          GestureDetector(
                                              onTap:(){
                                                Navigator.pop(showModalBottomSheet_GROWING_STANDARD_context);
                                              },
                                              child: Icon(Icons.cancel_outlined,size: 30.sp,color: Colors.black,)),
                                          Container(width: 20.w,),
                                        ],),
                                        Container(height: 10.h,),
                                        Text("衛服部幼兒發展數據",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20.sp,
                                            color: Colors.lightBlue)),
                                        Container(height: 10.h,),
                                        Expanded(child: Container(child: Column(children: [

                                          Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(5.w),
                                              ),
                                              //width: 80.w,
                                              height: 36.h,
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  items: GROWING_STANDARD_TYPE
                                                      .map((String item) => DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item.split("-").last,
                                                      style: TextStyle(
                                                        fontSize: 18.sp,
                                                        fontWeight: FontWeight.bold,
                                                        color: const Color(0xff555555),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                                      .toList(),
                                                  value: sel_GROWING_STANDARD_TYPE,
                                                  onChanged: (value) {

                                                    Male_salesDatas_3.clear();
                                                    Male_salesDatas_15.clear();
                                                    Male_salesDatas_50.clear();
                                                    Male_salesDatas_85.clear();
                                                    Male_salesDatas_97.clear();

                                                    Female_salesDatas_3.clear();
                                                    Female_salesDatas_15.clear();
                                                    Female_salesDatas_50.clear();
                                                    Female_salesDatas_85.clear();
                                                    Female_salesDatas_97.clear();


                                                    sel_GROWING_STANDARD_TYPE = value!;

                                                    for(int i=0;i<GROWING_STANDARDs.length;i++){
                                                      if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="M"){
                                                        Male_salesDatas_3.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_3)));
                                                        Male_salesDatas_15.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_15)));
                                                        Male_salesDatas_50.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_50)));
                                                        Male_salesDatas_85.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_85)));
                                                        Male_salesDatas_97.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_97)));
                                                      }
                                                      if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="F"){
                                                        Female_salesDatas_3.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_3)));
                                                        Female_salesDatas_15.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_15)));
                                                        Female_salesDatas_50.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_50)));
                                                        Female_salesDatas_85.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_85)));
                                                        Female_salesDatas_97.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_97)));
                                                      }
                                                    }

                                                    Male_salesDatas_3.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Male_salesDatas_15.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Male_salesDatas_50.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Male_salesDatas_85.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Male_salesDatas_97.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));

                                                    Female_salesDatas_3.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Female_salesDatas_15.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Female_salesDatas_50.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Female_salesDatas_85.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Female_salesDatas_97.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    showModalBottomSheet_GROWING_STANDARD_setState(() {

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
                                          (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.SEX=="M")?
                                          Expanded(child: SfCartesianChart(

                                              primaryXAxis: CategoryAxis(
                                                  title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              primaryYAxis: CategoryAxis(
                                                  title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              // Chart title
                                              title: ChartTitle(text: '男生',textStyle: TextStyle(fontSize: 20.sp)),
                                              // Enable legend
                                              legend: Legend(isVisible: true),
                                              // Enable tooltip
                                              tooltipBehavior: _tooltipBehavior,

                                              series: <LineSeries<SalesData, String>>[
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_3.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "3%",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_15.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  name: "15%",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_50.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  name: "50%",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_85.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  name: "85%",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_97.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  name: "97%",
                                                )
                                              ]
                                          )):
                                          //Container(height: 20.h,),
                                          Expanded(child: SfCartesianChart(


                                              primaryXAxis: CategoryAxis(
                                                  title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              primaryYAxis: CategoryAxis(
                                                  title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              // Chart title
                                              title: ChartTitle(text: '女生',textStyle: TextStyle(fontSize: 20.sp)),
                                              // Enable legend
                                              legend: Legend(isVisible: true),
                                              // Enable tooltip
                                              tooltipBehavior: _tooltipBehavior,

                                              series: <LineSeries<SalesData, String>>[
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_3.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "3%",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_15.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "15%",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_50.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "50%",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_85.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "85%",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_97.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "97%",
                                                ),
                                              ]
                                          )),
                                          Container(height: 20.h,),

                                        ],))),


                                      ],);
                                    });

                              });

                          resd_GROWING_STANDARD_db_sub();
                        }
                        else if(item.ITEM_NO=="到/離校"){
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_ROLLCALL_page(dateTime:dateTime)));
                        }
                        else if(item.ITEM_NO=="POV"){

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                title: Text('提醒',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 18.sp),),
                                content: Text('確定聯絡簿送出？',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 18.sp),),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // 關閉對話框
                                    },
                                    child: Text('取消',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 15.sp),),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async{
                                      Navigator.of(context).pop(); // 關閉對話框
                                      //先確認是否已送出
                                      bool check = await check_DAILY_MT_db_sub(TYPE: "POV");

                                      if(check==false){
                                        dev.log('聯絡簿已送出');
                                        add_DAILY_MT_db_sub(TYPE: "POV");
                                      }
                                      else{
                                        dev.log('聯絡簿已送出');
                                        SmartDialog.showToast("聯絡簿已送出");
                                      }

                                    },
                                    child: Text('確定',textScaler: const TextScaler.linear(1),style: TextStyle(color: Colors.black,fontSize: 15.sp),),
                                  ),
                                ],
                              );
                            },
                          );

                        }


                      },
                      columns: 4,
                      itemWidth: 72,
                      itemHeight: 72,
                      specialItems:specialItems
                  );


                },
                child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1), // changes position of shadow
                        ),
                      ],
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: Center(child:Icon(color: Colors.white,Icons.add,size: 30.sp,),))),
            mainScreenWidget:Scaffold(
            appBar: CustomAppBar(
                backgroundColor: Color(0xffF9AA88),
                toolbarHeight:42.h,
                leading: GestureDetector(
                    onTap: (){
                      //MyHomePage2_U_fun1!();
                      Navigator.pop(context);
                    },
                    child:Icon(Icons.arrow_back,size: 30.w,)),
                centerTitle: false,
                actions: [

                  /*
                  GestureDetector(
                      onTap: (){


                        if(EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.cUSTOMER_DL==null){
                           EasyLoading.showInfo("尚未建立家長資訊");
                        }
                        else{
                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ChatPage_T()));
                        }

                      },
                      child: Text("即時訊息", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.white , fontSize: 16.sp))),

                   */
                  Container(width: 10.w,)
                  /*
                  PopupMenuButton<String>(
                    onSelected: (String value) {
                      switch (value) {
                        case '成長曲線基準':
                          showModalBottomSheet(
                              backgroundColor: Colors.white,
                              isScrollControlled:true,
                              context: context,
                              builder: (BuildContext context) {
                                showModalBottomSheet_GROWING_STANDARD_context = context;
                                return StatefulBuilder(
                                    builder: (BuildContext context, showModalBottomSheet_image_setState){
                                      this.showModalBottomSheet_GROWING_STANDARD_setState =
                                          showModalBottomSheet_image_setState;
                                      return Column(children: [

                                        Container(height: 45.h,),
                                        Row(children: [
                                          Expanded(child: Container()),
                                          GestureDetector(
                                              onTap:(){
                                                Navigator.pop(showModalBottomSheet_GROWING_STANDARD_context);
                                              },
                                              child: Icon(Icons.cancel_outlined,size: 30.sp,color: Colors.black,)),
                                          Container(width: 20.w,),
                                        ],),
                                        Container(height: 10.h,),
                                        Text("衛服部幼兒發展數據",softWrap: true,textAlign: TextAlign.start,style: TextStyle(
                                            fontFamily: "GenJyuuGothic",
                                            fontWeight: FontWeight.normal,
                                            fontSize: 20.sp,
                                            color: Colors.lightBlue)),
                                        Container(height: 10.h,),
                                        Expanded(child: Container(child: Column(children: [

                                          Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                                borderRadius: BorderRadius.circular(5.w),
                                              ),
                                              //width: 80.w,
                                              height: 36.h,
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  items: GROWING_STANDARD_TYPE
                                                      .map((String item) => DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item.split("-").last,
                                                      style: TextStyle(
                                                        fontSize: 18.sp,
                                                        fontWeight: FontWeight.bold,
                                                        color: const Color(0xff555555),
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                                      .toList(),
                                                  value: sel_GROWING_STANDARD_TYPE,
                                                  onChanged: (value) {

                                                    Male_salesDatas_h.clear();
                                                    Female_salesDatas_h.clear();
                                                    Male_salesDatas_l.clear();
                                                    Female_salesDatas_l.clear();
                                                    sel_GROWING_STANDARD_TYPE = value!;

                                                    for(int i=0;i<GROWING_STANDARDs.length;i++){
                                                      if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="M"){
                                                        Male_salesDatas_h.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_H)));
                                                        Male_salesDatas_l.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_L)));
                                                      }
                                                      if(sel_GROWING_STANDARD_TYPE.contains("${GROWING_STANDARDs[i].TYPE}") && "${GROWING_STANDARDs[i].SEX}"=="F"){
                                                        Female_salesDatas_h.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_H)));
                                                        Female_salesDatas_l.add(SalesData(MONTH:GROWING_STANDARDs[i].MONTH,DATA:double.parse(GROWING_STANDARDs[i].DATA_L)));
                                                      }
                                                    }

                                                    Male_salesDatas_h.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Male_salesDatas_l.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Female_salesDatas_h.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    Female_salesDatas_l.sort((a, b) => int.parse(a.MONTH).compareTo(int.parse(b.MONTH)));
                                                    showModalBottomSheet_GROWING_STANDARD_setState(() {

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
                                          Expanded(child: SfCartesianChart(

                                              primaryXAxis: CategoryAxis(
                                                  title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              primaryYAxis: CategoryAxis(
                                                  title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              // Chart title
                                              title: ChartTitle(text: '男生',textStyle: TextStyle(fontSize: 20.sp)),
                                              // Enable legend
                                              legend: Legend(isVisible: true),
                                              // Enable tooltip
                                              tooltipBehavior: _tooltipBehavior,

                                              series: <LineSeries<SalesData, String>>[
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_h.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據上限",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Male_salesDatas_l.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  name: "數據下限",
                                                )
                                              ]
                                          )),
                                          Container(height: 20.h,),
                                          Expanded(child: SfCartesianChart(


                                              primaryXAxis: CategoryAxis(
                                                  title:AxisTitle(text:"月齡",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              primaryYAxis: CategoryAxis(
                                                  title:AxisTitle(text:sel_GROWING_STANDARD_TYPE.contains("頭圍")?"公分":sel_GROWING_STANDARD_TYPE.contains("身高")?"公分":" 體重",textStyle: TextStyle(fontSize: 14.sp))
                                              ),
                                              // Chart title
                                              title: ChartTitle(text: '女生',textStyle: TextStyle(fontSize: 20.sp)),
                                              // Enable legend
                                              legend: Legend(isVisible: true),
                                              // Enable tooltip
                                              tooltipBehavior: _tooltipBehavior,

                                              series: <LineSeries<SalesData, String>>[
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_h.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據上限",
                                                ),
                                                LineSeries<SalesData, String>(
                                                  dataSource:  Female_salesDatas_l.toList(),
                                                  xValueMapper: (SalesData sales, _) => sales.MONTH,
                                                  yValueMapper: (SalesData sales, _) => sales.DATA,
                                                  // Enable data label
                                                  dataLabelSettings: DataLabelSettings(isVisible: true),
                                                  //xAxisName: "月齡",
                                                  //yAxisName: "數據",
                                                  name: "數據下限",
                                                )
                                              ]
                                          )),
                                          Container(height: 20.h,),

                                        ],))),


                                      ],);
                                    });

                              });

                          resd_GROWING_STANDARD_db_sub();
                          break;
                        case '手動補點名':

                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: ADD_ROLLCALL_page()));

                          break;

                        case '健康紀錄':

                          Navigator.push(context, PageTransition(
                              type: PageTransitionType.rightToLeft, child: GROWING_T_page()));

                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return {'手動補點名', '成長曲線基準',"健康紀錄"}.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice,style: TextStyle(fontSize: 16.sp),),
                        );
                      }).toList();
                    },
                  ),

                  Container(width: 5.w,),

                   */
                ],
                title: Row(children: [

                  Text("${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                  Container(width: 5.w,),
                  Column(children: [
                    Container(height: 5.h,),
                    Text("${birthday}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.white , fontSize: 14.sp)),
                  ],),

                ],)
            ),
            body: Stack(
                children: [

                  EasyRefresh(
                      header: ClassicHeader(
                        showText: false,
                        textStyle:TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w400,color: Colors.black , fontSize: 14.sp),
                        messageStyle:TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w400,color: Colors.black , fontSize: 14.sp),
                      ),
                      fit:StackFit.expand,
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 1));

                        //檢查有無用藥委託
                        await read_DRUG_MT_db_sub(datetime: dateTime,CS_NO: "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}");//先確定圖片流水號

                        //檢查有無點名紀錄
                        await ROLLCALL_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

                        //檢查有無委託接送
                        await ENTRUSTED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

                        //檢查有無請假
                        await EXCUSED_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

                        //檢查聯絡簿
                        await read_for_DAILY_PRS_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");

                        //生活概況時序查詢表(範例)
                        await read_View_DAILY_db_sub(
                            datetime: dateTime,
                            CS_NO: "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",
                            timeout:30
                        );


                      },
                      child:
                      ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        children: [

                          /*
                            GestureDetector(
                                onTap: (){
                                  DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      currentTime:dateTime,
                                      minTime: DateTime.now().subtract(Duration(days: 365)),
                                      maxTime: DateTime.now().add(Duration(days: 30)), onChanged: (date) {
                                        print('change $date');
                                      }, onConfirm: (date) {

                                        dateTime=date;
                                        print('confirm $date');
                                        init();

                                      },locale: LocaleType.tw);
                                },
                                child:
                                Container(
                                    color: Color(0x01000000),
                                    padding: EdgeInsets.only(left:10.w,right: 10.w),
                                    width: ScreenUtil().screenWidth,height: 55.h,child: Row(children: [
                                  Text("${DateFormat("yyyy年MM月dd日").format(dateTime)} ${WEEK_DAY[dateTime.weekday-1]}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 18.sp)),
                                ],))),
                            Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                             */

                          //用藥委託
                          (dRUG_MTs.isEmpty)?Container():
                          Column(children: dRUG_MTs.map((e){

                            dev.log("e.DATETIME=${e.DATETIME}");
                            String timeOfDay = DateFormat('ahh:mm').format(DateTime.parse(e.DATETIME));
                            timeOfDay = timeOfDay.replaceAll("AM", "上午");
                            timeOfDay = timeOfDay.replaceAll("PM", "下午");

                            return Column(children: [
                              GestureDetector(
                                  onTap: (){

                                    dev.log("用藥委託");
                                    dRUG_MT = e;
                                    Navigator.push(context, PageTransition(
                                        type: PageTransitionType.rightToLeft, child: DRUG_MT_T_page()));

                                  },
                                  child: Container(
                                      color: Colors.white,
                                      padding: EdgeInsets.only(left:10.w,right: 0.w,bottom: 20.h,top: 20.h),
                                      width: ScreenUtil().screenWidth,child: Row(children: [

                                    Container(
                                      width:30.w,
                                      height: 30.w,
                                      padding: EdgeInsets.all(4.w),
                                      child: SvgPicture.asset("assets/images/组 29164-2.svg",),),
                                    Container(width: 12.w,),
                                    Expanded(child:
                                    Row(children: [
                                      Text("用藥委託", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.red , fontSize: 20.sp)),
                                      Container(width: 12.w,),
                                      Expanded(child:Text("${e.REASON}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.black , fontSize: 20.sp))),
                                    ],)),


                                    (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.TYPE.contains("2"))?
                                    Text("${timeOfDay}       ",
                                        style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.black54 , fontSize: 14.sp))
                                        :
                                    Container(),




                                  ],))),
                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                            ],);
                          }).toList()),

                          Column(children: entrusted_pick_and_drop_list.map((item){

                            dev.log("item.ADD_DATE=${item.ADD_DATE}");
                            String timeOfDay = DateFormat('ahh:mm').format(DateTime.parse(item.ADD_DATE));
                            timeOfDay = timeOfDay.replaceAll("AM", "上午");
                            timeOfDay = timeOfDay.replaceAll("PM", "下午");

                            //學校(DEPM)
                            DEPM _DEPM = dEPMs.firstWhere((element) => element.DEPM_NO==item.DEPM_NO);
                            CLASS _CLASS = cLASSs.firstWhere((element) => element.CLASS_NO==item.CLASS_NO);

                            //找出老師名字
                            EMPLOYEE eMPLOYEE = EMPLOYEE();
                            try{
                              eMPLOYEE = eMPLOYEEs.firstWhere((element) => element.EMP_NO==item.CFM_USER);
                            }
                            catch(e){

                            }


                            return Column(children: [


                              Container(
                                  width: ScreenUtil().screenWidth,
                                  //height: 55.w,
                                  //margin: EdgeInsets.only(bottom: 8.h),
                                  padding: EdgeInsets.all(5.w),
                                  color: Colors.white,
                                  child:Theme(
                                      data: ThemeData().copyWith(dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                          key: UniqueKey(),
                                          initiallyExpanded: item.isExpanded,
                                          onExpansionChanged: (v){
                                            item.isExpanded = v;
                                            setState(() {

                                            });
                                          },
                                          backgroundColor: Color(0xfffff6dc),
                                          iconColor: Color(0xff555555),
                                          collapsedIconColor: Color(0xff555555),
                                          tilePadding: EdgeInsets.only(left:5.w,right: 5.w,bottom: 0,top: 0),
                                          childrenPadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 10.h),
                                          title: Container(width: ScreenUtil().screenWidth,
                                            child: Column(children: [

                                              Row(children: [
                                                Container(
                                                  width:30.w,
                                                  height: 30.w,
                                                  padding: EdgeInsets.all(4.w),
                                                  child: SvgPicture.asset("assets/images/Icon fa-solid-car-side.svg",colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)),),
                                                Container(width: 12.w,),
                                                Container(
                                                  //width: ScreenUtil().screenWidth,
                                                    child: Text("委託接送",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.red , fontSize: 20.sp))),
                                                Expanded(child: Container()),
                                                (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.TYPE.contains("2"))?
                                                Text("${timeOfDay}       ",
                                                    style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.black54 , fontSize: 14.sp))
                                                    :
                                                Container(),
                                              ],),

                                            ],),),
                                          children:[

                                            Column(children: item.eNTRUSTED_DL_list.map((e) {
                                              ENTRUSTED_TYPE_ITEM? _ENTRUSTED_TYPE_ITEM;
                                              if(ENTRUSTED_TYPE_ITEM_list.length>0){
                                                _ENTRUSTED_TYPE_ITEM = ENTRUSTED_TYPE_ITEM_list.firstWhere((element) => element.ITEM_NO==e.TYPE_NO);
                                              }

                                              TimeOfDay? timeOfDay;
                                              List<String> t1 = e.TIME.split(":");
                                              try{
                                                timeOfDay = TimeOfDay(hour: int.parse(t1[0]),minute: int.parse(t1[1]));
                                              }
                                              catch(e){

                                              }


                                              return Container(width: ScreenUtil().screenWidth,child: Column(children: [
                                                Row(children: [
                                                  Text("${e.SR}.${_ENTRUSTED_TYPE_ITEM==null?"":_ENTRUSTED_TYPE_ITEM.ITEM_NM}",
                                                      maxLines: null,
                                                      style: TextStyle(
                                                          fontFamily: "GenJyuuGothic",
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 16.sp,
                                                          color: Color(0xff555555))),
                                                  Container(width: 5.w,),
                                                  Text("接送時間${(timeOfDay==null)?"":"${timeOfDay.period==DayPeriod.am?"上午":"下午"}${timeOfDay.hourOfPeriod}:${timeOfDay.minute.toString().padLeft(2,"0")}"}",
                                                      maxLines: null,
                                                      style: TextStyle(
                                                          fontFamily: "GenJyuuGothic",
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 16.sp,
                                                          color: Colors.blue)),
                                                ],),
                                              ],)
                                              );

                                            }).toList()),
                                            Container(height: 5.h,),
                                            Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                            Container(height: 5.h,),
                                            Row(children: [
                                              Text("代理人姓名:",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 16.sp,
                                                      color: Color(0xff555555))),
                                              Container(width: 5.w,),
                                              Text("${item.AGENT_NM}",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 16.sp,
                                                      color: Colors.blue)),
                                            ],),
                                            Container(height: 5.h,),
                                            Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                            Container(height: 5.h,),
                                            Row(children: [
                                              Text("代理人電話:",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 16.sp,
                                                      color: Color(0xff555555))),
                                              Container(width: 5.w,),
                                              Text("${item.AGENT_PHONE}",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 16.sp,
                                                      color: Colors.blue)),
                                            ],),
                                            Container(height: 5.h,),
                                            Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                            Container(height: 5.h,),
                                            Row(children: [
                                              Text("關係:",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 16.sp,
                                                      color: Color(0xff555555))),
                                              Container(width: 5.w,),
                                              Text("${item.RELATION}",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 16.sp,
                                                      color: Colors.blue)),
                                            ],),
                                            Container(height: 5.h,),
                                            Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                            Container(height: 5.h,),
                                            Row(children: [
                                              Text("說明:",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 16.sp,
                                                      color: Color(0xff555555))),
                                            ],),
                                            Row(children: [
                                              Expanded(child:
                                              Text("${item.NOTE}",
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
                                            Container(width: ScreenUtil().screenWidth,height: 200.h,child: Image.network(item.SIGN_LINK),),
                                            Container(height: 5.h,),
                                            Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                            Container(height: 5.h,),

                                            Container(width: ScreenUtil().screenWidth,child: Row(children: [

                                              Expanded(child: Column(children: [

                                                Row(children: [
                                                  Text("確認者:",
                                                      maxLines: null,
                                                      style: TextStyle(
                                                          fontFamily: "GenJyuuGothic",
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 16.sp,
                                                          color: Color(0xff555555))),
                                                  Container(width: 5.w,),
                                                  Text("${eMPLOYEE.EMP_NM}",
                                                      maxLines: null,
                                                      style: TextStyle(
                                                          fontFamily: "GenJyuuGothic",
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 16.sp,
                                                          color: Colors.blue)),
                                                ],),
                                                Container(height: 5.h,),
                                                Row(children: [
                                                  Text("確認日期時間:",
                                                      maxLines: null,
                                                      style: TextStyle(
                                                          fontFamily: "GenJyuuGothic",
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 16.sp,
                                                          color: Color(0xff555555))),
                                                  Container(width: 5.w,),
                                                  Text("${item.CFM_DT_str}",
                                                      maxLines: null,
                                                      style: TextStyle(
                                                          fontFamily: "GenJyuuGothic",
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 12.sp,
                                                          color: Colors.blue)),
                                                ],),
                                                Container(height: 5.h,),

                                              ],)),

                                              Container(
                                                  padding: EdgeInsets.only( left:0.w,right: 0.w),
                                                  width: 60.w,
                                                  height: 40.h,
                                                  child: ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor: MaterialStateProperty.all(Color(0xff48C2BC)),
                                                        surfaceTintColor: MaterialStateProperty.all(Color(0xff48C2BC)),
                                                        padding: MaterialStateProperty.all(EdgeInsets.all(0)),
                                                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                            RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(5.w),
                                                                side: BorderSide(color: Color(0xff555555))
                                                            )
                                                        )
                                                    ),
                                                    onPressed: () async{


                                                      write_ENTRUSTED_db_sub(
                                                          NO:"${item.NO}",
                                                          CFM_USER:EMPLOYEE_teacher.EMP_NO
                                                      );

                                                      /*
                                                        write_EXCUSED_db_sub(
                                                            NO:"${item.NO}",
                                                            CS_NO:"${item.CS_NO}",
                                                            CFM_NO:item.CFM_ITEM_selectedValue.CFM_NO,
                                                            CFM_USER:EMPLOYEE_teacher.EMP_NO
                                                        );

                                                         */



                                                    },
                                                    child: Row(children: [
                                                      Expanded(child: Container()),
                                                      Text('確認', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                                                      Expanded(child: Container()),
                                                    ],),
                                                  )),

                                            ],),),

                                            Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                            Container(height: 5.h,),


                                          ]))),
                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                            ],);


                          }).toList(),),

                          Column(children: EXCUSED_list.map((item){

                            dev.log("item.ADD_DATE=${item.ADD_DATE}");
                            String timeOfDay = DateFormat('ahh:mm').format(DateTime.parse(item.ADD_DATE));
                            timeOfDay = timeOfDay.replaceAll("AM", "上午");
                            timeOfDay = timeOfDay.replaceAll("PM", "下午");

                            //學校(DEPM)
                            DEPM _DEPM = dEPMs.firstWhere((element) => element.DEPM_NO==item.DEPM_NO);
                            CLASS _CLASS = cLASSs.firstWhere((element) => element.CLASS_NO==item.CLASS_NO);

                            EXCUSED_HOURS_ITEM _EXCUSED_HOURS_ITEM = EXCUSED_HOURS_ITEM();
                            if(EXCUSED_HOURS_ITEM_list.length>0) {
                              _EXCUSED_HOURS_ITEM = EXCUSED_HOURS_ITEM_list
                                  .firstWhere((element) =>
                              element.ITEM_NO == item.HOURS_NO);
                            }
                            EXCUSED_REASON_ITEM _EXCUSED_REASON_ITEM = EXCUSED_REASON_ITEM_list.firstWhere((element) => element.ITEM_NO==item.REASON_NO);
                            //CFM_ITEM CFM_ITEM_selectedValue = CFM_ITEM_list.firstWhere((element) => element.CFM_NO==EXCUSED_list[index].CFM_NO);

                            //老師名字
                            String teacher_name = "";
                            for(int i=0;i<eMPLOYEEs.length;i++){
                              if(eMPLOYEEs[i].EMP_NO==item.CFM_USER){
                                teacher_name = eMPLOYEEs[i].EMP_NM;
                                break;
                              }
                            }

                            String student_name = "";
                            for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
                              if(item.CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO){
                                student_name = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NM;
                                break;
                              }
                            }

                            return Column(children: [

                              Container(
                                  width: ScreenUtil().screenWidth,
                                  //height: 55.w,
                                  //margin: EdgeInsets.only(bottom: 8.h),
                                  color: Colors.white,
                                  padding: EdgeInsets.all(5.w),
                                  child:Theme(
                                      data: ThemeData().copyWith(dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                          key: UniqueKey(),
                                          initiallyExpanded: item.isExpanded,
                                          onExpansionChanged: (v){
                                            item.isExpanded = v;
                                            setState(() {

                                            });
                                          },
                                          backgroundColor: Color(0xfffff6dc),
                                          iconColor: Color(0xff555555),
                                          collapsedIconColor: Color(0xff555555),
                                          tilePadding: EdgeInsets.only(left:5.w,right: 5.w,bottom: 0,top: 0),
                                          childrenPadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 10.h),
                                          title: Container(width: ScreenUtil().screenWidth,
                                            child: Column(children: [

                                              Row(children: [
                                                Container(
                                                  width:30.w,
                                                  height: 30.w,
                                                  padding: EdgeInsets.all(4.w),
                                                  child: SvgPicture.asset("assets/images/Icon material-access-time.svg",colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn)),),
                                                Container(width: 12.w,),
                                                Text((_EXCUSED_REASON_ITEM==null)?"":"${_EXCUSED_REASON_ITEM.ITEM_NM}",
                                                    maxLines: null,
                                                    style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.red , fontSize: 20.sp)),
                                                Container(width: 10.w,),
                                                Text((_EXCUSED_HOURS_ITEM==null)?"":"${_EXCUSED_HOURS_ITEM.ITEM_NM}",
                                                    maxLines: null,
                                                    style: TextStyle(
                                                        fontFamily: "GenJyuuGothic",
                                                        fontWeight: FontWeight.w700,
                                                        color: Colors.red , fontSize: 20.sp)),

                                                Expanded(child: Container(),),
                                                (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.TYPE.contains("2"))?
                                                Text("${timeOfDay}       ",
                                                    style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.black54 , fontSize: 14.sp))
                                                    :
                                                Container(),
                                              ],),

                                            ],),),
                                          children:[

                                            Container(height: 5.h,),
                                            Row(children: [
                                              Text("說明:",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 16.sp,
                                                      color: Color(0xff555555))),
                                            ],),
                                            Row(children: [
                                              Expanded(child:
                                              Text("${item.NOTE}",
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
                                            Container(width: ScreenUtil().screenWidth,height: 200.h,child: Image.network(item.SING_LINK),),
                                            Container(height: 5.h,),
                                            Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                            Container(height: 5.h,),
                                            Row(children: [
                                              Text("確認者:",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14.sp,
                                                      color: Color(0xff555555))),
                                              Container(width: 5.w,),
                                              Text("${teacher_name}",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14.sp,
                                                      color: Colors.blue)),
                                              Expanded(child: Container()),

                                              Text("確認:",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14.sp,
                                                      color: Color(0xff555555))),
                                              Container(width: 5.w,),
                                              Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.grey),
                                                    borderRadius: BorderRadius.circular(5.w),
                                                  ),
                                                  //width: 80.w,
                                                  height: 36.h,
                                                  child:(item.CFM_ITEM_selectedValue.CFM_NO.isEmpty)?Container():
                                                  DropdownButtonHideUnderline(
                                                    child: DropdownButton2<CFM_ITEM>(
                                                      isExpanded: true,
                                                      items: CFM_ITEM_list
                                                          .map((CFM_ITEM item) => DropdownMenuItem<CFM_ITEM>(
                                                        value: item,
                                                        child: Text(
                                                          item.CFM_NM,
                                                          style: TextStyle(
                                                            fontSize: 16.sp,
                                                            fontWeight: FontWeight.bold,
                                                            color:Colors.blue,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ))
                                                          .toList(),
                                                      value: item.CFM_ITEM_selectedValue,
                                                      onChanged: (value) {

                                                        setState(() {
                                                          item.CFM_ITEM_selectedValue = value!;
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
                                              /*
                                                      Text((_CFM_ITEM==null)?"":"${_CFM_ITEM.CFM_NM}",
                                                          maxLines: null,
                                                          style: TextStyle(
                                                              fontFamily: "GenJyuuGothic",
                                                              fontWeight: FontWeight.w700,
                                                              fontSize: 16.sp,
                                                              color: Colors.blue)),

                                                       */
                                            ],),
                                            Container(height: 5.h,),
                                            Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                            Container(height: 5.h,),
                                            Row(children: [
                                              Text("確認日期時間:",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14.sp,
                                                      color: Color(0xff555555))),
                                              Container(width: 5.w,),
                                              Text((item.CFM_DT.isEmpty)?"":"${DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.parse(item.CFM_DT))}",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14.sp,
                                                      color: Colors.blue)),
                                            ],),
                                            Container(height: 5.h,),
                                            Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),
                                            Container(height: 5.h,),
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


                                                    write_EXCUSED_db_sub(
                                                        NO:"${item.NO}",
                                                        CS_NO:"${item.CS_NO}",
                                                        cFM_ITEM:item.CFM_ITEM_selectedValue,
                                                        CFM_USER:EMPLOYEE_teacher.EMP_NO
                                                    );



                                                  },
                                                  child: Row(children: [
                                                    Expanded(child: Container()),
                                                    Text('送出', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
                                                    Expanded(child: Container()),
                                                  ],),
                                                )),
                                            Container(height: 5.h,),

                                          ]))),

                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                            ]);


                          }).toList(),),

                          Column(children: ROLLCALL_list.map((e){

                            dev.log("(ROLLCALL_list)item.ADD_DATE=${e.ADD_DATE}");

                            String timeOfDay = DateFormat('ahh:mm').format(DateTime.parse(e.ADD_DATE));
                            timeOfDay = timeOfDay.replaceAll("AM", "上午");
                            timeOfDay = timeOfDay.replaceAll("PM", "下午");

                            return Slidable(
                              // Specify a key if the Slidable is dismissible.
                              //key: ValueKey(0),

                              // The end action pane is the one at the right or the bottom side.
                                endActionPane:  ActionPane(
                                  extentRatio:0.25,
                                  motion: ScrollMotion(),
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
                                                              onPressed: () {
                                                                Navigator.of(context).pop();

                                                              },
                                                            ),


                                                            TextButton(
                                                              child: Text('刪除',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                                              onPressed: () async{
                                                                Navigator.of(context).pop();
                                                                FocusManager.instance.primaryFocus?.unfocus();
                                                                SmartDialog.showLoading(msg: "處理中...");
                                                                await Future.delayed(const Duration(milliseconds: 500), () {});


                                                                await delete_ROLLCALL_db_sub(NO:e.NO);
                                                                MyHomePage2_T_fun4!(ROLLCALL_NO:e.NO);


                                                                //生活概況時序查詢表(範例)
                                                                //檢查有無點名紀錄
                                                                await ROLLCALL_db_sub(datetime: "${DateFormat('yyyy-MM-dd').format(dateTime)}");
                                                                SmartDialog.dismiss();
                                                                SmartDialog.showToast("處理成功");

                                                                setState(() {

                                                                });
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
                                    /*
                                          SlidableAction(
                                            onPressed: (c){

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
                                                                    onPressed: () {
                                                                      Navigator.of(context).pop();

                                                                    },
                                                                  ),


                                                                  TextButton(
                                                                    child: Text('刪除',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                                                    onPressed: () async{
                                                                      Navigator.of(context).pop();

                                                                      await EasyLoading.show(status: "處理中...");

                                                                      if(e.TYPE=="ACT"){
                                                                        await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_ACT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                      }
                                                                      else if(e.TYPE=="MLK"){
                                                                        await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_MLK_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                      }
                                                                      else if(e.TYPE=="POP"){
                                                                        await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_POP_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                      }
                                                                      else if(e.TYPE=="CLN"){
                                                                        await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_CLN_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                      }
                                                                      else if(e.TYPE=="CLS"){
                                                                        await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_CLS_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                      }
                                                                      else if(e.TYPE=="EAT"){
                                                                        await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_EAT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                      }
                                                                      else if(e.TYPE=="DRY"){
                                                                        await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_DRY_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                      }
                                                                      else if(e.TYPE=="TMP"){
                                                                        await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_TMP_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                      }
                                                                      else if(e.TYPE=="SLP"){
                                                                        await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_SLP_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                      }
                                                                      else if(e.TYPE=="RQD"){
                                                                        await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_RQD_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                      }
                                                                      else if(e.TYPE=="CND"){
                                                                        await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_CND_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                      }
                                                                      else if(e.TYPE=="NOT"){
                                                                        await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_NOT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                        await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                      }

                                                                      //生活概況時序查詢表(範例)
                                                                      await read_View_DAILY_db_sub(datetime: dateTime,CS_NO: "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}");
                                                                      EasyLoading.showSuccess("處理成功");

                                                                      setState(() {

                                                                      });
                                                                    },
                                                                  ),

                                                                ],
                                                              );
                                                            }));
                                                  });

                                            },
                                            backgroundColor: Color(0xFFFE4A49),
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            label: 'Delete',
                                          ),

                                           */
                                  ],
                                ),

                                // The child of the Slidable is what the user sees when the
                                // component is not dragged.
                                child: GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, PageTransition(
                                          type: PageTransitionType.rightToLeft, child: EDIT_ROLLCALL_page(dateTime:dateTime,rOLLCALL:e)));
                                    },
                                    child: Column(children: [

                                      Container(
                                          padding: EdgeInsets.only(left:15.w,right: 10.w,top: 10.h,bottom: 10.h),
                                          color: Colors.white,
                                          height:70.h,
                                          width: ScreenUtil().screenWidth,
                                          child: Column(children: [

                                            Expanded(child: Container()),
                                            Row(children: [
                                              (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.TYPE=="1")?
                                              Text("已點名，確認(${e.DateStr1.substring(e.DateStr1.length-2)})",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 18.sp,
                                                      color: Color(0xffE8885E)))
                                                  :
                                              Text("${e.DateStr1}",
                                                  maxLines: null,
                                                  style: TextStyle(
                                                      fontFamily: "GenJyuuGothic",
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 18.sp,
                                                      color: Color(0xffE8885E))),
                                              Expanded(child: Container()),
                                              (EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.TYPE.contains("2"))?
                                              Text("${timeOfDay}       ",
                                                  style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.black54 , fontSize: 14.sp))
                                                  :
                                              Container(),
                                            ],),
                                            Expanded(child: Container()),


                                          ],)),

                                      Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                                    ])));


                          }).toList(),),

                          Column(children: DAILY_PRSs.map((e){

                            //學校(DEPM)
                            DEPM _DEPM = DEPM();
                            CLASS _CLASS = CLASS();
                            try {
                              _DEPM = dEPMs.firstWhere((element) =>
                              element.DEPM_NO == e.DEPM_NO);
                              _CLASS = cLASSs.firstWhere((element) =>
                              element.CLASS_NO == e.CLASS_NO);
                            }
                            catch(e){

                            }

                            String student_name = "";
                            for(int i=0;i<EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs.length;i++){
                              if(e.CS_NO==EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NO){
                                student_name = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs[i].CS_NM;
                                break;
                              }
                            }

                            return Column(children: [

                              Container(
                                  width: ScreenUtil().screenWidth,
                                  //height: 55.w,
                                  //margin: EdgeInsets.only(bottom: 8.h),
                                  padding: EdgeInsets.all(5.w),
                                  decoration: BoxDecoration(
                                    color: e.isExpanded==false?Colors.white:Color(0xfffff6dc),
                                    borderRadius: BorderRadius.circular(0.w),
                                  ),
                                  child:Theme(
                                      data: ThemeData().copyWith(dividerColor: Colors.transparent),
                                      child: ExpansionTile(
                                          key: UniqueKey(),
                                          initiallyExpanded: e.isExpanded,
                                          onExpansionChanged: (v)async{
                                            e.isExpanded = v;
                                            setState(() {

                                            });

                                            if(e.STATUS!="老師已讀" && e.isExpanded==true){
                                              dev.log("聯絡簿上傳老師已讀");
                                              bool check = await updata_DAILY_PRS_db_sub(
                                                TYPE:e.TYPE,
                                                NO:e.NO,//編號
                                                STATUS:"老師已讀",//
                                              );
                                              if(check==true){
                                                e.STATUS="老師已讀";
                                                setState(() {

                                                });

                                                //2026/09/07,當老師已讀,更新is_STATUS狀態
                                                // 1. 尋找班級索引
                                                int classIndex = EMPLOYEE_teacher.Teacher_CUSTOMERs.indexWhere(
                                                      (tc) => tc.cLASS.CLASS_NO == EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.CLASS_NO,
                                                );

                                                if (classIndex != -1) {
                                                  var targetCustomers = EMPLOYEE_teacher.Teacher_CUSTOMERs[classIndex].cUSTOMERs;

                                                  // 2. 尋找學生索引
                                                  int studentIndex = targetCustomers.indexWhere(
                                                        (s) => s.CS_NO == EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO,
                                                  );

                                                  // 3. 更新狀態
                                                  if (studentIndex != -1) {
                                                    targetCustomers[studentIndex].is_STATUS = true;
                                                    EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.is_STATUS = true;
                                                  }

                                                  MyHomePage2_T_fun3!();

                                                }

                                              }
                                            }

                                          },
                                          backgroundColor: Color(0xfffff6dc),
                                          iconColor: Color(0xff555555),
                                          collapsedIconColor: Color(0xff555555),
                                          tilePadding: EdgeInsets.only(left:5.w,right: 5.w,bottom: 0,top: 0),
                                          childrenPadding: EdgeInsets.only(left:10.w,right: 10.w,bottom: 10.h),
                                          title: Container(width: ScreenUtil().screenWidth,
                                              child: Text("今日聯絡簿",textScaler: TextScaler.linear(1),style: TextStyle(
                                                  fontFamily: "GenJyuuGothic",
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.red , fontSize: 20.sp),)),
                                          children:[

                                            GestureDetector(
                                                behavior: HitTestBehavior.translucent,
                                                onTap:(){
                                                  e.REPLY_FocusNode.unfocus();
                                                },
                                                child: Column(children: [
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
                                                    Text("${e.NOTE}",
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

                                                  Container(height: 5.h,),
                                                  Row(children: [
                                                    Text("老師回覆:",
                                                        maxLines: null,
                                                        style: TextStyle(
                                                            fontFamily: "GenJyuuGothic",
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color: Color(0xff555555))),
                                                  ],),
                                                  Container(
                                                      color: Color(0xffEEEEEE),
                                                      padding: EdgeInsets.only(left:0.w,right: 0.w,top: 0.h,bottom: 5.h),
                                                      margin: EdgeInsets.only(left:0.w,right: 8.w,top: 0.h,bottom: 0.h),
                                                      width:ScreenUtil().screenWidth,child: Form(
                                                      child: TextFormField(
                                                        style: TextStyle(
                                                          fontSize: 20.sp,
                                                          color: Color(0xff555555),
                                                        ),
                                                        controller: e.REPLY_textEditingController,
                                                        focusNode: e.REPLY_FocusNode,
                                                        //textInputAction: TextInputAction.newline, // ✅ iOS 不要預設為「完成」
                                                        scrollPhysics: const NeverScrollableScrollPhysics(), // ✅ 禁止滾動
                                                        keyboardType: TextInputType.text,
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
                                                      ))),
                                                  Container(height: 3.h,),
                                                  Row(children: [

                                                    Expanded(child: Container()),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        // 按下按鍵要執行的動作

                                                        if(e.REPLY_textEditingController.text.isEmpty){
                                                          Fluttertoast.showToast(
                                                              msg: "請先輸入文字",
                                                              toastLength: Toast.LENGTH_SHORT,
                                                              gravity: ToastGravity.CENTER,
                                                              timeInSecForIosWeb: 1,
                                                              backgroundColor: Colors.red,
                                                              textColor: Colors.white,
                                                              fontSize: 16.0.sp
                                                          );
                                                          return;
                                                        }

                                                        showCupertinoDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return CupertinoAlertDialog(
                                                              title: Text('確定送出?',textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 16.sp),),
                                                              content: Text('${e.REPLY_textEditingController.text}',textAlign: TextAlign.left,textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 16.sp),),
                                                              actions: <Widget>[
                                                                CupertinoDialogAction(
                                                                  child: Text('取消',textScaler:const TextScaler.linear(1),style: TextStyle(fontSize: 16.sp),),
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop(); // 關閉 dialog
                                                                  },
                                                                ),
                                                                CupertinoDialogAction(
                                                                  isDestructiveAction: true,
                                                                  child: Text('送出',textScaler:const TextScaler.linear(1),style: TextStyle(color: Colors.blue,fontSize: 16.sp),),
                                                                  onPressed: () {
                                                                    Navigator.of(context).pop(); // 關閉 dialog
                                                                    // 執行送出動作
                                                                    write_REPLY_to_DAILY_PRS_db_sub(
                                                                      NO:e.NO,
                                                                      TYPE: e.TYPE,
                                                                      REPLY:e.REPLY_textEditingController.text,
                                                                      REPLY_USER_NO:EMPLOYEE_teacher.ACCOUNT,
                                                                    );

                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );

                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8), // 四角圓弧，數值越大越圓
                                                        ),
                                                        padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 8.h),
                                                        backgroundColor: Colors.blue, // 按鈕背景色
                                                        foregroundColor: Colors.white, // 文字顏色
                                                      ),
                                                      child: Text(
                                                        '送出',
                                                        textScaler: const TextScaler.linear(1),
                                                        style: TextStyle(fontSize: 16.sp),
                                                      ),
                                                    )

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
                                                  Container(width: ScreenUtil().screenWidth,height: 200.h,child: Image.network(e.SIGN_LINK),),
                                                  Container(height: 5.h,),
                                                ],)),


                                          ]))),
                              Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                            ]);


                          }).toList(),),

                          Container(width: ScreenUtil().screenWidth,child:
                          Column(children: view_DAILYs.map((e){

                            Color color = Colors.cyan;
                            var svg_icon;


                            if(e.TYPE=="ACT"){
                              color = Colors.cyan;
                              svg_icon = SvgPicture.asset("assets/images/Icon material-sports-handball.svg",color: color,);
                            }
                            else if(e.TYPE=="MLK"){
                              color = Colors.blueAccent;
                              svg_icon = SvgPicture.asset("assets/images/组 29134.svg",color: color,);
                            }
                            else if(e.TYPE=="POP"){
                              color = Colors.redAccent;
                              svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-poop.svg",color: color,);
                            }
                            else if(e.TYPE=="CLN"){
                              color = Colors.pinkAccent;
                              svg_icon = SvgPicture.asset("assets/images/Icon core-shower.svg",color: color,);
                            }
                            else if(e.TYPE=="CLS"){
                              color = Colors.green;
                              svg_icon = SvgPicture.asset("assets/images/Icon ion-shirt-sharp.svg",color: color,);
                            }
                            else if(e.TYPE=="EAT"){
                              color = Colors.orange;
                              svg_icon = SvgPicture.asset("assets/images/Icon material-food-bank.svg",color: color,);
                            }
                            else if(e.TYPE=="DRY"){
                              color = Colors.lightGreen;
                              svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-file-signature.svg",color: color,);
                            }
                            else if(e.TYPE=="TMP"){
                              color = Colors.deepPurpleAccent;
                              svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-temperature-full.svg",color: color,);
                            }
                            else if(e.TYPE=="SLP"){
                              color = Colors.lightBlueAccent;
                              svg_icon = SvgPicture.asset("assets/images/组 29166.svg",color: color,);
                            }
                            else if(e.TYPE=="RQD"){
                              color = Colors.purpleAccent;
                              svg_icon = SvgPicture.asset("assets/images/Icon fa-solid-basket-shopping.svg",color: color,);
                            }
                            else if(e.TYPE=="CND"){
                              color = Colors.amber;
                              svg_icon = SvgPicture.asset("assets/images/Icon ion-body-sharp.svg",color: color,);
                            }
                            else if(e.TYPE=="NOT"){
                              color = Colors.pink;
                              svg_icon = SvgPicture.asset("assets/images/Icon material-notifications-none-4.svg",color: color,);
                            }
                            else if(e.TYPE=="POV"){
                              color = Color(0xffC6A300);
                              svg_icon = Text("📒",textScaler: const TextScaler.linear(1),style: TextStyle(fontSize: 24.sp),);
                            }

                            List<String> t1 = e.TIME.split(":");
                            var timeOfDay = TimeOfDay(hour: int.parse(t1[0]),minute: int.parse(t1[1]));

                            String ITEM_NM="";
                            for(int i=0;i<DAILY_MT_TYPE_ITEMs.length;i++){
                              dev.log("${DAILY_MT_TYPE_ITEMs[i].ITEM_NO},${e.TYPE}");
                              if(DAILY_MT_TYPE_ITEMs[i].ITEM_NO==e.TYPE){
                                ITEM_NM = DAILY_MT_TYPE_ITEMs[i].ITEM_NM;
                                break;
                              }
                            }


                            return (e.TYPE=="PRS")?Container():
                            Slidable(
                              // Specify a key if the Slidable is dismissible.
                              //key: ValueKey(0),

                              // The end action pane is the one at the right or the bottom side.
                                endActionPane:  ActionPane(
                                  extentRatio:0.25,
                                  motion: ScrollMotion(),
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
                                                              onPressed: () {
                                                                Navigator.of(context).pop();

                                                              },
                                                            ),


                                                            TextButton(
                                                              child: Text('刪除',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                                              onPressed: () async{
                                                                Navigator.of(context).pop();
                                                                FocusManager.instance.primaryFocus?.unfocus();
                                                                SmartDialog.showLoading(msg: "處理中...");
                                                                await Future.delayed(const Duration(milliseconds: 500), () {});
                                                                if(e.TYPE=="ACT"){
                                                                  await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_ACT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                }
                                                                else if(e.TYPE=="MLK"){
                                                                  await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_MLK_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                }
                                                                else if(e.TYPE=="POP"){
                                                                  await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_POP_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                }
                                                                else if(e.TYPE=="CLN"){
                                                                  await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_CLN_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                }
                                                                else if(e.TYPE=="CLS"){
                                                                  await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_CLS_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                }
                                                                else if(e.TYPE=="EAT"){
                                                                  await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_EAT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                }
                                                                else if(e.TYPE=="DRY"){
                                                                  await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_DRY_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                }
                                                                else if(e.TYPE=="TMP"){
                                                                  await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_TMP_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                }
                                                                else if(e.TYPE=="SLP"){
                                                                  await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_SLP_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                }
                                                                else if(e.TYPE=="RQD"){
                                                                  await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_RQD_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                }
                                                                else if(e.TYPE=="CND"){
                                                                  await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_CND_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                }
                                                                else if(e.TYPE=="NOT"){
                                                                  await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_NOT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                }
                                                                else if(e.TYPE=="POV"){
                                                                  await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                }

                                                                //生活概況時序查詢表(範例)
                                                                await read_View_DAILY_db_sub(
                                                                    datetime: dateTime,
                                                                    CS_NO: "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}",
                                                                    timeout:30
                                                                );
                                                                SmartDialog.dismiss();
                                                                SmartDialog.showToast("處理成功");

                                                                setState(() {

                                                                });
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
                                    /*
                                      SlidableAction(
                                        onPressed: (c){

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
                                                                onPressed: () {
                                                                  Navigator.of(context).pop();

                                                                },
                                                              ),


                                                              TextButton(
                                                                child: Text('刪除',textScaleFactor: 1,style: TextStyle(fontSize: 16.sp),),
                                                                onPressed: () async{
                                                                  Navigator.of(context).pop();

                                                                  await EasyLoading.show(status: "處理中...");

                                                                  if(e.TYPE=="ACT"){
                                                                    await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_ACT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  }
                                                                  else if(e.TYPE=="MLK"){
                                                                    await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_MLK_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  }
                                                                  else if(e.TYPE=="POP"){
                                                                    await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_POP_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  }
                                                                  else if(e.TYPE=="CLN"){
                                                                    await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_CLN_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  }
                                                                  else if(e.TYPE=="CLS"){
                                                                    await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_CLS_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  }
                                                                  else if(e.TYPE=="EAT"){
                                                                    await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_EAT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  }
                                                                  else if(e.TYPE=="DRY"){
                                                                    await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_DRY_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  }
                                                                  else if(e.TYPE=="TMP"){
                                                                    await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_TMP_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  }
                                                                  else if(e.TYPE=="SLP"){
                                                                    await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_SLP_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  }
                                                                  else if(e.TYPE=="RQD"){
                                                                    await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_RQD_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  }
                                                                  else if(e.TYPE=="CND"){
                                                                    await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_CND_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  }
                                                                  else if(e.TYPE=="NOT"){
                                                                    await delete_DAILY_MT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_NOT_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                    await delete_DAILY_PIC_DL_db_sub(NO:e.NO,TYPE: e.TYPE);
                                                                  }

                                                                  //生活概況時序查詢表(範例)
                                                                  await read_View_DAILY_db_sub(datetime: dateTime,CS_NO: "${EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue.CS_NO}");
                                                                  EasyLoading.showSuccess("處理成功");

                                                                  setState(() {

                                                                  });
                                                                },
                                                              ),

                                                            ],
                                                          );
                                                        }));
                                              });

                                        },
                                        backgroundColor: Color(0xFFFE4A49),
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Delete',
                                      ),

                                       */
                                  ],
                                ),

                                // The child of the Slidable is what the user sees when the
                                // component is not dragged.
                                child: Column(children: [

                                  GestureDetector(
                                      onTap: (){

                                        dev.log("${e.TYPE}");

                                        if(e.TYPE=="ACT"){
                                          dev.log("編輯托嬰活動");
                                          Navigator.push(context, PageTransition(
                                              type: PageTransitionType.rightToLeft, child: Edit_DAILY_ACT_page(view_DAILY:e)));
                                        }
                                        else if(e.TYPE=="MLK"){
                                          dev.log("編輯[托嬰]飲食(餵奶)");
                                          Navigator.push(context, PageTransition(
                                              type: PageTransitionType.rightToLeft, child: Edit_DAILY_MLK_page(view_DAILY:e)));
                                        }
                                        else if(e.TYPE=="POP"){
                                          dev.log("編輯[托嬰]便便");
                                          Navigator.push(context, PageTransition(
                                              type: PageTransitionType.rightToLeft, child: Edit_DAILY_POP_page(view_DAILY:e)));
                                        }
                                        else if(e.TYPE=="CLN"){
                                          dev.log("編輯[托嬰/幼兒]洗澡 ");
                                          Navigator.push(context, PageTransition(
                                              type: PageTransitionType.rightToLeft, child: Edit_DAILY_CLN_page(view_DAILY:e)));
                                        }
                                        else if(e.TYPE=="CLS"){
                                          dev.log("編輯更換衣物");
                                          Navigator.push(context, PageTransition(
                                              type: PageTransitionType.rightToLeft, child: Edit_DAILY_CLS_page(view_DAILY:e)));
                                        }
                                        else if(e.TYPE=="EAT"){
                                          dev.log("編輯[托嬰/幼兒] 飲食(用餐) 副表  ");
                                          Navigator.push(context, PageTransition(
                                              type: PageTransitionType.rightToLeft, child: Edit_DAILY_EAT_page(view_DAILY:e)));
                                        }
                                        else if(e.TYPE=="DRY"){
                                          dev.log("編輯[托嬰/幼兒]日記 副表");
                                          Navigator.push(context, PageTransition(
                                              type: PageTransitionType.rightToLeft, child: Edit_DAILY_DRY_page(view_DAILY:e)));
                                        }
                                        else if(e.TYPE=="TMP"){
                                          dev.log("編輯[托嬰/幼兒]體溫");
                                          Navigator.push(context, PageTransition(
                                              type: PageTransitionType.rightToLeft, child: Edit_DAILY_TMP_page(view_DAILY:e)));
                                        }
                                        else if(e.TYPE=="SLP"){
                                          dev.log("編輯[托嬰/幼兒]睡覺 ");
                                          Navigator.push(context, PageTransition(
                                              type: PageTransitionType.rightToLeft, child: Edit_DAILY_SLP_page(view_DAILY:e)));
                                        }
                                        else if(e.TYPE=="CND"){
                                          dev.log("編輯[托嬰/幼兒]健康 生理狀況");
                                          Navigator.push(context, PageTransition(
                                              type: PageTransitionType.rightToLeft, child: Edit_DAILY_CND_page(view_DAILY:e)));
                                        }
                                        else if(e.TYPE=="NOT"){
                                          dev.log("編輯[托嬰/幼兒]  通知單(備註) 副表");
                                          Navigator.push(context, PageTransition(
                                              type: PageTransitionType.rightToLeft, child: Edit_DAILY_NOT_page(view_DAILY:e)));
                                        }
                                        else if(e.TYPE=="RQD"){
                                          Navigator.push(context, PageTransition(
                                              type: PageTransitionType.rightToLeft, child: Edit_DAILY_RQD_page(view_DAILY:e)));
                                        }

                                      },
                                      child: Container(
                                          color: Colors.white,
                                          padding: EdgeInsets.only(left:10.w,right: 10.w,top: 10.h,bottom: 10.h),
                                          width: ScreenUtil().screenWidth,child:
                                      Row(children: [

                                        Container(
                                          width:40.w,
                                          height: 40.w,
                                          padding: EdgeInsets.all(4.w),
                                          decoration: BoxDecoration(
                                              color: Colors.transparent,//Color(0xffEEE9E0),
                                              borderRadius: BorderRadius.circular(10.w),
                                              border: Border.all(
                                                width: 1,
                                                color: Colors.transparent,//Color(0xffEEE9E0),
                                              )),child: svg_icon,),
                                        Container(width: 12.w,),
                                        Expanded(child:
                                        Column(children: [

                                          Row(children: [
                                            Text("${ITEM_NM}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: color , fontSize: 20.sp)),
                                            (e.TYPE=="RQD")?
                                            Text("  (家長${e.RECIPIENT==false?"未讀":"已讀"})", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: e.RECIPIENT==false?Colors.red:Colors.blue , fontSize: 16.sp))
                                                :
                                            (e.TYPE=="NOT")?
                                            Text("  (家長${e.RECIPIENT==false?"未讀":"已讀"})", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: e.RECIPIENT==false?Colors.red:Colors.blue , fontSize: 16.sp))
                                                :
                                            Container(),
                                            Expanded(child:Container()),
                                            (e.TYPE=="TMP" || EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cLASS.TYPE.contains("2"))?
                                            Text("${timeOfDay.period==DayPeriod.am?"上午":"下午"}${timeOfDay.hourOfPeriod}:${timeOfDay.minute.toString().padLeft(2,"0")}       ",
                                                style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Colors.black54 , fontSize: 14.sp))
                                                :
                                            Container(),
                                            //Text('${"${timeOfDay.period==DayPeriod.am?"上午":"下午"}${timeOfDay.hourOfPeriod}:${timeOfDay.minute.toString().padLeft(2,"0")}"}', style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.normal,color: Colors.black54 , fontSize: 14.sp)),
                                          ],),
                                          Row(children: [
                                            Expanded(child:
                                            Text("${e.MARK}",
                                                style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: color , fontSize: 16.sp))),
                                          ],),

                                        ],)),

                                      ],))),
                                  Container(width: ScreenUtil().screenWidth,height: 1,color: Colors.grey,),

                                ],));



                          }).toList(),))



                        ],)),
                  // Loading 提示，覆蓋在 ListView 上
                  if (isLoading)Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children:  [
                              SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "載入中...",
                                style: TextStyle(fontSize: 14.sp,color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  Container(child: Column(children: [

                    Expanded(child: Container()),
                    Container(width: ScreenUtil().screenWidth,child: Row(children: [

                      Container(width: 10.w,),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0x01000000),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () {

                            if(isLoading == true){return;}

                            final list = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs;
                            final current = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue;

                            if (list.isEmpty) return;

                            int currentIndex = list.indexOf(current);

                            // 如果找不到目前項目，直接設成第一個
                            if (currentIndex == -1) {
                              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue = list.first;
                              init2();
                              return;
                            }

                            // 如果不是第一個，才往前一個
                            if (currentIndex > 0) {
                              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue = list[currentIndex - 1];
                              init2();
                            }
                            // 若 currentIndex == 0 → 不再改變（停在第一個）

                          },
                        ),
                      ),
                      Expanded(child: Container()),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0x01000000),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey, width: 2),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: () {

                            if(isLoading == true){return;}

                            final list = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.cUSTOMERs;
                            final current = EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue;

                            if (list.isEmpty) return;

                            int currentIndex = list.indexOf(current);

                            // 若找不到，預設為第一個
                            if (currentIndex == -1) {
                              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue = list.first;
                              init2();
                              return;
                            }

                            // 不是最後一個才往後移
                            if (currentIndex < list.length - 1) {
                              EMPLOYEE_teacher.Teacher_CUSTOMER_selectedValue.CUSTOMER_selectedValue = list[currentIndex + 1];
                              init2();
                            }

                          },
                        ),
                      ),
                      Container(width: 10.w,),

                    ],),),
                    Container(height: 100.h,),
                    Expanded(child: Container()),

                  ],),)

                ])


        )
        )));
  }
}


