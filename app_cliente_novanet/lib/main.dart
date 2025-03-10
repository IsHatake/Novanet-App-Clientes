import 'package:app_cliente_novanet/service/notificaciones_Service.dart';
import 'package:app_cliente_novanet/service/signalRChat_Service.dart';
import 'package:app_cliente_novanet/service/signalR_Service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_cliente_novanet/splashscreen.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  final PermissionStatus notificationPermissionStatus = await Permission.notification.status;

  if (notificationPermissionStatus != PermissionStatus.granted) {
    final PermissionStatus result = await Permission.notification.request();

    if (result != PermissionStatus.granted) {
    }
  }

  final notificationService = NotificationService();
  await notificationService.init();

  final signalRService = SignalRService("https://api.novanetgroup.com/notificaciones");
  await signalRService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ColorNotifire(),
        ),
      ],
      child:  const MaterialApp(
        home: Splashscreen(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
