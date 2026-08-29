import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppLogo, () {
    testWidgets('renders CustomPaint with AppLogoPainter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppLogo(),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (widget) => widget is CustomPaint && widget.painter is AppLogoPainter,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shouldRepaint returns false', (tester) async {
      const oldPainter = AppLogoPainter();
      const newPainter = AppLogoPainter();

      expect(oldPainter.shouldRepaint(newPainter), false);
    });
  });
}
