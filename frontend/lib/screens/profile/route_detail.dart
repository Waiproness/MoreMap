import 'package:flutter/material.dart';
import '../../routes/app_routes.dart'; // 👉 นำเข้า AppRoutes

class RouteDetailPage extends StatefulWidget {
  const RouteDetailPage({super.key});

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> {
  late String displayTitle;
  late String displayDescription;
  late String displayDistance;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      displayTitle = args?['title'] ?? 'Unknown Route';
      displayDescription = args?['description'] ?? 'No description provided.';
      displayDistance = args?['distance'] ?? '0 km';
      
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C8A8A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBEB),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Header: ปุ่ม Back และปุ่ม Edit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios, size: 28, color: Colors.black87),
                    ),
                    
                    // ปุ่ม Edit ไปหน้าแก้ไข
                    ElevatedButton(
                      onPressed: () async {
                        // 👉 ใช้ AppRoutes.routeDetailEdit แทนการพิมพ์สตริงเอง
                        final result = await Navigator.pushNamed(
                          context,
                          AppRoutes.routeDetailEdit, 
                          arguments: {
                            'title': displayTitle,
                            'distance': displayDistance,
                            'description': displayDescription,
                            'isNewRoute': false, // ไม่ใช่การสร้างใหม่
                          },
                        );

                        // ถ้าแก้ไขและส่งข้อมูลกลับมา ให้อัปเดต UI ชั่วคราวบนจอนี้
                        if (result != null && result is Map<String, String>) {
                          setState(() {
                            displayTitle = result['title']!;
                            displayDescription = result['description']!;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF989898),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        elevation: 0,
                      ),
                      child: const Text('Edit', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // 2. ข้อมูลเส้นทาง
                Text(
                  'Route: $displayTitle',
                  style: const TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Distance: $displayDistance',
                  style: const TextStyle(fontSize: 20, color: Colors.black87),
                ),
                const SizedBox(height: 25),

                // 3. กรอบแผนที่จำลอง
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Colors.white),
                ),
                const SizedBox(height: 25),

                // 4. คำอธิบาย
                Text(
                  displayDescription,
                  style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.3),
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