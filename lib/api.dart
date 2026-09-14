import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'dart:developer' as dev;
import 'package:code3/sql.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mime/mime.dart';
import 'package:code3/custom_orientation_player/data_manager.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:radio_group_v2/radio_group_v2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signature/signature.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'FlexiblePageView_u.dart';

//[Apple Developer]
//chuyahao@icloud.com
//Hha53826282

//[Google]
//administrator@huaweidigi.com
//Ws53132022

/*
等級 帳號 密碼
Google_Teacher 老師 0999000001 0999000001
Google_Parents 家長 0999000002 0999000002

Apple_Teacher 老師 0999000010 0999000010
Apple_Parents 家長 0999000011 0999000011
 */

/*
接寶phone
測試帳號:0911222333
文字內容 : 企鵝班  王曉明  家長預計10分鐘內抵達

 */



const String IMAGE_IP = "https://www.tw-wilson.com";
//const String IMAGE_IP = "http://123.252.108.29";

List<STORY_LANGUAGE_ITEM> STORY_MENU = [];
STORY_LANGUAGE_ITEM? STORY_MENU_selectedValue;

//畫布長寬
double screen_width = 393;
double screen_height = 852;


bool DEBUG_MODE = false;//true:debug模式 , false:正常模式

//app store版本
int android_version = 246;
int ios_version = 246;


bool is_finish_load = false;

const APP_STORE_URL =
    'https://apps.apple.com/app/id6498993386';
const PLAY_STORE_URL =
    'https://play.google.com/store/apps/details?id=com.huaweidigi.app2';


//圖片壓縮
/*
quality: 100 → 最佳品質（最少壓縮，檔案最大）
quality: 80 → 一般建議值（品質佳且檔案較小）
quality: 50 → 中等品質（明顯壓縮痕跡，檔案更小）
quality: 10 → 非常低品質（馬賽克感明顯，檔案最小）
 */
const downloadImageCompress_quality = 100; //下載圖片品質

const blogFlutterImageCompress_quality = 75; //活動花絮上傳圖片品質
const FlutterImageCompress_quality = 20; //20%
const FlutterImageCompress_width = 1024; //
const FlutterImageCompress_height = 768; //

bool user_is_login = false;
bool in_chat = false;
bool is_login_main = false;



bool doNotShowToday = false;
bool isDialogShowing = false; // 全域 flag，避免重複顯示
Future<void> checkShouldShowDialog({BuildContext? context}) async {
  dev.log("isDialogShowing:${isDialogShowing}");
  if (isDialogShowing) return; // 如果 Dialog 正在顯示，直接跳過
  try{

    String comm='SELECT * FROM View_Notify_Active';
    String result = await sql_command("${comm}");
    dev.log("result:${result}");
    List<dynamic> data_list = jsonDecode(result);
    data_list = trim_proc(data_list);
    if(data_list.length>0){
      final prefs = await SharedPreferences.getInstance();
      final today = intl.DateFormat('yyyy-MM-dd').format(DateTime.now());
      final lastDismissDate = prefs.getString('lastDismissDate');

      if (lastDismissDate != today) {
        isDialogShowing = true; // 標記 Dialog 正在顯示
        await showMaintenanceDialog(context:context,TITLE:"${data_list[0]["TITLE"]}",DETAIL:"${data_list[0]["DETAIL"]}");
        isDialogShowing = false; // Dialog 關閉後，重置 flag
      }
    }
    else{
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastDismissDate', "");
    }
  }
  catch(e){

  }


}

Future<void> showMaintenanceDialog({BuildContext? context ,String TITLE="",String DETAIL=""}) async{
  if (context == null) return;

  await showDialog(
    context: context,
    barrierDismissible: false, // 點外面不能關閉
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white, // 👈 背景改成白色
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/marketing_138591121.png",width: 74.w,),
                SizedBox(height: 12.h),
                Text(
                  "${TITLE}",
                  textScaler: const TextScaler.linear(1),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff444B54),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  "${DETAIL}",
                  textScaler: const TextScaler.linear(1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: const Color(0xff444B54),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child:
                    Checkbox(
                      value: doNotShowToday,
                      onChanged: (value) {
                        setState(() {
                          doNotShowToday = value ?? false;
                        });
                      },
                    )),
                    Container(width: 5.w,),
                    Text("今日不再顯示",
                      textScaler: const TextScaler.linear(1),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: const Color(0xff444B54),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Center(
                child: Container(width: ScreenUtil().screenWidth,child:ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff444B54),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () async {
                    if (doNotShowToday) {
                      final prefs = await SharedPreferences.getInstance();
                      final today =
                      intl.DateFormat('yyyy-MM-dd').format(DateTime.now());
                      await prefs.setString('lastDismissDate', today);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(
                    "我知道了",
                    textScaler: const TextScaler.linear(1),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    ),),
                ),
              )),
            ],
          );
        },
      );
    },
  );
}



/// 將字串中的 Sp_ 拆成 'S'+'p_'，避免 SQL 防火牆誤判
String safeForSql(String input) {
  return input.replaceAll("Sp_", "' + N'S' + N'p_' + N'");
}

/// 一個簡約風格的 CheckBox：細邊框、圓角、淡色對勾、輕微過度動畫。
class MinimalCheckbox extends StatelessWidget {
  const MinimalCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 22,
    this.borderRadius = 6,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final primary = Colors.black; // 黑色主色調
    final borderColor = primary.withOpacity(enabled ? 1 : 0.4);

    return Semantics(
      checked: value,
      button: true,
      child: InkWell(
        onTap: enabled ? () => onChanged!(!value) : null,
        borderRadius: BorderRadius.circular(borderRadius + 4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.transparent, // ✅ 永遠透明
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(width: 1.4, color: borderColor),
          ),
          alignment: Alignment.center,
          child: AnimatedOpacity(
            opacity: value ? 1 : 0,
            duration: const Duration(milliseconds: 120),
            child: Icon(
              Icons.check_rounded,
              size: size * 0.68,
              color: primary, // 對勾也是黑色
            ),
          ),
        ),
      ),
    );
  }
}


/// 彈出一個自訂時間選單，時段限制在 [startHour] ~ [endHour]（含）。
/// 分鐘固定為 10 分鐘一格 (00, 10, 20, 30, 40, 50)。
Future<DateTime?> showHourRangeTimePicker(
    BuildContext context, {
      DateTime? initialTime,
      int startHour = 8,
      int endHour = 17,
      String title = '選擇時間',
      String cancelText = '取消',
      String confirmText = '確定',
    }) async {
  final now = DateTime.now();
  final init = initialTime ?? now;

  // clamp initial hour 到範圍內
  final initHourClamped = init.hour.clamp(startHour, endHour);

  // ✅ 分鐘只允許 00,10,20,30,40,50
  final minutes = List<int>.generate(6, (i) => i * 10);
  // 找最接近的初始分鐘
  int closestMinute = (init.minute ~/ 10) * 10;
  if (closestMinute >= 60) closestMinute = 50;

  final hours = List<int>.generate(endHour - startHour + 1, (i) => startHour + i);

  final initialHourIndex = hours.indexOf(initHourClamped);
  final initialMinuteIndex = minutes.indexOf(closestMinute);

  return await showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final hourController = FixedExtentScrollController(initialItem: initialHourIndex);
      final minuteController = FixedExtentScrollController(initialItem: initialMinuteIndex);

      return SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(12),
          ),
          height: 320,
          child: Column(
            children: [
              // Title 與按鈕列
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(null),
                      child: Text(cancelText),
                    ),
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () {
                        final h = hours[hourController.selectedItem];
                        final m = minutes[minuteController.selectedItem];
                        final picked = DateTime(init.year, init.month, init.day, h, m);
                        Navigator.of(ctx).pop(picked);
                      },
                      child: Text(confirmText),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // pickers
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: hourController,
                        itemExtent: 36,
                        diameterRatio: 1.2,
                        useMagnifier: true,
                        magnification: 1.05,
                        children: hours
                            .map((h) => Center(child: Text(h.toString().padLeft(2, '0'))))
                            .toList(),
                        onSelectedItemChanged: (_) {},
                      ),
                    ),

                    Container(width: 1, color: Colors.grey.shade200),

                    Expanded(
                      child: CupertinoPicker(
                        scrollController: minuteController,
                        itemExtent: 36,
                        diameterRatio: 1.2,
                        useMagnifier: true,
                        magnification: 1.05,
                        children: minutes
                            .map((m) => Center(child: Text(m.toString().padLeft(2, '0'))))
                            .toList(),
                        onSelectedItemChanged: (_) {},
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}



class SingleQuoteToFullQuoteFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // 組字中（中文拼音）就不處理，避免破壞注音輸入
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue;
    }

    final oldText = newValue.text;
    final newText = oldText.replaceAll("'", "’");

    final int diff = newText.length - oldText.length;
    final int newOffset = newValue.selection.baseOffset + diff;

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: newOffset.clamp(0, newText.length),
      ),
    );
  }
}
/*
class SingleQuoteToFullQuoteFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final newText = newValue.text.replaceAll("'", "’");
    final cursorOffset = newText.length - newValue.text.length + newValue.selection.baseOffset;

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
  }
}

 */


