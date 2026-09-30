// lib/models/property.dart
class Property {
  final int id;
  final String propertyCode;
  final String? slug;
  final String title;
  final double? area;
  final double? landArea;
  final int? bedrooms;
  final int? bathrooms;
  final String? floor;
  final String? block;
  final String? unitNumber;
  final double price;
  final String currency;
  final String status;
  final String? coverImageUrl;
  final bool isFeatured;
  final String? typeName;
  final String? typeIcon;
  final String? projectName;
  final String? projectSlug;
  final String? phaseName;
  final double? latitude;
  final double? longitude;
  final String? description;

  Property({
    required this.id,
    required this.propertyCode,
    this.slug,
    required this.title,
    this.area,
    this.landArea,
    this.bedrooms,
    this.bathrooms,
    this.floor,
    this.block,
    this.unitNumber,
    required this.price,
    required this.currency,
    required this.status,
    this.coverImageUrl,
    this.isFeatured = false,
    this.typeName,
    this.typeIcon,
    this.projectName,
    this.projectSlug,
    this.phaseName,
    this.latitude,
    this.longitude,
    this.description,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id            : _toInt(json['id']),
      propertyCode  : json['property_code']?.toString() ?? '',
      slug          : json['slug']?.toString(),
      title         : json['title']?.toString() ?? '',
      area          : _toDouble(json['area']),
      landArea      : _toDouble(json['land_area']),
      bedrooms      : _toIntNullable(json['bedrooms']),
      bathrooms     : _toIntNullable(json['bathrooms']),
      floor         : json['floor']?.toString(),
      block         : json['block']?.toString(),
      unitNumber    : json['unit_number']?.toString(),
      price         : _toDouble(json['price']) ?? 0.0,
      currency      : json['currency']?.toString() ?? 'USD',
      status        : json['status']?.toString() ?? 'available',
      coverImageUrl : json['cover_image_url']?.toString(),
      isFeatured    : json['is_featured'] == true || json['is_featured'] == 1,
      typeName      : json['type_name']?.toString(),
      typeIcon      : json['type_icon']?.toString(),
      projectName   : json['project_name']?.toString(),
      projectSlug   : json['project_slug']?.toString(),
      phaseName     : json['phase_name']?.toString(),
      latitude      : _toDouble(json['latitude']),
      longitude     : _toDouble(json['longitude']),
      description   : json['description']?.toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static int? _toIntNullable(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }

  String get statusLabel {
    const map = {
      'available'  : 'متاح',
      'reserved'   : 'محجوز',
      'sold'       : 'مباع',
      'unavailable': 'غير متاح',
    };
    return map[status] ?? status;
  }

  String get formattedPrice {
    final val = price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$val $currency';
  }
}
