import 'package:daim/firebase_options.dart';
import 'package:daim/models/app_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:daim/localization/language_provider.dart';
import 'package:daim/localization/app_localizations.dart';
import 'package:daim/pages/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:app_links/app_links.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('Firebase initialized successfully');

    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: kReleaseMode
            ? AndroidProvider.playIntegrity
            : AndroidProvider.debug,
        appleProvider: AppleProvider.appAttestWithDeviceCheckFallback,
      );
      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

      if (!kReleaseMode) {
        await FirebaseAuth.instance.setSettings(
          appVerificationDisabledForTesting: true,
        ); // ⬅️ emülatör Phone Auth
      }
      print('Firebase App Check initialized successfully');
    } catch (appCheckError) {
      print('App Check initialization failed: $appCheckError');
    }

    LanguageProvider languageProvider = LanguageProvider();
    await languageProvider.loadSavedLanguage();
    print('Language provider initialized successfully');

    runApp(
      ChangeNotifierProvider<LanguageProvider>.value(
        value: languageProvider,
        child: const DaimApp(),
      ),
    );
  } catch (e) {
    print('Initialization error: $e');
    runApp(
      ChangeNotifierProvider<LanguageProvider>(
        create: (_) => LanguageProvider(),
        child: const DaimApp(),
      ),
    );
  }
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
      AppLoader.handleDeepLink(initialUri.toString());
    }
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();

    _appLinks.uriLinkStream.listen(
      (uri) {
        print("🎯 Deep link geldi: ${uri.toString()}");
        AppLoader.handleDeepLink(uri.toString());
      },
      onError: (err) {
        print('❌ Deep link error: $err');
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
