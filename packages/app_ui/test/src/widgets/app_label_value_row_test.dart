import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppLabelValueRow, () {
    testWidgets(
      'renders the label in uppercase and the value widget',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: AppLabelValueRow(
              label: 'ip address',
              value: Text('192.168.1.1'),
            ),
          ),
        );

        expect(find.text('IP ADDRESS'), findsOneWidget);
        expect(find.text('192.168.1.1'), findsOneWidget);
      },
    );

    testWidgets(
      'does not render the divider when showDivider is false',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: AppLabelValueRow(
              label: 'a',
              value: Text('b'),
              showDivider: false,
            ),
          ),
        );

        expect(find.byType(Divider), findsNothing);
      },
    );
  });
}
