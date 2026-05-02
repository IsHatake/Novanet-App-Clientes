// ignore_for_file: unused_element

import 'package:app_cliente_novanet/screens/qr_scanner_screen.dart';
import 'package:app_cliente_novanet/utils/BiometricLoginButton.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/localauthapi/local_auth_api.dart';
import 'package:local_auth/local_auth.dart';
import 'package:app_cliente_novanet/profile/forgotpassword.dart';
import 'package:app_cliente_novanet/service/pruebaService.dart';
import 'package:app_cliente_novanet/utils/string.dart';
import 'package:app_cliente_novanet/utils/textfeilds.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colornotifire.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({
    Key? key,
  }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late ColorNotifire notifire;
  final LocalAuthentication auth = LocalAuthentication();

  TextEditingController fcUsuarioAcceso = TextEditingController();
  TextEditingController fcPassword = TextEditingController();

  FocusNode focusPassword = FocusNode();
  FocusNode focusUsuario = FocusNode();

  String fcUsuarioAccesoCache = '';
  String fcPasswordCache = '';

  bool _isPasswordVisible = false;
  bool _isBiometricSupported = false;
  bool _isPrincipal = true;
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    loadCache();
    checkBiometrics();
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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              // Fondo completo con imagen
              SizedBox.expand(
                child: Image.asset(
                  notifire.isDark ? "images/bg-dark.png" : "images/bg.png",
                  fit: BoxFit.cover,
                ),
              ),

              // Contenido principal dentro de una card centrada
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: width * 0.06,
                        vertical: height * 0.02,
                      ),
                      padding: EdgeInsets.all(width * 0.06),
                      constraints: BoxConstraints(
                        maxWidth:
                            500, // Máximo ancho para tablets/pantallas grandes
                      ),
                      decoration: BoxDecoration(
                        color: notifire.getprimerycolor.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 30,
                            spreadRadius: 5,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo flotando arriba de la card
                          Container(
                            padding: EdgeInsets.all(width * 0.05),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 25,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              "images/logos.png",
                              height: height * 0.12,
                            ),
                          ),

                          SizedBox(height: height * 0.02),

                          // Título
                          Text(
                            'Bienvenido',
                            style: GoogleFonts.sen(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: notifire.getdarkscolor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: notifire.getorangeprimerycolor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Ingresar como ${_isPrincipal ? "Usuario Principal" : "Usuario Familiar"}',
                                    style: GoogleFonts.sen(
                                      color: notifire.getdarkscolor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ]),
                          ),

                          const SizedBox(height: 15),

                          // Toggle Principal / Familiar
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: notifire.getdarkwhitecolor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _isPrincipal = true),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      decoration: BoxDecoration(
                                        color: _isPrincipal
                                            ? notifire.getorangeprimerycolor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Usuario Principal',
                                          style: GoogleFonts.sen(
                                            color: _isPrincipal
                                                ? Colors.white
                                                : Colors.grey[700],
                                            fontWeight: _isPrincipal
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => _isPrincipal = false),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      decoration: BoxDecoration(
                                        color: !_isPrincipal
                                            ? notifire.getorangeprimerycolor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Usuario Familiar',
                                          style: GoogleFonts.sen(
                                            color: !_isPrincipal
                                                ? Colors.white
                                                : Colors.grey[700],
                                            fontWeight: !_isPrincipal
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: height * 0.04),

                          // Campo Correo
                          LoginTxt.textField(
                            notifire.getdarkscolor,
                            notifire.getdarkscolor,
                            notifire.getdarkscolor,
                            "images/email.png",
                            CustomStrings.emailhint,
                            notifire.getdarkwhitecolor,
                            fcUsuarioAcceso,
                            focusUsuario,
                          ),

                          SizedBox(height: height * 0.025),

                          // Campo Contraseña
                          passwordTextField(
                            notifire.getdarkscolor,
                            notifire.getdarkscolor,
                            notifire.getdarkscolor,
                            "images/password.png",
                            CustomStrings.passwordhint,
                            notifire.getdarkwhitecolor,
                            fcPassword,
                            _isPasswordVisible,
                            focusPassword,
                          ),

                          SizedBox(height: height * 0.02),

                          // Olvidó contraseña + Usuario Familiar QR
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const QrCodeScanner()),
                                    );
                                  },
                                  child: Text(
                                    'QR Usuario Familiar',
                                    style: GoogleFonts.sen(
                                      color: notifire.isDark
                                          ? notifire.getdarkscolor
                                          : notifire.getorangeprimerycolor,
                                      fontSize: 14,
                                      decoration: notifire.isDark
                                          ? TextDecoration.underline
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SizedBox(width: width * 0.05),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ForgotPassword()),
                                  ),
                                  child: Text(
                                    CustomStrings.forgotpassword,
                                    style: GoogleFonts.sen(
                                      color: notifire.isDark
                                          ? notifire.getdarkscolor
                                          : notifire.getorangeprimerycolor,
                                      fontSize: 14,
                                      decoration: notifire.isDark
                                          ? TextDecoration.underline
                                          : null,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),

                          SizedBox(height: height * 0.05),

                          // Botón de login
                          GestureDetector(
                            onTap: _isLoading
                                ? null
                                : () {
                                    if (fcUsuarioAcceso.text.isEmpty ||
                                        fcPassword.text.isEmpty) {
                                      CherryToast.warning(
                                        backgroundColor: notifire.getbackcolor,
                                        title: Text('Llene los campos vacíos',
                                            style: TextStyle(
                                                color: notifire.getdarkscolor)),
                                        borderRadius: 8,
                                      ).show(context);
                                      return;
                                    }
                                    fetchLogin(
                                      context,
                                      fcUsuarioAcceso.text,
                                      fcPassword.text,
                                      _isPrincipal,
                                      notifire.getbackcolor,
                                      notifire.getdarkscolor,
                                    );
                                  },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              decoration: BoxDecoration(
                                color: notifire.getorangeprimerycolor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: notifire.getorangeprimerycolor
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 3,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      CustomStrings.login,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.sen(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),

                          SizedBox(height: height * 0.025),

                          // Huella biométrica (si aplica)
                          if (_isBiometricSupported &&
                              (fcUsuarioAccesoCache.isNotEmpty &&
                                  fcPasswordCache.isNotEmpty))
                            BiometricLoginButton(
                              onTap: _authenticate,
                              notifire: notifire,
                            ),

                          SizedBox(height: height * 0.06),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
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
    FocusNode? focusNode,
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
