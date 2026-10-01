// lib/screens/properties/properties_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/properties_provider.dart';
import '../../widgets/common/property_card.dart';
import '../../widgets/common/error_widget_custom.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  final _searchCtrl   = TextEditingController();
  final _scrollCtrl   = ScrollController();
  String _searchQuery = '';
  String _statusFilter = 'available';
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: true));
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _load({bool reset = false}) {
    final auth = context.read<AuthProvider>();
    final filters = <String, String>{};
    if (_searchQuery.isNotEmpty) filters['search'] = _searchQuery;
    if (_statusFilter.isNotEmpty) filters['status'] = _statusFilter;
    context.read<PropertiesProvider>().loadProperties(
      token: auth.token,
      filters: filters,
      reset: reset,
    );
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 100) {
      final token = context.read<AuthProvider>().token;
      context.read<PropertiesProvider>().loadMore(token);
    }
  }

  void _applySearch() {
    setState(() => _searchQuery = _searchCtrl.text.trim());
    _load(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'ابحث عن عقار...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _applySearch(),
              )
            : const Text('العقارات'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchCtrl.clear();
                  _searchQuery = '';
                  _load(reset: true);
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // فلاتر الحالة
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _StatusChip(
                    label: 'المتاحة',
                    value: 'available',
                    selected: _statusFilter == 'available',
                    onTap: () {
                      setState(() => _statusFilter = 'available');
                      _load(reset: true);
                    },
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'الكل',
                    value: '',
                    selected: _statusFilter == '',
                    onTap: () {
                      setState(() => _statusFilter = '');
                      _load(reset: true);
                    },
                  ),
                  const SizedBox(width: 8),
                  _StatusChip(
                    label: 'المحجوزة',
                    value: 'reserved',
                    selected: _statusFilter == 'reserved',
                    onTap: () {
                      setState(() => _statusFilter = 'reserved');
                      _load(reset: true);
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<PropertiesProvider>(
              builder: (_, props, __) {
                if (props.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (props.error != null) {
                  return ErrorWidgetCustom(
                    message: props.error!,
                    onRetry: () => _load(reset: true),
                  );
                }
                if (props.properties.isEmpty) {
                  return EmptyWidgetCustom(
                    message: 'لا توجد عقارات تطابق معايير البحث',
                    icon: Icons.apartment_outlined,
                  );
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: props.properties.length + (props.isLoadingMore ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i >= props.properties.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final p = props.properties[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PropertyCard(
                        property: p,
                        onTap: () {
                          if (p.slug != null) context.push('/properties/${p.slug}');
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FiltersSheet(
        onApply: (filters) {
          Navigator.pop(ctx);
          final auth = context.read<AuthProvider>();
          context.read<PropertiesProvider>().loadProperties(
            token: auth.token,
            filters: filters,
            reset: true,
          );
        },
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1A3B5C) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF1A3B5C) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[700],
            fontSize: 13,
            fontFamily: 'Cairo',
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  final Function(Map<String, String>) onApply;
  const _FiltersSheet({required this.onApply});

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  double _minPrice = 0;
  double _maxPrice = 500000;
  int? _bedrooms;
  final String _type = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تصفية النتائج',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: Color(0xFF1A3B5C),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text('نطاق السعر (USD)', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
            RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: 0,
              max: 500000,
              divisions: 50,
              activeColor: const Color(0xFF1A3B5C),
              labels: RangeLabels(
                '\$${_minPrice.toStringAsFixed(0)}',
                '\$${_maxPrice.toStringAsFixed(0)}',
              ),
              onChanged: (v) => setState(() {
                _minPrice = v.start;
                _maxPrice = v.end;
              }),
            ),
            const SizedBox(height: 12),
            const Text('عدد الغرف', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [null, 1, 2, 3, 4].map((b) {
                final label = b == null ? 'الكل' : '$b غرف';
                final selected = _bedrooms == b;
                return GestureDetector(
                  onTap: () => setState(() => _bedrooms = b),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF1A3B5C) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: selected ? const Color(0xFF1A3B5C) : Colors.grey[300]!),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontFamily: 'Cairo',
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final filters = <String, String>{};
                  if (_minPrice > 0) filters['min_price'] = _minPrice.toStringAsFixed(0);
                  if (_maxPrice < 500000) filters['max_price'] = _maxPrice.toStringAsFixed(0);
                  if (_bedrooms != null) filters['bedrooms'] = '$_bedrooms';
                  if (_type.isNotEmpty) filters['type'] = _type;
                  widget.onApply(filters);
                },
                child: const Text('تطبيق الفلاتر'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
