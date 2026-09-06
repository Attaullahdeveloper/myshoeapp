import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_images.dart';
import '../../utils/app_toast.dart';
import '../../widgets/responsive_text.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../home/main_zoom_drawer.dart';
import 'signup_view.dart';
import 'recovery_view.dart';

typedef LoginView = SignInView;

class SignInView extends StatefulWidget {
  final String? initialEmail;
  final bool isFromCheckout;

  const SignInView({
    super.key,
    this.initialEmail,
    this.isFromCheckout = false,
  });

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

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
        message: 'Please enter your password',
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
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (res.user != null) {
        if (mounted) {
          AppToast.showSuccess(
            context: context,
            title: 'Welcome Back!',
            message: 'Signed in successfully!',
          );
        }

        if (widget.isFromCheckout) {
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
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
          title: 'Sign In Failed',
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
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 12),

              // ── Forgot Password / Recovery Link ──────────────────────────────
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecoveryView()),
                  ),
                  child: const ResponsiveText(
                    'Recovery Password',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onboardingSub,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),

              PrimaryButton(
                title: _isLoading ? 'Signing In...' : 'Sign In',
                onPressed: _isLoading ? () {} : _handleSignIn,
                borderRadius: 50,
              ),
              const SizedBox(height: 16),

              CustomOutlineButton(
                title: 'Sign In with Google',
                iconAsset: AppImages.google,
                onPressed: () {
                  AppToast.showInfo(
                    context: context,
                    title: 'Google Login',
                    message: 'Signing in with Google...',
                  );
                },
                borderRadius: 50,
              ),
              SizedBox(height: size.height * 0.12),

              // ── Footer ───────────────────────────────────────────────────────
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SignUpView(
                          initialEmail: _emailController.text.trim(),
                          isFromCheckout: widget.isFromCheckout,
                        ),
                      ),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
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
