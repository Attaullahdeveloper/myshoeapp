import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/company_controller.dart';
import '../../controllers/home_controller.dart';
import '../../models/product.dart';
import '../../models/stock_batch.dart';
import '../../utils/app_colors.dart';
import '../../widgets/animated_switch.dart';
import '../../widgets/responsive_text.dart';

class AddEditProductView extends StatefulWidget {
  final Product? product;

  const AddEditProductView({super.key, this.product});

  @override
  State<AddEditProductView> createState() => _AddEditProductViewState();
}

class _AddEditProductViewState extends State<AddEditProductView> {
  final HomeController homeController = Get.find<HomeController>();
  final CompanyController companyController = Get.isRegistered<CompanyController>()
      ? Get.find<CompanyController>()
      : Get.put(CompanyController());

  late bool isEditing;

  late TextEditingController nameController;
  late TextEditingController descController;
  late TextEditingController ratingController;

  late String selectedBrand;
  late String selectedMainImage;
  late List<int> selectedSizes;
  late List<String> selectedColors;
  late List<String> selectedGallery;
  late List<StockBatch> stockBatches;

  late bool isBestSeller;
  late bool isNewArrival;

  final ImagePicker _picker = ImagePicker();

  // Preset asset images
  final List<Map<String, String>> availableAssetImages = [
    {'name': 'Nike Air 1', 'path': 'assets/images/shoe_nike_1.png'},
    {'name': 'Nike Air 2', 'path': 'assets/images/shoe_nike_2.png'},
    {'name': 'Nike Air 3', 'path': 'assets/images/shoe_nike_3.png'},
    {'name': 'Adidas Red', 'path': 'assets/images/shoe_adidas_red.png'},
    {'name': 'Nike Orange', 'path': 'assets/images/shoe_nike_orange.png'},
    {'name': 'Nike Blue', 'path': 'assets/images/shoe_nike_blue.png'},
    {'name': 'Nike Pink', 'path': 'assets/images/shoe_nike_pink.png'},
    {'name': 'Nike Grey', 'path': 'assets/images/shoe_nike_grey.png'},
    {'name': 'Nike Pink Grey', 'path': 'assets/images/shoe_nike_pink_grey.png'},
    {'name': 'Boot Classic', 'path': 'assets/images/boot.png'},
  ];

  // Available shoe sizes
  final List<int> allAvailableSizes = [37, 38, 39, 40, 41, 42, 43, 44, 45];

  // Available color options
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

    nameController = TextEditingController(text: (isEditing && p != null) ? p.name : '');
    descController = TextEditingController(
        text: (isEditing && p != null) ? p.description : 'High performance premium shoe with maximum comfort.');
    ratingController =
        TextEditingController(text: (isEditing && p != null) ? p.rating.toString() : '4.7');

    final availableCompanies = companyController.companies.isNotEmpty
        ? companyController.companies.map((c) => c.name).toList()
        : ['Nike', 'Puma', 'Adidas', 'Converse', 'UA'];

    selectedBrand = (isEditing && p != null && availableCompanies.contains(p.category))
        ? p.category
        : availableCompanies.first;

    selectedMainImage = (isEditing && p != null) ? p.image : availableAssetImages.first['path']!;

    selectedSizes = (isEditing && p != null) ? List.from(p.sizes) : [38, 39, 40, 41, 42];
    selectedColors = (isEditing && p != null) ? List.from(p.colors) : ['#1A2530', '#5B9EE1'];
    selectedGallery = (isEditing && p != null) ? List.from(p.galleryImages) : [];

    stockBatches = (isEditing && p != null)
        ? List.from(p.stockBatches)
        : [
            StockBatch(
              id: 'batch_1',
              batchNumber: 'BATCH-2026-01',
              purchasePrice: (isEditing && p != null) ? p.price * 0.6 : 120.0,
              salePrice: (isEditing && p != null) ? p.price : 210.0,
              quantity: 50,
              entryDate: DateTime.now(),
              supplier: 'Nike Direct Supplier',
            )
          ];

