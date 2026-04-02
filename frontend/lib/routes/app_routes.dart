import 'package:flutter/material.dart';
// Import หน้าจอทั้งหมดของเรามาไว้ที่นี่ที่เดียว
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main_map_screen.dart';
import '../screens/search_screen.dart';

class AppRoutes {
  // 1. ตั้งชื่อ Route เป็นตัวแปร Constant เพื่อกันพิมพ์ผิด
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainMap = '/main-map';
  static const String search = '/search';

  // 2. สร้าง Map เพื่อจับคู่ชื่อ Route กับหน้าจอ
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      welcome: (context) => const WelcomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      // หน้า MainMaps อาจจะต้องมีการรับค่า isGuest เวลาเรียกใช้ค่อยส่งเป็น arguments แทนได้ครับ
      mainMap: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final isGuest = args?['isGuest'] ?? false;
        return MainMaps(isGuest: isGuest);
      },
      search: (context) => const SearchScreen(),
    };
  }
}