List<CUSTOMER> removeDuplicateCSNO(List<CUSTOMER> customers) {
  Set<String> seenCSNOs = {};
  List<CUSTOMER> uniqueCustomers = [];

  for (var customer in customers) {
    String csNo = customer.CS_NO ?? "";
    if (!seenCSNOs.contains(csNo)) {
      seenCSNOs.add(csNo);
      uniqueCustomers.add(customer);
    }
  }

  return uniqueCustomers;
}


/// 黑底九宮格選單
class CustomGridMenu extends StatefulWidget {
  final List<DAILY_MT_TYPE_ITEM> items;
  final Offset buttonOffset;
  final Size buttonSize;
  final VoidCallback onDismiss;
  final void Function(DAILY_MT_TYPE_ITEM) onSelected;
  final int columns;
  final double itemWidth;
  final double itemHeight;

  const CustomGridMenu({
    super.key,
    required this.items,
    required this.buttonOffset,
    required this.buttonSize,
    required this.onDismiss,
    required this.onSelected,
    this.columns = 3,
    this.itemWidth = 72,
    this.itemHeight = 72,
  });

  static Future<void> show({
    required BuildContext context,
    required List<DAILY_MT_TYPE_ITEM> gridItems,
    required List<DAILY_MT_TYPE_ITEM> specialItems,
    required Rect buttonRect,
    required void Function(DAILY_MT_TYPE_ITEM) onSelected,
    int columns = 3,
    double itemWidth = 72,
    double itemHeight = 72,
  }) async {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    const double spacing = 8;
    const double padding = 12;
    const double triangleHeight = 10;
    const double triangleWidth = 20;

    final screenSize = MediaQuery.of(context).size;
    final menuWidth = columns * itemWidth + (columns - 1) * spacing + padding * 2;

    final rowCount = (gridItems.length / columns).ceil();
    double gridHeight = rowCount * itemHeight + (rowCount - 1) * spacing;
    double specialHeight = specialItems.isNotEmpty ? itemHeight + spacing : 0;
    final menuHeight = gridHeight + padding * 2 + specialHeight;

    // 判斷要顯示在上或下
    bool showAbove = false;
    double top = buttonRect.bottom + triangleHeight;
    if (top + menuHeight > screenSize.height - 8) {
      showAbove = true;
      top = buttonRect.top - menuHeight - triangleHeight;
      if (top < 8) top = 8;
    }

    double idealLeft = buttonRect.left + buttonRect.width / 2 - menuWidth / 2;

    final double minLeft = 8.0;
    final double maxLeft = screenSize.width - menuWidth - 8.0;

    // 避免 maxLeft 小於 minLeft 導致 clamp 錯誤
    final double safeMaxLeft = maxLeft < minLeft ? minLeft : maxLeft;

    double left = idealLeft.clamp(minLeft, safeMaxLeft);

    double triangleLeft = buttonRect.left + buttonRect.width / 2 - triangleWidth / 2;

    entry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => entry.remove(),
        child: Stack(
          children: [
            // 三角形
            Positioned(
              left: triangleLeft,
              top: showAbove
                  ? top + menuHeight
                  : top,
              child: CustomPaint(
                size: Size(triangleWidth, triangleHeight),
                painter: TrianglePainter(
                  color: Colors.black87,
                  reverse: showAbove,
                ),
              ),
            ),

            // 選單主體
            Positioned(
              left: left,
              top: showAbove
                  ? top
                  : top + triangleHeight,

              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: menuWidth,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(padding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: gridItems.map((item) {
                          return _buildMenuItem(item, itemWidth, itemHeight, onSelected, entry);
                        }).toList(),
                      ),
                      if (specialItems.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: spacing),
                          child: Row(
                            children: List.generate(
                              specialItems.length * 2 - 1,
                                  (index) {
                                if (index.isEven) {
                                  final item = specialItems[index ~/ 2];
                                  return Expanded(
                                    child: _buildMenuItem(
                                      item,
                                      itemWidth,
                                      itemHeight,
                                      onSelected,
                                      entry,
                                    ),
                                  );
                                } else {
                                  return const SizedBox(width: 8); // 👈 這就是間隔
                                }
                              },
                            ),
                          ),
                        ),


                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(entry);
  }

  static Widget _buildMenuItem(
      DAILY_MT_TYPE_ITEM item,
      double itemWidth,
      double itemHeight,
      void Function(DAILY_MT_TYPE_ITEM) onSelected,
      OverlayEntry entry,
      ) {
    return GestureDetector(
      onTap: () {
        onSelected(item);
        entry.remove();
      },
      child: SizedBox(
        width: itemWidth,
        height: itemHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Center( // 👈 這一層可確保 Column 水平+垂直都置中
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (item.svg_icon==null)?Container():item.svg_icon,
              const SizedBox(height: 4),
              (item==null)?Container():Text(
                item.ITEM_NM,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ));
  }

  @override
  State<CustomGridMenu> createState() => _CustomGridMenuState();
}


class _CustomGridMenuState extends State<CustomGridMenu> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(); // 不會直接使用此widget build
  }
}


class TrianglePainter extends CustomPainter {
  final Color color;
  final bool reverse;
  TrianglePainter({required this.color, this.reverse = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();
    if (reverse) {
      path.moveTo(0, 0);
      path.lineTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}






class CustomPopupMenuEntry extends PopupMenuEntry<Null> {
  final Widget child;

  CustomPopupMenuEntry({required this.child});

  @override
  double get height => 0; // 不使用預設高度

  @override
  bool represents(void value) => false;

  @override
  State createState() => _CustomPopupMenuEntryState();
}

class _CustomPopupMenuEntryState extends State<CustomPopupMenuEntry> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

void showSaveSuccessToast() {
  SmartDialog.showToast(
    '', // 不用文字，使用自訂 widget
    alignment: Alignment.center, // ⭐ 顯示在頂部
    displayTime: Duration(seconds: 2),
    maskColor: Colors.transparent, // 背景透明
    builder: (_) => Container(
      margin: EdgeInsets.only(bottom: 80),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.green[600],
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: Colors.white, size: 24.sp),
          SizedBox(width: 10),
          Text(
            "儲存成功！",textScaler: const TextScaler.linear(1),
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
        ],
      ),
    ),
  );
}


double getWidthFactor(String sentCountStr, String answerCountStr) {
  double? sentCount = double.tryParse(sentCountStr);
  double? answerCount = double.tryParse(answerCountStr);
  double ratio = (sentCount==0)?0:(answerCount!/sentCount!).toDouble();
  dev.log("ratio:${ratio}");
  return ratio.clamp(0.0, 1.0);
}


Map<String, List<String>> buildColumnData(List<String> headers, List<List<String>> dataLists) {
  Map<String, List<String>> columnData = {};

  for (int i = 0; i < headers.length; i++) {
    if (i < dataLists.length) {
      columnData[headers[i]] = dataLists[i];
    } else {
      // 若缺資料則補空 List
      columnData[headers[i]] = [];
    }
  }

  return columnData;
}



List<List<String>> convertToTableRows(Map<String, List<String>> columnData) {
  // 找出最大資料列數
  int maxRows = columnData.values.fold(0, (max, list) => list.length > max ? list.length : max);

  // 第一列是標題列
  List<List<String>> tableRows = [
    columnData.keys.toList(),
  ];

  // 資料列
  for (int rowIndex = 0; rowIndex < maxRows; rowIndex++) {
    List<String> row = [];
    for (var key in columnData.keys) {
      List<String> col = columnData[key]!;
      row.add(rowIndex < col.length ? col[rowIndex] : '');
    }
    tableRows.add(row);
  }

  return tableRows;
}

class DynamicTableWidget extends StatelessWidget {
  final Map<String, List<String>> columnData;
  final TextStyle textStyle;

  const DynamicTableWidget({
    super.key,
    required this.columnData,
    this.textStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double screenWidth = constraints.maxWidth;

        // 最大資料列數
        int maxRows = columnData.values.fold(0, (prev, list) => list.length > prev ? list.length : prev);

        // 標題列
        List<String> headers = columnData.keys.toList();

        // 合併標題 + 資料列
        List<List<String>> tableRows = [];
        tableRows.add(headers);

        for (int i = 0; i < maxRows; i++) {
          List<String> row = [];
          for (var key in headers) {
            final values = columnData[key]!;
            row.add(i < values.length ? values[i] : '');
          }
          tableRows.add(row);
        }

        // 計算每欄最大寬度（包含標題列）
        List<double> columnWidths = List.filled(headers.length, 0.0);
        for (int col = 0; col < headers.length; col++) {
          double maxWidth = 0;
          for (var row in tableRows) {
            final text = row[col];
            final painter = TextPainter(
              text: TextSpan(text: text, style: textStyle),
              textDirection: TextDirection.ltr,
              maxLines: 1,
            )..layout();
            maxWidth = maxWidth < painter.width ? painter.width : maxWidth;
          }
          columnWidths[col] = maxWidth + 16; // padding
        }

        double totalTableWidth = columnWidths.reduce((a, b) => a + b);

        // 建立 Table
        Widget table = Table(
          columnWidths: {
            for (int i = 0; i < columnWidths.length; i++)
              i: FixedColumnWidth(columnWidths[i]),
          },
          border: TableBorder.all(color: Colors.grey),
          children: tableRows.asMap().entries.map((entry) {
            int rowIndex = entry.key;
            List<String> row = entry.value;
            return TableRow(
              decoration: BoxDecoration(
                color: rowIndex == 0 ? Colors.grey.shade300 : null,
              ),
              children: row
                  .map(
                    (cell) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(cell, style: textStyle),
                ),
              )
                  .toList(),
            );
          }).toList(),
        );

        return totalTableWidth > screenWidth
            ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: table)
            : Row(children: [Expanded(child: table)]);
      },
    );
  }
}


