import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kisan_ai/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KisanAIApp()));
    await tester.pump();
    // Basic smoke test — app renders without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
