import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_granja/app/app_theme.dart';
import 'package:memo_granja/screens/adult_zone_screen.dart';

void main() {
  testWidgets('purchase controls remain behind the adult gate', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const AdultZoneScreen(),
      ),
    );

    expect(find.text('Acceso completo'), findsNothing);
    final holdTarget = find.text('Mantén pulsado 3 segundos');
    final gesture = await tester.startGesture(tester.getCenter(holdTarget));
    await tester.pump(const Duration(seconds: 3));
    await gesture.up();
    await tester.pump();

    expect(find.text('Resuelve esta cuenta para continuar: 3 + 4'),
        findsOneWidget);
    expect(find.text('Acceso completo'), findsNothing);
  });
}
