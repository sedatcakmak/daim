import 'package:daim/models/manager.dart';
import 'package:daim/pages/badge_page.dart';
import 'package:daim/pages/membership_page.dart';
import 'package:daim/pages/wallets_page.dart';
import 'package:daim/widgets/campaigns.dart';
import 'package:daim/widgets/new_restaurants.dart';
import 'package:daim/widgets/recommended_restaurants.dart';
import 'package:daim/widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:daim/widgets/info_card.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:daim/models/information.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    int total = Information.orders.fold(0, (sum, wallet) => sum + 1);

    Map<String, dynamic> membership = Manager.getMembership(total);
    String name = membership["name"];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'Hoşgeldin, ${Information.name}'),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 5),
            InfoCard(
              icon: Icons.star,
              iconBgStart: Colors.orange.shade200,
              iconBgEnd: Colors.orange.shade700,
              title:
                  'Yıldız Cüzdanı: ${Information.wallets.fold(0, (sum, wallet) => sum + wallet.currentAmount)}',
              description:
                  'Kazandığın yıldızları siparişlerinde kullanabilirsin.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WalletsPage()),
                );
              },
            ),
            InfoCard(
              icon: Icons.people,
              iconBgStart: Colors.blue.shade200,
              iconBgEnd: Colors.blue.shade700,
              title: 'Üyelik: $name',
              description:
                  'Üyelik seviyeleriyle daha çok fırsattan yararlanabilirsin.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Membership()),
                );
              },
            ),
            InfoCard(
              icon: Icons.badge,
              iconBgStart: Colors.green.shade200,
              iconBgEnd: Colors.green.shade700,
              title: 'Rozetler: ${Information.badges.length}',
              description:
                  'Rozet listesini görüntüleyip kazandıklarını inceleyebilirsin.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BadgePage()),
                );
              },
            ),
            SizedBox(height: 10),
            Divider(
              color: Color(0xFFE0E0E0),
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Text(
                    "Popüler İşletme",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: RestaurantCardWidget(
                restaurant:
                    Information.restaurants
                        .where(
                          (r) =>
                              r.isPopular &&
                              r.address.toLowerCase().contains(
                                Information.city.toLowerCase(),
                              ),
                        )
                        .firstOrNull ??
                    Information.restaurants.first,
              ),
            ),
            SizedBox(height: 10),
            Divider(
              color: Color(0xFFE0E0E0),
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            CampaignsWidget(),
            RecommendedRestaurantsWidget(),
            NewRestaurantsWidget(),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
