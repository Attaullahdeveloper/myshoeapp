import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/google_auth_service.dart';
import '../../utils/app_toast.dart';
import 'web_colors.dart';

class WebAuthModal extends StatefulWidget {
  final VoidCallback onClose;
  final VoidCallback onAuthSuccess;

  const WebAuthModal({
    super.key,
    required this.onClose,
    required this.onAuthSuccess,
  });

  @override
  State<WebAuthModal> createState() => _WebAuthModalState();
}

class _WebAuthModalState extends State<WebAuthModal> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final res = await GoogleAuthService.continueWithGoogle();
      if (mounted) {
        setState(() => _isGoogleLoading = false);
        AppToast.showSuccess(
          title: 'Google Sign-In',
          message: 'Connecting via Google...',
        );
        widget.onAuthSuccess();
        widget.onClose();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
        AppToast.showError(
          title: 'Google Sign-In Failed',
          message: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppToast.showWarning(
        title: 'Missing Fields',
        message: 'Please enter both email and password.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      if (_isSignUp) {
        final name = _nameController.text.trim();
        await supabase.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': name.isNotEmpty ? name : email.split('@')[0]},
        );
        AppToast.showSuccess(
          title: 'Account Created',
          message: 'Welcome to MM American Shoes!',
        );
      } else {
        await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
        AppToast.showSuccess(
          title: 'Welcome Back!',
          message: 'Signed in successfully.',
        );
      }

      widget.onAuthSuccess();
      widget.onClose();
    } catch (e) {
      AppToast.showError(
        title: 'Authentication Failed',
        message: e.toString().replaceFirst('AuthException: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    await GoogleAuthService.signOut();
    if (mounted) {
      setState(() {});
      AppToast.showInfo(
        title: 'Signed Out',
        message: 'You have been logged out.',
      );
      widget.onAuthSuccess();
      widget.onClose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final size = MediaQuery.of(context).size;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: size.width > 480 ? 460.0 : size.width * 0.92,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: WebColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: WebColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.7),
                blurRadius: 40,
                offset: const Offset(0, 16),
              ),
              BoxShadow(
                color: WebColors.gold.withOpacity(0.12),
                blurRadius: 30,
              ),
            ],
          ),
          child: currentUser != null
              ? _buildProfileView(currentUser)
              : _buildAuthForm(),
        ),
      ),
    );
  }

  Widget _buildProfileView(User user) {
    final name = user.userMetadata?['full_name'] ??
        user.userMetadata?['name'] ??
        user.email?.split('@')[0] ??
        'Sneakerhead';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MY ACCOUNT',
              style: TextStyle(
                color: WebColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            GestureDetector(
              onTap: widget.onClose,
              child: const Icon(CupertinoIcons.xmark, color: WebColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: WebColors.goldGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Color(0xFF090C10),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(
            color: WebColors.textMain,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? '',
          style: const TextStyle(
            color: WebColors.textMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _handleSignOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: WebColors.surfaceElevated,
              foregroundColor: WebColors.red,
              side: const BorderSide(color: WebColors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'SIGN OUT',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isSignUp ? 'CREATE ACCOUNT' : 'WELCOME BACK',
              style: const TextStyle(
                color: WebColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            GestureDetector(
              onTap: widget.onClose,
              child: const Icon(CupertinoIcons.xmark, color: WebColors.textMuted),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Google Sign-In Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: (_isLoading || _isGoogleLoading) ? null : _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: WebColors.border),
              backgroundColor: WebColors.surfaceElevated,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isGoogleLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(WebColors.gold),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.g_mobiledata_rounded, color: Colors.white, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Continue with Google',
                        style: TextStyle(
                          color: WebColors.textMain,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 20),

        // Divider
        Row(
          children: [
            const Expanded(child: Divider(color: WebColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'OR WITH EMAIL',
                style: TextStyle(color: WebColors.textDim, fontSize: 11),
              ),
            ),
            const Expanded(child: Divider(color: WebColors.border)),
          ],
        ),

        const SizedBox(height: 20),

        if (_isSignUp) ...[
          _buildInput(controller: _nameController, hint: 'Full Name'),
          const SizedBox(height: 12),
        ],

        _buildInput(
          controller: _emailController,
          hint: 'Email Address',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),

        _buildInput(
          controller: _passwordController,
          hint: 'Password',
          obscureText: true,
        ),

        const SizedBox(height: 24),

        // Email Submit Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: (_isLoading || _isGoogleLoading) ? null : _handleEmailAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: WebColors.gold,
              foregroundColor: const Color(0xFF090C10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF090C10)),
                    ),
                  )
                : Text(
                    _isSignUp ? 'SIGN UP' : 'SIGN IN',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 18),

        // Toggle Sign In / Sign Up
        Center(
          child: GestureDetector(
            onTap: () => setState(() => _isSignUp = !_isSignUp),
            child: Text(
              _isSignUp
                  ? 'Already have an account? Sign In'
                  : "Don't have an account? Create one",
              style: const TextStyle(
                color: WebColors.gold,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: WebColors.textMain, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: WebColors.textDim, fontSize: 13),
        filled: true,
        fillColor: WebColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WebColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WebColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: WebColors.gold),
        ),
      ),
    );
  }
}
