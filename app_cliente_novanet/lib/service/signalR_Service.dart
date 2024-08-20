// ignore_for_file: file_names, empty_catches

import 'package:app_cliente_novanet/service/notificaciones_Service.dart';
//import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignalRService {
  final HubConnection _hubConnection;

  SignalRService(String serverUrl)
      : _hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();

  Future<void> init() async {
    try {
      await _hubConnection.start();

      _hubConnection.on("ReceiveMessage", (arguments) async {
        try {
          if (arguments != null && arguments.length == 2) {
            List<String> users = List<String>.from(arguments[0] as List);
            String message = arguments[1] as String;

            final prefs = await SharedPreferences.getInstance();
            String fcNombreUsuarioFull =
                prefs.getString('fcUsuarioAcceso') ?? '';

            if (users.isEmpty || users.contains(fcNombreUsuarioFull)) {
              NotificationService()
                  .showNotification("Nueva notificación", message);
            } else {}
          } else {}
        } catch (e) {}
      });
    } catch (e) {}
  }
}
