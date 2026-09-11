import 'dart:developer';
import 'package:code3/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // 為了 ScrollDirection
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class MonthTableWidget extends StatefulWidget {
  final List<DAILY_EAT_ITEM> columns;
  final DateTime selectedMonth;
  final List<View_DAILY> view_DAILYs;

  const MonthTableWidget({
    super.key,
    required this.columns,
    required this.selectedMonth,
    required this.view_DAILYs,
  });

  @override
  State<MonthTableWidget> createState() => _MonthTableWidgetState();
}

class _MonthTableWidgetState extends State<MonthTableWidget> {
  final ScrollController horizontalHeader = ScrollController();
  final ScrollController horizontalBody = ScrollController();
  final ScrollController verticalLeft = ScrollController();
  final ScrollController verticalRight = ScrollController();

  // 用於標記目前是哪一個 Controller 正在被手勢操控
  ScrollController? _activeHorizontal;
  ScrollController? _activeVertical;

  Map<String, String> cellDataMap = {};

  @override
  void initState() {
    super.initState();
    _processData();

    // 水平滾動同步邏輯
    horizontalHeader.addListener(() => _syncHorizontal(horizontalHeader, horizontalBody));
    horizontalBody.addListener(() => _syncHorizontal(horizontalBody, horizontalHeader));

    // 垂直滾動同步邏輯
    verticalLeft.addListener(() => _syncVertical(verticalLeft, verticalRight));
    verticalRight.addListener(() => _syncVertical(verticalRight, verticalLeft));
  }

  // 同步水平偏移
  void _syncHorizontal(ScrollController source, ScrollController target) {
    if (_activeHorizontal == null && source.position.userScrollDirection != ScrollDirection.idle) {
      _activeHorizontal = source;
    }
    if (_activeHorizontal == source && target.hasClients) {
      target.jumpTo(source.offset);
    }
    if (source.position.userScrollDirection == ScrollDirection.idle && _activeHorizontal == source) {
      _activeHorizontal = null;
    }
  }

  // 同步垂直偏移
  void _syncVertical(ScrollController source, ScrollController target) {
    if (_activeVertical == null && source.position.userScrollDirection != ScrollDirection.idle) {
      _activeVertical = source;
    }
    if (_activeVertical == source && target.hasClients) {
      target.jumpTo(source.offset);
    }
    if (source.position.userScrollDirection == ScrollDirection.idle && _activeVertical == source) {
      _activeVertical = null;
    }
  }

  // ... _processData, getDays, weekdayZh 保持原本邏輯 ...
  // 🌟 資料處理邏輯（加入 CS_NO 學生比對、POV & 時間觀看限制判斷）
  void _processData() {
    cellDataMap.clear();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // 1. 預先整理出「該位學生」當月所有有 POV 紀錄的日期（YYYY-MM-DD）
    final Set<String> povDates = {};
    for (var item in widget.view_DAILYs) {
      if (item.TYPE.trim() == 'POV' && item.CS_NO == CUSTOMER_selectedValue.CS_NO) { // 👈 補上 CS_NO 比對
        String povDateStr = item.DATE.split('T').first;
        povDates.add(povDateStr);
      }
    }

    // 2. 僅篩選「該位學生」的 EAT 資料
    final eatItems = widget.view_DAILYs
        .where((d) => d.TYPE == 'EAT' && d.CS_NO == CUSTOMER_selectedValue.CS_NO) // 👈 補上 CS_NO 比對
        .toList();

    for (var dailyItem in eatItems) {
      DateTime? date;
      try { date = DateTime.parse(dailyItem.DATE); } catch (e) { continue; }

      String rawDateStr = dailyItem.DATE.split('T').first; // e.g., "2026-05-20"
      bool is_pov = false;

      // --- POV 邏輯判斷開始 ---
      // 條件 1：當天有 POV 紀錄
      if (povDates.contains(rawDateStr)) {
        log("當天有POV才顯示每日活動");
        is_pov = true;
      }

      // 條件 2：檔案日期在今天以前
      final itemDateOnly = DateTime(date.year, date.month, date.day);
      if (itemDateOnly.isBefore(todayStart)) {
        log("該檔案的修改日期是今天以前-3");
        is_pov = true;
      }

      // 條件 3：目前時間已超過當日允許觀看的時間
      if (CUSTOMER_selectedValue.DAILY_READ_TIME != null) {
        DateTime target = DateTime(
          date.year,
          date.month,
          date.day,
          CUSTOMER_selectedValue.DAILY_READ_TIME!.hour,
          CUSTOMER_selectedValue.DAILY_READ_TIME!.minute,
          CUSTOMER_selectedValue.DAILY_READ_TIME!.second,
        );
        log('now:${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}');
        log('target:${DateFormat('yyyy-MM-dd HH:mm:ss').format(target)}');

        if (now.isAfter(target)) {
          log("已超過時間,日記可以給家長觀看-3");
          is_pov = true;
        } else {
          log("尚未到時間,日記不能給家長觀看");
        }
      }

      // 若均不符合條件，跳過不處理該筆資料
      if (!is_pov) {
        continue;
      }
      // --- POV 邏輯判斷結束 ---

      final dateKey = DateFormat("MM/dd").format(date);
      for (var column in widget.columns) {
        final columnName = column.ITEM_NM;
        String displayMark = dailyItem.MARK;
        if (dailyItem.MARK.contains('/')) {
          final parts = dailyItem.MARK.split('/');
          if (parts.length == 2 && parts[0] == columnName) {
            displayMark = parts[1].split('\n')[0];
          } else if (parts.length == 2 && parts[0] != columnName) {
            continue;
          }
        }
        if (columnName.contains(dailyItem.TIME) || dailyItem.MARK.contains(columnName)) {
          final key = '${dateKey}_$columnName';
          if (cellDataMap.containsKey(key)) {
            cellDataMap[key] = '${cellDataMap[key]}, $displayMark';
          } else {
            cellDataMap[key] = displayMark;
          }
        }
      }
    }
  }

