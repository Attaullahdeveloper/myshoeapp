import 'package:flutter/material.dart';

/// A sleek Shimmer Skeleton Loader container widget.
class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget? child;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 16.0,
    this.child,
  });

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_shimmerAnimation.value - 1.0, -0.3),
              end: Alignment(_shimmerAnimation.value + 1.0, 0.3),
              colors: const [
                Color(0xFFEBEBF4),
                Color(0xFFF6F6FA),
                Color(0xFFEBEBF4),
              ],
              stops: const [0.1, 0.5, 0.9],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// A Skeleton Loader card matching the Shoe card format.
class ShoeCardSkeleton extends StatelessWidget {
  const ShoeCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder shimmer box
          const Expanded(
            child: ShimmerLoader(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 12,
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle shimmer
          const ShimmerLoader(
            width: 80,
            height: 10,
            borderRadius: 4,
          ),
          const SizedBox(height: 6),
          // Title shimmer
          const ShimmerLoader(
            width: 120,
            height: 14,
            borderRadius: 4,
          ),
          const SizedBox(height: 6),
          // Subtitle 2 shimmer
          const ShimmerLoader(
            width: 70,
            height: 10,
            borderRadius: 4,
          ),
          const SizedBox(height: 12),
          // Price and dots row shimmer
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerLoader(
                width: 60,
                height: 14,
                borderRadius: 4,
              ),
              Row(
                children: [
                  ShimmerLoader(width: 12, height: 12, borderRadius: 6),
                  SizedBox(width: 4),
                  ShimmerLoader(width: 12, height: 12, borderRadius: 6),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 2-column Grid of Skeleton Cards
class BestSellersGridSkeleton extends StatelessWidget {
  final int itemCount;
  const BestSellersGridSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ShoeCardSkeleton(),
    );
  }
}
