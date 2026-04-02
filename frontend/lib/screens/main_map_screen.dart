import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/custom_bottom_nav_item.dart';
import '../widgets/circular_map_button.dart';
import '../routes/app_routes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';

class MainMaps extends StatefulWidget {
  final bool isGuest; 
  const MainMaps({super.key, this.isGuest = false}); 

  @override
  State<MainMaps> createState() => _MainMapsState();
}

class _MainMapsState extends State<MainMaps> {
  final MapController _mapController = MapController();
  
  // 👉 1. ตัวแปรคุม Tab (0 = Explore, 1 = Add Route)
  int _currentTabIndex = 0;
  Timer? _debounceTimer;

  // 👉 2. ตัวแปรสำหรับการบันทึกเส้นทาง (Record)
  bool _isRecording = false; 
  bool _isPaused = false;    
  final List<List<LatLng>> _recordedRoutes = [];
  double _totalDistance = 0.0;

  LatLng? _currentPosition;
  double _currentHeading = 0.0; 
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isFollowingUser = true;

  final LatLng _initialCenter = const LatLng(13.7946, 100.3236); 
  List<Marker> _poiMarkers = [];

  Future<void> _fetchCyclingPOIs(LatLngBounds bounds) async {
    final south = bounds.south;
    final west = bounds.west;
    final north = bounds.north;
    final east = bounds.east;

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
            IconData icon = Icons.place;
            Color iconColor = Colors.grey;
            
            if (tags['amenity'] == 'fuel') { icon = Icons.local_gas_station; iconColor = Colors.orange; } 
            else if (tags['leisure'] == 'park') { icon = Icons.park; iconColor = Colors.green; } 
            else if (tags['shop'] == 'convenience') { icon = Icons.storefront; iconColor = Colors.blue; } 
            else if (tags['amenity'] == 'drinking_water') { icon = Icons.water_drop; iconColor = Colors.lightBlue; }

            return Marker(point: LatLng(lat, lon), width: 40, height: 40, child: Icon(icon, color: iconColor, size: 30));
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
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    const LocationSettings locationSettings = LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5);

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        if (mounted) {
          setState(() {
            final newPosition = LatLng(position.latitude, position.longitude);
            _currentPosition = newPosition; 
            _currentHeading = position.heading;

            if (_isRecording && !_isPaused) {
              if (_recordedRoutes.isEmpty) {
                _recordedRoutes.add([]); 
              }
              if (_recordedRoutes.last.isNotEmpty) {
                final lastPoint = _recordedRoutes.last.last;
                const distance = Distance(); 
                final double meters = distance(lastPoint, newPosition);
                if (meters > 1.0) _totalDistance += meters;
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
          // 🗺️ 1. แผนที่
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 15.0,
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(const LatLng(5.612851, 97.343807), const LatLng(20.464926, 105.637025)),
              ),
              // 👉 แก้ไขตรง onPositionChanged ทั้งก้อนเป็นแบบนี้ครับ
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) {
                  // 1. สั่ง setState แค่ครั้งเดียว (เฉพาะตอนที่กล้องยังล็อกอยู่) จะได้ไม่ Rebuild หน้าจอรัวๆ
                  if (_isFollowingUser) {
                    setState(() => _isFollowingUser = false);
                  }
                  // 2. ยกเลิกการโหลดเก่าทิ้งไปก่อน
                  if (_debounceTimer?.isActive ?? false) {
                    _debounceTimer!.cancel();
                  }
                  // 3. ตั้งเวลาใหม่: รอให้หยุดเลื่อนจอ 500 มิลลิวินาที (ครึ่งวินาที) แล้วค่อยโหลด POIs
                  _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                    if (camera.bounds != null) {
                      _fetchCyclingPOIs(camera.bounds!);
                    }
                  });
                }
              },
            ), 
            children: [
              TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.moremap'),
              MarkerLayer(markers: _poiMarkers),
              
              if (_isRecording && _recordedRoutes.isNotEmpty)
                PolylineLayer(
                  polylines: _recordedRoutes
                      .where((route) => route.isNotEmpty)
                      .map((route) => Polyline(points: route, strokeWidth: 5.0, color: Colors.redAccent))
                      .toList(),
                ),

              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!, width: 60, height: 60,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle),
                        child: Center(child: Transform.rotate(angle: (_currentHeading * 3.14159) / 180, child: const Icon(Icons.navigation, color: Colors.blue, size: 28))),
                      ),
                    ),
                  
                  if (_isRecording && _recordedRoutes.any((route) => route.isNotEmpty))
                    Marker(
                      point: _recordedRoutes.lastWhere((route) => route.isNotEmpty).last, width: 12, height: 12,
                      child: Container(decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                    ),
                ],
              ),
            ],
          ),

          // 🔍 2. UI ด้านบนสุด (สลับตาม Tab)
          if (_currentTabIndex == 0 && !_isRecording)
            // Tab 0: แถบค้นหา
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 15, left: 20, right: 20),
                decoration: const BoxDecoration(
                  color: AppColors.primaryTeal,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                ),
                child: GestureDetector( 
                  onTap: () async {
                    // 👉 สั่งเปิดหน้า Search และรอรับค่า LatLng กลับมา (อย่าลืม as LatLng? ด้วยนะครับ)
                    final LatLng? result = await Navigator.pushNamed(context, AppRoutes.search) as LatLng?;
                    
                    if (result != null) {
                      setState(() => _isFollowingUser = false);
                      _mapController.move(result, 15.0); 
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
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
            )
          else
            // Tab 1 หรือตอนกด Record: แถบสีเขียวเข้มด้านบน (ตามรูปภาพเป๊ะๆ)
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                color: AppColors.primaryTeal,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 15, bottom: 15, left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(_isRecording ? "Recording " : "Record Route", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        if (_isRecording)
                          Container(width: 18, height: 18, decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle)),
                      ],
                    ),
                    if (!_isRecording)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                        child: Row(
                          children: [
                            const Text("GPS", style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(width: 4),
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ),

          // 🏃 3. ป้ายบอกระยะทาง (โชว์ตอน Record เท่านั้น)
          if (_isRecording)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80, left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
                child: Row(
                  children: [
                    const Icon(Icons.directions_walk, color: AppColors.primaryTeal),
                    const SizedBox(width: 8),
                    Text(
                      _totalDistance >= 1000 ? "${(_totalDistance / 1000).toStringAsFixed(2)} km" : "${_totalDistance.toStringAsFixed(0)} m",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

          // 🎯 4. ปุ่มเล็งเป้าด้านขวา
          Positioned(
            top: (_currentTabIndex == 0 && !_isRecording) ? 130 : MediaQuery.of(context).padding.top + 80, 
            right: 15,
            child: Column(
              children: [
                CircularMapButton(iconData: Icons.my_location, onPressed: _moveToCurrentLocation),
                const SizedBox(height: 10),
                CircularMapButton(iconData: Icons.explore_outlined, onPressed: () => _mapController.rotate(0)),
              ],
            ),
          ),

          // 🟩 5. ปุ่ม Start/Finish สีเขียวใหญ่ตรงกลางล่าง
          if (_currentTabIndex == 1 || _isRecording)
            Positioned(
              bottom: 20, left: 20, right: 20,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (!_isRecording) {
                      // 👉 เริ่มอัดเส้นทาง
                      _isRecording = true;
                      _isPaused = false;
                      _recordedRoutes.clear();
                      _totalDistance = 0.0;
                      _recordedRoutes.add([]);
                      if (_currentPosition != null) _recordedRoutes.last.add(_currentPosition!);
                    } else {
                      // 👉 กดหยุดอัดเส้นทาง
                      _isRecording = false;
                      _isPaused = false;
                      _currentTabIndex = 0; // เด้งกลับไปหน้า Explore
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ เส้นทางถูกบันทึกเรียบร้อย!'), backgroundColor: Colors.green));
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
      
      // 6. แถบเมนูด้านล่างสุด
      bottomNavigationBar: _isRecording 
          ? _buildRecordingBottomNav() // โหมดบันทึกโชว์ Pause
          : CustomBottomNavBar( // โหมดปกติโชว์เมนู 3 ปุ่ม
              selectedIndex: _currentTabIndex,
              isGuest: widget.isGuest,
              onExploreTap: () => setState(() => _currentTabIndex = 0), // สลับกลับหน้าแรก
              onAddRouteTap: () => setState(() => _currentTabIndex = 1), // สลับไปหน้าเตรียมบันทึก
            ),
    ); 
  }

  // --- Widget ย่อย: ปุ่ม Pause/Resume ตอนกำลัง Record ---
  Widget _buildRecordingBottomNav() {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                if (!_isPaused) {
                  _recordedRoutes.add([]); 
                  if (_currentPosition != null) _recordedRoutes.last.add(_currentPosition!);
                }
                _isPaused = !_isPaused; 
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isPaused ? Icons.play_arrow_outlined : Icons.radio_button_checked, 
                  size: 40, 
                  color: Colors.black87
                ),
                const SizedBox(height: 4),
                Text(_isPaused ? "Resume" : "Pause", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}