import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

import '../../routes/app_routes.dart';
import '../../services/route_service.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final Color primaryDarkTeal = const Color(0xFF0C8A8A);
  final Color primaryLightTeal = const Color(0xFF00CACA);

  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late TextEditingController _emailController;

  String _joinDate = '';
  String? _existingAvatarUrl;
  Uint8List? _selectedAvatarBytes;
  String _fileExtension = 'jpg';
  bool _isLoading = false;
  bool _isInitialized = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      
      _usernameController.text = args?['initialUsername'] ?? '';
      _passwordController.text = '********'; 
      _emailController.text = args?['initialEmail'] ?? '';
      _existingAvatarUrl = args?['initialAvatarUrl'];
      _joinDate = args?['joinDate'] ?? 'Joined Feb 2026';

      _isInitialized = true; 
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedAvatarBytes = bytes;
          _fileExtension = pickedFile.name.split('.').last;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  // 🔥 ฟังก์ชันสร้าง Popup ยืนยันการเปลี่ยนแปลง 🔥
  Future<bool?> _showConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('Confirm Changes', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('Want to keep changes or discard?', style: TextStyle(fontSize: 16)),
          actionsAlignment: MainAxisAlignment.spaceEvenly, 
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false), 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B6B), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Discard', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), 
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF389C57), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Change', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 30),
            _buildFormSection(),
            const SizedBox(height: 50),
            _buildLogoutButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, bottom: 30, left: 20, right: 20),
      decoration: BoxDecoration(color: primaryDarkTeal, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30))),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 130, height: 130,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFD9D9D9)),
                clipBehavior: Clip.hardEdge,
                child: _selectedAvatarBytes != null
                    ? Image.memory(_selectedAvatarBytes!, fit: BoxFit.cover)
                    : (_existingAvatarUrl != null)
                        ? Image.network(_existingAvatarUrl!, fit: BoxFit.cover)
                        : const Icon(Icons.person, size: 80, color: Colors.grey),
              ),
              Positioned(
                top: 5, right: 5,
                child: GestureDetector(
                  onTap: _pickImage, 
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: primaryLightTeal, shape: BoxShape.circle),
                    child: const Icon(Icons.edit, color: Colors.black87, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            _usernameController.text.isNotEmpty ? _usernameController.text : 'No Name', 
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(_joinDate, style: const TextStyle(color: Colors.white, fontSize: 14)), 
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFE2E2E2), borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Username', _usernameController, onChanged: (val) => setState(() {})), 
          const SizedBox(height: 15),
          _buildTextField('Password', _passwordController, isPassword: true),
          const SizedBox(height: 15),
          const Text('Email', style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          TextField(
            controller: _emailController, readOnly: true, 
            style: const TextStyle(color: Colors.grey), 
            decoration: InputDecoration(
              filled: true, fillColor: Colors.grey[300], 
              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 25),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () async {
                // 🔥 1. ดัก Validation ก่อนเปิด Popup! 🔥
                final newUsername = _usernameController.text.trim();
                final newPassword = _passwordController.text.trim();

                if (newUsername.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ กรุณากรอก Username ห้ามปล่อยว่างครับ'), backgroundColor: Colors.orange));
                  return; // หยุดการทำงาน
                }

                if (newPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ กรุณากรอก Password ห้ามปล่อยว่างครับ'), backgroundColor: Colors.orange));
                  return; // หยุดการทำงาน
                }

                if (newPassword != '********' && newPassword.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Password ต้องมีอย่างน้อย 6 ตัวอักษรครับ'), backgroundColor: Colors.orange));
                  return; // หยุดการทำงาน
                }
                // ------------------------------------

                bool? confirm = await _showConfirmationDialog();
                
                // ถ้ากดปุ่ม Discard (หรือกดพื้นที่ว่างปิด Popup) ให้หยุดการทำงาน
                if (confirm != true) return;

                setState(() => _isLoading = true);
                final RouteService routeService = RouteService();
                try {
                  String? finalAvatar = _existingAvatarUrl;
                  if (_selectedAvatarBytes != null) {
                    finalAvatar = await routeService.uploadAvatar(_selectedAvatarBytes!, _fileExtension);
                  }
                  
                  await routeService.updateUserProfile(newUsername, finalAvatar);

                  // อัปเดตรหัสผ่าน
                  if (newPassword != '********') {
                    await Supabase.instance.client.auth.updateUser(
                      UserAttributes(password: newPassword),
                    );
                  }
                  
                  if (mounted) {
                    Navigator.pop(context, true); 
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile Updated! ✅'), backgroundColor: Colors.green));
                  }
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update ❌'), backgroundColor: Colors.red));
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF389C57),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Apply', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false, Function(String)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        TextField(
          controller: controller, obscureText: isPassword, onChanged: onChanged,
          decoration: InputDecoration(
            filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            suffixIcon: IconButton(icon: const Icon(Icons.cancel_outlined, color: Colors.black87), onPressed: () { controller.clear(); if (onChanged != null) onChanged(''); }),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () async {
            final RouteService routeService = RouteService();
            await routeService.signOut(); 
            if (mounted) Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (route) => false);
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          child: const Text('Log Out', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}