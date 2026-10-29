import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pupr_perizinan/features/petugas/screens/petugas_detail_screen.dart';
import 'package:pupr_perizinan/providers/petugas_provider.dart';
import 'package:pupr_perizinan/models/permohonan_model.dart';

class MockPetugasProvider extends PetugasProvider {
  MockPetugasProvider() : super(); 

  @override
  bool get isLoading => true; // FORCE LOADING STATE

  @override
  String? get error => null;

  @override
  PermohonanModel? get selectedPermohonan => null; // FORCE NULL
}

void main() {
  testWidgets('PetugasDetailScreen renders loading state', (WidgetTester tester) async {
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
    
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
