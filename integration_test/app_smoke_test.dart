import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mitologi_clothing_mobile/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app router smoke test boots', (tester) async {
    expect(AppRouter.router, isNotNull);
  });
}
