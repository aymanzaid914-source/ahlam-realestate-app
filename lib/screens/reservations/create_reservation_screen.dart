// lib/screens/reservations/create_reservation_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../constants.dart';

class CreateReservationScreen extends StatefulWidget {
  final int propertyId;
  final String propertyTitle;

  const CreateReservationScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _contactPref  = 'phone';
  String _paymentPref  = '';
  final _notesCtrl     = TextEditingController();
  bool _loading        = false;
  String? _error;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final auth = context.read<AuthProvider>();
    try {
      final api = ApiService(token: auth.token);
      final resp = await api.post(AppConstants.reservationsEndpoint, {
        'property_id' : widget.propertyId,
        'contact_pref': _contactPref,
        'payment_pref': _paymentPref,
        'notes'       : _notesCtrl.text.trim(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('تم إرسال طلب الحجز', style: TextStyle(fontFamily: 'Cairo')),
          content: Text(
            resp.message.isNotEmpty ? resp.message : 'سيتواصل معك فريق المبيعات قريباً.',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/reservations');
              },
              child: const Text('عرض حجوزاتي'),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      setState(() { _error = 'حدث خطأ. حاول مجدداً.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب حجز')),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // بيانات العقار
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A3B5C).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1A3B5C).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.apartment, color: Color(0xFF1A3B5C), size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('الوحدة المطلوبة', style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Cairo')),
                            Text(
                              widget.propertyTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                fontFamily: 'Cairo',
                                color: Color(0xFF1A3B5C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // طريقة التواصل
                const Text('طريقة التواصل المفضلة', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Cairo', fontSize: 14)),
                const SizedBox(height: 10),
                Column(
                  children: [
                    {'value': 'phone', 'label': 'مكالمة هاتفية', 'icon': Icons.phone},
                    {'value': 'whatsapp', 'label': 'واتساب', 'icon': Icons.message},
                    {'value': 'email', 'label': 'بريد إلكتروني', 'icon': Icons.email_outlined},
                  ].map((opt) {
                    final val = opt['value'] as String;
                    final label = opt['label'] as String;
                    final icon = opt['icon'] as IconData;
                    return GestureDetector(
                      onTap: () => setState(() => _contactPref = val),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: _contactPref == val ? const Color(0xFF1A3B5C) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _contactPref == val ? const Color(0xFF1A3B5C) : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, size: 20, color: _contactPref == val ? Colors.white : Colors.grey),
                            const SizedBox(width: 12),
                            Text(
                              label,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                color: _contactPref == val ? Colors.white : Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            if (_contactPref == val)
                              const Icon(Icons.check_circle, color: Colors.white, size: 20),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // طريقة الدفع
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'طريقة الدفع المفضلة (اختياري)',
                    hintText: 'نقداً / تحويل بنكي / أقساط...',
                    prefixIcon: Icon(Icons.payment_outlined),
                  ),
                  onChanged: (v) => _paymentPref = v,
                ),
                const SizedBox(height: 16),

                // ملاحظات
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظات أو استفسارات (اختياري)',
                    prefixIcon: Icon(Icons.note_outlined),
                  ),
                ),
                const SizedBox(height: 24),

                // خطأ
                if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(_error!, style: TextStyle(color: Colors.red[700], fontFamily: 'Cairo')),
                  ),

                // زر الإرسال
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('إرسال طلب الحجز'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB59659),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _loading ? null : _submit,
                  ),
                ),

                if (_loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'سيتواصل معك فريق المبيعات بعد تلقي طلبك',
                    style: TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Cairo'),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
