import 'package:flutter/material.dart';
import 'package:moremap/constants/app_colors.dart';
import '../screens/welcome_screen.dart'; // import หน้า AddRoute


// ---------------------------------------------------
// ฟังก์ชันสำหรับเรียก Popup แจ้งเตือนให้ Login 
// ---------------------------------------------------
void showLoginRequiredDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF008282), width: 1.5), // ขอบสี Teal
        ),
        backgroundColor: const Color(0xFFE5E5E5), // สีพื้นหลังเทาอ่อน
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Need to Login first",
                style: TextStyle(fontSize: 22, color: Colors.black),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // ปุ่ม Yes
                  SizedBox(
                    width: 100,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34A853),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context); 
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (context) => const WelcomeScreen())
                        );
                      },
                      child: const Text("Yes", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  
                  // ปุ่ม Cancel
                  SizedBox(
                    width: 100,
                    height: 45,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5252),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
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
// ---------------------------------------------------
// คลาส CustomBottomNavBar ของคุณ TP (รักษา UI เดิมไว้ 100%)
// ---------------------------------------------------
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final bool isGuest;
  final VoidCallback? onAddRouteTap;
  final VoidCallback? onExploreTap; // 👉 1. เพิ่มตัวแปรนี้

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    this.isGuest = false,
    this.onAddRouteTap,
    this.onExploreTap, // 👉 2. ใส่รับค่าตรงนี้
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.location_on, 
              label: "Explore", 
              isActive: selectedIndex == 0, // สลับเป็นสี Teal ถ้าอยู่หน้า 0
              onTap: onExploreTap,          // 👉 3. ใส่สายส่งสัญญาณนี้
            ),
            _buildNavItem(
              icon: Icons.add, 
              label: "AddRoute", 
              isLarge: true,
              isActive: selectedIndex == 1, // สลับเป็นสี Teal ถ้าอยู่หน้า 1
              onTap: () {
                if (isGuest) {
                  showLoginRequiredDialog(context);
                  return;
                }
                if (onAddRouteTap != null) onAddRouteTap!(); 
              }
            ),
            
            // ปุ่ม 2: Profile (เผื่ออนาคต)
            _buildNavItem(
              icon: Icons.person_outline,
              label: "Profile",
              isActive: selectedIndex == 2,
              onTap: () {
                // TODO: ใส่ Navigator ไปหน้า Profile
                if (isGuest) {
                  showLoginRequiredDialog(context);
                  return;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ซ่อนฟังก์ชันสร้างปุ่มย่อยไว้ในนี้เลย จะได้ไม่ต้องมีหลายไฟล์
  Widget _buildNavItem({required IconData icon, required String label, required bool isActive, bool isLarge = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isLarge ? 40 : 30, color: isActive ? AppColors.primaryTeal : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primaryTeal : Colors.grey,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}