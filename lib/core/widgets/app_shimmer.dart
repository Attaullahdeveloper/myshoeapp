import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// 1. REUSABLE SHIMMER CORE UTILITIES
/// ─────────────────────────────────────────────────────────────────────────────

/// Base Shimmer widget wrapping children with standard smooth animations
class AppShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? period;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey.shade300,
      highlightColor: highlightColor ?? Colors.grey.shade100,
      period: period ?? const Duration(milliseconds: 1100),
      child: child,
    );
  }
}

/// Geometric placeholder box for quick shimmer mockups
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Alias for backwards compatibility
typedef AppShimmerBox = ShimmerBox;

/// ─────────────────────────────────────────────────────────────────────────────
/// 2. SCREEN-BY-SCREEN SKELETON COMPONENTS
/// ─────────────────────────────────────────────────────────────────────────────

/// A. Home Screen - Brand Logos Row Skeleton
class HomeBrandLogosShimmer extends StatelessWidget {
  const HomeBrandLogosShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, index) {
            const widths = [88.0, 76.0, 82.0, 78.0];
            return ShimmerBox(
              width: widths[index % widths.length],
              height: 38,
              borderRadius: 22,
            );
          },
        ),
      ),
    );
  }
}

/// A. Home Screen - Popular Shoes Section Skeleton
class HomePopularShoesShimmer extends StatelessWidget {
  final int count;
  const HomePopularShoesShimmer({super.key, this.count = 2});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SizedBox(
        height: 215,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: count,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            return Container(
              width: 157,
              height: 201,
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
              child: Stack(
                children: [
                  // Circular image backdrop placeholder inside
                  Positioned(
                    top: 18,
                    left: 28,
                    right: 28,
                    child: Center(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  // Bottom content: 2 text lines (Shoe Name 70%, Price 40%)
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Best seller / Brand tag
                        Container(
                          width: 45,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Shoe Name (70% width)
                        Container(
                          width: 100,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Price Line (40% width)
                        Container(
                          width: 55,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rounded square box at bottom right for "+" button
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// A. Home Screen - New Arrivals / Special Offers Banner Skeleton
class HomeNewArrivalsShimmer extends StatelessWidget {
  const HomeNewArrivalsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SizedBox(
        height: 125,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 2,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.82,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const ShimmerBox(width: 80, height: 12, borderRadius: 6),
                        const SizedBox(height: 8),
                        const ShimmerBox(width: 130, height: 16, borderRadius: 6),
                        const SizedBox(height: 8),
                        const ShimmerBox(width: 60, height: 12, borderRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const ShimmerBox(width: 85, height: 75, borderRadius: 12),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// B. Cart Screen - Cart Items Skeleton (3 List items)
class CartItemsShimmer extends StatelessWidget {
  final int itemCount;
  const CartItemsShimmer({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Left: Rounded square container (70x70) for shoe image
                const ShimmerBox(
                  width: 70,
                  height: 70,
                  borderRadius: 14,
                ),
                const SizedBox(width: 14),
                // Middle: 2 shimmer lines (Shoe title & Price tag)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerBox(width: 120, height: 14, borderRadius: 6),
                      const SizedBox(height: 8),
                      const ShimmerBox(width: 70, height: 13, borderRadius: 6),
                      const SizedBox(height: 6),
                      const ShimmerBox(width: 45, height: 10, borderRadius: 4),
                    ],
                  ),
                ),
                // Right: Counter capsule (width 60, height 30) & delete placeholder
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const ShimmerBox(
                      width: 60,
                      height: 30,
                      borderRadius: 15,
                    ),
                    const SizedBox(height: 10),
                    const ShimmerBox(
                      width: 22,
                      height: 22,
                      shape: BoxShape.circle,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// B. Cart Screen - Summary Section Skeleton (Subtotal, Shipping, Total)
class CartSummaryShimmer extends StatelessWidget {
  const CartSummaryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtotal row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBox(width: 70, height: 14, borderRadius: 6),
                ShimmerBox(width: 60, height: 14, borderRadius: 6),
              ],
            ),
            const SizedBox(height: 12),
            // Shipping row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBox(width: 80, height: 14, borderRadius: 6),
                ShimmerBox(width: 50, height: 14, borderRadius: 6),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            // Total Cost row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerBox(width: 90, height: 18, borderRadius: 6),
                ShimmerBox(width: 80, height: 18, borderRadius: 6),
              ],
            ),
            const SizedBox(height: 20),
            // Checkout button placeholder
            const ShimmerBox(
              width: double.infinity,
              height: 52,
              borderRadius: 28,
            ),
          ],
        ),
      ),
    );
  }
}

/// C. Notifications Screen - Notification Tiles Skeleton (4 List tiles)
class NotificationTilesShimmer extends StatelessWidget {
  final int count;
  const NotificationTilesShimmer({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Rounded shoe thumbnail box (50x50)
                const ShimmerBox(
                  width: 50,
                  height: 50,
                  borderRadius: 12,
                ),
                const SizedBox(width: 14),
                // Middle: 2 title lines ("We Have New Products With Offers" + Price line)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: double.infinity, height: 13, borderRadius: 6),
                      SizedBox(height: 6),
                      ShimmerBox(width: 140, height: 13, borderRadius: 6),
                      SizedBox(height: 8),
                      ShimmerBox(width: 80, height: 11, borderRadius: 4),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Right: Time badge placeholder ("6 min ago")
                const ShimmerBox(
                  width: 55,
                  height: 12,
                  borderRadius: 6,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// D. Admin Dashboard - Skeletons for Stat Cards & Action Tiles
class AdminDashboardShimmer extends StatelessWidget {
  const AdminDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat Metric Cards (2 top rectangular cards)
          Row(
            children: const [
              Expanded(
                child: ShimmerBox(
                  height: 90,
                  borderRadius: 16,
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: ShimmerBox(
                  height: 90,
                  borderRadius: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const ShimmerBox(width: 150, height: 18, borderRadius: 6),
          const SizedBox(height: 14),
          // Management Action Tiles (3 wide rounded cards with icon & trailing box)
          for (int i = 0; i < 3; i++) ...[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: const [
                  ShimmerBox(width: 48, height: 48, borderRadius: 14),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 140, height: 14, borderRadius: 6),
                        SizedBox(height: 6),
                        ShimmerBox(width: 190, height: 11, borderRadius: 4),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  ShimmerBox(width: 28, height: 28, shape: BoxShape.circle),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// E. Admin Products View - Skeletons for Brand Chips & Product List
class AdminProductsShimmer extends StatelessWidget {
  final int count;
  const AdminProductsShimmer({super.key, this.count = 4});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Chips (5 rounded chip placeholders)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, __) => const ShimmerBox(
                width: 75,
                height: 36,
                borderRadius: 18,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Product Cards
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: count,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left circular dark shoe thumbnail
                          const ShimmerBox(
                            width: 65,
                            height: 65,
                            borderRadius: 14,
                          ),
                          const SizedBox(width: 14),
                          // Middle: Title, price, rating star placeholder
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                ShimmerBox(width: 130, height: 14, borderRadius: 6),
                                SizedBox(height: 6),
                                ShimmerBox(width: 70, height: 13, borderRadius: 6),
                                SizedBox(height: 6),
                                ShimmerBox(width: 50, height: 10, borderRadius: 4),
                              ],
                            ),
                          ),
                          // Action buttons: Edit & Delete icon placeholders
                          Row(
                            children: const [
                              ShimmerBox(width: 32, height: 32, borderRadius: 8),
                              SizedBox(width: 8),
                              ShimmerBox(width: 32, height: 32, borderRadius: 8),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      // Bottom: Size chip pills row & color dots placeholders
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              ShimmerBox(width: 26, height: 18, borderRadius: 4),
                              SizedBox(width: 4),
                              ShimmerBox(width: 26, height: 18, borderRadius: 4),
                              SizedBox(width: 4),
                              ShimmerBox(width: 26, height: 18, borderRadius: 4),
                            ],
                          ),
                          Row(
                            children: const [
                              ShimmerBox(width: 14, height: 14, shape: BoxShape.circle),
                              SizedBox(width: 4),
                              ShimmerBox(width: 14, height: 14, shape: BoxShape.circle),
                              SizedBox(width: 4),
                              ShimmerBox(width: 14, height: 14, shape: BoxShape.circle),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// F. Profile Screen - Skeleton (Avatar + 3 Text Field Bars)
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Top avatar circular shimmer (diameter 90)
            const Center(
              child: ShimmerBox(
                width: 90,
                height: 90,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 32),
            // 3 text field skeleton bars (Full Name, Email, Password)
            for (int i = 0; i < 3; i++) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerBox(width: 90, height: 12, borderRadius: 6),
                  SizedBox(height: 8),
                  ShimmerBox(
                    width: double.infinity,
                    height: 50,
                    borderRadius: 14,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            const SizedBox(height: 16),
            const ShimmerBox(
              width: double.infinity,
              height: 52,
              borderRadius: 26,
            ),
          ],
        ),
      ),
    );
  }
}

/// G. Search View - Recommendations Skeleton (6 Search History rows)
class SearchRecommendationsShimmer extends StatelessWidget {
  final int count;
  const SearchRecommendationsShimmer({super.key, this.count = 6});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          return Row(
            children: const [
              // Leading clock / search icon placeholder
              ShimmerBox(
                width: 20,
                height: 20,
                shape: BoxShape.circle,
              ),
              SizedBox(width: 14),
              // Text placeholder line
              Expanded(
                child: ShimmerBox(
                  height: 14,
                  borderRadius: 6,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Helper for network image loading builder with smooth shimmer effect
class ShimmerImageLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  const ShimmerImageLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ShimmerBox(
        width: width,
        height: height,
        borderRadius: borderRadius,
        shape: shape,
      ),
    );
  }
}

/// Backward compatibility wrappers
class AppCompanyCardShimmer extends StatelessWidget {
  const AppCompanyCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeBrandLogosShimmer();
  }
}

class AppProductCardShimmer extends StatelessWidget {
  const AppProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomePopularShoesShimmer(count: 1);
  }
}

class AppOrderItemShimmer extends StatelessWidget {
  const AppOrderItemShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const CartItemsShimmer(itemCount: 1);
  }
}
