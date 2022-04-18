import 'package:flutter/material.dart';
import 'package:weatherapp/helper/colors.dart';

BoxDecoration appBackground = BoxDecoration(gradient: bgGradient);

LinearGradient bgGradient =  LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter);

LinearGradient textGradient = const LinearGradient(colors: <Color>[
  Color(0xffffffff),
  Color(0x22ffffff),
], begin: Alignment(0, -0.4), end: Alignment.bottomCenter);
