import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kSunColorPri = Color(0xFFFFD447);
const kSunColorSL = Color(0xFFF3D498);
const kSunColorSC = Color(0xFFF2E5B4);
const kSunColorTR = Color(0xFFF2E5B4);
const kNightColorPri = Color(0xFF5A5ECC);
const kNightColorSL = Color(0xFFB79DD4);
const kNightColorSC = Color(0xFFB2BCEC);
const kNightColorTR = Color(0xFFBFDDE5);

const darkGreyColor = Color.fromARGB(255, 4, 1, 1);
const darkHeaderColor = Color(0xFF424242);

class Themes {
  static final light = ThemeData(colorScheme: const ColorScheme.light());
  static final dark = ThemeData(colorScheme: const ColorScheme.dark());
}

TextStyle get subHeadingStyle {
  return GoogleFonts.lato(
    textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[400]),
  );
}

TextStyle get headingStyle {
  return GoogleFonts.lato(
    textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
  );
}

TextStyle get smallTextStyle {
  return GoogleFonts.lato(
    textStyle: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.bold,
    ),
  );
}
