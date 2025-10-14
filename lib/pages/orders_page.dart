import 'package:daim/models/information.dart';
import 'package:daim/widgets/last_order_card.dart';
import 'package:flutter/material.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';

class Orders extends StatelessWidget {
  const Orders({super.key});

  @override
  Widget build(BuildContext context) {
    final sortedOrders = List.of(Information.orders)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Scaffold(
      appBar: CustomAppBar(title: "Siparişler"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: sortedOrders.isEmpty
          ? const Center(
              child: Text(
                "Siparişiniz bulunmamaktadır.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: sortedOrders.length,
              itemBuilder: (context, index) {
                final order = sortedOrders[index];

                final restaurant = Information.restaurants.firstWhere(
                  (res) => res.id == order.restaurantId,
                );

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: LastOrderCard(
                    restaurantModel: restaurant,
                    orderModel: order,
                  ),
                );
              },
            ),
    );
  }
}
