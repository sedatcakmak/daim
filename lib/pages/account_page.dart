import 'package:daim/models/app_loader.dart';
import 'package:daim/pages/activites_page.dart';
import 'package:daim/pages/contact_us_page.dart';
import 'package:daim/pages/faq_page.dart';
import 'package:daim/pages/orders_page.dart';
import 'package:daim/pages/privacy_policy_page.dart';
import 'package:daim/pages/terms_of_use_page.dart';
import 'package:daim/pages/welcome_page.dart';
import 'package:daim/widgets/settings_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountInformation extends StatelessWidget {
  const AccountInformation({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController codeController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Hesap"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Promosyon Kodu",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Promosyon kodun bulunuyorsa burada kullanabilirsin.",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: codeController,
                            style: TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Kod',
                              labelStyle: TextStyle(fontSize: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1098F7),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.all(16),
                        ),
                        onPressed: () async {
                          await AppLoader.useCode(context, codeController.text);
                        },
                        child: Text(
                          'Onayla',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SettingsButton(
              title: "Siparişler",
              icon: Icons.production_quantity_limits,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Orders()),
                );
              },
            ),
            Divider(),
            SettingsButton(
              title: "Hesap Hareketleri",
              icon: Icons.account_balance,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountActivities()),
                );
              },
            ),
            SizedBox(height: 20),
            SettingsButton(
              title: "Sıkça Sorulan Sorular",
              icon: Icons.question_answer,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FAQ()),
                );
              },
            ),
            Divider(),
            SettingsButton(
              title: "Bize Ulaşın",
              icon: Icons.contact_page,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactUs()),
                );
              },
            ),
            SizedBox(height: 20),
            SettingsButton(
              title: "Kullanım Şartları",
              icon: Icons.control_camera_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TermsOfUse()),
                );
              },
            ),
            Divider(),
            SettingsButton(
              title: "Gizlilik Politikası",
              icon: Icons.access_alarm_rounded,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicy()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1098F7),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 100),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.remove('phone');

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => PhoneNumberScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text(
                'Çıkış Yap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
