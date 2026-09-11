import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'utils/CustomAppBar.dart';

class InAppWebViewPage extends StatefulWidget {
  final String url;
  const InAppWebViewPage({Key? key, required this.url}) : super(key: key);

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  InAppWebViewController? webViewController;

  String _convertYoutubeUrl(String url) {
    if (url.contains("watch?v=")) {
      final videoId = url.split("watch?v=").last;
      return "https://www.youtube.com/embed/$videoId?playsinline=0";
    }
    return url;
  }

  @override
  void initState() {
    super.initState();

    // 允許旋轉（全螢幕影片時需要）
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // 離開時恢復直式
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fixedUrl = _convertYoutubeUrl(widget.url);

    return Scaffold(
      appBar: CustomAppBar(
        backgroundColor: Colors.white,
        title: Text("瀏覽",textScaler: TextScaler.linear(1),style: TextStyle(fontSize: 20.sp),),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            if (await webViewController?.canGoBack() ?? false) {
              webViewController?.goBack();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(fixedUrl)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          allowsInlineMediaPlayback: true,
          mediaPlaybackRequiresUserGesture: false,
          useWideViewPort: true,
          supportZoom: true,
        ),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
      ),
    );
  }
}
