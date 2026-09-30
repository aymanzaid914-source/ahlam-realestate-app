// lib/screens/projects/project_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/projects_provider.dart';
import '../../models/project.dart';
import '../../widgets/common/property_card.dart';
import '../../services/api_service.dart';
import '../../constants.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String slug;
  const ProjectDetailScreen({super.key, required this.slug});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetail());
  }

  Future<void> _loadDetail() async {
    setState(() { _loading = true; _error = null; });
    final auth = context.read<AuthProvider>();
    final result = await context.read<ProjectsProvider>()
        .getProjectDetail(auth.token, slug: widget.slug);
    setState(() {
      _data    = result;
      _loading = false;
      _error   = result == null ? 'تعذّر تحميل تفاصيل المشروع' : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل المشروع')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل المشروع')),
        body: Center(child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadDetail, child: const Text('إعادة المحاولة')),
          ],
        )),
      );
    }

    final project = Project.fromJson(_data!['project'] as Map<String, dynamic>);
    final phases  = List<Map<String, dynamic>>.from(_data!['phases'] as List? ?? []);
    final stats   = _data!['stats'] as Map<String, dynamic>? ?? {};

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: const Color(0xFF1A3B5C),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(project.name, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14)),
              background: project.coverImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: project.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFF1A3B5C),
                        child: const Icon(Icons.location_city, size: 64, color: Colors.white),
                      ),
                    )
                  : Container(
                      color: const Color(0xFF1A3B5C),
                      child: const Icon(Icons.location_city, size: 80, color: Colors.white),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // معلومات المشروع
                  if (project.tagline != null)
                    Text(
                      project.tagline!,
                      style: const TextStyle(
                        color: Color(0xFFB59659),
                        fontSize: 15,
                        fontFamily: 'Cairo',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (project.location != null || project.city != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Color(0xFF1A3B5C)),
                        const SizedBox(width: 4),
                        Text(
                          '${project.city ?? ''} · ${project.location ?? ''}'.trim(),
                          style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo', fontSize: 13),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  // إحصائيات
                  Row(
                    children: [
                      Expanded(child: _StatCard(label: 'إجمالي الوحدات', value: '${stats['total'] ?? 0}', color: const Color(0xFF1A3B5C))),
                      const SizedBox(width: 8),
                      Expanded(child: _StatCard(label: 'المتاحة', value: '${stats['available'] ?? 0}', color: Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _StatCard(label: 'المحجوزة', value: '${stats['reserved'] ?? 0}', color: Colors.orange)),
                      const SizedBox(width: 8),
                      Expanded(child: _StatCard(label: 'المبيعة', value: '${stats['sold'] ?? 0}', color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // الوصف
                  if (project.description != null && project.description!.isNotEmpty) ...[
                    const Text('وصف المشروع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Color(0xFF1A3B5C))),
                    const SizedBox(height: 8),
                    Text(project.description!, style: const TextStyle(fontFamily: 'Cairo', fontSize: 14, height: 1.6, color: Colors.black87)),
                    const SizedBox(height: 20),
                  ],
                  // المراحل
                  if (phases.isNotEmpty) ...[
                    const Text('مراحل المشروع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: Color(0xFF1A3B5C))),
                    const SizedBox(height: 12),
                    ...phases.map((ph) => _PhaseCard(phase: ph)),
                  ],
                  const SizedBox(height: 20),
                  // زر الوحدات
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.apartment),
                      label: const Text('عرض وحدات هذا المشروع'),
                      onPressed: () => context.go('/properties?project_id=${project.id}'),
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
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color, fontFamily: 'Cairo')),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Cairo'), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PhaseCard extends StatelessWidget {
  final Map<String, dynamic> phase;
  const _PhaseCard({required this.phase});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1A3B5C).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.layers, color: Color(0xFF1A3B5C), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phase['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 14)),
                if (phase['status'] != null)
                  Text(
                    _phaseStatusLabel(phase['status'].toString()),
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Cairo'),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${phase['total_units'] ?? 0} وحدة', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
              Text('${phase['available_units'] ?? 0} متاحة', style: const TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  String _phaseStatusLabel(String status) {
    const map = {
      'planning': 'تخطيط',
      'selling': 'طرح للبيع',
      'construction': 'إنشاء',
      'completed': 'مكتملة',
      'on_hold': 'موقوفة',
    };
    return map[status] ?? status;
  }
}
