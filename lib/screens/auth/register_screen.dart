// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl    = TextEditingController();
  final _cpwCtrl   = TextEditingController();
  bool _showPw     = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    _cpwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      fullName : _nameCtrl.text.trim(),
      phone    : _phoneCtrl.text.trim(),
      email    : _emailCtrl.text.trim(),
      password : _pwCtrl.text,
    );
    if (!mounted) return;
    if (ok) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('تم التسجيل بنجاح', style: TextStyle(fontFamily: 'Cairo')),
          content: const Text(
            'تم إنشاء حسابك. سيتم مراجعة طلبك من قِبل فريق أحلام الشرق وسيتم إشعارك بعد التفعيل.',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/login');
              },
              child: const Text('حسناً'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'حدث خطأ أثناء التسجيل'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'انضم إلى أحلام الشرق العقارية',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: Color(0xFF1A3B5C),
                  ),
                ),
                const Text(
                  'أنشئ حسابك للبدء في تصفح وحجز العقارات',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 28),
                // الاسم
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الكامل *',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().length < 3) ? 'الاسم يجب أن يكون 3 أحرف على الأقل' : null,
                ),
                const SizedBox(height: 16),
                // الهاتف
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف *',
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: '7XXXXXXXX',
                  ),
                  validator: (v) => (v == null || v.trim().length < 7) ? 'رقم الهاتف غير صحيح' : null,
                ),
                const SizedBox(height: 16),
                // البريد
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني (اختياري)',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v != null && v.isNotEmpty) {
                      if (!v.contains('@')) return 'البريد الإلكتروني غير صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // كلمة المرور
                TextFormField(
                  controller: _pwCtrl,
                  obscureText: !_showPw,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور *',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_showPw ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _showPw = !_showPw),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل' : null,
                ),
                const SizedBox(height: 16),
                // تأكيد
                TextFormField(
                  controller: _cpwCtrl,
                  obscureText: !_showPw,
                  decoration: const InputDecoration(
                    labelText: 'تأكيد كلمة المرور *',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) => v != _pwCtrl.text ? 'كلمتا المرور غير متطابقتين' : null,
                ),
                const SizedBox(height: 32),
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => ElevatedButton(
                    onPressed: auth.isLoading ? null : _submit,
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 22, width: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('إنشاء الحساب'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('لديك حساب بالفعل؟ ', style: TextStyle(fontFamily: 'Cairo')),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('تسجيل الدخول', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
