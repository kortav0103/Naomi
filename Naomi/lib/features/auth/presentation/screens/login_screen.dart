import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/presentation/screens/main_navigation_screen.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Màn hình Đăng nhập, Đăng ký & Khôi phục mật khẩu chuẩn thương mại (S01 - FR-00, US-00, NFR-05)
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(const CheckAuthEvent()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController(text: 'reader@naomi.app');
  final _passwordController = TextEditingController(text: 'naomi123456');
  final _displayNameController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSignUpMode = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _submitAuth(BuildContext context) {
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

    if (_isSignUpMode) {
      final name = _displayNameController.text.trim();
      context.read<AuthBloc>().add(
            SignUpSubmittedEvent(
              email: email,
              password: password,
              displayName: name.isNotEmpty ? name : 'Độc giả Naomi',
            ),
          );
    } else {
      context.read<AuthBloc>().add(
            LoginSubmittedEvent(email: email, password: password),
          );
    }
  }

  void _loginAsGuest(BuildContext context) {
    context.read<AuthBloc>().add(const GuestLoginEvent());
  }

  /// Hộp thoại Khôi phục mật khẩu qua Email (US-00 / S01)
  Future<void> _showForgotPasswordDialog(BuildContext parentContext) async {
    final resetEmailCtrl = TextEditingController(text: _emailController.text.trim());
    final newPassCtrl = TextEditingController();

    final result = await showDialog<Map<String, String>>(
      context: parentContext,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Khôi phục mật khẩu',
          style: TextStyle(color: AppColors.darkTextPrimary, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập địa chỉ Email đã đăng ký và mật khẩu mới để đặt lại quyền truy cập tài khoản:',
              style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: resetEmailCtrl,
              style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Email tài khoản',
                labelStyle: TextStyle(color: AppColors.darkTextSecondary),
                prefixIcon: Icon(Icons.email_outlined, size: 18, color: AppColors.primaryLight),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPassCtrl,
              obscureText: true,
              style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 13),
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới (tối thiểu 6 ký tự)',
                labelStyle: TextStyle(color: AppColors.darkTextSecondary),
                prefixIcon: Icon(Icons.lock_reset_rounded, size: 18, color: AppColors.primaryLight),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: AppColors.darkTextMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx, {
                'email': resetEmailCtrl.text.trim(),
                'password': newPassCtrl.text.trim(),
              });
            },
            child: const Text('Đặt lại mật khẩu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (result != null && parentContext.mounted) {
      final email = result['email'] ?? '';
      final newPassword = result['password'] ?? '';
      if (email.isEmpty || newPassword.length < 4) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập Email hợp lệ và mật khẩu mới từ 4 ký tự trở lên!'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      _emailController.text = email;
      _passwordController.text = newPassword;
      parentContext.read<AuthBloc>().add(
            ResetPasswordSubmittedEvent(email: email, newPassword: newPassword),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            );
          } else if (state is PasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Logo Naomi sang trọng
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.auto_stories_rounded, size: 46, color: Colors.white),
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

                    const SizedBox(height: 36),

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

                    // 3. Tên hiển thị (chỉ khi đăng ký)
                    if (_isSignUpMode) ...[
                      TextField(
                        controller: _displayNameController,
                        style: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.darkTextSecondary, size: 20),
                          hintText: 'Tên hiển thị của bạn (Ví dụ: Kiệt Nguyễn)',
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
                    ],

                    // 4. Trường Email
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

                    // 5. Trường Mật khẩu
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

                    // Liên kết Quên mật khẩu (US-00 / S01)
                    if (!_isSignUpMode)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showForgotPasswordDialog(context),
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 16),

                    const SizedBox(height: 8),

                    // 6. Nút Đăng nhập / Đăng ký
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
                        onPressed: isLoading ? null : () => _submitAuth(context),
                        child: isLoading
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

                    // 7. Nút Tiếp tục với vai trò Khách
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkTextPrimary,
                          side: const BorderSide(color: AppColors.darkBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: isLoading ? null : () => _loginAsGuest(context),
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

                    const SizedBox(height: 14),

                    // 8. Chuyển đổi Đăng nhập <-> Đăng ký
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
          );
        },
      ),
    );
  }
}
