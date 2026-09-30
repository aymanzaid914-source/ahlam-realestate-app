// lib/screens/pages/contact_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../constants.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _msgCtrl    = TextEditingController();
  bool _loading     = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // تعبئة تلقائية من بيانات الحساب
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customer = context.read<AuthProvider>().customer;
      if (customer != null) {
        _nameCtrl.text  = customer.fullName;
        _phoneCtrl.text = customer.phone ?? '';
        _emailCtrl.text = customer.email ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final api = ApiService();
      final resp = await api.post(AppConstants.contactEndpoint, {
        'name'   : _nameCtrl.text.trim(),
        'phone'  : _phoneCtrl.text.trim(),
        'email'  : _emailCtrl.text.trim(),
        'subject': _subjectCtrl.text.trim(),
        'message': _msgCtrl.text.trim(),
      });

      if (!mounted) return;
      _msgCtrl.clear();
      _subjectCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp.message.isNotEmpty ? resp.message : 'تم إرسال رسالتك بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() => _loading = false);
    } on ApiException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      setState(() { _error = 'حدث خطأ. حاول مجدداً.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تواصل معنا')),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // معلومات الشركة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A3B5C), Color(0xFF2C5282)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.domain, color: Colors.white, size: 36),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.companyName,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'فريقنا جاهز للرد على استفساراتك',
                            style: TextStyle(color: Color(0xFFB59659), fontFamily: 'Cairo', fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // النموذج
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'الاسم *', prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني', prefixIcon: Icon(Icons.email_outlined)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _subjectCtrl,
                decoration: const InputDecoration(labelText: 'الموضوع', prefixIcon: Icon(Icons.subject)),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _msgCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'الرسالة *',
                  prefixIcon: Icon(Icons.message_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (v) => (v == null || v.trim().length < 5) ? 'الرسالة مطلوبة' : null,
              ),
              const SizedBox(height: 24),

              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!, style: TextStyle(color: Colors.red[700], fontFamily: 'Cairo')),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('إرسال الرسالة'),
                  onPressed: _loading ? null : _submit,
                ),
              ),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
