// ignore_for_file: file_names
import 'package:app_cliente_novanet/screens/registrodeposito.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/button.dart';
import '../utils/media.dart';

Future<void> DialogPago(
    BuildContext context, dynamic notifire, String fcLlaveUnica) async {
  final double width = MediaQuery.of(context).size.width;

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: notifire.getbackcolor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          margin: const EdgeInsets.all(15.0),
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  // Aquí agrega la lógica para registrar el depósito.
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RegistroDepositoScreen(notifire: notifire),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Custombutton.button(
                      notifire.getorangeprimerycolor,
                      'Registrar Depósito',
                      width / 2,
                      icon: Icons.attach_money, // Icono de dinero
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Separador entre botones.
              GestureDetector(
                onTap: () async {
                  if (!await launchUrl(Uri.parse(
                      'https://ppos.novanetgroup.com/PagoCuota?id=$fcLlaveUnica'))) {
                    throw Exception(
                        'https://ppos.novanetgroup.com/PagoCuota?id=$fcLlaveUnica');
                  }
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) =>
                  //         PaymentScreen(
                  //             keyId: fcLlaveUnica),
                  //   ),
                  // );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Custombutton.button(
                      notifire.getorangeprimerycolor,
                      'Pagar en línea',
                      width / 2,
                      icon: Icons.credit_card, // Icono de tarjeta de crédito
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
