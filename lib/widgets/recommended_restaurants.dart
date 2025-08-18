import 'package:daim/models/information.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:daim/pages/menu_page.dart';
import 'package:daim/pages/restaurants_page.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RecommendedRestaurantsWidget extends StatefulWidget {
  const RecommendedRestaurantsWidget({super.key});

  @override
  State<StatefulWidget> createState() => _RecommendedRestaurantState();
}

class _RecommendedRestaurantState extends State<RecommendedRestaurantsWidget> {
  final PageController _controller = PageController(viewportFraction: 0.92);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Text(
                "Önerilen Kafeler",
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
          height: 126,
          child: PageView(
            controller: _controller,
            children: Information.restaurants
                .map((restaurant) => _buildRestaurantCard(restaurant, context))
                .toList(),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: SmoothPageIndicator(
            controller: _controller,
            count: Information.restaurants.isNotEmpty
                ? Information.restaurants.length
                : 1,
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

  Widget _buildRestaurantCard(
      RestaurantModel restaurant, BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias, // 👈 Resim taşmasını önler
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MenuPage(restaurant: restaurant),
              ),
            );
          },
          child: Row(
            children: [
              // 🖼️ Restoran Fotoğrafı
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Image.network(
                  restaurant.image,
                  width: 85,
                  height: 85,
                  fit: BoxFit.cover,
                ),
              ),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              restaurant.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 2, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              restaurant.category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1098F7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        restaurant.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        restaurant.hours,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
