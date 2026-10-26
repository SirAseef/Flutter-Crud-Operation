import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_theme.dart';
import 'controllers/app_controller.dart';
import 'controllers/product_controller.dart';
import 'firebase_options.dart';
import 'views/home_page.dart';
import 'views/product_form_page.dart';
import 'views/product_view_page.dart';
import 'views/splash_page.dart';

Future<void> main() async {
  // Firebase plugins need Flutter's platform channel ready before initialization.
  WidgetsFlutterBinding.ensureInitialized();

  // Let the app still open if Firebase is unavailable; data actions then show
  // the setup error from ProductController instead of crashing at startup.
  var firebaseReady = false;
  String? firebaseError;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (error) {
    firebaseError = error.toString();
  }

  // Register shared GetX controllers once so every route uses the same state.
  Get.put(AppController());
  Get.put(
    ProductController(
      firebaseReady: firebaseReady,
      firebaseError: firebaseError,
    ),
  );
  runApp(const EasyCrudApp());
}

class EasyCrudApp extends StatelessWidget {
  const EasyCrudApp({super.key});

  @override
  Widget build(BuildContext context) {
    // GetMaterialApp provides named navigation and GetX reactive widgets.
    return GetMaterialApp(
      title: 'Easy CRUD',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: '/',
      // Forms/details receive their selected product through Get.arguments.
      getPages: [
        GetPage(name: '/', page: () => const SplashPage()),
        GetPage(name: '/home', page: () => const HomePage()),
        GetPage(
          name: '/form',
          page: () => ProductFormPage(product: Get.arguments),
        ),
        GetPage(
          name: '/view',
          page: () => ProductViewPage(product: Get.arguments),
        ),
      ],
    );
  }
}
