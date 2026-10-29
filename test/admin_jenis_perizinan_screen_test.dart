import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pupr_perizinan/features/admin/screens/admin_jenis_perizinan_screen.dart';
import 'package:pupr_perizinan/models/jenis_perizinan_model.dart';
import 'package:pupr_perizinan/models/permohonan_model.dart';
import 'package:pupr_perizinan/models/user_model.dart';
import 'package:pupr_perizinan/providers/admin_provider.dart';

class MockAdminProvider extends AdminProvider {
  @override
  bool get isJenisLoading => false;
  @override
  List<JenisPerizinanModel> get jenisList => [
    const JenisPerizinanModel(
      id: 1,
      kode: 'KRK',
      nama: 'KRK',
      persyaratan: [PersyaratanModel(nama: 'KTP', isOpsional: false, maxSizeMb: 5)],
      status: 'aktif',
    )
  ];
  @override
  String? get error => null;
  @override
  bool get isActionLoading => false;
}

void main() {
  testWidgets('show dialog', (WidgetTester tester) async {
    final provider = MockAdminProvider();
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<AdminProvider>.value(
          value: provider,
          child: const AdminJenisPerizinanScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    
    // Tap edit button
    await tester.tap(find.byIcon(Icons.edit_outlined).first);
    await tester.pump(); // Start animation
    await tester.pumpAndSettle(); // Finish animation
    
    expect(find.text('Edit Jenis Perizinan'), findsOneWidget);
  });
}
