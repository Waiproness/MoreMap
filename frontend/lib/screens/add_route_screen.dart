import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/circular_map_button.dart'; 
import '../constants/app_colors.dart';
// 👉 เรียกใช้ AppRoutes เพื่อความคลีนในการจัดการหน้าจอ
import '../routes/app_routes.dart';

class AddRouteScreen extends StatefulWidget {
  const AddRouteScreen({super.key});

  @override
  State<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  final MapController _mapController = MapController();
  
  // 👉 ตั้งค่าให้เป็นโหมดกำลังบันทึกตั้งแต่เริ่มเปิดหน้านี้
  bool _isRecording = true; 
  bool _isPaused = false;    

  LatLng? _currentPosition;
  double _currentHeading = 0.0; 
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isFollowingUser = true;

  final List<List<LatLng>> _recordedRoutes = [[]]; // เก็บพิกัดเส้นทาง
  double _totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _startLocationTracking(); 
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel(); 
    super.dispose();
  }

  // ระบบติดตามตำแหน่ง GPS
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

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        if (mounted) { 
          setState(() { 
            final newPosition = LatLng(position.latitude, position.longitude);
            _currentPosition = newPosition; 
            _currentHeading = position.heading; 
            
            // บันทึกเส้นทางเฉพาะตอนที่ไม่กด Pause
            if (_isRecording && !_isPaused) {
              if (_recordedRoutes.last.isNotEmpty) {
                final lastPoint = _recordedRoutes.last.last;
                const distance = Distance(); 
                final double meters = distance(lastPoint, newPosition);
                
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
      body: Stack(
        children: [
          // 1. แผนที่
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(13.7946, 100.3236),
              initialZoom: 16.0,
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  setState(() => _isFollowingUser = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.moremap', 
              ),
              
              // วาดเส้นทางสีแดงที่บันทึกไว้
              if (_isRecording && _recordedRoutes.isNotEmpty)
                PolylineLayer(
                  polylines: _recordedRoutes
                      .where((route) => route.isNotEmpty) 
                      .map((route) => Polyline(
                            points: route,
                            strokeWidth: 5.0,
                            color: Colors.redAccent,
                          ))
                      .toList(),
                ),

              // MarkerLayer สำหรับแสดงตำแหน่งผู้ใช้และจุดสิ้นสุด
              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      width: 60, height: 60,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle),
                        child: Center(
                          child: Transform.rotate(
                            angle: (_currentHeading * 3.14159) / 180, 
                            child: const Icon(Icons.navigation, color: Colors.blue, size: 28),
                          ),
                        ),
                      ),
                    ),
                  
                  // หมุดสีแดงแสดงพิกัดปัจจุบัน/ล่าสุดที่บันทึก
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

          // 2. ป้ายบอกระยะทางแบบ Real-time
          Positioned(
            top: MediaQuery.of(context).padding.top + 10, left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_walk, color: AppColors.primaryTeal, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    _totalDistance >= 1000 
                        ? "${(_totalDistance / 1000).toStringAsFixed(2)} km" 
                        : "${_totalDistance.toStringAsFixed(0)} m",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),

          // 3. ปุ่มควบคุมแผนที่
          Positioned(
            top: 100, right: 15,
            child: Column(
              children: [
                CircularMapButton(iconData: Icons.my_location, onPressed: _moveToCurrentLocation),
                const SizedBox(height: 10),
                CircularMapButton(iconData: Icons.explore_outlined, onPressed: () => _mapController.rotate(0)),
              ],
            ),
          ),
        ],
      ),

      // 4. แถบควบคุมด้านล่าง (Pause & Finish)
      bottomNavigationBar: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              // ปุ่ม Pause / Resume
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (!_isPaused) {
                        // เมื่อหยุดชั่วคราว ให้เริ่ม List ชุดใหม่เพื่อสร้างช่องว่างของเส้น
                        _recordedRoutes.add([]); 
                        if (_currentPosition != null) {
                          _recordedRoutes.last.add(_currentPosition!);
                        }
                      }
                      _isPaused = !_isPaused; 
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isPaused ? Icons.play_circle_fill : Icons.pause_circle_filled, 
                        size: 45, 
                        color: _isPaused ? Colors.blue : Colors.orange
                      ),
                      Text(_isPaused ? "Resume" : "Pause", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 20),

              // ปุ่ม Finish: สรุปผลและย้ายไปยังหน้าแก้ไขข้อมูล
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () async {
                    if (context.mounted) {
                      // 1. แสดง SnackBar ก่อนเพื่อให้รู้ว่าปุ่มโดนกดแล้ว
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('กำลังบันทึกและไปหน้าแก้ไข...'),
                          backgroundColor: Colors.blue,
                        ),
                      );

                      // 2. ใช้ AppRoutes.routeDetailEdit (ตัวแปร static) แทนการพิมพ์ชื่อ path เอง
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.routeDetailEdit, // 👈 ใช้ตัวแปรนี้จะชัวร์กว่าพิมพ์ '/route-detail-edit'
                        arguments: {
                          'distance': _totalDistance >= 1000 
                              ? "${(_totalDistance / 1000).toStringAsFixed(2)} km" 
                              : "${_totalDistance.toStringAsFixed(0)} m",
                          'isNewRoute': true,
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    "Finish Route", 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}