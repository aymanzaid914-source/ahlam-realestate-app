// lib/screens/pages/page_detail_screen.dart
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../constants.dart';

class PageDetailScreen extends StatefulWidget {
  final String slug;
  const PageDetailScreen({super.key, required this.slug});

  @override
  State<PageDetailScreen> createState() => _PageDetailScreenState();
}

class _PageDetailScreenState extends State<PageDetailScreen> {
  Map<String, dynamic>? _pageData;
  bool _loading = true;
  String? _error;

  static const Map<String, String> _slugTitles = {
    'privacy-policy': 'سياسة الخصوصية',
    'terms': 'الشروط والأحكام',
    'about': 'من نحن',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = ApiService();
      final resp = await api.get(AppConstants.pagesEndpoint, queryParams: {'slug': widget.slug});
      setState(() {
        _pageData = (resp.data as Map<String, dynamic>?)?['page'] as Map<String, dynamic>?;
        _loading = false;
        if (_pageData == null) _error = 'الصفحة غير موجودة';
      });
    } catch (e) {
      setState(() { _error = 'تعذّر تحميل الصفحة'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _pageData?['title']?.toString()
        ?? _slugTitles[widget.slug]
        ?? 'المحتوى';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Builder(builder: (_) {
        if (_loading) return const Center(child: CircularProgressIndicator());
        if (_error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
              ],
            ),
          );
        }
        final content = _pageData?['content']?.toString() ?? '';
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: Color(0xFF1A3B5C),
                ),
              ),
              const Divider(height: 24),
              if (content.isNotEmpty)
                Text(
                  content,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    height: 1.8,
                    color: Colors.black87,
                  ),
                )
              else
                const Text(
                  'لا يوجد محتوى متاح حالياً.',
                  style: TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
                ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }
}
