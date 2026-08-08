import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/responsive_text.dart';

class PrimaryButton extends StatefulWidget {
  final String title;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color textColor;
  final double fontSize;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.width,
    this.height = 54.0,
    this.borderRadius = 30.0,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.fontSize = 16.0,
    this.icon,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.onboardingBtn;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: _isPressed ? 0.25 : 0.40),
                blurRadius: _isPressed ? 8 : 16,
                offset: Offset(0, _isPressed ? 3 : 6),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ResponsiveText(
                  widget.title,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w700,
                  color: widget.textColor,
                ),
                if (widget.icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    widget.icon,
                    color: widget.textColor,
                    size: widget.fontSize + 2,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomOutlineButton extends StatefulWidget {
  final String title;
  final VoidCallback onPressed;
  final String? iconAsset;
  final double height;
  final double borderRadius;

  const CustomOutlineButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.iconAsset,
    this.height = 54.0,
    this.borderRadius = 30.0,
  });

  @override
  State<CustomOutlineButton> createState() => _CustomOutlineButtonState();
}

class _CustomOutlineButtonState extends State<CustomOutlineButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.08),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.iconAsset != null) ...[
                Image.asset(
                  widget.iconAsset!,
                  width: 22,
                  height: 22,
                ),
                const SizedBox(width: 12),
              ],
              ResponsiveText(
                widget.title,
                fontSize: 15.5,
                fontWeight: FontWeight.w600,
                color: AppColors.onboardingTitle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
