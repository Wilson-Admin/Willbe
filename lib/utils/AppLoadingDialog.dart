import 'package:code3/main.dart';
import 'package:flutter/material.dart';

class AppLoadingDialog {
  static bool _isShowing = false;
  static Route<dynamic>? _loadingRoute;

  // ⭐ 用於即時更新訊息
  static final ValueNotifier<String?> _messageNotifier = ValueNotifier(null);

  /// 顯示 Loading Dialog（若已顯示，改為更新文字）
  static void show({String? message, bool barrierDismissible = false}) {
    final BuildContext? context = navigatorKey.currentContext;

    if (_isShowing) {
      _messageNotifier.value = message;
      return;
    }

    if (context == null) return;
    _isShowing = true;

    // 初始訊息
    _messageNotifier.value = message;

    _loadingRoute = DialogRoute(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        final size = MediaQuery.of(context).size;
        final shortest = size.shortestSide; // 用較短邊當縮放基準

        // 📌 自動縮放系數（手機 360px 基準）
        double scale = shortest / 360;

        // 防止平板太大
        scale = scale.clamp(0.8, 1.6);

        return WillPopScope(
          onWillPop: () async => barrierDismissible,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20 * scale),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12 * scale,
                    offset: Offset(0, 4 * scale),
                  ),
                ],
              ),

              // 📌 Dialog 自動依螢幕調整大小
              constraints: BoxConstraints(
                maxWidth: 280 * scale,
                maxHeight: size.height * 0.8,
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // 📌 Loading 圖示自動縮放
                  SizedBox(
                    width: 40 * scale,
                    height: 40 * scale,
                    child: CircularProgressIndicator(strokeWidth: 3 * scale),
                  ),

                  SizedBox(height: 16 * scale),

                  // ⭐ 可即時更新文字
                  Flexible(
                    child: ValueListenableBuilder<String?>(
                      valueListenable: _messageNotifier,
                      builder: (_, text, __) {
                        if (text == null || text.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return SingleChildScrollView(
                          child: Text(
                            text,
                            textAlign: TextAlign.left,
                            textScaler: const TextScaler.linear(1),
                            // 📌 文字自動縮放
                            style: TextStyle(
                              fontSize: 16 * scale,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                              height: 1.3,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    navigatorKey.currentState!.push(_loadingRoute!).then((_) {
      _isShowing = false;
      _loadingRoute = null;
      _messageNotifier.value = null;
    });
  }

  /// 關閉 Loading Dialog
  static void dismiss() {
    final navigator = navigatorKey.currentState;

    if (_isShowing && navigator != null && _loadingRoute != null) {
      navigator.removeRoute(_loadingRoute!);
      _isShowing = false;
      _loadingRoute = null;
      _messageNotifier.value = null;
    }
  }
}
