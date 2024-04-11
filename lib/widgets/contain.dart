import 'package:flutter/material.dart';

class SquareSkewCut extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0.5, 13); // Start at top-left corner
    path.lineTo(size.width, 0); // Line to top-right corner
    path.lineTo(size.width, size.height); // Line to bottom-right corner
    path.lineTo(0, size.height * 5); // Line to mid-point on left side
    path.close();
    return path;
  }

  @override
  bool shouldReclip(SquareSkewCut oldClipper) => false;
}
