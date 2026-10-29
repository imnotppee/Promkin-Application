import 'package:flutter/material.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/core/widgets/motion_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.paper,
    body: SafeArea(
      child: FadeSlideIn(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Expanded(
                      child: Text(
                        'Forgot Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
              sliver: SliverList.list(
                children: [
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'ลืมรหัสผ่าน?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ไม่ต้องกังวล กรอกอีเมลหรือเบอร์โทรศัพท์ที่ใช้สมัคร แล้วเราจะส่งลิงก์สำหรับตั้งรหัสผ่านใหม่ให้',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    child: _submitted ? _successCard() : _formCard(),
                  ),
                  const SizedBox(height: 23),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('กลับไปเข้าสู่ระบบ'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _formCard() => Container(
    key: const ValueKey('form'),
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withAlpha(8),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'อีเมล หรือเบอร์โทรศัพท์',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'name@example.com หรือ 08X-XXX-XXXX',
              prefixIcon: Icon(Icons.mail_outline),
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'กรอกอีเมลหรือเบอร์โทรศัพท์ก่อน'
                : null,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('ส่งลิงก์รีเซ็ตรหัสผ่าน'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'หากข้อมูลนี้มีบัญชี PromKin คุณจะได้รับคำแนะนำสำหรับรีเซ็ตรหัสผ่าน',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _successCard() => Container(
    key: const ValueKey('success'),
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      boxShadow: [
        BoxShadow(
          color: AppColors.ink.withAlpha(8),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          color: AppColors.primary,
          size: 42,
        ),
        const SizedBox(height: 12),
        const Text(
          'ตรวจสอบอีเมลของคุณ',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'หาก ${_emailController.text.trim()} มีบัญชี PromKin คุณจะได้รับคำแนะนำสำหรับตั้งรหัสผ่านใหม่',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.muted,
            height: 1.5,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: () => setState(() => _submitted = false),
          child: const Text('ส่งใหม่อีกครั้ง หรือเปลี่ยนข้อมูล'),
        ),
      ],
    ),
  );

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _submitted = true);
    }
  }
}
