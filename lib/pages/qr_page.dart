import 'package:daim/models/information.dart';
import 'package:flutter/material.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QR extends StatelessWidget {
  const QR({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "QR"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: 2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              "Her sipariş sana yıldız ⭐ kazandırır!",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Hesabının QR'ını çalışana göstererek yıldız kazanabilir veya yıldızlarını harcayabilirsin!",
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            _buildQRInfo(),
            const SizedBox(height: 18),
            _infoCard(
              title: "QR Nedir?",
              description:
                  "Siparişini verirken kasadaki QR kodunu okut, böylece yıldız kazan!",
              icon: Icons.qr_code,
              color: Colors.blue.shade200,
            ),
            const SizedBox(height: 18),
            _infoCard(
              title: "Yıldız Nedir?",
              description:
                  "Yıldızlarını biriktirerek ürünlere harcayabilir veya sürpriz hediyeler kazanabilirsin!",
              icon: Icons.star,
              color: Colors.green.shade200,
            ),
            SizedBox(height: 50),
          ],
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
        BoxShadow(
          color: Colors.grey.shade200,
          spreadRadius: 1,
          blurRadius: 3,
        ),
      ],
    );
  }

  Widget _buildQRInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        padding: EdgeInsets.all(12),
        width: double.infinity,
        decoration: _boxDecoration(),
        child: Column(
          children: [
            QrImageView(
              data: Information.userId,
              version: QrVersions.auto,
              size: 300,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: Information.userId
                  .split('')
                  .map((digit) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          digit,
                          style: const TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
      {required String title,
      required String description,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(description, style: TextStyle(fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
