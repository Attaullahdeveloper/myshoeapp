class Company {
  final String id;
  String name;
  String logoUrl;
  String tagline;
  int productCount;
  bool isActive;

  Company({
    required this.id,
    required this.name,
    required this.logoUrl,
    this.tagline = '',
    this.productCount = 0,
    this.isActive = true,
  });

  Company copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? tagline,
    int? productCount,
    bool? isActive,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      tagline: tagline ?? this.tagline,
      productCount: productCount ?? this.productCount,
      isActive: isActive ?? this.isActive,
    );
  }
}
