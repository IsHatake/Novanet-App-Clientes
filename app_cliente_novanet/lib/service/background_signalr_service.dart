// ignore_for_file: avoid_print

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signalr_netcore/signalr_client.dart';

// Nombre del puerto para comunicación (opcional)
const String isolateName = 'signalr_background_service';

Future<void> initializeBackgroundSignalRService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // Esta función se ejecuta en el isolate de background
      onStart: onBackgroundSignalRStart,
      isForegroundMode: true, // Obligatorio para mantener vivo en Android
      autoStart: true,
      notificationChannelId: 'signalr_channel',
      foregroundServiceNotificationId: 999,
      initialNotificationTitle: 'Servicio SignalR',
      initialNotificationContent: 'Conectado y escuchando notificaciones',
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onBackgroundSignalRStart,
      onBackground: onIosBackground,
    ),
  );

  // Iniciar el servicio automáticamente
  service.startService();
}

// Función que corre en background
@pragma('vm:entry-point')
Future<void> onBackgroundSignalRStart(ServiceInstance service) async {
  // Inicializar notificaciones locales (para mostrar alertas cuando llegue mensaje)
  final FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

  const InitializationSettings initSettings = InitializationSettings(
    android: androidInit,
    iOS: iosInit,
  );

  await notifications.initialize(initSettings);

  // Conectar a SignalR
  const String serverUrl = 'https://api.novanetgroup.com/notificaciones';

  final HubConnection hubConnection = HubConnectionBuilder()
      .withUrl(serverUrl)
      .withAutomaticReconnect() // Reconexión automática si se cae
      .build();

  hubConnection.on("ReceiveMessage", (List<Object?>? arguments) async {
    if (arguments == null || arguments.length < 2) return;

    try {
      final List<String> users = List<String>.from(arguments[0] as List<dynamic>);
      final String message = arguments[1] as String;

      final prefs = await SharedPreferences.getInstance();
      final String? usuarioFull = prefs.getString('fcUsuarioAcceso');

      if (usuarioFull != null && (users.isEmpty || users.contains(usuarioFull))) {
        // Mostrar notificación local
        const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
          'signalr_channel',
          'Notificaciones SignalR',
          channelDescription: 'Notificaciones en background',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          playSound: true,
        );

        const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

        await notifications.show(
          0,
          'Nueva notificación',
          message,
          platformDetails,
        );
      }
    } catch (e) {
      print('Error al procesar mensaje en background: $e');
    }
  });

  // Reconexión automática si se pierde la conexión
  hubConnection.onclose(({Exception? error}) async {
    print('SignalR desconectado en background. Intentando reconectar...');
    await Future.delayed(const Duration(seconds: 5));
    try {
      await hubConnection.start();
      print('SignalR reconectado en background');
    } catch (e) {
      print('Error al reconectar: $e');
    }
  });

  try {
    await hubConnection.start();
    print('SignalR conectado en background');
  } catch (e) {
    print('Error inicial al conectar SignalR en background: $e');
  }

  // Escuchar comando para detener (opcional desde la UI)
  service.on('stopService').listen((event) {
    hubConnection.stop();
    service.stopSelf();
  });
}

// Para iOS (background fetch limitado)
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}