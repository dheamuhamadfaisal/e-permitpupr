import 'package:flutter_test/flutter_test.dart';
import 'package:pupr_perizinan/app.dart';

void main() {
  testWidgets('PUPR Perizinan app smoke test', (WidgetTester tester) async {
    // Build aplikasi dan trigger frame.
    await tester.pumpWidget(const PuprPerizinanApp());

    // Verifikasi splash screen muncul
    expect(find.text('PUPR Perizinan'), findsOneWidget);
  });
}
