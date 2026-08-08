import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      Get.snackbar(
        'Required Field',
        'Please enter your email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
      );
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
      );
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
      );
      return false;
    }

    if (password.length < 6) {
      Get.snackbar(
        'Weak Password',
        'Password must be at least 6 characters long',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
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
      Get.snackbar(
        'Required Field',
        'Please enter your name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
      );
      return false;
    }

    if (email.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
      );
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
      );
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter a password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
      );
      return false;
    }

    if (password.length < 6) {
      Get.snackbar(
        'Weak Password',
        'Password must be at least 6 characters long',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  bool validateRecovery() {
    final email = recoveryEmail.text.trim();

    if (email.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
      );
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid email address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE57373),
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  void login() {
    Get.snackbar(
      'Success',
      'Welcome back to MM Shoes!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF81C784),
      colorText: Colors.white,
    );
    Get.offAll(() => const MainZoomDrawer());
  }

  void register() {
    Get.snackbar(
      'Account Created',
      'Your account has been successfully created!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF81C784),
      colorText: Colors.white,
    );
    // Automatically redirect to MainZoomDrawer
    Get.offAll(() => const MainZoomDrawer());
  }

  void recover() {
    Get.dialog(
      AlertDialog(
        title: const Text('Check Your Email'),
        content: const Text('A password recovery link has been sent to your email. Please check your inbox.'),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // close dialog
              Get.back(); // go back to sign in screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
