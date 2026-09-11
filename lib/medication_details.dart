import 'dart:convert';
import 'dart:io';
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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:radio_group_v2/radio_group_v2.dart' as rg;
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

import 'utils/CustomAppBar.dart';

class MedicationDetails extends StatefulWidget {

  int index=-1;
  String mode="";
  MedicationDetails({int index=-1,String mode=""}){
    this.index = index;
    this.mode = mode;
  }

  @override
  State<MedicationDetails> createState() => MedicationDetailsState(index:this.index,mode:this.mode);
}

class MedicationDetailsState extends State<MedicationDetails> {

  TextEditingController DETAIL_textEditingController = TextEditingController();//藥品名稱
  TextEditingController DOSAGE_textEditingController = TextEditingController();//用量
  TextEditingController NOTE_textEditingController = TextEditingController();//說明
  DRUG_UNIT_ITEM? sel_DRUG_UNIT_ITEM_unit;//

  TimeOfDay? timeOfDay1 = TimeOfDay(hour: 9,minute: 0);
  TimeOfDay? timeOfDay2; //= TimeOfDay(hour: 12,minute: 0);
  TimeOfDay? timeOfDay3; // = TimeOfDay(hour: 18,minute: 0);

  var prescriptionsbytes_xfile;//藥品照片

  var showModalBottomSheet_image_context;

  List<String> _history = [];

  int index=-1;
  String mode="";
  MedicationDetailsState({int index=-1,String mode=""}){
    this.index = index;
    this.mode = mode;
  }

  BuildContext? this_context;

  @override
  void initState() {
    // TODO: implement initState

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();
    _loadHistory();

    init();
  }

  @override
  void dispose() {
    DETAIL_textEditingController.dispose();
    super.dispose();
  }

