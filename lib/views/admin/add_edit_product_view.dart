import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../controllers/company_controller.dart';
import '../../controllers/home_controller.dart';
import '../../models/product.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_toast.dart';
import '../../widgets/animated_switch.dart';
import '../../widgets/app_animated_dropdown.dart';
import '../../widgets/responsive_text.dart';
import '../companies/edit_companies_view.dart';

class AddEditProductView extends StatefulWidget {
  final Product? product;

  const AddEditProductView({super.key, this.product});

  @override
  State<AddEditProductView> createState() => _AddEditProductViewState();
}

class _AddEditProductViewState extends State<AddEditProductView> {
  final HomeController homeController = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put(HomeController());
  final CompanyController companyController = Get.isRegistered<CompanyController>()
      ? Get.find<CompanyController>()
      : Get.put(CompanyController());

  late bool isEditing;
  bool isSaving = false;
  bool showPreviewPanel = false;

  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController purchasePriceController;
  late TextEditingController salePriceController;
  late TextEditingController stockQuantityController;

  late String selectedBrand;
  late String selectedMainImage;
  Uint8List? productImageBytes;
  late List<int> selectedSizes;
  late List<String> selectedColors;
  late List<String> selectedGallery;

  late bool isBestSeller;
  late bool isNewArrival;
  late bool isSpecialOffer;
  late String selectedStatus;
  late bool isAvailable;
  late bool hasDiscount;
  late TextEditingController discountPercentageController;

  final ImagePicker _picker = ImagePicker();

  final List<int> allAvailableSizes = [37, 38, 39, 40, 41, 42, 43, 44, 45];

  final List<Map<String, dynamic>> allAvailableColors = [
    {'name': 'Dark Navy', 'hex': '#1A2530', 'color': const Color(0xFF1A2530)},
    {'name': 'Ocean Blue', 'hex': '#5B9EE1', 'color': const Color(0xFF5B9EE1)},
    {'name': 'Crimson Red', 'hex': '#E74C3C', 'color': const Color(0xFFE74C3C)},
    {'name': 'Vivid Orange', 'hex': '#FF9800', 'color': const Color(0xFFFF9800)},
    {'name': 'Neon Pink', 'hex': '#E91E63', 'color': const Color(0xFFE91E63)},
    {'name': 'Slate Grey', 'hex': '#9E9E9E', 'color': const Color(0xFF9E9E9E)},
    {'name': 'Pure White', 'hex': '#FFFFFF', 'color': Colors.white},
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    isEditing = p != null;

    if (companyController.companies.isEmpty) {
      companyController.fetchCompaniesFromSupabase();
    }

    nameController = TextEditingController(text: (isEditing && p != null) ? p.name : '');
    descController = TextEditingController(
        text: (isEditing && p != null) ? p.description : 'High performance premium shoe with maximum comfort.');

    purchasePriceController = TextEditingController(
        text: (isEditing && p != null && p.stockBatches.isNotEmpty)
            ? p.stockBatches.last.purchasePrice.toStringAsFixed(2)
            : ((isEditing && p != null) ? (p.price * 0.6).toStringAsFixed(2) : '120.00'));

    salePriceController = TextEditingController(
        text: (isEditing && p != null) ? p.price.toStringAsFixed(2) : '210.00');

    stockQuantityController = TextEditingController(
        text: (isEditing && p != null) ? p.totalStock.toString() : '50');

    selectedBrand = (isEditing && p != null) ? p.category : 'Nike';

    selectedMainImage = (isEditing && p != null) ? p.image : '';

    selectedSizes = (isEditing && p != null) ? List.from(p.sizes) : [38, 39, 40, 41, 42];
    selectedColors = (isEditing && p != null) ? List.from(p.colors) : ['#1A2530', '#5B9EE1'];
    selectedGallery = (isEditing && p != null) ? List.from(p.galleryImages) : [];

    if (isEditing && p != null) {
      for (var sz in p.sizes) {
        if (!allAvailableSizes.contains(sz)) {
          allAvailableSizes.add(sz);
        }
      }
      allAvailableSizes.sort();

      for (var hex in p.colors) {
        if (!allAvailableColors.any((c) => c['hex'] == hex)) {
          allAvailableColors.add({
            'name': hex,
            'hex': hex,
            'color': _parseHexColor(hex),
          });
        }
      }
    }

    isBestSeller = (isEditing && p != null) ? p.isBestSeller : false;
    isNewArrival = (isEditing && p != null) ? p.isNewArrival : false;
    isSpecialOffer = (isEditing && p != null) ? (p.isSpecialOffer || p.status.toLowerCase().contains('special')) : false;

    if (isEditing && p != null) {
      selectedStatus = p.status.isNotEmpty
          ? (p.status.toLowerCase().contains('special')
              ? 'Special Offer'
              : (p.status.toLowerCase().contains('best')
                  ? 'Best Seller'
                  : 'New Arrival'))
          : (isSpecialOffer ? 'Special Offer' : (isBestSeller ? 'Best Seller' : 'New Arrival'));
      isAvailable = p.isAvailable;
      hasDiscount = p.hasDiscount;
      discountPercentageController = TextEditingController(
          text: p.discountPercentage > 0 ? p.discountPercentage.toStringAsFixed(0) : '20');
    } else {
      selectedStatus = 'New Arrival';
      isNewArrival = true;
      isAvailable = true;
      hasDiscount = false;
      discountPercentageController = TextEditingController(text: '20');
    }
  }

