import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../widgets/responsive_text.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

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
              SizedBox(height: size.height * 0.03),

              // ── Header Text ──────────────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    ResponsiveText(
                      'Create Account',
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.onboardingTitle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ResponsiveText(
                      "Let's Create Account Together",
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.onboardingSub,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height * 0.04),

              // ── Input Fields ─────────────────────────────────────────────────
              CustomTextField(
                label: 'Your Name',
                hint: 'Alisson Becker',
                controller: controller.signUpName,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Email Address',
                hint: 'alissonbecker@gmail.com',
                controller: controller.signUpEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              Obx(() => CustomTextField(
                    label: 'Password',
                    hint: '••••••••',
                    controller: controller.signUpPassword,
                    isPassword: true,
                    isPasswordVisible: controller.signUpPasswordVisible.value,
                    onSuffixIconPressed: controller.toggleSignUpPasswordVisibility,
                  )),
              SizedBox(height: size.height * 0.04),

              PrimaryButton(
                title: 'Sign Up',
                onPressed: controller.register,
                borderRadius: 50,
              ),
              const SizedBox(height: 16),

              CustomOutlineButton(
                title: 'Sign Up with Google',
                iconAsset: AppImages.google,
                onPressed: () {
                  Get.snackbar(
                    'Google Login',
                    'Signing up with Google...',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.onboardingBtn.withValues(alpha: 0.8),
                    colorText: Colors.white,
                  );
                },
                borderRadius: 50,
              ),
              SizedBox(height: size.height * 0.055),

              // ── Footer ───────────────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Get.back(), // Returns to SignInView
                  child: RichText(
                    text: TextSpan(
                      text: "Already Have An Account? ",
                      style: TextStyle(
                        fontFamily: 'Airbnb Cereal App',
                        fontSize: 14,
                        color: AppColors.onboardingSub,
                        fontWeight: FontWeight.w400,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign In',
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
