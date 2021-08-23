import 'dart:math';

import 'package:flutter/material.dart';

const Color deusEx = Color(0xFFCBB7B3);

final kThemeSwatch = MaterialColor(
  deusEx.value,
  {
    50: tintColor(deusEx, 0.9),
    100: tintColor(deusEx, 0.8),
    200: tintColor(deusEx, 0.6),
    300: tintColor(deusEx, 0.4),
    400: tintColor(deusEx, 0.2),
    500: deusEx,
    600: shadeColor(deusEx, 0.1),
    700: shadeColor(deusEx, 0.2),
    800: shadeColor(deusEx, 0.3),
    900: shadeColor(deusEx, 0.4),
  },
);

int tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1);

int shadeValue(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

Color shadeColor(Color color, double factor) => Color.fromRGBO(
    shadeValue(color.red, factor),
    shadeValue(color.green, factor),
    shadeValue(color.blue, factor),
    1);