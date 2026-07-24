import 'package:bs_flutter/app/widgets/quantity_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('centers the quantity between decrement and increment controls', (tester) async {
    var quantity = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: QuantityStepper(
                value: quantity,
                onDecrement: quantity > 1 ? () => setState(() => quantity--) : null,
                onIncrement: () => setState(() => quantity++),
              ),
            );
          },
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
    expect(find.byTooltip('Decrease quantity'), findsOneWidget);
    expect(find.byTooltip('Increase quantity'), findsOneWidget);

    await tester.tap(find.byTooltip('Decrease quantity'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byTooltip('Increase quantity'));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byTooltip('Decrease quantity'));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });
}