  Color _parseHexColor(String hex) {
    try {
      String cleanHex = hex.replaceAll('#', '');
      if (cleanHex.length == 6) cleanHex = 'FF$cleanHex';
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return const Color(0xFF5B9EE1);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    purchasePriceController.dispose();
    salePriceController.dispose();
    stockQuantityController.dispose();
    super.dispose();
  }

  int? _getSelectedCompanyId() {
    try {
      if (companyController.companies.isEmpty) return 1;
      final match = companyController.companies.firstWhere(
        (c) => c.name.toLowerCase() == selectedBrand.toLowerCase(),
        orElse: () => companyController.companies.first,
      );
      return int.tryParse(match.id) ?? 1;
    } catch (_) {
      return 1;
    }
  }

  Future<void> _pickAndCropImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      if (pickedFile != null) {
        final Uint8List bytes = await pickedFile.readAsBytes();
        if (!mounted) return;

        setState(() {
          productImageBytes = bytes;
          selectedMainImage = pickedFile.path;
        });
      }
    } catch (e) {
      AppToast.showError(
        title: 'Image Access Error',
        message: 'Could not pick image',
      );
    }
  }

  Future<void> _pickImageFromGallery() async => _pickAndCropImage(ImageSource.gallery);
  Future<void> _pickImageFromCamera() async => _pickAndCropImage(ImageSource.camera);

  Widget _buildImageWidget(
    String path, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (productImageBytes != null && productImageBytes!.isNotEmpty) {
      return Image.memory(
        productImageBytes!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallbackImage(width, height),
      );
    }

    if (path.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: const Color(0xFFF7F8F9),
        child: const Center(
          child: Icon(Icons.add_photo_alternate_outlined,
              color: Color(0xFF5B9EE1), size: 36),
        ),
      );
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallbackImage(width, height),
      );
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallbackImage(width, height),
      );
    }

    if (kIsWeb) {
      return _buildFallbackImage(width, height);
    }

    return Image.file(
      File(path),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _buildFallbackImage(width, height),
    );
  }

  Widget _buildFallbackImage(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF0F4F8),
      child: const Center(
        child: Icon(Icons.image_not_supported_rounded,
            color: Color(0xFF90A4AE), size: 32),
      ),
    );
  }

  Widget _buildLivePreviewCard() {
    final title = nameController.text.trim().isEmpty ? 'Shoe Product Title' : nameController.text.trim();
    final purPrice = double.tryParse(purchasePriceController.text.trim()) ?? 120.0;
    final salePrice = double.tryParse(salePriceController.text.trim()) ?? 210.0;
    final stock = stockQuantityController.text.trim().isEmpty ? '50' : stockQuantityController.text.trim();
    final profit = (salePrice - purPrice).clamp(0.0, 99999.0);
    final profitMargin = salePrice > 0 ? ((profit / salePrice) * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.remove_red_eye_rounded, color: Color(0xFF5B9EE1), size: 18),
                  SizedBox(width: 8),
                  Text('LIVE STORE PREVIEW', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(radius: 3, backgroundColor: Color(0xFF4CAF50)),
                    SizedBox(width: 6),
                    Text('LIVE', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 10, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Wrap(spacing: 6, children: [
                        if (isBestSeller) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFF9800), borderRadius: BorderRadius.circular(8)), child: const Text('BEST SELLER', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900))),
                        if (isNewArrival) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF5B9EE1), borderRadius: BorderRadius.circular(8)), child: const Text('NEW ARRIVAL', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900))),
                      ]),
                      const Icon(Icons.favorite_border_rounded, size: 16, color: Color(0xFF1A2530)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(height: 160, width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12), child: ClipRRect(borderRadius: BorderRadius.circular(14), child: _buildImageWidget(selectedMainImage, fit: BoxFit.cover))),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(selectedBrand.toUpperCase(), style: const TextStyle(color: Color(0xFF5B9EE1), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                      Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF1A2530), fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('\$${salePrice.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF1A2530), fontSize: 18, fontWeight: FontWeight.w900)),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFF1A2530), borderRadius: BorderRadius.circular(10)), child: Text('$stock Pairs', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
                      ]),
                      const SizedBox(height: 10),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF0F4F8), borderRadius: BorderRadius.circular(8)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Cost: \$${purPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Color(0xFF707B81), fontWeight: FontWeight.w600)),
                        Text('Profit: +\$${profit.toStringAsFixed(2)} (${profitMargin.toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 11, color: Color(0xFF4CAF50), fontWeight: FontWeight.w800)),
                      ])),
                      const SizedBox(height: 10),
                      if (selectedColors.isNotEmpty) Row(children: [const Text('Colors: ', style: TextStyle(fontSize: 11, color: Color(0xFF707B81), fontWeight: FontWeight.w600)), Wrap(spacing: 4, children: selectedColors.map((hex) => Container(width: 14, height: 14, decoration: BoxDecoration(color: _parseHexColor(hex), shape: BoxShape.circle, border: Border.all(color: Colors.black26)))).toList())]),
                      const SizedBox(height: 6),
                      if (selectedSizes.isNotEmpty) Text('Sizes: ${selectedSizes.join(', ')}', style: const TextStyle(fontSize: 11, color: Color(0xFF707B81), fontWeight: FontWeight.w500)),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isWideScreen = size.width >= 820;

    return Scaffold(
      backgroundColor: AppColors.onboardingBg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A2530)),
                    ),
                  ),
                  ResponsiveText(isEditing ? 'Edit Shoe Product' : 'Add New Shoe Product', fontSize: 19, fontWeight: FontWeight.w700, color: const Color(0xFF1A2530)),
                  GestureDetector(
                    onTap: () => setState(() => showPreviewPanel = !showPreviewPanel),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: showPreviewPanel ? const Color(0xFF1A2530) : Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]),
                      child: Row(children: [
                        Icon(Icons.remove_red_eye_rounded, size: 16, color: showPreviewPanel ? const Color(0xFF5B9EE1) : const Color(0xFF1A2530)),
                        const SizedBox(width: 6),
                        Text('Preview', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: showPreviewPanel ? Colors.white : const Color(0xFF1A2530))),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: isWideScreen || showPreviewPanel
                    ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(flex: 6, child: _buildFormContent()),
                        const SizedBox(width: 24),
                        Expanded(flex: 5, child: _buildLivePreviewCard()),
                      ])
                    : _buildFormContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('General Information', Icons.info_outline_rounded),
        const SizedBox(height: 12),
        _buildInputLabel('Shoe Title / Name *'),
        const SizedBox(height: 6),
        TextField(
          controller: nameController,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: Color(0xFF1A2530), fontSize: 15, fontWeight: FontWeight.w600),
          decoration: _buildInputDecoration(hintText: 'e.g. Nike Air Jordan Retro High', icon: Icons.shopping_bag_outlined),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildInputLabel('Company / Brand *'),
            GestureDetector(
              onTap: () async {
                await Get.to(() => const EditCompaniesView());
                companyController.fetchCompaniesFromSupabase();
              },
              child: const Row(
                children: [
                  Icon(Icons.add_business_outlined, size: 15, color: Color(0xFF5B9EE1)),
                  SizedBox(width: 4),
                  Text(
                    '+ Add Brand',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5B9EE1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Obx(() {
          final availableCompanies = companyController.companies.isNotEmpty
              ? companyController.companies.map((c) => c.name).toList()
              : ['Nike', 'Puma', 'Adidas', 'Converse', 'UA'];
          if (!availableCompanies.contains(selectedBrand) &&
              availableCompanies.isNotEmpty) {
            selectedBrand = availableCompanies.first;
          }
          return AppAnimatedDropdown<String>(
            label: '',
            hint: 'Select Brand',
            value: selectedBrand,
            items: availableCompanies,
            itemLabel: (brand) => brand,
            prefixIcon: Icons.business_rounded,
            accentColor: const Color(0xFF5B9EE1),
            isRequired: false,
            sheetTitle: 'Select Shoe Brand',
            showSearch: availableCompanies.length > 6,
            onChanged: (val) {
              if (val != null) setState(() => selectedBrand = val);
            },
          );
        }),
        const SizedBox(height: 16),
        _buildInputLabel('Description / Specifications'),
        const SizedBox(height: 6),
        TextField(
          controller: descController,
          onChanged: (_) => setState(() {}),
          maxLines: 2,
          style: const TextStyle(color: Color(0xFF1A2530), fontSize: 14, fontWeight: FontWeight.w500),
          decoration: _buildInputDecoration(hintText: 'Enter shoe description...'),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Pricing & Stock', Icons.attach_money_rounded),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildInputLabel('Purchase Price *'),
            const SizedBox(height: 6),
            TextField(controller: purchasePriceController, onChanged: (_) => setState(() {}), keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Color(0xFF1A2530), fontSize: 15, fontWeight: FontWeight.w700), decoration: _buildInputDecoration(hintText: '120.00', icon: Icons.monetization_on_outlined, iconColor: const Color(0xFFFF9800))),
          ])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildInputLabel('Sale Price *'),
            const SizedBox(height: 6),
            TextField(controller: salePriceController, onChanged: (_) => setState(() {}), keyboardType: const TextInputType.numberWithOptions(decimal: true), style: const TextStyle(color: Color(0xFF1A2530), fontSize: 15, fontWeight: FontWeight.w700), decoration: _buildInputDecoration(hintText: '210.00', icon: Icons.sell_outlined, iconColor: const Color(0xFF5B9EE1))),
          ])),
        ]),
        const SizedBox(height: 16),
        _buildInputLabel('Total Stock / Quantity (Pairs) *'),
        const SizedBox(height: 6),
        TextField(controller: stockQuantityController, onChanged: (_) => setState(() {}), keyboardType: TextInputType.number, style: const TextStyle(color: Color(0xFF1A2530), fontSize: 15, fontWeight: FontWeight.w700), decoration: _buildInputDecoration(hintText: 'e.g. 50', icon: Icons.inventory_2_outlined, iconColor: const Color(0xFF4CAF50))),
        const SizedBox(height: 24),
        _buildSectionHeader('Product Main Image', Icons.image_outlined),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))]),
          child: Column(children: [
            if (selectedMainImage.isNotEmpty || (productImageBytes != null && productImageBytes!.isNotEmpty))
              Stack(children: [
                ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: SizedBox(height: 200, width: double.infinity, child: _buildImageWidget(selectedMainImage, fit: BoxFit.cover))),
                Positioned(top: 10, right: 10, child: GestureDetector(onTap: () => setState(() { selectedMainImage = ''; productImageBytes = null; }), child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: const Icon(Icons.close_rounded, color: Colors.white, size: 18)))),
              ])
            else
              Container(height: 140, width: double.infinity, decoration: const BoxDecoration(color: Color(0xFFF7F8F9), borderRadius: BorderRadius.vertical(top: Radius.circular(20))), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.cloud_upload_outlined, size: 40, color: Color(0xFF5B9EE1)), SizedBox(height: 8), Text('No Image Selected', style: TextStyle(color: Color(0xFF707B81), fontSize: 13, fontWeight: FontWeight.w600))])),
            Padding(padding: const EdgeInsets.all(12), child: Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: _pickImageFromGallery, style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF5B9EE1)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 10)), icon: const Icon(Icons.photo_library_outlined, size: 18, color: Color(0xFF5B9EE1)), label: const Text('Gallery', style: TextStyle(color: Color(0xFF5B9EE1), fontWeight: FontWeight.w700, fontSize: 13)))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: _pickImageFromCamera, style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF1A2530)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 10)), icon: const Icon(Icons.camera_alt_outlined, size: 18, color: Color(0xFF1A2530)), label: const Text('Camera', style: TextStyle(color: Color(0xFF1A2530), fontWeight: FontWeight.w700, fontSize: 13)))),
            ])),
          ]),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Available Variants', Icons.style_outlined),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildInputLabel('Select Sizes (EU)'), GestureDetector(onTap: _showAddCustomSizeDialog, child: const Row(children: [Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF5B9EE1)), SizedBox(width: 4), Text('Custom Size', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5B9EE1)))]))]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: allAvailableSizes.map((sz) {
          final isSelected = selectedSizes.contains(sz);
          return ChoiceChip(label: Text('$sz', style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1A2530), fontWeight: FontWeight.w700)), selected: isSelected, selectedColor: const Color(0xFF5B9EE1), backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isSelected ? const Color(0xFF5B9EE1) : Colors.black12)), onSelected: (selected) => setState(() => selected ? selectedSizes.add(sz) : selectedSizes.remove(sz)));
        }).toList()),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_buildInputLabel('Select Colors'), GestureDetector(onTap: _showAddCustomColorDialog, child: const Row(children: [Icon(Icons.palette_outlined, size: 16, color: Color(0xFF5B9EE1)), SizedBox(width: 4), Text('Custom Color', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF5B9EE1)))]))]),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: allAvailableColors.map((colMap) {
          final hex = colMap['hex'] as String;
          final isSelected = selectedColors.contains(hex);
          return FilterChip(avatar: Container(width: 16, height: 16, decoration: BoxDecoration(color: colMap['color'], shape: BoxShape.circle, border: Border.all(color: Colors.black26, width: 1))), label: Text(colMap['name'], style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1A2530), fontWeight: FontWeight.w700, fontSize: 12)), selected: isSelected, selectedColor: const Color(0xFF1A2530), backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: isSelected ? const Color(0xFF1A2530) : Colors.black12)), onSelected: (selected) => setState(() => selected ? selectedColors.add(hex) : selectedColors.remove(hex)));
        }).toList()),
        const SizedBox(height: 24),
        _buildSectionHeader('Category Placement & Status', Icons.verified_outlined),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppAnimatedDropdown<String>(
                label: 'Featured Badge / Store Placement',
                hint: 'Select Placement',
                value: isBestSeller
                    ? 'Best Seller'
                    : (isSpecialOffer
                        ? 'Special Deal'
                        : (isNewArrival ? 'New Arrival' : 'Standard Product')),
                items: const [
                  'Standard Product',
                  'Best Seller',
                  'New Arrival',
                  'Special Deal',
                ],
                itemLabel: (item) => item,
                prefixIcon: Icons.stars_rounded,
                accentColor: const Color(0xFF5B9EE1),
                onChanged: (val) {
                  setState(() {
                    isBestSeller = val == 'Best Seller';
                    isNewArrival = val == 'New Arrival';
                    isSpecialOffer = val == 'Special Deal';
                  });
                },
              ),
              const SizedBox(height: 16),
              AppAnimatedDropdown<String>(
                label: 'Stock Availability Status',
                hint: 'Select Availability',
                value: isAvailable
                    ? 'In Stock (Available in Store)'
                    : 'Out of Stock (Hidden)',
                items: const [
                  'In Stock (Available in Store)',
                  'Out of Stock (Hidden)',
                ],
                itemLabel: (item) => item,
                prefixIcon: isAvailable
                    ? Icons.check_circle_outline_rounded
                    : Icons.remove_circle_outline_rounded,
                accentColor: isAvailable
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                onChanged: (val) {
                  setState(() {
                    isAvailable = val == 'In Stock (Available in Store)';
                  });
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        _buildSectionHeader('Universal Discount System', Icons.local_offer_outlined),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Apply Discount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A2530))),
                        SizedBox(height: 2),
                        Text('Applies percentage discount price tag across all categories', style: TextStyle(fontSize: 11, color: Color(0xFF707B81))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitch(
                    value: hasDiscount,
                    activeColor: const Color(0xFF5B9EE1),
                    onChanged: (val) => setState(() => hasDiscount = val),
                  ),
                ],
              ),
              if (hasDiscount) ...[
                const SizedBox(height: 16),
                _buildInputLabel('Discount Percentage (%)'),
                const SizedBox(height: 6),
                TextField(
                  controller: discountPercentageController,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: Color(0xFF1A2530), fontSize: 15, fontWeight: FontWeight.w700),
                  decoration: _buildInputDecoration(hintText: 'e.g. 20', icon: Icons.percent_rounded, iconColor: const Color(0xFFE74C3C)),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF81C784)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Calculated Final Price:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF2E7D32)),
                      ),
                      Text(
                        '\$${_calculateFinalPrice().toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 32),
        SizedBox(width: double.infinity, height: 54, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B9EE1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 4), onPressed: isSaving ? null : _saveProduct, child: isSaving ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)), SizedBox(width: 12), Text('Uploading & Saving to Supabase...', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))]) : Text(isEditing ? 'Save Product Changes' : 'Create Shoe Product', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)))),
        const SizedBox(height: 32),
      ],
    );
  }

  double _calculateFinalPrice() {
    final double sPrice = double.tryParse(salePriceController.text.trim()) ?? 0.0;
    final double dPct = double.tryParse(discountPercentageController.text.trim()) ?? 0.0;
    if (!hasDiscount || dPct <= 0 || sPrice <= 0) {
      return sPrice;
    }
    final double discounted = sPrice - (sPrice * (dPct / 100.0));
    return discounted > 0 ? discounted : 0.0;
  }

  void _showAddCustomSizeDialog() {
    final sizeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Custom Shoe Size', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A2530))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInputLabel('Shoe Size (EU)'),
              const SizedBox(height: 6),
              TextField(
                controller: sizeCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A2530)),
                decoration: _buildInputDecoration(hintText: 'e.g. 46', icon: Icons.straighten_rounded),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Color(0xFF707B81)))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B9EE1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                final newSize = int.tryParse(sizeCtrl.text.trim());
                if (newSize != null && newSize > 0) {
                  setState(() {
                    if (!allAvailableSizes.contains(newSize)) {
                      allAvailableSizes.add(newSize);
                      allAvailableSizes.sort();
                    }
                    if (!selectedSizes.contains(newSize)) {
                      selectedSizes.add(newSize);
                    }
                  });
                  Get.back();
                }
              },
              child: const Text('Add Size', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  void _showAddCustomColorDialog() {
    final nameCtrl = TextEditingController();
    final hexCtrl = TextEditingController(text: '#');
    Color selectedColorVal = const Color(0xFF9C27B0);
    final List<Color> presetPalette = [const Color(0xFF9C27B0), const Color(0xFF009688), const Color(0xFF795548), const Color(0xFF607D8B), const Color(0xFFFFEB3B), const Color(0xFF8BC34A), const Color(0xFF00BCD4), const Color(0xFF673AB7), const Color(0xFF000000)];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Add Custom Color Option', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A2530))),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputLabel('Color Name'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A2530)),
                      decoration: _buildInputDecoration(hintText: 'e.g. Purple Mint', icon: Icons.palette_outlined),
                    ),
                    const SizedBox(height: 12),
                    _buildInputLabel('HEX Code'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: hexCtrl,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A2530)),
                      decoration: _buildInputDecoration(hintText: '#9C27B0', icon: Icons.tag_rounded),
                      onChanged: (val) {
                        if (val.startsWith('#') && val.length == 7) {
                          try {
                            final c = Color(int.parse(val.substring(1), radix: 16) + 0xFF000000);
                            setDialogState(() => selectedColorVal = c);
                          } catch (_) {}
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    const Text('Quick Palette:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF707B81))),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: presetPalette.map((col) {
                        final hexString =
                            '#${col.red.toRadixString(16).padLeft(2, '0')}${col.green.toRadixString(16).padLeft(2, '0')}${col.blue.toRadixString(16).padLeft(2, '0')}'
                                .toUpperCase();
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColorVal = col;
                              hexCtrl.text = hexString;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: col,
                              shape: BoxShape.circle,
                              border: Border.all(color: selectedColorVal == col ? const Color(0xFF5B9EE1) : Colors.black12, width: selectedColorVal == col ? 2.5 : 1),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Get.back(), child: const Text('Cancel', style: TextStyle(color: Color(0xFF707B81)))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B9EE1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    final name = nameCtrl.text.trim().isEmpty ? 'Custom' : nameCtrl.text.trim();
                    var hex = hexCtrl.text.trim();
                    if (!hex.startsWith('#')) hex = '#$hex';
                    if (hex.length >= 4) {
                      setState(() {
                        bool exists = allAvailableColors.any((c) => c['hex'] == hex);
                        if (!exists) {
                          allAvailableColors.add({'name': name, 'hex': hex, 'color': selectedColorVal});
                        }
                        if (!selectedColors.contains(hex)) selectedColors.add(hex);
                      });
                      Get.back();
                    }
                  },
                  child: const Text('Add Color', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<String?> _uploadImageToSupabase(Uint8List imageBytes) async {
    try {
      final String fileName = 'shoe_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecond % 9000))}.png';
      final String filePath = 'shoes/$fileName';
      await Supabase.instance.client.storage.from('products_img').uploadBinary(filePath, imageBytes, fileOptions: const FileOptions(contentType: 'image/png', upsert: true));
      return Supabase.instance.client.storage.from('products_img').getPublicUrl(filePath);
    } catch (e) {
      debugPrint('❌ SUPABASE IMAGE UPLOAD ERROR: $e');
      return null;
    }
  }

  Future<void> _saveProduct() async {
    final name = nameController.text.trim();
    final desc = descController.text.trim();
    final purPrice = double.tryParse(purchasePriceController.text.trim()) ?? 0.0;
    final salePrice = double.tryParse(salePriceController.text.trim()) ?? 0.0;
    final stockQty = int.tryParse(stockQuantityController.text.trim()) ?? 0;

    if (name.isEmpty) {
      HapticFeedback.heavyImpact();
      AppToast.showError(title: 'Required Field Missing', message: 'Please enter shoe title / name');
      return;
    }

    if (desc.isEmpty) {
      HapticFeedback.heavyImpact();
      AppToast.showError(title: 'Required Field Missing', message: 'Please enter shoe description');
      return;
    }

    final int? companyId = _getSelectedCompanyId();
    if (companyId == null || companyId <= 0) {
      HapticFeedback.heavyImpact();
      AppToast.showError(title: 'Required Field Missing', message: 'Please select a valid company / brand');
      return;
    }

    if (purchasePriceController.text.trim().isEmpty || purPrice <= 0) {
      HapticFeedback.heavyImpact();
      AppToast.showError(title: 'Required Field Missing', message: 'Please enter a valid purchase price (> 0)');
      return;
    }

    if (salePriceController.text.trim().isEmpty || salePrice <= 0) {
      HapticFeedback.heavyImpact();
      AppToast.showError(title: 'Required Field Missing', message: 'Please enter a valid sale price (> 0)');
      return;
    }

    if (stockQuantityController.text.trim().isEmpty || stockQty <= 0) {
      HapticFeedback.heavyImpact();
      AppToast.showError(title: 'Required Field Missing', message: 'Please enter a valid stock quantity (> 0)');
      return;
    }

    if (selectedSizes.isEmpty) {
      HapticFeedback.heavyImpact();
      AppToast.showError(title: 'Required Field Missing', message: 'Please select at least one shoe size');
      return;
    }

    if (selectedColors.isEmpty) {
      HapticFeedback.heavyImpact();
      AppToast.showError(title: 'Required Field Missing', message: 'Please select at least one shoe color');
      return;
    }

    final bool hasProductImg = (productImageBytes != null && productImageBytes!.isNotEmpty) ||
        selectedMainImage.startsWith('http://') ||
        selectedMainImage.startsWith('https://');

    if (!hasProductImg) {
      HapticFeedback.heavyImpact();
      AppToast.showError(title: 'Required Field Missing', message: 'Please select or upload a product image');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => isSaving = true);

    try {
      List<String> productImgUrls = [];
      if (productImageBytes != null && productImageBytes!.isNotEmpty) {
        final uploadedUrl = await _uploadImageToSupabase(productImageBytes!);
        if (uploadedUrl != null) productImgUrls.add(uploadedUrl);
      } else if (selectedMainImage.startsWith('http://') || selectedMainImage.startsWith('https://')) {
        productImgUrls.add(selectedMainImage);
      }

      final String mainImageUrl = productImgUrls.isNotEmpty
          ? productImgUrls.first
          : (selectedMainImage.startsWith('http') ? selectedMainImage : '');

      final int finalStockQty = isAvailable ? (stockQty > 0 ? stockQty : 50) : 0;

      final String statusString = isSpecialOffer
          ? 'Special Offer'
          : (isBestSeller ? 'Best Seller' : (isNewArrival ? 'New Arrival' : 'Standard'));

      final Map<String, dynamic> rowData = {
        'company_id': companyId,
        'title': name,
        'description': desc,
        'purchase_price': purPrice,
        'sale_price': salePrice,
        'stock_quantity': finalStockQty,
        'sizes': selectedSizes.isNotEmpty ? selectedSizes : [38, 39, 40, 41, 42],
        'colors': selectedColors.isNotEmpty ? selectedColors : ['#1A2530', '#5B9EE1'],
        'product_img_url': mainImageUrl,
        'is_best_seller': isBestSeller,
        'is_new_arrival': isNewArrival,
        'is_special': isSpecialOffer,
        'is_special_offer': isSpecialOffer,
        'status': statusString,
        'has_discount': hasDiscount,
        'discount_percentage': hasDiscount ? (double.tryParse(discountPercentageController.text.trim()) ?? 0.0) : 0.0,
        'discounted_price': hasDiscount ? _calculateFinalPrice() : salePrice,
      };

      Future<void> executeSave(Map<String, dynamic> data) async {
        if (isEditing && widget.product != null && int.tryParse(widget.product!.id) != null) {
          final int prodId = int.parse(widget.product!.id);
          await Supabase.instance.client
              .from('products')
              .update(data)
              .eq('prod_id', prodId);
        } else {
          await Supabase.instance.client
              .from('products')
              .insert(data);
        }
      }

      try {
        await executeSave(rowData);
      } catch (saveErr) {
        debugPrint('⚠️ Initial product save note ($saveErr). Retrying with schema fallback...');
        final fallbackData = Map<String, dynamic>.from(rowData)..remove('is_special_offer');
        try {
          await executeSave(fallbackData);
        } catch (_) {
          final minimalData = Map<String, dynamic>.from(fallbackData)..remove('status');
          await executeSave(minimalData);
        }
      }

      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        await homeCtrl.refreshAllSections();
      }

      HapticFeedback.mediumImpact();
      if (mounted) {
        Get.back();
        AppToast.showSuccess(
          title: isEditing ? 'Product Updated' : 'Product Created Successfully!',
          message: '$name has been saved',
        );
      }
    } catch (e) {
      HapticFeedback.heavyImpact();
      debugPrint('❌ SUPABASE SAVE PRODUCT ERROR: $e');
      if (e is PostgrestException) {
        debugPrint('Details: ${e.details}, Hint: ${e.hint}, Code: ${e.code}, Message: ${e.message}');
      }
      if (mounted) {
        final String errorMsg = e is PostgrestException
            ? '${e.message} (Code: ${e.code})'
            : e.toString();
        AppToast.showError(
          title: 'Database Error',
          message: 'Failed to save product: $errorMsg',
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF5B9EE1)),
        const SizedBox(width: 8),
        ResponsiveText(title, fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1A2530)),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A2530)));
  }

  InputDecoration _buildInputDecoration({required String hintText, IconData? icon, Color? iconColor}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF707B81), fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: icon != null ? Icon(icon, color: iconColor ?? const Color(0xFF5B9EE1), size: 20) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.black12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.black12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF5B9EE1), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
