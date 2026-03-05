import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_cliente_novanet/utils/colornotifire.dart';

class BiometricLoginButton extends StatelessWidget {
  final VoidCallback onTap;
  final ColorNotifire notifire;

  const BiometricLoginButton({
    Key? key,
    required this.onTap,
    required this.notifire,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: height * 0.025,    // Padding vertical proporcional
          horizontal: width * 0.06,    // Padding horizontal proporcional
        ),
        decoration: BoxDecoration(
          color: notifire.getbackcolor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: notifire.getorangeprimerycolor.withOpacity(0.4),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: notifire.getorangeprimerycolor.withOpacity(0.18),
              blurRadius: 24,
              spreadRadius: 6,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícono escalado proporcionalmente
            Icon(
              Icons.fingerprint,
              color: notifire.getorangeprimerycolor,
              size: width * 0.10, // 10% del ancho → responsive y visible
            ),
            SizedBox(width: width * 0.05), // Espacio proporcional

            // Textos con FittedBox para que nunca se salgan del botón
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ingresar con datos biométricos',
                      style: GoogleFonts.sen(
                        fontWeight: FontWeight.w700,
                        color: notifire.getdarkscolor,
                        fontSize: 16, // Tamaño base, FittedBox lo ajusta si es necesario
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: height * 0.008),
                    Text(
                      'Usa Face ID o huella digital',
                      style: GoogleFonts.sen(
                        fontSize: 12,
                        color: notifire.getdarkscolor.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}