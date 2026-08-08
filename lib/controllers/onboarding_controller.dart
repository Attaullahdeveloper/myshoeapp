import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/auth/signin_view.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final RxBool isLoading = false.obs;

  bool get isLastPage => currentPage.value == 2;

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (isLastPage) {
      completeOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutQuart,
      );
    }
  }

  void skip() {
    completeOnboarding();
  }

  void completeOnboarding() {
    Get.offAll(
      () => const SignInView(),
      transition: Transition.rightToLeftWithFade,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
