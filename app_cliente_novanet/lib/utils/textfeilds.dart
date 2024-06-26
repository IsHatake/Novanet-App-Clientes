import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'media.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class Customtextfilds {
  static Widget textField(
      textclr, hintclr, borderclr, img, hinttext, fillcolor) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width / 18),
      child: Container(
        color: Colors.transparent,
        height: height / 15,
        child: TextField(
          autofocus: false,
          style: TextStyle(
            fontSize: height / 50,
            color: textclr,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillcolor,
            hintText: hinttext,
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: height / 100, horizontal: height / 70),
              child: Image.asset(
                img,
                height: height / 30,
              ),
            ),
            hintStyle: TextStyle(color: hintclr, fontSize: height / 60),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderclr),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.4),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}


class LoginTxt {
  static Widget textField(
      textclr, hintclr, borderclr, img, hinttext, fillcolor, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width / 18),
      child: Container(
        color: Colors.transparent,
        height: height / 15,
        child: TextField(
          controller: controller,
          autofocus: false,
          style: TextStyle(
            fontSize: height / 50,
            color: textclr,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillcolor,
            hintText: hinttext,
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: height / 100, horizontal: height / 70),
              child: Image.asset(
                img,
                height: height / 30,
              ),
            ),
            hintStyle: TextStyle(color: hintclr, fontSize: height / 60),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderclr),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.4),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}


class Registrar {
  static Widget textField(
      textclr, hintclr, borderclr, img, hinttext, fillcolor, TextEditingController controller, bool enable) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width / 18),
      child: Container(
        color: Colors.transparent,
        height: height / 15,
        child: TextField(
          readOnly: enable,
          controller: controller,
          autofocus: false,
          style: TextStyle(
            fontSize: 15,
            color: textclr,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: fillcolor,
            hintText: hinttext,
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: height / 100, horizontal: height / 70),
              child: Image.asset(
                img,
                height: height / 30,
              ),
            ),
            hintStyle: TextStyle(color: hintclr, fontSize: height / 60),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderclr),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.4),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

class DNI {
  static Widget textField(Color textclr, Color hintclr, Color borderclr,
      String img, String hinttext, Color fillcolor, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width / 18),
      child: Container(
        color: Colors.transparent,
        height: height / 15,
        child: TextField(
          controller: controller,
          autofocus: false,
          style: TextStyle(
            fontSize: 15,
            color: textclr,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(13),
            MaskTextInputFormatter(
                mask: '####-####-#####',
                filter: {"#": RegExp(r'[0-9]')},
                type: MaskAutoCompletionType.lazy)
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: fillcolor,
            hintText: hinttext,
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: height / 100, horizontal: height / 70),
              child: Image.asset(
                img,
                color: borderclr,
                height: height / 30,
              ),
            ),
            hintStyle: TextStyle(color: hintclr, fontSize: height / 60),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: borderclr),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.withOpacity(0.4),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
         
        ),
      ),
    );
  }
}
