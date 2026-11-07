import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum SimulatorDevice {
  iphone16Pro(
    label: 'iPhone 16 Pro (iOS)',
    width: 393,
    height: 852,
    borderRadius: 50,
    isIOS: true,
    isFullScreen: false,
  ),
  iphone16ProMax(
    label: 'iPhone 16 Pro Max (iOS)',
    width: 430,
    height: 932,
    borderRadius: 54,
    isIOS: true,
    isFullScreen: false,
  ),
  pixel8Pro(
    label: 'Pixel 8 Pro (Android)',
    width: 412,
    height: 892,
    borderRadius: 38,
    isIOS: false,
    isFullScreen: false,
  ),
  fullScreen(
    label: 'Toàn màn hình (Desktop)',
    width: double.infinity,
    height: double.infinity,
    borderRadius: 0,
    isIOS: false,
    isFullScreen: true,
  );

  final String label;
  final double width;
  final double height;
  final double borderRadius;
  final bool isIOS;
  final bool isFullScreen;

  const SimulatorDevice({
    required this.label,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.isIOS,
    required this.isFullScreen,
  });
}

/// Cho phép dùng chuột kéo/vuốt trên Windows & Web mượt như cảm ứng trên iOS/Android
class MobileTouchScrollBehavior extends MaterialScrollBehavior {
  const MobileTouchScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

/// Bộ khung Giả lập Di động (iOS iPhone 16 Pro / Android Pixel 8 Pro) tích hợp sẵn cho Desktop & Web
class MobileSimulatorWrapper extends StatefulWidget {
  final Widget child;

  const MobileSimulatorWrapper({
    super.key,
    required this.child,
  });

  @override
  State<MobileSimulatorWrapper> createState() => _MobileSimulatorWrapperState();
}

class _MobileSimulatorWrapperState extends State<MobileSimulatorWrapper> {
  SimulatorDevice _selectedDevice = SimulatorDevice.iphone16Pro;
  bool _isLandscape = false;

  bool get _isDesktopOrWeb {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  @override
  Widget build(BuildContext context) {
    // Nếu đang chạy trên điện thoại Android/iOS thật hoặc trong môi trường Unit Test màn hình nhỏ, hiển thị trực tiếp
    if (!_isDesktopOrWeb) {
      return widget.child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Khi chạy flutter test (mặc định 800x600) hoặc cửa sổ quá nhỏ, không bọc thanh công cụ để giữ nguyên test
        if (constraints.maxWidth <= 800 && constraints.maxHeight <= 600) {
          return widget.child;
        }

        if (_selectedDevice.isFullScreen) {
          return Column(
            children: [
              _buildSimulatorToolbar(),
              Expanded(child: widget.child),
            ],
          );
        }

        final double targetW = _isLandscape ? _selectedDevice.height : _selectedDevice.width;
        final double targetH = _isLandscape ? _selectedDevice.width : _selectedDevice.height;

        return Scaffold(
          backgroundColor: const Color(0xFF09090D),
          body: Column(
            children: [
              _buildSimulatorToolbar(),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: _buildPhoneFrame(targetW, targetH),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimulatorToolbar() {
    return Material(
      color: const Color(0xFF15151E),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.darkBorder, width: 1),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.phone_iphone_rounded, color: AppColors.primaryLight, size: 18),
            const SizedBox(width: 8),
            const Text(
              'NAOMI MOBILE SIMULATOR',
              style: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(width: 16),
            // Các nút chọn thiết bị giả lập (iOS / Android / Fullscreen)
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: SimulatorDevice.values.map((device) {
                    final isSelected = _selectedDevice == device;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          device.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.darkTextSecondary,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.darkBackground,
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) {
                          setState(() => _selectedDevice = device);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (!_selectedDevice.isFullScreen)
              IconButton(
                tooltip: 'Xoay màn hình Dọc / Ngang',
                icon: Icon(
                  _isLandscape ? Icons.stay_current_landscape_rounded : Icons.stay_current_portrait_rounded,
                  size: 18,
                  color: AppColors.darkTextSecondary,
                ),
                onPressed: () => setState(() => _isLandscape = !_isLandscape),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneFrame(double width, double height) {
    final radius = _selectedDevice.borderRadius;
    final mediaQuery = MediaQuery.of(context);

    return Container(
      width: width + 24,
      height: height + 24,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF22222B),
        borderRadius: BorderRadius.circular(radius + 8),
        border: Border.all(
          color: const Color(0xFF454555),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.75),
            blurRadius: 40,
            spreadRadius: 4,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 32,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: width,
          height: height,
          child: MediaQuery(
            data: mediaQuery.copyWith(
              size: Size(width, height),
              padding: EdgeInsets.only(
                top: _selectedDevice.isIOS ? 48 : 32,
                bottom: _selectedDevice.isIOS ? 24 : 16,
              ),
              viewPadding: EdgeInsets.only(
                top: _selectedDevice.isIOS ? 48 : 32,
                bottom: _selectedDevice.isIOS ? 24 : 16,
              ),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                platform: _selectedDevice.isIOS ? TargetPlatform.iOS : TargetPlatform.android,
              ),
              child: Stack(
                children: [
                  // Nội dung ứng dụng Naomi
                  Positioned.fill(child: widget.child),

                  // Thanh trạng thái iOS / Dynamic Island hoặc Camera đục lỗ Android
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: _buildStatusBarOverlay(),
                    ),
                  ),

                  // Thanh Home Indicator chuẩn iOS / Android Gesture Bar ở đáy màn hình
                  Positioned(
                    bottom: 6,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: Container(
                          width: _selectedDevice.isIOS ? 134 : 108,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
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

  Widget _buildStatusBarOverlay() {
    final now = TimeOfDay.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return Container(
      height: _selectedDevice.isIOS ? 44 : 32,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Đồng hồ bên trái
          Text(
            timeStr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),

          // Dynamic Island (iOS) hoặc Punch-hole Camera (Android)
          if (_selectedDevice.isIOS && !_isLandscape)
            Container(
              width: 116,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10, width: 0.8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A1A2E),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            )
          else if (!_selectedDevice.isIOS && !_isLandscape)
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),

          // Biểu tượng Sóng, Wi-Fi, Pin bên phải
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.signal_cellular_alt_rounded, color: Colors.white, size: 15),
              SizedBox(width: 4),
              Icon(Icons.wifi_rounded, color: Colors.white, size: 15),
              SizedBox(width: 4),
              Icon(Icons.battery_full_rounded, color: Colors.white, size: 17),
            ],
          ),
        ],
      ),
    );
  }
}
