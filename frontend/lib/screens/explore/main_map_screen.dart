import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../widgets/custom_bottom_nav_item.dart';
import '../../widgets/circular_map_button.dart';
import '../../routes/app_routes.dart';
import '../../constants/app_colors.dart';
import '../profile/profile.dart';
import '../../services/route_service.dart';

class MainMaps extends StatefulWidget {
  final bool isGuest; 
  const MainMaps({super.key, this.isGuest = false}); 

  @override
  State<MainMaps> createState() => _MainMapsState();
}

class _MainMapsState extends State<MainMaps> {
  final MapController _mapController = MapController();
  final RouteService _routeService = RouteService(); 
  
  int _currentTabIndex = 0;

  bool _isRecording = false; 
  bool _isPaused = false;    
  final List<List<LatLng>> _recordedRoutes = [];
  double _totalDistance = 0.0;

  LatLng? _currentPosition;
  double _currentHeading = 0.0; 
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isFollowingUser = true;

  final LatLng _initialCenter = const LatLng(13.7946, 100.3236); 
  
  List<Polyline> _cloudPolylines = []; 

  // 🔥 ฟังก์ชันสร้าง Popup ยืนยันการบันทึกเส้นทาง 🔥
  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Start Recording?', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(' Yes or No?', style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), 
              child: const Text('No', style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), 
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Yes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchAllRoutesFromCloud() async {
    try {
      final data = await _routeService.getAllRoutes(); 
      List<Polyline> loadedPolylines = [];

      for (var route in data) {
        if (route['route_points'] != null) {
          List<dynamic> pointsJson = route['route_points'];
          
          List<LatLng> points = pointsJson.map((p) {
            return LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble());
          }).toList();

          if (points.isNotEmpty) {
            loadedPolylines.add(
              Polyline(
                points: points,
                strokeWidth: 5.0,
                color: Colors.purpleAccent.withOpacity(0.6), 
              ),
            );
          }
        }
      }

      if (mounted) {
        setState(() {
          _cloudPolylines = loadedPolylines; 
        });
      }
    } catch (e) {
      print("Error fetching cloud routes: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
    _fetchAllRoutesFromCloud(); 
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController.dispose();
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
      body: IndexedStack(
        index: _currentTabIndex == 2 ? 1 : 0, 
        children: [
          Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom: 15.0,
                  cameraConstraint: CameraConstraint.contain(
                    bounds: LatLngBounds(const LatLng(5.612851, 97.343807), const LatLng(20.464926, 105.637025)),
                  ),
                  onPositionChanged: (camera, hasGesture) {
                    if (hasGesture) {
                      if (_isFollowingUser) {
                        setState(() => _isFollowingUser = false);
                      }
                    }
                  },
                ), 
                children: [
                  TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.example.moremap'),
                  
                  PolylineLayer(
                    polylines: [
                      ..._cloudPolylines, 
                      
                      if (_isRecording && _recordedRoutes.isNotEmpty)
                        ..._recordedRoutes
                            .where((route) => route.isNotEmpty)
                            .map((route) => Polyline(points: route, strokeWidth: 5.0, color: Colors.redAccent))
                    ],
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

              if (_currentTabIndex == 0 && !_isRecording)
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
              else if (_currentTabIndex == 1 || _isRecording)
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
                                Text(
                                  "GPS", 
                                  style: TextStyle(
                                    color: _currentPosition != null ? AppColors.primaryTeal : Colors.grey, 
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 12
                                  )
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 6, 
                                  height: 6, 
                                  decoration: BoxDecoration(
                                    color: _currentPosition != null ? Colors.green : Colors.grey, 
                                    shape: BoxShape.circle
                                  )
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
                ),

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

              if (_currentTabIndex == 1 || _isRecording)
                Positioned(
                  bottom: 20, left: 20, right: 20,
                  child: GestureDetector(
                    onTap: () async {
                      if (!_isRecording) {
                        bool? confirm = await _showConfirmationDialog();

                        if (confirm == true && mounted) {
                          setState(() {
                            _isRecording = true;
                            _isPaused = false;
                            _recordedRoutes.clear();
                            _totalDistance = 0.0;
                            _recordedRoutes.add([]);
                            if (_currentPosition != null) _recordedRoutes.last.add(_currentPosition!);
                          });
                        }
                      } else {
                        final List<LatLng> finalPath = _recordedRoutes.expand((x) => x).toList();
                        
                        setState(() {
                          _isRecording = false;
                          _isPaused = false;
                          _currentTabIndex = 0; 
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('✅ บันทึกเส้นทางสำเร็จ! กำลังไปหน้าแก้ไข...'), backgroundColor: Colors.green)
                        );
                        
                        Navigator.pushNamed(
                          context,
                          AppRoutes.routeDetailEdit,
                          arguments: {
                            'distance': _totalDistance >= 1000 
                                ? "${(_totalDistance / 1000).toStringAsFixed(2)} km" 
                                : "${_totalDistance.toStringAsFixed(0)} m",
                            'isNewRoute': true, 
                            'routePoints': finalPath, 
                          },
                        ).then((_) {
                          _fetchAllRoutesFromCloud();
                        });
                      }
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

          const ProfilePage(),
        ],
      ),
      
      bottomNavigationBar: _isRecording 
          ? _buildRecordingBottomNav() 
          : CustomBottomNavBar( 
              selectedIndex: _currentTabIndex,
              isGuest: widget.isGuest,
              onExploreTap: () {
                setState(() => _currentTabIndex = 0);
                _fetchAllRoutesFromCloud(); 
              }, 
              onAddRouteTap: () => setState(() => _currentTabIndex = 1), 
              onProfileTap: () => setState(() => _currentTabIndex = 2), 
            ),
    );
  }

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