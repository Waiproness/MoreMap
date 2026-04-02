import 'package:flutter/material.dart';
import 'route_detail_edit.dart';

class RouteDetailPage extends StatefulWidget {
  final String title;
  final String distance;
  final String description;

  const RouteDetailPage({
    super.key,
    required this.title,
    required this.distance,
    required this.description,
  });

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> {
  // สร้างตัวแปรภายในเพื่อเก็บค่าที่สามารถเปลี่ยนแปลงได้
  late String displayTitle;
  late String displayDescription;

  @override
  void initState() {
    super.initState();
    // กำหนดค่าเริ่มต้นจากข้อมูลที่รับมาจากหน้า Saved Route
    displayTitle = widget.title;
    displayDescription = widget.description;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C8A8A), // พื้นหลังสีเขียวเข้ม
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB), // สีเทาอ่อนของกรอบการ์ด
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // ให้กล่องพอดีกับเนื้อหา
              children: [
                // 1. Header: ปุ่ม Back และปุ่ม Edit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // *** ปุ่มย้อนกลับที่แก้ไขให้ส่งข้อมูลกลับไป ***
                    GestureDetector(
                      onTap: () {
                        // ส่งข้อมูลล่าสุดกลับไปยังหน้า Saved Route
                        Navigator.pop(context, {
                          'title': displayTitle,
                          'description': displayDescription,
                        });
                      },
                      child: const Icon(Icons.arrow_back_ios, size: 28, color: Colors.black87),
                    ),
                    
                    // ปุ่ม Edit ไปยังหน้าแก้ไข
                    ElevatedButton(
                      onPressed: () async {
                        // สั่งเปิดหน้า Edit และ "รอ" รับข้อมูลกลับมา
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RouteDetailEditPage(
                              title: displayTitle,
                              distance: widget.distance,
                              description: displayDescription,
                            ),
                          ),
                        );

                        // ถ้ามีข้อมูลส่งกลับมา ให้อัปเดตตัวแปรหน้าจอนี้
                        if (result != null && result is Map<String, String>) {
                          setState(() {
                            displayTitle = result['title']!;
                            displayDescription = result['description']!;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF989898), // สีเทาของปุ่ม Edit
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // 2. ข้อมูลเส้นทาง
                Text(
                  'Route: $displayTitle',
                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Distance: ${widget.distance}',
                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                ),
                const SizedBox(height: 25),

                // 3. กล่องสีขาว Placeholder สำหรับแผนที่หรือรูปภาพ
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),

                // 4. รายละเอียดคำอธิบาย
                Text(
                  displayDescription,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}