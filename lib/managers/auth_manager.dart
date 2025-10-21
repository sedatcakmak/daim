import 'package:daim/models/app_loader.dart';
import 'package:daim/pages/employee_home_page.dart';
import 'package:daim/pages/home_page.dart';
import 'package:daim/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  Future<void> autoLogin(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString("phone");

    if (phone != null) {
      if (!context.mounted) return;
      await login(context, phone, prefs.getBool("employee") ?? false);
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
    BuildContext context,
    String phone,
    bool isEmployee,
  ) async {
    if (isEmployee) {
      await AppLoader.loadEmployeeData(phone);
    } else {
      await AppLoader.loadAllData(phone);
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('phone', phone);
    await prefs.setBool('employee', isEmployee);

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Başarıyla giriş yaptın!")));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => isEmployee ? EmployeeHomePage() : HomePage(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> logout(BuildContext context) async {
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
