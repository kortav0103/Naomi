import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_context_extension.dart';
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
        SnackBar(
          backgroundColor: context.surfaceColor,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
              const SizedBox(width: 8),
              Text(
                'Temporary cache cleared successfully!',
                style: TextStyle(color: context.textPrimary),
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
        backgroundColor: context.surfaceColor,
        title: Text('Edit Display Name', style: TextStyle(color: context.textPrimary, fontSize: 16)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: context.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter your new display name...',
            hintStyle: TextStyle(color: context.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
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
              SnackBar(content: Text('Error: ${failure.message}'), backgroundColor: AppColors.error),
            );
          }
        },
        (updated) {
          if (mounted) {
            setState(() => _currentUser = updated);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Display name updated successfully!'), backgroundColor: AppColors.primary),
            );
          }
        },
      );
    }
  }

  /// Hộp thoại chọn Ngôn ngữ bản dịch mặc định (Chỉ hỗ trợ Tiếng Anh EN)
  Future<void> _showLanguagePickerDialog() async {
    const options = [
      {'code': 'en', 'label': 'English Only (EN)'},
    ];

    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: Text(
          'Comic Translation Language',
          style: TextStyle(color: context.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.radio_button_checked_rounded,
                color: AppColors.primaryLight,
              ),
              title: Text(
                opt['label']!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryLight,
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
    return 'English Only (EN)';
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: Text('Sign Out', style: TextStyle(color: context.textPrimary, fontSize: 16)),
        content: Text(
          'Are you sure you want to sign out of Naomi?',
          style: TextStyle(color: context.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Stay', style: TextStyle(color: context.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
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
    final displayName = user?.displayName.isNotEmpty == true ? user!.displayName : 'Naomi Reader';
    final email = user?.email.isNotEmpty == true ? user!.email : 'reader@naomi.app';
    final isGuest = user?.isGuest ?? false;
    final isDarkMode = _themeController.isDarkMode;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(
          'PROFILE & SETTINGS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: context.textPrimary,
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
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
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
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primaryLight),
                            tooltip: 'Edit display name',
                            onPressed: _showEditNameDialog,
                          ),
                        ],
                      ),
                      Text(
                        email,
                        style: TextStyle(fontSize: 12, color: context.textSecondary),
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
                          isGuest ? 'GUEST READER' : 'OFFICIAL MEMBER',
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
            'APP PREFERENCES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 8),

          Material(
            color: context.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: context.borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Dark Mode',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary),
                  ),
                  value: isDarkMode,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    _themeController.toggleDarkMode(val);
                    setState(() {});
                  },
                ),
                Divider(height: 1, color: context.borderColor),
                ListTile(
                  title: Text(
                    'Comic Translation Language',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.textPrimary),
                  ),
                  subtitle: Text(
                    _getLanguageLabel(_themeController.preferredLanguage),
                    style: const TextStyle(fontSize: 11, color: AppColors.primaryLight),
                  ),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.textMuted),
                  onTap: _showLanguagePickerDialog,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Nhóm Quản lý Bộ nhớ Thật
          const Text(
            'STORAGE & LOCAL DATA',
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
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Image Cache on Disk',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.textPrimary),
                    ),
                    Text(
                      _isLoadingCache ? 'Calculating...' : '${_cacheSizeMb.toStringAsFixed(1)} MB / 500 MB',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryLight),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (_cacheSizeMb / 500.0).clamp(0.01, 1.0),
                  backgroundColor: context.backgroundColor,
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
                    label: const Text('Clear Cache Now'),
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
              label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
              onPressed: _handleLogout,
            ),
          ),

          const SizedBox(height: 32),

          // 5. Thông tin đồ án & Phiên bản
          Center(
            child: Column(
              children: [
                Text(
                  'NAOMI MANGA READER',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2, color: context.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0 (Production Build)',
                  style: TextStyle(fontSize: 11, color: context.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
