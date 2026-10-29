import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pupr_perizinan/features/petugas/screens/petugas_detail_screen.dart';
import 'package:pupr_perizinan/providers/petugas_provider.dart';
import 'package:pupr_perizinan/models/permohonan_model.dart';
import 'package:pupr_perizinan/models/jenis_perizinan_model.dart';
import 'package:pupr_perizinan/models/user_model.dart';
import 'package:pupr_perizinan/models/permohonan_history_model.dart';
import 'package:pupr_perizinan/models/permohonan_dokumen_model.dart';

class MockPetugasProvider extends PetugasProvider {
  MockPetugasProvider() : super(); // no service arg

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  PermohonanModel? get selectedPermohonan {
    return const PermohonanModel(
      id: 1,
      nomorPermohonan: 'PM-2026-00002',
      userId: 1,
      jenisPerizinanId: 1,
      status: 'diajukan',
      createdAt: '2026-01-01',
      updatedAt: '2026-01-01',
      fieldBermasalah: [],
      jenisPerizinan: JenisPerizinanModel(id: 1, kode: 'SITEPLAN', nama: 'Pengesahan Site Plan', deskripsi: ''),
      pemohon: UserModel(id: 1, name: 'Pemohon', email: 'pemohon@test.com'),
      histories: [
        PermohonanHistoryModel(id: 1, permohonanId: 1, userId: 1, statusBaru: 'diajukan', createdAt: '2026-01-01'),
      ],
      dokumen: [
        PermohonanDokumenModel(
          id: 1, permohonanId: 1, jenisDokumen: 'KTP', namaFile: 'ktp.pdf', path: 'ktp.pdf', mimeType: 'application/pdf', ukuran: 1000, statusVerifikasi: 'pending', createdAt: '2026-01-01', updatedAt: '2026-01-01',
        )
      ],
    );
  }
}

void main() {
  testWidgets('PetugasDetailScreen renders on narrow screen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(300, 800);
    tester.view.devicePixelRatio = 1.0;

    FlutterError.onError = (FlutterErrorDetails details) {
      print('FLUTTER ERROR CAUGHT: ${details.exception}');
      print(details.stack);
    };

    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<PetugasProvider>(
              create: (_) => MockPetugasProvider(),
            ),
          ],
          child: const PetugasDetailScreen(permohonanId: 1),
        ),
      ),
    );

    await tester.pumpAndSettle();
    
    expect(find.text('Proses: PM-2026-00002'), findsOneWidget);
    
    // reset
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
