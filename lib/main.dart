import 'dart:convert';

import 'package:daim/models/information.dart';
import 'package:daim/pages/reward_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_links/app_links.dart';

import 'package:daim/localization/language_provider.dart';
import 'package:daim/localization/app_localizations.dart';
import 'package:daim/pages/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.playIntegrity,
    appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
  );

  await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

  LanguageProvider languageProvider = LanguageProvider();
  await languageProvider.loadSavedLanguage();

  runApp(
    ChangeNotifierProvider<LanguageProvider>.value(
      value: languageProvider,
      child: const DaimApp(),
    ),
  );
}

class DaimApp extends StatefulWidget {
  const DaimApp({super.key});

  @override
  State<DaimApp> createState() => _DaimAppState();
}

class _DaimAppState extends State<DaimApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
    _checkInitialLink();
  }

  Future<void> _checkInitialLink() async {
    final initialUri = await AppLinks().getInitialLink();
    if (initialUri != null) {
      print("📥 Initial deep link: $initialUri");
      _handleDeepLink(initialUri.toString());
    }
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen((uri) {
      print("🎯 Deep link geldi: ${uri.toString()}");
      _handleDeepLink(uri.toString());
    }, onError: (err) {
      print('❌ Deep link error: $err');
    });
  }

  Future<void> _handleDeepLink(String link) async {
    print("🎯 Deep link geldi: $link");

    final uri = Uri.parse(link);

    if (uri.host == 'reward') {
      final code = uri.queryParameters['code'];
      print("📦 Kod alındı: $code");

      if (code != null && Information.userId.isNotEmpty) {
        String newCode = "${Information.userId}-$code";
        await _verifyQrCode(newCode);
      }
    }
  }

  Future<void> _verifyQrCode(String fullCode) async {
    final uri = Uri.parse("https://api.daimapp.com/verify_qr").replace(
      queryParameters: {
        "code": fullCode,
      },
    );

    print("📤 İstek gönderildi: $uri");

    try {
      final response = await http.get(uri);
      print("📥 Yanıt: ${response.body}");

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        if (result == true) {
          _navigateToReward("✅ Kod doğrulandı ve yıldız verildi!");
        } else {
          _navigateToReward("❌ Kod geçersiz veya süresi dolmuş.");
        }
      } else {
        _navigateToReward("⚠️ Sunucu hatası: ${response.statusCode}");
      }
    } catch (e) {
      _navigateToReward("⚠️ Hata: $e");
    }
  }

  void _navigateToReward(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => RewardPage(message: message)),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey, // 🌟 Eklendi
          title: 'Daim',
          debugShowCheckedModeBanner: false,
          locale: languageProvider.locale,
          theme: ThemeData(
            fontFamily: 'Roboto',
            scaffoldBackgroundColor: Colors.white,
            primaryColor: Colors.blue,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.black,
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black),
              titleMedium: TextStyle(color: Colors.black),
            ),
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              labelStyle: TextStyle(color: Colors.black),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.blue,
              selectionColor: Colors.blueAccent,
              selectionHandleColor: Colors.blue,
            ),
          ),
          supportedLocales: const [
            Locale('en'),
            Locale('tr'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}
