import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class FluidPopNavItem extends StatefulWidget {
  final int index;
  final String? iconPath;
  final IconData? iconData;
  final bool isSelected;
  final VoidCallback onTap;

  const FluidPopNavItem({
    super.key,
    required this.index,
    this.iconPath,
    this.iconData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<FluidPopNavItem> createState() => _FluidPopNavItemState();
}

class _FluidPopNavItemState extends State<FluidPopNavItem> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _morphAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    // Dynamic Pop scale: springs up, then settles nicely
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.15).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_animController);

    // Morph curve: soft bubble stretch
    _morphAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOutCubic,
    );

    if (widget.isSelected) {
      _animController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant FluidPopNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _animController.forward(from: 0.0);
      } else {
        _animController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _animController,
        builder: (context, child) {
          final scale = widget.isSelected ? _scaleAnimation.value : 1.0;
          final morph = _morphAnimation.value;

          return SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── Morphing Bubble Background ──
                if (widget.isSelected || _animController.isAnimating)
                  Opacity(
                    opacity: morph.clamp(0.0, 1.0) * 0.12,
                    child: Transform.scale(
                      scale: 0.8 + (morph * 0.4), // grows from 0.8 to 1.2
                      child: Container(
                        // Morphs width dynamically during transition
                        width: 44 + (8 * (1.0 - morph)), 
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.onboardingBtn,
                          borderRadius: BorderRadius.circular(
                            22 - (6 * (1.0 - morph)), // circularity morphs slightly
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.onboardingBtn.withValues(alpha: 0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ── Pop Animated Icon ──
                Transform.scale(
                  scale: scale,
                  child: widget.iconData != null
                      ? Icon(
                          widget.iconData,
                          size: 26,
                          color: widget.isSelected
                              ? AppColors.onboardingBtn
                              : AppColors.onboardingSub,
                        )
                      : Image.asset(
                          widget.iconPath!,
                          width: 24,
                          height: 24,
                          color: widget.isSelected
                              ? AppColors.onboardingBtn // Highlighted color
                              : AppColors.onboardingSub, // Inactive gray/sub color
                        ),
                ),

                // ── Morphing Bottom Indicator Dot/Pill ──
                Positioned(
                  bottom: 6,
                  child: Opacity(
                    opacity: morph.clamp(0.0, 1.0),
                    child: Container(
                      width: 4 + (10 * morph), // stretches width from 4 to 14
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.onboardingBtn,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
