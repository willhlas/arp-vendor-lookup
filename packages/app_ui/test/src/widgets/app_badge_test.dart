import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppBadge, () {
    testWidgets('renders its label in uppercase', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppBadge(label: 'resolved', variant: AppBadgeVariant.success),
        ),
      );

      expect(find.text('RESOLVED'), findsOneWidget);
    });
  });
}
