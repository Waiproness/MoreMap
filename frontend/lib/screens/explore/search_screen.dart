import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.isGuest = false});
  final bool isGuest;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Color _primaryTeal = const Color(0xFF008282);
  bool _isLoading = false;
  
  List<String> _searchHistory = [];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory(); 
  }

  // ฟังก์ชันโหลดข้อมูลจากเครื่อง
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('recent_searches') ?? [];
    });
  }

  // ฟังก์ชันบันทึกข้อมูลลงเครื่อง
  Future<void> _saveSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _searchHistory.remove(query);
      _searchHistory.insert(0, query);
      if (_searchHistory.length > 5) {
        _searchHistory.removeLast();
      }
    });

    await prefs.setStringList('recent_searches', _searchHistory);
  }

  // 🚀 ฟังก์ชันยิง API ไปถามหาพิกัด (อัปเกรดระบบดักจับคำค้นหาแล้ว)
  Future<void> _searchPlace(String query) async {
    String searchText = query.trim();
    
    // --- 🛡️ 1. ดักจับข้อความว่างเปล่า ---
    if (searchText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ กรุณาพิมพ์ชื่อสถานที่ก่อนค้นหา'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return; // 🛑 หยุดทำงาน
    }
    
    // --- 🛡️ 2. ดักจับตัวเลขและอักขระพิเศษ ---
    bool isOnlyNumbers = RegExp(r'^[0-9]+$').hasMatch(searchText);
    bool isOnlySpecialChars = RegExp(r'^[^a-zA-Z0-9ก-๙]+$').hasMatch(searchText);

    if (isOnlyNumbers) {
      FocusManager.instance.primaryFocus?.unfocus(); // ซ่อนคีย์บอร์ด
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ ค้นหาด้วยตัวเลขอย่างเดียวไม่ได้ครับ กรุณาระบุชื่อสถานที่'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return; // 🛑 สั่งหยุดการทำงาน ไม่บันทึกประวัติ ไม่ยิง API
    }

    if (isOnlySpecialChars) {
      FocusManager.instance.primaryFocus?.unfocus(); // ซ่อนคีย์บอร์ด
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ ค้นหาด้วยอักขระพิเศษอย่างเดียวไม่ได้ครับ'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return; // 🛑 สั่งหยุดการทำงาน
    }
    // ------------------------------------

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => _isLoading = true);
    await _saveSearchHistory(searchText); 

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final url = 'https://nominatim.openstreetmap.org/search?q=$searchText&format=json&limit=1';
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ ไม่พบสถานที่นี้ ลองเปลี่ยนคำค้นหาดูนะครับ'),
                backgroundColor: Colors.redAccent, 
                behavior: SnackBarBehavior.floating, 
                duration: Duration(seconds: 3), 
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error searching place: $e');
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
          // ส่วน Header สีเขียว
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
                      maxLength: 100, // 🔥 3. ล็อคความยาวไม่เกิน 100 ตัวอักษร
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(color: Colors.grey[600], fontSize: 18),
                        prefixIcon: const Icon(Icons.search, color: Colors.black87, size: 28),
                        border: InputBorder.none,
                        counterText: "", // 🔥 4. ซ่อนตัวนับเลขเพื่อความคลีนของ UI
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

          // ส่วนแสดงประวัติการค้นหาแบบ Dynamic
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
    );
  }

  Widget _buildHistoryCard(String text) {
    return InkWell(
      onTap: () => _searchPlace(text),
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
}