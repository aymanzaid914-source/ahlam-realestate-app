// lib/models/reservation.dart
class Reservation {
  final int id;
  final String reservationNo;
  final String reservationDate;
  final String? expiresAt;
  final double depositAmount;
  final String currency;
  final String status;
  final String? contactPref;
  final String? paymentPref;
  final String? notes;
  final String createdAt;
  final int propertyId;
  final String propertyTitle;
  final String? propertySlug;
  final String? unitNumber;
  final double? area;
  final double? price;
  final String? propertyCoverUrl;
  final String? projectName;
  final String? projectSlug;

  Reservation({
    required this.id,
    required this.reservationNo,
    required this.reservationDate,
    this.expiresAt,
    required this.depositAmount,
    required this.currency,
    required this.status,
    this.contactPref,
    this.paymentPref,
    this.notes,
    required this.createdAt,
    required this.propertyId,
    required this.propertyTitle,
    this.propertySlug,
    this.unitNumber,
    this.area,
    this.price,
    this.propertyCoverUrl,
    this.projectName,
    this.projectSlug,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id              : json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      reservationNo   : json['reservation_no']?.toString() ?? '',
      reservationDate : json['reservation_date']?.toString() ?? '',
      expiresAt       : json['expires_at']?.toString(),
      depositAmount   : json['deposit_amount'] != null ? double.tryParse(json['deposit_amount'].toString()) ?? 0.0 : 0.0,
      currency        : json['currency']?.toString() ?? 'USD',
      status          : json['status']?.toString() ?? 'pending',
      contactPref     : json['contact_pref']?.toString(),
      paymentPref     : json['payment_pref']?.toString(),
      notes           : json['notes']?.toString(),
      createdAt       : json['created_at']?.toString() ?? '',
      propertyId      : json['property_id'] is int ? json['property_id'] : int.parse(json['property_id'].toString()),
      propertyTitle   : json['property_title']?.toString() ?? '',
      propertySlug    : json['property_slug']?.toString(),
      unitNumber      : json['unit_number']?.toString(),
      area            : json['area'] != null ? double.tryParse(json['area'].toString()) : null,
      price           : json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      propertyCoverUrl: json['property_cover_url']?.toString(),
      projectName     : json['project_name']?.toString(),
      projectSlug     : json['project_slug']?.toString(),
    );
  }

  String get statusLabel {
    const map = {
      'pending'  : 'قيد الانتظار',
      'confirmed': 'مؤكد',
      'cancelled': 'ملغى',
      'expired'  : 'منتهي',
      'converted': 'تم البيع',
    };
    return map[status] ?? status;
  }
}
