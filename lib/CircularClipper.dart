/*
 * Copyright © 2021 -  Dorian & Co - All right reserved
 */

import 'dart:math';

import 'package:flutter/cupertino.dart';

class CircularClipper extends CustomClipper<Path> {
  int percent;
  CircularClipper(this.percent);

  Path getClip(Size size) {
    Path path = Path();
    double ratio = percent / 100;
    double radius = max(size.width, size.height) * ratio * sqrt(2);
    path.addOval(Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: radius, height: radius));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
