// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  Future<void> _loadProfile() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) return;
    try {
      final api = ApiService(token: auth.token);
      final resp = await api.get(AppConstants.profileEndpoint);
      if (!mounted) return;
      setState(() {
        _profile = resp.data as Map<String, dynamic>?;
      });
    } catch (_) {
      // silently ignore profile load errors
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('حسابي')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_outline, size: 72, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('سجّل دخولك للوصول لحسابك', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.push('/login'),
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    final customer = auth.customer;
    final stats = _profile?['stats'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A3B5C),
            title: const Text('حسابي'),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A3B5C), Color(0xFF2C5282)],
                  ),
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFFB59659),
                          child: Text(
                            customer?.fullName.isNotEmpty == true
                                ? customer!.fullName[0].toUpperCase()
                                : '؟',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          customer?.fullName ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          customer?.customerCode ?? '',
                          style: const TextStyle(
                            color: Color(0xFFB59659),
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // إحصائيات
                  Row(
                    children: [
                      _StatTile(
                        icon: Icons.calendar_today,
                        label: 'حجوزاتي',
                        value: '${stats['reservations'] ?? 0}',
                        onTap: () => context.go('/reservations'),
                      ),
                      const SizedBox(width: 12),
                      _StatTile(
                        icon: Icons.favorite_border,
                        label: 'المفضلة',
                        value: '${stats['favorites'] ?? 0}',
                        onTap: () => context.go('/properties'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // بيانات الحساب
                  _SectionHeader(title: 'بيانات الحساب'),
                  _InfoTile(icon: Icons.person_outline, label: 'الاسم', value: customer?.fullName ?? ''),
                  _InfoTile(icon: Icons.phone_outlined, label: 'الهاتف', value: customer?.phone ?? 'غير محدد'),
                  _InfoTile(icon: Icons.email_outlined, label: 'البريد', value: customer?.email ?? 'غير محدد'),
                  const SizedBox(height: 20),

                  // روابط سريعة
                  _SectionHeader(title: 'الخدمات'),
                  _MenuTile(icon: Icons.calendar_today_outlined, label: 'حجوزاتي', onTap: () => context.go('/reservations')),
                  _MenuTile(icon: Icons.notifications_outlined, label: 'الإشعارات', onTap: () => context.push('/notifications')),
                  _MenuTile(icon: Icons.phone_outlined, label: 'تواصل معنا', onTap: () => context.push('/contact')),
                  _MenuTile(icon: Icons.privacy_tip_outlined, label: 'سياسة الخصوصية', onTap: () => context.push('/page/privacy-policy')),
                  _MenuTile(icon: Icons.article_outlined, label: 'الشروط والأحكام', onTap: () => context.push('/page/terms')),
                  const SizedBox(height: 20),

                  // تسجيل خروج
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.red, fontFamily: 'Cairo')),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _confirmLogout(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '${AppConstants.appName} v${AppConstants.appVersion}',
                      style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: 'Cairo'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();
              if (mounted) {
                // ignore: use_build_context_synchronously
                context.go('/login');
              }
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _StatTile({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF1A3B5C), size: 28),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Color(0xFF1A3B5C))),
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Cairo')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Color(0xFF1A3B5C))),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo', fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14), textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1A3B5C)),
        title: Text(label, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14)),
        trailing: const Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
