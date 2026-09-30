// lib/widgets/common/property_card.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/property.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;
  final bool showStatus;

  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.showStatus = true,
  });

  Color _statusColor(String status) {
    return switch (status) {
      'available'   => Colors.green,
      'reserved'    => Colors.orange,
      'sold'        => Colors.red,
      'unavailable' => Colors.grey,
      _             => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة العقار
            SizedBox(
              height: 180,
              width: double.infinity,
              child: Stack(
                children: [
                  property.coverImageUrl != null && property.coverImageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: property.coverImageUrl!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.apartment, size: 48, color: Colors.grey),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.apartment, size: 48, color: Colors.grey),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFE8EFF5),
                          width: double.infinity,
                          height: 180,
                          child: const Center(
                            child: Icon(Icons.apartment, size: 56, color: Color(0xFF1A3B5C)),
                          ),
                        ),
                  // حالة العقار
                  if (showStatus)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _statusColor(property.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          property.statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                  // مميز
                  if (property.isFeatured)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB59659),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '⭐ مميز',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // معلومات العقار
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (property.projectName != null) ...[
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            property.projectName!,
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Cairo'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  // خصائص
                  Row(
                    children: [
                      if (property.area != null) ...[
                        const Icon(Icons.square_foot, size: 14, color: Color(0xFF1A3B5C)),
                        const SizedBox(width: 3),
                        Text(
                          '${property.area!.toStringAsFixed(0)} م²',
                          style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (property.bedrooms != null && property.bedrooms! > 0) ...[
                        const Icon(Icons.bed_outlined, size: 14, color: Color(0xFF1A3B5C)),
                        const SizedBox(width: 3),
                        Text(
                          '${property.bedrooms} غرف',
                          style: const TextStyle(fontSize: 12, fontFamily: 'Cairo'),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // السعر
                  Text(
                    property.formattedPrice,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB59659),
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
