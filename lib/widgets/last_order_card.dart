import 'package:daim/models/manager.dart';
import 'package:daim/models/order_model.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:daim/pages/order_details.dart';
import 'package:daim/pages/order_review_page.dart';
import 'package:flutter/material.dart';

class LastOrderCard extends StatelessWidget {
  final RestaurantModel restaurantModel;
  final OrderModel orderModel;

  const LastOrderCard({
    super.key,
    required this.restaurantModel,
    required this.orderModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              restaurantModel.image,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  restaurantModel.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "${_formatDate(orderModel.createdAt.toDate())} - ${orderModel.price} ⭐",
                  style: TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "${orderModel.items.length} ürün siparişi",
                  style: TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton("Detaylar", Colors.blue, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailsPage(order: orderModel),
                  ),
                );
              }),
              SizedBox(height: 7),
              _buildButton("Değerlendir", Colors.orange, () async {
                if (await Manager.isReviewed(
                  restaurantId: restaurantModel.id,
                  orderId: orderModel.id,
                )) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Zaten bu siparişi değerlendirmişsin!"),
                    ),
                  );
                  return;
                }

                if (!context.mounted) return;
                showOrderReviewPopup(context, orderModel);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 100,
      height: 30,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color, width: 1.5),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return "${date.day}.${date.month}.${date.year}";
}
