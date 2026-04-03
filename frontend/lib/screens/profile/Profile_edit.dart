import 'package:flutter/material.dart';

class ProfileEditPage extends StatefulWidget {
  // 👉 1. ลบ Constructor แบบเก่าทิ้งไปเลย ให้เหลือแค่นี้ครับ
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

  bool _isInitialized = false; // ตัวแปรเช็คว่าดึงข้อมูลหรือยัง

  @override
  void initState() {
    super.initState();
    // ❌ ไม่ต้องสร้าง Controller ในนี้แล้ว ให้ปล่อยว่างไว้
  }

  // 👉 2. ใช้ didChangeDependencies แทน initState สำหรับดึง ModalRoute
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // เช็คว่าเพิ่งเปิดหน้านี้ครั้งแรกใช่ไหม (เพื่อไม่ให้มันดึงค่าใหม่ซ้ำซ้อนตอนพิมพ์)
    if (!_isInitialized) {
      // แกะกล่องข้อมูลที่ส่งมาจากหน้าแรก
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
      
      // ดึงข้อมูลออกมาใช้ (ถ้าไม่มีให้เป็นค่าว่าง)
      final username = args?['initialUsername'] ?? '';
      final password = args?['initialPassword'] ?? '';
      final email = args?['initialEmail'] ?? '';

      // นำข้อมูลไปใส่ในกล่องข้อความ
      _usernameController = TextEditingController(text: username);
      _passwordController = TextEditingController(text: password);
      _emailController = TextEditingController(text: email);

      _isInitialized = true; // เซ็ตว่าทำเสร็จแล้ว
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ❌ ลบ ModalRoute ใน build ออกไปได้เลย เพราะเราดึงไปแล้วใน didChangeDependencies
    
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
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 30,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: primaryDarkTeal,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD9D9D9),
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryLightTeal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.black87,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            _usernameController.text, // แสดงชื่อที่อาจถูกพิมพ์แก้ไขอยู่แบบ Real-time
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            '#33',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Joined Febuary 7, 2026',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E2E2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            'Username',
            _usernameController,
            onChanged: (val) => setState(() {}),
          ), 
          const SizedBox(height: 15),
          _buildTextField('Password', _passwordController, isPassword: true),
          const SizedBox(height: 15),
          _buildTextField('E-mail', _emailController),
          const SizedBox(height: 25),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // ส่งข้อมูลที่อัปเดตแล้วกลับไปให้หน้า Profile
                Navigator.pop(context, {
                  'username': _usernameController.text,
                  'password': _passwordController.text,
                  'email': _emailController.text,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile Updated')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF389C57),
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Apply',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: isPassword,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.black87),
              onPressed: () {
                controller.clear();
                if (onChanged != null) onChanged('');
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
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
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B6B),
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Log Out',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}