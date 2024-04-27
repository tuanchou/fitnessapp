import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor1 = Color(0xFF92A3FD);
  static const primaryColor2 = Color(0xFF9DCEFF);
  static const primaryColor3 = Color(0xFF9DCEFF);

  static const secondaryColor1 = Color(0xFFC58BF2);
  static const secondaryColor2 = Color(0xFFEEA4CE);

  static const whiteColor = Color(0xFFFFFFFF);
  static const blackColor = Color(0xFF1D1617);
  static const grayColor = Color(0xFF7B6F72);
  static const lightGrayColor = Color(0xFFF7F8F8);
  static const midGrayColor = Color.fromARGB(255, 238, 233, 234);

  static List<Color> get primaryG => [primaryColor1, primaryColor2];
  static List<Color> get secondaryG => [secondaryColor1, secondaryColor2];
  static List<Color> get secondaryF => [primaryColor2, secondaryColor2];
  static List<Color> get secondaryH => [secondaryColor1, primaryColor1];
  static List<Color> get gray => [grayColor, midGrayColor];
}
