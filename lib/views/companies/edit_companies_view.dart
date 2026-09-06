import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/company_controller.dart';
import '../../models/company.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_toast.dart';
import '../../widgets/app_delete_dialog.dart';
import '../../widgets/circular_crop_dialog.dart';
import '../../widgets/responsive_text.dart';

class EditCompaniesView extends StatefulWidget {
  const EditCompaniesView({super.key});

  @override
  State<EditCompaniesView> createState() => _EditCompaniesViewState();
}

class _EditCompaniesViewState extends State<EditCompaniesView> {
  final CompanyController controller = Get.isRegistered<CompanyController>()
      ? Get.find<CompanyController>()
      : Get.put(CompanyController());

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.onboardingBg, // #F9F9F9 Light theme background

      // ── FLOATING ADD BUTTON AT THE BOTTOM ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditBottomSheet(context),
        backgroundColor: const Color(0xFF5B9EE1),
        elevation: 6,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: const Text(
          'Add Company',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── 1. HEADER ROW (Back Button, Title & Refresh) ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Row(
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

                  const SizedBox(width: 16),

                  // Title
                  const Expanded(
                    child: ResponsiveText(
                      'Manage Companies',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2530),
                    ),
                  ),

                  // Refresh Button (Fetch from Supabase)
                  GestureDetector(
                    onTap: () async {
                      await controller.fetchCompaniesFromSupabase();
                      AppToast.showSuccess(
                        title: 'Supabase Sync',
                        message: 'Refreshed companies from Supabase database',
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9EE1).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sync_rounded,
                        size: 20,
                        color: Color(0xFF5B9EE1),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── 2. SEARCH BAR ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => controller.searchQuery.value = value,
                  style: const TextStyle(
                    color: Color(0xFF1A2530),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  cursorColor: const Color(0xFF5B9EE1),
                  decoration: InputDecoration(
                    hintText: 'Search company or tagline...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF707B81),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF707B81),
                    ),
                    suffixIcon: Obx(() {
                      if (controller.searchQuery.value.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(Icons.clear_rounded,
                              color: Color(0xFF707B81), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            controller.searchQuery.value = '';
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── 3. COMPANIES LIST FROM SUPABASE ──
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF5B9EE1),
                    ),
                  );
                }

                final list = controller.filteredCompanies;

                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5B9EE1).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.business_outlined,
                            size: 40,
                            color: Color(0xFF5B9EE1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const ResponsiveText(
                          'No Companies Found',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A2530),
                        ),
                        const SizedBox(height: 6),
                        const ResponsiveText(
                          'Tap + Add Company button below to insert into Supabase',
                          fontSize: 14,
                          color: Color(0xFF707B81),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchCompaniesFromSupabase(),
                  color: const Color(0xFF5B9EE1),
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      left: size.width * 0.05,
                      right: size.width * 0.05,
                      top: 8,
                      bottom: 80, // Space for Floating Action Button
                    ),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final company = list[index];
                      return _buildCompanyCard(context, company);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── COMPANY CARD ITEM WITH SUPABASE IMAGE DISPLAY & FALLBACK ──
  Widget _buildCompanyCard(BuildContext context, Company company) {
    final hasImage = company.imageUrl != null && company.imageUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: company.isActive
              ? const Color(0xFF5B9EE1).withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Accent Status Line
              Container(
                width: 6,
                color: company.isActive
                    ? const Color(0xFF5B9EE1)
                    : const Color(0xFFB0BEC5),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // CircleAvatar (Supabase Network Image or Letter Fallback)
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: company.isActive
                            ? const Color(0xFF5B9EE1)
                            : const Color(0xFF707B81),
                        child: ClipOval(
                          child: hasImage
                              ? Image.network(
                                  company.imageUrl!,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _buildLetterAvatar(company.name),
                                )
                              : _buildLetterAvatar(company.name),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Company Text Details Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    company.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A2530),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Clickable Status Badge (Toggles is_active in Supabase)
                                GestureDetector(
                                  onTap: () => controller.toggleStatus(company),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: company.isActive
                                          ? const Color(0xFFE8F5E9)
                                          : const Color(0xFFFFEBEE),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: company.isActive
                                            ? const Color(0xFF81C784)
                                            : const Color(0xFFE57373),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: company.isActive
                                                ? const Color(0xFF2E7D32)
                                                : const Color(0xFFC62828),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          company.isActive ? 'Active' : 'Inactive',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: company.isActive
                                                ? const Color(0xFF2E7D32)
                                                : const Color(0xFFC62828),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            Text(
                              company.tagline.isNotEmpty
                                  ? company.tagline
                                  : 'No tagline provided',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF707B81),
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Action Buttons (Edit & Delete)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Edit Button
                          InkWell(
                            onTap: () =>
                                _showAddEditBottomSheet(context, company: company),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5B9EE1).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: Color(0xFF5B9EE1),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Delete Button
                          InkWell(
                            onTap: () => _showDeleteDialog(context, company),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF4444).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                size: 18,
                                color: Color(0xFFFF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLetterAvatar(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'C',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  // ── ADD / EDIT BOTTOM SHEET WITH WHATSAPP/FACEBOOK CIRCULAR CROP DIALOG ──
  void _showAddEditBottomSheet(BuildContext context, {Company? company}) {
    final isEditing = company != null;
    final nameController =
        TextEditingController(text: isEditing ? company.name : '');
    final taglineController =
        TextEditingController(text: isEditing ? company.tagline : '');
    bool isActive = isEditing ? company.isActive : true;
    bool isSubmitting = false;
    Uint8List? croppedBytes;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            // Pick Image from Gallery & Launch WhatsApp-Style Circular Crop Dialog
            Future<void> pickAndCropLogo() async {
              try {
                final ImagePicker picker = ImagePicker();
                final XFile? file = await picker.pickImage(source: ImageSource.gallery);

                if (file != null) {
                  final Uint8List bytes = await file.readAsBytes();
                  if (!context.mounted) return;

                  // Store picked bytes immediately in modal state
                  setStateModal(() {
                    croppedBytes = bytes;
                  });

                  // Open WhatsApp/Facebook Style Circular Profile Crop Dialog
                  final Uint8List? resultBytes = await showDialog<Uint8List>(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => WhatsAppCircularCropDialog(imageBytes: bytes),
                  );

                  if (resultBytes != null && resultBytes.isNotEmpty) {
                    setStateModal(() {
                      croppedBytes = resultBytes;
                    });
                  }
                }
              } catch (e) {
                debugPrint('Upload/Insert Error: $e');
              }
            }

            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sheet Handle Bar
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sheet Header Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ResponsiveText(
                          isEditing ? 'Edit Company' : 'Add New Company',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A2530),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFF707B81)),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── CIRCLEAVATAR LOGO PREVIEW WITH CAMERA BADGE BUTTON ──
                    Center(
                      child: GestureDetector(
                        onTap: pickAndCropLogo,
                        child: Stack(
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F8F9),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF5B9EE1),
                                  width: 2.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: croppedBytes != null
                                    ? Image.memory(
                                        croppedBytes!,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                      )
                                    : (isEditing && company.imageUrl != null && company.imageUrl!.isNotEmpty)
                                        ? Image.network(
                                            company.imageUrl!,
                                            width: 96,
                                            height: 96,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _buildLetterAvatar(nameController.text),
                                          )
                                        : _buildLetterAvatar(nameController.text),
                              ),
                            ),

                            // Camera Badge Icon Button
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF5B9EE1),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Center(
                      child: GestureDetector(
                        onTap: pickAndCropLogo,
                        child: const Text(
                          'Tap photo to Crop & Adjust Logo',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5B9EE1),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Company Name Field
                    const ResponsiveText(
                      'Company / Brand Name',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2530),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      onChanged: (_) => setStateModal(() {}),
                      style: const TextStyle(
                        color: Color(0xFF1A2530),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      cursorColor: const Color(0xFF5B9EE1),
                      decoration: InputDecoration(
                        hintText: 'e.g. Puma, Jordan, Nike',
                        hintStyle: const TextStyle(
                            color: Color(0xFF707B81), fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF7F8F9),
                        prefixIcon: const Icon(Icons.business_rounded,
                            color: Color(0xFF5B9EE1), size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tagline Field
                    const ResponsiveText(
                      'Tagline / Description',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2530),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: taglineController,
                      style: const TextStyle(
                        color: Color(0xFF1A2530),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      cursorColor: const Color(0xFF5B9EE1),
                      decoration: InputDecoration(
                        hintText: 'e.g. Forever Faster',
                        hintStyle: const TextStyle(
                            color: Color(0xFF707B81), fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF7F8F9),
                        prefixIcon: const Icon(Icons.subtitles_outlined,
                            color: Color(0xFF5B9EE1), size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Active Switch
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.toggle_on_outlined,
                                  color: Color(0xFF5B9EE1)),
                              SizedBox(width: 10),
                              ResponsiveText(
                                'Company Active Status',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A2530),
                              ),
                            ],
                          ),
                          Switch(
                            value: isActive,
                            activeColor: const Color(0xFF5B9EE1),
                            onChanged: (val) {
                              setStateModal(() {
                                isActive = val;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button with Upload & Saving Progress Loading State
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5B9EE1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 3,
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                final tagline = taglineController.text.trim();

                                if (name.isEmpty) {
                                  HapticFeedback.heavyImpact();
                                  AppToast.showError(
                                    title: 'Required Field Missing',
                                    message: 'Please enter company name',
                                  );
                                  return;
                                }

                                if (tagline.isEmpty) {
                                  HapticFeedback.heavyImpact();
                                  AppToast.showError(
                                    title: 'Required Field Missing',
                                    message: 'Please enter company tagline',
                                  );
                                  return;
                                }

                                final bool hasLogo = croppedBytes != null ||
                                    (isEditing && company.imageUrl != null && company.imageUrl!.isNotEmpty);

                                if (!hasLogo) {
                                  HapticFeedback.heavyImpact();
                                  AppToast.showError(
                                    title: 'Required Field Missing',
                                    message: 'Please select or upload a company logo image',
                                  );
                                  return;
                                }

                                setStateModal(() {
                                  isSubmitting = true;
                                });

                                try {
                                  if (isEditing) {
                                    final success = await controller.updateCompany(
                                      company.id,
                                      name: name,
                                      tagline: tagline,
                                      isActive: isActive,
                                      imageBytes: croppedBytes,
                                      currentImageUrl: company.imageUrl,
                                    );
                                    if (success) {
                                      Get.back();
                                      AppToast.showSuccess(
                                        title: 'Company Updated',
                                        message: '$name updated and synced with Supabase Storage & DB',
                                      );
                                    } else {
                                      AppToast.showError(
                                        title: 'Update Error',
                                        message: 'Failed to update company in Supabase',
                                      );
                                    }
                                  } else {
                                    final success = await controller.addCompany(
                                      name: name,
                                      tagline: tagline,
                                      isActive: isActive,
                                      imageBytes: croppedBytes,
                                    );
                                    if (success) {
                                      Get.back();
                                      AppToast.showSuccess(
                                        title: 'Company Added',
                                        message: '$name uploaded & saved to Supabase Storage & DB',
                                      );
                                    } else {
                                      AppToast.showError(
                                        title: 'Save Error',
                                        message: 'Failed to insert company into Supabase',
                                      );
                                    }
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setStateModal(() {
                                      isSubmitting = false;
                                    });
                                  }
                                }
                              },
                        child: isSubmitting
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Uploading & Saving...',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                isEditing ? 'Save Changes' : 'Add Company',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── DELETE CONFIRMATION DIALOG ──
  void _showDeleteDialog(BuildContext context, Company company) {
    AppDeleteDialog.show(
      context,
      title: 'Delete Company',
      description:
          'Are you sure you want to delete "${company.name}"? This action will remove it from Supabase table "companies".',
      confirmText: 'Delete',
      onConfirm: () async {
        final success = await controller.deleteCompany(company.id);
        if (success) {
          AppToast.showError(
            title: 'Company Deleted',
            message: '${company.name} removed from Supabase table "companies"',
          );
        }
      },
    );
  }
}
