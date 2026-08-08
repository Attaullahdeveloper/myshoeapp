import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../widgets/responsive_text.dart';
import '../../widgets/custom_textfield.dart';

class RecoveryView extends StatelessWidget {
  const RecoveryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.onboardingBg, // Same background as onboarding (#F9F9F9)
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.07),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // ── Back Button ──────────────────────────────────────────────────
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      AppImages.backArrow,
                      width: 36,
                      height: 36,
                    ),
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.05),

              // ── Header Text ──────────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    ResponsiveText(
                      'Recovery Password',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onboardingTitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ResponsiveText(
                      "Please Enter Your Email Address To Receive A Verification Code",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.onboardingSub,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.06),

              // ── Input Fields ─────────────────────────────────────────────────
              CustomTextField(
                label: 'Email Address',
                hint: 'alissonbecker@gmail.com',
                controller: controller.recoveryEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: size.height * 0.05),

              // ── Continue Button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: controller.recover,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.onboardingBtn,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const ResponsiveText(
                    'Continue',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
