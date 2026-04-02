import 'package:flutter/material.dart';
import 'route_detail.dart';

class SavedRoutePage extends StatefulWidget {
  const SavedRoutePage({super.key});

  @override
  State<SavedRoutePage> createState() => _SavedRoutePageState();
}

class _SavedRoutePageState extends State<SavedRoutePage> {
  final Color primaryDarkTeal = const Color(0xFF0C8A8A);

  // สร้างรายการข้อมูลเส้นทาง (จำลองเป็นข้อมูลเริ่มต้น)
  List<Map<String, String>> routes = [
    {
      'title': 'Khlong Saan Sap',
      'distance': '1 km',
      'description': 'Explore this for one reason!\nto Find One Piece Because\nof that we have to survey',
    },
    {
      'title': 'Khlong Saan Sap', // ข้อมูลสมมติอันที่สอง
      'distance': '1 km',
      'description': 'Explore this for one reason!\nto Find One Piece Because\nof that we have to survey',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          // แสดงผลรายการเส้นทางด้วย ListView.builder
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: routes.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _buildRouteCard(
                    context,
                    index: index,
                    title: routes[index]['title']!,
                    distance: routes[index]['distance']!,
                    description: routes[index]['description']!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ส่วนหัว (Header)
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
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
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

  // กล่องแสดงเส้นทางแต่ละอัน
  Widget _buildRouteCard(
    BuildContext context, {
    required int index,
    required String title,
    required String distance,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 22, color: Color(0xFF4A4A4A)),
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
                    height: 1.3,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  // รอรับข้อมูลกลับมาเมื่อหน้า Detail ปิดตัวลง
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RouteDetailPage(
                        title: title,
                        distance: distance,
                        description: description,
                      ),
                    ),
                  );

                  // หากมีการแก้ไขข้อมูลและส่งค่ากลับมา ให้ทำการอัปเดต List 
                  if (result != null && result is Map<String, String>) {
                    setState(() {
                      routes[index]['title'] = result['title']!;
                      routes[index]['description'] = result['description']!;
                    });
                  }
                },
                child: const Icon(Icons.arrow_forward, color: Colors.black87, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }
}