import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Import หน้าโหลด
import 'constants/app_colors.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const MoreMapApp());
}

class MoreMapApp extends StatelessWidget {
  const MoreMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoreMap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryTeal,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryTeal),
        useMaterial3: true,
      ),
      
      // ให้หน้าแรกสุดเป็นหน้า Loading (SplashScreen)
      home: const SplashScreen(),
      initialRoute: AppRoutes.splash, // หน้าแรกที่จะเปิด
      routes: AppRoutes.getRoutes(),  // โยนแผนที่ Routes ทั้งหมดให้ระบบ
    );
  }
}