// ignore_for_file: file_names

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/screens/confirmPINFamily.dart';
import 'package:app_cliente_novanet/service/usuarioService.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/button.dart';
import '../utils/colornotifire.dart';
import '../utils/string.dart';
import '../utils/textfeilds.dart';

class AdduserFamily extends StatefulWidget {
  const AdduserFamily({Key? key}) : super(key: key);

  @override
  State<AdduserFamily> createState() => _AdduserFamilyState();
}

class _AdduserFamilyState extends State<AdduserFamily> {
  late ColorNotifire notifire;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  final TextEditingController _nombreCompletoController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contraseniaController = TextEditingController();
  final TextEditingController _contraseniaconfirmarController =
      TextEditingController();

  Future<void> validacionCampos() async {
    final prefs = await SharedPreferences.getInstance();

    String nombreCompleto = _nombreCompletoController.text;
    String contrasenia = _contraseniaController.text;
    String contraseniaConfirmar = _contraseniaconfirmarController.text;
    String? fiIdcliente = prefs.getString('fiIDCliente');
    String email = _emailController.text;
    String errorMessage = '';


    if (contrasenia.isEmpty ||
        contraseniaConfirmar.isEmpty ||
        nombreCompleto.isEmpty ||
        email.isEmpty) {
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text('Complete los campos vacios por favor',
            style: TextStyle(color: notifire.getdarkscolor),
            textAlign: TextAlign.start),
        borderRadius: 5,
      ).show(context);
      return;
    }

