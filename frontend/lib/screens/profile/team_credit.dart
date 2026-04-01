import 'package:flutter/material.dart';

class TeamCreditPage extends StatelessWidget {
  const TeamCreditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C8A8A),
      body: SafeArea(
        child: Center(
          child: Container(
            // เพิ่มคำสั่งนี้เพื่อให้กล่องกว้างเต็มพื้นที่ (แต่ยังเว้นระยะ margin ซ้ายขวา 30 ไว้)
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 30),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF8BBFBF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Team Credit',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),

                // สมาชิกคนที่ 1
                // TODO: ใส่รูปภาพโดยเพิ่ม imagePath เช่น _buildTeamMember('6787012', 'Jirawat Pratuangtip', imagePath: 'assets/images/jirawat.png')
                _buildTeamMember('6787012', 'Jirawat Pratuangtip'),
                const SizedBox(height: 30),

                // สมาชิกคนที่ 2
                // TODO: ใส่รูปภาพโดยเพิ่ม imagePath เช่น _buildTeamMember('6787044', 'Theerawat Puvekit', imagePath: 'assets/images/theerawat.png')
                _buildTeamMember('6787044', 'Theerawat Puvekit'),
                const SizedBox(height: 40),

                // ปุ่มย้อนกลับ
                _buildBackButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMember(String studentId, String name) {
    return Column(
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9), // สีเทา Placeholder
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            // TODO: เมื่อมีรูปภาพแล้ว ให้เอาคอมเมนต์ 5 บรรทัดด้านล่างนี้ออก เพื่อแสดงรูป
            // image: imagePath != null
            //     ? DecorationImage(
            //         image: AssetImage(imagePath),
            //         fit: BoxFit.cover, // ปรับรูปให้พอดีกับวงกลม
            //       )
            //     : null,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          studentId,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center, // จัดให้อยู่กึ่งกลางเสมอ
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(Icons.close, color: Colors.black, size: 24),
      label: const Text(
        'BACK',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE0E0E0),
        elevation: 3,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
