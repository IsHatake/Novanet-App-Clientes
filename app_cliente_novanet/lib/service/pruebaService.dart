// ignore_for_file: use_build_context_synchronously, camel_case_types, sized_box_for_whitespace, non_constant_identifier_names, file_names

import 'dart:convert';
import 'package:app_cliente_novanet/service/signalRChat_Service.dart';
import 'package:app_cliente_novanet/utils/normaltextfild.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/home/home.dart';
//import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:http/http.dart' as http;
import 'package:app_cliente_novanet/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

Future<void> fetchLogin(
  BuildContext context,
  String fcUsuarioAcceso,
  String fcPassword,
  bool fbprincipal,
  Color backgroundColor,
  Color color,
) async {
  // Mostrar dialog de animación "Iniciando sesión" relacionado con internet (ondas WiFi)
  showDialog(
  context: context,
  barrierDismissible: false,
  builder: (BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitWave(
                color: Colors.white,
                size: 60.0,
              ),
              SizedBox(height: 20),
              Text(
                'Iniciando sesión...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);


  try {
    final prefs = await SharedPreferences.getInstance();

    // Guardar usuario y contraseña en caché
    prefs.setString("UsuarioCache", fcUsuarioAcceso);
    prefs.setString("ContraseniaCache", fcPassword);

    final response = await http.get(Uri.parse(
      '${apiUrl}Login/LoginApp?fcUsuarioAcceso=$fcUsuarioAcceso&fcPassword=$fcPassword&fbprincipal=$fbprincipal',
    ));

    // Cerrar el dialog de animación
    Navigator.of(context).pop();

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        // Validación: asegurarnos que data tenga al menos 5 elementos
        final List<dynamic> data = decoded;

        final bool isLoginValido = List.generate(
          5,
          (index) => index < data.length && data[index].isNotEmpty,
        ).any((e) => e);

        if (isLoginValido) {
          final loginData = (data.length > 0 && data[0].isNotEmpty) ? data[0][0] : {};
          final identidadData = (data.length > 1 && data[1].isNotEmpty) ? data[1][0] : {};
          final llaveUnica = (data.length > 5 && data[5].isNotEmpty)
              ? data[5][0]["fcLlaveUnica"] ?? ''
              : '';

          DNIData(context, identidadData["fcIdentidad"] ?? '');

          prefs.setString("fiIDUnico", loginData["fiIDUnico"]?.toString() ?? '');
          prefs.setString("fcUsuarioAcceso", loginData["fcUsuarioAcceso"]?.toString() ?? '');
          prefs.setString("fcNombreUsuario", loginData["fcNombreUsuario"]?.toString() ?? '');
          prefs.setString("fcTelefono", loginData["fcTelefono"]?.toString() ?? '');
          prefs.setString("fbAccesoCamaras", loginData["fbAccesoCamaras"]?.toString() ?? '');
          
          prefs.setString("fiIDCliente", loginData["fiIDCliente"]?.toString() ?? '');
          prefs.setString("fiIDCuentaFamiliar", loginData["fiIDCuentaFamiliar"]?.toString() ?? '');
          prefs.setString("fcIdentidad", identidadData["fcIdentidad"]?.toString() ?? '');
          prefs.setString("fcURLFotoPersonalizda", loginData["NombreArchivo"]?.toString() ?? '');
          prefs.setString("fcLlaveUnica", llaveUnica);

          // Guardar los arreglos existentes (0 a 4)
          for (int i = 0; i <= 4; i++) {
            if (i < data.length) {
              prefs.setString("datalogin[$i]", jsonEncode(data[i]));
            }
          }

          // Navegar al Home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Home(fbprincipal: fbprincipal),
            ),
          );
        } else {
          // Credenciales inválidas
          CherryToast.warning(
            backgroundColor: backgroundColor,
            title: Text(
              'Usuario o Contraseña Incorrectos',
              style: TextStyle(color: color),
              textAlign: TextAlign.start,
            ),
            borderRadius: 5,
          ).show(context);
        }
      } else {
        // El backend no devolvió una lista
        CherryToast.warning(
          backgroundColor: backgroundColor,
          title: Text(
            'Respuesta inesperada del servidor',
            style: TextStyle(color: color),
            textAlign: TextAlign.start,
          ),
          borderRadius: 5,
        ).show(context);
      }
    } else {
      // Status code no 200
      CherryToast.warning(
        backgroundColor: backgroundColor,
        title: Text(
          'Error de conexión: ${response.statusCode}',
          style: TextStyle(color: color),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
    }
  } catch (e) {
    // Cerrar el dialog en caso de error
    Navigator.of(context).pop();
    if (kDebugMode) print(e);
    CherryToast.warning(
      backgroundColor: backgroundColor,
      title: Text(
        'No se ha podido conectar al Servidor',
        style: TextStyle(color: color),
        textAlign: TextAlign.start,
      ),
      borderRadius: 5,
    ).show(context);
  }
}





Future<void> fetchDatosRegistro(
    BuildContext context, int pilDUsuario, int pilDSolicitud) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.get(Uri.parse(
        '${apiUrl}Prueba/ListPrueba?pilDUsuario=34&pilDSolicitud=$pilDSolicitud'));

    if (kDebugMode) {
      print(response);
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data[0].toString().isNotEmpty) {
        prefs.setString("data[0]", jsonEncode(data[0]));
      }

      if (data[1].toString().isNotEmpty) {
        prefs.setString("data[1]", jsonEncode(data[1]));
      }

      if (data[2].toString().isNotEmpty) {
        prefs.setString("data[2]", jsonEncode(data[2]));
      }

      if (data[3].toString().isNotEmpty) {
        prefs.setString("data[3]", jsonEncode(data[3]));
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  } finally {}
}

DNIData(BuildContext context, pcIdentidadCliente) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.get(Uri.parse(
        '${apiUrl}Login/IdentidadRegistro?pcIdentidadCliente=$pcIdentidadCliente'));

    if (kDebugMode) {
      print(response);
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      prefs.setString("piIDSolicitud", data[0]['fiIDSolicitud'].toString());
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  } finally {}
}

Future<void> IdentidadRegistro(
    BuildContext context, TextEditingController pcIdentidadCliente) async {
  try {
    var newpcIdentidadCliente = pcIdentidadCliente.text.replaceAll("-", "");
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("Cliente", '');

    final response = await http.get(Uri.parse(
        '${apiUrl}Login/IdentidadRegistro?pcIdentidadCliente=$newpcIdentidadCliente'));

    if (kDebugMode) {
      print(response);
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data != null && data is List && data.isNotEmpty) {
        final fcCorreo = data[0]?["fcCorreo"];
        final fcNombre = data[0]?["fcNombre"];
        final fiIDEquifax = data[0]?['fiIDEquifax'];

        if (fcCorreo != null && fcNombre != null && fiIDEquifax != null) {
          prefs.setString("fcCorreo", fcCorreo);
          prefs.setString("fcNombre", fcNombre);
          prefs.setString("fiIDEquifax", fiIDEquifax.toString());
          prefs.setString("Cliente", 'SI');

          fetchDatosRegistro(context, 34, data[0]?["fiIDSolicitud"] ?? '');
        } else {}
      } else {
        prefs.setString("Cliente", 'NO');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  } finally {}
}
