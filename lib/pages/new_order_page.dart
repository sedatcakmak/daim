import 'package:daim/models/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:daim/models/order_model.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';

class OrderConfirmationPage extends StatefulWidget {
  final String code;
  final OrderModel orderModel;
  final RestaurantModel restaurant;

  const OrderConfirmationPage({
    super.key,
    required this.code,
    required this.orderModel,
    required this.restaurant,
  });

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  bool _isCancelling = false; // ✅ İptal işlemi devam ediyor mu?

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "${widget.restaurant.name} siparişi"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
              SizedBox(height: 10),
              Text(
                "Sipariş başarıyla oluşturuldu!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      QrImageView(data: widget.code, size: 250),
                      SizedBox(height: 10),
                      Text(
                        widget.code,
                        style: TextStyle(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Lütfen bu QR kodunu kasiyere gösteriniz.",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isCancelling
                    ? null
                    : () async {
                        setState(() {
                          _isCancelling = true;
                        });

                        bool status = await AppLoader.deletePendingOrder();

                        if (!context.mounted) return;
                        if (status) {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Sipariş başarıyla silindi!"),
                            ),
                          );
                        }

                        if (Navigator.canPop(context)) {
                          Navigator.pop(context, true);
                        }

                        if (Navigator.canPop(context)) {
                          Navigator.pop(context, true);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isCancelling ? Colors.grey : Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Siparişi İptal Et",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
