import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daim/managers/auth_manager.dart';
import 'package:daim/pages/register_page.dart';
import 'package:daim/pages/type_page.dart';
import 'package:daim/pages/welcome_page.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phone;

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
  bool _loading = true;
  String? _errorText;
  int resendCooldown = 60;
  bool canResendSMS = false;
  Timer? _timer;

  // Retry & guard
  int _attempt = 0;
  final int _maxAttempts = 2;
  bool _done = false;

  String? _cachedToken;
  Future<bool> _primeAppCheck() async {
    try {
      _cachedToken = await FirebaseAppCheck.instance.getToken(false);

      return true;
    } catch (_) {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();

    _startVerification();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  void _markDone() {
    if (!_done) setState(() => _done = true);
  }

  String _tail(String s, [int n = 6]) {
    if (s.isEmpty) return '';
    return s.length <= n ? s : s.substring(0, n);
  }

  Future<void> _rlog(String stage, {Map<String, dynamic>? extra}) async {
    try {
      final data = <String, dynamic>{
        'ts': FieldValue.serverTimestamp(),
        'stage': stage,
        'phoneMasked': widget.phone,
        'verificationId': _verificationId,
        'resendToken': _resendToken,
        'appCheckTokenLen': _cachedToken?.length ?? 0,
        'platform': Platform.operatingSystem,
        'isRelease': kReleaseMode,
        'pkg': 'com.cakmakstudios.daim',
        'projectNumber': '1041416288073',
        if (extra != null) ...extra,
      };
      await firestore.collection('otp_debug').add(data);
    } on FirebaseException catch (e) {
      debugPrint('RLOG FS ERROR: ${e.code} | ${e.message}');
      _showSnack('Log yazılamadı: ${e.code}');
    } catch (e) {
      debugPrint('RLOG ERROR: $e');
      _showSnack('Log hatası');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  // ----------------- PHONE VERIFICATION FLOW -----------------
  int? _resendToken;

  Future<void> _startVerification() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });
    _attempt = 0;
    await _verify();
  }

  Future<void> _verify() async {
    if (_done) return;
    await _primeAppCheck();

    await _rlog(
      'verifyPhoneNumber_call',
      extra: {
        'attempt': _attempt,
        'timeoutSec': 120,
        'forceResendToken': _resendToken,
      },
    );

    try {
      await auth.verifyPhoneNumber(
        phoneNumber: widget.phone,
        timeout: const Duration(seconds: 120),
        forceResendingToken: _resendToken,

        verificationCompleted: (PhoneAuthCredential cred) async {
          if (_done) return;
          try {
            await auth.signInWithCredential(cred);
            if (!mounted) return;
            _markDone();
            setState(() => _loading = false);
            await _handlePostSignIn();
          } catch (e) {
            if (!mounted) return;
            setState(() {
              _errorText = e.toString();
              _loading = false;
            });
            await _rlog(
              'verification_completed_failed',
              extra: {'error': e.toString()},
            );
          }
        },

        verificationFailed: (FirebaseAuthException e) async {
          await _rlog(
            'verification_failed',
            extra: {'code': e.code, 'message': e.message ?? ''},
          );
          if (_done) return;

          _attempt++;
          if (_attempt < _maxAttempts) {
            await Future.delayed(const Duration(seconds: 2));
            return _verify(); // tek kanaldan retry
          }

          if (!mounted) return;
          setState(() {
            _errorText = e.message;
            _loading = false;
          });

          String userMessage;
          switch (e.code) {
            case 'too-many-requests':
              userMessage =
                  'Çok fazla deneme yapıldı. Lütfen daha sonra tekrar deneyin.';
              break;
            case 'invalid-phone-number':
              userMessage = 'Geçersiz telefon numarası.';
              break;
            default:
              userMessage = e.message ?? 'Bilinmeyen hata oluştu.';
          }
          _showSnack('Hata: $userMessage');
        },

        codeSent: (String verificationId, int? resendToken) async {
          if (!mounted || _done) return;
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _loading = false;
          });

          await _rlog(
            'code_sent',
            extra: {
              'verificationId_tail': _tail(verificationId),
              'resendToken': resendToken,
            },
          );
          _showSnack('Doğrulama kodu gönderildi.');
        },

        codeAutoRetrievalTimeout: (String verificationId) async {
          if (!mounted || _done) return;
          setState(() => _verificationId = verificationId);
          await _rlog(
            'auto_retrieval_timeout',
            extra: {'verificationId_tail': _tail(verificationId)},
          );
          // İstersen burada sınırlı sayıda yeniden deneyebilirsin
        },
      );
    } catch (e) {
      await _rlog('verify_call_throw', extra: {'error': e.toString()});
      if (!mounted) return;
      setState(() {
        _errorText = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (_done) return;

    if (_verificationId == null) {
      _showSnack('Kod henüz gelmedi, lütfen bekleyin.');
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpController.text,
      );

      final current = auth.currentUser;
      UserCredential userCredential;

      if (current != null) {
        try {
          userCredential = await current.linkWithCredential(credential);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'provider-already-linked' ||
              e.code == 'credential-already-in-use') {
            userCredential = await auth.signInWithCredential(credential);
            await _rlog('otp_signin_fallback');
          } else {
            rethrow;
          }
        }
      } else {
        userCredential = await auth.signInWithCredential(credential);
      }

      if (userCredential.user == null) {
        await _rlog('otp_user_null');
        _showSnack('HATA!');
        return;
      }

      _markDone();
      await _handlePostSignIn();
    } catch (e) {
      await _rlog('verify_otp_failed', extra: {'error': e.toString()});
      final msg = e.toString().toLowerCase().contains('invalid')
          ? 'Yanlış kod girildi!'
          : e.toString();
      _showSnack('Hata: $msg');
    }
  }

  Future<void> _handlePostSignIn() async {
    try {
      final user = auth.currentUser;
      if (user == null) return;

      final phone = user.phoneNumber ?? widget.phone;
      if (phone.isEmpty) {
        _showSnack('Telefon numarası bulunamadı.');
        return;
      }

      final employeeSnap = await firestore
          .collection('employees')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      final userSnap = await firestore
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      final hasEmployee = employeeSnap.docs.isNotEmpty;
      final hasUser = userSnap.docs.isNotEmpty;

      if (!mounted) return;

      if (hasEmployee && hasUser) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => TypePage(userId: user.uid, phone: phone),
          ),
          (route) => false,
        );
        return;
      }

      if (hasEmployee || hasUser) {
        _authManager.login(context, user.uid, phone, hasEmployee);
        return;
      }

      _showSnack('Başarıyla doğruladın!');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RegistrationScreen(id: user.uid, phone: phone),
        ),
      );
    } catch (e) {
      _showSnack('Giriş tamamlanamadı: $e');
    }
  }

  Future<void> _resendOTP() async {
    if (!canResendSMS || _done) return;
    _startResendCooldown();
    setState(() {
      _loading = true;
      _errorText = null;
    });
    await _verify();
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

  // ----------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    final enabled = !_loading && _verificationId != null && isButtonEnabled;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Hesap Doğrulama',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
              const Text(
                'Daim',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '${widget.phone} numarasına gönderilen kodu girin.',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(),
                )
              else if (_errorText != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Hata: $_errorText',
                    style: const TextStyle(color: Colors.red),
                  ),
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
                      if (enabled) _verifyOTP();
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Doğrulama Kodu',
                    ),
                    scrollPadding: const EdgeInsets.only(bottom: 200),
                  ),
                ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: enabled ? _verifyOTP : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: enabled ? Colors.green : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Doğrula',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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
                      builder: (_) => const PhoneNumberScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Telefon Numarasını Değiştir',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
