// ignore_for_file: file_names, non_constant_identifier_names
import 'package:app_cliente_novanet/screens/registrodeposito.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


Future<void> DialogPago(
    BuildContext context, dynamic notifire, String fcLlaveUnica) async {
  final double width = MediaQuery.of(context).size.width;
  final double height = MediaQuery.of(context).size.height;

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: notifire.getbackcolor,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: notifire.getdarkscolor.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Opciones de Pago',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Gilroy Bold',
                  fontSize: height * 0.024,
                  color: notifire.getdarkscolor,
                ),
              ),
              SizedBox(height: height * 0.02),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RegistroDepositoScreen(notifire: notifire),
                    ),
                  );
                },
                child: Container(
                  
                  height: height * 0.06,
decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_money,
                          color: Colors.white, size: height * 0.03),
                      SizedBox(width: width * 0.02),
                      Text(
                        'Registrar Depósito',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Gilroy Bold',
                          fontSize: height * 0.018,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.015),
              GestureDetector(
                onTap: () async {
                  if (!await launchUrl(Uri.parse(
                      'https://ppos.novanetgroup.com/PagoCuota?id=$fcLlaveUnica'))) {
                    throw Exception(
                        'https://ppos.novanetgroup.com/PagoCuota?id=$fcLlaveUnica');
                  }
                },
                child: Container(
                  height: height * 0.06,
                  decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.credit_card,
                          color: Colors.white, size: height * 0.03),
                      SizedBox(width: width * 0.02),
                      Text(
                        'Pagar en Línea',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Gilroy Bold',
                          fontSize: height * 0.018,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: height * 0.02),
              Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: notifire.getorangeprimerycolor,
                      fontFamily: 'Gilroy Medium',
                      fontSize: height * 0.016,
                    ),
                  ),
                ),
              ),
            ],  
          ),
        ),
      );
    },
  );
}