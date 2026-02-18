import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle nodeFontStyle(
  String font, {
  required Color color,
  required double fontSize,
}) {
  switch (font) {
    case 'Lobster':
      return GoogleFonts.lobster(
        color: color,
        fontSize: fontSize,
      );
    case 'Montserrat':
      return GoogleFonts.montserrat(
        color: color,
        fontSize: fontSize,
      );
    case 'FiraCode':
      return GoogleFonts.firaCode(
        color: color,
        fontSize: fontSize,
      );
    case 'Roboto':
    default:
      return GoogleFonts.roboto(
        color: color,
        fontSize: fontSize,
      );
  }
}
