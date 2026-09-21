import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/cart_controller.dart';
import 'web_colors.dart';

class WebHeader extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onCartTap;
  final VoidCallback onAuthTap;
  final VoidCallback onAdminTap;
  final VoidCallback onFavoritesTap;
  final String activeSection;
  final ValueChanged<String> onSectionSelected;

  const WebHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onCartTap,
    required this.onAuthTap,
    required this.onAdminTap,
    required this.onFavoritesTap,
    required this.activeSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isTablet = width >= 700 && width < 1024;
    final currentUser = Supabase.instance.client.auth.currentUser;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: WebColors.bg.withOpacity(0.82),
            border: const Border(
              bottom: BorderSide(color: WebColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              // ── Brand Logo ───────────────────────────────────────
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => onSectionSelected('all'),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: WebColors.goldGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: WebColors.gold.withOpacity(0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.sports_basketball_rounded,
                            color: Color(0xFF090C10),
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MM AMERICAN',
                            style: TextStyle(
                              color: WebColors.textMain,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'PREMIUM SNEAKERS',
                            style: TextStyle(
                              color: WebColors.gold,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 32),

              // ── Navigation Tabs (Desktop only) ───────────────────
              if (isDesktop) ...[
                _buildNavItem('All Sneakers', 'all'),
                const SizedBox(width: 8),
                _buildNavItem('New Arrivals', 'new'),
                const SizedBox(width: 8),
                _buildNavItem('Best Sellers', 'best'),
                const SizedBox(width: 8),
                _buildNavItem('Special Deals', 'deals'),
                const SizedBox(width: 24),
              ],

              // ── Search Input ─────────────────────────────────────
              Expanded(
                child: Container(
                  height: 44,
                  constraints: const BoxConstraints(maxWidth: 420),
                  decoration: BoxDecoration(
                    color: WebColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: WebColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.search,
                        color: WebColors.textMuted,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: onSearchChanged,
                          style: const TextStyle(
                            color: WebColors.textMain,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Search shoes, brands, styles...',
                            hintStyle: TextStyle(
                              color: WebColors.textDim,
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                          child: const Icon(
                            CupertinoIcons.clear_circled_solid,
                            color: WebColors.textMuted,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // ── Action Buttons (Admin, Fav, Cart, Auth) ───────────
              Row(
                children: [
                  // Admin Quick Access Button
                  Tooltip(
                    message: 'Admin Dashboard',
                    child: _buildHeaderIconButton(
                      icon: CupertinoIcons.slider_horizontal_3,
                      onTap: onAdminTap,
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Favorites Button
                  Tooltip(
                    message: 'Favorites',
                    child: _buildHeaderIconButton(
                      icon: CupertinoIcons.heart,
                      onTap: onFavoritesTap,
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Cart Button with live Badge
                  Obx(() {
                    final count = CartController.to.itemCount;
                    return Tooltip(
                      message: 'Your Bag',
                      child: GestureDetector(
                        onTap: onCartTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: WebColors.goldGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: WebColors.gold.withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.bag_fill,
                                size: 18,
                                color: Color(0xFF090C10),
                              ),
                              if (count > 0) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Color(0xFF090C10),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(width: 12),

                  // Auth / User Button
                  GestureDetector(
                    onTap: onAuthTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: WebColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: WebColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            currentUser != null
                                ? CupertinoIcons.person_crop_circle_fill_badge_checkmark
                                : CupertinoIcons.person_crop_circle,
                            size: 18,
                            color: currentUser != null
                                ? WebColors.emerald
                                : WebColors.textMain,
                          ),
                          if (isDesktop || isTablet) ...[
                            const SizedBox(width: 8),
                            Text(
                              currentUser != null
                                  ? (currentUser.userMetadata?['full_name'] ??
                                      currentUser.email?.split('@')[0] ??
                                      'Account')
                                  : 'Sign In',
                              style: const TextStyle(
                                color: WebColors.textMain,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String title, String sectionKey) {
    final isSelected = activeSection == sectionKey;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onSectionSelected(sectionKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? WebColors.surfaceElevated : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? WebColors.gold.withOpacity(0.5) : Colors.transparent,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? WebColors.gold : WebColors.textMuted,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: WebColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: WebColors.border),
          ),
          child: Center(
            child: Icon(
              icon,
              size: 18,
              color: WebColors.textMain,
            ),
          ),
        ),
      ),
    );
  }
}
