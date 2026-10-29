import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test Exception', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER ERROR: ${details.exception}');
      print(details.stack);
    };

    String status = 'Aktif'; // capitalized!
    
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DropdownButtonFormField<String>(
          initialValue: status,
          items: const [
            DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
            DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
          ],
          onChanged: (val) {},
        ),
      ),
    ));
    
  });
}
