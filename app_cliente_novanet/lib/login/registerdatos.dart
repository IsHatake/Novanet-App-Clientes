// ignore_for_file: file_names

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/service/usuarioService.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/button.dart';
import '../utils/colornotifire.dart';
import '../utils/media.dart';
import '../utils/string.dart';
import '../utils/textfeilds.dart';

class Registerdatos extends StatefulWidget {
  final int fiIDEquifax;  
  const Registerdatos({
    Key? key,
    required this.fiIDEquifax,
  }) : super(key: key);

  @override
  State<Registerdatos> createState() => _RegisterdatosState();
}

class _RegisterdatosState extends State<Registerdatos> {
  late ColorNotifire notifire;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final TextEditingController _nombreCompletoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contraseniaController = TextEditingController();
  final TextEditingController _contraseniaconfirmarController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _validacionCampos() async {
    String nombreCompleto = _nombreCompletoController.text.trim();
    String contrasenia = _contraseniaController.text.trim();
    String contraseniaConfirmar = _contraseniaconfirmarController.text.trim();
    String email = _emailController.text.trim();

    if (contrasenia.isEmpty || contraseniaConfirmar.isEmpty || nombreCompleto.isEmpty || email.isEmpty) {
      _showToast('Complete todos los campos por favor', isWarning: true);
      return;
    }

    if (contrasenia != contraseniaConfirmar) {
      _showToast('Las contraseñas no coinciden', isWarning: true);
      return;
    }

    if (contrasenia.length < 8) {
      _showToast('La contraseña debe tener al menos 8 caracteres', isWarning: true);
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showToast('Ingrese un correo electrónico válido', isWarning: true);
      return;
    }

    sendUsuarioCreacion(
      context,
      nombreCompleto,
      email,
      contrasenia,
      widget.fiIDEquifax,
      notifire.getbackcolor,
      notifire.getdarkscolor,
      false,
      false,
    );
  }

  void _showToast(String message, {bool isWarning = false}) {
    CherryToast.warning(
      backgroundColor: notifire.getbackcolor,
      title: Text(
        message,
        style: TextStyle(color: notifire.getdarkscolor),
        textAlign: TextAlign.start,
      ),
      borderRadius: 5,
    
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        shadowColor: Colors.black26,
        centerTitle: true,
        backgroundColor: notifire.getprimerycolor,
        title: Text(
          'Registrar Usuario Familiar',
          style: TextStyle(
            fontFamily: 'Gilroy Bold',
            color: notifire.getdarkscolor,
            fontSize: height * 0.026,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: notifire.getdarkscolor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: notifire.getprimerycolor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [notifire.getprimerycolor, notifire.getprimerycolor.withOpacity(0.8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: height * 0.02),
              Image.asset(
                "images/logos.png",
                height: height * 0.1,
                color: notifire.getorangeprimerycolor,
              ),
              SizedBox(height: height * 0.03),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: notifire.getbackcolor,
                child: Padding(
                  padding: EdgeInsets.all(width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        label: CustomStrings.fullname,
                        hint: CustomStrings.fullnamehere,
                        icon: Icons.person,
                        controller: _nombreCompletoController,
                      ),
                      SizedBox(height: height * 0.03),
                      _buildTextField(
                        label: CustomStrings.email,
                        hint: CustomStrings.emailhint,
                        icon: Icons.email,
                        controller: _emailController,
                      ),
                      SizedBox(height: height * 0.03),
                      _buildTextField(
                        label: CustomStrings.password,
                        hint: CustomStrings.createpassword,
                        icon: Icons.lock,
                        controller: _contraseniaController,
                        isPassword: true,
                        isVisible: _isPasswordVisible,
                        toggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                      SizedBox(height: height * 0.03),
                      _buildTextField(
                        label: CustomStrings.confirmpassword,
                        hint: CustomStrings.retypepassword,
                        icon: Icons.lock,
                        controller: _contraseniaconfirmarController,
                        isPassword: true,
                        isVisible: _isConfirmPasswordVisible,
                        toggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                      ),
                      SizedBox(height: height * 0.04),
                      Center(
                        child: GestureDetector(
                          onTap: _validacionCampos,
                          child: Custombutton.button(
                            notifire.getorangeprimerycolor,
                            CustomStrings.registeraccount,
                            width * 0.8,
                           
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? toggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Gilroy Medium',
            color: notifire.getdarkscolor.withOpacity(0.8),
            fontSize: height * 0.018,
          ),
        ),
        SizedBox(height: height * 0.01),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isVisible,
            style: TextStyle(
              fontFamily: 'Gilroy Medium',
              color: notifire.getdarkscolor,
              fontSize: height * 0.018,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: notifire.getdarkgreycolor,
                fontSize: height * 0.016,
              ),
              prefixIcon: Icon(icon, color: notifire.getorangeprimerycolor, size: height * 0.025),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                        color: notifire.getorangeprimerycolor,
                        size: height * 0.025,
                      ),
                      onPressed: toggleVisibility,
                    )
                  : null,
              filled: true,
              fillColor: notifire.getwhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: notifire.getorangeprimerycolor, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: width * 0.04),
            ),
          ),
        ),
      ],
    );
  }
}