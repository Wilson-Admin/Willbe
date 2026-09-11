import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final double? leadingWidth; // 🔥 支援自訂 leading 寬度
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? toolbarHeight;
  final bool? centerTitle;
  final double? elevation;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    super.key,
    this.title,
    this.leading,
    this.leadingWidth,
    this.actions,
    this.backgroundColor,
    this.toolbarHeight,
    this.centerTitle = true,
    this.elevation = 0,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final double actualToolbarHeight = toolbarHeight ?? 42.h;

    return AppBar(
      backgroundColor: backgroundColor ?? const Color(0xffF9AA88),
      toolbarHeight: actualToolbarHeight,
      centerTitle: centerTitle,
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      leadingWidth: leadingWidth, // 🔥 傳入 AppBar
      title: title,
      // 自動將 actions 內的所有元件（例如文字、圖示）包裹 Center 做垂直置中
      actions: actions?.map((widget) {
        // 如果是間距元件 (SizedBox/Container) 則不需重複包 Center
        if (widget is SizedBox || (widget is Container && widget.child == null)) {
          return widget;
        }
        return Center(child: widget);
      }).toList(),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? 42.h);
}