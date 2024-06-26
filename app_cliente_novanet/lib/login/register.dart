// ignore_for_file: non_constant_identifier_names

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/login/confirmpin.dart';
import 'package:app_cliente_novanet/login/login.dart';
import 'package:app_cliente_novanet/service/usuarioService.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/button.dart';
import '../utils/colornotifire.dart';
import '../utils/string.dart';
import '../utils/textfeilds.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app_cliente_novanet/api.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late ColorNotifire notifire;

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  Future<void> handleTap() async {
    if (_identidadController.text.isEmpty) {
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'Llene el campo vacio',
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }
    if (_identidadController.text.length != 15) {
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'Se requieren 13 dígitos para el campo de identidad',
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    IdentidadRegistro(context, _identidadController);
  }

  Future<void> IdentidadRegistro(
      BuildContext context, TextEditingController pcIdentidadCliente) async {
    try {
      var newpcIdentidadCliente = pcIdentidadCliente.text.replaceAll("-", "");
      final response = await http.get(Uri.parse(
          '${apiUrl}Login/IdentidadRegistro?pcIdentidadCliente=$newpcIdentidadCliente'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data is List && data.isNotEmpty) {
          final fcCorreo = data[0]?["fcCorreo"];
          final fcNombre = data[0]?["fcNombre"];
          final fiIDEquifax = data[0]?['fiIDEquifax'];
          final usuarioExiste = data[0]?['usuarioExiste'];

          if (usuarioExiste == 'SI') {
            CherryToast.info(
              backgroundColor: notifire.getbackcolor,
              title: Text(
                'Ya cuenta con un Usuario como Cliente',
                style: TextStyle(color: notifire.getdarkscolor),
                textAlign: TextAlign.start,
              ),
              borderRadius: 5,
            ).show(context);
          } else {
            String tokenAPI = await fetchTokenAPI(
              context,
              notifire.getbackcolor,
              notifire.getdarkscolor,
              fcCorreo,
            );
            
            if (tokenAPI.isEmpty) {
              CherryToast.error(
                backgroundColor: notifire.getbackcolor,
                title: Text(
                  'Ha Ocurrido un Error Inesperado',
                  style: TextStyle(color: notifire.getdarkscolor),
                  textAlign: TextAlign.start,
                ),
                borderRadius: 5,
              ).show(context);
              return;
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ConfirmPin(
                  tokenAPI: tokenAPI,
                  fcCorreo: fcCorreo,
                  fcNombre: fcNombre,
                  fiIDEquifax: fiIDEquifax,
                  backColor: notifire.getbackcolor,
                  darkColor: notifire.getdarkscolor,
                ),
              ),
            );
          }
        } else {
          CherryToast.warning(
            backgroundColor: notifire.getbackcolor,
            title: Text(
              'Necesitas ser un cliente de Novanet',
              style: TextStyle(color: notifire.getdarkscolor),
              textAlign: TextAlign.start,
            ),
            borderRadius: 5,
          ).show(context);
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    } finally {}
  }

  final TextEditingController _identidadController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        backgroundColor: notifire.getprimerycolor,
        title: Text(
          'Registrarme como Usuario',
          style: TextStyle(
            color: notifire.getdarkscolor,
            fontFamily: 'Gilroy Bold',
            fontSize: MediaQuery.of(context).size.height / 35,
          ),
        ),
      ),
      backgroundColor: notifire.getprimerycolor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.transparent,
                  child: Image.asset(
                    "images/background.png",
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 20,
                    ),
                    Stack(
                      children: [
                        Center(
                          child: Container(
                            height: MediaQuery.of(context).size.height / 1.22,
                            width: MediaQuery.of(context).size.width / 1.1,
                            decoration: BoxDecoration(
                              color: notifire.gettabwhitecolor,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              reverseDuration:
                                  const Duration(milliseconds: 200),
                              switchInCurve: Curves.decelerate,
                              switchOutCurve: Curves.decelerate,
                              child: _buildDNIContent(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          CustomStrings.accounts,
                          style: TextStyle(
                            color: notifire.getdarkgreycolor.withOpacity(0.6),
                            fontSize: MediaQuery.of(context).size.height / 50,
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 100,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                            );
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: Text(
                              'Inicia Sesión',
                              style: TextStyle(
                                color: notifire.getdarkscolor,
                                fontSize:
                                    MediaQuery.of(context).size.height / 60,
                                fontFamily: 'Gilroy Medium',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 60,
                    ),
                    Center(
                      child: Image.asset(
                        "images/logos.png",
                        height: MediaQuery.of(context).size.height / 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextRow(String text) {
    return Row(
      children: [
        SizedBox(width: MediaQuery.of(context).size.width / 18),
        Text(
          text,
          style: TextStyle(
            color: notifire.getdarkscolor,
            fontSize: MediaQuery.of(context).size.height / 50,
          ),
        ),
      ],
    );
  }

  Widget _buildDNIContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 15,
        ),
        _buildTextRow("Ingrese su DNI"),
        SizedBox(height: MediaQuery.of(context).size.height / 70),
        DNI.textField(
          notifire.getdarkscolor,
          notifire.getdarkgreycolor,
          notifire.getorangeprimerycolor,
          "images/DNI.png",
          "DNI",
          notifire.getdarkwhitecolor,
          _identidadController,
        ),
        SizedBox(height: MediaQuery.of(context).size.height / 35),
        GestureDetector(
          onTap: () {
            handleTap();
          },
          child: Custombutton.button(
            notifire.getorangeprimerycolor,
            "Verificar",
            MediaQuery.of(context).size.width / 2,
          ),
        ),
      ],
    );
  }
}
