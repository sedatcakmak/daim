import 'package:daim/main.dart';
import 'package:daim/pages/menu_page.dart';
import 'package:daim/pages/qr_page.dart';
import 'package:daim/pages/restaurants_page.dart';
import 'package:daim/pages/membership_page.dart';
import 'package:flutter/material.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:daim/models/information.dart';

class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Yıldız Cüzdanı"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 4),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: ListView(
          children: [
            _buildInfoCard(
              icon: Icons.star,
              title: "Yıldızları Kazan",
              description: "Kafe siparişleri verdiğinde yıldız kazanırsın.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QRPage()),
                );
              },
            ),
            _buildInfoCard(
              icon: Icons.redeem,
              title: "Yıldızları Kullan",
              description:
                  "Yıldızlarını özel indirimler ve kampanyalarda kullanabilirsin.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RestaurantListPage()),
                );
              },
            ),
            _buildInfoCard(
              icon: Icons.emoji_events,
              title: "Seviye Atla",
              description:
                  "Daha fazla yıldız toplayarak üyelik seviyeni yükseltebilir, özel ayrıcalıklar kazanabilirsin.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Membership()),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              "Yıldız Kazandığın Kafeler",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            if (Information.wallets.isEmpty)
              const Text(
                "Hiçbir kafede daha yıldız kazanmamışsın.",
                style: TextStyle(fontSize: 15),
              )
            else
              ...Information.wallets.map((star) {
                final restaurant = Information.restaurants.firstWhere(
                  (r) => r.id == star.restaurantId,
                );
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  color: Colors.white,
                  child: ListTile(
                    leading: restaurant.image.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              restaurant.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.storefront,
                            size: 50,
                            color: Colors.grey,
                          ),
                    title: Text(
                      restaurant.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("⭐ ${star.currentAmount} yıldız"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MenuPage(restaurant: restaurant),
                        ),
                      );
                    },
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        onTap: onTap, // ✅ Tıklama olayı
        leading: Icon(icon, color: AppColors.black, size: 50),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black),
      ),
    );
  }
}
