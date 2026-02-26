// ignore_for_file: unused_element

import 'package:app_cliente_novanet/screens/qr_scanner_screen.dart';
import 'package:app_cliente_novanet/service/signalRChat_Service.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/localauthapi/local_auth_api.dart';
import 'package:local_auth/local_auth.dart';
import 'package:app_cliente_novanet/profile/forgotpassword.dart';
import 'package:app_cliente_novanet/service/pruebaService.dart';
import 'package:app_cliente_novanet/utils/button.dart';
import 'package:app_cliente_novanet/utils/string.dart';
import 'package:app_cliente_novanet/utils/textfeilds.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colornotifire.dart';

class Login extends StatefulWidget {

  const Login({Key? key,}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late ColorNotifire notifire;
  final LocalAuthentication auth = LocalAuthentication();

  TextEditingController fcUsuarioAcceso = TextEditingController();
  TextEditingController fcPassword = TextEditingController();

  String fcUsuarioAccesoCache = '';
  String fcPasswordCache = '';

  bool _isPasswordVisible = false;
  bool _isBiometricSupported = false;
  bool _isPrincipal = true;


  @override
  void initState() {
    super.initState();

    loadCache();
    checkBiometrics();
   // _checkFirstVisit();
    
  }




  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fcUsuarioAccesoCache = prefs.getString("UsuarioCache") ?? '';
      fcPasswordCache = prefs.getString("ContraseniaCache") ?? '';
    });
  }

  Future<void> checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } catch (e) {
      canCheckBiometrics = false;
    }

    if (!mounted) return;

    setState(() {
      _isBiometricSupported = canCheckBiometrics;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: notifire.gettabwhitecolor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: height,
                  width: width,
                  color: Colors.transparent,
                  child:
                      Image.asset("images/background.png", fit: BoxFit.cover),
                ),
                Column(
                  children: [
                    SizedBox(
                      height: height / 5,
                    ),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: Container(
                            height: height,
                            width: width / 1.1,
                            decoration: BoxDecoration(
                              color: notifire.getprimerycolor,
                              border:
                                  Border.all(color: Colors.black12, width: 3),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(40),
                                topLeft: Radius.circular(40),
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: height / 10,
                                ),
                                // User Type Toggle Switch
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Usuario Principal",
                                      style: TextStyle(
                                        color: _isPrincipal
                                            ? notifire.getorangeprimerycolor
                                            : Colors.grey,
                                      ),
                                    ),
                                    Switch(
                                      value: _isPrincipal,
                                      onChanged: (value) {
                                        setState(() {
                                          _isPrincipal = value;
                                        });
                                      },
                                      activeColor:
                                          notifire.getorangeprimerycolor,
                                      inactiveThumbColor: Colors.grey,
                                      inactiveTrackColor: Colors.grey.shade400,
                                    ),
                                    Text(
                                      "Usuario Familiar",
                                      style: TextStyle(
                                        color: !_isPrincipal
                                            ? notifire.getorangeprimerycolor
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                // Rest of your form
                                SizedBox(
                                  height: height / 50,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: width / 18,
                                    ),
                                    Text(
                                      'Correo',
                                      style: TextStyle(
                                        color: notifire.getdarkscolor,
                                        fontSize: height / 50,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: height / 70,
                                ),
                                LoginTxt.textField(
                                    notifire.getdarkscolor,
                                    notifire.getdarkscolor,
                                    notifire.getbluecolor,
                                    "images/email.png",
                                    CustomStrings.emailhint,
                                    notifire.getdarkwhitecolor,
                                    fcUsuarioAcceso),
                                SizedBox(
                                  height: height / 35,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: width / 18,
                                    ),
                                    Text(
                                      CustomStrings.password,
                                      style: TextStyle(
                                        color: notifire.getdarkscolor,
                                        fontSize: height / 50,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: height / 70,
                                ),
                                passwordTextField(
                                  notifire.getdarkscolor,
                                  notifire.getdarkscolor,
                                  notifire.getbluecolor,
                                  "images/password.png",
                                  CustomStrings.passwordhint,
                                  notifire.getdarkwhitecolor,
                                  fcPassword,
                                  _isPasswordVisible,
                                ),
                                SizedBox(
                                  height: height / 35,
                                ),
                                Row(
                                  children: [
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const QrCodeScanner(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: height / 40,
                                        color: Colors.transparent,
                                        child: Text(
                                          'Usuario Familiar',
                                          style: TextStyle(
                                              color: notifire.getdarkscolor,
                                              fontSize: height / 60,
                                              fontFamily: 'Gilroy Medium'),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    const Spacer(),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgotPassword(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: height / 40,
                                        color: Colors.transparent,
                                        child: Text(
                                          CustomStrings.forgotpassword,
                                          style: TextStyle(
                                              color: notifire.getdarkscolor,
                                              fontSize: height / 60,
                                              fontFamily: 'Gilroy Medium'),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: width / 18,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: height / 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (fcUsuarioAcceso.text.isEmpty ||
                                        fcPassword.text.isEmpty) {
                                      CherryToast.warning(
                                        backgroundColor: notifire.getbackcolor,
                                        title: Text('Llene los campos vacíos',
                                            style: TextStyle(
                                                color: notifire.getdarkscolor),
                                            textAlign: TextAlign.start),
                                        borderRadius: 5,
                                      ).show(context);
                                    } else {
                                      fetchLogin(
                                          context,
                                          fcUsuarioAcceso.text,
                                          fcPassword.text,
                                          _isPrincipal,
                                          notifire.getbackcolor,
                                          notifire.getdarkscolor);
                                    }
                                  },
                                  child: Custombutton.button(
                                      notifire.getorangeprimerycolor,
                                      CustomStrings.login,
                                      width / 2),
                                ),
                                SizedBox(
                                  height: height / 50,
                                ),
                                if (_isBiometricSupported)
                                  if ((fcUsuarioAccesoCache.isNotEmpty &&
                                          fcPasswordCache.isNotEmpty) ||
                                      (fcUsuarioAccesoCache != '' &&
                                          fcPasswordCache != ''))
                                    GestureDetector(
                                      onTap: _authenticate,
                                      child: Container(
                                        margin: const EdgeInsets.only(top: 20),
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border.all(
                                              color: notifire
                                                  .getorangeprimerycolor),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.fingerprint,
                                          color: notifire.getorangeprimerycolor,
                                          size: 70,
                                        ),
                                      ),
                                    ),
                                const SizedBox(height: 50),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          top: -105,
                          child: Center(
                            child: Image.asset(
                              "images/NOVANETLOGO.png",
                              height: height / 15.5,
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
                      height: height / 15,
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

  Widget passwordTextField(
    Color textclr,
    Color hintclr,
    Color borderclr,
    String img,
    String hinttext,
    Color fillColor,
    TextEditingController controller,
    bool isPasswordVisible,
  ) {
    bool obscureText = !isPasswordVisible;

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width / 18),
      child: Container(
        color: Colors.transparent,
        height: MediaQuery.of(context).size.height / 13,
        child: TextField(
          controller: controller,
          autofocus: false,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 15,
            color: textclr,
          ),
          decoration: InputDecoration(
            hintText: hinttext,
            filled: true,
            fillColor: fillColor,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 50,
                  horizontal: MediaQuery.of(context).size.height / 70,
                ),
                child: Image.asset(
                  isPasswordVisible ? "images/show.png" : "images/oculto.png",
                  color: notifire.getorangeprimerycolor,
                  height: MediaQuery.of(context).size.height / 50,
                ),
              ),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.height / 100,
                horizontal: MediaQuery.of(context).size.height / 70,
              ),
              child: Image.asset(
                img,
                height: MediaQuery.of(context).size.height / 30,
              ),
            ),
            hintStyle: TextStyle(
              color: hintclr,
              fontSize: MediaQuery.of(context).size.height / 60,
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

  void _authenticate() async {
    final authenticate = await LocalAuth.authenticate();

    if (authenticate) {
      fetchLogin(context, fcUsuarioAccesoCache, fcPasswordCache, _isPrincipal,
          notifire.getbackcolor, notifire.getdarkscolor);
    } else {
      CherryToast.error(
        backgroundColor: notifire.getbackcolor,
        title: Text('Autenticación fallida',
            style: TextStyle(color: notifire.getdarkscolor),
            textAlign: TextAlign.start),
        borderRadius: 5,
      ).show(context);
    }
  }
}
