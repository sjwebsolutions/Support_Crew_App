import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scupporo_crew_app/services/notification_service.dart';
import 'package:scupporo_crew_app/view/screens/splash_screen.dart';
import 'package:scupporo_crew_app/view_model/get_x/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AuthController());
  runApp(const MyApp());

  // Initialize notification service in background without blocking runApp
  NotificationService().initialize().catchError((e) {
    debugPrint("NotificationService initialization error: $e");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Support Crew App',
      home: const SplashScreen(),
    );
  }
}
