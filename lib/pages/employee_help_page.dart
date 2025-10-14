import 'package:daim/models/information.dart';
import 'package:daim/models/restaurant_model.dart';
import 'package:daim/widgets/employee_bottom.dart';
import 'package:daim/widgets/employee_header.dart';
import 'package:flutter/material.dart';

class EmployeeHelpPage extends StatefulWidget {
  const EmployeeHelpPage({super.key});

  @override
  State<StatefulWidget> createState() => _EmployeeHelpPageState();
}

class _EmployeeHelpPageState extends State<EmployeeHelpPage> {
  RestaurantModel? restaurant = Information.restaurant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomEmployeeAppBar(title: 'Kılavuz'),
      bottomNavigationBar: CustomEmployeeBottomNavBar(currentIndex: 2),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBox("Müşteri Hesap QR'ı Okutma", [
                "Kullanıcı telefonunda bir QR gösterir.",
                "Uygulamada QR Okut sayfasına gir.",
                "Kamerayı bu QR'a tut.",
                "İstediğin kadar yıldız ekleyebilir veya silebilirsin.",
              ]),
              _buildBox("Müşteri Sipariş QR'ı Okutma", [
                "Kullanıcı siparişi için bir QR gösterir.",
                "QR Okut sayfasında kamerayı bu QR'a tut.",
                "Sipariş detayları ekranda görünür.",
                "'Onayla' ile siparişi onayla, 'Reddet' ile iptal et.",
              ]),
              _buildBox("Yıldız Kazandırma (QR Cihazı Varsa)", [
                "Kasanın yanında QR cihazı varsa yenileme butonuna bas.",
                "Ekranda yeni QR çıkar.",
                "Kullanıcı uygulamasını açmadan yıldız kazanır.",
                "Her zaman bu yöntemi tercih et.",
              ]),
              _buildBox("Yıldız Kazandırma (Uygulama Üzerinden)", [
                "Kasada cihaz yoksa veya çalışmıyorsa Ana Sayfa’dan QR oluştur.",
                "Kullanıcı bu QR’ı okutur ve yıldız kazanır.",
              ]),
            ],
          ),
        ),
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

  Widget _buildBox(String title, List<String> steps) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: _boxDecoration(),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ...steps.map(
              (step) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.circle, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
