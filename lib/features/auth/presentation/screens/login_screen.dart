import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';
import 'package:promkin_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:promkin_app/core/widgets/motion_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _register = false;
  bool _remember = true;
  bool _showPassword = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
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
                      Expanded(
                        child: Text(
                          _register ? 'Create Account' : 'Sign In',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: () {},
                        icon: const Icon(Icons.person_outline),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                sliver: SliverList.list(
                  children: [
                    const SizedBox(height: 13),
                    Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 11),
                    const Center(
                      child: Text(
                        'P R O M K I N',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Center(
                      child: Text(
                        'SMART MEAL PLANNING & BUDGET MANAGEMENT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        _register
                            ? 'สร้างบัญชีผู้ใช้ใหม่'
                            : 'พร้อมกิน | มื้อดีคุมงบได้',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _register
                          ? 'เริ่มต้นวางแผนมื้ออาหารและจัดการงบประมาณกับ PromKin'
                          : 'วางแผนมื้ออาหารอย่างมีระดับ สุขภาพดี และคุมงบได้อย่างสบายใจ',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1EFEA),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          _authTab('เข้าสู่ระบบ', false),
                          _authTab('สร้างบัญชีใหม่', true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(18),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_register) ...[
                            _field(
                              'ชื่อ - นามสกุล',
                              'สมชาย ใจดี',
                              Icons.person_outline,
                              controller: _name,
                            ),
                            const SizedBox(height: 15),
                          ],
                          _field(
                            'อีเมล หรือเบอร์โทรศัพท์',
                            'name@example.com หรือ 08X-XXX-XXXX',
                            Icons.mail_outline,
                            controller: _email,
                          ),
                          const SizedBox(height: 15),
                          _field(
                            'รหัสผ่าน',
                            _register
                                ? 'ตั้งรหัสผ่านที่ปลอดภัย'
                                : '••••••••••••',
                            Icons.lock_outline,
                            controller: _password,
                            obscure: !_showPassword,
                            trailing: IconButton(
                              onPressed: () => setState(
                                () => _showPassword = !_showPassword,
                              ),
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                          ),
                          if (_register) ...[
                            const SizedBox(height: 5),
                            const Text(
                              'อย่างน้อย 8 ตัวอักษร',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 10,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _field(
                              'ยืนยันรหัสผ่าน',
                              'กรอกรหัสผ่านอีกครั้ง',
                              Icons.lock_outline,
                              controller: _confirm,
                              obscure: true,
                            ),
                          ] else ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Checkbox(
                                  value: _remember,
                                  activeColor: AppColors.primary,
                                  onChanged: (v) =>
                                      setState(() => _remember = v ?? false),
                                ),
                                const Expanded(
                                  child: Text(
                                    'จดจำการเข้าสู่ระบบ',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  ),
                                  child: const Text(
                                    'ลืมรหัสผ่าน?',
                                    style: TextStyle(
                                      color: AppColors.tertiary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (_register) ...[
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _acceptedTerms,
                                  activeColor: AppColors.primary,
                                  onChanged: (value) => setState(
                                    () => _acceptedTerms = value ?? false,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'ฉันยอมรับ ข้อกำหนดการให้บริการ และนโยบายความเป็นส่วนตัวของ PromKin',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: auth.isLoading ? null : _submit,
                              icon: auth.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      _register
                                          ? Icons.arrow_forward_rounded
                                          : Icons.login_rounded,
                                    ),
                              label: Text(
                                _register ? 'สร้างบัญชี' : 'เข้าสู่ระบบ',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB2C1AD),
                                foregroundColor: AppColors.primary,
                                minimumSize: const Size.fromHeight(52),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'หรือดำเนินการต่อด้วย',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Text(
                                    'G',
                                    style: TextStyle(
                                      color: Color(0xFF4285F4),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  label: const Text('Google'),
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.apple,
                                    color: AppColors.ink,
                                  ),
                                  label: const Text('Apple ID'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        _register
                            ? 'มีบัญชีอยู่แล้ว?  เข้าสู่ระบบ'
                            : 'ยังไม่มีบัญชีใช่หรือไม่?  สมัครสมาชิกฟรี',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Center(
                      child: Text(
                        'ข้อกำหนดการให้บริการ  ·  นโยบายความเป็นส่วนตัว\n© 2025 PROMKIN. ALL RIGHTS RESERVED.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 10,
                          height: 2,
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
  }

  Widget _authTab(String text, bool register) => Expanded(
    child: InkWell(
      onTap: () => setState(() => _register = register),
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _register == register
              ? const Color(0xFFB2C1AD)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: _register == register ? AppColors.primary : AppColors.muted,
            fontSize: 13,
          ),
        ),
      ),
    ),
  );

  Widget _field(
    String label,
    String hint,
    IconData icon, {
    required TextEditingController controller,
    bool obscure = false,
    Widget? trailing,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
      const SizedBox(height: 7),
      TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: trailing,
          filled: true,
          fillColor: const Color(0xFFF4F2EE),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
      ),
    ],
  );

  Future<void> _submit() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      _message('กรอกอีเมลและรหัสผ่านก่อน');
      return;
    }
    if (_register &&
        (_name.text.trim().isEmpty ||
            _password.text.length < 8 ||
            _password.text != _confirm.text ||
            !_acceptedTerms)) {
      _message('ตรวจสอบชื่อและรหัสผ่านให้ถูกต้อง');
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = _register
        ? await auth.createAccount(_name.text, _email.text, _password.text)
        : await auth.login(_email.text, _password.text);
    if (!mounted) return;
    if (success) {
      Navigator.maybePop(context);
    } else {
      _message('เข้าสู่ระบบไม่สำเร็จ กรุณาลองอีกครั้ง');
    }
  }

  void _message(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));
}
