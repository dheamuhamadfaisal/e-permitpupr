import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test showFormDialog builder', (WidgetTester tester) async {
    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER_ERROR: ${details.exception}');
      print(details.stack);
    };

    final item = {'status': 'aktif', 'logoUrl': null};
    final kodeController = TextEditingController(text: 'KRK');
    final namaController = TextEditingController(text: 'KRK');
    final deskripsiController = TextEditingController(text: 'KRK');
    final waktuController = TextEditingController(text: '14');
    final ukuranFileController = TextEditingController(text: '5');
    
    final List<Map<String, dynamic>> persyaratanList = [
      <String, dynamic>{
        'namaController': TextEditingController(text: 'KTP'),
        'isOpsional': false,
        'maxSizeController': TextEditingController(text: '5'),
      }
    ];

    String rawStatus = 'aktif';
    String status = ['aktif', 'nonaktif'].contains(rawStatus) ? rawStatus : 'aktif';

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: Text('Edit'),
                      content: SingleChildScrollView(
                        child: SizedBox(
                          width: double.maxFinite,
                          child: Column(
                            children: [
                              ...persyaratanList.asMap().entries.map((entry) {
                                int idx = entry.key;
                                var req = entry.value;
                                return Card(
                                  child: Column(
                                    children: [
                                      TextField(controller: req['namaController']),
                                      TextField(controller: req['maxSizeController']),
                                      Checkbox(
                                        value: req['isOpsional'] ?? false,
                                        onChanged: (val) {
                                          setState(() {
                                            req['isOpsional'] = val ?? false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              DropdownButtonFormField<String>(
                                value: status,
                                items: const [
                                  DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                                  DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
                                ],
                                onChanged: (val) {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            child: Text('Open'),
          );
        }),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  });
}
