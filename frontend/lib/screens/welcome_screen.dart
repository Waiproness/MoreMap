import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'main_map_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Welcome MoreMap",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryTeal, // สีเขียวอมฟ้าตามธีม
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Lets get started",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              
              // 👉 จุดที่แก้: ใส่โลโก้ตรงกลางแทน Spacer()
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/logo_moremap.png', // ชื่อไฟล์โลโก้ที่คุณ TP เซฟไว้
                    width: 220, // ปรับขนาดความกว้างได้ตามชอบเลยครับ
                  ),
                ),
              ), // ดันเนื้อหาที่เหลือลงไปด้านล่าง

              const Text(
                "Existing customer / Get started",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              
              // ปุ่ม Sign in
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // โดดไปหน้า Login
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Sign in",
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // ปุ่ม Create new account
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("New customer? ", style: TextStyle(color: Colors.black87)),
                  GestureDetector(
                 onTap: () {
                   // 👉 เอาคอมเมนต์ตรงนี้ออกครับ
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                 },
                 child: const Text(
                   "Create new account",
                      style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 60),

              // ปุ่ม Skip ด้านล่างสุด
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // โดดไปหน้า MainMaps พร้อมส่งธงบอกว่าเป็น Guest
                        Navigator.pushReplacement(
                          context, 
                          // 👉 แก้กลับมาใช้ MainMaps ได้เลยครับ
                          MaterialPageRoute(builder: (context) => const MainMaps(isGuest: true))
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        fixedSize: const Size(150, 45),
                      ),
                      child: const Text("Skip", style: TextStyle(color: Colors.black54, fontSize: 16)),
                    ),
                    const SizedBox(height: 8),
                    const Text("No login? No problem.", style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}