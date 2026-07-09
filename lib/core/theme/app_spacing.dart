import 'package:flutter/material.dart';

/// Definición centralizada de espaciado
abstract class AppSpacing {
  // Spacing base
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;

  // Common EdgeInsets
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets paddingVerticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXl = EdgeInsets.symmetric(vertical: xl);

  // Gaps for SizedBox
  static const SizedBox gapXs = SizedBox(width: xs, height: xs);
  static const SizedBox gapSm = SizedBox(width: sm, height: sm);
  static const SizedBox gapMd = SizedBox(width: md, height: md);
  static const SizedBox gapLg = SizedBox(width: lg, height: lg);
  static const SizedBox gapXl = SizedBox(width: xl, height: xl);
  static const SizedBox gapXxl = SizedBox(width: xxl, height: xxl);

  // Gaps vertical
  static const SizedBox gapVerticalXs = SizedBox(height: xs);
  static const SizedBox gapVerticalSm = SizedBox(height: sm);
  static const SizedBox gapVerticalMd = SizedBox(height: md);
  static const SizedBox gapVerticalLg = SizedBox(height: lg);
  static const SizedBox gapVerticalXl = SizedBox(height: xl);
  static const SizedBox gapVerticalXxl = SizedBox(height: xxl);

  // Gaps horizontal
  static const SizedBox gapHorizontalXs = SizedBox(width: xs);
  static const SizedBox gapHorizontalSm = SizedBox(width: sm);
  static const SizedBox gapHorizontalMd = SizedBox(width: md);
  static const SizedBox gapHorizontalLg = SizedBox(width: lg);
  static const SizedBox gapHorizontalXl = SizedBox(width: xl);
  static const SizedBox gapHorizontalXxl = SizedBox(width: xxl);
}
