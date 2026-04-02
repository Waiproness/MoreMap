import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 👉 1. Import ตัวเก็บข้อมูล
import '../widgets/custom_bottom_nav_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.isGuest = false});
  final bool isGuest;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Color _primaryTeal = const Color(0xFF008282);
  bool _isLoading = false;
  
  // 👉 2. สร้าง List มารอรับประวัติการค้นหา
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory(); // 👉 3. โหลดประวัติขึ้นมาทันทีที่เปิดหน้านี้
  }

  // ฟังก์ชันโหลดข้อมูลจากเครื่อง
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // ดึงข้อมูล Key ชื่อ 'recent_searches' ถ้าไม่มีให้เป็น List ว่าง
      _searchHistory = prefs.getStringList('recent_searches') ?? [];
    });
  }

  // ฟังก์ชันบันทึกข้อมูลลงเครื่อง (พร้อม Logic 5 อัน)
  Future<void> _saveSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // Logic: ถ้ามีคำนี้อยู่แล้ว ให้ลบอันเก่าออกก่อน เพื่อเอามาแปะไว้บนสุด (อันล่าสุด)
      _searchHistory.remove(query);
      
      // เพิ่มเข้าไปที่ตำแหน่งแรกสุด (Index 0)
      _searchHistory.insert(0, query);

      // ถ้าเกิน 5 อัน ให้ตัดอันสุดท้าย (เก่าสุด) ออก
      if (_searchHistory.length > 5) {
        _searchHistory.removeLast();
      }
    });

    // เซฟลงเครื่องจริงๆ
    await prefs.setStringList('recent_searches', _searchHistory);
  }

  // ฟังก์ชันยิง API ไปถามหาพิกัดจากชื่อสถานที่
  Future<void> _searchPlace(String query) async {
    if (query.trim().isEmpty) return;
    
    // 👉 1. สั่งพับคีย์บอร์ดเก็บลงไปก่อน เพื่อให้เห็นแถบโหลดและแจ้งเตือนชัดๆ
    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => _isLoading = true);
    await _saveSearchHistory(query); 

    try {
      // 👉 2. ใส่ Delay หน่วงเวลาเทียม 800 มิลลิวินาที (ให้ UI โชว์แถบโหลดวิ่งๆ ให้ดูสมูทขึ้น)
      await Future.delayed(const Duration(milliseconds: 800));

      final url = 'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1';
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'com.yourcompany.moremap' 
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          
          if (mounted) {
            Navigator.pop(context, LatLng(lat, lon));
          }
        } else {
          // 👉 3. ถ้าหาไม่เจอ ให้โชว์ SnackBar สีแดงเตือนให้ชัดเจน
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ ไม่พบสถานที่นี้ ลองเปลี่ยนคำค้นหาดูนะครับ'),
                backgroundColor: Colors.redAccent, // เปลี่ยนสีพื้นหลังให้ดูเด่นขึ้น
                behavior: SnackBarBehavior.floating, // ให้ป้ายลอยขึ้นมา ไม่ติดขอบล่าง
                duration: Duration(seconds: 3), // ให้อยู่ค้างไว้ 3 วินาที
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error searching place: $e');
      // 👉 4. ดัก Error กรณีเน็ตหลุดหรือเซิร์ฟเวอร์ล่ม
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาลองใหม่'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      // ปิดแถบโหลด
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ส่วน Header สีเขียว (คงเดิม)
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              bottom: 15,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: _primaryTeal,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _searchPlace,
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 18),
                        prefixIcon: const Icon(Icons.search, color: Colors.black87, size: 28),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          if (_isLoading) 
            LinearProgressIndicator(color: _primaryTeal, backgroundColor: Colors.transparent),

          // 5. ส่วนแสดงประวัติการค้นหาแบบ Dynamic
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Latest Search",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 15),
                
                // 👉 วนลูปสร้างประวัติการค้นหาจาก List จริงๆ
                if (_searchHistory.isEmpty)
                  const Center(child: Text("No recent searches", style: TextStyle(color: Colors.grey)))
                else
                  ..._searchHistory.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildHistoryCard(item),
                  )).toList(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildFakeBottomNav(),
    );
  }

  // แก้ไข Card ให้กดแล้วค้นหาได้ทันที
  Widget _buildHistoryCard(String text) {
    return InkWell(
      onTap: () => _searchPlace(text), // 👉 พอกดปุ่มประวัติ ให้ทำการค้นหาคำนั้นทันที
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.history, color: Colors.grey, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                overflow: TextOverflow.ellipsis, // กันชื่อยาวเกินจนล้น
              ),
            ),
            const Icon(Icons.north_west, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  // _buildFakeBottomNav และ _buildNavItem (เหมือนเดิมที่คุณ TP มี)
  Widget _buildFakeBottomNav() {
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
            _buildNavItem(
              icon: Icons.location_on, 
              label: "Explore", 
              isActive: true,
              onTap: () => Navigator.pop(context)
            ),
            _buildNavItem(
              icon: Icons.add, 
              label: "AddRoute", 
              isLarge: true,
              onTap: () {
                if (widget.isGuest) {
                  showLoginRequiredDialog(context);
                  return;
                }
              }
            ),
            _buildNavItem(
              icon: Icons.person_outline, 
              label: "Profile",
              onTap: () {
                if (widget.isGuest) {
                  showLoginRequiredDialog(context);
                  return;
                }
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, bool isActive = false, bool isLarge = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isLarge ? 40 : 30, color: _primaryTeal),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: _primaryTeal, fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}