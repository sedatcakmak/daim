import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String restaurantId;
  final int price;
  final Timestamp createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.restaurantId,
    required this.price,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromMap(
      String id, Map<String, dynamic> data, List<OrderItemModel> items) {
    return OrderModel(
      id: id,
      restaurantId: data['restaurant_id'] ?? '',
      price: data['price'] ?? 0,
      createdAt: (data['created_at'] is Timestamp)
          ? data['created_at']
          : Timestamp.now(),
      items: items,
    );
  }
}
