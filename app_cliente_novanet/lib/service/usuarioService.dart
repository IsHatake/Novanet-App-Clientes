// ignore_for_file: use_build_context_synchronously, camel_case_types, sized_box_for_whitespace, non_constant_identifier_names, file_names, control_flow_in_finally

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/login/done.dart';
import 'package:app_cliente_novanet/models/UsuariosViewModel.dart';
import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:http/http.dart' as http;
import 'package:app_cliente_novanet/api.dart';

Future<void> sendUsuarioCreacion(
  BuildContext context,
  String fcPassword,
  int fiIdcliente,
  backgroundColor,
  color,
) async {
  try {
    UsuarioCreate UsuarioData = UsuarioCreate(
        fcUsuarioAcceso: '', fcPassword: fcPassword, fiIdcliente: fiIdcliente);

    String usuarioJson = jsonEncode(UsuarioData);

    final response = await http.post(
      Uri.parse('${apiUrl}Usuario/Insert'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: usuarioJson,
    );
    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);
      final codeStatus = decodedJson["code"];
      final messageStatus = decodedJson["message"];

      if (codeStatus.toString() == '200') {
        CherryToast.success(
          backgroundColor: backgroundColor,
          title: Text(
            '$messageStatus',
            style: TextStyle(color: color),
            textAlign: TextAlign.start,
          ),
          borderRadius: 5,
        ).show(context);

        Future.delayed(const Duration(seconds: 3), () {});
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VerificationDone(),
          ),
        );
      } else if (codeStatus.toString() == '409') {
        CherryToast.warning(
          backgroundColor: backgroundColor,
          title: Text('$messageStatus',
              style: TextStyle(color: color), textAlign: TextAlign.start),
          borderRadius: 5,
        ).show(context);
      } else {
        CherryToast.error(
          backgroundColor: backgroundColor,
          title: Text('$messageStatus',
              style: TextStyle(color: color), textAlign: TextAlign.start),
          borderRadius: 5,
        ).show(context);
      }
    }
  } catch (e) {
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

Future<void> sendUsuarioFamiliarCreacion(
  BuildContext context,
  String fcCorreo,
  String fcNombreUsuario,
  String fcPassword,
  String? fiIdcliente,
  backgroundColor,
  color,
) async {
  try {
    UsuarioFamiliarCreate UsuarioData = UsuarioFamiliarCreate(
        fcUsuarioAcceso: fcCorreo,
        fcPassword: fcPassword,
        fiIdcliente: int.parse(fiIdcliente ?? '0'),
        fcNombreUsuario: fcNombreUsuario);

    String usuarioJson = jsonEncode(UsuarioData);

    final response = await http.post(
      Uri.parse('${apiUrl}Usuario/InsertUsuarioFamiliar'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: usuarioJson,
    );
    if (response.statusCode == 200) {
      final decodedJson = jsonDecode(response.body);
      final codeStatus = decodedJson["code"];
      final messageStatus = decodedJson["message"];

      if (codeStatus.toString() == '200') {
        CherryToast.success(
          backgroundColor: backgroundColor,
          title: Text(
            '$messageStatus',
            style: TextStyle(color: color),
            textAlign: TextAlign.start,
          ),
          borderRadius: 5,
        ).show(context);

        Future.delayed(const Duration(seconds: 3), () {});
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VerificationDone(),
          ),
        );
      } else if (codeStatus.toString() == '409') {
        CherryToast.warning(
          backgroundColor: backgroundColor,
          title: Text('$messageStatus',
              style: TextStyle(color: color), textAlign: TextAlign.start),
          borderRadius: 5,
        ).show(context);

        return;
      } else {
        CherryToast.error(
          backgroundColor: backgroundColor,
          title: Text('$messageStatus',
              style: TextStyle(color: color), textAlign: TextAlign.start),
          borderRadius: 5,
        ).show(context);
      }
    }
  } catch (e) {
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

Future<String> fetchTokenAPI(
  BuildContext context,
  Color backgroundColor,
  Color color,
  String correo,
) async {
  try {
    final response =
        await http.post(Uri.parse('${apiUrl}Usuario/EmailToken?email=$correo'));

    if (response.statusCode == 200) {
      return response.body.toString();
    } else {
      CherryToast.warning(
        backgroundColor: backgroundColor,
        title: Text(
          'No se ha podido conectar al Servidor',
          style: TextStyle(color: color),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return '';
    }
  } catch (e) {
    CherryToast.warning(
      backgroundColor: backgroundColor,
      title: Text(
        'No se ha podido conectar al Servidor',
        style: TextStyle(color: color),
        textAlign: TextAlign.start,
      ),
      borderRadius: 5,
    ).show(context);
    return '';
  }
}
