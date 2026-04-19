# 🗺️ MoreMap - แผนที่สำหรับเส้นทางที่แอปอื่นไปไม่ถึง

**MoreMap** คือแอปพลิเคชันนำทางและแชร์เส้นทางลับ (Crowdsourced Mapping) ที่พัฒนาขึ้นด้วย Flutter สำหรับรายวิชา ITDS283 Mobile Application Development แอปนี้ถูกสร้างขึ้นเพื่อแก้ปัญหาแผนที่กระแสหลัก (เช่น Google Maps) ที่มักจะไม่แสดงเส้นทางเดินเท้า ทางเลียบคลอง หรือทางลัดในชุมชน 

ผู้ใช้งานสามารถใช้แอปนี้เพื่อค้นหาสถานที่ เดินบันทึกเส้นทางจริงด้วย GPS แบบ Real-time และแชร์เส้นทางใหม่ๆ ให้กับชุมชนได้

---

## ✨ ฟีเจอร์หลัก (Key Features)

* 📍 **Explore Routes:** ดูเส้นทางลับที่มีผู้ใช้คนอื่นแชร์ไว้บนแผนที่ (OpenStreetMap)
* 🚶‍♂️ **Record Route (Real-time GPS):** ระบบติดตามพิกัด GPS เพื่อวาดเส้นทางเดิน (Polyline) พร้อมคำนวณระยะทางอัตโนมัติ (รองรับระบบ Pause / Resume)
* 🔍 **Smart Search:** ค้นหาสถานที่พร้อมระบบดักจับคำขยะ (Blacklist) และกรองสถานที่แฟรนไชส์เพื่อลดภาระของระบบ
* ☁️ **Cloud Storage:** บันทึกข้อมูลเส้นทาง รายละเอียด และรูปภาพขึ้นระบบ Cloud (Supabase)
* 👤 **User Profile:** ระบบสมัครสมาชิก ล็อกอิน และจัดการโปรไฟล์ (เปลี่ยนชื่อ, รูปภาพ และรหัสผ่าน)

---

## 🛠️ เทคโนโลยีที่ใช้ (Tech Stack)

* **Frontend:** Flutter & Dart
* **Backend & Database:** Supabase (PostgreSQL, Authentication, Storage)
* **Maps & Geolocation:** * `flutter_map` (แสดงผล OpenStreetMap)
  * `geolocator` (ดึงพิกัด GPS)
  * Nominatim API (สำหรับระบบค้นหาสถานที่)

---

## 🚀 วิธีการติดตั้งและรันโปรเจกต์ (Getting Started)

### สิ่งที่ต้องมีเบื้องต้น (Prerequisites)
* ติดตั้ง [Flutter SDK](https://flutter.dev/docs/get-started/install) 
* เครื่องจำลอง (Android Emulator / iOS Simulator) หรือ โทรศัพท์มือถือสำหรับทดสอบจริง (แนะนำ Android สำหรับการเทส GPS)

### ขั้นตอนการรันแอปพลิเคชัน
1. โคลนโปรเจกต์ลงเครื่องของคุณ:
   ```bash
   git clone [https://github.com/YourUsername/MoreMap.git](https://github.com/YourUsername/MoreMap.git)

เข้าไปที่โฟลเดอร์โปรเจกต์:

Bash
cd MoreMap
ติดตั้ง Packages ที่จำเป็น:

Bash
flutter pub get
รันแอปพลิเคชัน:

Bash
flutter run
(หมายเหตุ: หากรันบน Web Browser อาจจะใช้งานฟีเจอร์ GPS ได้ไม่สมบูรณ์ แนะนำให้รันบนมือถือจริง)

📖 คู่มือการใช้งานเบื้องต้น (How to Use)
การเริ่มต้นใช้งาน: * เปิดแอปพลิเคชัน สามารถเลือก "Continue as Guest" เพื่อดูแผนที่ หรือกด "Sign Up" เพื่อสร้างบัญชีสำหรับการบันทึกเส้นทาง

การค้นหาสถานที่: * ในหน้าหลัก (Explore) กดปุ่มแถบ "Search" พิมพ์ชื่อสถานที่ที่ต้องการ (ระบบจะป้องกันการค้นหาด้วยคำขยะ เช่น 'test' หรือร้านค้าที่มีสาขาเยอะเกินไป)

การบันทึกเส้นทางใหม่:

กดที่เมนูตรงกลางด้านล่าง -> กด "Start Record Route" -> เดินตามเส้นทางที่ต้องการ

สามารถกดปุ่ม Pause/Resume ระหว่างทางได้

เมื่อถึงปลายทาง กด "Finished Your Route"

การบันทึกข้อมูลลง Cloud:

หลังจากจบการเดิน ระบบจะพาไปหน้า Edit Route

ใส่รูปภาพหน้าปก, ตั้งชื่อเส้นทาง และใส่รายละเอียด จากนั้นกด "Save" เส้นทางของคุณจะไปปรากฏบนแผนที่ของทุกคน!

👨‍💻 ผู้พัฒนา (Developers)
โครงงานนี้เป็นส่วนหนึ่งของรายวิชา ITDS283 Mobile Application Development คณะเทคโนโลยีสารสนเทศและการสื่อสาร (ICT) มหาวิทยาลัยมหิดล

นายจิรวัฒน์ ประเทืองทิพย์ (6787012)

นายธีรวัฒน์ ปุเวกิจ (6787044)

Created with ❤️ and Flutter


**💡 ทริคเล็กน้อย:**
ตรงหัวข้อ `git clone https://github.com/YourUsername/MoreMap.git` อย่าลืมเปลี่ยนคำว่า `YourUsername` ให้เป็นชื่อลิงก์ GitHub ของ TP จริงๆ ก่อนส่งงานนะครับ 

มีไฟล์ Readme หล่อๆ แบบนี้ ตอนอาจารย์กดเข้าไปดูใน GitHub ต้องประทับใจความโปรเฟสชันนอลแน่นอนครับ! 🎉