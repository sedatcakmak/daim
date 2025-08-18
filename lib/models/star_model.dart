class StarModel {
  final String restaurantId;
  final int totalAmount;
  final int currentAmount;

  StarModel({
    required this.restaurantId,
    required this.totalAmount,
    required this.currentAmount,
  });

  factory StarModel.fromMap(Map<String, dynamic> data, String id) {
    return StarModel(
      restaurantId: data['restaurant_id'] ?? '',
      totalAmount: data['total_amount'] ?? 0,
      currentAmount: data['current_amount'] ?? 0,
    );
  }
}
