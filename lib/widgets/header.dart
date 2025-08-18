import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:daim/pages/account_page.dart';
import 'package:daim/pages/language_page.dart';
import 'package:daim/pages/notifications_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        height: preferredSize.height + top,
        padding: EdgeInsets.only(top: top, left: 16, right: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFEE741B),
              Color(0xFFFF9333),
            ], // Açık mavi geçiş
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Başlık
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),

            // Butonlar yan yana
            Row(
              children: [
                _iconButton(
                  icon: Icons.language,
                  onTap: () {
                    if (title != "Dil / Language") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const Language()),
                      );
                    }
                  },
                ),
                const SizedBox(width: 12),
                _iconButton(
                  icon: Icons.notifications,
                  onTap: () {
                    if (title != "Bildirimler") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsPage()),
                      );
                    }
                  },
                ),
                const SizedBox(width: 12),
                _iconButton(
                  icon: Icons.account_circle,
                  onTap: () {
                    if (title != "Hesap") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AccountInformation()),
                      );
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
