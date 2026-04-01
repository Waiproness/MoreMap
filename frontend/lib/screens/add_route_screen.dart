import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/circular_map_button.dart'; 
import '../widgets/custom_bottom_nav_item.dart'; // <--- แก้ Import เป็นไฟล์นี้ครับ
import '../constants/app_colors.dart';

class AddRouteScreen extends StatefulWidget {
  const AddRouteScreen({super.key});

  @override
  State<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  final MapController _mapController = MapController();
  
  // ตัวแปรควบคุมสถานะหน้าจอ
  bool _isRecording = false; 
  bool _isPaused = false;    

  // ตัวแปรสำหรับ GPS
  LatLng? _currentPosition;
  double _currentHeading = 0.0; // 👉 เพิ่มบรรทัดนี้: เก็บองศาการหันหน้า
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isFollowingUser = true;

  // ถังเปล่าสำหรับเก็บพิกัด GPS จริงๆ ตอนที่เรากำลังเดิน
  // เปลี่ยนจาก List ธรรมดา เป็น List ที่เก็บ List อีกที (แยกเป็นหลายๆ เส้น)
  final List<List<LatLng>> _recordedRoutes = [];

  // 👉 เพิ่มตัวแปรนี้: เก็บระยะทางรวม (หน่วยเป็นเมตร)
  double _totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _startLocationTracking(); // เริ่มดึง GPS ทันทีที่เปิดหน้านี้
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel(); // ปิด GPS ตอนออกหน้าต่างนี้
    super.dispose();
  }

  // ฟังก์ชันดึงพิกัด GPS
  // ฟังก์ชันดึงพิกัด GPS
  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, 
    );

    // 👇 ครึ่งล่างที่มี setState อยู่ตรงนี้ครับ!
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        if (mounted) { 
          setState(() { // <--- setState แอบอยู่ตรงนี้!
            // 1. สร้างตัวแปรเก็บพิกัดใหม่ที่เพิ่งได้รับมา
            final newPosition = LatLng(position.latitude, position.longitude);
            _currentPosition = newPosition; // อัปเดตจุดสีฟ้า
            
            // 👉 เพิ่มแล้ว: ดึงทิศทางมาให้ลูกศรหมุนตาม
            _currentHeading = position.heading; 
            
            // 2. ถ้ากำลังกด Record อยู่ และไม่ได้กด Pause ให้เอาพิกัดใหม่ใส่ลงในถัง
            if (_isRecording && !_isPaused) {
              if (_recordedRoutes.isEmpty) {
                _recordedRoutes.add([]); 
              }
              
              // คำนวณระยะทาง
              if (_recordedRoutes.last.isNotEmpty) {
                // ดึงจุดล่าสุดที่เรายืนอยู่ก่อนหน้านี้
                final lastPoint = _recordedRoutes.last.last;
                // คำนวณระยะห่างระหว่างจุดเก่า กับจุดใหม่ที่เพิ่งก้าวเดิน
                const distance = Distance(); 
                final double meters = distance(lastPoint, newPosition);
                
                // ถ้าระยะห่างเกิน 1 เมตร ค่อยบวกเพิ่ม (กัน GPS แกว่งตอนยืนเฉยๆ)
                if (meters > 1.0) {
                  _totalDistance += meters;
                }
              }
              
              _recordedRoutes.last.add(newPosition);
            }
          });
          
          if (_isFollowingUser) {
            _mapController.move(_currentPosition!, _mapController.camera.zoom);
          }
        }
      }
    );
  }
  // ฟังก์ชันพากล้องกลับมาหาตัวเอง
  void _moveToCurrentLocation() {
    setState(() => _isFollowingUser = true);
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 16.0);
    } else {
      _startLocationTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryTeal,
        automaticallyImplyLeading: false, 
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  _isRecording ? "Recording " : "Record Route",
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if (_isRecording) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 15, height: 15,
                    decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                  ),
                ]
              ],
            ),
            if (!_isRecording)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    Text("GPS", style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 4),
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  ],
                ),
              )
          ],
        ),
      ),
      
      body: Stack(
        children: [
          // 1. แผนที่
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(13.7946, 100.3236),
              initialZoom: 16.0,
              onPositionChanged: (camera, hasGesture) {
                // ถ้าเอานิ้วเลื่อนแผนที่ ให้ปิดการเกาะติดกล้องชั่วคราว
                if (hasGesture) {
                  setState(() => _isFollowingUser = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // 👇 เติมบรรทัดนี้ลงไปครับ (บอกให้เซิร์ฟเวอร์รู้ว่าแอปเราชื่ออะไร)
                userAgentPackageName: 'com.example.moremap', 
              ),
              
              // เส้นทางสีแดง
              // วาดเส้นทางสีแดง (วนลูปวาดทีละเส้นจากทุกถัง)
              if (_isRecording && _recordedRoutes.isNotEmpty)
                PolylineLayer(
                  polylines: _recordedRoutes
                      .where((route) => route.isNotEmpty) // เอาเฉพาะถังที่มีพิกัด
                      .map((route) => Polyline(
                            points: route,
                            strokeWidth: 4.0,
                            color: Colors.redAccent,
                          ))
                      .toList(),
                ),

              // หมุดแผนที่
              MarkerLayer(
                markers: [
                  // 👉 เปลี่ยนจุดสีฟ้า เป็นลูกศรตรงนี้ครับ
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      width: 60, height: 60,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle),
                        child: Center(
                          child: Transform.rotate(
                            angle: (_currentHeading * 3.14159) / 180, // หมุนตามองศาที่เราหันหน้า
                            child: const Icon(Icons.navigation, color: Colors.blue, size: 28),
                          ),
                        ),
                      ),
                    ),
                  
                  // หมุดจุดสิ้นสุดสีแดง (หาพิกัดสุดท้ายจากถังใบล่าสุดที่มีของ)
                  if (_isRecording && _recordedRoutes.any((route) => route.isNotEmpty))
                    Marker(
                      point: _recordedRoutes.lastWhere((route) => route.isNotEmpty).last, 
                      width: 12, height: 12,
                      child: Container(decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                    ),
                ],
              ),   
            ],
          ),
          // 👉 เพิ่มป้ายโชว์ระยะทางมุมซ้ายบน (โชว์เฉพาะตอนกด Record)
          if (_isRecording)
            Positioned(
              top: 20,
              left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_walk, color: AppColors.primaryTeal),
                    const SizedBox(width: 8),
                    Text(
                      // ถ้าเกิน 1000 เมตร ให้โชว์เป็นกิโลเมตร (km) แต่ถ้าไม่ถึงให้โชว์เป็นเมตร (m)
                      _totalDistance >= 1000 
                          ? "${(_totalDistance / 1000).toStringAsFixed(2)} km" 
                          : "${_totalDistance.toStringAsFixed(0)} m",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          // ปุ่มเข็มทิศและ GPS ด้านขวาบน
          if (!_isRecording)
            Positioned(
              top: 20,
              right: 15,
              child: Column(
                children: [
                  CircularMapButton(
                    iconData: Icons.my_location,
                    onPressed: _moveToCurrentLocation, 
                  ),
                  const SizedBox(height: 10),
                  CircularMapButton(
                    iconData: Icons.explore,
                    onPressed: () {
                      _mapController.rotate(0);
                    },
                  ),
                ],
              ),
            ),

          // 2. ปุ่ม Start / Finish กลางจอด้านล่าง
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (!_isRecording) {
                    // กดเริ่มบันทึก
                    // ตอนกดเริ่มบันทึก
                    _isRecording = true;
                    _isPaused = false;
                    _recordedRoutes.clear(); // เคลียร์กล่องทิ้งทั้งหมด
                    _totalDistance = 0.0; // 👉 เพิ่มบรรทัดนี้: รีเซ็ตระยะทางกลับเป็น 0 ตอนเริ่มใหม่ 
                    _recordedRoutes.add([]); // สร้างถังใบที่ 1 รอไว้เลย
                    
                    if (_currentPosition != null) {
                      _recordedRoutes.last.add(_currentPosition!);
                    }
                  } else {
                    // กดปุ่ม Finished 
                    _isRecording = false; 
                    _isPaused = false;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('เส้นทางถูกบันทึกเรียบร้อย!')));
                    Navigator.pop(context); 
                  }
                });
              },
              child: Container(
                height: 55,
                decoration: BoxDecoration(
                  color: _isRecording ? Colors.green[700] : AppColors.primaryTeal,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_isRecording) ...[
                        const Icon(Icons.sync, color: Colors.white),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        _isRecording ? "Finished Your Route" : "Start Record Route",
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // 3. แถบเมนูด้านล่างสุด
      bottomNavigationBar: _isRecording
          ? Container(
              height: 85,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (!_isPaused) {
                            _recordedRoutes.add([]); // งอกถังใบใหม่ เส้นจะได้ขาดจากกัน
                            if (_currentPosition != null) {
                              _recordedRoutes.last.add(_currentPosition!); // บันทึกจุดเริ่มของเส้นใหม่ทันที
                            }
                          }
                          _isPaused = !_isPaused; 
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_isPaused ? Icons.play_arrow_outlined : Icons.pause_circle_outline, size: 40, color: Colors.black87),
                          const SizedBox(height: 4),
                          Text(
                            _isPaused ? "Resume" : "Pause",
                            style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const CustomBottomNavBar(selectedIndex: 1), 
    );
  }
}