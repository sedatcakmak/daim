import 'dart:io';

import 'package:daim/main.dart';
import 'package:daim/managers/auth_manager.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
// ignore: depend_on_referenced_packages
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthManager _authManager = AuthManager();
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    debugPrint('SplashScreen: initState called');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  /// 🔹 Uygulama açıldığında çağrılır
  Future<void> _initializeApp() async {
    try {
      debugPrint('SplashScreen: Starting initialization...');

      await Future.delayed(const Duration(milliseconds: 500));

      // 🔸 1. Firebase Remote Config sürüm kontrolü
      bool shouldContinue = await _checkAppVersion();
      if (!shouldContinue || !mounted) return;

      // 🔸 2. Otomatik giriş
      await _authManager.autoLogin(context);
      debugPrint('SplashScreen: Auto login completed');
    } catch (e) {
      debugPrint('SplashScreen: Error during initialization: $e');

      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });

      // Birkaç saniye sonra fallback navigasyon
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _hasError) {
          _showFallbackNavigation();
        }
      });
    }
  }

  /// 🔹 Firebase Remote Config sürüm kontrolü
  Future<bool> _checkAppVersion() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: Duration.zero,
        ),
      );

      await remoteConfig.fetchAndActivate();

      final minVersion =
          int.tryParse(remoteConfig.getString('minimum_version_code')) ??
          remoteConfig.getInt('minimum_version_code');

      final updateUrl = Platform.isIOS
          ? remoteConfig.getString('update_url_ios')
          : remoteConfig.getString('update_url_android');

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;

      debugPrint(
        "📱 App Version: $currentVersionCode | Min Required: $minVersion",
      );

      if (currentVersionCode < minVersion) {
        if (!mounted) return false;

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text("Yeni sürüm gerekli"),
            content: const Text(
              "Uygulamanın yeni bir sürümü mevcut.\nDevam etmek için güncelleme yapmalısın.",
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (await canLaunchUrl(Uri.parse(updateUrl))) {
                    await launchUrl(
                      Uri.parse(updateUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                child: Text(
                  "Güncelle",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.black),
                ),
              ),
            ],
          ),
        );

        return false; // Güncelleme yapılmadan devam etmesin
      }

      return true; // Devam et
    } catch (e) {
      debugPrint("⚠️ Remote Config Error: $e");
      return true; // Hata olsa bile kullanıcıyı engelleme
    }
  }

  void _showFallbackNavigation() {
    Navigator.pushReplacementNamed(context, '/welcome');
  }

  void _retry() {
    setState(() {
      _hasError = false;
      _errorMessage = '';
    });
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logo.png",
                width: 256,
                height: 256,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error loading logo: $error');
                  return Container(
                    width: 256,
                    height: 256,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.restaurant,
                      size: 100,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
              const SizedBox(height: 25),
              const Text(
                "Daim",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),

              if (_hasError)
                Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Bir hata oluştu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Uygulama başlatılırken sorun yaşandı. Lütfen tekrar deneyin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                )
              else
                const CircularProgressIndicator(color: Colors.black),

              const SizedBox(height: 40),

              if (_hasError)
                Text(
                  'Hata: ${_errorMessage.length > 100 ? '${_errorMessage.substring(0, 100)}...' : _errorMessage}',
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
