import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/company.dart';
import 'home_controller.dart';

class CompanyController extends GetxController {
  final RxList<Company> companies = <Company>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCompaniesFromSupabase();
  }

  // Filtered companies list based on search query
  List<Company> get filteredCompanies {
    if (searchQuery.value.trim().isEmpty) {
      return companies;
    }
    return companies.where((c) {
      final query = searchQuery.value.toLowerCase();
      return c.name.toLowerCase().contains(query) ||
          c.tagline.toLowerCase().contains(query);
    }).toList();
  }

  /// ── SUPABASE STORAGE IMAGE UPLOAD ─────────────────────────────────────────

  /// Upload cropped image bytes to Supabase Storage Bucket ('company_images')
  Future<String?> uploadImageToSupabaseStorage(Uint8List imageBytes) async {
    try {
      final String fileName = 'logo_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = 'logos/$fileName';

      debugPrint('Uploading image to Supabase bucket "company_images" at $filePath...');
      await Supabase.instance.client.storage
          .from('company_images')
          .uploadBinary(
            filePath,
            imageBytes,
            fileOptions: const FileOptions(
              contentType: 'image/png',
              upsert: true,
            ),
          );

      final String publicUrl = Supabase.instance.client.storage
          .from('company_images')
          .getPublicUrl(filePath);

      debugPrint('Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e, stack) {
      debugPrint('Upload/Insert Error (Supabase Storage): $e');
      debugPrint(stack.toString());
      return null;
    }
  }

  /// ── SUPABASE DIRECT DATABASE CRUD OPERATIONS ──────────────────────────────

  /// Fetch all companies from Supabase `companies` table
  Future<void> fetchCompaniesFromSupabase() async {
    isLoading.value = true;
    try {
      debugPrint('⏳ Fetching companies from Supabase table "companies"...');
      final response = await Supabase.instance.client
          .from('companies')
          .select()
          .order('id', ascending: false);

      final List<Company> fetched =
          (response as List).map((json) => Company.fromJson(json)).toList();
      companies.assignAll(fetched);
      debugPrint('✅ Successfully fetched ${fetched.length} companies from Supabase.');

      // Refresh Home Screen companies & products list if HomeController is active
      if (Get.isRegistered<HomeController>()) {
        final homeCtrl = Get.find<HomeController>();
        homeCtrl.fetchCompanies();
        homeCtrl.fetchProducts();
      }
    } catch (e) {
      debugPrint('Upload/Insert Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Add a new company into Supabase `companies` table with optional image upload
  Future<bool> addCompany({
    required String name,
    required String tagline,
    required bool isActive,
    Uint8List? imageBytes,
  }) async {
    try {
      String? publicUrl;

      if (imageBytes != null && imageBytes.isNotEmpty) {
        publicUrl = await uploadImageToSupabaseStorage(imageBytes);
        if (publicUrl == null) {
          debugPrint('Upload/Insert Error: Failed to upload image to Supabase Storage bucket "company_images".');
        }
      }

      debugPrint('Inserting into Supabase: name=$name, tagline=$tagline, is_active=$isActive, image_url=$publicUrl');
      final response = await Supabase.instance.client.from('companies').insert({
        'name': name.trim(),
        'tagline': tagline.trim(),
        'is_active': isActive,
        'image_url': publicUrl,
      }).select();

      debugPrint('Successfully inserted company into Supabase: $response');
      await fetchCompaniesFromSupabase();
      return true;
    } catch (e, stack) {
      debugPrint('Upload/Insert Error: $e');
      debugPrint(stack.toString());
      return false;
    }
  }

  /// Update existing company in Supabase `companies` table
  Future<bool> updateCompany(
    String id, {
    required String name,
    required String tagline,
    required bool isActive,
    Uint8List? imageBytes,
    String? currentImageUrl,
  }) async {
    try {
      String? finalImageUrl = currentImageUrl;

      if (imageBytes != null && imageBytes.isNotEmpty) {
        final uploadedUrl = await uploadImageToSupabaseStorage(imageBytes);
        if (uploadedUrl != null) {
          finalImageUrl = uploadedUrl;
        } else {
          debugPrint('Upload/Insert Error: Image re-upload failed for company id=$id');
        }
      }

      debugPrint('Updating company id=$id in Supabase "companies"...');
      await Supabase.instance.client.from('companies').update({
        'name': name.trim(),
        'tagline': tagline.trim(),
        'is_active': isActive,
        'image_url': finalImageUrl,
      }).eq('id', id);

      debugPrint('Successfully updated company id=$id in Supabase');
      await fetchCompaniesFromSupabase();
      return true;
    } catch (e, stack) {
      debugPrint('Upload/Insert Error: $e');
      debugPrint(stack.toString());
      return false;
    }
  }

  /// Toggle Active / Inactive status in Supabase `companies` table
  Future<void> toggleStatus(Company company) async {
    final newStatus = !company.isActive;
    try {
      debugPrint('⏳ Toggling status for ${company.name} to $newStatus in Supabase...');
      await Supabase.instance.client
          .from('companies')
          .update({'is_active': newStatus})
          .eq('id', company.id);

      debugPrint('✅ Successfully toggled status in Supabase');
      await fetchCompaniesFromSupabase();
    } catch (e) {
      debugPrint('❌ Error toggling status in Supabase: $e');
    }
  }

  /// Delete a company by ID from Supabase `companies` table
  Future<bool> deleteCompany(String id) async {
    try {
      debugPrint('⏳ Deleting company id=$id from Supabase "companies"...');
      await Supabase.instance.client.from('companies').delete().eq('id', id);
      debugPrint('✅ Successfully deleted company id=$id from Supabase');
      await fetchCompaniesFromSupabase();
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting company from Supabase: $e');
      return false;
    }
  }
}
