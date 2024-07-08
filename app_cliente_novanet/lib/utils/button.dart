import 'package:flutter/material.dart';
import 'media.dart';

class Custombutton {
  static Widget button(Color clr, String text, double wid) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(30),
          ),
          color: clr,
        ),
        height: height / 15,
        width: wid,
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: height / 50,
              fontFamily: 'Gilroy Medium',
            ),
          ),
        ),
      ),
    );
  }
}
