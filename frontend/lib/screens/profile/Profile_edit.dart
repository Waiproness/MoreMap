import 'package:flutter/material.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // สีหลักอิงจากรูป
  final Color primaryDarkTeal = const Color(0xFF0C8A8A);
  final Color primaryLightTeal = const Color(0xFF00CACA);

  // Controllers สำหรับจัดการข้อความใน TextField
  final TextEditingController _usernameController = TextEditingController(
    text: 'Wai Verstappen',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '**************',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'WaiVerstappen.33@gmail.com',
  );

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
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

  // ส่วนหัว: ปุ่ม Back, รูป Profile, ชื่อ
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
          // แถวบนสุด: ปุ่ม Back
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context), // คำสั่งกลับหน้าเดิม
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),

          // รูป Profile และไอคอนดินสอแก้ไข
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 130,
                height: 130,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD9D9D9), // สีเทา Placeholder
                ),
              ),
              // ไอคอนดินสอแก้ไขมุมขวาบน
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryLightTeal, // สีฟ้าอมเขียวสว่าง
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

          // ข้อมูลผู้ใช้
          const Text(
            'Wai Verstappen',
            style: TextStyle(
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

  // ส่วนฟอร์มแก้ไขข้อมูล
  Widget _buildFormSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E2E2), // พื้นหลังสีเทาอ่อน
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Username', _usernameController),
          const SizedBox(height: 15),
          _buildTextField('Password', _passwordController, isPassword: true),
          const SizedBox(height: 15),
          _buildTextField('E-mail', _emailController),
          const SizedBox(height: 25),

          // ปุ่ม Apply อิงขวา
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                // TODO: ใส่คำสั่งบันทึกข้อมูล
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('บันทึกข้อมูลเรียบร้อย')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF389C57), // สีเขียวตามรูป
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

  // วิดเจ็ตสำหรับช่องกรอกข้อมูลแต่ละช่อง
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
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
          obscureText: isPassword, // ปิดบังรหัสผ่านถ้า isPassword เป็น true
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            // ไอคอนกากบาทขวาสุด สำหรับกดเคลียร์ข้อความ
            suffixIcon: IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.black87),
              onPressed: () => controller.clear(),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none, // เอาเส้นขอบออก
            ),
          ),
        ),
      ],
    );
  }

  // ส่วนปุ่ม Log Out
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () {
            // TODO: ใส่คำสั่ง Log Out (เช่น กลับไปหน้า Login)
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF6B6B), // สีแดงอมส้ม
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
