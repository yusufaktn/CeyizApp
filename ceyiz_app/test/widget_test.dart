// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:ceyiz_app/main.dart';
import 'package:ceyiz_app/services/bohca_service.dart';
import 'package:ceyiz_app/services/ceyiz_service.dart';
import 'package:ceyiz_app/services/local_storage_service.dart';
import 'package:ceyiz_app/services/photo_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App başlangıç testi', (WidgetTester tester) async {
    // Servisleri oluştur
    final localStorageService = LocalStorageService();
    final ceyizService = CeyizService(storage: localStorageService);
    final bohcaService = BohcaService(storage: localStorageService);
    final photoService = PhotoService();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      ceyizService: ceyizService,
      bohcaService: bohcaService,
      photoService: photoService,
    ));

    // Uygulama başlangıç kontrolü
    expect(find.text('Çeyiz Uygulaması'), findsOneWidget);
  });
}
