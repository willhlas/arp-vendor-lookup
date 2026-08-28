import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

extension L10nHelper on WidgetTester {
  AppLocalizations get l10n {
    final app = widget<MaterialApp>(find.byType(MaterialApp));

    final locale = app.locale ?? app.supportedLocales.first;

    return lookupAppLocalizations(locale);
  }
}
