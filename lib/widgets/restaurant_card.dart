import 'package:daim/main.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:daim/pages/menu_page.dart';
import 'package:flutter/material.dart';

class RestaurantCardWidget extends StatefulWidget {
  final RestaurantModel restaurant;
  const RestaurantCardWidget({super.key, required this.restaurant});

  @override
  State<StatefulWidget> createState() => _RecommendedRestaurantState();
}

class _RecommendedRestaurantState extends State<RestaurantCardWidget> {
  Widget _buildRatingRow(double? raw) {
    // Güvenli değer: -1, null veya NaN ise "rating yok"
    final hasRating = raw != null && !raw.isNaN && raw >= 0;
    final rating = hasRating ? raw : 0.0;

    // 5 yıldız (dolu/yarım/boş). Rating yoksa hepsi boş-gri.
    List<Widget> stars = [];
    for (int i = 1; i <= 5; i++) {
      IconData icon;
      if (!hasRating) {
        icon = Icons.star_border;
      } else {
        icon = rating >= i
            ? Icons.star
            : (rating >= i - 0.5 ? Icons.star_half : Icons.star_border);
      }
      stars.add(
        Icon(icon, size: 16, color: hasRating ? Colors.amber : Colors.black26),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...stars,
        const SizedBox(width: 6),
        Text(
          hasRating
              ? "${rating.toStringAsFixed(1)} (${widget.restaurant.reviews.length} değerlendirme)"
              : '—',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: hasRating ? Colors.black87 : Colors.black38,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final rating = widget.restaurant.getRating(); // double (-1 ise yok)
    return Card(
      color: AppColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MenuPage(restaurant: widget.restaurant),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // üstten hizalı dursun
          children: [
            // 🖼️ Restoran Fotoğrafı
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                widget.restaurant.image,
                width: 85,
                height: 85,
                fit: BoxFit.cover,
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık + Kategori
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.restaurant.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            widget.restaurant.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Adres
                    Text(
                      widget.restaurant.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),

                    // Çalışma saatleri
                    Text(
                      widget.restaurant.hours,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 4),
                    _buildRatingRow(rating),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
