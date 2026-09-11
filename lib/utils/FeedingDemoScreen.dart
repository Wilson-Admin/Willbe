import 'dart:developer' as dev;
import 'dart:math';
import 'package:code3/api.dart';
import 'package:code3/utils/VerticalDashedLine.dart'; // 假設這裡包含 VerticalDashedLine
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

// =====================================================
// 1. 數據模型與幫助函數 (新增外部模型定義與轉換邏輯)
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


/// 根據外部數據生成 DailyFeedingData (加入 CS_NO 比對與 POV 閱讀權限判斷)
List<DailyFeedingData> generateFeedingData({
    required DateTime selectedMonth,
    required List<View_DAILY> view_DAILYs,
    required List<DAILY_MLK_ITEM> DAILY_MLK_ITEMs,
  }) {
    final Map<String, String> milkItems = {
      for (var item in DAILY_MLK_ITEMs) item.ITEM_NM: item.ITEM_NM
    };

    final targetCsNo = CUSTOMER_selectedValue.CS_NO; // 取得目標學生編號

    // 1. 生成當月所有日期和結構
    final Map<String, DailyFeedingData> dailyDataMap = {};
    DateTime date = DateTime(selectedMonth.year, selectedMonth.month, 1);
    DateTime nextMonth = DateTime(selectedMonth.year, selectedMonth.month + 1, 1);

    const List<String> chineseWeekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

    while (date.isBefore(nextMonth)) {
      String yearStr = date.year.toString();
      String monthStr = date.month.toString().padLeft(2, '0');
      String dayStr = date.day.toString().padLeft(2, '0');

      // *** 內部 Map 使用的標準 Key 格式：YYYY/MM/DD ***
      String dateKey = '$yearStr/$monthStr/$dayStr';
      String dateLabel = '$monthStr/$dayStr\n(${chineseWeekdays[date.weekday - 1]})';

      List<FeedingEntry> initialEntries = List.generate(11, (_) => FeedingEntry(type: FeedingType.none, amountMl: 0));
      dailyDataMap[dateKey] = DailyFeedingData(dateLabel: dateLabel, entries: initialEntries);
      date = date.add(const Duration(days: 1));
    }

    // 取得今天的開始時間（不含時間成分）
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // 🌟 關鍵步驟 1：預先整理出「該位學生」哪些日期有 POV 記錄（儲存格式為 YYYY-MM-DD）
    final Set<String> povDates = {};
    for (var item in view_DAILYs) {
      if (item.TYPE.trim() == 'POV' && item.CS_NO == targetCsNo) { // 👈 補上 CS_NO 比對
        String povDateStr = item.DATE.split('T').first; // 取得 "YYYY-MM-DD"
        povDates.add(povDateStr);
      }
    }

    // 2. 填充數據
    for (var daily in view_DAILYs) {
      // 僅處理「該位學生」且 TYPE 為 MLK 的資料
      if (daily.TYPE.trim() != 'MLK' || daily.CS_NO != targetCsNo) continue; // 👈 補上 CS_NO 比對

      String rawDateStr1 = daily.DATE.split('T').first; // 取得目前 MLK 的日期 (e.g., "2026-05-20")
      bool is_pov = false;

      // --- POV 邏輯判斷開始 ---

      // 1. 確認「當天 (與 MLK 同一天)」是否有 POV 紀錄
      if (povDates.contains(rawDateStr1)) {
        dev.log("當天有 POV 才顯示每日活動");
        is_pov = true;
      }

      // 2. 檔案修改日期在今天以前
      final modifiedDate = DateTime.parse(daily.DATE);
      final modifiedDateOnly = DateTime(modifiedDate.year, modifiedDate.month, modifiedDate.day);
      if (modifiedDateOnly.isBefore(todayStart)) {
        dev.log("該檔案的修改日期是今天以前-3");
        is_pov = true;
      } else {
        // dev.log("該檔案的修改日期是今天或之後");
      }

      // 3. 目前時間是否已過該日期的可讀取時間
      DateTime target = DateTime(
        modifiedDate.year,
        modifiedDate.month,
        modifiedDate.day,
        CUSTOMER_selectedValue.DAILY_READ_TIME!.hour,
        CUSTOMER_selectedValue.DAILY_READ_TIME!.minute,
        CUSTOMER_selectedValue.DAILY_READ_TIME!.second,
      );
      dev.log('now:${DateFormat('yyyy-MM-dd HH:mm:ss').format(now)}');
      dev.log('target:${DateFormat('yyyy-MM-dd HH:mm:ss').format(target)}');

      if (now.isAfter(target)) {
        dev.log("已超過時間,日記可以給家長觀看-3");
        is_pov = true;
      } else {
        dev.log("尚未到時間,日記不能給家長觀看");
      }

      // 只有 is_pov == true 才能繼續顯示與處理資料
      if (!is_pov) {
        continue;
      }
      // --- POV 邏輯判斷結束 ---

      try {
        // *** 修正點 A: 處理帶時間戳的日期，並轉換為 YYYY/MM/DD 格式 ***
        String rawDateStr = daily.DATE.split('T').first; // e.g., "2025-12-13"
        String dateKey = rawDateStr.replaceAll('-', '/'); // e.g., "2025/12/13"

        int hour = int.tryParse(daily.TIME.split(':')[0]) ?? -1;

        if (hour < 8 || hour > 18) continue;

        // 處理 MARK 字段
        String markLine = daily.MARK.split('\n').first.trim();
        List<String> markParts = markLine.split(':');
        if (markParts.length != 2) continue;

        String itemType = markParts[0].trim();
        // 修正點 B: 確保 amountStr 在解析前移除所有非數字字符 (僅適用於簡單的 'ml' 結尾)
        String amountStr = markParts[1].trim().replaceAll('ml', '').trim();
        int amount = int.tryParse(amountStr) ?? 0;

        if (amount <= 0 || !milkItems.containsKey(itemType)) continue;

        // 判斷 FeedingType
        FeedingType feedingType;
        if (itemType == milkItems['母乳']) {
          feedingType = FeedingType.breastMilk;
        } else if (itemType == milkItems['配方奶']) {
          feedingType = FeedingType.formula;
        } else {
          continue;
        }

        // 找到對應的時間索引
        int entryIndex = hour - 8;
        if (dailyDataMap.containsKey(dateKey)) {
          dailyDataMap[dateKey]!.entries[entryIndex] = FeedingEntry(type: feedingType, amountMl: amount);
        }

      } catch (e) {
        debugPrint('Error processing MLK data: $e');
        continue;
      }
    }

    // 3. 返回結果列表
    return dailyDataMap.values.toList();
  }


