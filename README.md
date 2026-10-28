# 🥬 PROM KIN (พร้อมกิน)
> **แอปพลิเคชันวางแผนมื้ออาหาร และจัดการงบประมาณอย่างชาญฉลาด**  
> Smart Meal Planner & Budget Management (Mobile Application & REST Backend)

[![Flutter](https://img.shields.io/badge/Flutter-3.44.5-blue.svg)](https://flutter.dev)
[![Node.js Backend](https://img.shields.io/badge/Backend-Node.js%20%7C%20Express-green.svg)](https://nodejs.org)
[![Material Design 3](https://img.shields.io/badge/UI-Material%20Design%203-416448.svg)](https://m3.material.io)
[![Test Coverage](https://img.shields.io/badge/Coverage-73.66%25-brightgreen.svg)]()
[![Tests](https://img.shields.io/badge/Tests-21%2F21%20Passing-success.svg)]()

---

## 🏗️ โครงสร้างสถาปัตยกรรม (Project Structure)

โปรเจกต์แบ่งเป็น 2 ส่วนหลัก เพื่อให้เพื่อนร่วมทีมทำงานร่วมกันได้สะดวก ไม่เกิด Git Conflict:

```
Promkin-Application/
├── backend/                             # 🌐 ส่วน Backend REST API (Node.js + Express)
│   ├── src/
│   │   ├── routes/
│   │   │   ├── meals.routes.js          # API จัดการมื้ออาหาร (GET, POST, PUT, DELETE)
│   │   │   ├── recipes.routes.js        # API ค้นหาและกรองสูตรอาหาร
│   │   │   ├── ai.routes.js             # API แนะนำเมนูอาหารด้วย Gemini AI / Smart Rules
│   │   │   └── auth.routes.js           # API ระบบสมาชิก
│   │   └── server.js                    # Express App Setup & Middlewares (PORT 5000)
│   ├── .env.example                     # ไฟล์ตัวอย่าง Environment Variables
│   ├── package.json                     # Dependencies: express, cors, dotenv
│   └── README.md                        # เอกสารและวิธีทดสอบ Endpoints ฝั่ง Backend
│
├── lib/                                 # 📱 ส่วน Mobile Application (Flutter Frontend)
│   ├── core/                            # ส่วนกลางที่แชร์ร่วมกันในทีม
│   │   ├── constants/                   # app_colors.dart, app_constants.dart, app_strings.dart
│   │   ├── database/                    # database_helper.dart (SQLite), preferences_helper.dart
│   │   ├── network/                     # api_client.dart, api_endpoints.dart
│   │   ├── services/                    # ai_service.dart (Gemini), firebase_service.dart
│   │   ├── theme/                       # app_theme.dart (Material Design 3 + Kanit)
│   │   └── utils/                       # currency_formatter.dart, date_formatter.dart
│   │
│   ├── features/                        # แบ่งโมดูลแบบ Feature-First (เพื่อนรับผิดชอบคนละโมดูล)
│   │   ├── home/                        # หน้าหลัก ภาพรวม (DashboardScreen) ตรงตามแบบ prototype
│   │   │   └── presentation/screens/
│   │   │       ├── dashboard_screen.dart        # การ์ดงบประมาณ, วัน 7 วัน, เมนูประจำวัน, สรุปโภชนาการ
│   │   │       └── main_navigation_screen.dart  # เมนูนำทาง 5 แท็บ พร้อมปุ่ม ✦ AI เด่นตรงกลาง
│   │   │
│   │   ├── meal_planner/                # โมดูลที่ 2: วางแผนมื้ออาหารประจำสัปดาห์
│   │   │   ├── data/                    # meal_model.dart, meal_repository.dart
│   │   │   └── presentation/
│   │   │       ├── screens/weekly_planner_screen.dart   # ปฏิทิน 7 วัน และ Day Detail
│   │   │       ├── screens/add_meal_screen.dart         # ฟอร์มเพิ่มมื้ออาหาร
│   │   │       └── widgets/add_to_plan_dialog.dart      # Dialog เลือกวัน/มื้อ/เวลา
│   │   │
│   │   ├── ai_recommendation/           # โมดูลที่ 3: ระบบ AI แนะนำเมนูอาหาร
│   │   │   ├── data/ai_recommendation_model.dart
│   │   │   └── presentation/screens/ai_recommendation_screen.dart
│   │   │
│   │   ├── recipe_search/               # โมดูลที่ 4: คลังสูตรอาหาร & การค้นหา
│   │   │   ├── data/recipe_model.dart
│   │   │   └── presentation/screens/recipe_search_screen.dart
│   │   │
│   │   ├── nutrition/                   # โมดูลที่ 5: ติดตามสารอาหาร (Macros)
│   │   │   ├── data/nutrition_model.dart
│   │   │   └── presentation/screens/nutrition_dashboard_screen.dart
│   │   │
│   │   ├── settings_budget/             # โมดูลที่ 6: ตั้งค่างบประมาณ อาหารที่แพ้ และโหมดมืด
│   │   │   ├── data/budget_settings_model.dart
│   │   │   └── presentation/screens/settings_screen.dart
│   │   │
│   │   └── auth/                        # โมดูลที่ 7: ระบบล็อกอินและโปรไฟล์ผู้ใช้
│   │       ├── data/user_model.dart
│   │       └── presentation/screens/login_screen.dart, profile_screen.dart
│   │
│   └── main.dart                        # Initializer (Thai Locale, Desktop SQLite, Providers)
│
├── test/                                # 🧪 Automated Tests ครบ 4 ประเภท (Coverage: 73.66%)
│   ├── unit/                            # ทดสอบ Model, Formatter, Nutrition, Settings
│   ├── widget/                          # ทดสอบ MealCard, ProgressBar, Dashboard, Planner, Search
│   ├── integration/                     # ทดสอบ E2E Flow เพิ่มอาหาร -> ตัดงบ -> โภชนาการเปลี่ยน
│   └── security/                        # ทดสอบ XSS sanitization, SQL Injection prevention, Negative inputs
│
└── .github/workflows/ci.yml             # 🤖 GitHub Actions CI Workflow
```

---

## 🚀 วิธีการรันโปรเจกต์ (สำหรับเพื่อนร่วมทีม)

### 1. วิธีรัน Mobile Application (Frontend)
```bash
# ติดตั้ง Flutter Dependencies
flutter pub get

# ตรวจสอบโค้ดว่าไม่มี Error/Warning
flutter analyze

# รัน Automated Tests ทั้งหมด พร้อมวัด Code Coverage
flutter test --coverage

# รันแอปพลิเคชัน (บน Android Emulator, Chrome หรือเครื่องจริง)
flutter run
```

### 2. วิธีรัน REST API Server (Backend)
```bash
# เข้าโฟลเดอร์ backend
cd backend

# ติดตั้ง Dependencies
npm install

# รัน Server ในโหมด Auto-reload
npm run dev
```
> **หมายเหตุการเชื่อมต่อ**:  
> ฝั่ง Android Emulator จะเชื่อมต่อ Backend ที่เครื่องคอมพิวเตอร์ผ่าน URL `http://10.0.2.2:5000/api` โดยอัตโนมัติ

---

## 🌿 กฎการทำงานร่วมกันในทีม (Git Collaboration)

1. **อย่า Commit ทับลงบน `main` โดยตรง**:
   ให้แตก Branch ตามฟีเจอร์ของตนเองเสมอ เช่น:
   - `feature/meal-planner`
   - `feature/ai-recommendation`
   - `feature/recipe-catalog`
   - `feature/backend-api`
2. **ก่อน Push โค้ดขึ้น GitHub**:
   รันคำสั่งตรวจสอบเสมอ:
   ```bash
   flutter analyze   # ต้องไม่มี Error
   flutter test      # ต้องผ่าน 100%
   ```
3. **เปิด Pull Request (PR)**:
   GitHub Actions CI จะทำการตรวจสอบ Build & Test อัตโนมัติให้ก่อนรวมโค้ดเข้าสู่ `main`
