import 'package:daim/managers/auth_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomEmployeeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  const CustomEmployeeAppBar({super.key, required this.title});

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
              Colors.blueAccent,
              Colors.lightBlueAccent
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
                  icon: Icons.logout,
                  onTap: () {
                    if (title != "Hesap") {
                      AuthManager().logout(context);
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
        child: Row(
          children: [
            Text(
              "Çıkış Yap",
              style: const TextStyle(
                overflow: TextOverflow.ellipsis,
                color: Colors.white,
                fontSize: 20,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
