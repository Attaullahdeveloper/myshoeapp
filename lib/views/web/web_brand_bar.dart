import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import 'web_colors.dart';
import 'web_product_image_helper.dart';

class WebBrandBar extends StatelessWidget {
  final Function(String? companyId, String companyName)? onBrandSelected;

  const WebBrandBar({
    super.key,
    this.onBrandSelected,
  });

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Obx(() {
      final companies = homeController.companies;
      final selectedId = homeController.selectedCompanyId.value;

      return Container(
        height: 60,
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: companies.length + 1, // +1 for "All Brands"
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              final isSelected = selectedId == null || selectedId == 'all';
              return _BrandChip(
                label: 'All Brands',
                isSelected: isSelected,
                onTap: () {
                  homeController.selectCompany(null);
                  onBrandSelected?.call(null, 'All Brands');
                },
              );
            }

            final company = companies[index - 1];
            final cId = company['id']?.toString();
            final cName = company['name']?.toString() ?? 'Brand';
            final cLogo = company['logo_url']?.toString();
            final isSelected = selectedId == cId;

            return _BrandChip(
              label: cName,
              logoUrl: cLogo,
              isSelected: isSelected,
              onTap: () {
                homeController.selectCompany(cId);
                onBrandSelected?.call(cId, cName);
              },
            );
          },
        ),
      );
    });
  }
}

class _BrandChip extends StatefulWidget {
  final String label;
  final String? logoUrl;
  final bool isSelected;
  final VoidCallback onTap;

  const _BrandChip({
    required this.label,
    this.logoUrl,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_BrandChip> createState() => _BrandChipState();
}

class _BrandChipState extends State<_BrandChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: active
                ? WebColors.gold.withOpacity(0.15)
                : (_isHovered
                    ? WebColors.surfaceHover
                    : WebColors.surface),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: active
                  ? WebColors.gold
                  : (_isHovered
                      ? WebColors.border.withOpacity(0.9)
                      : WebColors.border),
              width: active ? 1.5 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: WebColors.gold.withOpacity(0.25),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ]
                : (_isHovered
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : []),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.logoUrl != null && widget.logoUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 26,
                    height: 26,
                    color: Colors.white,
                    padding: const EdgeInsets.all(3),
                    child: WebProductImageHelper(
                      imagePath: widget.logoUrl!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: active
                      ? WebColors.gold
                      : (_isHovered
                          ? WebColors.textMain
                          : WebColors.textMuted),
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
