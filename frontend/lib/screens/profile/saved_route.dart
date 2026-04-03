import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👉 นำเข้าระบบโหลดข้อมูล
import '../../routes/app_routes.dart';

class SavedRoutePage extends StatefulWidget {
  const SavedRoutePage({super.key});

  @override
  State<SavedRoutePage> createState() => _SavedRoutePageState();
}

class _SavedRoutePageState extends State<SavedRoutePage> {
  final Color primaryDarkTeal = const Color(0xFF0C8A8A);
  List<Map<String, String>> routes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoutesFromLocal();
  }

  // 👉 ฟังก์ชันโหลดข้อมูลจากในเครื่อง (SharedPreferences)
  Future<void> _fetchRoutesFromLocal() async {
    setState(() => isLoading = true);
    
    // หน่วงเวลาให้ดูเหมือนโหลดข้อมูลนิดนึง
    await Future.delayed(const Duration(milliseconds: 500)); 
    
    final prefs = await SharedPreferences.getInstance();
    final String? routesString = prefs.getString('saved_routes');

    if (mounted) {
      if (routesString != null) {
        // มีข้อมูลที่ถูกเซฟไว้ เอามาโชว์
        final List<dynamic> decoded = json.decode(routesString);
        setState(() {
          routes = decoded.map((e) => Map<String, String>.from(e)).toList();
          isLoading = false;
        });
      } else {
        // ยังไม่มีข้อมูลเลย โชว์ Mock Data ไปก่อน
        setState(() {
          routes = [
            {'title': 'Welcome to MoreMap', 'distance': '0 km', 'description': 'Start recording your first route!'}
          ];
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0C8A8A))) 
                : routes.isEmpty
                    ? const Center(child: Text('No saved routes found.', style: TextStyle(fontSize: 18)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: routes.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: _buildRouteCard(
                              context,
                              title: routes[index]['title'] ?? '',
                              distance: routes[index]['distance'] ?? '',
                              description: routes[index]['description'] ?? '',
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 15, bottom: 25, left: 20, right: 20),
      decoration: BoxDecoration(color: primaryDarkTeal, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(25))),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context), 
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 10),
          const Text('Saved Route', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context, {required String title, required String distance, required String description}) {
    return GestureDetector(
      onTap: () async {
        // เปิดหน้า Detail (ดูรายละเอียด)
        await Navigator.pushNamed(
          context,
          AppRoutes.routeDetail, 
          arguments: {
            'title': title,
            'distance': distance,
            'description': description,
          },
        );

        // เวลากด Back ถอยกลับมา ให้ทำการโหลดข้อมูลล่าสุดมาโชว์เสมอ
        if (mounted) {
          _fetchRoutesFromLocal(); 
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 22, color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Distance: $distance', style: const TextStyle(fontSize: 16, color: Color(0xFF6B6B6B))),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    description, 
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis, // กันข้อความล้น
                    style: const TextStyle(fontSize: 16, color: Color(0xFF6B6B6B), height: 1.3)
                  )
                ),
                const Icon(Icons.arrow_forward, color: Colors.black87, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}