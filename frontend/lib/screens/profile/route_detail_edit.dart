import 'package:flutter/material.dart';

class RouteDetailEditPage extends StatefulWidget {
  // รับค่าเดิมมาจากหน้า Detail เพื่อมาแสดงในช่องแก้ไข
  final String title;
  final String distance;
  final String description;

  const RouteDetailEditPage({
    super.key,
    this.title = 'Khlong Saan Sap', 
    this.distance = '1 Km',
    this.description = 'Explore this for one reason!\nto Find One Piece Because\nof that we have to survey',
  });

  @override
  State<RouteDetailEditPage> createState() => _RouteDetailEditPageState();
}

class _RouteDetailEditPageState extends State<RouteDetailEditPage> {
  // สร้าง Controller สำหรับจัดการข้อความในช่องพิมพ์
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    // ดึงค่าเดิมมาใส่ในช่องพิมพ์ตอนเปิดหน้า
    _titleController = TextEditingController(text: widget.title);
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C8A8A), // พื้นหลังสีเขียวเข้ม
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView( // ป้องกันปัญหาคีย์บอร์ดเด้งขึ้นมาบังหน้าจอ
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBEBEB), // สีเทาอ่อนของกรอบการ์ด
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. ปุ่ม Cancel (ขวาบน)
                    Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF989898), // สีเทา
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. ช่องแก้ไขชื่อ Route
                    Row(
                      children: [
                        const Text(
                          'Route: ',
                          style: TextStyle(fontSize: 20, color: Colors.black87),
                        ),
                        Expanded(
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9), // กล่องสีเทาหลังชื่อ
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TextField(
                              controller: _titleController,
                              style: const TextStyle(fontSize: 20),
                              decoration: const InputDecoration(
                                border: InputBorder.none, // เอาเส้นขอบล่างออก
                                contentPadding: EdgeInsets.only(left: 10, bottom: 12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 3. ระยะทาง (เป็น Text ธรรมดา)
                    Text(
                      'Distance: ${widget.distance}',
                      style: const TextStyle(fontSize: 20, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),

                    // 4. กรอบรูป/แผนที่สีขาว + ไอคอนดินสอที่มุมขวาล่าง
                    Stack(
                      clipBehavior: Clip.none, // ยอมให้ไอคอนล้นกรอบออกมาได้
                      children: [
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                        ),
                        // ไอคอนดินสอแก้ไขรูปภาพ (ขวาล่าง)
                        Positioned(
                          bottom: -15,
                          right: -15,
                          child: GestureDetector(
                            onTap: () {
                              // TODO: ใส่ฟังก์ชันเลือกเปลี่ยนรูปภาพ
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: Color(0xFF00CACA), // สีฟ้าอมเขียว
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, color: Colors.black, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30), // เผื่อที่เว้นระยะให้ไอคอนดินสอ

                    // 5. ช่องแก้ไขรายละเอียด (Description) แบบไม่มีกรอบ
                    TextField(
                      controller: _descriptionController,
                      maxLines: null, // ยอมให้พิมพ์ขึ้นบรรทัดใหม่ได้เรื่อยๆ
                      style: const TextStyle(fontSize: 18, color: Colors.black87, height: 1.3),
                      decoration: const InputDecoration(
                        border: InputBorder.none, // ไม่มีเส้นขอบ
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 6. ปุ่ม Save และ Delete
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // ปุ่ม Save
                        ElevatedButton(
                          onPressed: () {
                            // ส่งข้อมูลใหม่กลับไปในรูปแบบ Map
                            Navigator.pop(context, {
                              'title': _titleController.text,
                              'description': _descriptionController.text,
                            });
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Saved Successfully')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF389C57), // สีเขียว
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),

                        // ปุ่ม Delete
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Deleted')),
                            );
                            Navigator.pop(context); // กลับไปหน้า Detail
                            Navigator.pop(context); // กลับไปหน้า Saved Route หลัก
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B6B), // สีแดงอมส้ม
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 12),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
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