import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void snackBar(
    String text, Color bgColor, Color txtColor, BuildContext context) {
  var snackBar = SnackBar(
    content: Text(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(color: txtColor), fontWeight: FontWeight.w500),
    ),
    backgroundColor: bgColor,
    behavior: SnackBarBehavior.floating,
  );

  // Find the ScaffoldMessenger in the widget tree
  // and use it to show a SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
