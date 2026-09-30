// lib/constants.dart
// ثوابت التطبيق

class AppConstants {
  // ===== API Base URL =====
  // عدّل هذا الرابط ليشير لموقعك الحقيقي
  static const String baseUrl = 'https://ahlamalsharq.com';
  static const String apiBase = '$baseUrl/mobile/v1';

  // API Endpoints
  static const String loginEndpoint       = '$apiBase/auth/login.php';
  static const String registerEndpoint    = '$apiBase/auth/register.php';
  static const String logoutEndpoint      = '$apiBase/auth/logout.php';
  static const String propertiesEndpoint  = '$apiBase/properties/index.php';
  static const String propertyDetailEndpoint = '$apiBase/properties/detail.php';
  static const String favoritesEndpoint   = '$apiBase/properties/favorites.php';
  static const String projectsEndpoint    = '$apiBase/projects/index.php';
  static const String projectDetailEndpoint = '$apiBase/projects/detail.php';
  static const String reservationsEndpoint = '$apiBase/reservations/index.php';
  static const String profileEndpoint     = '$apiBase/profile/index.php';
  static const String notificationsEndpoint = '$apiBase/notifications/index.php';
  static const String pagesEndpoint       = '$apiBase/pages/index.php';
  static const String contactEndpoint     = '$apiBase/pages/contact.php';

  // Colors
  static const int primaryColorValue   = 0xFF1A3B5C;
  static const int secondaryColorValue = 0xFFB59659;
  static const int bgColorValue        = 0xFFF5F5F5;

  // SharedPreferences keys
  static const String tokenKey     = 'auth_token';
  static const String customerKey  = 'customer_data';
  static const String expiresKey   = 'token_expires';

  // Pagination
  static const int pageSize = 15;

  // App Info
  static const String appName     = 'أحلام الشرق العقارية';
  static const String companyName = 'شركة أحلام الشرق للتطوير العقاري والاستثمار';
  static const String appVersion  = '1.0.0';

  // Status labels
  static const Map<String, String> propertyStatus = {
    'available'   : 'متاح',
    'reserved'    : 'محجوز',
    'sold'        : 'مباع',
    'unavailable' : 'غير متاح',
  };

  static const Map<String, String> reservationStatus = {
    'pending'  : 'قيد الانتظار',
    'confirmed': 'مؤكد',
    'cancelled': 'ملغى',
    'expired'  : 'منتهي',
    'converted': 'تم البيع',
  };

  static const Map<String, String> projectStatus = {
    'planning'    : 'تخطيط',
    'selling'     : 'طرح للبيع',
    'construction': 'قيد الإنشاء',
    'completed'   : 'مكتمل',
    'on_hold'     : 'موقوف مؤقتاً',
  };
}
