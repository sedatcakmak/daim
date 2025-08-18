class MenuItemModel {
  final String id;
  final String name;
  final int price;
  final String category;
  final String image;
  final int maximum;
  final String description;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.image,
    required this.maximum,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> data, String id) {
    return MenuItemModel(
      id: id,
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      maximum: data['maximum'] ?? 0,
    );
  }
}
