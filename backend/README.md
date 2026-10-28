# 🌿 PROM KIN - Backend REST API

REST API Server สำหรับแอปพลิเคชัน **PROM KIN (พร้อมกิน)** พัฒนาด้วย Node.js + Express เพื่อรองรับเกณฑ์การประเมินโครงงาน (เกณฑ์ที่ 2: REST API / Firebase Backend $\ge 2$ บริการ)

---

## 🚀 วิธีการติดตั้งและรัน (สำหรับเพื่อนร่วมทีมฝั่ง Backend)

### 1. ติดตั้ง Dependencies
```bash
cd backend
npm install
```

### 2. ตั้งค่า Environment Variables (.env)
คัดลอกไฟล์ `.env.example` เป็น `.env`:
```bash
cp .env.example .env
```
ภายในไฟล์ `.env`:
```env
PORT=5000
NODE_ENV=development
GEMINI_API_KEY=your_gemini_api_key_here
```

### 3. เริ่มต้น Server
```bash
# โหมด Development (มี Auto-reload เมื่อแก้โค้ด)
npm run dev

# หรือโหมด Production
npm start
```
Server จะเริ่มทำงานที่:
- **เครื่อง Local**: `http://localhost:5000`
- **Android Emulator**: `http://10.0.2.2:5000`

---

## 📡 รายการ API Endpoints

### 1. Health Check
- **GET** `/api/health`
  - ตรวจสอบสถานะการทำงานของ Server

### 2. Meals & Planner (`/api/meals`)
- **GET** `/api/meals`
  - ดึงรายการมื้ออาหารทั้งหมด (สามารถกรองตามวันที่ได้: `?date=YYYY-MM-DD`)
- **POST** `/api/meals`
  - เพิ่มมื้ออาหารใหม่ลงในแผน
  - Payload ตัวอย่าง:
    ```json
    {
      "name": "ข้าวกะเพราเต้าหู้ไข่",
      "mealType": "มื้อเย็น",
      "price": 45,
      "calories": 380,
      "protein": 18,
      "carbs": 52,
      "fat": 10,
      "date": "2026-10-28",
      "emoji": "🍛",
      "time": "18:30",
      "tags": ["มังสวิรัติ", "ทำง่าย"]
    }
    ```
- **PUT** `/api/meals/:id`
  - อัปเดตข้อมูลมื้ออาหารหรือสถานะการกิน (Completed)
- **DELETE** `/api/meals/:id`
  - ลบมื้ออาหารออกจากแผน

### 3. Recipe Catalog (`/api/recipes`)
- **GET** `/api/recipes`
  - ค้นหาและกรองเมนูอาหาร (Query parameters: `?category=มังสวิรัติ&q=กะเพรา`)
- **GET** `/api/recipes/:id`
  - ดูรายละเอียดเมนูและโภชนาการ

### 4. AI Recommendation (`/api/ai`)
- **POST** `/api/ai/recommend`
  - สร้างชุดเมนูแนะนำตามเงื่อนไขของผู้ใช้ (รองรับทั้ง Google Gemini API และ Rule-Based AI อัจฉริยะ)
  - Payload ตัวอย่าง:
    ```json
    {
      "budget": 180,
      "targetCalories": 2000,
      "mealCount": 3,
      "dislikedIngredients": ["ถั่วลิสง"],
      "goal": "สมดุล"
    }
    ```

### 5. Authentication (`/api/auth`)
- **POST** `/api/auth/login`
  - เข้าสู่ระบบผู้ใช้งาน
- **POST** `/api/auth/register`
  - ลงทะเบียนผู้ใช้งานใหม่

---

## 🤝 การเชื่อมต่อกับ Flutter Mobile App (Frontend)

แอปพลิเคชัน Flutter ฝั่ง Mobile ได้เตรียม Client เชื่อมต่อไปยัง Server ไว้แล้วที่:
- `lib/core/network/api_client.dart`
- `lib/core/network/api_endpoints.dart`

โดยฝั่ง Android Emulator จะเข้าถึง Backend ได้ผ่าน `http://10.0.2.2:5000/api` โดยอัตโนมัติ
