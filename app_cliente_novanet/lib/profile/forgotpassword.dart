// ignore_for_file: unused_import

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/api.dart';
import 'package:app_cliente_novanet/profile/confirmPinPass.dart';
import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:app_cliente_novanet/utils/media.dart';
import 'package:app_cliente_novanet/utils/string.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../utils/colornotifire.dart';
import '../utils/textfeilds.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  late ColorNotifire notifire;
  TextEditingController emaiController = TextEditingController();

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  void _validarCorreo(email) async {
    final response = await http
        .get(Uri.parse('${apiUrl}Usuario/EmailTokenPassword?email=$email'));

    if (response.statusCode == 200) {
      String data = response.body;
      if (data.toString() == 'No encontrado') {
        CherryToast.warning(
          backgroundColor: notifire.getbackcolor,
          title: Text(
            'Correo no Encontrado',
            style: TextStyle(color: notifire.getdarkscolor),
            textAlign: TextAlign.start,
          ),
          borderRadius: 5,
        ).show(context);
      } else {
        var dataSplit = data.split(' ');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConfirmPinPass(
              fiIDUnico: int.parse(dataSplit[1]),
              backColor: notifire.getbackcolor,
              darkColor: notifire.getdarkscolor,
              token: dataSplit[0],
            ),
          ),
        );
      }
    } else {
      CherryToast.error(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          'Ha Ocurrido un Error Inesperado',
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Cambiar Contraseña',
          style: TextStyle(
              fontSize: height / 40,
              color: notifire.getdarkscolor,
              fontFamily: 'Gilroy Bold'),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: notifire.getdarkscolor),
        backgroundColor: notifire.getprimerycolor,
      ),
      backgroundColor: notifire.getprimerycolor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: height * 0.9,
              width: width,
              color: Colors.transparent,
              child: Image.asset(
                "images/background.png",
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: height / 20,
                ),
                Image.asset(
                  "images/forgotp.png",
                  height: height / 7,
                ),
                SizedBox(
                  height: height / 30,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: width / 20,
                    ),
                    Text(
                      CustomStrings.resetyourpassword,
                      style: TextStyle(
                        color: notifire.getdarkscolor,
                        fontSize: height / 40,
                        fontFamily: 'Gilroy Bold',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height / 100,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: width / 20,
                    ),
                    Text(
                      CustomStrings.linkemail,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: height / 60,
                        fontFamily: 'Gilroy Bold',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height / 40,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: width / 20,
                    ),
                    Text(
                      CustomStrings.email,
                      style: TextStyle(
                        color: notifire.getdarkscolor,
                        fontSize: height / 50,
                        fontFamily: 'Gilroy Bold',
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height / 60,
                ),
                LoginTxt.textField(
                    notifire.getdarkscolor,
                    notifire.getdarkgreycolor,
                    notifire.getbluecolor,
                    "images/email.png",
                    CustomStrings.emailhint,
                    notifire.getdarkwhitecolor,
                    emaiController),
                SizedBox(
                  height: height / 2.8,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width / 20),
                  child: GestureDetector(
                    onTap: () {
                      if (emaiController.text.isNotEmpty) {
                        _validarCorreo(emaiController.text);
                      } else {
                        CherryToast.warning(
                          backgroundColor: notifire.getbackcolor,
                          title: Text(
                            'Llene el campo vacio',
                            style: TextStyle(color: notifire.getdarkscolor),
                            textAlign: TextAlign.start,
                          ),
                          borderRadius: 5,
                        ).show(context);
                      }
                    },
                    child: Container(
                      height: height / 17,
                      width: width,
                      decoration: BoxDecoration(
                        color: notifire.getorangeprimerycolor,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          CustomStrings.sendemail,
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Gilroy Medium',
                              fontSize: height / 50),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