    isBestSeller = (isEditing && p != null) ? p.isBestSeller : true;
    isNewArrival = (isEditing && p != null) ? p.isNewArrival : false;
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    ratingController.dispose();
    super.dispose();
  }

  // Image Picker from Gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile != null) {
        setState(() {
          selectedMainImage = pickedFile.path;
        });
        Get.snackbar(
          'Image Selected',
          'Selected photo from gallery successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1A2530),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gallery Access Error',
        'Could not pick image from gallery',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  // Helper Widget for Image Preview (Supports File & Asset)
  Widget _buildImageWidget(String path, {double width = 80, double height = 80, BoxFit fit = BoxFit.contain}) {
    if (path.startsWith('/') || path.contains(':\\') || path.contains('/data/')) {
      return Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_rounded, color: Colors.grey),
      );
    } else {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_rounded, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final availableCompanies = companyController.companies.isNotEmpty
        ? companyController.companies.map((c) => c.name).toList()
        : ['Nike', 'Puma', 'Adidas', 'Converse', 'UA'];

    return Scaffold(
      backgroundColor: AppColors.onboardingBg, // #F9F9F9 Light theme background
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── 1. HEADER ROW ──
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF1A2530),
                      ),
                    ),
                  ),

                  // Title
                  ResponsiveText(
                    isEditing ? 'Edit Shoe Product' : 'Add New Shoe Product',
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2530),
                  ),

                  // Save Button Header Action
                  GestureDetector(
                    onTap: _saveProduct,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9EE1),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x335B9EE1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── 2. SCROLLABLE FORM BODY ──
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── SECTION 1: PRODUCT BASICS ──
                    _buildSectionHeader('Product Details', Icons.info_outline_rounded),
                    const SizedBox(height: 12),

                    // Shoe Title Name Input
                    _buildInputLabel('Shoe Title / Name *'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(
                        color: Color(0xFF1A2530),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _buildInputDecoration(
                        hintText: 'e.g. Nike Air Jordan Retro High',
                        icon: Icons.shopping_bag_outlined,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Brand Dropdown & Rating Row
                    Row(
                      children: [
                        // Brand Dropdown
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputLabel('Company / Brand'),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedBrand,
                                    isExpanded: true,
                                    icon: const Icon(
                                        Icons.arrow_drop_down_rounded,
                                        color: Color(0xFF5B9EE1)),
                                    items: availableCompanies
                                        .map((brand) => DropdownMenuItem(
                                              value: brand,
                                              child: Text(
                                                brand,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1A2530),
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() {
                                          selectedBrand = val;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Rating Input
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInputLabel('Rating (1-5)'),
                              const SizedBox(height: 6),
                              TextField(
                                controller: ratingController,
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                                style: const TextStyle(
                                  color: Color(0xFF1A2530),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                                decoration: _buildInputDecoration(
                                  hintText: '4.8',
                                  icon: Icons.star_rounded,
                                  iconColor: const Color(0xFFFFB800),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description Field
                    _buildInputLabel('Description / Specifications'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descController,
                      maxLines: 2,
                      style: const TextStyle(
                        color: Color(0xFF1A2530),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _buildInputDecoration(
                        hintText: 'Enter shoe description and comfort details...',
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── SECTION 2: BATCH STOCK & PRICING MANAGEMENT ──
                    _buildSectionHeader('Stock & Batch Entries', Icons.inventory_2_outlined),
                    const SizedBox(height: 12),

                    // Stock Summary Tile
                    _buildStockSummaryCard(),

                    const SizedBox(height: 12),

                    // Batch Entries Cards / Table
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Stock Batches',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A2530),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _showAddBatchDialog,
                          icon: const Icon(Icons.add_circle_outline_rounded,
                              size: 18, color: Color(0xFF5B9EE1)),
                          label: const Text(
                            'Add Batch',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5B9EE1),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    if (stockBatches.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            'No stock batches added yet. Tap "+ Add Batch" above.',
                            style: TextStyle(color: Color(0xFF707B81), fontSize: 13),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: stockBatches.map((batch) {
                          return _buildBatchTile(batch);
                        }).toList(),
                      ),

                    const SizedBox(height: 24),

                    // ── SECTION 3: IMAGE SELECTION (GALLERY & ASSETS) ──
                    _buildSectionHeader('Product Images', Icons.image_outlined),
                    const SizedBox(height: 12),

                    // Main Image Preview Box & Gallery Pick Button
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Main Image Thumbnail
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8F9),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF5B9EE1),
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: _buildImageWidget(selectedMainImage, width: 84, height: 84),
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Main Product Image',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A2530),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Pick from gallery or select asset below',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF707B81),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Pick from Gallery Button
                                ElevatedButton.icon(
                                  onPressed: _pickImageFromGallery,
                                  icon: const Icon(Icons.photo_library_rounded,
                                      size: 18, color: Colors.white),
                                  label: const Text(
                                    'Pick from Gallery',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1A2530),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 10),
                                    elevation: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Preset Assets Grid
                    _buildInputLabel('Or Choose Preset Shoe Asset'),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 75,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: availableAssetImages.length,
                        itemBuilder: (context, idx) {
                          final imgMap = availableAssetImages[idx];
                          final isSelected = selectedMainImage == imgMap['path'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedMainImage = imgMap['path']!;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 75,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF5B9EE1)
                                      : Colors.black12,
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(6.0),
                                child: Image.asset(
                                  imgMap['path']!,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── SECTION 4: SIZES & COLORS SELECTION ──
                    _buildSectionHeader('Multiple Sizes & Colors', Icons.format_size_rounded),
                    const SizedBox(height: 12),

                    // Multiple Sizes Choice Chips
                    _buildInputLabel('Available Shoe Sizes'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allAvailableSizes.map((sz) {
                        final isSelected = selectedSizes.contains(sz);
                        return FilterChip(
                          label: Text('$sz'),
                          selected: isSelected,
                          selectedColor: const Color(0xFF1A2530),
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF1A2530),
                            fontWeight: FontWeight.w700,
                          ),
                          backgroundColor: Colors.white,
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                selectedSizes.add(sz);
                              } else {
                                selectedSizes.remove(sz);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Multiple Colors Choice Chips
                    _buildInputLabel('Available Color Options'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: allAvailableColors.map((colMap) {
                        final String hex = colMap['hex'];
                        final Color colorVal = colMap['color'];
                        final bool isSelected = selectedColors.contains(hex);

                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: colorVal,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black38),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(colMap['name']),
                            ],
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF5B9EE1).withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? const Color(0xFF5B9EE1)
                                : const Color(0xFF1A2530),
                            fontWeight: FontWeight.w700,
                          ),
                          backgroundColor: Colors.white,
                          onSelected: (val) {
                            setState(() {
                              if (val) {
                                selectedColors.add(hex);
                              } else {
                                selectedColors.remove(hex);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // ── SECTION 5: ANIMATED SWITCHES & BADGES ──
                    _buildSectionHeader('Badges & Visibility', Icons.stars_rounded),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.workspace_premium_rounded,
                                      color: Color(0xFFFF9800), size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Best Seller Badge',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A2530),
                                    ),
                                  ),
                                ],
                              ),
                              AnimatedSwitch(
                                value: isBestSeller,
                                activeColor: const Color(0xFF5B9EE1),
                                onChanged: (val) {
                                  setState(() {
                                    isBestSeller = val;
                                  });
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.new_releases_outlined,
                                      color: Color(0xFF4CAF50), size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'New Arrival Badge',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A2530),
                                    ),
                                  ),
                                ],
                              ),
                              AnimatedSwitch(
                                value: isNewArrival,
                                activeColor: const Color(0xFF5B9EE1),
                                onChanged: (val) {
                                  setState(() {
                                    isNewArrival = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Full Width Prominent Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B9EE1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        onPressed: _saveProduct,
                        child: Text(
                          isEditing ? 'Save Product Changes' : 'Create Shoe Product',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STOCK SUMMARY CARD ──
  Widget _buildStockSummaryCard() {
    int totalStock = stockBatches.fold(0, (sum, b) => sum + b.quantity);
    double latestPur = stockBatches.isNotEmpty ? stockBatches.last.purchasePrice : 0;
    double latestSale = stockBatches.isNotEmpty ? stockBatches.last.salePrice : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A2530), Color(0xFF2C3E50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryCol('Total Stock', '$totalStock Pairs', Colors.white),
          Container(width: 1, height: 36, color: Colors.white24),
          _buildSummaryCol('Purchase Price', '\$${latestPur.toStringAsFixed(2)}', const Color(0xFFFFB800)),
          Container(width: 1, height: 36, color: Colors.white24),
          _buildSummaryCol('Sale Price', '\$${latestSale.toStringAsFixed(2)}', const Color(0xFF5B9EE1)),
        ],
      ),
    );
  }

  Widget _buildSummaryCol(String title, String val, Color valColor) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(
            color: valColor,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ── BATCH TILE WIDGET ──
  Widget _buildBatchTile(StockBatch batch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF5B9EE1).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_rounded,
                size: 18, color: Color(0xFF5B9EE1)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.batchNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2530),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pur: \$${batch.purchasePrice.toStringAsFixed(2)} | Sale: \$${batch.salePrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF707B81)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2530),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${batch.quantity} Pairs',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                size: 18, color: Color(0xFFFF4444)),
            onPressed: () {
              setState(() {
                stockBatches.removeWhere((b) => b.id == batch.id);
              });
            },
          ),
        ],
      ),
    );
  }

  // ── ADD STOCK BATCH DIALOG ──
  void _showAddBatchDialog() {
    final batchNumCtrl = TextEditingController(
        text: 'BATCH-2026-0${stockBatches.length + 1}');
    final purCtrl = TextEditingController(text: '120.00');
    final saleCtrl = TextEditingController(text: '210.00');
    final qtyCtrl = TextEditingController(text: '50');
    final supplierCtrl = TextEditingController(text: 'Nike Direct');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add Stock Batch Entry',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2530),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputLabel('Batch Number / Code'),
                const SizedBox(height: 4),
                TextField(
                  controller: batchNumCtrl,
                  style: const TextStyle(color: Color(0xFF1A2530), fontWeight: FontWeight.w600),
                  decoration: _buildInputDecoration(hintText: 'BATCH-2026-01'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Purchase Price (\$)'),
                          const SizedBox(height: 4),
                          TextField(
                            controller: purCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Color(0xFF1A2530), fontWeight: FontWeight.w700),
                            decoration: _buildInputDecoration(hintText: '120.00'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInputLabel('Sale Price (\$)'),
                          const SizedBox(height: 4),
                          TextField(
                            controller: saleCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(color: Color(0xFF1A2530), fontWeight: FontWeight.w700),
                            decoration: _buildInputDecoration(hintText: '210.00'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInputLabel('Stock Quantity (Pairs)'),
                const SizedBox(height: 4),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Color(0xFF1A2530), fontWeight: FontWeight.w700),
                  decoration: _buildInputDecoration(hintText: '50'),
                ),
                const SizedBox(height: 12),
                _buildInputLabel('Supplier Name'),
                const SizedBox(height: 4),
                TextField(
                  controller: supplierCtrl,
                  style: const TextStyle(color: Color(0xFF1A2530), fontWeight: FontWeight.w600),
                  decoration: _buildInputDecoration(hintText: 'Official Distributor'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF707B81))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B9EE1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final batchNum = batchNumCtrl.text.trim();
                final purPrice = double.tryParse(purCtrl.text.trim()) ?? 120.0;
                final salePrice = double.tryParse(saleCtrl.text.trim()) ?? 210.0;
                final qty = int.tryParse(qtyCtrl.text.trim()) ?? 50;
                final supplier = supplierCtrl.text.trim();

                if (batchNum.isNotEmpty) {
                  setState(() {
                    stockBatches.add(StockBatch(
                      id: 'batch_${DateTime.now().millisecondsSinceEpoch}',
                      batchNumber: batchNum,
                      purchasePrice: purPrice,
                      salePrice: salePrice,
                      quantity: qty,
                      entryDate: DateTime.now(),
                      supplier: supplier,
                    ));
                  });
                  Get.back();
                }
              },
              child: const Text('Add Batch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  // ── SAVE PRODUCT ACTION ──
  void _saveProduct() {
    final name = nameController.text.trim();
    final desc = descController.text.trim();
    final rating = double.tryParse(ratingController.text.trim()) ?? 4.5;
    final finalPrice = stockBatches.isNotEmpty
        ? stockBatches.last.salePrice
        : 150.0;

    if (name.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter shoe title name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFFF4444),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (isEditing) {
      final updated = widget.product!.copyWith(
        name: name,
        category: selectedBrand,
        price: finalPrice,
        image: selectedMainImage,
        rating: rating,
        isBestSeller: isBestSeller,
        isNewArrival: isNewArrival,
        description: desc,
        sizes: selectedSizes,
        colors: selectedColors,
        galleryImages: selectedGallery,
        stockBatches: stockBatches,
      );
      homeController.updateProduct(updated);
      Get.back();
      Get.snackbar(
        'Product Saved',
        '$name was updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1A2530),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } else {
      final newProd = Product(
        id: 'shoe_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        category: selectedBrand,
        price: finalPrice,
        image: selectedMainImage,
        rating: rating,
        isBestSeller: isBestSeller,
        isNewArrival: isNewArrival,
        description: desc,
        sizes: selectedSizes.isNotEmpty ? selectedSizes : [38, 39, 40, 41, 42],
        colors: selectedColors.isNotEmpty ? selectedColors : ['#1A2530', '#5B9EE1'],
        galleryImages: selectedGallery,
        stockBatches: stockBatches,
      );
      homeController.addProduct(newProd);
      Get.back();
      Get.snackbar(
        'Shoe Created',
        '$name was added to store catalog',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1A2530),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  // ── STYLING HELPERS ──
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF5B9EE1)),
        const SizedBox(width: 8),
        ResponsiveText(
          title,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF1A2530),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A2530),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    IconData? icon,
    Color? iconColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF707B81),
        fontSize: 14,
      ),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: icon != null
          ? Icon(icon, color: iconColor ?? const Color(0xFF5B9EE1), size: 20)
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF5B9EE1), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
