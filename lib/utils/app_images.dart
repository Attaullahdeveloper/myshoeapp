class AppImages {
  // Private constructor to prevent instantiation
  AppImages._();

  // Base path for images
  static const String _basePath = 'assets/images/';

  // Splash
  static const String splashBg = '${_basePath}splash_bg.png';
  static const String boot = '${_basePath}boot.png';

  // Onboarding / Welcome
  static const String onboarding1 = '${_basePath}onboarding1.png';
  static const String onboarding2 = '${_basePath}onboarding2.png';
  static const String onboarding3 = '${_basePath}onboarding3.png';
  static const String ellipse = '${_basePath}ellipse.png';
  static const String onboardingDots = '${_basePath}onboarding_dots.png';
  static const String bottomBar = '${_basePath}bottom_bar.png';

  // Empty States
  static const String emptyCart = '${_basePath}empty_cart.png';
  static const String emptyFavorite = '${_basePath}empty_favorite.png';

  // Products (to be populated when images are uploaded)
  // static const String shoeNike1 = '${_basePath}shoe_nike_1.png';
  // static const String shoeAdidas1 = '${_basePath}shoe_adidas_1.png';

  // Brands
  // static const String brandNike = '${_basePath}brand_nike.png';
  // static const String brandAdidas = '${_basePath}brand_adidas.png';

  // Icons
  static const String _iconsPath = 'assets/icons/';
  static const String eyeSlashed = '${_iconsPath}eye_slashed.png';
  static const String google = '${_iconsPath}google.png';
  static const String backArrow = '${_iconsPath}back_arrow.png';
  static const String deleteTrash = '${_iconsPath}delete_trash.png';
  static const String checkoutEmail = '${_iconsPath}checkout_email.png';
  static const String checkoutPhone = '${_iconsPath}checkout_phone.png';
  static const String checkoutEdit = '${_iconsPath}checkout_edit.png';

  // Checkout Success
  static const String confettiPopper = '${_basePath}confetti_popper.png';
}
