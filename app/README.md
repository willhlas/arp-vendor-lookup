# app

The Flutter desktop client. Takes an IP address (typed in, or the local
machine's own IP via "use my IP"), resolves it to a MAC address by
reading the local ARP table, then resolves that MAC to a vendor name via
the Rails API in `../api`. Shows a recent-lookups history alongside the
current result. See the repo-root `CLAUDE.md` for the full project
context and conventions.

## Setup

- `flutter pub get`
- `flutter run -d macos` (or `-d linux` / `-d windows`)
- `flutter test`

`lib/main.dart` is the composition root: it constructs `createArpResolver()`,
`SystemLocalNetworkInfo()`, a `VendorApiClient`, and the
`VendorLookupRepository` built from the two, then passes them into `App`.
All four `packages/*` are consumed as local `path:` dependencies.

## Architecture

### State management — `lib/vendor/bloc/`

A single `VendorBloc` (`Bloc<VendorEvent, VendorState>`) drives the whole
feature, handling three events: `VendorLookupRequested`,
`VendorRecentLookupsRequested`, and `VendorLocalIpDetectionRequested`.
`VendorState` tracks three independent enum statuses
(`VendorLookupStatus`, `RecentLookupsStatus`, `LocalIpDetectionStatus`) —
each `initial/loading/success/error` — plus derived getters (`isArpMiss`,
`isVendorFound`) rather than boolean flags, per `CLAUDE.md`'s Bloc
conventions. Lookup failures are further classified into a
`VendorLookupErrorKind` enum (e.g. `arpCommandFailed`,
`upstreamUnavailable`, `rateLimited`) so the UI can show a distinct
message per failure mode instead of one generic error.

### Widget structure — `lib/vendor/`

- `view/lookup_page.dart` — the Page, wiring `BlocProvider`.
- `widgets/lookup_section.dart` — the app's one accepted `StatefulWidget`
  (owns a `TextEditingController`); composes the form and result sections.
- `widgets/lookup_result_section.dart` plus the per-status
  `lookup_*_card.dart` widgets (`loading`, `resolved`, `unknown_vendor`,
  `arp_miss`, `error`, `empty`) — Content widgets selected by
  `state.lookupStatus`.
- `widgets/recent_lookups_panel.dart` / `recent_lookup_row.dart` — the
  history list.

### Utilities — `lib/vendor/utils/`

`ip_validator.dart`, `lookup_error_message.dart` (maps
`VendorLookupErrorKind` to user-facing copy), `relative_time.dart` (for
the history list's timestamps).

## Testing

`flutter test` covers bloc behavior (`test/vendor/bloc/vendor_bloc_test.dart`,
using `bloc_test`'s `blocTest<VendorBloc, VendorState>`), one widget test
per UI state under `test/vendor/widgets/`, and the page/app shell
(`test/vendor/view/lookup_page_test.dart`, `test/app/view/app_test.dart`).
`test/helpers/pump_app.dart` provides a shared `pumpApp` `WidgetTester`
extension that wires a `MockVendorBloc` (`extends MockBloc<VendorEvent,
VendorState>`, via `mocktail`) into the provider tree + `MaterialApp`, so
widget tests never touch a real ARP table or network call.
