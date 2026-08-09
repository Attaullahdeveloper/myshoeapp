import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/company_controller.dart';
import '../../controllers/home_controller.dart';
import '../../utils/app_colors.dart';
import '../../widgets/responsive_text.dart';
import '../companies/edit_companies_view.dart';
import 'edit_products_view.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final companyController = Get.isRegistered<CompanyController>()
        ? Get.find<CompanyController>()
        : Get.put(CompanyController());
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.onboardingBg, // #F9F9F9 Light theme background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. HEADER ROW ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Color(0xFF1A2530),
                        ),
                      ),
                    ),

                    // Title
                    const ResponsiveText(
                      'Admin Control Panel',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2530),
                    ),

                    // Admin Badge Icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9EE1).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 22,
                        color: Color(0xFF5B9EE1),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── 2. HERO GREETING BANNER ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1A2530), Color(0xFF2C3E50)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5B9EE1).withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'SYSTEM MANAGEMENT',
                              style: TextStyle(
                                color: Color(0xFF5B9EE1),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const ResponsiveText(
                            'Manage Store Data',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Control companies, products, sizes, multi-colors and images statically.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── 3. QUICK STATS ROW ──
                Obx(() {
                  final totalCompanies = companyController.companies.length;
                  final totalProducts = homeController.products.length;
                  final activeCompanies = companyController.companies
                      .where((c) => c.isActive)
                      .length;

                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatTile(
                          title: 'Companies',
                          value: '$totalCompanies',
                          subtitle: '$activeCompanies Active',
                          icon: Icons.business_outlined,
                          color: const Color(0xFF5B9EE1),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildStatTile(
                          title: 'Total Shoes',
                          value: '$totalProducts',
                          subtitle: 'In Catalog',
                          icon: Icons.inventory_2_outlined,
                          color: const Color(0xFFE74C3C),
                        ),
                      ),
                    ],
                  );
                }),

                const SizedBox(height: 28),

                const ResponsiveText(
                  'Management Sections',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2530),
                ),
                const SizedBox(height: 14),

                // ── 4. COMPANIES BUTTON CARD ──
                _buildActionCard(
                  title: 'Companies Management',
                  subtitle: 'Fetch, edit and create shoe companies/brands',
                  icon: Icons.business_center_rounded,
                  badgeText: 'GET COMPANIES',
                  accentColor: const Color(0xFF5B9EE1),
                  onTap: () => Get.to(() => const EditCompaniesView()),
                ),

                const SizedBox(height: 16),

                // ── 5. PRODUCTS (SHOES) BUTTON CARD ──
                _buildActionCard(
                  title: 'Products (Shoes) Management',
                  subtitle: 'Fetch all shoes, edit sizes, multi-colors & multi-images',
                  icon: Icons.storefront_rounded,
                  badgeText: 'GET ALL SHOES',
                  accentColor: const Color(0xFF1A2530),
                  onTap: () => Get.to(() => const EditProductsView()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              ResponsiveText(
                value,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A2530),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ResponsiveText(
            title,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A2530),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF707B81),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String badgeText,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.15),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: accentColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ResponsiveText(
                    title,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2530),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF707B81),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
