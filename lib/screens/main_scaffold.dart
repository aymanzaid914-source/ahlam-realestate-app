// lib/screens/main_scaffold.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notifications_provider.dart';

class MainScaffold extends StatefulWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  static const _tabs = [
    '/home',
    '/properties',
    '/projects',
    '/reservations',
    '/profile',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<NotificationsProvider>().load(auth.token);
    });
  }

  void _onTap(int index) {
    setState(() => _selectedIndex = index);
    context.go(_tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Consumer<NotificationsProvider>(
        builder: (ctx, notifs, _) {
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onTap,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.apartment_outlined),
                activeIcon: Icon(Icons.apartment),
                label: 'العقارات',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.location_city_outlined),
                activeIcon: Icon(Icons.location_city),
                label: 'المشاريع',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'حجوزاتي',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'حسابي',
              ),
            ],
          );
        },
      ),
    );
  }
}