/// Captures the current screen and saves it as an image in the gallery.
Future<void> _saveScreen({String img_url=""}) async {

  dev.log("下載圖片:${img_url}");

  try {
    final response = await Dio().get(
      img_url,
      options: Options(responseType: ResponseType.bytes),
    );
    final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data),
        quality: downloadImageCompress_quality,
        isReturnImagePathOfIOS: true,
        name: "${DateTime.now().microsecondsSinceEpoch}");
    Fluttertoast.showToast(msg: "下載圖片成功\n${result["filePath"]}", toastLength: Toast.LENGTH_LONG);

  } catch (e) {
    Fluttertoast.showToast(msg: "下載圖片遇到錯誤", toastLength: Toast.LENGTH_LONG);
  }
}

void showImageViewer(BuildContext context, String image_url) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.all(8),
      child: Stack(
        children: [
          InteractiveViewer(
            child: Center(child: Image.network(image_url)),
          ),
          // 關閉按鈕
          Positioned(
            top: 12,
            right: 12,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.black,size: 30.sp,),
              onPressed: () => Navigator.pop(_),
            ),
          ),
          // 下載按鈕
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Color(0xffF9AA88),
              child: Icon(Icons.download, color: Colors.black),
              onPressed: () async {


                if(Platform.isAndroid){
                  if(await checkAndRequestPermissions(skipIfExists: true)==true){
                    _saveScreen(img_url:image_url);
                  }
                }
                else{
                  _saveScreen(img_url:image_url);
                }


              },
            ),
          ),
        ],
      ),
    ),
  );
}


bool iPad = false;
Future<bool> isTablet(BuildContext context) async {
  bool isTab = false;
  if (Platform.isIOS) {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    if(iosInfo.model.toLowerCase() == "ipad") {
      isTab = true;
    } else {
      isTab = false;
    }
    return isTab;
  } else {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    if(shortestSide > 600) {
      isTab = true;
    } else {
      isTab = false;
    }
    return isTab;
  }
}



class DecimalTextInputFormatter extends TextInputFormatter {
  final int integerRange;
  final int decimalRange;

  DecimalTextInputFormatter({
    this.integerRange = 3,
    this.decimalRange = 2,
  })  : assert(integerRange >= 0),
        assert(decimalRange >= 0);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String newText = newValue.text;

    if (newText.isEmpty) return newValue;

    final regex = RegExp(r'^\d{0,' +
        integerRange.toString() +
        r'}(?:\.\d{0,' +
        decimalRange.toString() +
        r'})?$');

    if (regex.hasMatch(newText)) {
      return newValue;
    }
    return oldValue;
  }
}

/*
Explanation:

For Android:
SDK 29+: Does not require read permission for writing files.
SDK 33+: Requires Permission.photos to check if a file exists.
SDK < 29: Requires Permission.storage for read and write operations.

For iOS:
Uses Permission.photos to check if a file exists.
Uses Permission.photosAddOnly for saving files without needing full photo library access.
 */
Future<bool> checkAndRequestPermissions({required bool skipIfExists}) async {
  if (!Platform.isAndroid && !Platform.isIOS) {
    return false; // Only Android and iOS platforms are supported
  }

  if (Platform.isAndroid) {
    final deviceInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = deviceInfo.version.sdkInt;

    if (skipIfExists) {
      // Read permission is required to check if the file already exists
      return sdkInt >= 33
          ? await Permission.photos.request().isGranted
          : await Permission.storage.request().isGranted;
    } else {
      // No read permission required for Android SDK 29 and above
      return sdkInt >= 29 ? true : await Permission.storage.request().isGranted;
    }
  } else if (Platform.isIOS) {
    // iOS permission for saving images to the gallery
    return skipIfExists
        ? await Permission.photos.request().isGranted
        : await Permission.photosAddOnly.request().isGranted;
  }

  return false; // Unsupported platforms
}





final RegExp regExp = RegExp(r'(?:[\u2700-\u27bf]|(?:\ud83c[\udde6-\uddff]){2}|[\ud800-\udbff][\udc00-\udfff]|[\u0023-\u0039]\ufe0f?\u20e3|\u3299|\u3297|\u303d|\u3030|\u24c2|\ud83c[\udd70-\udd71]|\ud83c[\udd7e-\udd7f]|\ud83c\udd8e|\ud83c[\udd91-\udd9a]|\ud83c[\udde6-\uddff]|\ud83c[\ude01-\ude02]|\ud83c\ude1a|\ud83c\ude2f|\ud83c[\ude32-\ude3a]|\ud83c[\ude50-\ude51]|\u203c|\u2049|[\u25aa-\u25ab]|\u25b6|\u25c0|[\u25fb-\u25fe]|\u00a9|\u00ae|\u2122|\u2139|\ud83c\udc04|[\u2600-\u26FF]|\u2b05|\u2b06|\u2b07|\u2b1b|\u2b1c|\u2b50|\u2b55|\u231a|\u231b|\u2328|\u23cf|[\u23e9-\u23f3]|[\u23f8-\u23fa]|\ud83c\udccf|\u2934|\u2935|[\u2190-\u21ff])');


/// Removing emoji in input text and remaining cursor index
/// Example: 'Hello, welcome to Flutter 😀!' => 'Hello, welcome to Flutter !'
class RemoveEmojiInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(regExp, "");
    return TextEditingValue(text: text);
  }
}

Future<void> setAdaptiveSystemUI(BuildContext context) async {
  //final brightness = Theme.of(context).brightness;
  //final bool isDarkMode = brightness == Brightness.dark;


  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //Set status bar
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,//isDarkMode ? Brightness.light : Brightness.dark,
    statusBarBrightness: Brightness.light,//isDarkMode ? Brightness.dark : Brightness.light,

    // Set navigation bar
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

}


String decodeUnicode(String input) {
  //  regex find all unicode escape sequences dạng \\u{xxxx}
  final RegExp regex = RegExp(r'\\u\{([A-Fa-f0-9]+)\}');

  // replace unicode sequenc
  return input.replaceAllMapped(regex, (match) {
    final hexCode = match.group(1);
    if (hexCode != null) {
      // convert from hex to character code
      final emoji = String.fromCharCode(int.parse(hexCode, radix: 16));
      return emoji;
    }
    return match.group(0)!;
  });
}




