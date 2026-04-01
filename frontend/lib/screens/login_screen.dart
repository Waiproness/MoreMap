import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'main_map_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true; // เอาไว้เปิด/ปิดตา รหัสผ่าน

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Back", style: TextStyle(color: Colors.black, fontSize: 16)),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView( // ป้องกันคีย์บอร์ดบังจอ
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Login",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primaryTeal),
              ),
              const SizedBox(height: 10),
              const Text("Please log in into your account", style: TextStyle(fontSize: 16, color: Colors.black87)),
              const SizedBox(height: 40),

              // ช่องกรอก Email
              const Text("Email", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: "myemail@gmail.com",
                  filled: true,
                  fillColor: Colors.grey[100],
                  suffixIcon: const Icon(Icons.check, color: Colors.green), // ไอคอนติ๊กถูกชั่วคราว
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ช่องกรอก Password
              const Text("Password", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                obscureText: _obscurePassword, // ซ่อนรหัส
                decoration: InputDecoration(
                  hintText: "••••••••",
                  filled: true,
                  fillColor: Colors.grey[100],
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.primaryTeal),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ปุ่ม Sign in
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: ใส่ฟังก์ชันเช็ก Login ของ Supabase ตรงนี้
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainMaps(isGuest: false),
                      ),
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
            ],
          ),
        ),
      ),
    );
  }
}