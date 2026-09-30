// lib/screens/projects/projects_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/projects_provider.dart';
import '../../models/project.dart';
import '../../widgets/common/error_widget_custom.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      context.read<ProjectsProvider>().loadProjects(auth.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المشاريع')),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<ProjectsProvider>(
        builder: (_, proj, __) {
          if (proj.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (proj.error != null) {
            return ErrorWidgetCustom(
              message: proj.error!,
              onRetry: () {
                final auth = context.read<AuthProvider>();
                proj.loadProjects(auth.token);
              },
            );
          }
          if (proj.projects.isEmpty) {
            return const EmptyWidgetCustom(
              message: 'لا توجد مشاريع متاحة حالياً',
              icon: Icons.location_city_outlined,
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              final auth = context.read<AuthProvider>();
              await proj.loadProjects(auth.token);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: proj.projects.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _ProjectCard(
                  project: proj.projects[i],
                  onTap: () => context.push('/projects/${proj.projects[i].slug}'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const _ProjectCard({required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المشروع
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  project.coverImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: project.coverImageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            color: const Color(0xFF1A3B5C),
                            child: const Icon(Icons.location_city, size: 64, color: Colors.white),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF1A3B5C),
                          height: 200,
                          child: const Center(
                            child: Icon(Icons.location_city, size: 64, color: Colors.white),
                          ),
                        ),
                  // حالة المشروع
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        project.statusLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: Color(0xFF1A3B5C),
                    ),
                  ),
                  if (project.tagline != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      project.tagline!,
                      style: const TextStyle(
                        color: Color(0xFFB59659),
                        fontSize: 13,
                        fontFamily: 'Cairo',
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (project.location != null || project.city != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${project.city ?? ''} ${project.location ?? ''}'.trim(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _StatBadge(
                        icon: Icons.apartment,
                        label: 'إجمالي الوحدات',
                        value: '${project.totalUnits}',
                      ),
                      const SizedBox(width: 8),
                      _StatBadge(
                        icon: Icons.check_circle_outline,
                        label: 'المتاحة',
                        value: '${project.availableUnits}',
                        color: Colors.green,
                      ),
                    ],
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

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
    this.color = const Color(0xFF1A3B5C),
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                  fontFamily: 'Cairo',
                )),
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Cairo')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
