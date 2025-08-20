import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daim/managers/auth_manager.dart';
import 'package:daim/pages/register_page.dart';
import 'package:daim/pages/type_page.dart';
import 'package:daim/pages/welcome_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phone; // ARTIK SADECE TELEFON ALIYORUZ

  const OTPVerificationScreen({super.key, required this.phone});

  @override
  State<StatefulWidget> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final TextEditingController otpController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AuthManager _authManager = AuthManager();

  bool isButtonEnabled = false;

  // SMS/verification state
  String? _verificationId;
  bool _loading = true; // ekran açılır açılmaz loader
  String? _errorText; // hata olursa göster
  int resendCooldown = 30;
  bool canResendSMS = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startVerification(); // EKRAN AÇILDIĞINDA BAŞLAT
    _startResendCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  // --- PHONE VERIFICATION FLOW ---
  int? _resendToken;

  Future<void> _startVerification() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: widget.phone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken, // <-- kritik
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await auth.signInWithCredential(credential);
            if (!mounted) return;
            setState(() => _loading = false);
            await _handlePostSignIn();
          } catch (e) {
            if (!mounted) return;
            setState(() {
              _errorText = e.toString();
              _loading = false;
            });
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            _errorText = e.message;
            _loading = false;
          });
          _showSnack('Hata: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _loading = false;
          });
          _showSnack('Doğrulama kodu gönderildi.');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!mounted) return;
          // Süre dolsa da elde verificationId kalsın
          setState(() => _verificationId = verificationId);
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = e.toString();
        _loading = false;
      });
      _showSnack('Hata: $e');
    }
  }

  Future<void> _verifyOTP() async {
    if (_verificationId == null) {
      _showSnack('Kod henüz gelmedi, lütfen bekleyin.');
      return;
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpController.text,
      );
      final userCredential = await auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        _showSnack('HATA!');
        return;
      }

      await _handlePostSignIn();
    } catch (e) {
      final msg = e.toString().contains('invalid')
          ? 'Yanlış kod girildi!'
          : e.toString();
      _showSnack('Hata: $msg');
    }
  }

  Future<void> _handlePostSignIn() async {
    final user = auth.currentUser;
    if (user == null) return;

    final employeeDoc =
        await firestore.collection('employees').doc(user.uid).get();
    final userDoc = await firestore.collection('users').doc(user.uid).get();

    if (!mounted) return;
    if (employeeDoc.exists && userDoc.exists) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => TypePage(userId: user.uid, phone: widget.phone),
        ),
        (route) => false,
      );
    } else if (employeeDoc.exists || userDoc.exists) {
      _authManager.login(context, user.uid, widget.phone, employeeDoc.exists);
    } else {
      _showSnack('Başarıyla doğruladın!');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegistrationScreen(id: user.uid, phone: widget.phone),
        ),
      );
    }
  }

  Future<void> _resendOTP() async {
    if (!canResendSMS) return;
    _startResendCooldown(); // cooldown reset
    await _startVerification(); // yeniden başlatır; _verificationId güncellenir
  }

  void _startResendCooldown() {
    _timer?.cancel();
    setState(() {
      canResendSMS = false;
      resendCooldown = 30;
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

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text('Hesap Doğrulama',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/logo.png', width: 200, height: 200),
              const SizedBox(height: 10),
              const Text('Daim',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(
                '${widget.phone} numarasına gönderilen kodu girin.',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // LOADER / ERROR / OTP INPUT
              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                )
              else if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('Hata: $_errorText',
                      style: const TextStyle(color: Colors.red)),
                )
              else
                SizedBox(
                  width: 380,
                  child: TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    onChanged: _onOTPChanged,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (isButtonEnabled) _verifyOTP();
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Doğrulama Kodu',
                    ),
                    scrollPadding: const EdgeInsets.only(bottom: 200),
                  ),
                ),
              const SizedBox(height: 20),
              _buildVerifyButton(),
              const SizedBox(height: 20),
              TextButton(
                onPressed: canResendSMS ? _resendOTP : null,
                child: Text(
                  canResendSMS
                      ? 'Tekrar SMS Gönder'
                      : 'Tekrar SMS Gönder ($resendCooldown)',
                  style: TextStyle(
                    fontSize: 16,
                    color: canResendSMS ? Colors.blue : Colors.grey,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PhoneNumberScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Telefon Numarasını Değiştir',
                    style: TextStyle(fontSize: 16, color: Colors.blue)),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    final enabled = !_loading && _verificationId != null && isButtonEnabled;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: enabled ? _verifyOTP : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? Colors.green : Colors.grey,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Doğrula',
            style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
