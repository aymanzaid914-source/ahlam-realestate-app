// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl  = TextEditingController();
  final _pwCtrl  = TextEditingController();
  bool _showPw   = false;

  @override
  void dispose() {
    _idCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_idCtrl.text.trim(), _pwCtrl.text);
    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'بيانات الدخول غير صحيحة'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A3B5C), Color(0xFF2C5282)],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.domain, size: 44, color: Color(0xFF1A3B5C)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'أحلام الشرق العقارية',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'تسجيل الدخول إلى حسابك',
                      style: TextStyle(
                        color: Color(0xFFB59659),
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      // بريد / هاتف
                      TextFormField(
                        controller: _idCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني أو رقم الهاتف',
                          prefixIcon: Icon(Icons.person_outline),
                          hintText: 'example@email.com أو 7XXXXXXXX',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'هذا الحقل مطلوب';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // كلمة المرور
                      TextFormField(
                        controller: _pwCtrl,
                        obscureText: !_showPw,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(_showPw ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _showPw = !_showPw),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'كلمة المرور مطلوبة';
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      // زر الدخول
                      Consumer<AuthProvider>(
                        builder: (_, auth, __) => ElevatedButton(
                          onPressed: auth.isLoading ? null : _submit,
                          child: auth.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text('تسجيل الدخول'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // رابط التسجيل
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('ليس لديك حساب؟ ', style: TextStyle(fontFamily: 'Cairo')),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            child: const Text(
                              'إنشاء حساب جديد',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
