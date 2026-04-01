import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'search_screen.dart';
// ยืนยันการ import ให้ตรงกับโครงสร้าง
import 'profile/profile.dart';

class MainMaps extends StatefulWidget {
  const MainMaps({super.key});

  @override
  State<MainMaps> createState() => _MainMapsState();
}

class _MainMapsState extends State<MainMaps> {
  final MapController _mapController = MapController();

  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  bool _isFollowingUser = true;

  final LatLng _initialCenter = const LatLng(13.7946, 100.3236);
  final Color _primaryTeal = const Color(0xFF008282);

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
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: locationSettings,
        ).listen((Position position) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });

          if (_isFollowingUser) {
            _mapController.move(_currentPosition!, _mapController.camera.zoom);
          }
        });
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
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.yourcompany.moremap',
              ),
              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Search bar
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
                color: _primaryTeal,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: GestureDetector(
                onTap: () async {
                  final LatLng? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      _isFollowingUser = false;
                    });
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
                      const Icon(Icons.search, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        "Search",
                        style: TextStyle(color: Colors.grey[600], fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right buttons
          Positioned(
            top: 130,
            right: 15,
            child: Column(
              children: [
                _buildMapButton(
                  Icons.my_location,
                  onPressed: _moveToCurrentLocation,
                ),
                const SizedBox(height: 10),
                _buildMapButton(Icons.explore_outlined, onPressed: () {}),
              ],
            ),
          ),
        ],
      ),

      // Bottom bar
      bottomNavigationBar: Container(
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
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
              ),
              _buildNavItem(icon: Icons.add, label: "AddRoute", isLarge: true),
              _buildNavItem(
                icon: Icons.person_outline,
                label: "Profile",
                onTap: () {
                  // แก้ไขตรงนี้ให้เรียก ProfilePage()
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapButton(IconData icon, {required VoidCallback onPressed}) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(icon: Icon(icon), onPressed: onPressed),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    bool isLarge = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: isLarge ? 40 : 30, color: _primaryTeal),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: _primaryTeal,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
