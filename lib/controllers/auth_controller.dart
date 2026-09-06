import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_toast.dart';
import '../views/home/main_zoom_drawer.dart';

class AuthController extends GetxController {
  // Sign In controllers
  final signInEmail = TextEditingController();
  final signInPassword = TextEditingController();
  final signInPasswordVisible = false.obs;

  // Sign Up controllers
  final signUpName = TextEditingController();
  final signUpEmail = TextEditingController();
  final signUpPassword = TextEditingController();
  final signUpPasswordVisible = false.obs;

  // Recovery Password controllers
  final recoveryEmail = TextEditingController();

  final RxBool isLoading = false.obs;

  void toggleSignInPasswordVisibility() {
    signInPasswordVisible.value = !signInPasswordVisible.value;
  }

  void toggleSignUpPasswordVisibility() {
    signUpPasswordVisible.value = !signUpPasswordVisible.value;
  }

  bool validateSignIn() {
    final email = signInEmail.text.trim();
    final password = signInPassword.text;

    if (email.isEmpty) {
      AppToast.showError(
        title: 'Required Field',
        message: 'Please enter your email address',
      );
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      AppToast.showError(
        title: 'Invalid Email',
        message: 'Please enter a valid email address',
      );
      return false;
    }

    if (password.isEmpty) {
      AppToast.showError(
        title: 'Required Field',
        message: 'Please enter your password',
      );
      return false;
    }

    if (password.length < 6) {
      AppToast.showError(
        title: 'Weak Password',
        message: 'Password must be at least 6 characters long',
      );
      return false;
    }

    return true;
  }

  bool validateSignUp() {
    final name = signUpName.text.trim();
    final email = signUpEmail.text.trim();
    final password = signUpPassword.text;

    if (name.isEmpty) {
      AppToast.showError(
        title: 'Required Field',
        message: 'Please enter your full name',
      );
      return false;
    }

    if (email.isEmpty) {
      AppToast.showError(
        title: 'Required Field',
        message: 'Please enter your email address',
      );
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      AppToast.showError(
        title: 'Invalid Email',
        message: 'Please enter a valid email address',
      );
      return false;
    }

    if (password.isEmpty) {
      AppToast.showError(
        title: 'Required Field',
        message: 'Please enter a password',
      );
      return false;
    }

    if (password.length < 6) {
      AppToast.showError(
        title: 'Weak Password',
        message: 'Password must be at least 6 characters long',
      );
      return false;
    }

    return true;
  }

  bool validateRecovery() {
    final email = recoveryEmail.text.trim();

    if (email.isEmpty) {
      AppToast.showError(
        title: 'Required Field',
        message: 'Please enter your email address',
      );
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      AppToast.showError(
        title: 'Invalid Email',
        message: 'Please enter a valid email address',
      );
      return false;
    }

    return true;
  }

  Future<void> login({bool isFromCheckout = false}) async {
    if (!validateSignIn()) return;

    isLoading.value = true;
    try {
      final email = signInEmail.text.trim();
      final password = signInPassword.text;
      
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      isLoading.value = false;
      if (res.user != null) {
        AppToast.showSuccess(
          title: 'Welcome Back!',
          message: 'Signed in successfully!',
        );
        if (isFromCheckout) {
          Get.back();
        } else {
          Get.offAll(() => const MainZoomDrawer());
        }
      }
    } catch (e) {
      isLoading.value = false;
      AppToast.showError(
        title: 'Sign In Failed',
        message: e.toString().replaceFirst('AuthException: ', ''),
      );
    }
  }

  Future<void> register({bool isFromCheckout = false}) async {
    if (!validateSignUp()) return;

    isLoading.value = true;
    try {
      final name = signUpName.text.trim();
      final email = signUpEmail.text.trim();
      final password = signUpPassword.text;

      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      isLoading.value = false;
      if (res.user != null) {
        AppToast.showSuccess(
          title: 'Account Created',
          message: 'Welcome to MM Shoes, $name!',
        );
        if (isFromCheckout) {
          Get.back();
        } else {
          Get.offAll(() => const MainZoomDrawer());
        }
      }
    } catch (e) {
      isLoading.value = false;
      AppToast.showError(
        title: 'Registration Failed',
        message: e.toString().replaceFirst('AuthException: ', ''),
      );
    }
  }

  Future<void> recover() async {
    if (!validateRecovery()) return;
    try {
      final email = recoveryEmail.text.trim();
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      AppToast.showSuccess(
        title: 'Recovery Email Sent',
        message: 'Password reset link sent to $email. Please check your inbox.',
      );
      Get.back();
    } catch (e) {
      AppToast.showError(
        title: 'Password Reset Failed',
        message: e.toString().replaceFirst('AuthException: ', ''),
      );
    }
  }

  @override
  void onClose() {
    signInEmail.dispose();
    signInPassword.dispose();
    signUpName.dispose();
    signUpEmail.dispose();
    signUpPassword.dispose();
    recoveryEmail.dispose();
    super.onClose();
  }
}
