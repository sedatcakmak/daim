import 'package:daim/models/app_loader.dart';
import 'package:daim/pages/employee_home_page.dart';
import 'package:daim/pages/home_page.dart';
import 'package:daim/pages/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  Future<void> autoLogin(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? phone = user?.phoneNumber ?? "";

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (user != null && phone != "") {
      await login(context, user.uid, phone, prefs.getBool("employee") ?? false);
    } else {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PhoneNumberScreen()),
        );
      }
    }
  }

  Future<void> login(
      BuildContext context, String id, String phone, bool isEmployee) async {
    if (isEmployee) {
      await AppLoader.loadEmployeeData(id);
    } else {
      await AppLoader.loadAllData(id);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', phone);
    await prefs.setBool('employee', isEmployee);

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Başarıyla giriş yaptın!")));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => isEmployee ? EmployeeHomePage() : HomePage()),
            (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('phone');
    await prefs.remove('employee');

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => PhoneNumberScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }
}
