import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daim/main.dart';
import 'package:daim/models/information.dart';
import 'package:daim/pages/activites_page.dart';
import 'package:daim/pages/contact_us_page.dart';
import 'package:daim/pages/faq_page.dart';
import 'package:daim/pages/orders_page.dart';
import 'package:daim/pages/privacy_policy_page.dart';
import 'package:daim/pages/terms_of_use_page.dart';
import 'package:daim/pages/welcome_page.dart';
import 'package:daim/widgets/settings_button.dart';
import 'package:flutter/material.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountInformation extends StatelessWidget {
  const AccountInformation({super.key});

  @override
  Widget build(BuildContext context) {
    //TextEditingController codeController = TextEditingController();
    return Scaffold(
      appBar: CustomAppBar(title: "Hesap"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /*
            Information.isGuest
                ? const SizedBox(height: 20)
                : Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
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
                                backgroundColor: AppColors.black,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.all(16),
                              ),
                              onPressed: () async {
                                await AppLoader.useCode(
                                  context,
                                  codeController.text,
                                );
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
            */
            const SizedBox(height: 20),
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
                backgroundColor: AppColors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 100),
              ),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Information.id = "";
                Information.name = "";
                Information.surname = "";
                Information.phone = "";
                Information.city = "";
                Information.userId = "";

                Information.isGuest = false;
                Information.restaurant = null;
                Information.badges = [];
                Information.wallets = [];
                Information.campaigns = [];
                Information.notifications = [];
                Information.orders = [];
                Information.activities = [];
                Information.restaurants = [];

                if (!context.mounted) return;
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
            SizedBox(height: 20),
            if (!Information.isGuest)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 100),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(
                          'Hesabımı Sil',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: const Text(
                          'Hesabınızı ve tüm verilerinizi kalıcı olarak silmek istediğinize emin misiniz?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Vazgeç'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              Navigator.of(context).pop();

                              try {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.remove('phone');

                                final userDocs = await FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .where(
                                      'phone',
                                      isEqualTo: Information.phone,
                                    )
                                    .limit(1)
                                    .get();

                                for (final doc in userDocs.docs) {
                                  await doc.reference.delete();
                                }

                                if (!context.mounted) return;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PhoneNumberScreen(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              } catch (e) {
                                debugPrint('❌ Hesap silinirken hata: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Hesap silinirken hata oluştu.',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Sil'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  'Hesabı Sil',
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
