import 'package:flutter/material.dart';

class SavedRoutePage extends StatelessWidget {
  const SavedRoutePage({super.key});

  final Color primaryDarkTeal = const Color(0xFF0C8A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          // ใช้ Expanded เพื่อให้ ListView กินพื้นที่ที่เหลือทั้งหมด (เลื่อนขึ้นลงได้)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildRouteCard(
                  title: 'Khlong Saan Sap',
                  distance: '1 km',
                  description:
                      'Explore this for one reason!\nto Find One Piece Because\nof that we have to survey',
                ),
                const SizedBox(height: 15),
                _buildRouteCard(
                  title: 'Khlong Saan Sap',
                  distance: '1 km',
                  description:
                      'Explore this for one reason!\nto Find One Piece Because\nof that we have to survey',
                ),
                // TODO: ในอนาคตสามารถใช้ ListView.builder โหลดข้อมูลจาก Database มาแสดงตรงนี้ได้
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ส่วนหัว (Header) สีเขียวเข้ม โค้งมนด้านล่าง
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 15,
        bottom: 25,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: primaryDarkTeal,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context), // กดย้อนกลับ
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Saved Route',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // วิดเจ็ตสำหรับสร้างกล่องประวัติเส้นทางแต่ละอัน
  Widget _buildRouteCard({
    required String title,
    required String distance,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE), // สีเทาอ่อนๆ คล้ายในรูป
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              color: Color(0xFF4A4A4A), // สีเทาเข้ม
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Distances $distance',
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B6B6B)),
          ),
          const SizedBox(height: 15),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B6B6B),
                    height: 1.3, // เพิ่มระยะห่างบรรทัดให้อ่านง่ายขึ้น
                  ),
                ),
              ),
              // ปุ่มลูกศร
              GestureDetector(
                onTap: () {
                  // TODO: ลิงก์ไปหน้าดูรายละเอียดเส้นทาง
                },
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.black87,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
