import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/app/esquilo_invest_app.dart';

void main() {
  testWidgets('shows configuration state when backend is missing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EsquiloInvestApp());
    await tester.pumpAndSettle();

    expect(find.text('Configurar backend'), findsOneWidget);
    expect(
      find.textContaining('flutter run --dart-define=APP_SCRIPT_BASE_URL'),
      findsOneWidget,
    );
  });
}
