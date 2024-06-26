// ignore_for_file: empty_catches

import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class LocalAuth {
  static final _auth = LocalAuthentication();

  static Future<bool> _canAuthenticate() async =>
      await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

  static Future<bool> authenticate() async {
    try {
      if (!await _canAuthenticate()) return false;

      return await _auth.authenticate(
          localizedReason: 'Por favor autentícate para iniciar sesión',
          options: const AuthenticationOptions(
              useErrorDialogs: true, stickyAuth: true),
          authMessages: const [
            AndroidAuthMessages(
              signInTitle: 'Iniciar Sesión',
              cancelButton: 'No Gracias',
            ),
            IOSAuthMessages(
              cancelButton: 'No Gracias',
            ),
          ]);
    } catch (e) {
      // Handle exceptions here if needed
      return false;
    }
  }
}
