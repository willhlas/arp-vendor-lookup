import 'package:arp_vendor_lookup/l10n/l10n.dart';
import 'package:arp_vendor_lookup/vendor/vendor.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockVendorBloc extends MockBloc<VendorEvent, VendorState>
    implements VendorBloc {
  @override
  VendorState get state => const VendorState();
}

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    VendorBloc? vendorBloc,
  }) {
    return pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BlocProvider<VendorBloc>.value(
            value: vendorBloc ?? _MockVendorBloc(),
            child: widget,
          ),
        ),
      ),
    );
  }
}
