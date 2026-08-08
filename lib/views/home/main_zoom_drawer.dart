import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import '../../widgets/side_menu_view.dart';
import 'home_view.dart';

class MainZoomDrawer extends StatefulWidget {
  const MainZoomDrawer({super.key});

  @override
  State<MainZoomDrawer> createState() => _MainZoomDrawerState();
}

class _MainZoomDrawerState extends State<MainZoomDrawer> {
  final ZoomDrawerController _zoomDrawerController = ZoomDrawerController();

  @override
  Widget build(BuildContext context) {
    return ZoomDrawer(
      controller: _zoomDrawerController,
      menuScreen: SideMenuView(zoomDrawerController: _zoomDrawerController),
      mainScreen: HomeView(zoomDrawerController: _zoomDrawerController),
      borderRadius: 24.0,
      showShadow: false,
      angle: -12.0,
      drawerShadowsBackgroundColor: const Color(0xFFE0E0E0),
      slideWidth: MediaQuery.of(context).size.width * 0.65,
      menuBackgroundColor: const Color(0xFF1A2530),
    );
  }
}
