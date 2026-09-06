class Company {
  final String id;
  String name;
  String tagline;
  bool isActive;
  String? imageUrl;

  Company({
    required this.id,
    required this.name,
    this.tagline = '',
    this.isActive = true,
    this.imageUrl,
  });

  String get logoUrl => imageUrl ?? '';

  Company copyWith({
    String? id,
    String? name,
    String? tagline,
    bool? isActive,
    String? imageUrl,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      tagline: json['tagline']?.toString() ?? '',
      isActive: json['is_active'] ?? json['isActive'] ?? true,
      imageUrl: json['image_url']?.toString() ?? json['logo_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tagline': tagline,
      'is_active': isActive,
      'image_url': imageUrl,
    };
  }
}
