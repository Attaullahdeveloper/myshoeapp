import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../utils/app_toast.dart';
import '../../widgets/responsive_text.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../home/main_zoom_drawer.dart';

class SignUpView extends StatefulWidget {
  final String? initialEmail;
  final bool isFromCheckout;

  const SignUpView({
    super.key,
    this.initialEmail,
    this.isFromCheckout = false,
  });

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _emailController;
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      AppToast.showError(
        context: context,
        title: 'Required Field',
        message: 'Please enter your full name',
      );
      return;
    }

    if (email.isEmpty) {
      AppToast.showError(
        context: context,
        title: 'Required Field',
        message: 'Please enter your email address',
      );
      return;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    );
    if (!emailRegex.hasMatch(email)) {
      AppToast.showError(
        context: context,
        title: 'Invalid Email',
        message: 'Please enter a valid email address (e.g. user@gmail.com)',
      );
      return;
    }

    if (password.isEmpty) {
      AppToast.showError(
        context: context,
        title: 'Required Field',
        message: 'Please enter a password',
      );
      return;
    }

    if (password.length < 6) {
      AppToast.showError(
        context: context,
        title: 'Weak Password',
        message: 'Password must be at least 6 characters long',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      if (res.user != null) {
        if (mounted) {
          AppToast.showSuccess(
            context: context,
            title: 'Account Created',
            message: 'Account created successfully!',
          );
        }

        if (widget.isFromCheckout) {
          // Direct return to CheckoutView (popping both SignUpView and SignInView)
          if (mounted) {
            int count = 0;
            Navigator.of(context).popUntil((route) => count++ >= 2 || route.isFirst);
          }
        } else {
          // Direct login navigation to HomeView/Dashboard (Skip SignInView completely)
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainZoomDrawer()),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          context: context,
          title: 'Registration Failed',
          message: e.toString().replaceFirst('AuthException: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                onTap: () => Navigator.pop(context),
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
                controller: _nameController,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Email Address',
                hint: 'alissonbecker@gmail.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Password',
                hint: '••••••••',
                controller: _passwordController,
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                onSuffixIconPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              SizedBox(height: size.height * 0.04),

              PrimaryButton(
                title: _isLoading ? 'Creating Account...' : 'Sign Up',
                onPressed: _isLoading ? () {} : _handleSignUp,
                borderRadius: 50,
              ),
              const SizedBox(height: 16),

              CustomOutlineButton(
                title: 'Sign Up with Google',
                iconAsset: AppImages.google,
                onPressed: () {
                  AppToast.showInfo(
                    context: context,
                    title: 'Google Login',
                    message: 'Signing up with Google...',
                  );
                },
                borderRadius: 50,
              ),
              SizedBox(height: size.height * 0.055),

              // ── Footer ───────────────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context), // Returns to SignInView
                  child: RichText(
                    text: const TextSpan(
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
