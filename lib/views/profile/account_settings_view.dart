import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import '../../widgets/responsive_text.dart';

class AccountSettingsView extends StatefulWidget {
  const AccountSettingsView({super.key});

  @override
  State<AccountSettingsView> createState() => _AccountSettingsViewState();
}

class _AccountSettingsViewState extends State<AccountSettingsView> {
  bool _enableFaceId = false;
  bool _enablePushNotifications = true;
  bool _enableLocationServices = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.onboardingBg, // #F9F9F9 Light theme background
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── TOP HEADER ROW ────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Row(
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
                    Expanded(
                      child: Center(
                        child: ResponsiveText(
                          'Account & Settings',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onboardingTitle,
                          usePlayfair: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44), // Spacer for header symmetry
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── SECTION 1: ACCOUNT ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      'Account',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onboardingTitle,
                    ),
                    const SizedBox(height: 16),
                    _buildAccountTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notification Setting',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildAccountTile(
                      icon: Icons.shopping_cart_outlined,
                      title: 'Shipping Address',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildAccountTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'Payment Info',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildAccountTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'Delete Account',
                      onTap: () {},
                    ),
                    _buildDivider(),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── SECTION 2: APP SETTINGS ─────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      'App Settings',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onboardingTitle,
                    ),
                    const SizedBox(height: 16),
                    _buildSwitchTile(
                      title: 'Eneble Face ID For Log In',
                      value: _enableFaceId,
                      onChanged: (val) => setState(() => _enableFaceId = val),
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      title: 'Eneble Push Notifications',
                      value: _enablePushNotifications,
                      onChanged: (val) => setState(() => _enablePushNotifications = val),
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      title: 'Eneble Location Services',
                      value: _enableLocationServices,
                      onChanged: (val) => setState(() => _enableLocationServices = val),
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      title: 'Dark Mode',
                      value: _darkMode,
                      onChanged: (val) => setState(() => _darkMode = val),
                    ),
                    _buildDivider(),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey.shade600,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ResponsiveText(
                title,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.onboardingTitle,
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade400,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ResponsiveText(
            title,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.onboardingTitle,
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.onboardingBtn,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade200,
    );
  }
}