String convertStringToUnicode(String content) {
  String regex = "\\u";
  int offset = content.indexOf(regex) + regex.length;
  while(offset > 1){
    int limit = offset + 4;
    String str = content.substring(offset, limit);
//     print(str);
    if(str!=null && str.isNotEmpty){
      String uni = String.fromCharCode(int.parse(str,radix:16));


      content = content.replaceFirst(regex+str,uni);
//       print(content);

    }
    offset = content.indexOf(regex) + regex.length;
//     print(offset);
  }
  return content;

}


List<String> WEEK_DAY = [
  "週ㄧ",
  "週二",
  "週三",
  "週四",
  "週五",
  "週六",
  "週日",
];

/*
Map<String,dynamic> SORT =
  {
    "1":"活動消息",
    "2":"行事曆",
    "3":"食在健康",
    "4":"招生訊息",
    "5":"接送辦法",
    "6":"收費基準"
  };

 */

List<BULLETIN_SORT_ITEM> BULLETIN_SORT_ITEM_list = [];
class BULLETIN_SORT_ITEM{
  String SORT_ID="";
  String SORT_NM="";
  bool is_sel = false;
}


PackageInfo packageInfo = PackageInfo(
  appName: 'Unknown',
  packageName: 'Unknown',
  version: 'Unknown',
  buildNumber: 'Unknown',
  buildSignature: 'Unknown',
  installerStore: 'Unknown',
);


/*
管理者:A 學校主管:M  老師:T 家長:U  (RANK_ITEM)
 */
User user = User();
class User{
  String USER_NM="";//登入者姓名
  String DEPM_NO="";//幼兒園編號
  String DEPM_NM="";//幼兒園名稱
  String CLASS_NO="";//班級編號
  String CLASS_NM="";//班級名稱
  String CLASS_TY="";//班級類別
  String CLASS_TYNM="";//班級類別名稱
  String ACCOUNT="";//帳號(手機)
  String PASSWORD="";//密碼
  String RANK="";//等級(管理者:A 學校主管:M  老師:T 家長:U  (RANK_ITEM))
  String TOKEN_ID="";//通訊編號
  String KIDS_NO="";//幼兒編號
  String KIDS_NM="";//幼兒姓名
}


/*
公告欄 BULLETIN
 */
List<BULLETIN> BULLETIN_list = [];
class BULLETIN{
  String BLTN_NO="";//公告編號
  String TITLE="";//標題
  String DETAIL="";//內容
  String BLTN_DT="";//顯示日期
  String SORT_ID="";//分類
  String DEPM_NO="";//學校編號
  String NOTE="";//備註
  bool isExpanded = false;//app自定義(是否展開)
  List<BULLETIN_DL> BULLETIN_DL_list = [];
}

/*
公告欄子表單 BULLETIN_DL
 */
class BULLETIN_DL{
  String BLTN_NO="";//公告編號
  String BLTN_SR="";//序號
  String LINK="";//連結
  String NOTE="";//備註
}




/*
[托嬰/幼兒] 點名 ROLLCALL
 */
List<ROLLCALL> ROLLCALL_list = [];
class ROLLCALL{
  String NO="";//序號
  String DATE="";//日期
  String TIME="";//時間
  String DEPM_NO="";//學校
  String CLASS_NO="";//班級
  String CS_NO="";//學生
  String STATUS="";//狀態
  String DateStr="";//app自定義
  String DateStr1="";//app自定義
  String ADD_USER="";//app自定義
  String ADD_DATE="";//app自定義
  var timeOfDay;
  bool isExpanded = false;//app自定義(是否展開)
}


/*
生活花絮 BLOG
 */
List<BLOG> BLOG_list = [];
class BLOG{
  String BLOG_NO="";//生活花絮編號
  String TITLE="";//標題
  String DETAIL="";//內容
  String BLTN_DT="";//顯示日期
  String DEPM_NO="";//學校編號
  String CLASS_NO="";//班級編號
  String NOTE="";//備註
  bool isExpanded = false;//app自定義(是否展開)
  List<String> LINK=[];//照片儲存位置
  List<BLOG_DL> bLOG_DL = [];
  String BLTN_DT_str="";
}

class BLOG_DL{
  String BLOG_NO="";//生活花絮編號
  String BLOG_SR="";//序號
  String LINK="";//連結
  String NOTE="";//備註
  var prescriptionsbytes_xfile;//活動花絮圖片
  TextEditingController NOTE_textEditingController = TextEditingController();//備註
}


/*
故事繪本 STORY
 */
List<STORY> STORY_list = [];
class STORY{
  String NO="";//編號
  String TITLE="";//標題
  String NOTE="";//內容
  String COVER_LINK="";//照片
  String VIDEO_LINK="";//影片連結
  String LANGUAGE="";//語言
  String DEPM_NO="";//學校
  String ADD_DATE="";//
  bool isExpanded = false;//app自定義(是否展開)
  WebViewController? web_controller;
  FlickManager? flickManager;
  DataManager? dataManager;
  VideoPlayerController? videoPlayerController;
}

class STORY_LANGUAGE_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
問卷 SURVEY
 */
List<SURVEY> SURVEY_list = [];
class SURVEY{
  String NO="";//編號
  String TITLE="";//標題
  String TARGET="";//對象(全校: 1 全班: 2 特定人:3)
  String LINK="";//照片
  String ADD_USER="";//建立者
  String ADD_DATE="";//建立日期
  bool isExpanded = true;//app自定義(是否展開)
  List<SURVEY_DL> survey_dl_list=[];
  int total_num = 0;
  RadioGroupController myController = RadioGroupController();
  TextEditingController NOTE_textEditingController = TextEditingController();//
  String View_SURVEY_COUNTS_SentCount="";//送出數量
  String View_SURVEY_COUNTS_ReceivedCount="";//回復數量
  List<View_SURVEY_ANSWER_STATS> View_SURVEY_ANSWER_STATS_list = [];
}

/*
 通知單 副表
 */
class SURVEY_DL{
  String NO="";//編號
  String SR="";//序號
  String NOTE="";//說明
  int num = 0;
}

/*
已填寫過問卷 View_SURVEY
 */
List<View_SURVEY> View_SURVEY_list = [];
class View_SURVEY{
  String NO="";//編號
  String TITLE="";//標題
  String DEPM_NO="";//學校
  String TARGET="";//全校: 1 / 全班: 2 / 特定人:3 / 未發送:0
  String LINK="";//照片
  String ADD_USER="";//建立者
  String ADD_DATE="";//建立日期
  String SR="";//序號
  String ACCOUNT="";//家長電話(APP帳號)
  String ANSWER="";//選擇問卷答案
  String DATETIME="";//日期時間
  String NOTE="";//備註
  String KIDS_NO="";//學生編號
  String KIDS_NM="";//學生姓名
  String SURVEY_NM="";//問卷題目
  String CLASS_NO="";//
}


/*
View_SURVEY_SEND 是檢查是否已投票
 */
List<View_SURVEY_SEND> View_SURVEY_SEND_list = [];
class View_SURVEY_SEND{
  String NO="";//問卷編號
  String TITLE="";//問卷題目
  String DEPM_NO="";//學校
  String SR="";//發送序號
  String ACCOUNT="";//家長電話(APP帳號)
  String CS_NO="";//學生編號
  String CS_NM="";//學生姓名
  String CLASS_NO="";//班級編號
  String CompletionStatus="";//只顯示未完成
}



/*
[托嬰/幼兒]成長紀錄
 */
List<GROWING> GROWING_list = [];
List<GROWINGs> gROWINGs = [];
class GROWINGs{
  String DATE="";//日期
  String CS_NO="";//學生
  String DEPM_NO="";//學校
  String CLASS_NO="";//班級
  String USER_NO="";//建立者
  bool isExpanded=false;
  String DateStr="";
  List<GROWING> GROWING_list = [];
}
class GROWING{
  String TYPE="";//種類
  String NO="";//編號
  String DATE="";//日期
  String DEPM_NO="";//學校
  String CLASS_NO="";//班級
  String CS_NO="";//學生
  String USER_NO="";//建立者
  List<GROWING_TYPE_ITEM> GROWING_TYPE_ITEM_list = [];
  bool is_value = false;//確認是否已有值
}


/*
健康分類表
 */
