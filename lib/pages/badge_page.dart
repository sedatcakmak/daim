import 'dart:convert';
import 'package:daim/models/information.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';

class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    icon: json['icon'],
  );
}

class BadgePage extends StatefulWidget {
  const BadgePage({super.key});

  @override
  State<BadgePage> createState() => _BadgePageState();
}

class _BadgePageState extends State<BadgePage> {
  List<Badge> _badges = [];

  Map<String, IconData> iconMap = {
    "favorite": Icons.favorite,
    "star": Icons.star,
    "travel_explore": Icons.travel_explore,
    "flight_takeoff": Icons.flight_takeoff,
    "workspace_premium": Icons.workspace_premium,
    "diamond": Icons.diamond,
    "comment": Icons.comment,
    "reviews": Icons.reviews,
  };

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    final jsonString = await rootBundle.loadString('assets/badges.json');
    final List data = json.decode(jsonString) as List;

    final badges = data
        .map((e) => Badge.fromJson(e as Map<String, dynamic>))
        .toList();

    final owned = Information.badges.toSet();

    // Açık olanlar (owned) önce, sonra alfabetik
    badges.sort((a, b) {
      final aHas = owned.contains(a.id);
      final bHas = owned.contains(b.id);
      if (aHas != bHas) return aHas ? -1 : 1; // açık rozetler üste
      return a.name.compareTo(b.name); // ikincil sıralama
    });

    setState(() => _badges = badges);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Rozetler'),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: -1),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 50),
        itemCount: _badges.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final b = _badges[i];
          final hasBadge = Information.badges.contains(b.id);

          final bgColor = hasBadge
              ? Colors.green.shade50
              : Colors.grey.shade100;
          final borderColor = hasBadge
              ? Colors.green.shade300
              : Colors.grey.shade300;
          final labelBg = hasBadge
              ? Colors.green.withValues(alpha: 0.12)
              : Colors.grey.withValues(alpha: 0.12);
          final labelFg = hasBadge
              ? Colors.green.shade700
              : Colors.grey.shade700;

          return Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _GrayscaleIfLocked(
                    locked: !hasBadge,
                    child: Icon(
                      iconMap[b.icon] ?? Icons.help_outline,
                      size: 48,
                      color: hasBadge ? Colors.lightGreen : Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              b.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: hasBadge
                                    ? Colors.black
                                    : Colors.grey.shade800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: labelBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              hasBadge ? 'Açıldı' : 'Kilitli',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: labelFg,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        b.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: hasBadge
                              ? Colors.black87
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GrayscaleIfLocked extends StatelessWidget {
  final bool locked;
  final Widget child;
  const _GrayscaleIfLocked({required this.locked, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        // Grayscale matrix
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 1, 0,
      ]),
      child: child,
    );
  }
}
