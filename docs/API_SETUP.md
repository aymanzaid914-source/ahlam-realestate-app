# دليل إعداد REST API - أحلام الشرق العقارية

## المتطلبات

- PHP 7.4+ مع PDO و MySQLi
- MySQL 5.7+ / MariaDB 10.3+
- HTTPS (إلزامي للإنتاج)
- Apache مع mod_rewrite و mod_headers

---

## 1. رفع ملفات API على الخادم

ارفع مجلد `mobile/` داخل `public_html/`:

```
public_html/
└── mobile/
    ├── bootstrap.php        ← منطق المصادقة والردود
    ├── .htaccess            ← إعدادات CORS
    └── v1/
        ├── auth/
        │   ├── login.php       POST  تسجيل دخول
        │   ├── register.php    POST  تسجيل عميل جديد
        │   └── logout.php      POST  تسجيل خروج
        ├── properties/
        │   ├── index.php       GET   قائمة العقارات
        │   ├── detail.php      GET   تفاصيل عقار
        │   └── favorites.php   GET/POST المفضلة
        ├── projects/
        │   ├── index.php       GET   قائمة المشاريع
        │   └── detail.php      GET   تفاصيل مشروع
        ├── reservations/
        │   └── index.php       GET/POST الحجوزات
        ├── profile/
        │   └── index.php       GET/PUT  الملف الشخصي
        ├── notifications/
        │   └── index.php       GET/POST الإشعارات
        └── pages/
            ├── index.php       GET   صفحة ثابتة
            └── contact.php     POST  نموذج تواصل
```

---

## 2. تشغيل Migration قاعدة البيانات

شغّل ملف `database/migrations/2026_mobile_api_tokens.sql` لإنشاء جدول التوكنات:

```sql
CREATE TABLE IF NOT EXISTS `api_mobile_tokens` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id`  INT UNSIGNED NOT NULL,
  `token_hash`   VARCHAR(64)  NOT NULL COMMENT 'SHA256 of raw token',
  `device_name`  VARCHAR(255) DEFAULT NULL,
  `last_used_at` DATETIME     DEFAULT NULL,
  `created_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at`   DATETIME     DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_token_hash` (`token_hash`),
  KEY `idx_customer_id` (`customer_id`),
  CONSTRAINT `fk_mobile_tokens_customer`
    FOREIGN KEY (`customer_id`) REFERENCES `customers`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

من phpMyAdmin أو Terminal:
```bash
mysql -u DB_USER -p DB_NAME < database/migrations/2026_mobile_api_tokens.sql
```

---

## 3. إعداد config.php

تأكد من صحة هذه القيم في `config/config.php`:

```php
define('DB_HOST', 'localhost');
define('DB_USER', 'your_db_user');
define('DB_PASS', 'your_db_password');
define('DB_NAME', 'your_db_name');
define('APP_URL', 'https://your-domain.com');  // بدون / في النهاية
```

---

## 4. التحقق من .htaccess

ملف `mobile/.htaccess` يجب أن يحتوي:

```apache
Options -Indexes
Header always set Access-Control-Allow-Origin "*"
Header always set Access-Control-Allow-Headers "Content-Type, Authorization"
Header always set Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"

RewriteEngine On
RewriteCond %{REQUEST_METHOD} OPTIONS
RewriteRule ^(.*)$ $1 [R=200,L]
```

---

## 5. جدول نقاط النهاية (Endpoints)

### المصادقة
| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| POST | `/mobile/v1/auth/login.php` | ❌ | تسجيل دخول |
| POST | `/mobile/v1/auth/register.php` | ❌ | تسجيل جديد |
| POST | `/mobile/v1/auth/logout.php` | ✅ | تسجيل خروج |

### العقارات
| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/mobile/v1/properties/index.php` | ❌ | قائمة (search, status, min_price, max_price, bedrooms, page) |
| GET | `/mobile/v1/properties/detail.php?slug=xxx` | ❌ | تفاصيل |
| GET | `/mobile/v1/properties/favorites.php` | ✅ | قائمة المفضلة |
| POST | `/mobile/v1/properties/favorites.php` | ✅ | `{"property_id":1}` toggle |

### المشاريع
| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/mobile/v1/projects/index.php` | ❌ | قائمة المشاريع |
| GET | `/mobile/v1/projects/detail.php?slug=xxx` | ❌ | تفاصيل + مراحل + إحصائيات |

### الحجوزات
| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/mobile/v1/reservations/index.php` | ✅ | حجوزات العميل |
| POST | `/mobile/v1/reservations/index.php` | ✅ | `{"property_id":1, "notes":"..."}` |

### الملف الشخصي
| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/mobile/v1/profile/index.php` | ✅ | بيانات + إحصائيات |
| PUT | `/mobile/v1/profile/index.php` | ✅ | تحديث بيانات/كلمة مرور |

### الإشعارات
| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/mobile/v1/notifications/index.php` | ✅ | الإشعارات + عدد غير المقروء |
| POST | `/mobile/v1/notifications/index.php` | ✅ | `{"action":"mark_read","id":1}` |

---

## 6. نظام المصادقة

يستخدم التطبيق Token مستقل تماماً عن جلسة الأدمن.

**إرسال Token مع كل طلب محمي:**
```http
Authorization: Bearer {raw_token}
```

**آلية العمل:**
1. `login.php` يولّد token عشوائي → يحسب `hash('sha256', $token)` → يحفظه في `api_mobile_tokens`
2. في كل طلب: يستخرج Token من Header → يحسب hash → يبحث في الجدول
3. عند logout: يحذف السجل من الجدول

---

## 7. تنسيق الردود

جميع الردود بتنسيق JSON موحّد:
```json
{
  "success": true,
  "message": "نص الرسالة",
  "data": { ... },
  "errors": []
}
```

---

## 8. استكشاف الأخطاء الشائعة

| المشكلة | السبب | الحل |
|---------|-------|------|
| 401 Unauthorized | Token منتهي أو خاطئ | أعد تسجيل الدخول |
| 404 Not Found | الملف غير مرفوع | تحقق من رفع مجلد `mobile/` |
| 500 Server Error | خطأ PHP | راجع error_log في الخادم |
| CORS Error | إعدادات Apache | تأكد من تفعيل mod_headers وصحة .htaccess |
| Token لا يعمل | خطأ في config.php | تحقق من بيانات قاعدة البيانات |
