import 'package:daim/pages/home_page.dart';
import 'package:daim/pages/qr_page.dart';
import 'package:daim/pages/restaurants_page.dart';
import 'package:daim/pages/wallets_page.dart';
import 'package:flutter/material.dart';
import 'package:daim/pages/locations_page.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  void _navigateToScreen(BuildContext context, int index) {
    Widget destination;

    switch (index) {
      case 0:
        destination = const HomePage();
        break;
      case 1:
        destination = const RestaurantListPage();
        break;
      case 2:
        destination = const QR();
        break;
      case 3:
        destination = const Locations();
        break;
      case 4:
        destination = const WalletsPage();
        break;
      default:
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => destination),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            spreadRadius: 3,
            blurRadius: 8,
          )
        ],
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildNavItem(context, Icons.home, 'Ana Sayfa', 0)),
          Expanded(child: _buildNavItem(context, Icons.apps, 'Restoranlar', 1)),
          _buildQRNavItem(context, 2),
          Expanded(
              child: _buildNavItem(context, Icons.location_on, 'Lokasyon', 3)),
          Expanded(child: _buildNavItem(context, Icons.star, 'Cüzdan', 4)),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String label, int index) {
    bool isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        if (!isSelected) _navigateToScreen(context, index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Color(0xFFEE741B) : Colors.grey.shade600,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Color(0xFFEE741B) : Colors.grey.shade600,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            height: 3,
            width: isSelected ? 28 : 0,
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFEE741B) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRNavItem(BuildContext context, int index) {
    bool isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        if (!isSelected) _navigateToScreen(context, index);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Color(0xFFEE741B),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFFEE741B),
              spreadRadius: 1,
              blurRadius: 3,
            )
          ],
        ),
        child: const Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
