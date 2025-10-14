import 'package:daim/models/information.dart';
import 'package:daim/models/manager.dart';
import 'package:flutter/material.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';

String membership = "Gümüş Üye";

class Membership extends StatelessWidget {
  final int total = Information.orders.fold(0, (sum, wallet) => sum + 1);

  Membership({super.key});

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> membership = Manager.getMembership(total);
    String name = membership["name"];
    int required = membership["required"];

    return Scaffold(
      appBar: CustomAppBar(title: "Üyelik"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        SizedBox(height: 16),
                        Text(
                          "Mevcut Üyelik: $name",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Yeni üyelik için ${required - total} siparişe ihtiyacın var.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color(0xFFEE741B),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: required > 0 ? total / required : 1,
                                  backgroundColor: Colors.white,
                                  color: Color(0xFFEE741B),
                                  minHeight: 35,
                                ),
                              ),
                            ),
                            Text(
                              '$total / $required sipariş',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(),
                  SizedBox(height: 8),
                  membershipCard(
                    "Gümüş Üye",
                    Icons.circle,
                    Colors.grey,
                    0,
                    false,
                    ["Başlangıç seviyesinde erişim"],
                  ),
                  SizedBox(height: 8),
                  membershipCard(
                    "Altın Üye",
                    Icons.square,
                    Color(0xFFEE741B),
                    25,
                    false,
                    ["Üyeliğine özel kampanyalar"],
                  ),
                  SizedBox(height: 8),
                  membershipCard(
                    "Elmas Üye",
                    Icons.pentagon,
                    Colors.blue,
                    50,
                    false,
                    ["Üyeliğine özel kampanyalar"],
                  ),
                  SizedBox(height: 8),
                  membershipCard(
                    "Premium Üye",
                    Icons.hexagon,
                    Colors.purpleAccent,
                    0,
                    true,
                    ["Üyeliğine özel kampanyalar"],
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

Widget membershipCard(
  String name,
  IconData icon,
  Color color,
  int star,
  bool isPremium,
  List<String> benefits,
) {
  return Card(
    color: Colors.white,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: membership == name
            ? Colors.green
            : (isPremium ? Colors.purpleAccent : Colors.grey),
        width: 2,
      ),
    ),
    child: SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 50, color: color),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    Text(
                      isPremium
                          ? "Özel Üyelik"
                          : (star > 0
                                ? "$star siparişte açılır"
                                : "Varsayılan Üyelik"),
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 5),
            ...benefits.map(
              (benefit) => Row(
                children: [
                  Icon(Icons.check, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text(benefit, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
