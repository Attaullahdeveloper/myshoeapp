import 'package:flutter/material.dart';
import 'responsive_text.dart';
import '../utils/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onSuffixIconPressed;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onSuffixIconPressed,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          label,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.onboardingTitle,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !isPasswordVisible,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontFamily: 'Airbnb Cereal App',
              fontSize: 15,
              color: Color(0xFF1A2530),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontFamily: 'Airbnb Cereal App',
                fontSize: 14,
                color: Color(0xFF707B81),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: InputBorder.none,
              suffixIcon: suffixIcon ?? (isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF707B81),
                        size: 22,
                      ),
                      onPressed: onSuffixIconPressed,
                    )
                  : null),
            ),
          ),
        ),
      ],
    );
  }
}