// =====================================================
// 2. 核心 UI 元件 (重構 FeedingRow)
// =====================================================

/// 單次餵食區塊 (黃色或綠色) - 保持不變
class FeedingBlock extends StatelessWidget {
  final FeedingEntry entry;
  const FeedingBlock({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    if (entry.type == FeedingType.none) {
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

/// *** 新增 ***：小時格與總和的數據區 (負責內部分割線)
class FeedingRowData extends StatelessWidget {
  final DailyFeedingData data;
  const FeedingRowData({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    List<Widget> hourWidgets = [];

    for (int i = 0; i < data.entries.length; i++) {
      bool isFeedingTime = data.entries[i].amountMl > 0;
      Widget cellContent = FeedingBlock(entry: data.entries[i]);

      // 每個小時格都需要一個 Expanded
      hourWidgets.add(
        Expanded(
          flex: 1,
          child: Stack(
            // 使用 Stack 讓內容和虛線重疊
            children: [
              // 1. 內容區 (FeedingBlock)
              cellContent,

              // 2. 垂直分割線 (虛線/實線) - 定位在左側
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                // 第一格 (i=0) 不需要左邊線
                child: i == 0
                    ? const SizedBox.shrink()
                    : isFeedingTime
                    ? Container( // 有數據時使用實線
                  width: 1.w,
                  color: Colors.grey.shade300,
                )
                    : VerticalDashedLine( // 無數據時使用虛線 (CustomPainter 實現)
                  height: 50, // 50.h
                  color: Colors.grey.shade300,
                  dashLength: 6,
                  dashSpace: 3,
                ),
              ),
            ],
          ),
        ),
      );
    } // for 迴圈結束

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 中間數據區 (小時格)
        Expanded(
          child: Container(
            // 數據行底部的細灰線
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: hourWidgets,
            ),
          ),
        ),

        VerticalDashedLine( // <--- 確保您使用的是 Widget: VerticalDashedLine
          height: 50.h,
          color: Colors.black,
          dashLength: 6,
          dashSpace: 3,
        ),
        
        // 最右側總和 (固定寬度 50.w)
        Container(
          width: 50.w,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 8.0),
          // 確保總和欄位的高度與內容對齊
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '${data.totalMl}ml',
              textScaler: const TextScaler.linear(1),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}


/// *** 重命名 ***：原有的 FeedingRow 現在是 FullFeedingRow
class FullFeedingRow extends StatelessWidget {
  final DailyFeedingData data;
  const FullFeedingRow({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左側日期標籤 (固定寬度 50.w, 不在黑框內)
        Container(
          width: 40.w,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 4.0, top: 4.0, bottom: 4.0), // 增加 padding 以對齊內容
          child: Text(
            data.dateLabel,
            textScaler: const TextScaler.linear(1),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, height: 1.2, color: Colors.black),
          ),
        ),

        // 數據區 (小時格 + 總和)
        Expanded(
          child: FeedingRowData(data: data),
        ),
      ],
    );
  }
}

// =====================================================
// 3. 主元件：餵食記錄圖表 (驅動外部數據)
// =====================================================

class FeedingChart extends StatelessWidget {
  final DateTime selectedMonth;
  final List<View_DAILY> view_DAILYs;
  final List<DAILY_MLK_ITEM> daily_MLK_ITEMs;

