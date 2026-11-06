import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/screens/main_navigation_screen.dart';

/// Màn hình Đăng nhập (S01: Sign In - FR-00 & NFR-05)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'reader@naomi.app');
  final _passwordController = TextEditingController(text: 'naomi123456');
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isSignUpMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ Email và Mật khẩu!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Giả lập xác thực người dùng trong <= 1.0s theo NFR-05
    await Future.delayed(const Duration(milliseconds: 600));

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isSignUpMode ? 'Đăng ký tài khoản thành công! Chào mừng bạn.' : 'Đăng nhập thành công!'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );

      // Chuyển hướng vào màn hình chính
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  void _continueAsGuest() {
    // Chế độ Khách (Guest Mode) cho phép trải nghiệm ngay không cần tài khoản
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Logo thương hiệu Naomi
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.auto_stories_rounded, size: 42, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'NAOMI',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4.0,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ambient Manga Reader & Tracker',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.darkTextSecondary,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 40),

                // 2. Tiêu đề biểu mẫu
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _isSignUpMode ? 'TẠO TÀI KHOẢN MỚI' : 'ĐĂNG NHẬP HỆ THỐNG',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.primaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Trường Email
                TextField(
                  controller: _emailController,
                  style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.darkTextSecondary, size: 20),
                    hintText: 'Nhập địa chỉ email...',
                    hintStyle: const TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.darkSurface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.darkBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.darkBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 4. Trường Mật khẩu
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.darkTextSecondary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.darkTextSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    hintText: 'Nhập mật khẩu...',
                    hintStyle: const TextStyle(color: AppColors.darkTextMuted, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.darkSurface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.darkBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.darkBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Nút Xác thực Chính
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isLoading ? null : _handleAuth,
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            _isSignUpMode ? 'ĐĂNG KÝ TÀI KHOẢN' : 'ĐĂNG NHẬP',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.0),
                          ),
                  ),
                ),

                const SizedBox(height: 12),

                // 6. Nút Tiếp tục với vai trò Khách (Không cần đăng nhập)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkTextPrimary,
                      side: const BorderSide(color: AppColors.darkBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _continueAsGuest,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_outline_rounded, size: 18, color: AppColors.darkTextSecondary),
                        SizedBox(width: 8),
                        Text(
                          'Trải nghiệm ngay (Chế độ Khách)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 7. Chuyển đổi Đăng nhập <-> Đăng ký
                TextButton(
                  onPressed: () {
                    setState(() => _isSignUpMode = !_isSignUpMode);
                  },
                  child: Text(
                    _isSignUpMode
                        ? 'Đã có tài khoản? Đăng nhập ngay'
                        : 'Chưa có tài khoản? Đăng ký miễn phí',
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
