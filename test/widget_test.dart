import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_ordenes/main.dart';

void main() {
  testWidgets('App loads and shows main screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AppOrdenes());

    // Verify that the app starts with the correct title
    expect(find.text('Órdenes de Trabajo'), findsOneWidget);
    expect(find.text('Filtros de Búsqueda'), findsOneWidget);
    
    // Verify that the main filter fields are present
    expect(find.text('Pedido Cliente'), findsOneWidget);
    expect(find.text('Centro/Planta'), findsOneWidget);
    expect(find.text('Puesto de Trabajo'), findsOneWidget);
  });

  testWidgets('Filter form shows search button', (WidgetTester tester) async {
    await tester.pumpWidget(const AppOrdenes());

    // Find the search button
    expect(find.text('Buscar'), findsOneWidget);
    expect(find.text('Limpiar'), findsOneWidget);
  });

  testWidgets('Tapping search button triggers order loading', (WidgetTester tester) async {
    await tester.pumpWidget(const AppOrdenes());

    // Tap the search button
    await tester.tap(find.text('Buscar'));
    await tester.pump();

    // Verify loading indicator appears
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}