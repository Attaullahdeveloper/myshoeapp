import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/onboarding_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/custom_button.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    final size = MediaQuery.of(context).size;

    // Defined pages data based on user design requests
    final List<OnboardingData> onboardingPages = [
      OnboardingData(
        image: AppImages.onboarding1,
        title: "Original Brands,\nAffordable Prices",
        subtitle: "Get 100% authentic imported shoes from top global brands at the lowest prices.",
        bottomOffset: -0.145,
      ),
      OnboardingData(
        image: AppImages.onboarding2,
        title: "Premium Quality,\nHandpicked",
        subtitle: "Every pair is strictly inspected, cleaned, and sanitized for near-new condition.",
        bottomOffset: -0.125,
      ),
      OnboardingData(
        image: AppImages.onboarding3,
        title: "Step Into\nYour Style",
        subtitle: "Upgrade your sneaker game with unbeatable value. Find your perfect fit now.",
        bottomOffset: -0.125,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.onboardingBg, // #F9F9F9 Background color
      body: Stack(
        children: [
          // ── Top-Right Ellipse Shape (placed outside SafeArea to touch physical edges) ──
          Positioned(
            top: -size.height * 0.02,
            right: -size.width * 0.08,
            child: Image.asset(
              AppImages.ellipse,
              width: size.width * 0.57,
              fit: BoxFit.contain,
            ),
          ),

          // ── Page View Content (inside SafeArea for aligned screen elements) ──
          SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutQuart,
                    builder: (context, entryValue, child) {
                      return PageView.builder(
                        physics: const BouncingScrollPhysics(),
                        controller: controller.pageController,
                        onPageChanged: controller.onPageChanged,
                        itemCount: onboardingPages.length,
                        itemBuilder: (context, index) {
                          final data = onboardingPages[index];
                          return AnimatedBuilder(
                            animation: controller.pageController,
                            builder: (context, child) {
                              double pageOffset = 0.0;
                              if (controller.pageController.hasClients &&
                                  controller.pageController.position.hasContentDimensions) {
                                pageOffset = controller.pageController.page! - index;
                              } else {
                                pageOffset = (controller.currentPage.value - index).toDouble();
                              }

                              final double absOffset = pageOffset.abs().clamp(0.0, 1.0);
                              final double curvedOffset = Curves.easeInOutCubic.transform(absOffset);
                              final double sign = pageOffset < 0 ? -1.0 : 1.0;
                              final double curvedSignedOffset = curvedOffset * sign;

                              // Merge with entrance animation (runs on first page load)
                              // Only apply entrance animation to the first page (index 0)
                              double itemOpacity = (1.0 - curvedOffset).clamp(0.0, 1.0);
                              double shoeScale = (1.0 - (curvedOffset * 0.12)).clamp(0.88, 1.0);
                              double textScale = (1.0 - (curvedOffset * 0.06)).clamp(0.94, 1.0);
                              
                              double entryTranslateY = 0.0;
                              double entryShoeTranslateY = 0.0;
                              
                              if (index == 0) {
                                itemOpacity *= entryValue;
                                shoeScale *= (0.85 + 0.15 * entryValue);
                                textScale *= (0.95 + 0.05 * entryValue);
                                entryTranslateY = (1.0 - entryValue) * 35.0; // Text slides up
                                entryShoeTranslateY = (1.0 - entryValue) * 50.0; // Shoe floats down/up
                              }

                              // Parallax horizontal slide translations
                              final double shoeTranslateX = curvedSignedOffset * size.width * 0.35;
                              final double titleTranslateX = curvedSignedOffset * size.width * 0.22;
                              final double subtitleTranslateX = curvedSignedOffset * size.width * 0.36;
                              
                              // Slide down-up/vertical offset for text
                              final double textTranslateY = (curvedOffset * 35.0) + entryTranslateY;

                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Spacer(),

                                    // ── Shoe Graphic & Background Stack ───────────────────
                                    Transform.translate(
                                      offset: Offset(shoeTranslateX, entryShoeTranslateY),
                                      child: Transform.scale(
                                        scale: shoeScale,
                                        child: Opacity(
                                          opacity: itemOpacity,
                                          child: Center(
                                            child: SizedBox(
                                              height: size.height * 0.44,
                                              width: size.width * 0.92,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                clipBehavior: Clip.none,
                                                children: [
                                                  // 1. Three Dots Overlay Pattern (Animate with opposing parallax and rotation)
                                                  Positioned.fill(
                                                    child: Transform.translate(
                                                      offset: Offset(-curvedSignedOffset * size.width * 0.25, 0), // Opposing parallax
                                                      child: Transform.rotate(
                                                        angle: -curvedSignedOffset * 0.5, // Subtle rotation
                                                        child: Transform.scale(
                                                          scale: (1.0 - (curvedOffset * 0.12)).clamp(0.88, 1.0),
                                                          child: Image.asset(
                                                            AppImages.onboardingDots,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                  // 2. Large "MM" Background Text
                                                  Positioned(
                                                    bottom: size.height * 0.14,
                                                    child: Text(
                                                      "MM",
                                                      style: TextStyle(
                                                        fontFamily: 'Airbnb Cereal App',
                                                        fontSize: 160,
                                                        fontWeight: FontWeight.w900,
                                                        color: Colors.black.withValues(alpha: 0.045),
                                                        letterSpacing: -10,
                                                        height: 1.0,
                                                      ),
                                                    ),
                                                  ),

                                                  // 3. Sneaker / Boot Image (Shifted to the bottom of the stack with 3D rotation)
                                                  Positioned(
                                                    bottom: size.height * data.bottomOffset,
                                                    child: Transform(
                                                      alignment: Alignment.center,
                                                      transform: Matrix4.identity()
                                                        ..setEntry(3, 2, 0.0015) // Perspective factor
                                                        ..rotateY(-curvedSignedOffset * 0.7) // 3D Y-axis turn rotation
                                                        ..rotateZ(-curvedSignedOffset * 0.12), // Organic flight angle tilt
                                                      child: Image.asset(
                                                        data.image,
                                                        width: size.width * 0.98,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Adjusted space to prevent layout pushing/clipping on mobile screens
                                    SizedBox(height: size.height * 0.005),

                                    // ── Title & Subtitle Wrapper with Staggered Animations ──────
                                    Opacity(
                                      opacity: itemOpacity,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // ── Title (Original Brands, Affordable Prices) ────────
                                          Transform.translate(
                                            offset: Offset(titleTranslateX, textTranslateY),
                                            child: Transform.scale(
                                              scale: textScale,
                                              child: ResponsiveText(
                                                data.title,
                                                fontSize: 30,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.onboardingTitle, // #1A2530 as requested
                                                textAlign: TextAlign.start,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),

                                          SizedBox(height: size.height * 0.015),

                                          // ── Sub-text / Subtitle (formatted in two lines) ──────
                                          Transform.translate(
                                            offset: Offset(subtitleTranslateX, textTranslateY * 1.3),
                                            child: Transform.scale(
                                              scale: textScale,
                                              child: ResponsiveText(
                                                data.subtitle,
                                                fontSize: 17, // Increased font size as requested
                                                fontWeight: FontWeight.w400,
                                                color: AppColors.onboardingSub, // #707B81 as requested
                                                textAlign: TextAlign.start,
                                                height: 1.5,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    SizedBox(height: size.height * 0.20),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),

                // ── Bottom Section (Dots Indicators & Action Button) ─────────
                Positioned(
                  bottom: size.height * 0.04,
                  left: size.width * 0.07,
                  right: size.width * 0.07,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page Indicators (changed inactive color to dark/translucent grey for light BG)
                      Row(
                        children: List.generate(
                          onboardingPages.length,
                          (index) => Obx(() {
                            final isActive = controller.currentPage.value == index;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: size.height * 0.007,
                              width: isActive ? size.width * 0.07 : size.width * 0.02,
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.onboardingBtn : Colors.black.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ),

                      // High-end PrimaryButton
                      Obx(() {
                        final isLast = controller.isLastPage;
                        return PrimaryButton(
                          title: isLast ? 'Get Started' : 'Next',
                          onPressed: controller.nextPage,
                          width: isLast ? size.width * 0.44 : size.width * 0.32,
                          height: size.height * 0.065,
                          borderRadius: 30,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;
  final String subtitle;
  final double bottomOffset;

  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.bottomOffset,
  });
}
