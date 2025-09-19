import 'package:daim/managers/auth_manager.dart';
import 'package:flutter/material.dart';

class TypePage extends StatefulWidget {
  final String userId;
  final String phone;

  const TypePage({super.key, required this.userId, required this.phone});

  @override
  State<TypePage> createState() => _TypePageState();
}

class _TypePageState extends State<TypePage> {
  final AuthManager _authManager = AuthManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // 👈 İçerikleri sıkıştırır
            children: [
              _buildAccountCard(
                icon: Icons.person,
                title: "Kullanıcı Girişi",
                description:
                    "Sipariş verin, yıldız kazanın ve fırsatlardan yararlanın.",
                color: Colors.blueAccent,
                onTap: () async {
                  _authManager.login(
                    context,
                    widget.userId,
                    widget.phone,
                    false,
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildAccountCard(
                icon: Icons.storefront,
                title: "Çalışan Girişi",
                description:
                    "Müşteri siparişlerinde QR göstererek yıldız kazandırın.",
                color: Colors.green,
                onTap: () async {
                  _authManager.login(
                    context,
                    widget.userId,
                    widget.phone,
                    true,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
