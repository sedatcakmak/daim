import 'package:daim/models/app_loader.dart';
import 'package:daim/models/information.dart';
import 'package:daim/models/menu_item_model.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:daim/models/pending_order_model.dart';
import 'package:daim/pages/employee_home_page.dart';
import 'package:daim/widgets/employee_bottom.dart';
import 'package:daim/widgets/employee_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EmployeeOrderPage extends StatefulWidget {
  final PendingOrderModel order;

  const EmployeeOrderPage({super.key, required this.order});

  @override
  State<StatefulWidget> createState() => _EmployeeOrderPageState();
}

class _EmployeeOrderPageState extends State<EmployeeOrderPage> {
  RestaurantModel? restaurant = Information.restaurant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomEmployeeAppBar(title: 'Sipariş'),
      bottomNavigationBar: CustomEmployeeBottomNavBar(currentIndex: -1),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderInfo(),
              _buildActionButtons(),
              _buildOrderItems(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Sipariş Ürünleri",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...widget.order.items.map((orderItem) {
          final menuItem = restaurant!.menu.firstWhere(
            (item) => item.id == orderItem.id,
            orElse: () => MenuItemModel(
              id: '',
              name: 'Bilinmeyen Ürün',
              price: 0,
              category: '',
              description: '',
              image: '',
              maximum: 0,
            ),
          );

          return Card(
            color: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      menuItem.image.isNotEmpty
                          ? menuItem.image
                          : "https://via.placeholder.com/80",
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image,
                        size: 70,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${menuItem.name} (${orderItem.amount} adet)",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          menuItem.description,
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Birim Fiyat: ${orderItem.unitPrice} ⭐",
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  await AppLoader.removeStarsByPhone(
                    widget.order.phone,
                    widget.order.price,
                  );
                  await AppLoader.movePendingToOrders(widget.order);

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Sipariş başarıyla onaylandı.")),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EmployeeHomePage()),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Sipariş onaylanamadı: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              label: Text(
                "Onayla",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: Icon(Icons.check, size: 24, color: Colors.white),
            ),
          ),
          /*
          SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              label: Text(
                "Reddet",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: Icon(Icons.close, size: 24, color: Colors.white),
            ),
          ),
          */
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
      boxShadow: [
        BoxShadow(color: Colors.grey.shade200, spreadRadius: 1, blurRadius: 3),
      ],
    );
  }

  Widget _buildOrderInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: _boxDecoration(),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(
                  restaurant!.image,
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.grey,
                    );
                  },
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Müşteri: ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                                "${widget.order.name} ${widget.order.surname}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Tarih: ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: DateFormat(
                              'HH:mm:ss dd/MM/yyyy',
                            ).format(widget.order.createdAt.toDate()),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Toplam Fiyat: ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "${widget.order.price} ⭐",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
