import 'package:apex_dropdown/apex_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens overlay on tap', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: ApexDropdown<String>(
                items: const ['Apple', 'Banana', 'Cherry'],
                itemLabel: (s) => s,
                value: null,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ApexDropdown<String>));
    await tester.pumpAndSettle();

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Banana'), findsOneWidget);
  });

  testWidgets('selects item and closes', (tester) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: ApexDropdown<String>(
                items: const ['Apple', 'Banana'],
                itemLabel: (s) => s,
                value: null,
                onChanged: (v) => selected = v,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ApexDropdown<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();

    expect(selected, equals('Banana'));
    expect(find.text('Apple'), findsNothing);
  });

  testWidgets('filters items based on search', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: ApexDropdown<String>(
                items: const ['Apple', 'Apricot', 'Banana', 'Cherry'],
                itemLabel: (s) => s,
                value: null,
                onChanged: (_) {},
                searchEnabled: true,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ApexDropdown<String>));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ap');
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Apricot'), findsOneWidget);
    expect(find.text('Banana'), findsNothing);
    expect(find.text('Cherry'), findsNothing);
  });
}