    if (contrasenia != contraseniaConfirmar) {
      setState(() {
        errorMessage = 'Las contraseñas no coinciden';
      });
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          errorMessage,
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    if (contrasenia.length < 8) {
      setState(() {
        errorMessage = 'La contraseña debe tener al menos 8 caracteres';
      });
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          errorMessage,
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    if (!RegExp(r'[A-Z]').hasMatch(contrasenia)) {
      setState(() {
        errorMessage = 'La contraseña debe tener al menos una letra mayúscula';
      });
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          errorMessage,
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    if (!RegExp(r'[a-z]').hasMatch(contrasenia)) {
      setState(() {
        errorMessage = 'La contraseña debe tener al menos una letra minúscula';
      });
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          errorMessage,
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    if (!RegExp(r'[0-9]').hasMatch(contrasenia)) {
      setState(() {
        errorMessage = 'La contraseña debe tener al menos un número';
      });
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          errorMessage,
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(contrasenia)) {
      setState(() {
        errorMessage = 'La contraseña debe tener al menos un carácter especial';
      });
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          errorMessage,
          style: TextStyle(color: notifire.getdarkscolor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }


    String token = await fetchTokenAPI(
      context,
      notifire.getbackcolor,
      notifire.getdarkscolor,
      email,
    );

    if (token.isEmpty) {
      setState(() {
        errorMessage = 'No se ha podido Conectar al Servidor';
      });
      CherryToast.warning(
        backgroundColor: notifire.getbackcolor,
        title: Text(
          errorMessage,
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
        builder: (context) => confirmPINFamily(
          contrasenia: contrasenia,
          fcCorreo: email,
          fcNombreUsuario: nombreCompleto,
          fiIdcliente: fiIdcliente,
          backColor: notifire.getbackcolor,
          darkColor: notifire.getdarkscolor,
          correo: email,
          tokenApi: token,
        ),
      ),
    );
  }

  bool inputsVisibles = false;

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        elevation: 0,
        backgroundColor: notifire.getprimerycolor,
        title: Text(
          'Registrar Nuevo Usuario',
          style: TextStyle(
            color: notifire.getdarkscolor,
            fontFamily: 'Gilroy Bold',
            fontSize: height / 35,
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
                    Stack(
                      children: [
                        Center(
                          child: Container(
                            height: height / 1.22,
                            width: width / 1.1,
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
                              child: SingleChildScrollView(
                                child: _buildInputsContent(height, width),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height / 40,
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: height / 60,
                    ),
                    Center(
                      child: Image.asset(
                        "images/logos.png",
                        height: height / 8,
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

  Widget _buildInputsContent(double height, double width) {
    return Column(
      children: [
        SizedBox(
          height: height / 15,
        ),
        _buildTextRow(CustomStrings.fullname, height, width),
        SizedBox(
          height: height / 70,
        ),
        Registrar.textField(
          notifire.getdarkscolor,
          notifire.getdarkgreycolor,
          notifire.getorangeprimerycolor,
          "images/user.png",
          CustomStrings.fullnamehere,
          notifire.getdarkwhitecolor,
          _nombreCompletoController,
          false,
        ),
        SizedBox(
          height: height / 70,
        ),
        _buildTextRow(CustomStrings.email, height, width),
        SizedBox(
          height: height / 70,
        ),
        Registrar.textField(
          notifire.getdarkscolor,
          notifire.getdarkgreycolor,
          notifire.getorangeprimerycolor,
          "images/email.png",
          CustomStrings.emailhint,
          notifire.getdarkwhitecolor,
          _emailController,
          false,
        ),
        SizedBox(
          height: height / 35,
        ),
        _buildTextRow(CustomStrings.password, height, width),
        SizedBox(
          height: height / 70,
        ),
        passwordTextField(
          notifire.getdarkscolor,
          notifire.getdarkgreycolor,
          notifire.getorangeprimerycolor,
          "images/password.png",
          CustomStrings.createpassword,
          _contraseniaController,
          _isPasswordVisible,
          height,
          width,
        ),
        SizedBox(
          height: height / 35,
        ),
        _buildTextRow(CustomStrings.confirmpassword, height, width),
        SizedBox(
          height: height / 70,
        ),
        passwordTextField(
          notifire.getdarkscolor,
          notifire.getdarkgreycolor,
          notifire.getorangeprimerycolor,
          "images/password.png",
          CustomStrings.retypepassword,
          _contraseniaconfirmarController,
          _isConfirmPasswordVisible,
          height,
          width,
        ),
        SizedBox(
          height: height / 35,
        ),
        GestureDetector(
          onTap: () {
            validacionCampos();
          },
          child: Custombutton.button(
            notifire.getorangeprimerycolor,
            CustomStrings.registeraccount,
            width / 2,
          ),
        ),
      ],
    );
  }

  Widget _buildTextRow(String text, double height, double width) {
    return Row(
      children: [
        SizedBox(
          width: width / 18,
        ),
        Text(
          text,
          style: TextStyle(
            color: notifire.getdarkscolor,
            fontSize: height / 50,
          ),
        ),
      ],
    );
  }

  Widget passwordTextField(
    Color textclr,
    Color hintclr,
    Color borderclr,
    String img,
    String hinttext,
    TextEditingController controller,
    bool isPasswordVisible,
    double height,
    double width,
  ) {
    bool obscureText = !isPasswordVisible;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width / 18),
      child: Container(
        color: Colors.transparent,
        height: height / 15,
        child: TextField(
          controller: controller,
          autofocus: false,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: height / 50,
            color: textclr,
          ),
          decoration: InputDecoration(
            hintText: hinttext,
            filled: true,
            fillColor: notifire.getwhite,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  if (controller == _contraseniaController) {
                    _isPasswordVisible = !_isPasswordVisible;
                  } else {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  }
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: height / 50,
                  horizontal: height / 70,
                ),
                child: Image.asset(
                  isPasswordVisible ? "images/show.png" : "images/oculto.png",
                  color: notifire.getorangeprimerycolor,
                  height: height / 50,
                ),
              ),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(
                vertical: height / 100,
                horizontal: height / 70,
              ),
              child: Image.asset(
                img,
                height: height / 30,
              ),
            ),
            hintStyle: TextStyle(
              color: hintclr,
              fontSize: height / 60,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderclr),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
