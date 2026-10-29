import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';
import 'package:promkin_app/features/auth/presentation/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์ผู้ใช้')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: user == null
            ? Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text('ไปที่หน้าเข้าสู่ระบบ'),
                ),
              )
            : Column(
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 54,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  const ListTile(
                    leading: Icon(Icons.security),
                    title: Text('สถานะการยืนยันตัวตน'),
                    trailing: Text(
                      'ออนไลน์ (Mock/Firebase)',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: () => auth.logout(),
                    icon: const Icon(Icons.logout),
                    label: const Text('ออกจากระบบ'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
