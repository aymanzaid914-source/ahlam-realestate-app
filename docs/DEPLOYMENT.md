# دليل نشر التطبيق - أحلام الشرق العقارية

## ملفات التسليم

| الملف | الحجم | الاستخدام |
|-------|-------|-----------|
| `app-debug.apk` | ~147 MB | تثبيت مباشر على الجهاز للاختبار |
| `app-release.aab` | ~42 MB | رفع على Google Play Store |

---

## التثبيت المباشر (APK Debug)

### على الجهاز:
1. انسخ `app-debug.apk` إلى الجهاز
2. افتح الملف لتثبيته (قد تحتاج تفعيل "مصادر غير معروفة")
3. أو استخدم ADB:
```bash
adb install app-debug.apk
```

### متطلبات الجهاز:
- Android 5.0+ (API 21+)
- مساحة تخزين: 200 MB على الأقل

---

## إعداد URL الـ API في التطبيق

قبل البناء، عدّل ملف `lib/constants.dart`:

```dart
class AppConstants {
  // غيّر هذا إلى رابط الموقع الفعلي
  static const String baseUrl = 'https://your-domain.com';
  static const String apiBase = '$baseUrl/mobile/v1';
  // ...
}
```

ثم أعد البناء:
```bash
flutter build apk --debug          # للاختبار
flutter build appbundle --release  # لـ Google Play
```

---

## الرفع على Google Play Store (AAB)

### متطلبات الرفع:
1. حساب Google Play Developer ($25 رسوم لمرة واحدة)
2. ملف `app-release.aab` (موقّع بـ keystore المضمّن)
3. لقطات شاشة (عرض 1080px × ارتفاع 1920px على الأقل)
4. وصف التطبيق بالعربية والإنجليزية

### معلومات التطبيق:
- **اسم الباكيج**: `com.ahlamalsharq.realestate`
- **الإصدار**: 1.0.0 (build 1)
- **الحد الأدنى للـ Android**: 5.0 (API 21)

### الـ Keystore المستخدم:
- **الملف**: `android/release-key.jks`
- **الـ Alias**: `release`
- ⚠️ **احتفظ بملف الـ Keystore وكلمة المرور** - لا يمكن تحديث التطبيق بدونها

---

## إعداد الخادم (Server Setup)

### 1. رفع ملفات PHP
```bash
# من جهازك المحلي إلى الخادم
scp -r mobile/ user@your-server:/var/www/html/public_html/
```

### 2. تشغيل Migration
```bash
mysql -u db_user -p db_name < database/migrations/2026_mobile_api_tokens.sql
```

### 3. التحقق من API
اختبر الـ API بعد الرفع:
```bash
curl https://your-domain.com/mobile/v1/auth/login.php \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"123456"}'
```

---

## الإعدادات المطلوبة في الخادم

```apache
# في .htaccess الرئيسي أو httpd.conf
<Directory "/var/www/html/public_html/mobile">
    AllowOverride All
    Options -Indexes
</Directory>
```

```
# PHP Settings (php.ini)
display_errors = Off
log_errors = On
error_log = /var/log/php_errors.log
max_execution_time = 30
memory_limit = 256M
```

---

## اختبار الاتصال

بعد تغيير `baseUrl` في `constants.dart` وبناء التطبيق:

1. افتح التطبيق
2. اذهب إلى شاشة تسجيل الدخول
3. أدخل بيانات عميل موجود في قاعدة البيانات
4. تأكد من ظهور بيانات العقارات في الصفحة الرئيسية

---

## البنية التقنية

```
[Flutter App Android] 
    ↓ HTTPS REST API
[mobile/v1/ PHP Endpoints]
    ↓ PDO Prepared Statements  
[MySQL Database - نفس قاعدة بيانات الموقع]
    ↑
[لوحة تحكم الأدمن PHP - بدون تعديل]
```

**مبدأ العمل:** أي تغيير من التطبيق (حجز، تسجيل، إشعار) يظهر فوراً في لوحة الأدمن، وأي تغيير من الأدمن (إضافة عقار، تغيير حالة حجز) يظهر فوراً في التطبيق.
