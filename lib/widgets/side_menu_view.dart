import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../views/auth/signin_view.dart';
import '../views/cart/cart_view.dart';
import '../views/profile/profile_view.dart';
import '../views/admin/admin_dashboard_view.dart';
import '../views/companies/edit_companies_view.dart';
import '../widgets/responsive_text.dart';

class SideMenuView extends StatelessWidget {
  final ZoomDrawerController zoomDrawerController;

  const SideMenuView({super.key, required this.zoomDrawerController});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    return Scaffold(
      backgroundColor: const Color(0xFF1A2530), // #1A2530 Dark Side Menu Background
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.06,
            vertical: size.height * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // ── 1. USER PROFILE SECTION ──
              Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      image: const DecorationImage(
                        image: AssetImage('assets/images/ellipse.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const ResponsiveText(
                    'Hey, ',
                    fontSize: 17,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                  const Text(
                    '👋',
                    style: TextStyle(fontSize: 17),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              const ResponsiveText(
                'Alisson Becker',
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),

              const SizedBox(height: 36),

              // ── 2. SIDE MENU NAV ITEMS ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Profile',
                        onTap: () {
                          zoomDrawerController.close?.call();
                          Get.to(() => const ProfileView());
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.home_outlined,
                        title: 'Home Page',
                        onTap: () {
                          zoomDrawerController.close?.call();
                          controller.changeIndex(0); // Home tab
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.shopping_bag_outlined,
                        title: 'My Cart',
                        onTap: () {
                          zoomDrawerController.close?.call();
                          Get.to(() => const CartView());
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.favorite_border_rounded,
                        title: 'Favorite',
                        onTap: () {
                          zoomDrawerController.close?.call();
                          controller.changeIndex(1); // Favorite tab
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.local_shipping_outlined,
                        title: 'Orders',
                        onTap: () {
                          zoomDrawerController.close?.call();
                          Get.to(() => const CartView());
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifications',
                        onTap: () {
                          zoomDrawerController.close?.call();
                          controller.changeIndex(2); // Notifications tab
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Admin Panel',
                        onTap: () {
                          zoomDrawerController.close?.call();
                          Get.to(() => const AdminDashboardView());
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.business_outlined,
                        title: 'Edit Companies',
                        onTap: () {
                          zoomDrawerController.close?.call();
                          Get.to(() => const EditCompaniesView());
                        },
                      ),

                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 16),

                      // Sign Out Item
                      _buildMenuItem(
                        icon: Icons.logout_rounded,
                        title: 'Sign Out',
                        onTap: () {
                          zoomDrawerController.close?.call();
                          Get.offAll(() => const SignInView());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white10,
        highlightColor: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 22,
            ),
            const SizedBox(width: 18),
            ResponsiveText(
              title,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
