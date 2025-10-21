import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daim/models/app_loader.dart';
import 'package:daim/models/information.dart';
import 'package:daim/models/menu_item_model.dart';
import 'package:daim/models/order_item_model.dart';
import 'package:daim/models/order_model.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:daim/models/star_model.dart';
import 'package:daim/pages/home_page.dart';
import 'package:daim/pages/new_order_page.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  final Map<MenuItemModel, int> order;
  final RestaurantModel restaurant;

  const OrderPage({super.key, required this.restaurant, required this.order});

  @override
  State<StatefulWidget> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  bool _isProcessing = false;
  StreamSubscription? _listener;

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }

  void _addItem(MenuItemModel item) {
    setState(() {
      int currentQuantity = widget.order[item] ?? 0;
      int totalPrice = widget.order.entries.fold(
        0,
        (int sum, entry) => sum + (entry.key.price * entry.value),
      );

      int userBalance = Information.wallets
          .firstWhere(
            (star) => star.restaurantId == widget.restaurant.id,
            orElse: () => StarModel(
              restaurantId: widget.restaurant.id,
              totalAmount: 0,
              currentAmount: 0,
            ),
          )
          .currentAmount;

      if (item.price > 0) {
        if (totalPrice + item.price > userBalance) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Yetersiz yıldız! Daha az seçin.")),
          );
          return;
        }
      }

      if (currentQuantity < item.maximum) {
        widget.order[item] = currentQuantity + 1;
      }
    });
  }

  void _removeItem(MenuItemModel item) {
    setState(() {
      if (widget.order[item] != null && widget.order[item]! > 0) {
        widget.order[item] = widget.order[item]! - 1;
        if (widget.order[item] == 0) {
          widget.order.remove(item);
        }
      }

      if (widget.order.isEmpty) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      }
    });
  }

  void _clearOrder() {
    setState(() {
      widget.order.clear();
    });

    if (Navigator.canPop(context)) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalAmount = widget.order.entries.fold(
      0,
      (int sum, entry) => sum + (entry.key.price * entry.value),
    );

    return Scaffold(
      appBar: CustomAppBar(title: widget.restaurant.name),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: widget.order.length,
              itemBuilder: (context, index) {
                final entry = widget.order.entries.elementAt(index);
                final item = entry.key;
                final quantity = entry.value;
                final total = (item.price * quantity);
                final bool canAddMore = quantity < item.maximum;

                return Card(
                  color: Colors.white,
                  elevation: 3,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                item.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "Toplam Ücret: $total ⭐",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${item.price} ⭐",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.remove,
                                    size: 22,
                                    color: quantity > 0
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  onPressed: () => _removeItem(item),
                                ),
                                Text(
                                  "$quantity",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    color: canAddMore
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  onPressed: canAddMore
                                      ? () => _addItem(item)
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _isProcessing
                      ? null
                      : () async {
                          setState(() {
                            _isProcessing = true;
                          });

                          try {
                            List<OrderItemModel> items = [];
                            widget.order.forEach((menuItem, amount) {
                              items.add(
                                OrderItemModel(
                                  id: menuItem.id,
                                  unitPrice: menuItem.price,
                                  amount: amount,
                                ),
                              );
                            });

                            OrderModel orderModel = OrderModel(
                              id: "RANDOM",
                              restaurantId: widget.restaurant.id,
                              price: totalAmount,
                              createdAt: Timestamp.now(),
                              items: items,
                            );

                            String number = await AppLoader.createPendingOrder(
                              orderModel,
                            );

                            if (!context.mounted) return;
                            _listener = FirebaseFirestore.instance
                                .collection('orders')
                                .where('order_id', isEqualTo: number)
                                .snapshots()
                                .listen((snapshot) async {
                                  if (snapshot.docs.isNotEmpty) {
                                    debugPrint(
                                      "✅ Sipariş onaylandı, orders koleksiyonuna taşındı!",
                                    );

                                    _listener?.cancel();

                                    await AppLoader.loadOrders();
                                    await AppLoader.loadStars();
                                    await AppLoader.loadActivities();

                                    if (!context.mounted) return;
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => HomePage(),
                                      ),
                                      (route) => false,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Siparişin onaylandı!"),
                                      ),
                                    );
                                  }
                                });

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderConfirmationPage(
                                  restaurant: widget.restaurant,
                                  orderModel: orderModel,
                                  code: number,
                                ),
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Sipariş başarıyla oluşturuldu!"),
                              ),
                            );

                            setState(() {
                              widget.order.clear();
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Sipariş oluşturulamadı: $e"),
                              ),
                            );
                          } finally {
                            setState(() {
                              _isProcessing = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isProcessing ? Colors.grey : Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: Text(
                    "Siparişi Onayla",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _clearOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                  child: Text(
                    "Siparişi Temizle",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
