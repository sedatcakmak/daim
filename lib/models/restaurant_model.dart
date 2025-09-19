import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daim/models/menu_item_model.dart';

class RestaurantModel {
  final String id;
  final double latitude;
  final double longitude;
  final String address;
  final String name;
  final String link;
  final String image;
  final String hours;
  final String category;
  final List<MenuItemModel> menu;
  final List<int> reviews;
  final Timestamp createdAt;
  final int stars;
  final bool isRecommended;
  final bool isPopular;
  late bool isNew = false;

  RestaurantModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.name,
    required this.link,
    required this.menu,
    required this.category,
    required this.image,
    required this.hours,
    required this.reviews,
    required this.createdAt,
    required this.stars,
    required this.isRecommended,
    required this.isPopular,
  });

  double getRating() {
    return reviews.isNotEmpty
        ? reviews.fold(0, (sum, star) => sum + star) / reviews.length
        : -1.0;
  }

  factory RestaurantModel.fromMap(
    String id,
    Map<String, dynamic> data,
    List<MenuItemModel> menu,
    List<int> reviews,
  ) {
    return RestaurantModel(
      id: id,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      address: data['address'] ?? '',
      name: data['name'] ?? '',
      link: data['link'] ?? '',
      createdAt: (data['created_at'] is Timestamp)
          ? data['created_at']
          : Timestamp.now(),
      category: data['category'] ?? '',
      hours: data['hours'] ?? '',
      image: data['image'] ?? '',
      stars: data['stars'] ?? 0,
      isRecommended: data['recommended'] ?? false,
      isPopular: data['popular'] ?? false,
      menu: menu,
      reviews: reviews,
    );
  }
}
