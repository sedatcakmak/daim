import 'package:daim/models/information.dart';
import 'package:daim/pages/restaurants_page.dart';
import 'package:daim/widgets/restaurant_card.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class NewRestaurantsWidget extends StatefulWidget {
  const NewRestaurantsWidget({super.key});

  @override
  State<StatefulWidget> createState() => _NewRestaurantState();
}

class _NewRestaurantState extends State<NewRestaurantsWidget> {
  final PageController _controller = PageController(viewportFraction: 0.92);

  final restaurants = Information.restaurants
      .where(
        (r) =>
            r.isNew &&
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
        Divider(
          color: Color(0xFFE0E0E0),
          thickness: 1,
          indent: 16,
          endIndent: 16,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Text(
                "Yeni İşletmeler",
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
