import 'package:flutter/material.dart';
import '../screens/add_route_screen.dart';
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
  final Color _primaryTeal = const Color(0xFF008282);
  final bool isGuest;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    this.isGuest = false,
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
            // ปุ่ม 0: Explore
            _buildNavItem(
              icon: Icons.location_on,
              label: "Explore",
              isActive: selectedIndex == 0,
              onTap: () {
                if (selectedIndex != 0) {
                  Navigator.pop(context); // ถ้าไม่ได้อยู่หน้าแรก ให้ถอยกลับไปหน้าแรก
                }
              },
            ),
            
            // ปุ่ม 1: AddRoute
            _buildNavItem(
              icon: Icons.add,
              label: "AddRoute",
              isLarge: true,
              isActive: selectedIndex == 1,
              onTap: () {
                if (isGuest) {
                  showLoginRequiredDialog(context); // ถ้าใช่ เด้ง Popup แจ้งเตือน
                  return; // สั่งหยุดทำงานตรงนี้เลย โค้ดด้านล่างจะไม่ได้ไปต่อ
                }
                if (selectedIndex != 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddRouteScreen()),
                  );
                }
              },
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
          Icon(icon, size: isLarge ? 40 : 30, color: isActive ? _primaryTeal : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? _primaryTeal : Colors.grey,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}