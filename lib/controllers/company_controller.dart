import 'package:get/get.dart';
import '../models/company.dart';

class CompanyController extends GetxController {
  // Reactive list of companies initialized with default shoe brands
  final RxList<Company> companies = <Company>[
    Company(
      id: '1',
      name: 'Nike',
      logoUrl: 'assets/images/onboarding1.png',
      tagline: 'Just Do It',
      productCount: 24,
      isActive: true,
    ),
    Company(
      id: '2',
      name: 'Adidas',
      logoUrl: 'assets/images/onboarding2.png',
      tagline: 'Impossible Is Nothing',
      productCount: 18,
      isActive: true,
    ),
    Company(
      id: '3',
      name: 'Puma',
      logoUrl: 'assets/images/onboarding3.png',
      tagline: 'Forever Faster',
      productCount: 12,
      isActive: true,
    ),
    Company(
      id: '4',
      name: 'Jordan',
      logoUrl: 'assets/images/boot.png',
      tagline: 'Flight & Performance',
      productCount: 15,
      isActive: true,
    ),
    Company(
      id: '5',
      name: 'New Balance',
      logoUrl: 'assets/images/onboarding1.png',
      tagline: 'Fearlessly Independent',
      productCount: 9,
      isActive: false,
    ),
    Company(
      id: '6',
      name: 'Under Armour',
      logoUrl: 'assets/images/onboarding2.png',
      tagline: 'Protect This House',
      productCount: 7,
      isActive: true,
    ),
  ].obs;

  // Search query filter
  final RxString searchQuery = ''.obs;

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

  /// ── CRUD Operations ───────────────────────────────────

  /// Add a new company
  void addCompany({
    required String name,
    required String tagline,
    String logoUrl = 'assets/images/onboarding1.png',
  }) {
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newCompany = Company(
      id: newId,
      name: name.trim(),
      logoUrl: logoUrl,
      tagline: tagline.trim(),
      productCount: 0,
      isActive: true,
    );
    companies.insert(0, newCompany);
  }

  /// Update existing company details
  void updateCompany(
    String id, {
    required String name,
    required String tagline,
    String? logoUrl,
    bool? isActive,
  }) {
    final index = companies.indexWhere((c) => c.id == id);
    if (index != -1) {
      final existing = companies[index];
      companies[index] = existing.copyWith(
        name: name.trim(),
        tagline: tagline.trim(),
        logoUrl: logoUrl ?? existing.logoUrl,
        isActive: isActive ?? existing.isActive,
      );
    }
  }

  /// Toggle Active / Inactive status of a company
  void toggleStatus(String id) {
    final index = companies.indexWhere((c) => c.id == id);
    if (index != -1) {
      final existing = companies[index];
      companies[index] = existing.copyWith(isActive: !existing.isActive);
    }
  }

  /// Delete a company by ID
  void deleteCompany(String id) {
    companies.removeWhere((c) => c.id == id);
  }
}
