import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hrms_app/controllers/auth_controller.dart';
import 'package:hrms_app/screens/splash_screen.dart';
import 'package:hrms_app/screens/login_screen.dart';
import 'package:hrms_app/screens/main_home_screen.dart';
import 'package:hrms_app/services/notification_service.dart';
import 'package:hrms_app/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseReady = await _initializeFirebase();
  if (firebaseReady) {
    await NotificationService.initialize();
  }
  runApp(const MyApp());
}

Future<bool> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    return true;
  } on FirebaseException catch (error, stackTrace) {
    developer.log(
      'Firebase initialization failed. The app will continue without push notifications until the platform Firebase configuration is added.',
      name: 'main',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkNest',
      theme: AppTheme.light(),
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/home', page: () => const MainHomeScreen()),
      ],
      home: const SplashScreen(),
    );
  }
}
