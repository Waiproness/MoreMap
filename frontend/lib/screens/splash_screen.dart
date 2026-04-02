import 'dart:async';
import 'package:flutter/material.dart'; // <--- เดี๋ยวพรุ่งนี้เรามาสร้างไฟล์นี้นะครับ
import '../constants/app_colors.dart'; 
import '../routes/app_routes.dart';// <--- ผมสมมติว่าคุณมีไฟล์สีนี้อยู่นะครับ

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 👉 จุดที่สำคัญที่สุด: ตั้งเวลา 3 วินาที แล้วให้โดดไปหน้า Login
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    });
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดธีมสีteal ฟ้าทะเล

    return Scaffold(
      backgroundColor: AppColors.primaryTeal, // พื้นหลังสีเทล ฟ้าทะเล
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // จัดกลางจอบนล่าง
          children: [
            // 1. Logo ตรงกลาง
            Image.asset(
              'assets/logo_moremap.png',
              width: 180, // ขนาดโลโก้
              height: 180,
            ),
            
            const SizedBox(height: 50), // เว้นระยะห่างลงมา

            // 2. Loading Bar ใต้ Logo (ขอเลือกแบบ Linear แถบยาว)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: SizedBox(
                height: 5, // ความหนาของแถบโหลด
                child: LinearProgressIndicator(
                  color: Colors.white, // สีของแถบที่วิ่ง
                  backgroundColor: Colors.white.withOpacity(0.2), // สีพื้นหลังแถบ
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // เพิ่มเติมนิดหน่อย: ข้อความ Loading
            Text(
              "Loading More Possibilities...",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}