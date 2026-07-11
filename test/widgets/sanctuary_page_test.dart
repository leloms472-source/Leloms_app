import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leloms_app/features/sanctuary/sanctuary_page.dart';
import 'package:leloms_app/providers/sanctuary_provider.dart';
import 'package:leloms_app/providers/user_provider.dart';

Widget createTestApp() {
  return MaterialApp(
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SanctuaryProvider()),
      ],
      child: const SanctuaryPage(),
    ),
  );
}

void main() {
  testWidgets('SanctuaryPage shows tree and cat', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Semilla'), findsOneWidget);
    expect(find.text('Santuario'), findsOneWidget);
    expect(find.byIcon(Icons.pets_rounded), findsWidgets);
  });

  testWidgets('SanctuaryPage XP bar updates correctly', (tester) async {
    await tester.pumpWidget(createTestApp());
    await tester.pumpAndSettle();

    expect(find.text('0 XP'), findsOneWidget);
  });
}
