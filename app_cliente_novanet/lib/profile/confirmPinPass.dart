// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:app_cliente_novanet/profile/changepassword.dart';
import 'package:app_cliente_novanet/toastconfig/toastconfig.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:app_cliente_novanet/utils/media.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';

import '../utils/button.dart';

class ConfirmPinPass extends StatefulWidget {
  final int fiIDUnico;
  final Color backColor;
  final Color darkColor;
  final String token;

  const ConfirmPinPass({
    Key? key,
    required this.fiIDUnico,
    required this.backColor,
    required this.darkColor,
    required this.token,
  }) : super(key: key);

  @override
  State<ConfirmPinPass> createState() => _ConfirmPinPassState();
}

class _ConfirmPinPassState extends State<ConfirmPinPass> {
  late ColorNotifire notifire;
  String tokenApi = '';
  String tokenApp = '';

  void compareTokens() {
    if (tokenApp.isEmpty) {
      CherryToast.warning(
        backgroundColor: widget.backColor,
        title: Text(
          'Llene el Campo Requerido',
          style: TextStyle(color: widget.darkColor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
      return;
    }

    if (tokenApi == tokenApp) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePassword(fiIDUnico: widget.fiIDUnico),
        ),
      );
    } else {
      CherryToast.warning(
        backgroundColor: widget.backColor,
        title: Text(
          'Token no válido',
          style: TextStyle(color: widget.darkColor),
          textAlign: TextAlign.start,
        ),
        borderRadius: 5,
      ).show(context);
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      tokenApi = widget.token;
    });
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: notifire.getdarkscolor),
        elevation: 0,
        backgroundColor: notifire.getprimerycolor,
      ),
      backgroundColor: widget.backColor,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: height * 0.89,
              width: width,
              color: widget.backColor,
              child: Image.asset(
                "images/background.png",
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                SizedBox(height: height / 20),
                Row(
                  children: [
                    SizedBox(width: width / 20),
                    Text(
                      'Confirma tu PIN',
                      style: TextStyle(
                        fontFamily: 'Gilroy Bold',
                        color: widget.darkColor,
                        fontSize: height / 30,
                      ),
                    ),
                    SizedBox(width: width / 80),
                  ],
                ),
                SizedBox(height: height / 80),
                Row(
                  children: [
                    SizedBox(width: width / 20),
                    Text(
                      'Revisa tu correo y confirma el PIN',
                      style: TextStyle(
                        color: widget.darkColor.withOpacity(0.7),
                        fontFamily: 'Gilroy Medium',
                        fontSize: height / 60,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height / 30),
                animatedBorders(),
                SizedBox(height: height / 1.8),
                GestureDetector(
                  onTap: () {
                    compareTokens();
                  },
                  child: Custombutton.button(
                    notifire.getorangeprimerycolor,
                    'Confirmar',
                    width / 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget animatedBorders() {
    return Container(
      color: Colors.transparent,
      height: height / 14,
      width: width / 1.2,
      child: OTPTextField(
        // controller: otpController,
        length: 4,
        width: MediaQuery.of(context).size.width,
        textFieldAlignment: MainAxisAlignment.spaceAround,
        otpFieldStyle: OtpFieldStyle(
          enabledBorderColor: Colors.grey.withOpacity(0.4),
          borderColor: Colors.grey.withOpacity(0.4),
        ),
        fieldWidth: 50,
        fieldStyle: FieldStyle.box,
        outlineBorderRadius: 15,
        style: TextStyle(fontSize: 17, color: widget.darkColor),
        onChanged: (pin) {
          if (pin.length == 4) {
            setState(() {
              tokenApp = pin.toString();
            });
          } else {
            setState(() {
              tokenApp = '';
            });
          }
        },
        onCompleted: (pin) {
          if (pin.length == 4) {
            setState(() {
              tokenApp = pin.toString();
            });
          } else {
            setState(() {
              tokenApp = '';
            });
          }
        },
      ),
    );
  }
}
