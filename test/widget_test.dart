// Placeholder scaffold smoke test, kept compiling against the current
// entry point. This is the default `flutter create` template test with
// its counter-app assertions removed (that widget no longer exists); a
// real test suite for this feature is out of scope for this prompt and
// covered later.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:onefi/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: OneFiApp()));
    await tester.pump(const Duration(seconds: 1));
  });
}
