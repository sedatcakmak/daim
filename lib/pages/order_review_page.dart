import 'package:daim/models/information.dart';
import 'package:daim/models/manager.dart';
import 'package:daim/models/order_model.dart';
import 'package:flutter/material.dart';

void showOrderReviewPopup(BuildContext context, OrderModel order) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // İçerik uzun olursa kaydırılabilir olsun
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => OrderReviewPopup(order: order),
  );
}

class OrderReviewPopup extends StatefulWidget {
  final OrderModel order;

  const OrderReviewPopup({super.key, required this.order});

  @override
  State<StatefulWidget> createState() => _OrderReviewPopupState();
}

class _OrderReviewPopupState extends State<OrderReviewPopup> {
  int rating = 0;
  TextEditingController reviewController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Hata",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => {
              if (Navigator.canPop(context)) {Navigator.pop(context, true)},
            },
            child: Text(
              "Tamam",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = Information.restaurants.firstWhere(
      (res) => res.id == widget.order.restaurantId,
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Siparişi Değerlendir",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 24),
                onPressed: () => {
                  if (Navigator.canPop(context)) {Navigator.pop(context, true)},
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 50,
                ),
                onPressed: () {
                  setState(() {
                    rating = index + 1;
                  });
                },
              );
            }),
          ),
          SizedBox(height: 10),

          // ✍️ Yorum Alanı
          TextField(
            controller: reviewController,
            maxLines: 3,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: "Yorumunuzu yazın...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                if (rating == 0) {
                  _showErrorDialog("Lütfen bir puan verin!");
                  return;
                }

                await Manager.addReview(
                  restaurantId: restaurant.id,
                  comment: reviewController.text,
                  rating: rating,
                  orderId: widget.order.id,
                );

                if (!context.mounted) return;
                if (Navigator.canPop(context)) {
                  Navigator.pop(context, true);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Değerlendirmeniz kaydedildi!")),
                );
              },
              child: Text(
                "Gönder",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
