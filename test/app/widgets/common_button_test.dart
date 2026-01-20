import 'package:bs_flutter/app/widgets/common_button.dart';
import 'package:bs_flutter/app/widgets/common_dotted_button.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Button Tests', () {
    testWidgets('CommonButton displays text and calls onPressed', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonButton(
              text: 'Test Button',
              onTap: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, true);
    });
  });

  testWidgets('DottedButton displays text and calls onPressed', (WidgetTester tester) async {
    bool pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DottedButton(
            text: 'Test Button',
            onTap: () {
              pressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
    expect(find.byType(DottedBorder), findsOneWidget);

    await tester.tap(find.byType(OutlinedButton));
    expect(pressed, true);
  });
}
