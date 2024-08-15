import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({Key? key}) : super(key: key);

  @override
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  @override
  void initState() {
    super.initState();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        InAppUpdate.performImmediateUpdate().catchError((e) {
          // Manejar el error de la actualización, por ejemplo, mostrar un mensaje
          print("Error durante la actualización: $e");
        });
      }
    } catch (e) {
      // Manejar cualquier error al verificar la actualización
      print("Error al verificar actualizaciones: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi App'),
      ),
      body: Center(
        child: const Text('Pantalla principal'),
      ),
    );
  }
}
