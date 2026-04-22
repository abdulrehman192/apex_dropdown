import 'package:apex_dropdown/apex_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('opens overlay and toggles selection', (tester) async {
    var values = <String>['Apple'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: SizedBox(
                  width: 320,
                  child: ApexMultiDropdown<String>(
                    items: const ['Apple', 'Banana', 'Cherry'],
                    values: values,
                    itemLabel: (s) => s,
                    chipDisplay: ApexDropdownChipDisplay.count,
                    onChanged: (v) => setState(() => values = v),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('1 selected'), findsOneWidget);

    await tester.tap(find.byType(ApexMultiDropdown<String>));
    await tester.pumpAndSettle();

    expect(find.text('Banana'), findsOneWidget);

    await tester.tap(find.text('Banana'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('2 selected'), findsOneWidget);

    await tester.tap(find.text('Banana'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('1 selected'), findsOneWidget);
  });

  testWidgets('maxSelection invokes onSelectionLimitReached', (tester) async {
    var values = <String>['Apple', 'Banana'];
    var limitHits = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: SizedBox(
                  width: 320,
                  child: ApexMultiDropdown<String>(
                    items: const ['Apple', 'Banana', 'Cherry'],
                    values: values,
                    itemLabel: (s) => s,
                    maxSelection: 2,
                    onSelectionLimitReached: () => limitHits++,
                    onChanged: (v) => setState(() => values = v),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ApexMultiDropdown<String>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cherry'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(limitHits, equals(1));
    expect(values.length, equals(2));
  });

  testWidgets('form field validates selection', (tester) async {
    var values = <String>[];
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: StatefulBuilder(
              builder: (context, setState) {
                return ApexMultiDropdownFormField<String>(
                  items: const ['A', 'B'],
                  values: values,
                  itemLabel: (s) => s,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Pick at least one' : null,
                  onChanged: (v) => setState(() => values = v),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Pick at least one'), findsOneWidget);

    await tester.tap(find.byType(ApexMultiDropdown<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    expect(formKey.currentState!.validate(), isTrue);
    await tester.pump();
    expect(find.text('Pick at least one'), findsNothing);
  });
}
