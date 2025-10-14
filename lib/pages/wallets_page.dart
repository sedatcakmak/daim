import 'package:daim/pages/menu_page.dart';
import 'package:daim/pages/qr_page.dart';
import 'package:daim/pages/restaurants_page.dart';
import 'package:daim/pages/membership_page.dart';
import 'package:flutter/material.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:daim/models/information.dart';
import 'package:daim/models/restaurant_model.dart';

class WalletsPage extends StatelessWidget {
  const WalletsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Yıldız Cüzdanı"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 4),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              icon: Icons.star,
              title: "Yıldızları Kazan",
              description: "Kafe siparişleri verdiğinde yıldız kazanırsın.",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QRPage()),
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
                  MaterialPageRoute(builder: (context) => RestaurantListPage()),
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
                  MaterialPageRoute(builder: (context) => Membership()),
                );
              },
            ),
            SizedBox(height: 12),
            Text(
              "Yıldız Kazandığın Kafeler",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Information.wallets.isEmpty
                ? Text(
                    "Hiçbir kafede daha yıldız kazanmamışsın.",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: Information.wallets.length,
                      itemBuilder: (context, index) {
                        final star = Information.wallets[index];
                        final RestaurantModel restaurant = Information
                            .restaurants
                            .firstWhere((r) => r.id == star.restaurantId);

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
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
                                : Icon(
                                    Icons.storefront,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                            title: Text(
                              restaurant.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("⭐ ${star.currentAmount} yıldız"),
                            trailing: Icon(Icons.arrow_forward_ios, size: 18),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MenuPage(restaurant: restaurant),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
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
      elevation: 2,
      color: Colors.white,
      child: ListTile(
        onTap: onTap, // ✅ Tıklama olayı
        leading: Icon(icon, color: Color(0xFF1098F7), size: 50),
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
