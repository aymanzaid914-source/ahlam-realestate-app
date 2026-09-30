// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/properties_provider.dart';
import '../../providers/projects_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../widgets/common/property_card.dart';
import '../../widgets/common/error_widget_custom.dart';
import '../../models/project.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    context.read<PropertiesProvider>().loadFeatured(auth.token);
    context.read<ProjectsProvider>().loadProjects(auth.token);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final customer = auth.customer;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF1A3B5C),
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
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer != null
                                          ? 'مرحباً، ${customer.fullName.split(' ').first}'
                                          : 'أهلاً بك',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                    const Text(
                                      'أحلام الشرق للتطوير العقاري',
                                      style: TextStyle(
                                        color: Color(0xFFB59659),
                                        fontSize: 12,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // إشعارات
                              Consumer<NotificationsProvider>(
                                builder: (_, notifs, __) => Stack(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                                      onPressed: () => context.push('/notifications'),
                                    ),
                                    if (notifs.unreadCount > 0)
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              notifs.unreadCount > 9 ? '9+' : '${notifs.unreadCount}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // شريط البحث
                          GestureDetector(
                            onTap: () => context.go('/properties'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search, color: Colors.grey),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'ابحث عن عقار...',
                                      style: TextStyle(color: Colors.grey, fontFamily: 'Cairo', fontSize: 14),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1A3B5C),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'بحث',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

                    // ─── أزرار الفئات السريعة ─────────────────────────────
                    Row(
                      children: [
                        _QuickBtn(
                          icon: Icons.apartment,
                          label: 'شقق',
                          onTap: () => context.go('/properties?type=apartment'),
                        ),
                        const SizedBox(width: 10),
                        _QuickBtn(
                          icon: Icons.house,
                          label: 'فيلل',
                          onTap: () => context.go('/properties?type=villa'),
                        ),
                        const SizedBox(width: 10),
                        _QuickBtn(
                          icon: Icons.landscape,
                          label: 'أراضي',
                          onTap: () => context.go('/properties?type=land'),
                        ),
                        const SizedBox(width: 10),
                        _QuickBtn(
                          icon: Icons.star,
                          label: 'المميزة',
                          onTap: () => context.go('/properties?featured=true'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ─── المشاريع ─────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'مشاريعنا',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            color: Color(0xFF1A3B5C),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/projects'),
                          child: const Text('عرض الكل', style: TextStyle(fontFamily: 'Cairo')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // قائمة المشاريع
                    Consumer<ProjectsProvider>(
                      builder: (_, proj, __) {
                        if (proj.isLoading) {
                          return const SizedBox(
                            height: 130,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (proj.projects.isEmpty) {
                          return const SizedBox(
                            height: 80,
                            child: Center(
                              child: Text(
                                'لا توجد مشاريع متاحة حالياً',
                                style: TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
                              ),
                            ),
                          );
                        }
                        return SizedBox(
                          height: 130,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: proj.projects.length,
                            itemBuilder: (_, i) => _ProjectChip(
                              project: proj.projects[i],
                              onTap: () => context.go('/projects/${proj.projects[i].slug}'),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // ─── العقارات المميزة ──────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'الوحدات المتاحة',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            color: Color(0xFF1A3B5C),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/properties'),
                          child: const Text('عرض الكل', style: TextStyle(fontFamily: 'Cairo')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Consumer<PropertiesProvider>(
                      builder: (_, props, __) {
                        if (props.isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (props.featured.isEmpty) {
                          return EmptyWidgetCustom(
                            message: 'لا توجد وحدات متاحة حالياً',
                            icon: Icons.apartment_outlined,
                            action: ElevatedButton(
                              onPressed: () => context.go('/properties'),
                              child: const Text('استعراض كل العقارات'),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: props.featured.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, i) => PropertyCard(
                            property: props.featured[i],
                            onTap: () {
                              final slug = props.featured[i].slug;
                              if (slug != null) {
                                context.push('/properties/$slug');
                              }
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // ─── بنر التواصل ──────────────────────────────────────
                    _ContactBanner(onTap: () => context.push('/contact')),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, size: 24, color: const Color(0xFF1A3B5C)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 11, fontFamily: 'Cairo', fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProjectChip extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const _ProjectChip({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            project.coverImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: project.coverImageUrl!,
                    width: 220,
                    height: 130,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: const Color(0xFF1A3B5C),
                      child: const Icon(Icons.location_city, size: 48, color: Colors.white),
                    ),
                  )
                : Container(
                    color: const Color(0xFF1A3B5C),
                    height: 130,
                    child: const Icon(Icons.location_city, size: 48, color: Colors.white),
                  ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${project.availableUnits} وحدة متاحة',
                    style: const TextStyle(
                      color: Color(0xFFB59659),
                      fontSize: 11,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _ContactBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB59659), Color(0xFFD4B06A)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.phone_in_talk, color: Colors.white, size: 32),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تواصل معنا الآن',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    'فريق المبيعات جاهز للمساعدة',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
