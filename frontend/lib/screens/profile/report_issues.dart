import 'package:flutter/material.dart';

class ReportIssuesPage extends StatefulWidget {
  const ReportIssuesPage({super.key});

  @override
  State<ReportIssuesPage> createState() => _ReportIssuesPageState();
}

class _ReportIssuesPageState extends State<ReportIssuesPage> {
  final Color primaryDarkTeal = const Color(0xFF0C8A8A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildReportBox(),
        ],
      ),
    );
  }

  // ส่วนหัว (Header) สีเขียวเข้ม โค้งมนด้านล่าง
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top:
            MediaQuery.of(context).padding.top +
            15, // เผื่อพื้นที่ Notch/Status bar
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
            'Report Issues',
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

  // ส่วนกล่องกรอกรายละเอียด Report
  Widget _buildReportBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFE6E6E6), // สีพื้นหลังเทาอ่อน
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            // กล่องพิมพ์ข้อความสีขาว
            Container(
              height: 250, // กำหนดความสูงของกล่องข้อความให้ใกล้เคียงรูป
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // พื้นที่พิมพ์ข้อความ
                  const Expanded(
                    child: TextField(
                      maxLines: null, // พิมพ์ได้หลายบรรทัด
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: 'Bla BLA BLA',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(15),
                      ),
                    ),
                  ),

                  // แถบไอคอนด้านล่าง (+ และ Send)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            size: 30,
                            color: Colors.black87,
                          ),
                          onPressed: () {
                            // TODO: ใส่ฟังก์ชันเพิ่มรูปภาพหรือไฟล์แนบ
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFD9D9D9,
                            ), // สีเทากล่องปุ่ม Send
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.send,
                              size: 22,
                              color: Colors.black87,
                            ),
                            onPressed: () {
                              // TODO: ใส่ฟังก์ชันส่ง Report
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('ส่ง Report เรียบร้อยแล้ว'),
                                ),
                              );
                              Navigator.pop(
                                context,
                              ); // ส่งเสร็จแล้วกลับหน้าเดิม
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
