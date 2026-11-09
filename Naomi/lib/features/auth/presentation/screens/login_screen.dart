import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_context_extension.dart';
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
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  final TextEditingController _displayNameController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSignUpMode = false;

  // Biểu thức chính quy kiểm tra định dạng email chuẩn RFC 5322 cơ bản (không dùng nháy cong)
  final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$",
  );

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: kDebugMode ? 'reader@naomi.app' : '');
    _passwordController = TextEditingController(text: kDebugMode ? 'naomi123456' : '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _submitAuth(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text; // Không trim password để bảo toàn ký tự khoảng trắng nếu có

    if (_isSignUpMode) {
      final name = _displayNameController.text.trim();
      context.read<AuthBloc>().add(
            SignUpSubmittedEvent(
              email: email,
              password: password,
              displayName: name.isNotEmpty ? name : 'Naomi Reader',
            ),
          );
    } else {
      context.read<AuthBloc>().add(
            LoginSubmittedEvent(email: email, password: password),
          );
    }
  }

  void _loginAsGuest(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<AuthBloc>().add(const GuestLoginEvent());
  }

  /// Mở hộp thoại Khôi phục mật khẩu qua Email (US-00 / S01)
  Future<void> _showForgotPasswordDialog(BuildContext parentContext) async {
    final email = await showDialog<String?>(
      context: parentContext,
      barrierDismissible: false,
      builder: (_) => _ForgotPasswordDialog(
        initialEmail: _emailController.text.trim(),
        emailRegex: _emailRegex,
      ),
    );

    if (email != null && email.isNotEmpty && parentContext.mounted) {
      parentContext.read<AuthBloc>().add(
            ResetPasswordSubmittedEvent(email),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            );
          } else if (state is PasswordResetSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 4),
                ),
              );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  duration: const Duration(seconds: 4),
                ),
              );
          }
        },
        builder: (context, state) {
          // Tránh chớp nháy form đăng nhập khi ứng dụng đang kiểm tra phiên lưu sẵn
          if (state is AuthInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Logo thương hiệu Naomi
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

                      Text(
                        'NAOMI',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Ambient Manga Reader & Tracker',
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 36),

                      // 2. Tiêu đề biểu mẫu
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _isSignUpMode ? 'CREATE NEW ACCOUNT' : 'SIGN IN TO YOUR ACCOUNT',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 3. Tên hiển thị (chỉ hiển thị khi đăng ký)
                      if (_isSignUpMode) ...[
                        TextFormField(
                          controller: _displayNameController,
                          style: TextStyle(color: context.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                              color: context.textSecondary,
                              size: 20,
                            ),
                            hintText: 'Your display name (e.g., Alex Mercer)',
                            hintStyle: TextStyle(color: context.textMuted, fontSize: 13),
                            filled: true,
                            fillColor: context.surfaceColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: context.borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: context.borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.error),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                            ),
                          ),
                          validator: (value) {
                            if (_isSignUpMode && (value == null || value.trim().isEmpty)) {
                              return 'Please enter a display name!';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                      ],

                      // 4. Trường nhập Email
                      TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: context.textPrimary, fontSize: 14),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: context.textSecondary,
                            size: 20,
                          ),
                          hintText: 'Enter your email address...',
                          hintStyle: TextStyle(color: context.textMuted, fontSize: 13),
                          filled: true,
                          fillColor: context.surfaceColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: context.borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: context.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.error),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email address!';
                          }
                          if (!_emailRegex.hasMatch(value.trim())) {
                            return 'Invalid email address format!';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // 5. Trường nhập Mật khẩu
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: context.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock_outline_rounded,
                            color: context.textSecondary,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: context.textSecondary,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          hintText: 'Enter your password...',
                          hintStyle: TextStyle(color: context.textMuted, fontSize: 13),
                          filled: true,
                          fillColor: context.surfaceColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: context.borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: context.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.error),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password!';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long!';
                          }
                          return null;
                        },
                      ),

                      // Nút Quên mật khẩu
                      if (!_isSignUpMode)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: isLoading ? null : () => _showForgotPasswordDialog(context),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: context.textSecondary, fontSize: 12),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 16),

                      const SizedBox(height: 8),

                      // 6. Nút Thực thi Đăng nhập / Đăng ký
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
                                  _isSignUpMode ? 'SIGN UP' : 'SIGN IN',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 7. Nút Tiếp tục với Chế độ Khách (Guest Mode)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.textPrimary,
                            side: BorderSide(color: context.borderColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: isLoading ? null : () => _loginAsGuest(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_outline_rounded, size: 18, color: context.textSecondary),
                              const SizedBox(width: 8),
                              const Text(
                                'Continue as Guest',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // 8. Chuyển đổi trạng thái Đăng nhập <-> Đăng ký
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                _formKey.currentState?.reset();
                                setState(() => _isSignUpMode = !_isSignUpMode);
                              },
                        child: Text(
                          _isSignUpMode
                              ? 'Already have an account? Sign In'
                              : "Don't have an account? Sign Up for free",
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
        },
      ),
    );
  }
}

/// Hộp thoại Khôi phục mật khẩu chuẩn Supabase (gửi link đặt lại mật khẩu qua email)
class _ForgotPasswordDialog extends StatefulWidget {
  final String initialEmail;
  final RegExp emailRegex;

  const _ForgotPasswordDialog({
    required this.initialEmail,
    required this.emailRegex,
  });

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _dialogFormKey = GlobalKey<FormState>();
  late final TextEditingController _resetEmailCtrl;

  @override
  void initState() {
    super.initState();
    _resetEmailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _resetEmailCtrl.dispose();
    super.dispose();
  }

  void _onConfirm() {
    if (!_dialogFormKey.currentState!.validate()) {
      return;
    }

    Navigator.pop(context, _resetEmailCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Reset Password',
        style: TextStyle(
          color: context.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Form(
        key: _dialogFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your registered email address. We will send you a secure link to reset your password:',
              style: TextStyle(color: context.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _resetEmailCtrl,
              style: TextStyle(color: context.textPrimary, fontSize: 13),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Account Email',
                labelStyle: TextStyle(color: context.textSecondary, fontSize: 12),
                prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.primaryLight),
                isDense: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email!';
                }
                if (!widget.emailRegex.hasMatch(value.trim())) {
                  return 'Invalid email address!';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: context.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _onConfirm,
          child: const Text('Send Reset Link', style: TextStyle(color: Colors.white, fontSize: 13)),
        ),
      ],
    );
  }
}
