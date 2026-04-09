import 'package:flutter/material.dart';
import 'constants/app_colors.dart';
import 'routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 👉 1. Import ตัวอ่านไฟล์ .env

Future<void> main() async {
  // 👉 2. บรรทัดนี้สำคัญมาก! ต้องมีเมื่อเราใช้คำสั่ง async/await ใน main()
  WidgetsFlutterBinding.ensureInitialized(); 

  // 👉 3. สั่งให้ระบบไปเปิดอ่านไฟล์ .env ก่อนเป็นอันดับแรก
  await dotenv.load(fileName: ".env"); 

  // 👉 4. เอา "กุญแจ" มาเสียบเพื่อเชื่อมต่อฐานข้อมูล (ดึงค่ามาจากไฟล์ .env)
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '', 
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '', 
  );

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
      initialRoute: AppRoutes.splash, // หน้าแรกที่จะเปิด
      routes: AppRoutes.getRoutes(),  // โยนแผนที่ Routes ทั้งหมดให้ระบบ
    );
  }
}