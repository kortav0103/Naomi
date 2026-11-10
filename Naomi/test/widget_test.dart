import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:naomi/core/di/injection_container.dart' as di;
import 'package:naomi/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await di.init();
  });

  testWidgets('Naomi App Smoke Test - Displays Auth Screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NaomiApp());
    await tester.pump();

    // Cho phép các Future bất đồng bộ trong BLoC / DI xử lý xong
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pump();

    // Xác nhận màn hình xác thực thương hiệu NAOMI xuất hiện
    expect(find.text('NAOMI'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
  });
}