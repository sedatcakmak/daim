import 'package:daim/models/information.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:daim/widgets/employee_bottom.dart';
import 'package:daim/widgets/employee_header.dart';
import 'package:daim/widgets/generate_qr.dart';
import 'package:flutter/material.dart';

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  RestaurantModel? restaurant = Information.restaurant;

  @override
  Widget build(BuildContext context) {
    final r = restaurant!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomEmployeeAppBar(title: 'Hoşgeldin, ${Information.name}'),
      bottomNavigationBar: CustomEmployeeBottomNavBar(currentIndex: 0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmployeeInfo(r),
              const SizedBox(height: 16),

              // ---- QR alanı: büyük, ortalanmış CTA buton + açıklama kartı ----
              _buildQrCtaCard(context, r),

              const SizedBox(height: 16),

              // ---- Menü Grid ----
              Text(
                "Menü",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildMenuGrid(r),
            ],
          ),
        ),
      ),
    );
  }

  // Üst kart: çalışan + restoran
  Widget _buildEmployeeInfo(RestaurantModel r) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          if (r.image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(r.image,
                  width: 56, height: 56, fit: BoxFit.cover),
            )
          else
            const CircleAvatar(radius: 28, child: Icon(Icons.storefront)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${Information.name} ${Information.surname}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(r.name,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // QR CTA: butona basınca alttan sheet ile GenerateQRWidget açılır
  Widget _buildQrCtaCard(BuildContext context, RestaurantModel r) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hızlı İşlem",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    const Icon(Icons.qr_code_2, color: Colors.blue, size: 28),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Müşteriye yıldız kazandırmak için QR oluştur.\n(Cihaz yoksa uygulamadan göster.)",
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Büyük, ortalı, dikkat çekici buton
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) => Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      top: 16,
                      left: 16,
                      right: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const Text("QR Oluştur",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        // Mevcut widget’ını aynen kullanıyoruz
                        GenerateQRWidget(restaurantId: r.id),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // mavi
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code, size: 22),
                  SizedBox(width: 8),
                  Text("QR OLUŞTUR"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(RestaurantModel r) {
    final menu = r.menu;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: menu.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        final item = menu[index];
        return Container(
          decoration: _boxDecoration(),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(item.image,
                    width: 80, height: 80, fit: BoxFit.cover),
              ),
              const SizedBox(height: 6),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text("${item.price} ⭐",
                  style: const TextStyle(fontSize: 13, color: Colors.blue)),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade100,
          spreadRadius: 1,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
