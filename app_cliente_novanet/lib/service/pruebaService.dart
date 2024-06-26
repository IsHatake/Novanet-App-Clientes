// ignore_for_file: use_build_context_synchronously, camel_case_types, sized_box_for_whitespace, non_constant_identifier_names, file_names

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/home/home.dart';
import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:http/http.dart' as http;
import 'package:app_cliente_novanet/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> fetchLogin(
  BuildContext context,
  String fcUsuarioAcceso,
  String fcPassword,
  backgroundColor,
  color,
) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("UsuarioCache", fcUsuarioAcceso);
    prefs.setString("ContraseniaCache", fcPassword);

    final response = await http.get(Uri.parse(
        '${apiUrl}Login/LoginApp?fcUsuarioAcceso=$fcUsuarioAcceso&fcPassword=$fcPassword'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data[0].isNotEmpty ||
          data[1].isNotEmpty ||
          data[2].isNotEmpty ||
          data[3].isNotEmpty ||
          data[4].isNotEmpty) {
        DNIData(context, data[1][0]["fcIdentidad"]);
        prefs.setString("fiIDUnico", data[0][0]["fiIDUnico"].toString());
        prefs.setString(
            "fcUsuarioAcceso", data[0][0]["fcUsuarioAcceso"].toString());
        prefs.setString(
            "fcNombreUsuario", data[0][0]["fcNombreUsuario"].toString());
        prefs.setString("fcTelefono", data[0][0]["fcTelefono"].toString());
        prefs.setString("fiIDCliente", data[0][0]["fiIDCliente"].toString());
        prefs.setString("fcIdentidad", data[1][0]["fcIdentidad"].toString());
        prefs.setString(
            "fcURLFotoPersonalizda", data[0][0]["NombreArchivo"].toString());

        prefs.setString("datalogin[0]", jsonEncode(data[0]));
        prefs.setString("datalogin[1]", jsonEncode(data[1]));
        prefs.setString("datalogin[2]", jsonEncode(data[2]));
        prefs.setString("datalogin[3]", jsonEncode(data[3]));
        prefs.setString("datalogin[4]", jsonEncode(data[4]));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      } else {
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
    }
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
    CherryToast.warning(
      backgroundColor: backgroundColor,
      title: Text(
        'No se ha podido conectar al Servidor',
        style: TextStyle(color: color),
        textAlign: TextAlign.start,
      ),
      borderRadius: 5,
    ).show(context);
  } finally {}
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
