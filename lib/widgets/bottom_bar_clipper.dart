import 'package:flutter/material.dart';

class BottomBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Original viewBox: 375 x 80. Coordinates ko actual size par scale karte hain.
    final double sx = size.width / 375.0;
    final double sy = size.height / 80.0;

    double dx(double v) => v * sx;
    double dy(double v) => v * sy;

    final path = Path();
    // M0,0 -> Raised corner at (0,0)
    path.moveTo(dx(0), dy(0));
    
    // Sharp curve down to the flat base level (30,15)
    path.cubicTo(dx(10), dy(0), dx(20), dy(15), dx(30), dy(15));
    
    // Flat line to the scoop start (110,15)
    path.lineTo(dx(110), dy(15));
    
    // Scoop from (110,15) to (187,57)
    path.cubicTo(dx(138), dy(15), dx(150), dy(57), dx(187), dy(57));
    
    // Scoop from (187,57) to (264,15)
    path.cubicTo(dx(224), dy(57), dx(236), dy(15), dx(264), dy(15));
    
    // Flat line to the corner-curve start (345,15)
    path.lineTo(dx(345), dy(15));
    
    // Sharp curve up to the raised corner (375,0)
    path.cubicTo(dx(355), dy(15), dx(365), dy(0), dx(375), dy(0));
    
    // Line to bottom-right (375,80)
    path.lineTo(dx(375), dy(80));
    // Line to bottom-left (0,80)
    path.lineTo(dx(0), dy(80));
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
