import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../models/app_notification.dart';
import '../../utils/app_colors.dart';
import '../../widgets/responsive_text.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = NotificationController.to;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.onboardingBg, // #F9F9F9
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── TOP BAR (Back Button, Notifications Title, Clear All) ─────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Arrow Button
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) {
                        Get.back();
                      } else if (Get.isRegistered<HomeController>()) {
                        Get.find<HomeController>().changeIndex(0);
                      }
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.onboardingTitle,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // Title: Notifications
                  ResponsiveText(
                    'Notifications',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onboardingTitle,
                  ),

                  // Clear All Text Button
                  Obx(() {
                    if (controller.notifications.isEmpty) {
                      return const SizedBox(width: 60);
                    }
                    return GestureDetector(
                      onTap: () => controller.clearAll(),
                      child: const ResponsiveText(
                        'Clear All',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF5B9EE1),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── NOTIFICATIONS LIST BODY ───────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.notifications.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_off_outlined,
                            size: 48,
                            color: AppColors.onboardingSub,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ResponsiveText(
                          'No Notifications Yet',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onboardingTitle,
                        ),
                        const SizedBox(height: 8),
                        ResponsiveText(
                          'You\'re all caught up! New offers will appear here.',
                          fontSize: 14,
                          color: AppColors.onboardingSub,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                final todayItems = controller.todayNotifications;
                final yesterdayItems = controller.yesterdayNotifications;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. TODAY SECTION ──
                      if (todayItems.isNotEmpty) ...[
                        ResponsiveText(
                          'Today',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onboardingTitle,
                        ),
                        const SizedBox(height: 12),
                        ...todayItems.map((item) => _buildNotificationCard(item)),
                        const SizedBox(height: 16),
                      ],

                      // ── 2. YESTERDAY SECTION ──
                      if (yesterdayItems.isNotEmpty) ...[
                        ResponsiveText(
                          'Yesterday',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onboardingTitle,
                        ),
                        const SizedBox(height: 12),
                        ...yesterdayItems.map((item) => _buildNotificationCard(item)),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Notification Item Card ──
  Widget _buildNotificationCard(AppNotification item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shoe Thumbnail Container
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Image.asset(
                item.image,
                width: 60,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Title & Price Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  item.title,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onboardingTitle,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${item.originalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Airbnb Cereal App',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ResponsiveText(
                      '\$${item.discountedPrice.toStringAsFixed(2)}',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onboardingTitle,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Time Ago Text (Top Right)
          ResponsiveText(
            item.timeAgo,
            fontSize: 12,
            color: AppColors.onboardingSub,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
