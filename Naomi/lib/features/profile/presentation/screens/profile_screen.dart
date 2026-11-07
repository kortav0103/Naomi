import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/screens/login_screen.dart';

/// Màn hình Hồ sơ & Cài đặt hệ thống chuẩn Production (S08 - FR-14, NFR-07, NFR-16)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ThemeController _themeController = sl<ThemeController>();
  UserEntity? _currentUser;
  double _cacheSizeMb = 0.0;
  bool _isLoadingCache = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _calculateRealCacheSize();
  }

  Future<void> _loadUserProfile() async {
    final authRepo = sl<AuthRepository>();
    final result = await authRepo.getCurrentUser();
    result.fold(
      (_) {},
      (user) {
        if (mounted) setState(() => _currentUser = user);
      },
    );
  }

  /// Tính toán dung lượng bộ nhớ đệm ảnh thật trên đĩa thiết bị (NFR-07)
  Future<void> _calculateRealCacheSize() async {
    try {
      final tempDir = await getTemporaryDirectory();
      int totalBytes = 0;
      if (await tempDir.exists()) {
        await for (final file in tempDir.list(recursive: true, followLinks: false)) {
          if (file is File) {
            totalBytes += await file.length();
          }
        }
      }
      if (mounted) {
        setState(() {
          _cacheSizeMb = totalBytes / (1024 * 1024);
          _isLoadingCache = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _cacheSizeMb = 0.0;
          _isLoadingCache = false;
        });
      }
    }
  }

  /// Dọn dẹp bộ nhớ đệm thật sự trên đĩa và trong RAM (NFR-07)
  Future<void> _clearRealCache() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final file in tempDir.list(recursive: false)) {
          try {
            await file.delete(recursive: true);
          } catch (_) {}
        }
      }
    } catch (_) {}

    await _calculateRealCacheSize();

    if (mounted) {
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
  }

  /// Hộp thoại Chỉnh sửa Tên hiển thị
  Future<void> _showEditNameDialog() async {
    final controller = TextEditingController(text: _currentUser?.displayName ?? '');

    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Đổi tên hiển thị', style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 16)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.darkTextPrimary),
          decoration: const InputDecoration(
            hintText: 'Nhập tên mới của bạn...',
            hintStyle: TextStyle(color: AppColors.darkTextMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppColors.darkTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final authRepo = sl<AuthRepository>();
      final result = await authRepo.updateProfile(displayName: newName);
      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi: ${failure.message}'), backgroundColor: AppColors.error),
            );
          }
        },
        (updated) {
          if (mounted) {
            setState(() => _currentUser = updated);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã cập nhật tên hiển thị thành công!'), backgroundColor: AppColors.primary),
            );
          }
        },
      );
    }
  }

  /// Hộp thoại chọn Ngôn ngữ bản dịch mặc định (FR-14)
  Future<void> _showLanguagePickerDialog() async {
    final currentLang = _themeController.preferredLanguage;
    final options = [
      {'code': 'all', 'label': 'Tất cả (Ưu tiên Tiếng Việt VI -> EN)'},
      {'code': 'vi', 'label': 'Chỉ bản dịch Tiếng Việt (VI)'},
      {'code': 'en', 'label': 'Chỉ bản dịch Tiếng Anh (EN)'},
    ];

    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Ngôn ngữ bản dịch mặc định',
          style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            final isSelected = opt['code'] == currentLang;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: isSelected ? AppColors.primaryLight : AppColors.darkTextMuted,
              ),
              title: Text(
                opt['label']!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primaryLight : AppColors.darkTextPrimary,
                ),
              ),
              onTap: () => Navigator.pop(ctx, opt['code']),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null) {
      _themeController.setPreferredLanguage(selected);
      setState(() {});
    }
  }

  String _getLanguageLabel(String code) {
    switch (code) {
      case 'vi':
        return 'Chỉ Tiếng Việt (VI)';
      case 'en':
        return 'Chỉ Tiếng Anh (EN)';
      default:
        return 'Tất cả (Ưu tiên Tiếng Việt VI -> EN)';
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Đăng xuất tài khoản', style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 16)),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi Naomi không?',
          style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ở lại', style: TextStyle(color: AppColors.darkTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await sl<AuthRepository>().logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final displayName = user?.displayName.isNotEmpty == true ? user!.displayName : 'Độc giả Naomi';
    final email = user?.email.isNotEmpty == true ? user!.email : 'reader@naomi.app';
    final isGuest = user?.isGuest ?? false;
    final isDarkMode = _themeController.isDarkMode;

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
                // Avatar với chữ cái đầu
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'N',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkTextPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryLight),
                            tooltip: 'Đổi tên hiển thị',
                            onPressed: _showEditNameDialog,
                          ),
                        ],
                      ),
                      Text(
                        email,
                        style: const TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isGuest
                              ? AppColors.warning.withValues(alpha: 0.2)
                              : AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isGuest ? AppColors.warning : AppColors.primaryLight,
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          isGuest ? 'KHÁCH TRẢI NGHIỆM' : 'THÀNH VIÊN CHÍNH THỨC',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isGuest ? AppColors.warning : AppColors.primaryLight,
                          ),
                        ),
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
            'TÙY CHỌN ỨNG DỤNG (FR-14)',
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
                  subtitle: Text(
                    isDarkMode
                        ? 'Đang bật AMOLED Dark (#111116) tiết kiệm pin OLED (NFR-16)'
                        : 'Đang dùng chế độ Sáng (Light Mode)',
                    style: const TextStyle(fontSize: 11, color: AppColors.darkTextSecondary),
                  ),
                  value: isDarkMode,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    _themeController.toggleDarkMode(val);
                    setState(() {});
                  },
                ),
                const Divider(height: 1, color: AppColors.darkBorder),
                ListTile(
                  title: const Text(
                    'Ngôn ngữ bản dịch mặc định',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
                  ),
                  subtitle: Text(
                    _getLanguageLabel(_themeController.preferredLanguage),
                    style: const TextStyle(fontSize: 11, color: AppColors.primaryLight),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.darkTextMuted),
                  onTap: _showLanguagePickerDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Nhóm Quản lý Bộ nhớ Thật (NFR-07 LRU Disk Cache)
          const Text(
            'BỘ NHỚ & DỮ LIỆU CỤC BỘ (NFR-07)',
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
                      'Bộ nhớ đệm ảnh thật trên đĩa',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
                    ),
                    Text(
                      _isLoadingCache ? 'Đang đo...' : '${_cacheSizeMb.toStringAsFixed(1)} MB / 500 MB',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (_cacheSizeMb / 500.0).clamp(0.01, 1.0),
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
                    onPressed: _clearRealCache,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Nút Đăng xuất tài khoản
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Đăng xuất tài khoản', style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: _handleLogout,
            ),
          ),

          const SizedBox(height: 32),

          // 5. Thông tin đồ án & Phiên bản
          const Center(
            child: Column(
              children: [
                Text(
                  'NAOMI MANGA READER',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppColors.darkTextMuted),
                ),
                SizedBox(height: 4),
                Text(
                  'Phiên bản 1.0.0 (Production Build)',
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
