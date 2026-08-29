import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppCard, () {
    testWidgets('renders its child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AppCard(child: Text('content'))),
      );

      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('uses the error-tinted decoration for the error variant', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppCard(
            variant: AppCardVariant.error,
            child: Text('content'),
          ),
        ),
      );

      final widget = tester.widget<Material>(find.byType(Material));
      expect(widget.color, AppColors.errorBackground);
    });
  });
}
