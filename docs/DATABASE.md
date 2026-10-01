# دليل إعداد قاعدة البيانات - أحلام الشرق العقارية

## الجداول الموجودة (من الموقع الأصلي)

قاعدة البيانات تحتوي على 25+ جدول، أهمها:

| الجدول | الوصف |
|--------|-------|
| `properties` | العقارات (id, title, slug, price, status, bedrooms, ...) |
| `property_images` | صور العقارات |
| `property_plans` | مخططات العقارات |
| `projects` | المشاريع العقارية |
| `project_phases` | مراحل المشاريع |
| `customers` | العملاء (id, full_name, email, phone, password_hash, status) |
| `reservations` | الحجوزات |
| `payments` | المدفوعات |
| `contracts` | العقود |
| `notifications` | الإشعارات |
| `customer_favorites` | المفضلة |
| `contact_messages` | رسائل التواصل |

---

## الجدول الجديد (يُنشأ بواسطة Migration)

### `api_mobile_tokens`
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

**الحقول:**
- `token_hash`: SHA256 للـ token الخام (لا يُخزَّن Token الخام أبداً)
- `device_name`: اسم الجهاز (اختياري)
- `last_used_at`: آخر استخدام (يُحدَّث تلقائياً)
- `expires_at`: تاريخ انتهاء الصلاحية (NULL = لا ينتهي)

---

## استعادة قاعدة البيانات الأصلية

```bash
# من ملف u288834495_ahlam.sql
mysql -u DB_USER -p DB_NAME < u288834495_ahlam.sql

# ثم تشغيل migration الجدول الجديد
mysql -u DB_USER -p DB_NAME < database/migrations/2026_mobile_api_tokens.sql
```

---

## الحقول المستخدمة من التطبيق

### جدول `customers`
```sql
id, full_name, email, phone, password_hash, 
customer_code, status, national_id, created_at
```
> `status` القيم: `active`, `under_review`, `suspended`

### جدول `properties`
```sql
id, title, slug, description, price, status,
bedrooms, bathrooms, area, floor,
city, location, cover_image, property_type,
project_id, created_at
```
> `status` القيم: `available`, `reserved`, `sold`, `not_available`

### جدول `reservations`
```sql
id, customer_id, property_id, status,
contact_preference, payment_preference,
notes, serial_number, created_at
```
> `status` القيم: `pending`, `confirmed`, `cancelled`, `completed`

### جدول `notifications`
```sql
id, customer_id, title, body, type, 
is_read, related_id, created_at
```

---

## صلاحيات قاعدة البيانات المطلوبة

```sql
-- منح الصلاحيات لمستخدم التطبيق
GRANT SELECT, INSERT, UPDATE ON your_db.api_mobile_tokens TO 'db_user'@'localhost';
GRANT SELECT ON your_db.properties TO 'db_user'@'localhost';
GRANT SELECT ON your_db.projects TO 'db_user'@'localhost';
GRANT SELECT ON your_db.project_phases TO 'db_user'@'localhost';
GRANT SELECT, INSERT ON your_db.reservations TO 'db_user'@'localhost';
GRANT SELECT ON your_db.customers TO 'db_user'@'localhost';
GRANT UPDATE ON your_db.customers TO 'db_user'@'localhost';
GRANT SELECT, UPDATE ON your_db.notifications TO 'db_user'@'localhost';
GRANT SELECT, INSERT, DELETE ON your_db.customer_favorites TO 'db_user'@'localhost';
GRANT INSERT ON your_db.contact_messages TO 'db_user'@'localhost';
FLUSH PRIVILEGES;
```

---

## ملاحظة مهمة

> ⚠️ **قاعدة البيانات مشتركة** بين الموقع والتطبيق.  
> الموقع ولوحة الأدمن تعمل بشكل مستقل وغير معدّل.  
> التطبيق يقرأ ويكتب من نفس الجداول عبر API الجديد فقط.
