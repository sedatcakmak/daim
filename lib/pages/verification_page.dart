import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daim/main.dart';
import 'package:daim/models/app_loader.dart';
import 'package:daim/pages/welcome_page.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OTPVerificationScreen extends StatefulWidget {
  final String phone;
  const OTPVerificationScreen({super.key, required this.phone});

  @override
  State<StatefulWidget> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isButtonEnabled = false;
  bool canResendSMS = false;
  int resendCooldown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _changePhone() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => PhoneNumberScreen()),
      (route) => false,
    );
  }

  Future<void> _sendOtp() async {
    try {
      _startResendCooldown();

      final response = await http.post(
        Uri.parse('https://api.daimapp.com/send_otp'),
        body: {'phone': widget.phone},
      );

      if (response.statusCode == 200) {
        _showSnack('Doğrulama kodu gönderildi.');
      } else {
        _showSnack('SMS gönderilemedi!');
      }
    } catch (e) {
      _showSnack('Hata: $e');
    }
  }

  Future<void> _verifyOtp() async {
    final code = otpController.text.trim();
    if (code.isEmpty || code.length != 6) {
      _showSnack('Lütfen 6 haneli kodu gir.');
      return;
    }

    isButtonEnabled = false;
    try {
      final response = await http.post(
        Uri.parse('https://api.daimapp.com/verify_otp'),
        body: {'phone': widget.phone, 'code': code},
      );

      if (response.statusCode == 200) {
        _showSnack('Doğrulama başarılı!');
        if (!mounted) {
          isButtonEnabled = true;
          return;
        }

        try {
          bool status = await AppLoader.handleLogin(context, widget.phone);
          if (status) {
            _showSnack('Başarıyla doğruladın!');
          } else {
            _showSnack('Giriş tamamlanamadı!');
          }
        } catch (e, stack) {
          isButtonEnabled = true;
          FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
          _showSnack('Giriş tamamlanamadı: $e');
        }
      } else {
        isButtonEnabled = true;
        _showSnack('Geçersiz veya süresi dolmuş kod girdiniz!');
      }
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
      isButtonEnabled = true;
      _showSnack('Hata: $e');
    }
  }

  Widget _buildLogo() {
    return Image.asset(
      "assets/logo.png",
      width: 256,
      height: 256,
      fit: BoxFit.contain,
    );
  }

  void _startResendCooldown() {
    _timer?.cancel();
    setState(() {
      canResendSMS = false;
      resendCooldown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() {
        if (resendCooldown > 0) {
          resendCooldown--;
        } else {
          canResendSMS = true;
          t.cancel();
        }
      });
    });
  }

  void _onOTPChanged(String v) {
    setState(() => isButtonEnabled = v.length == 6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.background,
          surfaceTintColor: AppColors.background,
          elevation: 0,
          title: Text(
            "Hesap Doğrulama",
            style: TextStyle(
              color: AppColors.black,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          iconTheme: IconThemeData(color: AppColors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildLogo(),
              Text(
                '${widget.phone} numarasına gönderilen doğrulama kodunu giriniz.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Container(
                padding: EdgeInsets.only(
                  top: 32,
                  bottom: 36,
                  left: 16,
                  right: 16,
                ),

                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.all(Radius.circular(24)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Doğrulama Kodu",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      CupertinoTextField(
                        prefix: Padding(
                          padding: EdgeInsets.only(left: 12, right: 8),
                          child: Icon(
                            CupertinoIcons.number,
                            color: AppColors.gray,
                          ),
                        ),
                        maxLength: 6,
                        maxLines: 1,
                        placeholder: "Kodu gir.",
                        obscureText: false,
                        onChanged: _onOTPChanged,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.gray, width: 1.2),
                          color: AppColors.white,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        controller: otpController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 16, color: AppColors.black),
                        placeholderStyle: TextStyle(color: AppColors.gray),
                      ),
                      SizedBox(height: 32),
                      _buildContinueButton(),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: canResendSMS ? _sendOtp : null,
                child: Text(
                  canResendSMS
                      ? 'Tekrar SMS Gönder'
                      : 'Tekrar SMS Gönder ($resendCooldown saniye)',
                  style: TextStyle(
                    fontSize: 15,
                    color: canResendSMS ? AppColors.black : AppColors.gray,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _changePhone,
                child: Text(
                  'Telefon Numarası Değiştir',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isButtonEnabled ? _verifyOtp : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled ? AppColors.black : AppColors.gray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          "Doğrula",
          style: TextStyle(
            fontSize: 18,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
