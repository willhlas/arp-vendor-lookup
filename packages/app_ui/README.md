# app_ui

Flutter package holding this project's shared design system — theme and
widgets only. Depends solely on the `flutter` SDK: no networking, no ARP
logic, no dependency on any data-layer package (`arp_resolver`,
`vendor_api_client`, `vendor_lookup_repository`). If a widget needs data,
`app` wires the two together at the call site — this package stays
presentation-only. See the repo-root `CLAUDE.md` for the full project
context and conventions.

## Setup

- `flutter pub get`
- `flutter test`

## What it contains

### Theme (`lib/src/theme/`)

- `AppTheme` — the app's `ThemeData`.
- `AppColors`, `AppSpacing`, `AppRadius`, `AppBorderWidth`, `AppIconSize` —
  design tokens.
- `AppTextStyles` — typography, built on three bundled font families:
  IBM Plex Mono, Inter, and Space Grotesk.
- `VendorSwatch` — a color mapping used to give recent/known vendors a
  consistent, distinguishable color in the UI.

### Widgets (`lib/src/widgets/`)

- `AppBadge`
- `AppCard`
- `AppLabelValueRow`
- `AppLogo`

All are plain `StatelessWidget`s taking data via constructor params —
no cubit/bloc/state code lives in this package, per `CLAUDE.md`'s
presentational-package convention.

Everything is exported through the `app_ui.dart` barrel file; consumers
should never reach into `lib/src/` directly.