  List<DateTime> getDays(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final next = DateTime(month.year, month.month + 1, 1);
    final last = next.subtract(const Duration(days: 1));
    return List.generate(last.day, (i) => DateTime(month.year, month.month, i + 1));
  }

  String weekdayZh(int weekday) {
    const list = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"];
    return list[weekday % 7];
  }

  @override
  void dispose() {
    horizontalHeader.dispose();
    horizontalBody.dispose();
    verticalLeft.dispose();
    verticalRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final days = getDays(widget.selectedMonth);
    double leftWidth = 70.w;
    double cellWidth = 80.w;
    double cellHeight = 50.h;

    // 設定滾動物理效果，確保 iOS 有回彈感
    const physics = BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());

    return Row(
      children: [
        // 左側固定日期欄
        Column(
          children: [
            Container(width: leftWidth, height: 40.h, alignment: Alignment.center, child: const Text("")),
            Expanded(
              child: SingleChildScrollView(
                controller: verticalLeft,
                physics: physics,
                child: Column(
                  children: List.generate(days.length, (i) {
                    final d = days[i];
                    return Container(
                      width: leftWidth, height: cellHeight,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
                      child: Text("${DateFormat("MM/dd").format(d)}\n(${weekdayZh(d.weekday)})",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold)),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),

        // 右側表格
        Expanded(
          child: Column(
            children: [
              // 上方標題
              SizedBox(
                height: 35.h,
                child: SingleChildScrollView(
                  controller: horizontalHeader,
                  scrollDirection: Axis.horizontal,
                  physics: physics,
                  child: Row(
                    children: widget.columns.map((col) {
                      return Container(
                        width: cellWidth,
                        height: 35.h,
                        alignment: Alignment.center,
                        child: Container(
                          width: cellWidth - 10.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: const Color(0xff49C2BB), width: 1.5),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8.0, offset: Offset(0, 4))],
                          ),
                          child: Text(col.ITEM_NM, style: TextStyle(color: Colors.black,fontSize: 18.sp, fontWeight: FontWeight.bold)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(height: 5.h),

              // 表格內容
              Expanded(
                child: SingleChildScrollView(
                  controller: horizontalBody,
                  scrollDirection: Axis.horizontal,
                  physics: physics,
                  child: SingleChildScrollView(
                    controller: verticalRight,
                    physics: physics,
                    child: Column(
                      children: List.generate(days.length, (r) {
                        final d = days[r];
                        final dateKey = DateFormat("MM/dd").format(d);
                        return Row(
                          children: List.generate(widget.columns.length, (c) {
                            final columnName = widget.columns[c].ITEM_NM;
                            final cellKey = '${dateKey}_$columnName';
                            final cellContent = cellDataMap[cellKey] ?? "";
                            return Container(
                              width: cellWidth, height: cellHeight,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(border: Border.all(color: Colors.black12, width: 0.5)),
                              child: Text(cellContent, textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}