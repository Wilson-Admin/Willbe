import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// -----------------------------------------------------
// 1. CustomPainter 實現：繪製虛線的邏輯
// -----------------------------------------------------

class VerticalDashedLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength; // 虛線段的長度
  final double dashSpace;  // 間隔的長度

  VerticalDashedLinePainter({
    required this.color,
    this.strokeWidth = 1,
    this.dashLength = 6,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double startY = 0;
    final double totalLength = dashLength + dashSpace;

    // 沿著左邊緣 (x=0) 繪製虛線段
    while (startY < size.height) {
      // 繪製線段
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashLength),
        paint,
      );
      // 移動到下一個線段的起點 (跳過間隔)
      startY += totalLength;
    }
  }

  @override
  bool shouldRepaint(covariant VerticalDashedLinePainter oldDelegate) {
    // 只有當參數發生變化時才重繪
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashLength != dashLength ||
        oldDelegate.dashSpace != dashSpace;
  }
}

// -----------------------------------------------------
// 2. 可重用的垂直虛線元件
// -----------------------------------------------------

/// 可重用的垂直虛線元件，高度為 50.h
class VerticalDashedLine extends StatelessWidget {
  final double height;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashSpace;

  const VerticalDashedLine({
    super.key,
    this.height = 50, // 預設為 50.h
    this.color =  Colors.black,
    this.strokeWidth = 1,
    this.dashLength = 6,
    this.dashSpace = 3,
  });

  @override
  Widget build(BuildContext context) {
    // 確保高度使用 ScreenUtil 進行適應性計算
    final double actualHeight = height.h;

    return SizedBox(
      // 設置寬度為筆畫寬度，高度為 50.h
      width: strokeWidth.w,
      height: actualHeight,

      child: CustomPaint(
        // 使用 CustomPaint 來呼叫我們的繪圖邏輯
        painter: VerticalDashedLinePainter(
          color: color,
          strokeWidth: strokeWidth,
          dashLength: dashLength,
          dashSpace: dashSpace,
        ),
      ),
    );
  }
}