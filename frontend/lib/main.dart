import 'package:flutter/material.dart';
// อย่าลืม import ไฟล์หน้าแผนที่ของเราเข้ามา
import 'screens/main_map_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoreMap',
      theme: ThemeData(
        // ปรับสีหลักของแอปตรงนี้ให้ตรงกับใน Figma ได้เลยครับ
        primarySwatch: Colors.teal,
      ),
      // ตรงนี้แหละครับคือตัวสั่งให้เปิดหน้าแผนที่เป็นหน้าแรก!
      home: const MainMaps(),
      // เอาแถบ Debug สีแดงมุมขวาบนออกจะได้ดู UI คลีนๆ
      debugShowCheckedModeBanner: false,
    );
  }
}
