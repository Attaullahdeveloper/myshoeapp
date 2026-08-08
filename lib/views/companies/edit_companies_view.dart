import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/company_controller.dart';
import '../../models/company.dart';
import '../../utils/app_colors.dart';
import '../../widgets/responsive_text.dart';

class EditCompaniesView extends StatefulWidget {
  const EditCompaniesView({super.key});

  @override
  State<EditCompaniesView> createState() => _EditCompaniesViewState();
}

class _EditCompaniesViewState extends State<EditCompaniesView> {
  final CompanyController controller = Get.put(CompanyController());
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
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── 1. HEADER ROW (Back Button, Title, Add Button) ──
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
                  const ResponsiveText(
                    'Edit Companies',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2530),
                  ),

                  // Add Button
                  GestureDetector(
                    onTap: () => _showAddEditBottomSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B9EE1), // #5B9EE1 Accent
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x335B9EE1),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          ResponsiveText(
                            'Add',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ],
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
                  decoration: InputDecoration(
                    hintText: 'Search company or brand...',
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

            // ── 3. COMPANIES LIST ──
            Expanded(
              child: Obx(() {
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
                          'Tap + Add button to create a new shoe company',
                          fontSize: 14,
                          color: Color(0xFF707B81),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.05,
                    vertical: 8,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final company = list[index];
                    return _buildCompanyCard(context, company);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── COMPANY CARD ITEM ──
  Widget _buildCompanyCard(BuildContext context, Company company) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo Avatar / Circle
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8F9),
              shape: BoxShape.circle,
              border: Border.all(
                color: company.isActive
                    ? const Color(0xFF5B9EE1).withValues(alpha: 0.3)
                    : Colors.grey.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                company.name.isNotEmpty ? company.name[0].toUpperCase() : 'B',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: company.isActive
                      ? const Color(0xFF1A2530)
                      : Colors.grey,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        company.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A2530),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: company.isActive
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        company.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: company.isActive
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFC62828),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  company.tagline.isNotEmpty
                      ? company.tagline
                      : 'No tagline specified',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF707B81),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Products count
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 14,
                      color: Color(0xFF5B9EE1),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${company.productCount} Products',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF5B9EE1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Action Buttons Column (Edit & Delete)
          Column(
            children: [
              // Edit Button
              GestureDetector(
                onTap: () => _showAddEditBottomSheet(context, company: company),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B9EE1).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Color(0xFF5B9EE1),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Delete Button
              GestureDetector(
                onTap: () => _showDeleteDialog(context, company),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4444).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
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
    );
  }

  // ── ADD / EDIT BOTTOM SHEET ──
  void _showAddEditBottomSheet(BuildContext context, {Company? company}) {
    final isEditing = company != null;
    final nameController = TextEditingController(text: isEditing ? company.name : '');
    final taglineController = TextEditingController(text: isEditing ? company.tagline : '');
    bool isActive = isEditing ? company.isActive : true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
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
                      decoration: InputDecoration(
                        hintText: 'e.g. Puma, Jordan, Converse',
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

                    // Submit Button
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
                        onPressed: () {
                          final name = nameController.text.trim();
                          final tagline = taglineController.text.trim();

                          if (name.isEmpty) {
                            Get.snackbar(
                              'Required Field',
                              'Please enter company name',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFFFF4444),
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                            );
                            return;
                          }

                          if (isEditing) {
                            controller.updateCompany(
                              company.id,
                              name: name,
                              tagline: tagline,
                              isActive: isActive,
                            );
                            Get.back();
                            Get.snackbar(
                              'Company Updated',
                              '$name has been updated successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF1A2530),
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                            );
                          } else {
                            controller.addCompany(
                              name: name,
                              tagline: tagline,
                            );
                            Get.back();
                            Get.snackbar(
                              'Company Added',
                              '$name has been added successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF1A2530),
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                            );
                          }
                        },
                        child: Text(
                          isEditing ? 'Save Changes' : 'Create Company',
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: Color(0xFFFF4444),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const ResponsiveText(
                'Delete Company?',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2530),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "${company.name}"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF707B81),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Color(0xFF707B81)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xFF707B81),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4444),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        controller.deleteCompany(company.id);
                        Get.back();
                        Get.snackbar(
                          'Company Deleted',
                          '${company.name} was removed from companies list',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFFFF4444),
                          colorText: Colors.white,
                          margin: const EdgeInsets.all(16),
                          borderRadius: 12,
                        );
                      },
                      child: const Text(
                        'Delete',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
