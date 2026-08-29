import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppBadge, () {
    for (final variant in AppBadgeVariant.values) {
      testWidgets(
        'renders label in uppercase for $variant variant',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: AppBadge(label: 'label', variant: variant),
            ),
          );

          expect(find.text('LABEL'), findsOneWidget);
        },
      );
    }
  });
}
