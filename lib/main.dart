import 'dart:async';

import 'package:daim/firebase_options.dart';
import 'package:daim/managers/deeplink_manager.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:daim/localization/language_provider.dart';
import 'package:daim/localization/app_localizations.dart';
import 'package:daim/pages/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kReleaseMode, PlatformDispatcher;
import 'package:app_links/app_links.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppColors {
  static bool get isDark => false;
  /*
  static bool get isDark =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;
  */

  static Color get background =>
      isDark ? Color(0xFF000000) : Color.fromARGB(255, 242, 242, 247);

  static Color get white => isDark ? Color(0xFF171717) : Color(0xFFFFFFFF);

  static Color get black =>
      isDark ? Color.fromARGB(255, 229, 229, 234) : Color(0xFF000000);

  static Color get gray => isDark
      ? Color.fromARGB(255, 199, 199, 204)
      : Color.fromARGB(153, 60, 60, 67);
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      DeepLinkManager().init();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      try {
        await FirebaseAppCheck.instance.activate(
          androidProvider: kReleaseMode
              ? AndroidProvider.playIntegrity
              : AndroidProvider.debug,
          appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
        );
        await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

        debugPrint('Firebase App Check initialized successfully');
      } catch (appCheckError, stack) {
        FirebaseCrashlytics.instance.recordError(
          appCheckError,
          stack,
          fatal: false,
        );
        debugPrint('App Check initialization failed: $appCheckError');
      }

      LanguageProvider languageProvider = LanguageProvider();
      await languageProvider.loadSavedLanguage();
      debugPrint('Language provider initialized successfully');

      runApp(
        ChangeNotifierProvider<LanguageProvider>.value(
          value: languageProvider,
          child: const DaimApp(),
        ),
      );
    },
    (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    },
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
      debugPrint("📥 Initial deep link: $initialUri");
      DeepLinkManager().handleDeepLink(initialUri.toString());
    }
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint("🎯 Deep link geldi: ${uri.toString()}");
        DeepLinkManager().handleDeepLink(uri.toString());
      },
      onError: (err) {
        debugPrint('❌ Deep link error: $err');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Daim',
          debugShowCheckedModeBanner: false,
          locale: languageProvider.locale,
          theme: ThemeData(
            fontFamily: 'SF Pro',
            scaffoldBackgroundColor: AppColors.background,
            primaryColor: AppColors.black,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.background,
              elevation: 0,
              iconTheme: IconThemeData(color: AppColors.black),
              titleTextStyle: TextStyle(
                color: AppColors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: AppColors.white,
              selectedItemColor: AppColors.black,
              unselectedItemColor: AppColors.black,
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: AppColors.black),
              bodyMedium: TextStyle(color: AppColors.black),
              titleMedium: TextStyle(color: AppColors.black),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.white, width: 2),
              ),
              labelStyle: TextStyle(color: AppColors.black),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: AppColors.black,
              selectionColor: AppColors.gray,
              selectionHandleColor: AppColors.black,
            ),
          ),
          supportedLocales: const [Locale('en'), Locale('tr')],
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
