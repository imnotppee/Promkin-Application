import 'package:flutter/material.dart';
import 'package:promkin_app/core/constants/app_colors.dart';

class PromkinHeader extends StatelessWidget {
  final VoidCallback? onTune;
  final VoidCallback? onProfile;
  final bool showTune;

  const PromkinHeader({
    super.key,
    this.onTune,
    this.onProfile,
    this.showTune = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.eco_outlined,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PromKin',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              Text(
                'พร้อมกิน',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (showTune)
            IconButton(
              onPressed: onTune,
              icon: const Icon(Icons.tune_rounded, color: AppColors.ink),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF4F2EE),
              ),
              tooltip: 'ตั้งค่า',
            ),
          const SizedBox(width: 6),
          IconButton.filled(
            onPressed: onProfile,
            icon: const Icon(Icons.person_outline_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              fixedSize: const Size(44, 44),
            ),
            tooltip: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}
