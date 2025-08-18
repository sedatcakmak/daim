import 'package:daim/pages/employee_help_page.dart';
import 'package:daim/pages/employee_home_page.dart';
import 'package:daim/pages/employee_qr_page.dart';
import 'package:flutter/material.dart';

class CustomEmployeeBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomEmployeeBottomNavBar({super.key, required this.currentIndex});

  void _navigateToScreen(BuildContext context, int index) {
    Widget destination;

    switch (index) {
      case 0:
        destination = const EmployeeHomePage();
        break;
      case 1:
        destination = const EmployeeQRPage();
        break;
      case 2:
        destination = const EmployeeHelpPage();
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
          Expanded(child: _buildNavItem(context, Icons.qr_code, 'QR Okut', 1)),
          Expanded(
              child: _buildNavItem(context, Icons.help_outline, 'Kılavuz', 2)),
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
            color: isSelected ? Colors.blueAccent : Colors.grey.shade600,
            size: 24,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blueAccent : Colors.grey.shade600,
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
              color: isSelected ? Colors.blueAccent : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
