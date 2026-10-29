import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';
import 'package:promkin_app/core/widgets/motion_widgets.dart';
import 'package:promkin_app/features/auth/presentation/screens/forgot_password_screen.dart';

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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: FadeSlideIn(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                      child: SizedBox(
                        height: 48,
                        child: Center(
                          child: Text(
                            _register ? 'Create Account' : 'Sign In',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    sliver: SliverList.list(
                      children: [
                        const SizedBox(height: 8),
                        Center(
                          child: Image.asset(
                            'assets/images/promkin_logo.png',
                            width: 132,
                            height: 132,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.restaurant_rounded,
                                  color: AppColors.primary,
                                  size: 64,
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
                                  'ชื่อผู้ใช้ (Username)',
                                  'เช่น Piyawit',
                                  Icons.person_outline,
                                  controller: _name,
                                ),
                                const SizedBox(height: 15),
                              ],
                              _field(
                                'อีเมล',
                                'name@example.com',
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
                                  'รหัสผ่านต้องมีอย่างน้อย 8 ตัว และประกอบด้วย A-Z, a-z, ตัวเลข และอักขระพิเศษ เช่น ! @ # \$ %',
                                  style: TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 11,
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
                                      onChanged: (v) => setState(
                                        () => _remember = v ?? false,
                                      ),
                                    ),
                                    const Expanded(
                                      child: Text(
                                        'จดจำการเข้าสู่ระบบ',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: auth.isLoading
                                          ? null
                                          : () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const ForgotPasswordScreen(),
                                              ),
                                            ),
                                      child: const Text('ลืมรหัสผ่าน?'),
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
                                    backgroundColor: AppColors.secondary,
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
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
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: auth.isLoading
                                      ? null
                                      : _signInWithGoogle,
                                  icon: const Text(
                                    'G',
                                    style: TextStyle(
                                      color: Color(0xFF4285F4),
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  label: const Text('ดำเนินการต่อด้วย Google'),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.dinnerBg,
                                    side: BorderSide.none,
                                    minimumSize: const Size.fromHeight(48),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () => setState(() {
                              _register = !_register;
                            }),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.ink,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: _register
                                    ? 'มีบัญชีอยู่แล้ว?  '
                                    : 'ยังไม่มีบัญชีใช่หรือไม่?  ',
                                style: const TextStyle(fontSize: 13),
                                children: [
                                  TextSpan(
                                    text: _register
                                        ? 'เข้าสู่ระบบ'
                                        : 'สมัครสมาชิกฟรี',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
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
              ? AppColors.secondary
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
    if (_register) {
      final password = _password.text;
      final hasRequiredPasswordParts =
          password.length >= 8 &&
          RegExp(r'[A-Z]').hasMatch(password) &&
          RegExp(r'[a-z]').hasMatch(password) &&
          RegExp(r'[0-9]').hasMatch(password) &&
          RegExp(r'[^A-Za-z0-9]').hasMatch(password);

      if (_name.text.trim().isEmpty) {
        _message('กรุณากรอกชื่อผู้ใช้');
        return;
      }
      if (!hasRequiredPasswordParts) {
        _message(
          'รหัสผ่านต้องยาวอย่างน้อย 8 ตัว มี A-Z, a-z, ตัวเลข และอักขระพิเศษ',
        );
        return;
      }
      if (password != _confirm.text) {
        _message('รหัสผ่านและการยืนยันรหัสผ่านไม่ตรงกัน');
        return;
      }
      if (!_acceptedTerms) {
        _message('กรุณายอมรับข้อกำหนดการให้บริการก่อนสร้างบัญชี');
        return;
      }
    }
    final auth = context.read<AuthProvider>();
    final success = _register
        ? await auth.createAccount(_name.text, _email.text, _password.text)
        : await auth.login(_email.text, _password.text);
    if (!mounted) return;
    if (success) {
      // AuthProvider updates the root authentication gate after success.
    } else {
      _message(auth.errorMessage ?? 'เข้าสู่ระบบไม่สำเร็จ กรุณาลองอีกครั้ง');
    }
  }

  Future<void> _signInWithGoogle() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (!mounted || success || auth.errorMessage == null) return;
    _message(auth.errorMessage!);
  }

  void _message(String value) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(value)));
}
