import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void snackBar(text, bg_color, txt_color, context) {
  var snackBar = SnackBar(
    content: Text(
      text,
      style: GoogleFonts.poppins(
          textStyle: TextStyle(color: txt_color), fontWeight: FontWeight.w500),
    ),
    backgroundColor: bg_color,
    behavior: SnackBarBehavior.floating,
  );

  // Find the ScaffoldMessenger in the widget tree
  // and use it to show a SnackBar.
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
