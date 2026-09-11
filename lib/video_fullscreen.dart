import 'dart:convert';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_button/sign_button.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:developer' as dev;
import 'api.dart';
import 'sql.dart';
import 'package:video_player/video_player.dart';
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class VideoFullScreenPage extends StatefulWidget {
  String VIDEO_LINK="";//影片連結
  VideoFullScreenPage({String VIDEO_LINK=""}){
    this.VIDEO_LINK = VIDEO_LINK;
  }

  @override
  State<VideoFullScreenPage> createState() => _VideoFullScreenPageState(VIDEO_LINK: this.VIDEO_LINK);
}

class _VideoFullScreenPageState extends State<VideoFullScreenPage> {

  double _width=0;
  double _height=0;

  WebViewController? webViewController;
  String VIDEO_LINK="";//影片連結
  _VideoFullScreenPageState({String VIDEO_LINK=""}){
    this.VIDEO_LINK = VIDEO_LINK;
  }

  @override
  void initState() {
    // TODO: implement initState

    SystemChrome.setPreferredOrientations([
      //DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.initState();

    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    webViewController =
    WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    webViewController!
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
          onHttpAuthRequest: (HttpAuthRequest request) {
            dev.log("${request}");
          },
        ),
      )
      ..addJavaScriptChannel(
          'Toaster',
          onMessageReceived: (JavaScriptMessage message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message.message)),
            );
          })
      ..loadHtmlString('''<video src="${this.VIDEO_LINK}" autoplay preload="none" playsinline controls controlsList="nofullscreen" width="100%" height="100%"></video>''');
    //..loadRequest(Uri.parse('${s.VIDEO_LINK}'));

    // #docregion platform_features
    if (webViewController!.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (webViewController!.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

  }

  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      //DeviceOrientation.landscapeLeft,
      //DeviceOrientation.landscapeRight,
    ]);


    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    _width = MediaQuery
        .of(context)
        .size
        .width;
    _height = MediaQuery
        .of(context)
        .size
        .height;

    dev.log("_width:${_width}");

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
      body: SafeArea(child:Container(
          width: _width,
          height: _height,
          child:Stack(children: [

              Container(
                  color: Colors.black,
                  width: _width,
                  height: _height,
              child:Row(children: [

                Expanded(child: Container()),
                Expanded(flex:10,child: WebViewWidget(controller: webViewController!)),
                Expanded(child: Container()),

              ],)),

              Container(
                width: _width,
                height: _height,
              child: Column(children: [

                Row(children: [

                  GestureDetector(
                    onTap:(){
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        //DeviceOrientation.landscapeLeft,
                        //DeviceOrientation.landscapeRight,
                      ]);
                      Navigator.pop(context);
                    },
                      child: Container(color: Colors.black54,padding: EdgeInsets.all(2.h),child:
                  Icon(Icons.arrow_back,color: Colors.white,size: 24.sp,))),
                  Expanded(child: Container()),

                ],)

              ],))

          ],)),//page 0

    ))));
  }
}
