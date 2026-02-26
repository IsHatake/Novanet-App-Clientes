import 'package:flutter/material.dart';
import 'media.dart';

class Custombutton {
  static Widget button(Color clr, String text, double wid, {IconData? icon}) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
          color: clr,
        ),
        height: height / 15,
        width: wid,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white,
                size: height / 40,
              ),
              const SizedBox(width: 8), // Espacio entre el icono y el texto
            ],
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: height / 50,
                fontFamily: 'Gilroy Medium',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
