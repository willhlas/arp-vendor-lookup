import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group(AppTheme, () {
    test('can be instantiated', () {
      expect(const AppTheme(), isNotNull);
    });

    group('themeData', () {
      test('is material 3', () {
        expect(const AppTheme().themeData.useMaterial3, isTrue);
      });

      test('has a non-null textTheme', () {
        expect(const AppTheme().themeData.textTheme, isNotNull);
      });
    });
  });

  group('BuildContextX', () {
    testWidgets('theme returns ThemeData', (tester) async {
      late final BuildContext context;
      late final ThemeData themeData;
      await tester.pumpWidget(
        Theme(
          data: ThemeData(),
          child: Builder(
            builder: (c) {
              context = c;
              themeData = Theme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(context.theme, equals(themeData));
    });

    testWidgets('textTheme returns TextTheme', (tester) async {
      late final BuildContext context;
      await tester.pumpWidget(
        Theme(
          data: const AppTheme().themeData,
          child: Builder(
            builder: (c) {
              context = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(context.textTheme, isA<TextTheme>());
    });
  });

  group('TextThemeX', () {
    test('mono returns a TextStyle', () {
      expect(const AppTheme().themeData.textTheme.mono, isA<TextStyle>());
    });
  });
}
