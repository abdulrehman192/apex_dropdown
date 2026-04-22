import 'package:apex_dropdown/apex_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('route pop closes overlay without crash', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: SizedBox(
                  width: 300,
                  child: ApexDropdown<String>(
                    items: const ['A', 'B'],
                    itemLabel: (s) => s,
                    value: null,
                    onChanged: (v) {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.byType(ApexDropdown<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });

  testWidgets('handles items update with stale value (no crash)', (tester) async {
    var items = <String>['A', 'B', 'C'];
    var value = 'B';

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: Column(
                children: [
                  SizedBox(
                    width: 300,
                    child: ApexDropdown<String>(
                      items: items,
                      value: value,
                      itemLabel: (s) => s,
                      onChanged: (_) {},
                      hintText: 'Pick',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        items = <String>['X', 'Y', 'Z'];
                      });
                    },
                    child: const Text('Update Items'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('B'), findsOneWidget);

    await tester.tap(find.text('Update Items'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}

