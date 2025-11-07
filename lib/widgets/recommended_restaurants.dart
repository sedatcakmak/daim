import 'package:daim/main.dart';
import 'package:daim/models/information.dart';
import 'package:daim/pages/restaurants_page.dart';
import 'package:daim/widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RecommendedRestaurantsWidget extends StatefulWidget {
  const RecommendedRestaurantsWidget({super.key});

  @override
  State<StatefulWidget> createState() => _RecommendedRestaurantState();
}

class _RecommendedRestaurantState extends State<RecommendedRestaurantsWidget> {
  final PageController _controller = PageController();

  final restaurants = Information.restaurants
      .where((r) => r.isRecommended)
      .toList();

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Text(
                "Önerilen İşletmeler",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RestaurantListPage(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tümü',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 137,
          child: PageView(
            controller: _controller,
            children: restaurants
                .map(
                  (restaurant) => RestaurantCardWidget(restaurant: restaurant),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: SmoothPageIndicator(
            controller: _controller,
            count: restaurants.isNotEmpty ? restaurants.length : 1,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 22,
              activeDotColor: AppColors.black,
              dotColor: AppColors.gray,
              spacing: 7,
            ),
          ),
        ),
      ],
    );
  }
}
