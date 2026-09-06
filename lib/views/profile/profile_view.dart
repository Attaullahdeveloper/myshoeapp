import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_toast.dart';
import '../../widgets/app_shimmer.dart';
import '../../widgets/responsive_text.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController(text: '••••••••');

  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final name = user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? user.email?.split('@').first ?? 'Alisson Becker';
      _nameController.text = name.toString();
      _emailController.text = user.email ?? 'alissonbecker@gmail.com';
    } else {
      _nameController.text = 'Alisson Becker';
      _emailController.text = 'alissonbecker@gmail.com';
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

              // ── TOP HEADER ROW (Back Button <, Title "Profile", Edit Pencil Icon) ────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Row(
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

                    // Center Title
                    ResponsiveText(
                      'Profile',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingTitle,
                      usePlayfair: true,
                    ),

                    // Edit Action Icon
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                        if (_isEditing) {
                          AppToast.showInfo(
                            title: 'Editing Mode',
                            message: 'You can now update your details.',
                          );
                        } else {
                          AppToast.showSuccess(
                            title: 'Profile Saved',
                            message: 'Profile details saved successfully.',
                          );
                        }
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _isEditing ? Icons.check_rounded : Icons.edit_outlined,
                            color: AppColors.onboardingBtn,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (_isLoading)
                const ProfileShimmer()
              else ...[
                // ── CENTER USER AVATAR WITH CAMERA BADGE ───────────────────────
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                              image: const DecorationImage(
                                image: AssetImage('assets/images/ellipse.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.onboardingBtn,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ResponsiveText(
                        _nameController.text.isNotEmpty ? _nameController.text : 'User Profile',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onboardingTitle,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // ── FORM INPUT CARDS MATCHING MOCKUP 2 ─────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // 1. Full Name
                    ResponsiveText(
                      'Full Name',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingTitle,
                    ),
                    const SizedBox(height: 10),
                    _buildInputCard(_nameController, false),

                    const SizedBox(height: 20),

                    // 2. Email Address
                    ResponsiveText(
                      'Email Address',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingTitle,
                    ),
                    const SizedBox(height: 10),
                    _buildInputCard(_emailController, false),

                    const SizedBox(height: 20),

                    // 3. Password
                    ResponsiveText(
                      'Password',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onboardingTitle,
                    ),
                    const SizedBox(height: 10),
                    _buildInputCard(_passwordController, true),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(TextEditingController controller, bool isObscured) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        obscureText: isObscured,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          color: AppColors.onboardingTitle,
        ),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