Map<String, String> GROWING_TYPE_ITEM_ICON = {
  "":"assets/images/Icon fa-solid-temperature-full.svg",//體溫
  "B1":"assets/images/Icon fa-solid-ruler-vertical.svg",//身高
  "B2":"assets/images/Icon fa-solid-weight-scale.svg",//體重
  "K3":"assets/images/Icon akar-person.svg",//頭圍
  "K1":"assets/images/Icon fa-solid-ruler-vertical.svg",//身高
  "K2":"assets/images/Icon fa-solid-weight-scale.svg",//體重
  "K4":"assets/images/组 29142.svg-assets/images/组 29141.svg",//視力-左,視力-右
  "K5":"assets/images/组 29163.svg",//塗氟
  "K6":"assets/images/Icon akar-dental.svg",//潔牙衛教
  "K7":"assets/images/组 29202.svg",//口腔檢查
};
Map<String, String> GROWING_TYPE_ITEM_UNIT = {
  "":"℃",//體溫
  "B1":"cm",//身高
  "B2":"kg",//體重
  "K3":"cm",//頭圍
  "K1":"cm",//身高
  "K2":"kg",//體重
  "K4":"",//視力
  "K5":"",//塗氟
  "K6":"",//潔牙衛教
  "K7":"",//口腔檢查
};
class GROWING_TYPE_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
  String ITEM_ICON="";//分類ICON(app自定義)
  String ITEM_UNIT="";//分類單位(app自定義)
  String ITEM_VALUE="";//分類值(app自定義)
  String ITEM_RECORD_LINK="";//檢查記錄表
  bool is_value = false;//確認是否已有值
}


/*
用藥原因
 */

DRUG_REASON drug_reason = DRUG_REASON();
class DRUG_REASON{
  String reason="";//其他理由
  DateTime? dateTime;//用藥時間
  bool checkbox = false;
  Uint8List? signaturebytes;//簽名圖檔
  Uint8List? prescriptionsbytes;//藥單封面
  String DRUG_LINK = "";//藥單封面
  String SIGN_LINK = "";//簽名圖檔
  var prescriptionsbytes_xfile;
  String DRUG_NO="";//編號(00年+00月+00日+流水號00000)
  SignatureController signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  List<DRUG_REASON_ITEM> DRUG_REASON_ITEM_list = [];
  List<DRUG_DL> DRUG_DL_list = [];
  List<DateTime> initialDates = [];
}
class DRUG_REASON_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
  bool is_sel = false;
}



//const IMAGE_UPLOAD_URL = '${IMAGE_IP}/School/Images/Sign/';
Future<bool> upload_image({Uint8List? img ,String image_path="", String file_name="",String folder = ""})async{
  //curl -H 'Content-Type: multipart/form-data' -v -F "file=@423237.jpg" https://www.tw-wilson.com/School/Images/Sign

  String IMAGE_UPLOAD_URL="${IMAGE_IP}/School/Images/${folder}";
  //String IMAGE_UPLOAD_URL = "http://10.255.255.1/School/Images/${folder}";
  dev.log("雲端圖片上傳路徑:${IMAGE_UPLOAD_URL}");
  //dev.log("image_path:${image_path}");
  Map<String, String> headers = {
    "Content-type": "multipart/form-data",
  };
  if(image_path.isEmpty) {
    image_path = await saveImage(bytes: img!, file_name: "${file_name}", folder: folder);
  }


  try{

    MultipartRequest request = http.MultipartRequest('POST', Uri.parse("${IMAGE_UPLOAD_URL}"));
    request.headers.addAll(headers);
    dev.log("image_path:${image_path}");
    File file = File("${image_path}");
    // Read file as bytes and add it to request object
    // get file length
    //var length = await file.length();
    //final bytes = await file.readAsBytes();
    //final httpImage =
    //http.MultipartFile.fromBytes('image', bytes, contentType: MediaType.parse(lookupMimeType(file.path)!), filename: file_name);
    //request.files.add(httpImage);
    dev.log("filename:${file_name}");

    request.files.add(
      /*
      http.MultipartFile(
        'file',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: "${file_name}.jpg",
      ),

       */
      await http.MultipartFile.fromPath(
        'file',             // 後端接收的欄位名稱
        file.path,          // 檔案的絕對路徑
        filename: "$file_name.jpg", // 顯示給後端的檔名
      ),
    );


    //http.Client? client = http.Client();
    //dev.log("httpImage:${httpImage.filename}");

    // Send request
    final response = await request.send().timeout(
      const Duration(seconds: 10), // 設定 10 秒模擬超時
    );//await client.send(request);//await request.send();

    // Get response of request
    http.Response responseStream = await http.Response.fromStream(response);
    dev.log("${responseStream.statusCode}");
    dev.log("${responseStream.body}");
    //final responseData = jsonDecode(responseStream.body);
    if(responseStream.statusCode!=200){
      return false;
    }
    else{
      dev.log("第一次上傳圖片成功");
      return true;
    }

  }
  catch(e){
    return false;
  }




}


Future<String> saveImage({Uint8List? bytes,String file_name="",String folder = ""}) async {
  String path = "";
  try {
    Directory root = await getTemporaryDirectory();
    String directoryPath = '${root.path}/威寶通/${folder}';
    // Create the directory if it doesn't exist
    await Directory(directoryPath).create(recursive: true);
    String filePath = '$directoryPath/${file_name}.jpg';
    final file = await File(filePath).writeAsBytes(bytes!);
    path = file.path;
  } catch (e) {
    dev.log(e.toString());
  }
  return path;
}


//const IMAGE_UPLOAD_URL = '${IMAGE_IP}/School/Images/Record/';
Future<void> upload_file({String file_path="", String file_name="",String folder = "",String extension=""})async{
  //curl -H 'Content-Type: multipart/form-data' -v -F "file=@423237.jpg" https://www.tw-wilson.com/School/Images/Sign

  String file_UPLOAD_URL="${IMAGE_IP}/School/Images/${folder}";
  dev.log("檔案上傳路徑:${file_UPLOAD_URL}");
  Map<String, String> headers = {
    "Content-type": "multipart/form-data",
  };
  MultipartRequest request = http.MultipartRequest('POST', Uri.parse(file_UPLOAD_URL));
  request.headers.addAll(headers);
  File file = File("${file_path}");
  request.files.add(
    http.MultipartFile(
      'file',
      file.readAsBytes().asStream(),
      file.lengthSync(),
      filename: "${file_name}.${extension}",
    ),
  );


  // Send request
  final response = await request.send();//await client.send(request);//await request.send();

  // Get response of request
  http.Response responseStream = await http.Response.fromStream(response);
  dev.log("${responseStream.statusCode}");
  dev.log("${responseStream.body}");
  //final responseData = jsonDecode(responseStream.body);

}


/*
圖片下載
 */
Future<Uint8List> get_url_image_to_byte_sub({String img_url=""})async{
  final ByteData imageData = await NetworkAssetBundle(Uri.parse("${img_url}")).load("");
  return imageData.buffer.asUint8List();
}


/*
[托嬰/幼兒]用藥委託主表單(個人) DRUG_MT
 */
List<DRUG_MT> DRUG_MT_list = [];
List<DRUG_MT> DRUG_MT_list_for_month = [];
class DRUG_MT{
   String DRUG_NO="";//編號
   String DATE="";//日期
   String DEPM_NO="";//學校
   String CLASS_NO="";//班級
   String CS_NO="";//學生編號
   String REASON="";//用藥原因
   String DRUG_LINK="";//藥單封面
   String AGREE="";//同意
   String SIGN_LINK="";//簽名
   String DATETIME="";//送出時間
   bool isExpanded=false;
   String DateStr="";
   List<DRUG_DL> DRUG_DL_list = [];
   //double cachedFlexiblePage_pageHeight = 200;
   FlexiblePageView_u? flexiblePageView_u;
   String DEL="";//
}

