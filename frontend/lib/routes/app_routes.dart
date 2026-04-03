import 'package:flutter/material.dart';

// --- Import Screens ตามโครงสร้างโฟลเดอร์ใหม่ ---
import '../screens/splash_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/explore/main_map_screen.dart';
import '../screens/explore/search_screen.dart';

// --- Import Profile Screens (ของเพื่อน) ---
import '../screens/profile/profile.dart';
import '../screens/profile/Profile_edit.dart';
import '../screens/profile/saved_route.dart';
import '../screens/profile/route_detail.dart';
import '../screens/profile/route_detail_edit.dart';
import '../screens/profile/report_issues.dart';
import '../screens/profile/team_credit.dart';

class AppRoutes {
  // 1. ชื่อ Route (Constants)
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainMap = '/main-map';
  static const String search = '/search';

  // Profile Routes
  static const String profile = '/profile';
  static const String profileEdit = '/profile-edit';
  static const String savedRoute = '/saved-route';
  static const String routeDetail = '/route-detail';
  static const String routeDetailEdit = '/route-detail-edit';
  static const String reportIssues = '/report-issues';
  static const String teamCredit = '/team-credit';

  // 2. สร้าง Map สำหรับลงทะเบียนหน้าจอ
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      splash: (context) => const SplashScreen(),
      welcome: (context) => const WelcomeScreen(),
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      
      // หน้า MainMaps ยังคงรับค่าแบบเดิมได้ (หรือจะย้ายไปรับข้างในแบบหน้าอื่นก็ได้ครับ)
      mainMap: (context) {
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final isGuest = args?['isGuest'] ?? false;
        return MainMaps(isGuest: isGuest);
      },
      
      search: (context) => const SearchScreen(),

      // --- Profile Section ---
      profile: (context) => const ProfilePage(),
      
      // 👉 แก้ไข: ให้เรียก Class เปล่าๆ เพราะเราไปแกะพัสดุ (Arguments) ข้างในหน้าจอแล้ว
      profileEdit: (context) => const ProfileEditPage(),
      savedRoute: (context) => const SavedRoutePage(),
      reportIssues: (context) => const ReportIssuesPage(),
      teamCredit: (context) => const TeamCreditPage(),

      // 👉 แก้ไข: ลบการส่ง Parameter ออกให้หมด เพื่อให้ตรงกับโครงสร้างใหม่ที่เราแก้ไป
      routeDetail: (context) => const RouteDetailPage(),

      // 👉 แก้ไข: ลบการส่ง Parameter ออกเช่นกัน
      routeDetailEdit: (context) => const RouteDetailEditPage(),
    };
  }
}