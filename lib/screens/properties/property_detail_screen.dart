// lib/screens/properties/property_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/properties_provider.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../constants.dart';

class PropertyDetailScreen extends StatefulWidget {
  final String slug;
  const PropertyDetailScreen({super.key, required this.slug});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  Property? _property;
  List<Map<String, dynamic>> _images = [];
  bool _isFavorite = false;
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
    try {
      final api = ApiService(token: auth.token);
      final resp = await api.get(
        AppConstants.propertyDetailEndpoint,
        queryParams: {'slug': widget.slug},
      );
      final data = resp.data as Map<String, dynamic>;
      setState(() {
        _property   = Property.fromJson(data['property'] as Map<String, dynamic>);
        _images     = List<Map<String, dynamic>>.from(data['images'] as List? ?? []);
        _isFavorite = data['is_favorite'] as bool? ?? false;
        _loading    = false;
      });
    } on ApiException catch (e) {
      setState(() { _error = e.message; _loading = false; });
    } catch (_) {
      setState(() { _error = 'حدث خطأ في تحميل التفاصيل'; _loading = false; });
    }
  }

  Future<void> _toggleFavorite() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سجّل دخولك أولاً لإضافة للمفضلة')),
      );
      return;
    }
    final result = await context.read<PropertiesProvider>()
        .toggleFavorite(auth.token!, _property!.id);
    setState(() => _isFavorite = result);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل العقار')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل العقار')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(fontFamily: 'Cairo')),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadDetail, child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }

    final p = _property!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // صور العقار
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A3B5C),
            actions: [
              IconButton(
                icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _images.isNotEmpty
                  ? PageView.builder(
                      itemCount: _images.length,
                      itemBuilder: (_, i) {
                        final url = _images[i]['url']?.toString() ?? '';
                        return CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFF1A3B5C),
                            child: const Icon(Icons.apartment, size: 64, color: Colors.white),
                          ),
                        );
                      },
                    )
                  : (p.coverImageUrl != null
                      ? CachedNetworkImage(imageUrl: p.coverImageUrl!, fit: BoxFit.cover)
                      : Container(
                          color: const Color(0xFF1A3B5C),
                          child: const Icon(Icons.apartment, size: 80, color: Colors.white),
                        )),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان وحالة
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: p.status == 'available' ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          p.statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // الموقع
                  if (p.projectName != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF1A3B5C)),
                        const SizedBox(width: 4),
                        Text(
                          p.projectName!,
                          style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo', fontSize: 13),
                        ),
                        if (p.phaseName != null)
                          Text(
                            ' · ${p.phaseName}',
                            style: const TextStyle(color: Colors.grey, fontFamily: 'Cairo', fontSize: 13),
                          ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  // السعر
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A3B5C), Color(0xFF2C5282)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'السعر',
                          style: TextStyle(color: Colors.white70, fontFamily: 'Cairo', fontSize: 14),
                        ),
                        Text(
                          p.formattedPrice,
                          style: const TextStyle(
                            color: Color(0xFFB59659),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // التفاصيل
                  const Text(
                    'تفاصيل الوحدة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: Color(0xFF1A3B5C),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (p.area != null)
                        _DetailChip(icon: Icons.square_foot, label: 'المساحة', value: '${p.area!.toStringAsFixed(0)} م²'),
                      if (p.landArea != null && p.landArea! > 0)
                        _DetailChip(icon: Icons.terrain, label: 'مساحة الأرض', value: '${p.landArea!.toStringAsFixed(0)} م²'),
                      if (p.bedrooms != null && p.bedrooms! > 0)
                        _DetailChip(icon: Icons.bed_outlined, label: 'الغرف', value: '${p.bedrooms}'),
                      if (p.bathrooms != null && p.bathrooms! > 0)
                        _DetailChip(icon: Icons.bathroom_outlined, label: 'الحمامات', value: '${p.bathrooms}'),
                      if (p.floor != null && p.floor!.isNotEmpty)
                        _DetailChip(icon: Icons.layers_outlined, label: 'الطابق', value: p.floor!),
                      if (p.block != null && p.block!.isNotEmpty)
                        _DetailChip(icon: Icons.grid_view_outlined, label: 'البلوك', value: p.block!),
                      if (p.unitNumber != null && p.unitNumber!.isNotEmpty)
                        _DetailChip(icon: Icons.tag, label: 'رقم الوحدة', value: p.unitNumber!),
                      if (p.typeName != null)
                        _DetailChip(icon: Icons.category_outlined, label: 'نوع العقار', value: p.typeName!),
                    ],
                  ),
                  // الوصف
                  if (p.description != null && p.description!.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'وصف العقار',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                        color: Color(0xFF1A3B5C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.description!,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
      // زر الحجز
      bottomNavigationBar: p.status == 'available'
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('احجز الآن'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB59659),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    final auth = context.read<AuthProvider>();
                    if (!auth.isAuthenticated) {
                      context.push('/login');
                      return;
                    }
                    context.push('/reserve/${p.id}?title=${Uri.encodeComponent(p.title)}');
                  },
                ),
              ),
            )
          : null,
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailChip({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (MediaQuery.of(context).size.width - 56) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1A3B5C)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Cairo')),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
