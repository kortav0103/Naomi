import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Màn hình Hồ sơ & Cài đặt hệ thống (S08) theo đặc tả Mục 1.6
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _cacheSizeMb = 42.5; // Dung lượng cache giả lập đo thực tế
  bool _isDarkMode = true;

  void _clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    setState(() {
      _cacheSizeMb = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.darkSurface,
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
            SizedBox(width: 8),
            Text(
              'Đã dọn dẹp sạch bộ nhớ đệm tạm thời!',
              style: TextStyle(color: AppColors.darkTextPrimary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text(
          'HỒ SƠ & CÀI ĐẶT',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.darkTextPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Thẻ thông tin độc giả (User Card)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.person_rounded, size: 36, color: AppColors.primaryLight),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kiet Nguyen',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkTextPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'kiet.nguyen@naomi.reader',
                        style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 2. Nhóm Cài đặt Giao diện & Đọc
          const Text(
            'TÙY CHỌN ỨNG DỤNG',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 8),

          Material(
            color: AppColors.darkSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.darkBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Chế độ tối AMOLED',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
                  ),
                  subtitle: const Text(
                    'Tối ưu tiết kiệm pin trên màn hình OLED (NFR-16)',
                    style: TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                  ),
                  value: _isDarkMode,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _isDarkMode = val);
                  },
                ),
                const Divider(height: 1, color: AppColors.darkBorder),
                const ListTile(
                  title: Text(
                    'Ngôn ngữ bản dịch mặc định',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
                  ),
                  subtitle: Text(
                    'Tiếng Việt & Tiếng Anh',
                    style: TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: AppColors.darkTextMuted),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Nhóm Quản lý Bộ nhớ (NFR-07 LRU Cache)
          const Text(
            'BỘ NHỚ & DỮ LIỆU CỤC BỘ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bộ nhớ đệm ảnh tạm thời (Disk Cache)',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
                    ),
                    Text(
                      '${_cacheSizeMb.toStringAsFixed(1)} MB / 500 MB',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: _cacheSizeMb / 500.0,
                  backgroundColor: AppColors.darkBackground,
                  color: AppColors.primary,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                    label: const Text('Dọn dẹp bộ nhớ đệm ngay'),
                    onPressed: _cacheSizeMb > 0 ? _clearCache : null,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 4. Thông tin đồ án & Phiên bản
          const Center(
            child: Column(
              children: [
                Text(
                  'NAOMI MANGA READER',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppColors.darkTextMuted),
                ),
                SizedBox(height: 4),
                Text(
                  'Phiên bản 1.0.0 (Assignment 02)',
                  style: TextStyle(fontSize: 11, color: AppColors.darkTextMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
