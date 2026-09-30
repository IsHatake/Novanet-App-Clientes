// ignore_for_file: camel_case_types, file_names, unused_field

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
  late final WebViewController _controller;
  final GlobalKey webViewKey = GlobalKey();
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    // El controller se crea una sola vez; si se crea en build() la página
    // se vuelve a cargar en cada reconstrucción.
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("Error WebView: ${error.errorCode} ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  Future<void> getDarkModePreviousState() async {
    final prefs = await SharedPreferences.getInstance();
    final previousState = prefs.getBool("setIsDark") ?? false;
    notifire.setIsDark = previousState;
  }

  // @override
  // void initState() {
  //   super.initState();
  //   FlutterForegroundTask.init(
  //     androidNotificationOptions: AndroidNotificationOptions(
  //       channelId: 'notification_channel_id',
  //       channelName: 'Foreground Notification',
  //       channelDescription: 'This notification appears when the foreground service is running.',
  //       channelImportance: NotificationChannelImportance.DEFAULT,
  //       priority: NotificationPriority.DEFAULT,
  //     ),
  //     iosNotificationOptions: const IOSNotificationOptions(),
  //     foregroundTaskOptions: const ForegroundTaskOptions(),
  //   );
  //   startForegroundTask();
  // }

  // void startForegroundTask() {
  //   FlutterForegroundTask.startService(
  //     notificationTitle: 'WebView en ejecución',
  //     notificationText: 'El WebView sigue ejecutándose en segundo plano.',
  //   );
  // }

  // @override
  // void dispose() {
  //   FlutterForegroundTask.stopService();
  //   super.dispose();
  // }

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
            color: notifire.getdarkscolor,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: notifire.getbackcolor,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            height: 40,
            width: 40,
            margin: const EdgeInsets.all(8),
            
            child: Icon(Icons.arrow_back, color: notifire.getdarkscolor),
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(
            key: webViewKey,
            controller: _controller,
          ),
          if (_progress < 100)
            LinearProgressIndicator(value: _progress / 100),
        ],
      ),
    );
  }
}
