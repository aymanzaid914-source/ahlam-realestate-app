// lib/models/project.dart
class Project {
  final int id;
  final String slug;
  final String name;
  final String? nameEn;
  final String? tagline;
  final String? shortDescription;
  final String? description;
  final String? location;
  final String? city;
  final String? coverImageUrl;
  final String? imageUrl;
  final String status;
  final bool isFeatured;
  final int totalUnits;
  final int availableUnits;
  final double? latitude;
  final double? longitude;
  final String? startDate;
  final String? expectedCompletion;

  Project({
    required this.id,
    required this.slug,
    required this.name,
    this.nameEn,
    this.tagline,
    this.shortDescription,
    this.description,
    this.location,
    this.city,
    this.coverImageUrl,
    this.imageUrl,
    required this.status,
    this.isFeatured = false,
    this.totalUnits = 0,
    this.availableUnits = 0,
    this.latitude,
    this.longitude,
    this.startDate,
    this.expectedCompletion,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id                  : json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      slug                : json['slug']?.toString() ?? '',
      name                : json['name']?.toString() ?? '',
      nameEn              : json['name_en']?.toString(),
      tagline             : json['tagline']?.toString(),
      shortDescription    : json['short_description']?.toString(),
      description         : json['description']?.toString(),
      location            : json['location']?.toString(),
      city                : json['city']?.toString(),
      coverImageUrl       : json['cover_image_url']?.toString(),
      imageUrl            : json['image_url']?.toString(),
      status              : json['status']?.toString() ?? 'selling',
      isFeatured          : json['is_featured'] == true || json['is_featured'] == 1,
      totalUnits          : json['total_units'] is int ? json['total_units'] : int.tryParse(json['total_units']?.toString() ?? '0') ?? 0,
      availableUnits      : json['available_units'] is int ? json['available_units'] : int.tryParse(json['available_units']?.toString() ?? '0') ?? 0,
      latitude            : json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude           : json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      startDate           : json['start_date']?.toString(),
      expectedCompletion  : json['expected_completion']?.toString(),
    );
  }

  String get statusLabel {
    const map = {
      'planning'    : 'تخطيط',
      'selling'     : 'طرح للبيع',
      'construction': 'قيد الإنشاء',
      'completed'   : 'مكتمل',
      'on_hold'     : 'موقوف مؤقتاً',
    };
    return map[status] ?? status;
  }
}
