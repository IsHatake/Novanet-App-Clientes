// ignore_for_file: camel_case_types, file_names

import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:app_cliente_novanet/utils/string.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewTest_screen extends StatefulWidget {
  const WebviewTest_screen({Key? key}) : super(key: key);

  @override
  _WebviewTest_screenState createState() => _WebviewTest_screenState();
}

String url = 'https://www.fast.com/es/';

class _WebviewTest_screenState extends State<WebviewTest_screen> {
  late ColorNotifire notifire;

  Future<void> getDarkModePreviousState() async {
    final prefs = await SharedPreferences.getInstance();
    final previousState = prefs.getBool("setIsDark") ?? false;
    notifire.setIsDark = previousState;
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          CustomStrings.test,
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Gilroy Bold',
            color: notifire.getwhite,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: notifire.getorangeprimerycolor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: notifire.getwhite),
            ),
            child: Icon(Icons.arrow_back, color: notifire.getwhite),
          ),
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }

  WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0x00000000))
    ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.contains(url)) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse(url));
}
