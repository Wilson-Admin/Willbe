import 'dart:math';
import 'package:code3/utils/VerticalDashedLine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// =====================================================
// 1. 數據模型與幫助函數
// =====================================================

// 餵食類型
enum FeedingType {
  breastMilk, // 母乳 (黃色: #FFFFC043)
  formula,    // 配方奶 (綠色: #FF7CB342)
  none,       // 無餵食
}

// 單次餵食記錄
class FeedingEntry {
  final FeedingType type;
  final int amountMl;
  FeedingEntry({required this.type, required this.amountMl});
}

// 每日記錄
class DailyFeedingData {
  final String dateLabel; // 格式如: "12/01\n(周一)"
  final List<FeedingEntry> entries;
  DailyFeedingData({required this.dateLabel, required this.entries});

  // 計算當日總毫升數
  int get totalMl => entries.fold(0, (sum, entry) => sum + entry.amountMl);
}

/// 模擬生成當月所有日期，並格式化為 "MM/DD\n(周X)"
List<String> generateCurrentMonthDates() {
  // 模擬日期從 2025年12月1日 開始
  DateTime now = DateTime(2025, 12, 1);
  DateTime date = DateTime(now.year, now.month, 1);
  DateTime nextMonth = DateTime(now.year, now.month + 1, 1);

  List<String> dates = [];
  const List<String> chineseWeekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  while (date.isBefore(nextMonth)) {
    String monthStr = date.month.toString().padLeft(2, '0');
    String dayStr = date.day.toString().padLeft(2, '0');
    String datePart = '$monthStr/$dayStr';

    // DateTime.weekday: 1=Mon, 7=Sun
    String weekdayPart = chineseWeekdays[date.weekday - 1];

    dates.add('$datePart\n($weekdayPart)');
    date = date.add(const Duration(days: 1));
  }
  return dates;
}

/// 根據日期列表生成隨機餵食數據
List<DailyFeedingData> generateRandomData({required List<String> dates}) {
  final Random random = Random();
  List<DailyFeedingData> data = [];

  // 模擬每日的可能餵食時間點（08, 12, 16, 18 點附近有較高機率）
  List<int> feedingHours = [8, 12, 16, 18];

  for (String date in dates) {
    List<FeedingEntry> dayEntries = [];
    // 遍歷 08:00 到 18:00 之間的數據（共 11 個小時的數據）
    for (int hour = 8; hour <= 18; hour++) {
      if (feedingHours.contains(hour) && random.nextDouble() < 0.7) {
        int amount = [80, 100, 120][random.nextInt(3)];
        FeedingType type = random.nextBool()
            ? FeedingType.breastMilk
            : FeedingType.formula;
        dayEntries.add(FeedingEntry(type: type, amountMl: amount));
      } else {
        dayEntries.add(FeedingEntry(type: FeedingType.none, amountMl: 0));
      }
    }
    data.add(DailyFeedingData(dateLabel: date, entries: dayEntries));
  }
  return data;
}

// =====================================================
// 2. 核心 UI 元件
// =====================================================

/// 單次餵食區塊 (黃色或綠色)
class FeedingBlock extends StatelessWidget {
  final FeedingEntry entry;
  const FeedingBlock({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    if (entry.type == FeedingType.none) {
      // 無餵食時返回佔位符，以確保行高一致
      return const SizedBox(height: 50);
    }
    Color color = entry.type == FeedingType.breastMilk
        ? const Color(0xFFFFC043) // 黃色 (母乳)
        : const Color(0xFF7CB342); // 綠色 (配方奶)

    return Container(
      alignment: Alignment.center,
      height: 50,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(child:Text(
          '${entry.amountMl}\nml',
          textScaler: const TextScaler.linear(1),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 8.sp, color: Colors.black87, fontWeight: FontWeight.bold)
      )),
    );
  }
}