class DRUG_DL{
  String DRUG_NO="";//編號
  String DRUG_SR="";//序號
  String DETAIL="";//藥品名稱
  String STORE="";//用藥保存 冷藏1/常溫2  DRUG_STORE_ITEM
  String MODE="";//用藥方式 餐前1/餐後2  DRUG_MODE_ITEM
  String UNIT="";//用量單位
  String DOSAGE="";//用量
  String TIME1="";//第1次
  dynamic TIME2="";//第2次
  dynamic TIME3="";//第3次
  String DRUG_LINK="";//藥品照片
  String NOTE="";//說明
  String CMPT_SIGN1="";//第1次_給藥者(老師)簽名
  String CMPT_SIGN2="";//第2次_給藥者(老師)簽名
  String CMPT_SIGN3="";//第3次_給藥者(老師)簽名
  String SING_LINK_TYPE1="";//
  String SING_LINK_TYPE2="";//
  String SING_LINK_TYPE3="";//
  SignatureController signatureController1 = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  SignatureController signatureController2 = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  SignatureController signatureController3 = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  Uint8List? signaturebytes1;//簽名圖檔
  Uint8List? signaturebytes2;//簽名圖檔
  Uint8List? signaturebytes3;//簽名圖檔
  String CMPT_Time1="";//第1次_完成時間
  String CMPT_Time2="";//第2次_完成時間
  String CMPT_Time3="";//第3次_完成時間
  var prescriptionsbytes_xfile;//藥品照片
  bool isExpanded=false;
  double cachedFlexiblePage_pageHeight = 200;
  String CMPT_NOTE1="";//老師給藥說明
  String CMPT_NOTE2="";//老師給藥說明
  String CMPT_NOTE3="";//老師給藥說明
  TextEditingController CMPT1_NOTE_textEditingController = TextEditingController();//老師給藥說明
  TextEditingController CMPT2_NOTE_textEditingController = TextEditingController();//老師給藥說明
  TextEditingController CMPT3_NOTE_textEditingController = TextEditingController();//老師給藥說明
}



/*
DRUG_STORE_ITEM
 */
DRUG_STORE dRUG_STORE = DRUG_STORE();
class DRUG_STORE{
    RadioGroupController radioGroupController = RadioGroupController();
    List<DRUG_STORE_ITEM> DRUG_STORE_ITEM_list = [];
}
class DRUG_STORE_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
DRUG_UNIT_ITEM
 */
List<DRUG_UNIT_ITEM> DRUG_UNIT_ITEM_list = [];
class DRUG_UNIT_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
DRUG_MODE_ITEM
 */
DRUG_MODE dRUG_MODE = DRUG_MODE();
class DRUG_MODE{
  RadioGroupController radioGroupController = RadioGroupController();
  List<DRUG_MODE_ITEM> DRUG_MODE_ITEM_list = [];
}
class DRUG_MODE_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
ROLLCALL_ITEMS
 */
List<ROLLCALL_ITEMS> ROLLCALL_ITEMS_list = [];
class ROLLCALL_ITEMS{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
ENTRUSTED_TYPE_ITEM
 */
List<ENTRUSTED_TYPE_ITEM> ENTRUSTED_TYPE_ITEM_list = [];
class ENTRUSTED_TYPE_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
委託接送
*/
List<Entrusted_pick_and_drop> entrusted_pick_and_drop_list = [];
Entrusted_pick_and_drop entrusted_pick_and_drop = Entrusted_pick_and_drop();
class Entrusted_pick_and_drop{
  DateTime? dateTime;//委託日期
  String DATE="";//日期
  String NO="";//編號
  String DEPM_NO="";//學校(系統自動帶入)
  String CLASS_NO="";//班級(系統自動帶入)
  String CS_NO="";//學生(系統自動帶入)
  String NOTE="";//說明
  String AGENT_NM="";//代理人姓名
  String AGENT_PHONE="";//代理人電話
  String RELATION="";//關係
  String ADD_DATE="";//建立日期時間
  String SIGN_LINK="";//家長簽名
  String CFM_USER="";//確認者
  String CFM_DT="";//確認日期時間
  String CFM_DT_str="";//確認日期時間
  String DateStr="";//app自定義
  bool isExpanded = false;//app自定義(是否展開)
  SignatureController signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  Uint8List? signaturebytes;//簽名圖檔
  List<ENTRUSTED_DL> eNTRUSTED_DL_list = [];
  String DEL="";
}

/*
[托嬰/幼兒] 預約接送明細 ENTRUSTED_DL
 */
class ENTRUSTED_DL{
   String NO="";//編號
   String SR="";//序號
   String TYPE_NO="";//接送
   String TIME="";//時間
}


/*
學生資料 CUSTOMER
 */
List<CUSTOMER> cUSTOMERs = [];
CUSTOMER CUSTOMER_selectedValue = CUSTOMER();
List<EMPLOYEE> cLASS_NO_for_teacher_chat = [];//聊天室有幾位老師
class CUSTOMER{
  String CS_NO="";//學生編號
  String CS_NM="";//學生姓名
  String DEPM_NO="";//學校
  String CLASS_NO="";//班級
  String STATUS="";//就讀情況(Y:就讀中 N:離校 (CUSTOMER_STATUS_ITEM))
  String BIRTHDAY="";//出生日期
  String SEX="";//性別(男性為 Male (M)，女性為 Female (F))
  String PICTURE_LINK="";//照片
  String ADD_DT="";//最後修改日期
  String ADD_USER="";//最後修改者
  String NOTE="";//備註
  CUSTOMER_DL? sel_cUSTOMER_DL;
  List<CUSTOMER_DL?> cUSTOMER_DLs = [];
  var PICTURE_LINK_xfile;//
  bool is_DAILY_PRS = false;//每日聯絡簿是否家長回簽
  bool is_STATUS = false;//老師已讀或老師未讀
  List<EMPLOYEE> cLASS_NO_for_teacher = [];//班級裡有幾位老師
  bool is_DRUG_MT = false;//今日是否有用藥委託
  bool is_EXCUSED = false;//今日是否有請假委託
  bool is_ENTRUSTED = false;//今日是否有接送委託
  String ChatID = "";
  List<types.Message> messages = [];
  int unread_count = 0;
  List<dynamic> unread_data_list = [];
  bool is_sel = false;
  String last_message = "";
  bool checkbox = false;
  String last_MessageID = "0";
  DateTime? DAILY_READ_TIME = null;//日記可讀取時間
  List<DAILY_MT_TYPE_ITEM> DAILY_MT_TYPE_ITEMs = [];
  int sel_DAILY_MT_TYPE_ITEMs_index = 0;
}


/*
授權家長子表單 CUSTOMER_DL
 */
class CUSTOMER_DL{
  String CS_NO="";//學生編號
  String CS_SR="";//序號
  String ACCOUNT="";//家長電話(手機)
  String PASSWORD="";//密碼
  String USER_NM="";//家長姓名
  String RANK="";//等級
  String TOKEN_ID="";//通訊編號
  String SIGN_LINK="";//簽名檔連結
  String FCM="";//推播
  TextEditingController edit_account_TextEditingController = TextEditingController();
  Uint8List? signaturebytes;//簽名圖檔
  TextEditingController admin_TextEditingController = TextEditingController();
  TextEditingController password_TextEditingController = TextEditingController();
  TextEditingController new_password_TextEditingController = TextEditingController();
  SignatureController signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
}


/*
學校(DEPM)
 */
List<DEPM> dEPMs = [];
class DEPM{
  String DEPM_NO="";//學校編號
  String DEPM_NM="";//學校名稱
  String DEPM_NM_S="";//學校簡稱
  String FB_URL="";//Facebook
  String ADDRESS="";//學校地址
  String TELEPHONE="";//學校電話
  String EMAIL="";//學校E-mail
  String NOTE="";//備註
}


/*
班級(CLASS)
 */
List<CLASS> cLASSs = [];
class CLASS{
  String CLASS_NO="";//班級編號
  String CLASS_NM="";//班級姓名
  String DEPM_NO="";//學校名稱
  String TYPE="";//班級類型(幼兒園:1、託嬰:2 (CLASS_ITEM))
  String ICON_PICTURE_LINK="";//照片
  String VISABLE="";//顯示設定
  String NOTE="";//備註
}


/*
老師資料(EMPLOYEE)
 */
List<EMPLOYEE> eMPLOYEEs = [];
EMPLOYEE EMPLOYEE_teacher = EMPLOYEE();//單一老師登入帳號
class EMPLOYEE{
  String EMP_NO="";//老師編號
  String EMP_NM="";//老師姓名
  String RANK="";//等級
  String DEPM_NO="";//學校
  String CLASS_NO="";//班級
  String ACCOUNT="";//手機
  String PASSWORD="";//密碼
  String STATUS="";//使用情況
  String ADD_DT="";//最後修改日期
  String ADD_USER="";//最後修改者
  String TOKEN_ID="";//通訊編號
  String SIGN_LINK="";//簽名檔連結
  String FCM="";//FCM
  String RESERVE1="";//預留
  String RESERVE2="";//預留
  TextEditingController admin_TextEditingController = TextEditingController();
  TextEditingController password_TextEditingController = TextEditingController();
  TextEditingController new_password_TextEditingController = TextEditingController();
  Uint8List? signaturebytes;//簽名圖檔
  SignatureController signatureController = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  List<String> CLASS_NOs = [];//老師自己底下的班級編號
  List<Teacher_CUSTOMER> Teacher_CUSTOMERs = [];//老師自己底下的單個班級
  Teacher_CUSTOMER Teacher_CUSTOMER_selectedValue = Teacher_CUSTOMER();//選了那一個班級
  int unread_count=0;
}

class Teacher_CUSTOMER{
  CLASS cLASS = CLASS();//老師底下班級
  List<CUSTOMER> cUSTOMERs = [];//班級底下學生
  CUSTOMER CUSTOMER_selectedValue = CUSTOMER();//選了那一個學生
}


/*
[托嬰/幼兒] 請假 EXCUSED
 */
List<EXCUSED> EXCUSED_list = [];
class EXCUSED{
  String NO="";//序號
  String DATE="";//日期
  String DEPM_NO="";//學校
  String CLASS_NO="";//班級
  String CS_NO="";//學生(身分證字號)
  String HOURS_NO="";//時數(整日:1、上午:2、下午:3 (EXCUSED_REASON_ITEM))
  String REASON_NO="";//事由(事假:1、病假:2、其他:3 (EXCUSED_HOURS_ITEM))
  String NOTE="";//說明
  String ADD_DATE="";//建立日期時間(系統自動帶入)
  String SING_LINK="";//家長簽名
  String CFM_NO="";//確認(核准：Y 、待確認：N (預設)、註銷：S (CFM_ITEM))
  String CFM_USER="";//確認者(系統自動帶入)
  String CFM_DT="";//確認日期時間(系統自動帶入)
  bool isExpanded = false;//app自定義(是否展開)
  String DateStr="";//app自定義
  CFM_ITEM CFM_ITEM_selectedValue = CFM_ITEM();
  String DEL="";//家長是否取消委託單
}



List<EXCUSED_HOURS_ITEM> EXCUSED_HOURS_ITEM_list = [];
EXCUSED_HOURS_ITEM? sel_EXCUSED_HOURS_ITEM;
class EXCUSED_HOURS_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}

