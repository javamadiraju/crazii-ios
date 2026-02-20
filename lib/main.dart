import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freebankingapp/translation/stringtranslation.dart';
import 'package:get/get.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ add this

import 'splash.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_notifications/notificationchecker.dart';
import 'stripe_config_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  // ✅ Initialize Stripe securely
  try {
    await StripeConfigService.initStripe();
  } catch (e) {
    debugPrint("Stripe init failed: $e");
  }

  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('language') ?? 'en';
  final initialLocale =
      savedLang == 'zh' ? const Locale('zh', 'CN') : const Locale('en', 'US');

  runApp(
    NotificationChecker(
      child: MyApp(initialLocale: initialLocale),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Locale initialLocale;
  const MyApp({Key? key, required this.initialLocale}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      FlutterNativeSplash.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
  debugShowCheckedModeBanner: false,
  navigatorKey: navigatorKey,
  navigatorObservers: [routeObserver],
  translations: Apptranslation(),
  locale: widget.initialLocale,
  fallbackLocale: const Locale('en', 'US'),

  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],

  supportedLocales: const [
    Locale('en', 'US'),
    Locale('vi', 'VN'),
    Locale('zh', 'CN'),
  ],

  // ⭐⭐⭐ GLOBAL THEME (WEB BODY STYLE) ⭐⭐⭐
  theme: ThemeData(
    fontFamily: "Poppins",

    scaffoldBackgroundColor: Color(0xFFEDEDF5),   // Web body background #EDEDF5

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        fontSize: 15,
        height: 1.6,            // line-height: 1.6
        letterSpacing: 0.004,   // letter-spacing: 0.004em
        color: Color(0xFF958D9E), // text color #958d9e
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        height: 1.6,
        letterSpacing: 0.004,
        color: Color(0xFF958D9E),
      ),
    ),
  ),

  home: SplashScreen(),
);

  }
}
