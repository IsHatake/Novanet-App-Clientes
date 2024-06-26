import 'dart:convert';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/models/UsuariosViewModel.dart';
import 'package:app_cliente_novanet/utils/media.dart';
import 'package:app_cliente_novanet/utils/string.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colornotifire.dart';
import '../utils/itextfield.dart';
import 'package:http/http.dart' as http;
import 'package:app_cliente_novanet/api.dart';

class ChangePassword extends StatefulWidget {
final int fiIDUnico;

  const ChangePassword({
    Key? key,
    required this.fiIDUnico,
  }) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  late ColorNotifire notifire;
  bool _obscureText2 = true;
  bool _obscureText3 = true;
  TextEditingController pcPassword = TextEditingController();
  TextEditingController pcPasswordConfirm = TextEditingController();
  bool show = false;
  String errorMessage = '';

  void _toggle2() {
    setState(() {
      _obscureText2 = !_obscureText2;
    });
  }

  void _toggle3() {
    setState(() {
      _obscureText3 = !_obscureText3;
    });
  }

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  void _validate(BuildContext context, String pcPassword,
      String pcPasswordConfirm, Color backColor, Color darksColor) {
    setState(() {
      show = true;
    });

    if (pcPassword.isEmpty || pcPasswordConfirm.isEmpty) {
      setState(() {
        errorMessage = 'Llene los Campos Vacios';
      });
      CherryToast.warning(
        backgroundColor: backColor,
        title: Text(
          errorMessage,
          style: TextStyle(color: darksColor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    if (pcPassword != pcPasswordConfirm) {
      setState(() {
        errorMessage = 'Las contraseñas no coinciden';
      });
      CherryToast.warning(
        backgroundColor: backColor,
        title: Text(
          errorMessage,
          style: TextStyle(color: darksColor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    if (pcPassword.length < 8) {
      setState(() {
        errorMessage = 'La contraseña debe tener al menos 8 caracteres';
      });
      CherryToast.warning(
        backgroundColor: backColor,
        title: Text(
          errorMessage,
          style: TextStyle(color: darksColor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    if (!RegExp(r'[A-Z]').hasMatch(pcPassword)) {
      setState(() {
        errorMessage = 'La contraseña debe tener al menos una letra mayúscula';
      });
      CherryToast.warning(
        backgroundColor: backColor,
        title: Text(
          errorMessage,
          style: TextStyle(color: darksColor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    if (!RegExp(r'[a-z]').hasMatch(pcPassword)) {
      setState(() {
        errorMessage = 'La contraseña debe tener al menos una letra minúscula';
      });
      CherryToast.warning(
        backgroundColor: backColor,
        title: Text(
          errorMessage,
          style: TextStyle(color: darksColor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    if (!RegExp(r'[0-9]').hasMatch(pcPassword)) {
      setState(() {
        errorMessage = 'La contraseña debe tener al menos un número';
      });
      CherryToast.warning(
        backgroundColor: backColor,
        title: Text(
          errorMessage,
          style: TextStyle(color: darksColor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pcPassword)) {
      setState(() {
        errorMessage = 'La contraseña debe tener al menos un carácter especial';
      });
      CherryToast.warning(
        backgroundColor: backColor,
        title: Text(
          errorMessage,
          style: TextStyle(color: darksColor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

   
    sendPass(context, pcPassword, pcPasswordConfirm, backColor, darksColor);
  }

  Future<void> sendPass(BuildContext context, String pcPassword,
      String pcPasswordConfirm, Color backColor, Color darksColor) async {
    try {

      UsuarioChangePass usuarioData = UsuarioChangePass(
          fcPassword: pcPassword,
          fiIdunico: widget.fiIDUnico);

      String usuarioJson = jsonEncode(usuarioData);

      final response = await http.post(
        Uri.parse('${apiUrl}Usuario/CambioContrasenia'),
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
            backgroundColor: backColor,
            title: Text(
              '$messageStatus',
              style: TextStyle(color: darksColor),
              textAlign: TextAlign.start,
            ),
            borderRadius: 5,
          ).show(context);

          Future.delayed(const Duration(seconds: 3), () {
            Navigator.pop(context);
          });
        } else if (codeStatus.toString() == '409') {
          CherryToast.warning(
            backgroundColor: backColor,
            title: Text('$messageStatus',
                style: TextStyle(color: darksColor),
                textAlign: TextAlign.start),
            borderRadius: 5,
          ).show(context);

          return;
        } else {
          CherryToast.error(
            backgroundColor: backColor,
            title: Text('$messageStatus',
                style: TextStyle(color: darksColor),
                textAlign: TextAlign.start),
            borderRadius: 5,
          ).show(context);
        }
      }
    } catch (e) {
      CherryToast.warning(
        backgroundColor: backColor,
        title: Text(
          'Ha ocurrido un error Inesperado',
          style: TextStyle(color: darksColor),
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
        backgroundColor: notifire.getprimerycolor,
        elevation: 0,
        iconTheme: IconThemeData(color: notifire.getdarkscolor),
        centerTitle: true,
        title: Text(
          CustomStrings.createnewpassword,
          style: TextStyle(
            color: notifire.getdarkscolor,
            fontFamily: 'Gilroy Bold',
            fontSize: height / 40,
          ),
        ),
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
                  height: height / 50,
                ),
                Text(
                  CustomStrings.accessaccount,
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Gilroy Bold',
                    fontSize: height / 60,
                  ),
                ),
                SizedBox(
                  height: height / 40,
                ),
                SizedBox(
                  height: height / 50,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: width / 20,
                    ),
                    Text(
                      'Nueva Contraseña',
                      style: TextStyle(
                        color: notifire.getdarkscolor,
                        fontFamily: 'Gilroy Bold',
                        fontSize: height / 50,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height / 50,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Customtextfild2.textField(
                    _obscureText3,
                    "Nueva Contraseña",
                    Colors.grey,
                    notifire.getdarkscolor,
                    "images/password.png",
                    GestureDetector(
                      onTap: _toggle3,
                      child: _obscureText3
                          ? Image.asset(
                              "images/eye.png",
                              color: notifire.getorangeprimerycolor,
                              height: height / 60,
                            )
                          : Icon(
                              Icons.remove_red_eye,
                              color: notifire.getorangeprimerycolor,
                            ),
                    ),
                    notifire.getorangeprimerycolor,
                    notifire.getdarkwhitecolor,
                    pcPassword,
                  ),
                ),
                SizedBox(
                  height: height / 50,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: width / 20,
                    ),
                    Text(
                      CustomStrings.confirmnewpassword,
                      style: TextStyle(
                        color: notifire.getdarkscolor,
                        fontFamily: 'Gilroy Bold',
                        fontSize: height / 50,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: height / 50,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Customtextfild2.textField(
                    _obscureText2,
                    "Confirmar Nueva Contraseña",
                    Colors.grey,
                    notifire.getdarkscolor,
                    "images/password.png",
                    GestureDetector(
                      onTap: _toggle2,
                      child: _obscureText2
                          ? Image.asset(
                              "images/eye.png",
                              height: height / 60,
                              color: notifire.getorangeprimerycolor,
                            )
                          : Icon(
                              Icons.remove_red_eye,
                              color: notifire.getorangeprimerycolor,
                            ),
                    ),
                    notifire.getorangeprimerycolor,
                    notifire.getdarkwhitecolor,
                    pcPasswordConfirm,
                  ),
                ),
                SizedBox(
                  height: height / 50,
                ),
                if (show)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width / 20),
                    child: Text(
                      errorMessage,
                      style: TextStyle(
                        color: errorMessage == 'Validación exitosa'
                            ? const Color(0xff00BF71)
                            : Colors.red,
                        fontFamily: 'Gilroy Medium',
                        fontSize: height / 60,
                      ),
                    ),
                  ),
                SizedBox(
                  height: height / 2.4,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width / 20),
                  child: GestureDetector(
                    onTap: () {
                      _validate(
                          context,
                          pcPassword.text,
                          pcPasswordConfirm.text,
                          notifire.getbackcolor,
                          notifire.getdarkscolor);
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
                          CustomStrings.createpasswords,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Gilroy Medium',
                            fontSize: height / 50,
                          ),
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
