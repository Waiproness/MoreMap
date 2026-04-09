import 'dart:typed_data'; 
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:flutter_map/flutter_map.dart'; 
import 'package:latlong2/latlong.dart';      

import '../../routes/app_routes.dart';
import '../../services/route_service.dart';

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
  String _routeId = ''; 
  List<LatLng> _routePoints = []; 

  bool _isInitialized = false;
  bool _isLoading = false; 

  Uint8List? _selectedImageBytes;
  String _fileExtension = 'jpg';
  String? _existingImageUrl;
  
  final ImagePicker _picker = ImagePicker();
  final RouteService _routeService = RouteService();

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
      
      _routeId = args?['id']?.toString() ?? ''; 
      _existingImageUrl = args?['image_url'];
      _routePoints = args?['routePoints'] ?? []; 

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

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes(); 
        setState(() {
          _selectedImageBytes = bytes;
          _fileExtension = pickedFile.name.split('.').last; 
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _saveRouteData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ กรุณาเข้าสู่ระบบก่อนบันทึกข้อมูล'), backgroundColor: Colors.red),
      );
      return; 
    }

    setState(() => _isLoading = true); 

    String? finalImageUrl = _existingImageUrl;

    if (_selectedImageBytes != null) {
      finalImageUrl = await _routeService.uploadImage(_selectedImageBytes!, _fileExtension);
    }

    // แปลงพิกัดเป็น List ของ JSON
    List<Map<String, double>> routePointsJson = _routePoints.map((p) => {
      'lat': p.latitude,
      'lng': p.longitude,
    }).toList();

    final newRouteData = {
      'title': _titleController.text.isEmpty ? 'Untitled Route' : _titleController.text,
      'distance': distance,
      'description': _descriptionController.text,
      'image_url': finalImageUrl, 
      'user_id': user.id, 
      if (routePointsJson.isNotEmpty) 'route_points': routePointsJson, 
    };

    try {
      if (isNewRoute) {
        await _routeService.addRoute(newRouteData);
      } else {
        await _routeService.updateRoute(_routeId, newRouteData);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Cloud! ☁️'), backgroundColor: Colors.green));
        if (isNewRoute) {
          Navigator.pushReplacementNamed(context, AppRoutes.savedRoute);
        } else {
          Navigator.pop(context, {
            'id': _routeId, 
            'title': _titleController.text,
            'description': _descriptionController.text,
            'image_url': finalImageUrl,
          });
        }
      }
    } catch (e) {
      print('Error saving data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ เกิดข้อผิดพลาดในการบันทึกข้อมูล'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); 
    }
  }

  Future<void> _deleteRouteData() async {
    try {
      setState(() => _isLoading = true);
      await _routeService.deleteRoute(_routeId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted from Cloud! 🗑️'), backgroundColor: Colors.redAccent));
        Navigator.popUntil(context, ModalRoute.withName(AppRoutes.savedRoute)); 
      }
    } catch (e) {
      print('Error deleting data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

                    Row(
                      children: [
                        const Text('Route: ', style: TextStyle(fontSize: 20, color: Colors.black87)),
                        Expanded(
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(color: const Color(0xFFD9D9D9), borderRadius: BorderRadius.circular(5)),
                            child: TextField(
                              controller: _titleController,
                              maxLength: 50, // 🔥 ล็อคความยาวชื่อ 50 ตัวอักษร
                              style: const TextStyle(fontSize: 20),
                              decoration: const InputDecoration(
                                border: InputBorder.none, 
                                contentPadding: EdgeInsets.only(left: 10, bottom: 12),
                                counterText: "", // 🔥 ซ่อนตัวนับเลข เพื่อไม่ให้ UI พัง
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Text('Distance: $distance', style: const TextStyle(fontSize: 20, color: Colors.black87)),
                    const SizedBox(height: 20),

                    if (_routePoints.isNotEmpty) ...[
                      Builder(
                        builder: (context) {
                          bool hasRealMovement = _routePoints.length > 1 && 
                              _routePoints.any((p) => p.latitude != _routePoints.first.latitude || p.longitude != _routePoints.first.longitude);

                          return Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade400, width: 2),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: _routePoints.first,
                                initialZoom: 16.0,
                                initialCameraFit: hasRealMovement
                                    ? CameraFit.bounds(
                                        bounds: LatLngBounds.fromPoints(_routePoints),
                                        padding: const EdgeInsets.all(25.0),
                                      )
                                    : null,
                                interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.moremap',
                                ),
                                PolylineLayer(
                                  polylines: [
                                    Polyline(points: _routePoints, strokeWidth: 5.0, color: Colors.redAccent),
                                  ],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: _routePoints.first, width: 14, height: 14,
                                      child: Container(decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                                    ),
                                    Marker(
                                      point: _routePoints.last, width: 14, height: 14,
                                      child: Container(decoration: BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        }
                      ),
                      const SizedBox(height: 20),
                    ],

                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 220, 
                          width: double.infinity, 
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                          clipBehavior: Clip.hardEdge,
                          child: _selectedImageBytes != null
                              ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                              : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                                  ? Image.network(_existingImageUrl!, fit: BoxFit.cover)
                                  : const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                        ),
                        Positioned(
                          bottom: -15, right: -15,
                          child: GestureDetector(
                            onTap: _pickImage, 
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

                    TextField(
                      controller: _descriptionController,
                      maxLines: null,
                      maxLength: 500, // 🔥 ล็อคความยาวรายละเอียด 500 ตัวอักษร
                      style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.3),
                      decoration: const InputDecoration(
                        border: InputBorder.none, 
                        isDense: true, 
                        contentPadding: EdgeInsets.zero, 
                        hintText: 'Write your description here...',
                        counterText: "", // 🔥 ซ่อนตัวนับเลข
                      ),
                    ),
                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveRouteData, 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF389C57),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            elevation: 0,
                          ),
                          child: _isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Save', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),

                        if (!isNewRoute)
                          ElevatedButton(
                            onPressed: _isLoading ? null : _deleteRouteData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF6B6B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                              elevation: 0,
                            ),
                            child: _isLoading 
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Delete', style: TextStyle(color: Colors.white, fontSize: 18)),
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