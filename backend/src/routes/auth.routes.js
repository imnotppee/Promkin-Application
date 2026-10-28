const express = require('express');
const router = express.Router();

// Mock User Database for team testing
const users = [
  {
    id: 'usr_1',
    email: 'pimchanok@student.kmitl.ac.th',
    password: 'password123',
    displayName: 'คุณพิมพ์ชนก',
    tier: 'นักศึกษา (ฟรี)',
    monthlyBudget: 3800.0,
    dailyCalories: 2000
  }
];

// POST /api/auth/login
router.post('/login', (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'กรุณากรอกอีเมลและรหัสผ่าน' });
  }

  const user = users.find((u) => u.email === email && u.password === password);
  if (!user) {
    // If not found in mock, return a test session for student testing
    return res.json({
      success: true,
      message: 'เข้าสู่ระบบสำเร็จ (โหมดทดสอบ)',
      data: {
        id: `usr_${Date.now()}`,
        email,
        displayName: email.split('@')[0],
        token: `mock_jwt_token_${Date.now()}`
      }
    });
  }

  const { password: _, ...safeUser } = user;
  res.json({
    success: true,
    message: 'เข้าสู่ระบบสำเร็จ',
    data: { ...safeUser, token: `mock_jwt_token_${user.id}` }
  });
});

// POST /api/auth/register
router.post('/register', (req, res) => {
  const { email, password, displayName } = req.body;
  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'กรุณากรอกข้อมูลให้ครบถ้วน' });
  }

  const existing = users.find((u) => u.email === email);
  if (existing) {
    return res.status(409).json({ success: false, message: 'อีเมลนี้ถูกใช้งานแล้ว' });
  }

  const newUser = {
    id: `usr_${Date.now()}`,
    email,
    password,
    displayName: displayName || email.split('@')[0],
    tier: 'นักศึกษา (ฟรี)',
    monthlyBudget: 3800.0,
    dailyCalories: 2000
  };
  users.push(newUser);

  const { password: _, ...safeUser } = newUser;
  res.status(201).json({
    success: true,
    message: 'ลงทะเบียนสำเร็จ',
    data: { ...safeUser, token: `mock_jwt_token_${newUser.id}` }
  });
});

module.exports = router;
