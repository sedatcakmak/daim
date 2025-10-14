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
  final PageController _controller = PageController(viewportFraction: 0.92);

  final restaurants = Information.restaurants
      .where(
        (r) =>
            r.isRecommended &&
            r.address.toLowerCase().contains(Information.city.toLowerCase()),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    if (restaurants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
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
                  children: const [
                    Text(
                      'Tümü',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1098F7),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Color(0xFF1098F7),
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
              activeDotColor: Color(0xFF1098F7),
              dotColor: Colors.black,
              spacing: 7,
            ),
          ),
        ),
      ],
    );
  }
}
