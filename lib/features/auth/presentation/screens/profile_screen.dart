import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:promkin_app/core/constants/app_colors.dart';
import 'package:promkin_app/core/services/firebase_service.dart';
import 'package:promkin_app/features/auth/presentation/auth_provider.dart';

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
            ? auth.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst),
                        child: const Text('กลับไปหน้าเข้าสู่ระบบ'),
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
                  ListTile(
                    leading: const Icon(Icons.verified_user_outlined),
                    title: const Text('สถานะการยืนยันตัวตน'),
                    subtitle: const Text('Firebase Authentication'),
                    trailing: const Text(
                      'ยืนยันแล้ว',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  FutureBuilder<bool>(
                    future: FirebaseService.instance.verifyFirestoreConnection(
                      user.id,
                    ),
                    builder: (context, snapshot) {
                      final connected = snapshot.data == true;
                      return ListTile(
                        leading: Icon(
                          connected
                              ? Icons.cloud_done_outlined
                              : Icons.cloud_off_outlined,
                        ),
                        title: const Text('Cloud Firestore'),
                        trailing:
                            snapshot.connectionState == ConnectionState.waiting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                connected ? 'เชื่อมต่อแล้ว' : 'เชื่อมต่อไม่ได้',
                                style: TextStyle(
                                  color: connected
                                      ? AppColors.primary
                                      : AppColors.error,
                                ),
                              ),
                      );
                    },
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            final loggedOut = await auth.logout();
                            if (!context.mounted) return;
                            if (loggedOut) {
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    auth.errorMessage ??
                                        'ออกจากระบบไม่สำเร็จ กรุณาลองอีกครั้ง',
                                  ),
                                ),
                              );
                            }
                          },
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
