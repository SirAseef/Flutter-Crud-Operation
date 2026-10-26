import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppController extends GetxController {
  // Observable theme state updates the dashboard icon automatically.
  final isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.toggle();
    // Tell GetX to apply the matching theme across the whole app.
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
