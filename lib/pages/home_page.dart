import 'package:daim/main.dart';
import 'package:daim/pages/wallets_page.dart';
import 'package:daim/widgets/campaigns.dart';
import 'package:daim/widgets/new_restaurants.dart';
import 'package:daim/widgets/recommended_restaurants.dart';
import 'package:flutter/material.dart';
import 'package:daim/widgets/info_card.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:daim/models/information.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    /*
    int total = Information.orders.fold(0, (sum, wallet) => sum + 1);

    Map<String, dynamic> membership = Manager.getMembership(total);
    String name = membership["name"];
    */

    return Scaffold(
      appBar: CustomAppBar(title: 'Hoşgeldin!'),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 4),
            InfoCard(
              icon: Icons.star,
              iconBgStart: AppColors.black,
              iconBgEnd: AppColors.black,
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
            /*
            InfoCard(
              icon: Icons.people,
              iconBgStart: AppColors.black,
              iconBgEnd: AppColors.black,
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
              iconBgStart: AppColors.black,
              iconBgEnd: AppColors.black,
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
            */
            RecommendedRestaurantsWidget(),
            CampaignsWidget(),
            NewRestaurantsWidget(),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
