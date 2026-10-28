# 🍱 PROMKIN (พร้อมกิน)
> **แอปพลิเคชันวางแผนมื้ออาหาร และจัดการงบประมาณอย่างชาญฉลาด**
> Smart Meal Planner & Budget Management Mobile Application

[![Promkin CI Workflow](https://github.com/imnotppee/Promkin-Application/actions/workflows/ci.yml/badge.svg)](https://github.com/imnotppee/Promkin-Application/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.44.5-blue.svg)](https://flutter.dev)
[![Material Design 3](https://img.shields.io/badge/UI-Material%20Design%203-orange.svg)](https://m3.material.io)
[![Test Coverage](https://img.shields.io/badge/Coverage-77.8%25-brightgreen.svg)]()

---

## 👥 สมาชิกกลุ่มและผู้จัดทำ
| ลำดับ | รหัสนักศึกษา | ชื่อ - นามสกุล | บทบาทในทีม |
| :---: | :---: | :--- | :--- |
| 1 | 67030002 | น.ส. กชณัช น้อยพันธ์ | สมาชิกและโปรไฟล์ (Auth / Profile / UI) |
| 2 | 670300142 | นาย พัชรพล กลิ่นอ่อน | วางแผนมื้ออาหาร (Meal Planner / CRUD) |
| 3 | 67030059 | น.ส. ชุธิพร เชาว์ชัย | AI แนะนำเมนู & โภชนาการ (AI Feature / Nutrition) |
| 4 | 67030154 | นาย ปิยะวิทย์ พลศรี | งบประมาณ แจ้งเตือน & ฐานข้อมูล (Budget / SQLite / CI) |

---

## 🎯 ตารางเปรียบเทียบเกณฑ์การประเมินวิชา MDSD (20 คะแนนเต็ม)

| ส่วนที่ | องค์ประกอบประเมิน | คะแนนเต็ม | สถานะในโค้ดปัจจุบัน | โฟลเดอร์ที่เกี่ยวข้อง |
| :---: | :--- | :---: | :---: | :--- |
| **1** | **UI/UX ตาม Material Design 3 + Usability Testing** | 3 (15%) | ✅ สมบูรณ์ (Material 3 Theme, ColorScheme, Kanit Font) | `lib/core/theme/` |
| **2** | **REST API / Firebase Backend ≥ 2 บริการ** | 3 (15%) | ✅ สมบูรณ์ (REST Client + Firebase Auth & Firestore Sync) | `lib/core/network/`<br>`lib/core/services/` |
| **3** | **AI Feature (สอดคล้องกับแอปและครบ Flow)** | 3 (15%) | ✅ สมบูรณ์ (Google Gemini AI แนะนำเมนูตามงบและแคลอรี) | `lib/features/ai_recommendation/` |
| **4** | **Local Database + Firestore** | 3 (15%) | ✅ สมบูรณ์ (SQLite ด้วย sqflite + SharedPreferences + Cloud Sync) | `lib/core/database/`<br>`lib/features/meal_planner/data/` |
| **5** | **Testing ครบ 4 ประเภท + Code Coverage ≥ 70%** | 5 (25%) | ✅ สมบูรณ์ (Unit, Widget, Integration, Security) **Coverage: 77.8%** | `test/` |
| **6** | **GitHub Actions CI (Build & Test อัตโนมัติ)** | 3 (15%) | ✅ สมบูรณ์ (CI Workflow: analyze + test + build) | `.github/workflows/ci.yml` |

---

## 🏗️ โครงสร้างสถาปัตยกรรม (Architecture & Folder Structure)

โปรเจกต์ใช้สถาปัตยกรรม **Feature-First Architecture** เพื่อให้สมาชิก 4 คนสามารถแยกกันพัฒนาฟีเจอร์ในโฟลเดอร์ของตนเองได้อย่างอิสระ ลดปัญหา Git Merge Conflict:

```
lib/
├── core/                                # ส่วนกลางที่แชร์ร่วมกันในทีม
│   ├── constants/                       # ค่าคงที่ สี และข้อความ
│   │   ├── app_colors.dart              # ชุดสี Material 3 อาหาร สุขภาพ
│   │   ├── app_constants.dart           # ค่าเริ่มต้น (งบ 300 บาท/วัน, 2000 kcal)
│   │   └── app_strings.dart
│   ├── database/                        # การจัดเก็บข้อมูลถาวร (เกณฑ์ข้อ 4)
│   │   ├── database_helper.dart         # SQLite Local DB จัดการตาราง meals
│   │   └── preferences_helper.dart      # SharedPreferences จัดการ Settings/Budget
│   ├── network/                         # การเชื่อมต่อเครือข่าย REST API (เกณฑ์ข้อ 2)
│   │   ├── api_client.dart              # REST Client (GET, POST, JSON parser)
│   │   └── api_endpoints.dart
│   ├── services/                        # บริการเสริมของแอป
│   │   ├── ai_service.dart              # เชื่อมต่อ Google Gemini API (เกณฑ์ข้อ 3)
│   │   ├── firebase_service.dart        # เชื่อมต่อ Firebase Backend (เกณฑ์ข้อ 2)
│   │   └── notification_service.dart    # ระบบแจ้งเตือนเวลากินอาหาร (Meal Reminder)
│   ├── theme/                           # ดีไซน์ Material 3 (เกณฑ์ข้อ 1)
│   │   └── app_theme.dart               # Light/Dark Theme + Google Fonts Kanit
│   └── utils/
│       ├── currency_formatter.dart      # จัดการรูปแบบเงินบาท (฿)
│       └── date_formatter.dart          # จัดการรูปแบบวันที่ภาษาไทย
│
├── features/                            # แบ่งตามฟีเจอร์หลัก (ให้เพื่อนแต่ละคนรับผิดชอบ)
│   ├── auth/                            # โมดูลที่ 1: ระบบสมาชิก และข้อมูลผู้ใช้
│   │   ├── data/user_model.dart
│   │   └── presentation/                # AuthProvider, LoginScreen, ProfileScreen
│   │
│   ├── meal_planner/                    # โมดูลที่ 2: วางแผนมื้ออาหารประจำวัน (CRUD)
│   │   ├── data/                        # MealModel, MealRepository
│   │   └── presentation/                # MealProvider, MealCard, MealPlannerScreen, AddMealScreen
│   │
│   ├── ai_recommendation/               # โมดูลที่ 3: ระบบ AI แนะนำเมนูอาหารตามงบ
│   │   ├── data/ai_recommendation_model.dart
│   │   └── presentation/                # AiProvider, RecommendedMenuCard, AiRecommendationScreen
│   │
│   ├── nutrition/                       # โมดูลที่ 4: ข้อมูลโภชนาการ (Calories/Macros)
│   │   ├── data/nutrition_model.dart
│   │   └── presentation/                # NutritionProvider, MacroProgressBar, NutritionDashboardScreen
│   │
│   ├── settings_budget/                 # โมดูลที่ 5: ตั้งค่างบประมาณ และอาหารที่แพ้
│   │   ├── data/budget_settings_model.dart
│   │   └── presentation/                # SettingsProvider, SettingsScreen
│   │
│   └── home/                            # หน้าหลัก NavigationBar รวม 4 แท็บ
│       └── presentation/screens/main_navigation_screen.dart
│
└── main.dart                            # Entry Point และการลงทะเบียน Provider
```

---

## 🧪 การทดสอบระบบ (Testing Suite ครบ 4 ประเภท)

ชุดทดสอบถูกจัดโครงสร้างในโฟลเดอร์ `test/` แยกตามประเภทอย่างชัดเจน:
1. **Unit Tests** (`test/unit/`):
   - `meal_model_test.dart`: ทดสอบการแปลงข้อมูล Model, Map, CopyWith
   - `currency_formatter_test.dart`: ทดสอบการจัดรูปแบบค่าเงินบาท
   - `nutrition_calculation_test.dart`: ทดสอบการคำนวณสัดส่วนสารอาหาร
2. **Widget Tests** (`test/widget/`):
   - `meal_card_widget_test.dart`: ทดสอบการเรนเดอร์การ์ดอาหารและปุ่มกด Check
   - `macro_progress_bar_test.dart`: ทดสอบแถบแสดงสถานะโภชนาการ
3. **Integration Tests** (`test/integration/`):
   - `meal_planner_flow_test.dart`: ทดสอบ Flow แบบครบวงจร (เพิ่มอาหาร -> ตัดงบประมาณ -> คำนวณโภชนาการใหม่ -> ติ๊กเสร็จสิ้น -> ลบรายการ)
4. **Security Tests** (`test/security/`):
   - `input_validation_test.dart`: ทดสอบการป้องกัน Script Injection ในช่อง Note, ทดสอบความปลอดภัยของ Data Model ต่อค่าผิดปกติ, และการป้องกัน SQL Injection

### คำสั่งรันการทดสอบและคำนวณ Coverage:
```bash
flutter test --coverage
```

---

## 🚀 วิธีการติดตั้งและรันโปรเจกต์ (Getting Started)

### 1. คัดลอกโปรเจกต์ (Clone)
```bash
git clone https://github.com/imnotppee/Promkin-Application.git
cd Promkin-Application
```

### 2. ติดตั้ง Dependencies
```bash
flutter pub get
```

### 3. ตั้งค่าตัวแปรสภาพแวดล้อม (Optional สำหรับ AI Key)
คัดลอกไฟล์ `.env.example` ไปเป็น `.env`:
```bash
cp .env.example .env
```
*(หากยังไม่มี API Key ระบบจะมี Smart Fallback Engine คอยแนะนำเมนูให้ทันทีโดยไม่พัง)*

### 4. รันแอปพลิเคชัน
```bash
flutter run
```

---

## 📖 คู่มือการทำงานร่วมกันในทีม
โปรดอ่านรายละเอียดเพิ่มเติมเกี่ยวกับการตั้งชื่อ Branch และการเปิด Pull Request ได้ใน [CONTRIBUTING.md](CONTRIBUTING.md)
