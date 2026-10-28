# 🤝 คู่มือการทำงานร่วมกันในทีม (Promkin Development Guide)

เอกสารนี้จัดทำขึ้นเพื่อให้สมาชิกในทีมทุกคนสามารถทำงานร่วมกันได้อย่างราบรื่น ไม่เกิด Git Conflict และรักษาคุณภาพโค้ดตามเกณฑ์การประเมินวิชา MDSD อย่างครบถ้วน

---

## 👥 1. การแบ่งงานรายบุคคล (Feature Ownership)

โครงสร้างโปรเจกต์นี้ถูกออกแบบด้วย **Feature-First Architecture** ทำให้สมาชิกแต่ละคนสามารถทำงานในโฟลเดอร์ของตัวเองได้โดยไม่กระทบกับเพื่อนร่วมทีม:

| สมาชิก | รหัสนักศึกษา | หน้าที่หลัก / โมดูลที่รับผิดชอบ | โฟลเดอร์ที่ทำงาน |
| :--- | :--- | :--- | :--- |
| **สมาชิกคนที่ 1** | 67030002 | **ระบบสมาชิก & ข้อมูลผู้ใช้**<br>- Login / Register / Profile<br>- Firebase Authentication Integration | `lib/features/auth/` |
| **สมาชิกคนที่ 2** | 670300142 | **ระบบวางแผนมื้ออาหาร (Meal Planner)**<br>- วางแผนอาหารรายวัน/สัปดาห์<br>- CRUD มื้ออาหาร (เช้า, กลางวัน, เย็น) | `lib/features/meal_planner/` |
| **สมาชิกคนที่ 3** | 67030059 | **AI แนะนำเมนู & โภชนาการ**<br>- Gemini API Integration<br>- Dashboard โภชนาการ (Calories/Macros) | `lib/features/ai_recommendation/`<br>`lib/features/nutrition/` |
| **สมาชิกคนที่ 4** | 67030154 | **จัดการงบประมาณ & แจ้งเตือน & Local DB**<br>- Budgeting System & SharedPreferences<br>- Local SQLite Database & Meal Reminder | `lib/features/settings_budget/`<br>`lib/core/database/` |

---

## 🌿 2. กฎการใช้งาน Git & Branching Strategy

เพื่อป้องกันโค้ดตีกัน (Merge Conflict) ให้ใช้หลักการ **Git Flow** ดังนี้:

### โครงสร้าง Branch
- `main` : เก็บโค้ดเวอร์ชันที่เสถียรที่สุดสำหรับส่งงาน/พรีเซนต์
- `develop` : Branch รวมงานหลักที่เพื่อนทุกคนจะ Merge เข้ามา
- `feature/<ชื่อฟีเจอร์>` : Branch เฉพาะสำหรับทำฟีเจอร์ของตนเอง แตกกิ่งมาจาก `develop`

### ตัวอย่างการสร้าง Branch ทำงาน:
```bash
# 1. สลับมาที่ develop แล้วดึงโค้ดล่าสุด
git checkout develop
git pull origin develop

# 2. สร้าง branch งานของตัวเอง
git checkout -b feature/meal-crud

# 3. เมื่อทำเสร็จ ให้ commit และ push ขึ้น GitHub
git add .
git commit -m "feat(meal): implement add meal validation and price calculation"
git push origin feature/meal-crud
```

### รูปแบบ Commit Message (Conventional Commits)
- `feat:` เพิ่มฟีเจอร์ใหม่ เช่น `feat(ai): integrate gemini meal recommendation`
- `fix:` แก้ไขบั๊ก เช่น `fix(auth): handle login error when network is offline`
- `test:` เพิ่มหรือแก้ไขชุดทดสอบ เช่น `test(nutrition): add unit test for macro calculation`
- `ui:` ปรับแต่งหน้าตาหรือดีไซน์ เช่น `ui(theme): apply material 3 color scheme`
- `docs:` แก้ไขเอกสาร เช่น `docs: update setup instructions in readme`

---

## 🧪 3. กฎก่อนส่งโค้ดขึ้น GitHub (Pre-Push Checklist)

ก่อนเปิด Pull Request (PR) ขอให้รันคำสั่ง 3 อย่างนี้ในเครื่องของตัวเองให้ผ่านทั้งหมด:

```bash
# 1. จัดรูปแบบโค้ดให้สะอาด
dart format .

# 2. ตรวจสอบ syntax และ linting (ต้อง 0 issues)
flutter analyze

# 3. รันชุดทดสอบพร้อมเช็ค coverage (ต้องผ่านทุกข้อ และ coverage >= 70%)
flutter test --coverage
```

> [!NOTE]
> ทางทีมได้ตั้งค่า **GitHub Actions CI** ไว้แล้ว เมื่อเปิด Pull Request ระบบจะรัน Analyze และ Test อัตโนมัติ หากมีข้อผิดพลาดระบบจะขึ้นแจ้งเตือนทันที