/// 每日餵食記錄列
class FeedingRow extends StatelessWidget {
  final DailyFeedingData data;
  const FeedingRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<Widget> hourWidgets = [];
    for (int i = 0; i < data.entries.length; i++) {

      hourWidgets.add(
        Expanded(
          flex: 1,
          child: Container(
            child: FeedingBlock(entry: data.entries[i]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左側日期標籤 (固定寬度 50)
          Container(
            width: 50.w,
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              data.dateLabel,
              textScaler: const TextScaler.linear(1),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, height: 1.2,color: Colors.black),
            ),
          ),

          Expanded(child:Container(

              child:
          Container(
            child: Row(crossAxisAlignment: CrossAxisAlignment.center,children: [
              // 中間數據區
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: hourWidgets,
                ),
              ),
              // --- 應用獨立的虛線元件 ---
              Container(width: 1.w,),
              VerticalDashedLine(height: 50.h),

              // 最右側總和 (固定寬度 50)
              Container(
                width: 50.w,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  '${data.totalMl}ml',
                  textScaler: const TextScaler.linear(1),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.black87),
                ),
              ),
            ],),
            decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: Colors.black, // 指定邊框顏色
                width: 1.0.w,        // 指定邊框粗細
                style: BorderStyle.solid, // 實線 (預設值，可省略)
              ),
              left: BorderSide(
                color: Colors.black, // 指定邊框顏色
                width: 1.0.w,        // 指定邊框粗細
                style: BorderStyle.solid, // 實線 (預設值，可省略)
              ),
              bottom: BorderSide(
                color: Colors.black, // 指定邊框顏色
                width: 1.w,        // 指定邊框粗細
                style: BorderStyle.solid, // 實線 (預設值，可省略)
              ),
            ),
          ),))),




        ],
      ),
    );
  }
}

// -----------------------------------------------------
// 3. 主元件：餵食記錄圖表 (新增圖例)
// -----------------------------------------------------
class FeedingChart extends StatelessWidget {
  // 小時範圍 (08, 09, ..., 18)
  final List<int> hours = List<int>.generate(11, (i) => i + 8);
  late final List<DailyFeedingData> chartData;

  FeedingChart({super.key}) {
    List<String> dates = generateCurrentMonthDates();
    chartData = generateRandomData(dates: dates);
  }

  // 新增：構建母乳與配方乳圖例
  Widget _buildLegend() {
    // 定義圖例項目
    Widget legendItem(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(label,textScaler: const TextScaler.linear(1), style: TextStyle(color: Colors.black,fontSize: 14.sp, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      alignment: Alignment.centerRight, // 讓圖例靠右對齊 (類似原圖)
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          legendItem(const Color(0xFFFFC043), '母乳'),
          legendItem(const Color(0xFF7CB342), '配方乳'),
        ],
      ),
    );
  }

  // 底部小時標題 (08~18)
  Widget _buildBottomHourTitle() {
    List<Widget> hourTitles = hours.map((hour) {
      return Expanded(
        flex: 1,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            hour.toString().padLeft(2, '0'),
            textScaler: const TextScaler.linear(1),
            style: TextStyle(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }).toList();

    return Container(
      child: Row(
        children: [
          // 左側日期佔位符 (寬度 80，用於對齊)
          SizedBox(width:50.w),
          // 小時標題 (08~18)
          Expanded(child: Row(children: hourTitles)),
          // 右側總和佔位符 (寬度 70，用於對齊)
          SizedBox(width: 50.w),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. 母乳/配方乳圖例 (在最頂端)
        _buildLegend(),

        // 2. 數據內容區（可滾動）- 佔據中間所有空間
        Expanded(
          child: Column(children: [
            Container(margin: EdgeInsets.only(left:50.w),width: ScreenUtil().screenWidth,height: 1.w,color: Colors.black,),
            Expanded(child:
            ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: chartData.length,
              itemBuilder: (context, index) {
                return FeedingRow(data: chartData[index]);
              },
            )),
        ],)

        ),

        // 3. 底部小時標題 (08~18) - 固定在畫面的最下方
        _buildBottomHourTitle(),
      ],
    );
  }
}

