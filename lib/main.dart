import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nandiott_flutter/app/theme/dark_theme.dart';
import 'package:nandiott_flutter/app/widgets/custombottombar.dart';
import 'package:nandiott_flutter/features/auth/loginpage_tv.dart';
import 'package:nandiott_flutter/features/auth/signup_page.dart';
import 'package:nandiott_flutter/features/home/pages/home_page.dart';
import 'package:nandiott_flutter/features/profile/provider/quailty_provider.dart';
import 'package:nandiott_flutter/pages/notification_second_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/theme/theme_provider.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required before using platform channels or async services
  await dotenv.load(fileName: "assets/.env");
  await Firebase.initializeApp();
   await initializeQualitySettings();
  await requestPermission();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Only safe to call after Firebase.initializeApp()
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("onMessageOpenApp: $message");
    Navigator.pushNamed(
      MaterialApplication.globalKey.currentState!.context,
      "/push-page",
      arguments: {"message": json.encode(message.data)},
    );
  });

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      Navigator.pushNamed(
        MaterialApplication.globalKey.currentState!.context,
        "/push-page",
        arguments: {"message": json.encode(message.data)},
      );
    }
  });

  runApp(const ProviderScope(child: MyApp()));
}

Future<void>requestPermission()async{
  final messaging=FirebaseMessaging.instance;

final settings=await messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
  provisional: false,
  announcement: false,
  carPlay: false,
  criticalAlert: false
);
print("Permission status:${settings.authorizationStatus}");
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("_firebaseMessagingBackgroundHandler: $message");
}

Future<void> initializeQualitySettings() async {
  final prefs = await SharedPreferences.getInstance();
  final streamQuality = prefs.getInt(streamQualityKey);
  final downloadQuality = prefs.getInt(downloadQualityKey);

  if (streamQuality == null || downloadQuality == null) {
    // Set default quality if not already saved
    const defaultQuality = QualityType.mediumQuality;
    await prefs.setInt(streamQualityKey, 720);
    await prefs.setInt(downloadQualityKey, 720);

    // Update Riverpod providers with default quality
    // Make sure these providers are properly initialized
    final container = ProviderContainer();
    container
        .read(streamQualityProvider.notifier)
        .updateQuality(defaultQuality);
    container
        .read(downloadQualityProvider.notifier)
        .updateQuality(defaultQuality);

    // Dispose the provider container
    container.dispose();
  }
}

class MaterialApplication {
  static final GlobalKey<NavigatorState> globalKey =
      GlobalKey<NavigatorState>();
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(themeProvider);

    return MaterialApp(
      routes: {'/push-page':((context)=>const ResponsiveNavigation())},
      navigatorKey: MaterialApplication.globalKey,
      debugShowCheckedModeBanner: false,
      title: 'OTT Platform',
      theme: getThemeData(appTheme, context), // Use the context to get system theme
      darkTheme: darkTheme,
      themeMode: appTheme == AppTheme.system
          ? ThemeMode.system
          : appTheme == AppTheme.dark
              ? ThemeMode.dark
              : ThemeMode.light,
              
    home: ResponsiveNavigation()

          );
  }
}

