import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:favorite_places_app/widgets/places_list.dart';

void main() {
  testWidgets('Shows message when no places exist', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: PlacesList(places: [])),
      ),
    );

    expect(find.text('No places added yet.'), findsOneWidget);
  });
}
