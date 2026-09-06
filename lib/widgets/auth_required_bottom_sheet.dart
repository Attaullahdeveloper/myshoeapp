import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_colors.dart';
import '../utils/app_images.dart';
import '../utils/app_toast.dart';
import '../views/auth/signin_view.dart';
import '../views/auth/signup_view.dart';

class AuthRequiredBottomSheet extends StatefulWidget {
  final double? orderTotal;
  final String? initialEmail;
  final VoidCallback? onAuthSuccess;

  const AuthRequiredBottomSheet({
    super.key,
    this.orderTotal,
    this.initialEmail,
    this.onAuthSuccess,
  });

  /// Animated Show Method
  static Future<bool?> show(
    BuildContext context, {
    double? orderTotal,
    String? initialEmail,
    VoidCallback? onAuthSuccess,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (ctx) => AuthRequiredBottomSheet(
        orderTotal: orderTotal,
        initialEmail: initialEmail,
        onAuthSuccess: onAuthSuccess,
      ),
    );
  }

  @override
  State<AuthRequiredBottomSheet> createState() =>
      _AuthRequiredBottomSheetState();
}

class _AuthRequiredBottomSheetState extends State<AuthRequiredBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _badgeController;
  late Animation<double> _badgeScaleAnimation;

  @override
  void initState() {
    super.initState();
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _badgeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.4, end: 1.12)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.12, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(_badgeController);

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _badgeController.forward();
    });
  }

  @override
  void dispose() {
    _badgeController.dispose();
    super.dispose();
  }

  void _handleGoogleSignIn() async {
    HapticFeedback.lightImpact();
    try {
      await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.google);
      if (mounted) {
        Navigator.pop(context, true);
        widget.onAuthSuccess?.call();
      }
    } catch (_) {
      if (mounted) {
        AppToast.showInfo(
          context: context,
          title: 'Google Sign In',
          message: 'Redirecting to Google authentication...',
        );
      }
    }
  }

  void _handleSignIn() {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignInView(
          initialEmail: widget.initialEmail,
          isFromCheckout: true,
        ),
      ),
    ).then((_) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        widget.onAuthSuccess?.call();
      }
    });
  }

  void _handleSignUp() {
    HapticFeedback.lightImpact();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SignUpView(
          initialEmail: widget.initialEmail,
          isFromCheckout: true,
        ),
      ),
    ).then((_) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        widget.onAuthSuccess?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final formattedPrice = widget.orderTotal != null
        ? '\$${widget.orderTotal!.toStringAsFixed(2)} '
        : '';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(22, 12, 22, bottomPadding + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top Grab Indicator ──
          Center(
            child: Container(
              width: 42,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // ── Close 'X' Button ──
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.pop(context, false),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 22,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ),
          ),

          // ── Blue Lock Badge with Entrance Bounce Animation ──
          ScaleTransition(
            scale: _badgeScaleAnimation,
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.lock_rounded,
                  color: Color(0xFF3B82F6),
                  size: 28,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Title ──
          const Text(
            'Sign In to Complete Order',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Airbnb Cereal App',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.2,
            ),
          ),

          const SizedBox(height: 8),

          // ── Subtitle ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text(
              'Please sign in or create an account to securely finalize your ${formattedPrice}order and track delivery status.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Airbnb Cereal App',
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                height: 1.45,
                color: Color(0xFF64748B),
              ),
            ),
          ),

          const SizedBox(height: 22),

          // ── Button 1: Continue with Google ──
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _handleGoogleSignIn,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    AppImages.google,
                    width: 20,
                    height: 20,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue with Google',
                    style: TextStyle(
                      fontFamily: 'Airbnb Cereal App',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Divider: OR CONTINUE WITH EMAIL ──
          Row(
            children: [
              const Expanded(
                child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'OR CONTINUE WITH EMAIL',
                  style: TextStyle(
                    fontFamily: 'Airbnb Cereal App',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Button 2: Sign In (Primary Blue) ──
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _handleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.onboardingBtn,
                elevation: 2,
                shadowColor: AppColors.onboardingBtn.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(
                Icons.login_rounded,
                color: Colors.white,
                size: 19,
              ),
              label: const Text(
                'Sign In',
                style: TextStyle(
                  fontFamily: 'Airbnb Cereal App',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Button 3: Create New Account ──
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _handleSignUp,
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF8FAFC),
                side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(
                Icons.person_add_outlined,
                color: Color(0xFF1E293B),
                size: 19,
              ),
              label: const Text(
                'Create New Account',
                style: TextStyle(
                  fontFamily: 'Airbnb Cereal App',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ── Bottom Legal Terms (No guest option added as requested) ──
          const Text(
            'By continuing, you agree to our Terms of Service & Privacy Policy.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Airbnb Cereal App',
              fontSize: 11.5,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
