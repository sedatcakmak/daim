class OrderItemModel {
  final String id;
  final int amount;
  final int unitPrice;

  OrderItemModel({
    required this.id,
    required this.unitPrice,
    required this.amount,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> data) {
    return OrderItemModel(
      id: data['id'] ?? '',
      amount: data['amount'] ?? 0,
      unitPrice: data['unit_price'] ?? 0,
    );
  }
}