List<EXCUSED_REASON_ITEM> EXCUSED_REASON_ITEM_list = [];
EXCUSED_REASON_ITEM? sel_EXCUSED_REASON_ITEM;
class EXCUSED_REASON_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}

List<CFM_ITEM> CFM_ITEM_list = [];
CFM_ITEM? sel_CFM_ITEM;
class CFM_ITEM{
  String CFM_NO="";//編號
  String CFM_NM="";//名稱
}


/*
成長曲線基準
 */
List<GROWING_STANDARD> GROWING_STANDARDs = [];
class GROWING_STANDARD{
    String TYPE="";//種類
    String SEX="";//性別
    String MONTH="";//月齡
    //String DATA_H="";//數據上限
    //String DATA_L="";//數據下限
    String DATA_3="";//
    String DATA_15="";//
    String DATA_50="";//
    String DATA_85="";//
    String DATA_97="";//
}
String sel_GROWING_STANDARD_TYPE ="K3-頭圍";
List<String> GROWING_STANDARD_TYPE = [
  "K3-頭圍",//頭圍
  "K1-身高",//身高
  "K2-體重",//體重
];
List<SalesData> Male_salesDatas_3 = [];
List<SalesData> Male_salesDatas_15 = [];
List<SalesData> Male_salesDatas_50 = [];
List<SalesData> Male_salesDatas_85 = [];
List<SalesData> Male_salesDatas_97 = [];
List<SalesData> Female_salesDatas_3 = [];
List<SalesData> Female_salesDatas_15 = [];
List<SalesData> Female_salesDatas_50 = [];
List<SalesData> Female_salesDatas_85 = [];
List<SalesData> Female_salesDatas_97 = [];
class SalesData {
  String MONTH="";
  double DATA=0;
  SalesData({String MONTH="", double DATA=0}){
    this.MONTH = MONTH;
    this.DATA = DATA;
  }
}


/*
生活概況時序查詢表(範例)
 */
List<View_DAILY> view_DAILYs = [];
List<View_DAILY> view_DAILYs_2 = [];
class View_DAILY{
  String TYPE="";//
  String NO="";//
  String DATE="";//
  String TIME="";//
  String DEPM_NO="";//
  String CLASS_NO="";//
  String CS_NO="";//
  String MARK="";//
  bool RECIPIENT = false;//讀取回條(須備物品)
}

/*
DAILY_MT_TYPE_ITEM
 */
List<DAILY_MT_TYPE_ITEM> DAILY_MT_TYPE_ITEMs = [];
List<DAILY_MT_TYPE_ITEM> DAILY_MT_TYPE_ITEMs_2 = [];
class DAILY_MT_TYPE_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
  Color? color;
  var svg_icon;
  bool VISABLE = true;//顯示
}


/*
DAILY_ACT_ITEM
 */
List<DAILY_ACT_ITEM> DAILY_ACT_ITEMs = [];
DAILY_ACT_ITEM sel_DAILY_ACT_ITEM = DAILY_ACT_ITEM();
class DAILY_ACT_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}

class DAILY_ACT{
  String TYPE="";//單別
  String NO="";//編號
  String ITEM="";//項目
  String NOTE="";//內容
  var prescriptionsbytes_xfile;//活動圖片
}


class DAILY_PIC_DL{
  String TYPE="";//單別
  String NO="";//編號
  String SR="";//序號
  String LINK="";//照片
  var prescriptionsbytes_xfile;//活動圖片
}

/*
[托嬰]飲食(餵奶)
 */
List<DAILY_MLK_ITEM> DAILY_MLK_ITEMs = [];
DAILY_MLK_ITEM sel_DAILY_MLK_ITEM = DAILY_MLK_ITEM();
class DAILY_MLK_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
DAILY_POP_HARD_ITEM
 */
List<DAILY_POP_HARD_ITEM> DAILY_POP_HARD_ITEMs = [];
DAILY_POP_HARD_ITEM sel_DAILY_POP_HARD_ITEM = DAILY_POP_HARD_ITEM();
class DAILY_POP_HARD_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}

/*
DAILY_POP_COLOR_ITEM
 */
List<DAILY_POP_COLOR_ITEM> DAILY_POP_COLOR_ITEMs = [];
DAILY_POP_COLOR_ITEM sel_DAILY_POP_COLOR_ITEM = DAILY_POP_COLOR_ITEM();
class DAILY_POP_COLOR_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
DAILY_POP_QUANTITY_ITEM
 */
List<DAILY_POP_QUANTITY_ITEM> DAILY_POP_QUANTITY_ITEMs = [];
DAILY_POP_QUANTITY_ITEM sel_DAILY_POP_QUANTITY_ITEM = DAILY_POP_QUANTITY_ITEM();
class DAILY_POP_QUANTITY_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
DAILY_EAT_ITEM
 */
List<DAILY_EAT_ITEM> DAILY_EAT_ITEMs = [];
DAILY_EAT_ITEM sel_DAILY_EAT_ITEM = DAILY_EAT_ITEM();
class DAILY_EAT_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
DAILY_EAT_NOTE_ITEM
 */
List<DAILY_EAT_NOTE_ITEM> DAILY_EAT_NOTE_ITEMs = [];
DAILY_EAT_NOTE_ITEM sel_DAILY_EAT_NOTE_ITEM = DAILY_EAT_NOTE_ITEM();
class DAILY_EAT_NOTE_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
DAILY_TMP_KIND_ITEM
 */
List<DAILY_TMP_KIND_ITEM> DAILY_TMP_KIND_ITEMs = [];
DAILY_TMP_KIND_ITEM sel_DAILY_TMP_KIND_ITEM = DAILY_TMP_KIND_ITEM();
class DAILY_TMP_KIND_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
DAILY_SLP_STATUS_ITEM
 */
List<DAILY_SLP_STATUS_ITEM> DAILY_SLP_STATUS_ITEMs = [];
DAILY_SLP_STATUS_ITEM sel_DAILY_SLP_STATUS_ITEM = DAILY_SLP_STATUS_ITEM();
class DAILY_SLP_STATUS_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
DAILY_RQD_ITEM
 */
