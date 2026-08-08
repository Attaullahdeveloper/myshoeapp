import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResponsiveText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? letterSpacing;
  final List<Shadow>? shadows;
  final double? height;
  final bool usePlayfair; // Set to true for headings/title font style

  const ResponsiveText(
    this.text, {
    super.key,
    required this.fontSize,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.letterSpacing,
    this.shadows,
    this.height,
    this.usePlayfair = false,
  });

  @override
  Widget build(BuildContext context) {
    // Using standard mobile screen width (375) as reference scale baseline
    final screenWidth = MediaQuery.of(context).size.width;
    final double scaleFactor = (screenWidth / 375.0).clamp(0.85, 1.4);
    final double responsiveSize = fontSize * scaleFactor;

    final textStyle = usePlayfair
        ? GoogleFonts.playfairDisplay(
            fontSize: responsiveSize,
            color: color ?? Colors.white,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            shadows: shadows,
            height: height,
          )
        : TextStyle(
            fontFamily: 'Airbnb Cereal App',
            fontSize: responsiveSize,
            color: color ?? Colors.white,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            shadows: shadows,
            height: height,
          );

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: textStyle,
    );
  }
}
