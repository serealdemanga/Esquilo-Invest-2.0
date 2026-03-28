import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/app/pocket_ops_app.dart';

void main() {
  testWidgets('shows configuration state when backend is missing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PocketOpsApp());
    await tester.pumpAndSettle();

    expect(find.text('Configurar backend'), findsOneWidget);
    expect(
      find.textContaining('flutter run --dart-define=APP_SCRIPT_BASE_URL'),
      findsOneWidget,
    );
  });
}