  /// 載入歷史紀錄
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList("drug_history") ?? [];
    });
  }

  /// 儲存歷史紀錄
  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("drug_history", _history);
  }

  /// 新增紀錄（避免重複）
  void _addToHistory(String value) {
    if (value.isEmpty) return;
    if (!_history.contains(value)) {
      setState(() {
        _history.insert(0, value); // 新的放最前面
      });
      _saveHistory();
    }
  }

  void init()async{

    await DRUG_STORE_ITEM_db_sub();
    await DRUG_UNIT_ITEM_db_sub();
    await DRUG_MODE_ITEM_db_sub();

    Future.delayed(const Duration(milliseconds: 100), () {

      if(index>-1){
        DETAIL_textEditingController.text = drug_reason.DRUG_DL_list[index].DETAIL.trim();
        DOSAGE_textEditingController.text = drug_reason.DRUG_DL_list[index].DOSAGE.trim();//DOSAGE
        NOTE_textEditingController.text = drug_reason.DRUG_DL_list[index].NOTE.trim();
        dev.log("${drug_reason.DRUG_DL_list[index].TIME1}");
        List<String> t1 = drug_reason.DRUG_DL_list[index].TIME1.split(":");
        timeOfDay1 = TimeOfDay(hour: int.parse(t1[0]),minute: int.parse(t1[1]));


        if(drug_reason.DRUG_DL_list[index].TIME2!=null && drug_reason.DRUG_DL_list[index].TIME2.toString().isNotEmpty){
          List<String> t2 = drug_reason.DRUG_DL_list[index].TIME2.split(":");
          timeOfDay2 = TimeOfDay(hour: int.parse(t2[0]),minute: int.parse(t2[1]));
        }
        if(drug_reason.DRUG_DL_list[index].TIME3!=null && drug_reason.DRUG_DL_list[index].TIME3.toString().isNotEmpty){
          List<String> t3 = drug_reason.DRUG_DL_list[index].TIME3.split(":");
          timeOfDay3 = TimeOfDay(hour: int.parse(t3[0]),minute: int.parse(t3[1]));
        }

        dev.log("drug_reason.DRUG_DL_list[index].DRUG_LINK:${drug_reason.DRUG_DL_list[index].DRUG_LINK}");
        dev.log("drug_reason.DRUG_DL_list[index].prescriptionsbytes_xfile:${drug_reason.DRUG_DL_list[index].prescriptionsbytes_xfile}");
        prescriptionsbytes_xfile = drug_reason.DRUG_DL_list[index].prescriptionsbytes_xfile;

        for(int i=0;i<DRUG_UNIT_ITEM_list.length;i++){
          if(DRUG_UNIT_ITEM_list[i].ITEM_NO=="${drug_reason.DRUG_DL_list[index].UNIT}"){
            sel_DRUG_UNIT_ITEM_unit = DRUG_UNIT_ITEM_list[i];
            break;
          }
        }

        dev.log("drug_reason.DRUG_DL_list[index].MODE:${drug_reason.DRUG_DL_list[index].MODE}");
        for(int i=0;i<dRUG_MODE.DRUG_MODE_ITEM_list.length;i++){
          dev.log("dRUG_MODE.DRUG_MODE_ITEM_list[i].ITEM_NO:${dRUG_MODE.DRUG_MODE_ITEM_list[i].ITEM_NO}");
          if(dRUG_MODE.DRUG_MODE_ITEM_list[i].ITEM_NO=="${drug_reason.DRUG_DL_list[index].MODE}"){
            dRUG_MODE.radioGroupController.selectAt(i);
            break;
          }
        }

        dev.log("drug_reason.DRUG_DL_list[index].STORE:${drug_reason.DRUG_DL_list[index].STORE}");
        for(int i=0;i<dRUG_STORE.DRUG_STORE_ITEM_list.length;i++){
          if(dRUG_STORE.DRUG_STORE_ITEM_list[i].ITEM_NO=="${drug_reason.DRUG_DL_list[index].STORE}"){
            dRUG_STORE.radioGroupController.selectAt(i);
            break;
          }
        }

        setState(() {

        });


      }


    });


  }


  /*
  DRUG_STORE_ITEM
   */
  Future<void>DRUG_STORE_ITEM_db_sub()async{

    dRUG_STORE.DRUG_STORE_ITEM_list.clear();
    String comm = "SELECT * FROM DRUG_STORE_ITEM";
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
        for(int j=0;j<data_list.length;j++){
          DRUG_STORE_ITEM ss = DRUG_STORE_ITEM();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          dRUG_STORE.DRUG_STORE_ITEM_list.add(ss);
        }
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
  DRUG_UNIT_ITEM
   */
  Future<void>DRUG_UNIT_ITEM_db_sub()async{

    DRUG_UNIT_ITEM_list.clear();
    String comm = "SELECT * FROM DRUG_UNIT_ITEM";
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
        for(int j=0;j<data_list.length;j++){
          DRUG_UNIT_ITEM ss = DRUG_UNIT_ITEM();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          DRUG_UNIT_ITEM_list.add(ss);
          if(j==0 && sel_DRUG_UNIT_ITEM_unit==null){
            sel_DRUG_UNIT_ITEM_unit = DRUG_UNIT_ITEM_list[0];
          }
        }

        dev.log("DRUG_UNIT_ITEM_list.length:${DRUG_UNIT_ITEM_list.length}");
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
  DRUG_MODE_ITEM
   */
  Future<void>DRUG_MODE_ITEM_db_sub()async{

    dRUG_MODE.DRUG_MODE_ITEM_list.clear();
    String comm = "SELECT * FROM DRUG_MODE_ITEM";
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
        for(int j=0;j<data_list.length;j++){
          DRUG_MODE_ITEM ss = DRUG_MODE_ITEM();
          ss.ITEM_NO = "${data_list[j]["ITEM_NO"]}";
          ss.ITEM_NM = "${data_list[j]["ITEM_NM"]}";
          dRUG_MODE.DRUG_MODE_ITEM_list.add(ss);
        }
      }

      setState(() {

      });

    }
    catch(e){
      dev.log("${e}");
      //EasyLoading.showInfo("錯誤:${e}");
    }
  }




  void showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // 禁止點擊外部關閉
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false, // 禁止返回鍵關閉
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3EB5B4), // 主體背景色（青綠色）
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "繼續新增下一筆明細",
                    textScaler: const TextScaler.linear(1),
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 是按鈕
                      ElevatedButton(
                        onPressed: () {
                          // 處理按下「是」的邏輯
                          Navigator.pop(context); // 關閉 dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shadowColor: Colors.black.withOpacity(0.2),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          "是",
                          textScaler: const TextScaler.linear(1),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      // 完成按鈕
                      ElevatedButton(
                        onPressed: () {
                          try{
                            dev.log("按下完成-1");
                            DRUG_MT_U_page_fun1!(); // 自行處理你的 function 呼叫
                            dev.log("按下完成-2");
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context); // 關閉 dialog
                            }
                            dev.log("按下完成-3");
                            if (Navigator.canPop(this_context!)) {
                              Navigator.pop(this_context!); // 關閉上一層 dialog（若有）
                            }
                            dev.log("按下完成-4");
                          }
                          catch(e){
                            dev.log("err:${e}");
                          }

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shadowColor: Colors.black.withOpacity(0.2),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          "完成",
                          textScaler: const TextScaler.linear(1),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {

    this_context = context;

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

                  _addToHistory(DETAIL_textEditingController.text);

                  /*
                  if(index==-1){

                    /*
                    if(DETAIL_textEditingController.text.isEmpty){
                      EasyLoading.showInfo("請輸入藥品名稱");
                      return;
                    }

                    if(dRUG_STORE.radioGroupController.selectedIndex<0){
                      EasyLoading.showInfo("請選擇用藥保存");
                      return;
                    }

                    if(dRUG_MODE.radioGroupController.selectedIndex<0){
                      EasyLoading.showInfo("請輸入用藥方式");
                      return;
                    }

                    if(DOSAGE_textEditingController.text.isEmpty){
                      EasyLoading.showInfo("請輸入用量");
                      return;
                    }

                     */

                    DRUG_DL dd = DRUG_DL();
                    dd.STORE = (dRUG_STORE.radioGroupController.selectedIndex<0)?"":"${dRUG_STORE.DRUG_STORE_ITEM_list[dRUG_STORE.radioGroupController.selectedIndex].ITEM_NO}";
                    dd.MODE = (dRUG_MODE.radioGroupController.selectedIndex<0)?"":"${dRUG_MODE.DRUG_MODE_ITEM_list[dRUG_MODE.radioGroupController.selectedIndex].ITEM_NO}";
                    dd.UNIT = sel_DRUG_UNIT_ITEM_unit!.ITEM_NO;
                    dd.NOTE = NOTE_textEditingController.text;
                    dd.DOSAGE = DOSAGE_textEditingController.text;
                    dd.DETAIL = DETAIL_textEditingController.text;
                    dd.prescriptionsbytes_xfile = prescriptionsbytes_xfile;
                    dd.TIME1 = "${timeOfDay1!.hour.toString().padLeft(2, '0')}:${timeOfDay1!.minute.toString().padLeft(2, '0')}:00";
                    dd.TIME2 = "${timeOfDay2!.hour.toString().padLeft(2, '0')}:${timeOfDay2!.minute.toString().padLeft(2, '0')}:00";
                    if(timeOfDay3!=null){
                      dd.TIME3 = "${timeOfDay3!.hour.toString().padLeft(2, '0')}:${timeOfDay3!.minute.toString().padLeft(2, '0')}:00";
                    }
                    else{
                      dd.TIME3 = null;
                    }
                    drug_reason.DRUG_DL_list.add(dd);
                  }
                  else{

                    dev.log("dRUG_MODE.radioGroupController.selectedIndex:${dRUG_MODE.radioGroupController.selectedIndex}");
                    drug_reason.DRUG_DL_list[index].STORE = (dRUG_STORE.radioGroupController.selectedIndex<0)?"":"${dRUG_STORE.DRUG_STORE_ITEM_list[dRUG_STORE.radioGroupController.selectedIndex].ITEM_NO}";
                    drug_reason.DRUG_DL_list[index].MODE = (dRUG_MODE.radioGroupController.selectedIndex<0)?"":"${dRUG_MODE.DRUG_MODE_ITEM_list[dRUG_MODE.radioGroupController.selectedIndex].ITEM_NO}";
                    drug_reason.DRUG_DL_list[index].UNIT = sel_DRUG_UNIT_ITEM_unit!.ITEM_NO;
                    drug_reason.DRUG_DL_list[index].NOTE = NOTE_textEditingController.text;
                    drug_reason.DRUG_DL_list[index].DOSAGE = DOSAGE_textEditingController.text;
                    drug_reason.DRUG_DL_list[index].DETAIL = DETAIL_textEditingController.text;
                    drug_reason.DRUG_DL_list[index].prescriptionsbytes_xfile = prescriptionsbytes_xfile;
                    dev.log("${timeOfDay1!.format(context)}");
                    drug_reason.DRUG_DL_list[index].TIME1 = "${timeOfDay1!.hour.toString().padLeft(2, '0')}:${timeOfDay1!.minute.toString().padLeft(2, '0')}:00";
                    drug_reason.DRUG_DL_list[index].TIME2 = "${timeOfDay2!.hour.toString().padLeft(2, '0')}:${timeOfDay2!.minute.toString().padLeft(2, '0')}:00";
                    if(timeOfDay3!=null){
                      drug_reason.DRUG_DL_list[index].TIME3 = "${timeOfDay3!.hour.toString().padLeft(2, '0')}:${timeOfDay3!.minute.toString().padLeft(2, '0')}:00";
                    }
                    else{
                      drug_reason.DRUG_DL_list[index].TIME3=null;
                    }

                  }

                  MyHomePage2_U_fun1!();
                  Navigator.pop(context);

                   */

                  Navigator.pop(context);

                },
                child:Icon(Icons.arrow_back,size: 30.w,)),
            centerTitle: true,
            actions: [
              GestureDetector(
                  onTap: (){



                    if(DETAIL_textEditingController.text.isEmpty){
                      Fluttertoast.showToast(
                          msg: "請輸入藥品名稱",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0.sp
                      );
                      return;
                    }

                    _addToHistory(DETAIL_textEditingController.text);


                    if(dRUG_STORE.radioGroupController.selectedIndex<0){
                      Fluttertoast.showToast(
                          msg: "請選擇用藥保存",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0.sp
                      );
                      return;
                    }

                    if(dRUG_MODE.radioGroupController.selectedIndex<0){
                      Fluttertoast.showToast(
                          msg: "請輸入用藥方式",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0.sp
                      );
                      return;
                    }

                    if(DOSAGE_textEditingController.text.isEmpty){
                      Fluttertoast.showToast(
                          msg: "請輸入用量",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0.sp
                      );
                      return;
                    }





                    if(index==-1){

                      if(prescriptionsbytes_xfile==null){
                        Fluttertoast.showToast(
                            msg: "請輸入明細照片",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0.sp
                        );
                        return;
                      }

                      DRUG_DL dd = DRUG_DL();
                      dd.STORE = (dRUG_STORE.radioGroupController.selectedIndex<0)?"":"${dRUG_STORE.DRUG_STORE_ITEM_list[dRUG_STORE.radioGroupController.selectedIndex].ITEM_NO}";
                      dd.MODE = (dRUG_MODE.radioGroupController.selectedIndex<0)?"":"${dRUG_MODE.DRUG_MODE_ITEM_list[dRUG_MODE.radioGroupController.selectedIndex].ITEM_NO}";
                      dd.UNIT = sel_DRUG_UNIT_ITEM_unit!.ITEM_NO;
                      dd.NOTE = NOTE_textEditingController.text;
                      dd.DOSAGE = DOSAGE_textEditingController.text;
                      dd.DETAIL = DETAIL_textEditingController.text;
                      dd.prescriptionsbytes_xfile = prescriptionsbytes_xfile;
                      dd.TIME1 = "${timeOfDay1!.hour.toString().padLeft(2, '0')}:${timeOfDay1!.minute.toString().padLeft(2, '0')}:00";
                      if(timeOfDay2!=null){
                        dd.TIME2 = "${timeOfDay2!.hour.toString().padLeft(2, '0')}:${timeOfDay2!.minute.toString().padLeft(2, '0')}:00";
                      }
                      else{
                        dd.TIME2 = null;
                      }
                      if(timeOfDay3!=null){
                        dd.TIME3 = "${timeOfDay3!.hour.toString().padLeft(2, '0')}:${timeOfDay3!.minute.toString().padLeft(2, '0')}:00";
                      }
                      else{
                        dd.TIME3 = null;
                      }
                      drug_reason.DRUG_DL_list.add(dd);

                      DETAIL_textEditingController.text="";//藥品名稱
                      DOSAGE_textEditingController.text = "";//用量
                      NOTE_textEditingController.text = "";//說明

                      timeOfDay1 = TimeOfDay(hour: 9,minute: 0);
                      timeOfDay2 = null;
                      timeOfDay3 = null;

                      prescriptionsbytes_xfile = null;//藥品照片
                      dRUG_STORE.radioGroupController = rg.RadioGroupController();
                      dRUG_MODE.radioGroupController = rg.RadioGroupController();
                      //sel_DRUG_UNIT_ITEM_unit=null;

                      setState(() {

                      });

                      showCustomDialog(context);

                    }
                    else{

                      dev.log("dRUG_MODE.radioGroupController.selectedIndex:${dRUG_MODE.radioGroupController.selectedIndex}");
                      drug_reason.DRUG_DL_list[index].STORE = (dRUG_STORE.radioGroupController.selectedIndex<0)?"":"${dRUG_STORE.DRUG_STORE_ITEM_list[dRUG_STORE.radioGroupController.selectedIndex].ITEM_NO}";
                      drug_reason.DRUG_DL_list[index].MODE = (dRUG_MODE.radioGroupController.selectedIndex<0)?"":"${dRUG_MODE.DRUG_MODE_ITEM_list[dRUG_MODE.radioGroupController.selectedIndex].ITEM_NO}";
                      drug_reason.DRUG_DL_list[index].UNIT = sel_DRUG_UNIT_ITEM_unit!.ITEM_NO;
                      drug_reason.DRUG_DL_list[index].NOTE = NOTE_textEditingController.text;
                      drug_reason.DRUG_DL_list[index].DOSAGE = DOSAGE_textEditingController.text;
                      drug_reason.DRUG_DL_list[index].DETAIL = DETAIL_textEditingController.text;
                      drug_reason.DRUG_DL_list[index].prescriptionsbytes_xfile = prescriptionsbytes_xfile;
                      dev.log("${timeOfDay1!.format(context)}");
                      drug_reason.DRUG_DL_list[index].TIME1 = "${timeOfDay1!.hour.toString().padLeft(2, '0')}:${timeOfDay1!.minute.toString().padLeft(2, '0')}:00";
                      if(timeOfDay2!=null){
                        drug_reason.DRUG_DL_list[index].TIME2 = "${timeOfDay2!.hour.toString().padLeft(2, '0')}:${timeOfDay2!.minute.toString().padLeft(2, '0')}:00";
                      }
                      else{
                        drug_reason.DRUG_DL_list[index].TIME2=null;
                      }
                      if(timeOfDay3!=null){
                        drug_reason.DRUG_DL_list[index].TIME3 = "${timeOfDay3!.hour.toString().padLeft(2, '0')}:${timeOfDay3!.minute.toString().padLeft(2, '0')}:00";
                      }
                      else{
                        drug_reason.DRUG_DL_list[index].TIME3=null;
                      }

                      DRUG_MT_U_page_fun1!();
                      Navigator.pop(context); // 關閉 dialog

                    }






                    

                  },
                  child: Text("完成", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp))),
              Container(width: 20.w,),
            ],
            title: Text("用藥明細", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.bold,color: Color(0xff292929) , fontSize: 20.sp)),
          ),
      body: //page 0
            ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [

          /*
          Container(
              margin: EdgeInsets.only(left:8.w,right: 8.w,top: 10.h,bottom: 10.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5.w),
              ),
              width:ScreenUtil().screenWidth,height: 36.h,child: Form(
              child: TextFormField(
                style: TextStyle(
                  fontSize: 20.sp,
                  color: Color(0xff555555),
                ),
                controller: DETAIL_textEditingController,
                keyboardType: TextInputType.text,
                inputFormatters: [
                  //RemoveEmojiInputFormatter()
                  SingleQuoteToFullQuoteFormatter(),
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
                  //drug_reason. = v;
                },
                decoration: InputDecoration(
                  filled: true, //<-- SEE HERE
                  fillColor: Colors.transparent, //<-- SEE HERE
                  hintText: '藥品名稱',
                  hintStyle: TextStyle(fontWeight: FontWeight.w400,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
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
              ))),

           */

            Container(
            margin: EdgeInsets.only(left:8.w,right: 8.w,top: 10.h,bottom: 10.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5.w),
          ),
          width:ScreenUtil().screenWidth,height: 36.h,child:
            TypeAheadField<String>(
              controller: DETAIL_textEditingController, // ✅ 直接給 controller
              suggestionsCallback: (pattern) async {
                if (pattern.isEmpty) return [];
                return _history
                    .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
                    .toList(); // ✅ 轉成 List
              },
              itemBuilder: (context, suggestion) {
                return ListTile(title: Text(suggestion));
              },
              onSelected: (suggestion) {
                DETAIL_textEditingController.text = suggestion;
              },
              builder: (context, controller, focusNode) {

                // ✅ 這裡用 TypeAhead 提供的 focusNode
                // 並在這裡加監聽器
                focusNode.addListener(() {
                  if (!focusNode.hasFocus) {
                    _addToHistory(controller.text);
                  }
                });

                return TextField(
                  controller: controller,
                  focusNode: focusNode, //
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    //RemoveEmojiInputFormatter()
                    SingleQuoteToFullQuoteFormatter(),
                  ],
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Color(0xff555555),
                  ),
                  decoration: InputDecoration(
                    filled: true, //<-- SEE HERE
                    fillColor: Colors.transparent, //<-- SEE HERE
                    hintText: '藥品名稱',
                    hintStyle: TextStyle(fontWeight: FontWeight.w400,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
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
                  onSubmitted: (value) {
                    _addToHistory(value);
                  },
                );
              },
            ),),
          Container(
            margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
            width: ScreenUtil().screenWidth,height: 1,color: Colors.grey[350],),
          Container(
              padding: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
              width: ScreenUtil().screenWidth,child: Text("用藥保存", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp))),
          Container(
            padding: EdgeInsets.only(left:8.w,right: 8.w,top: 5.h,bottom: 5.h),
            color: Colors.transparent,width: ScreenUtil().screenWidth,child: rg.RadioGroup(
            controller: dRUG_STORE.radioGroupController,
            values: dRUG_STORE.DRUG_STORE_ITEM_list.map((e) => "${e.ITEM_NM}").toList(),
            indexOfDefault: -1,
            orientation: rg.RadioGroupOrientation.horizontal,
            decoration: rg.RadioGroupDecoration(
              spacing: 10.0.w,
              labelStyle: TextStyle(
                color: Color(0xff555555),
                fontSize: 18.sp,
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.w400,
              ),
              activeColor: Color(0xffF9AA88),
            ),
          ),),
          Container(
            margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
            width: ScreenUtil().screenWidth,height: 1,color: Colors.grey[350],),
          Container(
              padding: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
              width: ScreenUtil().screenWidth,child: Text("用藥方式", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp))),
          Container(
            padding: EdgeInsets.only(left:8.w,right: 8.w,top: 5.h,bottom: 5.h),
            color: Colors.transparent,width: ScreenUtil().screenWidth,child: rg.RadioGroup(
            controller: dRUG_MODE.radioGroupController,
            values: dRUG_MODE.DRUG_MODE_ITEM_list.map((e) => "${e.ITEM_NM}").toList(),
            indexOfDefault: -1,
            orientation: rg.RadioGroupOrientation.horizontal,
            decoration: rg.RadioGroupDecoration(
              spacing: 10.0.w,
              labelStyle: TextStyle(
                color: Color(0xff555555),
                fontSize: 18.sp,
                fontFamily: "GenJyuuGothic",
                fontWeight: FontWeight.w400,
              ),
              activeColor: Color(0xffF9AA88),
            ),
          ),),
          Container(
            margin: EdgeInsets.only(left:8.w,right: 8.w,top: 0.h,bottom: 0.h),
            width: ScreenUtil().screenWidth,height: 1,color: Colors.grey[350],),
          Container(
            padding: EdgeInsets.only(left:8.w,right: 8.w,top: 10.h,bottom: 10.h),
            color: Colors.transparent,width: ScreenUtil().screenWidth,child: Row(children: [


              Text("用量:", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp)),
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.w),
                  ),
                  width: 80.w,
                  height: 36.h,child: Form(
                  child: TextFormField(
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Color(0xff555555),
                    ),
                    controller: DOSAGE_textEditingController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      //RemoveEmojiInputFormatter()
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                      DecimalTextInputFormatter(decimalRange: 2),
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
                      //drug_reason.reason = v;
                    },
                    decoration: InputDecoration(
                      filled: true, //<-- SEE HERE
                      fillColor: Colors.transparent, //<-- SEE HERE
                      hintText: '',
                      hintStyle: TextStyle(fontWeight: FontWeight.bold,fontFamily: "GenJyuuGothic",color:  Color(0xffB5B5B5),fontSize: 18.sp),
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
                  ))),
              Container(width: 2.w,),
              //Text("毫升/次", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp)),
              Expanded(child: Container()),
              Text("單位:", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp)),

              (sel_DRUG_UNIT_ITEM_unit==null)?Container():
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.w),
                ),
                //width: 80.w,
                height: 36.h,
                child: DropdownButtonHideUnderline(
              child: DropdownButton2<DRUG_UNIT_ITEM>(
                isExpanded: true,
                hint: Text(
                  '',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                items: DRUG_UNIT_ITEM_list
                    .map((DRUG_UNIT_ITEM item) => DropdownMenuItem<DRUG_UNIT_ITEM>(
                  value: item,
                  child: Text(
                    item.ITEM_NM,
                    style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.black
                    ),
                  ),
                ))
                    .toList(),
                value: sel_DRUG_UNIT_ITEM_unit,
                onChanged: (DRUG_UNIT_ITEM? value) {
                  setState(() {
                    sel_DRUG_UNIT_ITEM_unit = value;
                  });
                },
                buttonStyleData:  ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  height: 40.h,
                  width: 110.w,
                ),
                menuItemStyleData:  MenuItemStyleData(
                  height: 40.h,
                  selectedMenuItemBuilder: (c,w){
                    return Container(
                        color: Color(0xffFFDAC8),
                        child:Row(children: [

                      w,
                      Icon(Icons.check,size: 24.sp,),

                    ],));

                  }
                ),
              ),
            )),


          ],),),
          Container(
            padding: EdgeInsets.only(left:8.w,right: 8.w,top: 7.h,bottom: 7.h),
            color: Color(0xffFFDAC8),width: ScreenUtil().screenWidth,child:Row(children: [

            Text("在校用藥時間", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp)),
            Expanded(child: Container()),
            GestureDetector(
                onTap: (){
                  if(timeOfDay2==null) {
                    timeOfDay2 = TimeOfDay(hour: 12,minute: 0);
                  }
                  else if(timeOfDay3==null) {
                    timeOfDay3 = TimeOfDay(hour: 18, minute: 0);
                  }
                  setState(() {

                  });
                },
                child: Icon(Icons.add_circle_outline,size: 28.sp,color: Color(0xff292929),))

          ],)),
          Container(height: 5.h,),
          Container(
              padding: EdgeInsets.only(left:10.w,right: 10.w,top: 7.h,bottom: 7.h),
              width: ScreenUtil().screenWidth,child:Row(children: [


            Text("第1次", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp)),
            Container(width: 20.w,),
            GestureDetector(
                onTap: ()async{

                  /*
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

                   */

                  DateTime? datetime = await showHourRangeTimePicker(context, initialTime: DateTime.now());


                  if(datetime!=null){
                    timeOfDay1 = TimeOfDay.fromDateTime(datetime);
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
                    timeOfDay1 = _timeOfDay;
                  }
                  dev.log("${timeOfDay1!.format(context)}");

                  setState(() {

                  });

                   */

                },
                child: Container(width: 100.w,child:Text("${timeOfDay1!.period==DayPeriod.am?"上午":"下午"}${timeOfDay1!.hourOfPeriod}:${timeOfDay1!.minute.toString().padLeft(2,"0")}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w700,color: Colors.blue , fontSize: 18.sp)))),
            Expanded(child: Container()),
            //Text("給藥者簽名", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Colors.grey ,decoration: TextDecoration.underline, fontSize: 18.sp)),



          ],)),
          Container(
            margin: EdgeInsets.only(left:8.w,right: 8.w,top: 5.h,bottom: 5.h),
            width: ScreenUtil().screenWidth,height: 1,color: Colors.grey[350],),

          (timeOfDay2==null)?Container():
          Container(
              padding: EdgeInsets.only(left:10.w,right: 10.w,top: 7.h,bottom: 7.h),
              width: ScreenUtil().screenWidth,child:Row(children: [
            Text("第2次", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp)),
            Container(width: 20.w,),
              GestureDetector(
                onTap: ()async{

                  /*
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

                   */

                  DateTime? datetime = await showHourRangeTimePicker(context, initialTime: DateTime.now());
                  if(datetime!=null){
                    timeOfDay2 = TimeOfDay.fromDateTime(datetime);
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
                    timeOfDay2 = _timeOfDay;
                  }
                  dev.log("${timeOfDay2!.format(context)}");

                  setState(() {

                  });

                   */

                },
                child:Container(width: 100.w,child:
                Text("${timeOfDay2!.period==DayPeriod.am?"上午":"下午"}${timeOfDay2!.hourOfPeriod}:${timeOfDay2!.minute.toString().padLeft(2,"0")}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w700,color: Colors.blue , fontSize: 18.sp)))),
            Expanded(child: Container()),
            GestureDetector(onTap: (){
              timeOfDay2=null;
              setState(() {

              });
            },child:
            Icon(Icons.remove_circle,size: 24.sp,)),
            //Text("給藥者簽名", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Colors.grey ,decoration: TextDecoration.underline, fontSize: 18.sp)),



          ],)),

          Container(
            margin: EdgeInsets.only(left:8.w,right: 8.w,top: 5.h,bottom: 5.h),
            width: ScreenUtil().screenWidth,height: 1,color: Colors.grey[350],),

          (timeOfDay3==null)?Container():
          Container(
              padding: EdgeInsets.only(left:10.w,right: 10.w,top: 7.h,bottom: 7.h),
              width: ScreenUtil().screenWidth,child:Row(children: [



            Text("第3次", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp)),
            Container(width: 20.w,),
              GestureDetector(
                onTap: ()async{

                  /*
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

                   */

                  DateTime? datetime = await showHourRangeTimePicker(context, initialTime: DateTime.now());

                  if(datetime!=null){
                    timeOfDay3 = TimeOfDay.fromDateTime(datetime);
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
                    timeOfDay3 = _timeOfDay;
                  }
                  dev.log("${timeOfDay3!.format(context)}");

                  setState(() {

                  });

                   */

                },
                child:Container(width: 100.w,child:
                Text("${timeOfDay3!.period==DayPeriod.am?"上午":"下午"}${timeOfDay3!.hourOfPeriod}:${timeOfDay3!.minute.toString().padLeft(2,"0")}", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w700,color: Colors.blue , fontSize: 18.sp)))),
            Expanded(child: Container()),
            GestureDetector(onTap: (){
              timeOfDay3=null;
              setState(() {

              });
            },child:
            Icon(Icons.remove_circle,size: 24.sp,)),
            //Text("給藥者簽名", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Colors.grey ,decoration: TextDecoration.underline, fontSize: 18.sp)),



          ],)),

          Container(
            margin: EdgeInsets.only(left:8.w,right: 8.w,top: 5.h,bottom: 5.h),
            width: ScreenUtil().screenWidth,height: 1,color: Colors.grey[350],),
          Container(
            margin: EdgeInsets.only(left:8.w,right: 8.w,top: 5.h,bottom: 5.h),
            width: ScreenUtil().screenWidth,child: Row(children: [

              GestureDetector(
              onTap:(){
                showModalBottomSheet(
                context: context,
                builder: (
                BuildContext context) {
                showModalBottomSheet_image_context = context;
                  return Column(
                mainAxisSize: MainAxisSize
                    .min,
                children: <Widget>[
                ListTile(
                leading: Icon(Icons.photo_camera,size: 18.sp,),
                title: Text(
                "拍照",textScaleFactor: 1,style:TextStyle(fontSize: 18.sp)),
                onTap: () async {

                Navigator.pop(showModalBottomSheet_image_context!);

                XFile? imageFile;
                imageFile = await ImagePicker.ImagePicker().pickImage(source: ImagePicker.ImageSource.camera);


                if(imageFile!=null) {

                DateTime t = DateTime.now();
                Directory tempDir = await getTemporaryDirectory();
                var tempDirPath = tempDir.path;
                final myAppPath = '$tempDirPath/威寶通/Drug';
                final res = await Directory(myAppPath).create(recursive: true);
                String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                //var decodedImage = await imageFile.readAsBytes();
                //print(decodedImage.length);

                //壓縮image
                prescriptionsbytes_xfile = await FlutterImageCompress.compressAndGetFile(
                imageFile.path, filePath,
                  minWidth: FlutterImageCompress_width,
                  minHeight: FlutterImageCompress_height,
                  quality: FlutterImageCompress_quality,
                rotate: 0,
                );

                //var decodedImage2 = File(filePath).readAsBytesSync();
                //print(decodedImage2.length);

                //final path = xfile!.path;
                //final bytes = await File(path).readAsBytes();
                //image = img.decodeImage(bytes);



                setState(() {

                });

                }
                else
                {
                Navigator.pop(showModalBottomSheet_image_context!);
                }


                },
                ),
                ListTile(
                leading: Icon(Icons.photo_library,size: 18.sp,),
                title: Text(
                "相簿",textScaleFactor: 1,style:TextStyle(fontSize: 18.sp)),
                onTap: () async {

                Navigator.pop(showModalBottomSheet_image_context!);
                if (Platform.isAndroid) {





                PermissionStatus? status;

                final androidInfo = await DeviceInfoPlugin().androidInfo;
                if (androidInfo.version.sdkInt <= 32) {
                /// use [Permissions.storage.status]
                status = await Permission.storage.status;
                }  else {
                /// use [Permissions.photos.status]
                //print("test-1");
                status = await Permission.photos.status;
                //print("test-2");
                }



                //print("相簿-1${permission[Permission.WRITE_EXTERNAL_STORAGE]}");

                if( status.isGranted == false ) {

                //print("相簿-3");

                try {
                Map<Permission, PermissionStatus> statuses = await [
                (androidInfo.version.sdkInt <= 32)?Permission.storage:Permission.photos,
                ].request();
                } on Exception {
                //debugPrint("Error");
                }

                if (androidInfo.version.sdkInt <= 32) {
                /// use [Permissions.storage.status]
                status = await Permission.storage.status;
                }  else {
                /// use [Permissions.photos.status]
                status = await Permission.photos.status;
                }

                if( status.isGranted == true) {
                //print("Login ok");

                  PlatformFile? result = await FilePicker.pickFile(
                    //allowMultiple: false,
                    type: FileType.image,
                    //allowedExtensions: (Platform.isIOS)?null:['jpg','png','jpeg'],
                  );

                  if(result==null){
                    return;
                  }

                  var imageFile = result.xFile;

                if (imageFile !=
                null) {
                //print(
                //    "imageFile.lengthSync1():${imageFile
                //        .lengthSync()}");

                DateTime t = DateTime.now();
                Directory tempDir = await getTemporaryDirectory();
                var tempDirPath = tempDir.path;
                final myAppPath = '$tempDirPath/威寶通/Drug';
                final res = await Directory(myAppPath).create(recursive: true);
                String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                //壓縮image
                prescriptionsbytes_xfile = await FlutterImageCompress
                    .compressAndGetFile(
                imageFile.path, filePath,
                  minWidth: FlutterImageCompress_width,
                  minHeight: FlutterImageCompress_height,
                  quality: FlutterImageCompress_quality,
                rotate: 0,
                );

                setState(() {
                //_image = image;
                });
                }
                else {
                Navigator
                    .pop(
                showModalBottomSheet_image_context!);
                }

                }
                else {
                return;
                }

                }
                else{
                //print("相簿-2");
                  PlatformFile? result = await FilePicker.pickFile(
                    //allowMultiple: false,
                    type: FileType.image,
                    //allowedExtensions: (Platform.isIOS)?null:['jpg','png','jpeg'],
                  );

                  if(result==null){
                    return;
                  }

                  var imageFile = result.xFile;

                if (imageFile !=
                null) {
                //print(
                //    "imageFile.lengthSync1():${imageFile
                //        .lengthSync()}");

                DateTime t = DateTime.now();
                Directory tempDir = await getTemporaryDirectory();
                var tempDirPath = tempDir.path;
                final myAppPath = '$tempDirPath/威寶通/Drug';
                final res = await Directory(myAppPath).create(recursive: true);
                String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                //壓縮image
                prescriptionsbytes_xfile = await FlutterImageCompress
                    .compressAndGetFile(
                imageFile.path, filePath,
                  minWidth: FlutterImageCompress_width,
                  minHeight: FlutterImageCompress_height,
                  quality: FlutterImageCompress_quality,
                rotate: 0,
                );

                setState(() {

                });



                }
                else {
                Navigator
                    .pop(
                showModalBottomSheet_image_context!);
                }
                }




                }
                else {
                  PlatformFile? result = await FilePicker.pickFile(
                    //allowMultiple: false,
                    type: FileType.image,
                    //allowedExtensions: (Platform.isIOS)?null:['jpg','png','jpeg'],
                  );

                  if(result==null){
                    return;
                  }

                  var imageFile = result.xFile;

                if (imageFile !=
                null) {
                //print(
                //    "imageFile.lengthSync1():${imageFile
                //        .lengthSync()}");

                DateTime t = DateTime.now();
                Directory tempDir = await getTemporaryDirectory();
                var tempDirPath = tempDir.path;
                final myAppPath = '$tempDirPath/威寶通/Drug';
                final res = await Directory(myAppPath).create(recursive: true);
                String filePath = '${myAppPath}/${t.microsecondsSinceEpoch}.jpg';

                //壓縮image
                prescriptionsbytes_xfile = await FlutterImageCompress
                    .compressAndGetFile(
                imageFile.path, filePath,
                  minWidth: FlutterImageCompress_width,
                  minHeight: FlutterImageCompress_height,
                  quality: FlutterImageCompress_quality,
                rotate: 0,
                );


                setState(() {

                });


                setState(() {
                //_image = image;
                });
                }
                else {
                Navigator
                    .pop(
                showModalBottomSheet_image_context!);
                }



                }


                },
                ),
                ],
                );
                });
                },
              child: Container(width: 100.w,height: 100.h,color: Colors.grey,child: 
              Center(child:
              (mode=="編輯")?
              (prescriptionsbytes_xfile!=null)?Image.file(File(prescriptionsbytes_xfile!.path))
                  :
              (drug_reason.DRUG_DL_list[index].DRUG_LINK.isNotEmpty)?Image.network(drug_reason.DRUG_DL_list[index].DRUG_LINK,errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                  return Container();
              },)
                  :
              Icon(Icons.camera_alt,color: Colors.white,size: 60.sp)
                  :
              (prescriptionsbytes_xfile==null)?
              Icon(Icons.camera_alt,color: Colors.white,size: 60.sp)
                  :
                  Image.file(File(prescriptionsbytes_xfile!.path))
              ))),

              Expanded(child: Container(
                  height: 100.h,
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
                    controller: NOTE_textEditingController,
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
                  )))),

          ],),),

          /*
          Container(
              padding: EdgeInsets.only(left:10.w,right: 10.w,top: 7.h,bottom: 7.h),
              width: ScreenUtil().screenWidth,child:Row(children: [


                 Expanded(child:
                 Text("用藥前必須三讀五對。\n三讀：取藥時、用藥時、歸藥時必須核對。\n五對：藥名、病人名稱、用藥時間、用藥方式、劑量。", style: TextStyle(fontFamily: "GenJyuuGothic",fontWeight: FontWeight.w500,color: Color(0xff292929) , fontSize: 18.sp))),


          ],)),

           */


        ],),
    )));
  }
}
