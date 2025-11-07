import 'dart:async';
import 'package:daim/firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:daim/localization/language_provider.dart';
import 'package:daim/localization/app_localizations.dart';
import 'package:daim/pages/splash_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kReleaseMode, PlatformDispatcher;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("📩 Background mesaj alındı: ${message.notification?.title}");
}

Future<void> _createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel_id',
    'Genel Bildirimler',
    description: 'Daim uygulaması için varsayılan bildirim kanalı',
    importance: Importance.high,
  );

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
}

class AppColors {
  static bool get isDark => false;

  static Color get background => isDark
      ? const Color(0xFF000000)
      : const Color.fromARGB(255, 242, 242, 247);
  static Color get white =>
      isDark ? const Color(0xFF171717) : const Color(0xFFFFFFFF);
  static Color get black => isDark
      ? const Color.fromARGB(255, 229, 229, 234)
      : const Color(0xFF000000);
  static Color get gray => isDark
      ? const Color.fromARGB(255, 199, 199, 204)
      : const Color.fromARGB(153, 60, 60, 67);
}

Future<void> _setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Bildirim izni iste
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  debugPrint('🔔 Notification permission: ${settings.authorizationStatus}');

  String? token = await messaging.getToken();
  debugPrint('📱 FCM Token: $token');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('📩 Yeni bildirim geldi!');
    debugPrint('Başlık: ${message.notification?.title}');
    debugPrint('İçerik: ${message.notification?.body}');
  });

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
}

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint('Firebase initialized successfully');

      await _createNotificationChannel();
      await _setupFirebaseMessaging();

      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      try {
        await FirebaseAppCheck.instance.activate(
          providerAndroid: kReleaseMode
              ? const AndroidPlayIntegrityProvider()
              : const AndroidDebugProvider(),
          providerApple: kReleaseMode
              ? const AppleAppAttestProvider()
              : const AppleDebugProvider(),
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
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 2),
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
