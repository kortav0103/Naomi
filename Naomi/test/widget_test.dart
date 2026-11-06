import 'package:flutter_test/flutter_test.dart';
import 'package:naomi/core/di/injection_container.dart' as di;
import 'package:naomi/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await di.init();
  });

  testWidgets('Naomi DiscoverScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NaomiApp());
    await tester.pump();

    // Xác nhận tiêu đề màn hình khám phá xuất hiện
    expect(find.text('KHÁM PHÁ TRUYỆN'), findsOneWidget);
  });
}