  // 小時範圍 (08, 09, ..., 18)
  final List<int> hours = List<int>.generate(11, (i) => i + 8);

  late final List<DailyFeedingData> chartData;

  FeedingChart({
    super.key,
    required this.selectedMonth,
    required this.view_DAILYs,
    required this.daily_MLK_ITEMs,
  }) {
    // 根據外部數據生成圖表數據
    chartData = generateFeedingData(
      selectedMonth: selectedMonth,
      view_DAILYs: view_DAILYs,
      DAILY_MLK_ITEMs: daily_MLK_ITEMs,
    );
  }

  // 構建母乳與配方乳圖例
  Widget _buildLegend() {
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
          // 使用外部提供的名稱作為圖例文本
          Text(label, textScaler: const TextScaler.linear(1), style: TextStyle(color: Colors.black, fontSize: 14.sp, fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
        ],
      );
    }

    // 根據 DAILY_MLK_ITEMs 構造圖例 (假設 '母乳'/'配方奶' 字樣存在於 ITEM_NM 中)
    String breastMilkLabel = daily_MLK_ITEMs.firstWhere((item) => item.ITEM_NM.contains('母乳'), orElse: () => DAILY_MLK_ITEM()).ITEM_NM;
    String formulaLabel = daily_MLK_ITEMs.firstWhere((item) => item.ITEM_NM.contains('配方奶'), orElse: () => DAILY_MLK_ITEM()).ITEM_NM;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          legendItem(const Color(0xFFFFC043), breastMilkLabel), // 黃色
          legendItem(const Color(0xFF7CB342), formulaLabel),    // 綠色
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

    return Row(
      children: [
        // 左側日期佔位符 (寬度 50.w)
        SizedBox(width:40.w),

        // 數據區域對齊區 (小時格 + 總和)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              //color: Colors.grey.shade100,
              // 底部小時標題需要上方的黑邊，與數據區的下邊對齊
              border: Border(top: BorderSide(color: Colors.black, width: 1.w)),
            ),
            child: Row(
              children: [
                // 小時標題 (08~18)
                Expanded(child: Row(children: hourTitles)),
                // 右側總和佔位符 (寬度 50.w)
                SizedBox(width: 50.w),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 數據內容區 (帶黑色邊框)
  Widget _buildDataAreaWithBorder() {
    return Row(
      children: [
        // 左側日期標籤佔位符 (寬度 50.w)
        SizedBox(width: 50.w),

        // 數據區和總和區，帶有黑色邊框
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              // 設置黑色邊框 (只包圍數據區和總和區)
              border: Border.all(color: Colors.black, width: 1.w),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: chartData.length,
              itemBuilder: (context, index) {
                // 這裡我們直接渲染 FullFeedingRow 的數據區部分，因為日期在外面已經佔位
                // 需要修改 FullFeedingRow 讓它能被拆開使用
                return FeedingRowData(data: chartData[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  // 數據內容區（包含日期和數據，可滾動）
  Widget _buildScrollableContent() {
    // 確保將 FullFeedingRow 結構應用到每個列表項
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: chartData.length,
      itemBuilder: (context, index) {
        return FullFeedingRow(data: chartData[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. 母乳/配方乳圖例 (在最頂端)
        _buildLegend(),

        // 2. 數據內容區 (頂部黑線)
        // 頂部黑線寬度需要擴展到整個數據區
        Row(
          children: [
            SizedBox(width: 40.w), // 日期欄佔位
            Expanded(child: Container(height: 1.w, color: Colors.black)),
          ],
        ),

        // 3. 數據內容區（可滾動）
        Expanded(
          child: Stack( // 使用 Stack 來疊加左右黑邊
            children: [
              // 內容區 (包含日期和數據)
              ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: chartData.length,
                itemBuilder: (context, index) {
                  // 直接渲染 FullFeedingRow，它包含了日期
                  return FullFeedingRow(data: chartData[index]);
                },
              ),

              // 4. 左側黑邊 (數據區開始處，排除日期欄)
              Positioned(
                top: 0,
                bottom: 0,
                left: 40.w, // 定位在日期欄右側
                child: Container(
                  width: 1.w,
                  color: Colors.black,
                ),
              ),

              // 5. 右側黑邊 (數據區結束處)
              Positioned(
                top: 0,
                bottom: 0,
                right: 0,
                child: Container(
                  width: 1.w,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),

        // 6. 底部小時標題 (含上黑線)
        _buildBottomHourTitle(),
      ],
    );
  }
}