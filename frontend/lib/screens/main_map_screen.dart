import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/custom_bottom_nav_item.dart';
import '../widgets/circular_map_button.dart';
import 'search_screen.dart'; 
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';

 // or import it from app_colors if defined there

class MainMaps extends StatefulWidget {
  // 👉 1. เพิ่มตัวแปรนี้มารอรับค่าสถานะ Guest
  final bool isGuest; 

  // 👉 2. แก้ Constructor ให้มี this.isGuest
  const MainMaps({super.key, this.isGuest = false}); 

  @override
  State<MainMaps> createState() => _MainMapsState();
}

class _MainMapsState extends State<MainMaps> {
  final MapController _mapController = MapController();
  
  // ตัวแปรสำหรับเก็บพิกัดปัจจุบัน
  LatLng? _currentPosition;
  double _currentHeading = 0.0; // 👉 เพิ่มตัวแปรนี้: เก็บองศาว่าเราหันหน้าไปทางไหน
  
  // ตัวแปรสำหรับดักฟังการเคลื่อนที่ (Stream)
  StreamSubscription<Position>? _positionStreamSubscription;
  /// เพื่อเช็กว่ากล้องแผนที่ควรจะจับจ้องอยู่ที่ตัวเราตลอดเวลาไหม
  bool _isFollowingUser = true;

  final LatLng _initialCenter = const LatLng(13.7946, 100.3236); // พิกัดเริ่มต้น

  // สร้าง List เก็บหมุดของจุดแวะพัก
  List<Marker> _poiMarkers = [];

