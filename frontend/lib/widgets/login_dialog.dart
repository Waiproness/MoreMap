import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../screens/welcome_screen.dart'; // หรือไปหน้า login เลยก็ได้ครับ

// ฟังก์ชันสำหรับเรียก Popup แจ้งเตือนให้ Login
void showLoginRequiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.primaryTeal, width: 1.5), // ขอบสีเทล ฟ้าทะเล
        ),
        backgroundColor: const Color(0xFFE5E5E5), // สีพื้นหลังเทาอ่อนตามรูป
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Need to Login first",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ปุ่ม Yes (สีเขียว)
                  SizedBox(
                    width: 100,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34A853), // สีเขียว
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // ปิด Popup แล้วเด้งไปหน้า Welcome/Login
                        Navigator.pop(context); 
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (context) => const WelcomeScreen())
                        );
                      },
                      child: const Text("Yes", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  
                  // ปุ่ม Cancel (สีแดง)
                  SizedBox(
                    width: 100,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252), // สีแดง
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // ปิด Popup แค่นั้น จบ
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}