List<DAILY_RQD_ITEM> DAILY_RQD_ITEMs = [];
DAILY_RQD_ITEM sel_DAILY_RQD_ITEM = DAILY_RQD_ITEM();
class DAILY_RQD_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
  String DEMP="";//學校
  TextEditingController num_textEditingController = TextEditingController();//
}


/*
DAILY_CND_NASAL_STATUS_ITEM
 */
List<DAILY_CND_NASAL_STATUS_ITEM> DAILY_CND_NASAL_STATUS_ITEMs = [];
DAILY_CND_NASAL_STATUS_ITEM sel_DAILY_CND_NASAL_STATUS_ITEM = DAILY_CND_NASAL_STATUS_ITEM();
class DAILY_CND_NASAL_STATUS_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
DAILY_CND_RUNNY_COLOR_ITEM
 */
List<DAILY_CND_RUNNY_COLOR_ITEM> DAILY_CND_RUNNY_COLOR_ITEMs = [];
DAILY_CND_RUNNY_COLOR_ITEM sel_DAILY_CND_RUNNY_COLOR_ITEM = DAILY_CND_RUNNY_COLOR_ITEM();
class DAILY_CND_RUNNY_COLOR_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}

/*
DAILY_CND_RUNNY_TYPE_ITEM
 */
List<DAILY_CND_RUNNY_TYPE_ITEM> DAILY_CND_RUNNY_TYPE_ITEMs = [];
DAILY_CND_RUNNY_TYPE_ITEM sel_DAILY_CND_RUNNY_TYPE_ITEM = DAILY_CND_RUNNY_TYPE_ITEM();
class DAILY_CND_RUNNY_TYPE_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
DAILY_CND_RUNNY_QUANTITY_ITEM
 */
List<DAILY_CND_RUNNY_QUANTITY_ITEM> DAILY_CND_RUNNY_QUANTITY_ITEMs = [];
DAILY_CND_RUNNY_QUANTITY_ITEM sel_DAILY_CND_RUNNY_QUANTITY_ITEM = DAILY_CND_RUNNY_QUANTITY_ITEM();
class DAILY_CND_RUNNY_QUANTITY_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
DAILY_CND_RUNNY_QUANTITY_ITEM
 */
List<DAILY_CND_COUGH_LEVEL_ITEM> DAILY_CND_COUGH_LEVEL_ITEMs = [];
DAILY_CND_COUGH_LEVEL_ITEM sel_DAILY_CND_COUGH_LEVEL_ITEM = DAILY_CND_COUGH_LEVEL_ITEM();
class DAILY_CND_COUGH_LEVEL_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
DAILY_CND_COUGH_TIME_ITEM
 */
List<DAILY_CND_COUGH_TIME_ITEM> DAILY_CND_COUGH_TIME_ITEMs = [];
DAILY_CND_COUGH_TIME_ITEM sel_DAILY_CND_COUGH_TIME_ITEM = DAILY_CND_COUGH_TIME_ITEM();
class DAILY_CND_COUGH_TIME_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
DAILY_CND_HFMD_TYPE_ITEM
 */
List<DAILY_CND_HFMD_TYPE_ITEM> DAILY_CND_HFMD_TYPE_ITEMs = [];
DAILY_CND_HFMD_TYPE_ITEM sel_DAILY_CND_HFMD_TYPE_ITEM = DAILY_CND_HFMD_TYPE_ITEM();
class DAILY_CND_HFMD_TYPE_ITEM{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
}


/*
[托嬰/幼兒]  家長回簽
 */
bool is_DAILY_PRS_SIGN_LINK_flag = true;
int is_DAILY_MT_length = 0;
List<DAILY_PRS> DAILY_PRSs = [];
class DAILY_PRS{
  String TYPE="";//單別
  String NO="";//序號
  String DATE="";//日期
  String TIME="";//時間
  String DEPM_NO="";//學校
  String CLASS_NO="";//班級
  String CS_NO="";//學生編號
  String NOTE="";//備註
  String STATUS="";//消息的狀態(例如:老師已讀或老師未讀)
  String SIGN_LINK="";//家長簽名
  String DateStr="";//app自定義
  bool isExpanded = false;
  String REPLY="";//老師回覆
  String REPLY_USER_NO="";//回覆者
  TextEditingController REPLY_textEditingController = TextEditingController();//備註
  FocusNode REPLY_FocusNode = FocusNode();
}

/*
傳送與接收統計
 */
View_SURVEY_COUNTS view_SURVEY_COUNTS = View_SURVEY_COUNTS();
class View_SURVEY_COUNTS{
  String NO="";//問卷編號
  String SentCount="";//送出數量
  String ReceivedCount="";//回復數量
}


/*
回答統計 View_SURVEY_ANSWER_STATS
 */
View_SURVEY_ANSWER_STATS view_SURVEY_ANSWER_STATS = View_SURVEY_ANSWER_STATS();
class View_SURVEY_ANSWER_STATS{
  String NO="";//問卷編號
  String ANSWER="";//問卷題目編號
  String AnswerCount="";//數量
}


List<View_DAILY_ROLLCALL_RUG_MT> view_DAILY_ROLLCALL_RUG_MTs = [];
class View_DAILY_ROLLCALL_RUG_MT{
  String DATE="";//日期
  String DEPM_NO="";//學校
  String CLASS_NO="";//班級
  String CS_NO="";//學生編號
  List<View_DAILY> view_DAILYs = [];
  List<DAILY_PRS> DAILY_PRSs = [];
  List<ROLLCALL> ROLLCALL_list = [];
  List<DRUG_MT> DRUG_MT_list_for_month = [];
  List<View_DAILY_RETURN_LIST> View_DAILY_RETURN_LIST_for_month = [];
  bool isExpanded = false;//app自定義(是否展開)
  String DateStr="";//app自定義
}


/*
家長是否有回簽查詢表
 */
List<View_DAILY_RETURN_LIST> view_DAILY_RETURN_LISTs = [];
List<View_DAILY_RETURN_LIST> view_DAILY_RETURN_LISTs_2 = [];
class View_DAILY_RETURN_LIST{
  String DEPM_NO="";//學校
  String CLASS_NO="";//班級
  String CS_NO="";//學生編號
  String DATE="";//
  String Has_Activity="";//有無日報
  String Has_PRS="";//有無回簽
  bool isExpanded = false;//app自定義(是否展開)
  String DateStr="";//app自定義
  bool list_item_is_show = false;
}


//日常用語
Teacher_Daily_language_menu sel_teacher_Daily_language_menu = Teacher_Daily_language_menu();
class Teacher_Daily_language_menu{
  String account = "";
  List<Daily_language_menu> menu = [
    Daily_language_menu(title: "活動",is_sel: true),
    Daily_language_menu(title: "生理狀況"),
    Daily_language_menu(title: "日記"),
    Daily_language_menu(title: "用餐"),
    Daily_language_menu(title: "通知單"),
  ];
  Map<String, dynamic> toJson() {
    return {
      '活動': menu[0].contants,
      '生理狀況': menu[1].contants,
      '日記': menu[2].contants,
      '用餐': menu[3].contants,
      '通知單': menu[4].contants,
    };
  }
}
class Daily_language_menu{
  String title = "";
  bool is_sel = false;
  List<String> contants = [];
  List<TextEditingController> contant_TextEditingControllers = [];
  Daily_language_menu({String title="",bool is_sel = false,List<dynamic>? contants}){
    this.title = title;
    this.is_sel = is_sel;
    if(contants!=null){
      this.contants.clear();
      this.contant_TextEditingControllers.clear();
      for(int i=0;i<contants.length;i++){
        this.contants.add(contants[i]);
        this.contant_TextEditingControllers.add(TextEditingController(text: contants[i]));
      }

    }
  }
  Map<String, dynamic> toJson() {
    return {
      'contants': contants,
    };
  }
}


class CALL{
  String NO="";//編號
  String DATE_TIME="";//發送日期時間
  String DEPM_NO="";//學校
  String CLASS_NO="";//班級
  String CS_NO="";//學生編號
  String MINUTE="";//接送時間
  String ACCOUNT="";//家長發送者
  bool COMPLETE = false;//播放完成
  DateTime? ARRIVAL_TIME;//
}


/*

 */
List<DRUG_CANCEL_REASON> DRUG_CANCEL_REASONs = [];
class DRUG_CANCEL_REASON{
  String ITEM_NO="";//編號
  String ITEM_NM="";//名稱
  String LINK="";//照片位置
  bool sel = false;
}