  // ฟังก์ชันดึงจุดแวะพักสำหรับนักปั่น
  Future<void> _fetchCyclingPOIs(LatLngBounds bounds) async {
    // หาขอบเขตหน้าจอแผนที่ปัจจุบันเพื่อส่งไปให้ API
    final south = bounds.south;
    final west = bounds.west;
    final north = bounds.north;
    final east = bounds.east;

    // คำสั่ง Overpass QL: ขอข้อมูล ปั๊มน้ำมัน, สวนสาธารณะ, ร้านสะดวกซื้อ, และจุดเติมน้ำดื่ม
    String query = '''
      [out:json][timeout:25];
      (
        node["amenity"="fuel"]($south,$west,$north,$east);
        node["leisure"="park"]($south,$west,$north,$east);
        node["shop"="convenience"]($south,$west,$north,$east);
        node["amenity"="drinking_water"]($south,$west,$north,$east);
      );
      out body;
    ''';

    final url = Uri.parse('https://overpass-api.de/api/interpreter');
    
    try {
      final response = await http.post(url, body: {'data': query});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        setState(() {
          _poiMarkers = elements.map((element) {
            final lat = element['lat'];
            final lon = element['lon'];
            final tags = element['tags'] ?? {};
            
            // กำหนดไอคอนและสีตามประเภทสถานที่
            IconData icon = Icons.place;
            Color iconColor = Colors.grey;
            
            if (tags['amenity'] == 'fuel') {
              icon = Icons.local_gas_station;
              iconColor = Colors.orange;
            } else if (tags['leisure'] == 'park') {
              icon = Icons.park;
              iconColor = Colors.green;
            } else if (tags['shop'] == 'convenience') {
              icon = Icons.storefront;
              iconColor = Colors.blue;
            } else if (tags['amenity'] == 'drinking_water') {
              icon = Icons.water_drop;
              iconColor = Colors.lightBlue;
            }

            return Marker(
              point: LatLng(lat, lon),
              width: 40,
              height: 40,
              child: Icon(icon, color: iconColor, size: 30),
            );
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching POIs: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // เริ่มติดตามพิกัดทันทีที่เปิดหน้านี้
    _startLocationTracking();
  }

  @override
  void dispose() {
    // สำคัญมาก: ต้องยกเลิกการติดตามพิกัดเมื่อปิดหน้าจอเพื่อประหยัดแบตเตอรี่
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  // ฟังก์ชันติดตามพิกัดแบบ Real-time
  Future<void> _startLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // เช็กว่าเปิด GPS หรือยัง
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    // เช็ก Permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    // ตั้งค่าความแม่นยำ (ขยับทุกๆ 5 เมตรให้อัปเดต 1 ครั้ง)
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, 
    );

    // เปิดสตรีมรับพิกัดต่อเนื่อง
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        setState(() {
          final newPosition = LatLng(position.latitude, position.longitude);
            _currentPosition = newPosition; // อัปเดตจุดสีฟ้า
            
            // 👉 เพิ่มบรรทัดนี้: ดึงทิศทางที่กำลังเดินมาอัปเดต (ถ้าเดินอยู่มันจะเปลี่ยนทิศให้)
            _currentHeading = position.heading;
        });
        
        // อัปเดตบรรทัดนี้: ให้กล้องเลื่อนตามตัวเราเฉพาะตอนที่โหมด Following เปิดอยู่
        if (_isFollowingUser) {
          _mapController.move(_currentPosition!, _mapController.camera.zoom);
        }
      }
    );
  }

  // ฟังก์ชันสำหรับปุ่มเป้าเล็ง (กดแล้วเด้งกลับมาที่ตัวเรา)
  void _moveToCurrentLocation() {
    setState(() => _isFollowingUser = true); // เปิดโหมดกล้องเกาะติด
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 16.0);
    } else {
      _startLocationTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. แผนที่
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 15.0,
              // ล็อกพื้นที่ให้อยู่แค่ในประเทศไทย (กรอบสี่เหลี่ยม Bounding Box ของไทย)
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  const LatLng(5.612851, 97.343807),  // จุดซ้ายล่าง (South West)
                  const LatLng(20.464926, 105.637025), // จุดขวาบน (North East)
                ),
              ),
              onPositionChanged: (camera, hasGesture) {
                // ถ้าผู้ใช้ใช้นิ้วเลื่อนแผนที่ (hasGesture) ให้โหลดสถานที่ใหม่
                if (hasGesture && camera.bounds != null) {
                  _fetchCyclingPOIs(camera.bounds!);
                }
              },
            ), // <--- แก้ไขวงเล็บตรงนี้ให้ถูกต้องแล้วครับ
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // 👇 เติมบรรทัดนี้ลงไปครับ (บอกให้เซิร์ฟเวอร์รู้ว่าแอปเราชื่ออะไร)
                userAgentPackageName: 'com.example.moremap', 
              ),
              
              // ---> เพิ่ม MarkerLayer สำหรับจุดแวะพัก (POIs) ตรงนี้ <---
              MarkerLayer(
                markers: _poiMarkers,
              ),

              MarkerLayer(
                markers: [
                  // หมุดตำแหน่งปัจจุบัน
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      width: 60, height: 60,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle),
                        child: Center(
                          child: Transform.rotate(
                            angle: (_currentHeading * 3.14159) / 180, // หมุนตามองศา
                            child: const Icon(Icons.navigation, color: Colors.blue, size: 28),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 2. แถบค้นหา
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 15,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: GestureDetector( 
                onTap: () async {
                  // สั่งเปิดหน้า SearchScreen และรอรับค่าพิกัดที่จะ return กลับมา
                  final LatLng? result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchScreen()),
                  );

                  // ถ้าได้พิกัดกลับมาจากการค้นหา
                  if (result != null) {
                    setState(() {
                      _isFollowingUser = false; // ปิดโหมดกล้องเกาะติดตัวเราชั่วคราว
                    });
                    // สั่งเลื่อนกล้องไปที่สถานที่เป้าหมาย
                    _mapController.move(result, 15.0); 
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 15),
                      const Icon(Icons.search, color: Colors.black87, size: 28),
                      const SizedBox(width: 10),
                      Text("Search", style: TextStyle(color: Colors.grey[600], fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. ปุ่มด้านขวา
          Positioned(
            top: 130,
            right: 15,
            child: Column(
              children: [
                // สั่งให้ปุ่ม GPS ดึงกล้องกลับมาที่ตัวเรา
                // 👉 เปลี่ยนจาก _buildMapButton มาใช้ CircularMapButton 
                CircularMapButton(
                  iconData: Icons.my_location, 
                  onPressed: _moveToCurrentLocation,
                ),
                
                const SizedBox(height: 10),
                
                // สั่งหมุนกลับทิศเหนือ
                // 👉 เปลี่ยนจาก _buildMapButton มาใช้ CircularMapButton
                CircularMapButton(
                  iconData: Icons.explore_outlined, 
                  onPressed: () {
                    _mapController.rotate(0); 
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      
      // 4. แถบเมนูด้านล่าง
      // ใส่ต่อจาก body: Stack(...),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 0,
        isGuest: widget.isGuest, // 👉 เพิ่มบรรทัดนี้: ส่งสถานะ Guest ต่อไปให้ยามหน้าประตู
      ),
    ); // ปิด Scaffold
  }
}