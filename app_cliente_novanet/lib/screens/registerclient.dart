import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/login/login.dart';
import 'package:app_cliente_novanet/screens/formwebPrecalificado.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/button.dart';
import '../utils/colornotifire.dart';
import '../utils/string.dart';
import '../utils/textfeilds.dart';
import 'package:http/http.dart' as http;
import 'package:app_cliente_novanet/api.dart';

class Registerclient extends StatefulWidget {
  const Registerclient({Key? key}) : super(key: key);

  @override
  State<Registerclient> createState() => _RegisterclientState();
}

class _RegisterclientState extends State<Registerclient> {
  late ColorNotifire notifire;
  final TextEditingController _identidadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getDarkModePreviousState();
  }

  Future<void> getDarkModePreviousState() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setIsDark");
    if (previousState == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previousState;
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

    fetchURL();
  }

  Future<void> fetchURL() async {
    var dni = _identidadController.text.replaceAll("-", "");
    final response = await http.get(
        Uri.parse('${apiUrl}ClientesPrecalificados/DNIPrecalificado?dni=$dni'));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      if (data.isNotEmpty && data[0]["fiIdequifax"] != null) {
        String fiIdequifax = data[0]["fiIdequifax"].toString();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                formwebPrecalificado(fiIdequifax: fiIdequifax),
          ),
        );
      } else {
        CherryToast.warning(
          backgroundColor: notifire.getbackcolor,
          title: Text(
            'Cliente no Encontrado',
            style: TextStyle(color: notifire.getdarkscolor),
            textAlign: TextAlign.start,
          ),
          borderRadius: 5,
        ).show(context);
        return;
      }
    }
  }

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
          CustomStrings.register,
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
