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
  });

  factory RestaurantModel.fromMap(String id, Map<String, dynamic> data,
      List<MenuItemModel> menu, List<int> reviews) {
    return RestaurantModel(
        id: id,
        latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
        address: data['address'] ?? '',
        name: data['name'] ?? '',
        link: data['link'] ?? '',
        category: data['category'] ?? '',
        hours: data['hours'] ?? '',
        image: data['image'] ?? '',
        menu: menu);
  }
}
