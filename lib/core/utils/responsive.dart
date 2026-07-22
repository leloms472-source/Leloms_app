import 'package:flutter/material.dart';

class Responsive {
  static double width(BuildContext context) => MediaQuery.of(context).size.width;
  static double height(BuildContext context) => MediaQuery.of(context).size.height;

  static bool isMobile(BuildContext context) => width(context) < 600;
  static bool isTablet(BuildContext context) => width(context) >= 600 && width(context) < 1024;
  static bool isDesktop(BuildContext context) => width(context) >= 1024;

  static double padding(BuildContext context) => isMobile(context) ? 16.0 : 24.0;

  static double fontSize(BuildContext context, double mobileSize) {
    if (isMobile(context)) return mobileSize;
    if (isTablet(context)) return mobileSize * 1.15;
    return mobileSize * 1.25;
  }

  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  static double cardWidth(BuildContext context) {
    final w = width(context);
    if (isDesktop(context)) return (w - 80) / 4;
    if (isTablet(context)) return (w - 64) / 3;
    return (w - 48) / 2;
  }

  static double iconSize(BuildContext context, double size) {
    if (isMobile(context)) return size;
    return size * 1.2;
  }
}
