import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../widgets/responsive_text.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import 'signup_view.dart';
import 'recovery_view.dart';

class SignInView extends StatelessWidget {
  const SignInView({super.key});

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
                      'Hello Again!',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onboardingTitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ResponsiveText(
                      "Welcome Back You've Been Missed!",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.onboardingSub,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.05),

              // ── Input Fields ─────────────────────────────────────────────────
              CustomTextField(
                label: 'Email Address',
                hint: 'alissonbecker@gmail.com',
                controller: controller.signInEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              Obx(() => CustomTextField(
                    label: 'Password',
                    hint: '••••••••',
                    controller: controller.signInPassword,
                    isPassword: true,
                    isPasswordVisible: controller.signInPasswordVisible.value,
                    onSuffixIconPressed: controller.toggleSignInPasswordVisibility,
                  )),
              const SizedBox(height: 12),

              // ── Forgot Password / Recovery Link ──────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.to(() => const RecoveryView()),
                  child: ResponsiveText(
                    'Recovery Password',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onboardingSub,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),

              PrimaryButton(
                title: 'Sign In',
                onPressed: controller.login,
                borderRadius: 50,
              ),
              const SizedBox(height: 16),

              CustomOutlineButton(
                title: 'Sign In with Google',
                iconAsset: AppImages.google,
                onPressed: () {
                  Get.snackbar(
                    'Google Login',
                    'Signing in with Google...',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.onboardingBtn.withValues(alpha: 0.8),
                    colorText: Colors.white,
                  );
                },
                borderRadius: 50,
              ),
              SizedBox(height: size.height * 0.12),

              // ── Footer ───────────────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Get.to(() => const SignUpView()),
                  child: RichText(
                    text: TextSpan(
                      text: "Don't Have An Account? ",
                      style: TextStyle(
                        fontFamily: 'Airbnb Cereal App',
                        fontSize: 14,
                        color: AppColors.onboardingSub,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign Up For Free',
                          style: TextStyle(
                            fontFamily: 'Airbnb Cereal App',
                            fontSize: 14,
                            color: AppColors.onboardingTitle,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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
