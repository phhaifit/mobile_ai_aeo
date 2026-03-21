import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App sanity check - MaterialApp renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Jarvis AEO'))),
    );
    expect(find.text('Jarvis AEO'), findsOneWidget);
  });
}
