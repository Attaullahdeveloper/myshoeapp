import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/cart_controller.dart';
import 'controllers/home_controller.dart';
import 'utils/app_colors.dart';
import 'views/admin/add_edit_product_view.dart';
import 'views/admin/admin_dashboard_view.dart';
import 'views/admin/edit_products_view.dart';
import 'views/companies/edit_companies_view.dart';
import 'views/home/main_zoom_drawer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with user credentials & connection check
  try {
    await Supabase.initialize(
      url: 'https://awezbignzaeizkuhubqh.supabase.co',
      anonKey: 'sb_publishable_bx0QHbEqp1ds-QhSJ6dXzA_kyqLgFhW', // ignore: deprecated_member_use
    );
    debugPrint('====================================================');
    debugPrint('✅ SUPABASE CONNECTED SUCCESSFULLY TO MYSHOEAPP!');
    debugPrint('URL: https://awezbignzaeizkuhubqh.supabase.co');
    debugPrint('====================================================');
  } catch (e) {
    debugPrint('❌ SUPABASE CONNECTION FAILED: $e');
  }

  // Initialize global controllers
  Get.put(CartController(), permanent: true);
  Get.lazyPut(() => HomeController(), fenix: true);

  // Force portrait orientation for the app
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyShoeApp());
}

class MyShoeApp extends StatelessWidget {
  const MyShoeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MM American Shoes',
      debugShowCheckedModeBanner: false,

      // ── Theme ───────────────────────────────────────────
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: AppColors.black,
          onSecondary: AppColors.black,
          onSurface: AppColors.textPrimary,
        ),
      ),

      // ── Navigation & Registered Routes ──────────────────
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const MainZoomDrawer()),
        GetPage(name: '/AddEditProductView', page: () => const AddEditProductView()),
        GetPage(name: '/EditProductsView', page: () => const EditProductsView()),
        GetPage(name: '/AdminDashboardView', page: () => const AdminDashboardView()),
        GetPage(name: '/EditCompaniesView', page: () => const EditCompaniesView()),
      ],

      // ── Default Page Transition ─────────────────────────
      defaultTransition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}
