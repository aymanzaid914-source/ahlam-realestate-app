// lib/screens/reservations/reservations_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/reservation.dart';
import '../../constants.dart';
import '../../widgets/common/error_widget_custom.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<Reservation> _reservations = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      setState(() { _loading = false; });
      return;
    }
    try {
      final api = ApiService(token: auth.token);
      final resp = await api.get(AppConstants.reservationsEndpoint);
      final data = resp.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      setState(() {
        _reservations = items.map((e) => Reservation.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      setState(() { _error = 'حدث خطأ في تحميل الحجوزات'; _loading = false; });
    }
  }

  Color _statusColor(String status) {
    return switch (status) {
      'pending'   => Colors.orange,
      'confirmed' => Colors.green,
      'cancelled' => Colors.red,
      'expired'   => Colors.grey,
      'converted' => const Color(0xFF1A3B5C),
      _           => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('حجوزاتي')),
        body: EmptyWidgetCustom(
          message: 'سجّل دخولك لعرض حجوزاتك',
          icon: Icons.calendar_today_outlined,
          action: ElevatedButton(
            onPressed: () => context.push('/login'),
            child: const Text('تسجيل الدخول'),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('حجوزاتي')),
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _load,
        child: Builder(builder: (ctx) {
          if (_loading) return const Center(child: CircularProgressIndicator());
          if (_error != null) return ErrorWidgetCustom(message: _error!, onRetry: _load);
          if (_reservations.isEmpty) {
            return EmptyWidgetCustom(
              message: 'لا توجد حجوزات بعد',
              icon: Icons.calendar_today_outlined,
              action: ElevatedButton(
                onPressed: () => context.go('/properties'),
                child: const Text('تصفح العقارات'),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _reservations.length,
            itemBuilder: (_, i) {
              final r = _reservations[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // صورة
                    if (r.propertyCoverUrl != null && r.propertyCoverUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: CachedNetworkImage(
                          imageUrl: r.propertyCoverUrl!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            height: 120,
                            color: const Color(0xFFE8EFF5),
                            child: const Icon(Icons.apartment, size: 40, color: Color(0xFF1A3B5C)),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  r.propertyTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _statusColor(r.status).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: _statusColor(r.status).withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  r.statusLabel,
                                  style: TextStyle(
                                    color: _statusColor(r.status),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (r.projectName != null)
                            Text(r.projectName!, style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo', fontSize: 12)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.tag, size: 13, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(r.reservationNo, style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo', fontSize: 11)),
                              const Spacer(),
                              const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(r.reservationDate, style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo', fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
