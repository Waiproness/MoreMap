import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👉 นำเข้าระบบเซฟข้อมูล
import '../../routes/app_routes.dart';

class RouteDetailEditPage extends StatefulWidget {
  const RouteDetailEditPage({super.key});

  @override
  State<RouteDetailEditPage> createState() => _RouteDetailEditPageState();
}

class _RouteDetailEditPageState extends State<RouteDetailEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  String distance = '0 Km';
  bool isNewRoute = false;
  String _initialTitle = ''; // เก็บชื่อเดิมไว้หาในฐานข้อมูล
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      final title = args?['title'] ?? '';
      final description = args?['description'] ?? '';
      
      distance = args?['distance'] ?? '0 Km';
      isNewRoute = args?['isNewRoute'] ?? false;
      _initialTitle = title;

      _titleController.text = title;
      _descriptionController.text = description;

      _isInitialized = true; 
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // 👉 ฟังก์ชันสำหรับเซฟข้อมูลลงเครื่อง
  Future<void> _saveRouteData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? routesString = prefs.getString('saved_routes');
    List<Map<String, String>> currentRoutes = [];

    if (routesString != null) {
      final List<dynamic> decoded = json.decode(routesString);
      currentRoutes = decoded.map((e) => Map<String, String>.from(e)).toList();
    }

    final newRouteData = {
      'title': _titleController.text.isEmpty ? 'Untitled Route' : _titleController.text,
      'distance': distance,
      'description': _descriptionController.text,
      'date': 'Apr 4, 2026', // 👉 อย่าลืมใส่วันที่จำลองเพื่อให้หน้า Profile เอาไปโชว์ได้
    };

    if (isNewRoute) {
      currentRoutes.insert(0, newRouteData); 
    } else {
      int index = currentRoutes.indexWhere((r) => r['title'] == _initialTitle);
      if (index != -1) {
        currentRoutes[index] = newRouteData;
      } else {
        currentRoutes.insert(0, newRouteData);
      }
    }

    await prefs.setString('saved_routes', json.encode(currentRoutes));
  }

  // --- 👉 เพิ่มฟังก์ชันลบข้อมูล ---
  Future<void> _deleteRouteData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? routesString = prefs.getString('saved_routes');
    if (routesString != null) {
      List<dynamic> decoded = json.decode(routesString);
      List<Map<String, String>> currentRoutes = decoded.map((e) => Map<String, String>.from(e)).toList();
      
      // ลบข้อมูลโดยหาจากชื่อเดิม (Initial Title)
      currentRoutes.removeWhere((r) => r['title'] == _initialTitle);
      
      // เซฟข้อมูลที่เหลือกลับลงเครื่อง
      await prefs.setString('saved_routes', json.encode(currentRoutes));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C8A8A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(color: const Color(0xFFEBEBEB), borderRadius: BorderRadius.circular(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ปุ่ม Cancel
                    Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF989898),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          elevation: 0,
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ช่องแก้ไขชื่อ
                    Row(
                      children: [
                        const Text('Route: ', style: TextStyle(fontSize: 20, color: Colors.black87)),
                        Expanded(
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(5)),
                            child: TextField(
                              controller: _titleController,
                              style: const TextStyle(fontSize: 20),
                              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.only(left: 10, bottom: 12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Text('Distance: $distance', style: const TextStyle(fontSize: 20, color: Colors.black87)),
                    const SizedBox(height: 20),

                    // กรอบแผนที่
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(height: 220, width: double.infinity, decoration: const BoxDecoration(color: Colors.white)),
                        Positioned(
                          bottom: -15, right: -15,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(color: Color(0xFF00CACA), shape: BoxShape.circle),
                              child: const Icon(Icons.edit, color: Colors.black, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // ช่องแก้ไขรายละเอียด
                    TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.3),
                      decoration: const InputDecoration(
                        border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                        hintText: 'Write your description here...', 
                      ),
                    ),
                    const SizedBox(height: 40),

                    // ปุ่ม Save และ Delete
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // ปุ่ม Save
                        ElevatedButton(
                          onPressed: () async {
                            await _saveRouteData();

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved Successfully'), backgroundColor: Colors.green));

                              if (isNewRoute) {
                                Navigator.pushReplacementNamed(context, AppRoutes.savedRoute);
                              } else {
                                Navigator.pop(context, {
                                  'title': _titleController.text,
                                  'description': _descriptionController.text,
                                });
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF389C57),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),

                        // 👉 ปุ่ม Delete ที่เรียกฟังก์ชันลบจริงและเด้งกลับหน้าให้ถูก
                        if (!isNewRoute)
                          ElevatedButton(
                            onPressed: () async {
                              // 1. สั่งลบข้อมูลออกจากเครื่อง
                              await _deleteRouteData(); 
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Deleted Successfully'), backgroundColor: Colors.redAccent)
                                );
                                
                                // 2. สั่งปิดหน้า Edit และหน้า Detail ทิ้ง แล้วไปโผล่ที่หน้า Saved Route 
                                // (การทำแบบนี้จะทำให้หน้า Saved Route รีเฟรชข้อมูลอัตโนมัติตามที่เราตั้งค่าไว้)
                                Navigator.popUntil(context, ModalRoute.withName(AppRoutes.savedRoute)); 
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B6B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                              elevation: 0,
                            ),
                            child: const Text('Delete', style: TextStyle(color: Colors.white, fontSize: 18)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}