import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item_model.dart';

class PendingOrderModel {
  final String id;
  final String phone;
  final String restaurantId;
  final int price;
  final Timestamp createdAt;
  final List<OrderItemModel> items;

  late String name;
  late String surname;

  PendingOrderModel({
    required this.id,
    required this.phone,
    required this.restaurantId,
    required this.price,
    required this.createdAt,
    required this.items,
  });

  factory PendingOrderModel.fromMap(
    String id,
    Map<String, dynamic> data,
    List<OrderItemModel> items,
  ) {
    return PendingOrderModel(
      id: id,
      phone: data['phone'] ?? '',
      restaurantId: data['restaurant_id'] ?? '',
      price: data['price'] ?? 0,
      createdAt: (data['created_at'] is Timestamp)
          ? data['created_at']
          : Timestamp.now(),
      items: items,
    );
  }
}
