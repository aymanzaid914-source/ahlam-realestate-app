// lib/models/customer.dart
class Customer {
  final int id;
  final String customerCode;
  final String fullName;
  final String? email;
  final String? phone;
  final String status;
  final String reviewStatus;

  Customer({
    required this.id,
    required this.customerCode,
    required this.fullName,
    this.email,
    this.phone,
    required this.status,
    required this.reviewStatus,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id           : json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      customerCode : json['customer_code']?.toString() ?? '',
      fullName     : json['full_name']?.toString() ?? '',
      email        : json['email']?.toString(),
      phone        : json['phone']?.toString(),
      status       : json['status']?.toString() ?? 'active',
      reviewStatus : json['review_status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toJson() => {
    'id'            : id,
    'customer_code' : customerCode,
    'full_name'     : fullName,
    'email'         : email,
    'phone'         : phone,
    'status'        : status,
    'review_status' : reviewStatus,
  };
}
