import 'package:flutter/material.dart';

class AnimatedSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? activeText;
  final String? inactiveText;
  final Color activeColor;
  final Color inactiveColor;

  const AnimatedSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeText,
    this.inactiveText,
    this.activeColor = const Color(0xFF5B9EE1),
    this.inactiveColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 54,
        height: 30,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: value ? activeColor : inactiveColor,
          boxShadow: [
            if (value)
              BoxShadow(
                color: activeColor.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                value ? Icons.check_rounded : Icons.close_rounded,
                size: 14,
                color: value ? activeColor : const Color(0xFF707B81),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
