import 'package:daim/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:daim/pages/account_page.dart';
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
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(22),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            Row(
              children: [
                _RoundIcon(
                  icon: CupertinoIcons.bell_fill,
                  onTap: () {
                    if (title != "Bildirimler") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificationsPage(),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(width: 12),
                _RoundIcon(
                  icon: CupertinoIcons.person_fill,
                  onTap: () {
                    if (title != "Hesap") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountInformation(),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // boş alana da tıklanabilsin
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.gray.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 22, color: AppColors.black),
      ),
    );
  }
}
