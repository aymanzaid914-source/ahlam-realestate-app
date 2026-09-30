// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6)));
    _scale = Tween<double>(begin: 0.7, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _ctrl.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.status == AuthStatus.unknown) {
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        return auth.status == AuthStatus.unknown;
      });
    }
    if (!mounted) return;
    if (auth.isAuthenticated) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3B5C),
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.domain,
                      size: 60,
                      color: Color(0xFF1A3B5C),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'أحلام الشرق العقارية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'للتطوير العقاري والاستثمار',
                    style: TextStyle(
                      color: Color(0xFFB59659),
                      fontSize: 14,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 48),
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      color: Color(0xFFB59659),
                      strokeWidth: 2.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
