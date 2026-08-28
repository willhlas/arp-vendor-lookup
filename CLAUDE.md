# CLAUDE.md

## Project overview

A desktop tool that resolves an IP address to a MAC address and a vendor
name.

- **Flutter desktop app** — takes an IP address as input, reads the local
  ARP table to resolve it to a MAC address, then calls our Rails API to
  resolve that MAC to a vendor name. Displays IP, MAC, and vendor, with a
  "recent lookups" list.
- **Rails API** — a small JSON API. `GET /lookups?mac=...` proxies a
  public MAC-vendor lookup service, caches the result, and returns it.
  `GET /lookups` returns recent lookups for the app's history view. No
  authentication.

The interesting complexity in this project is at the edges, not in the
middle: parsing OS-specific ARP output, and handling a flaky/rate-limited
third-party API gracefully. Most bugs will live in those two places —
treat them accordingly (see Testing below).

## Repository structure

```
/app                       # Flutter desktop client
/api                       # Rails JSON API
/packages
  /arp_resolver            # Pure Dart: reads/parses the local ARP table (per-OS)
  /vendor_api_client       # Pure Dart: HTTP client for our Rails API
  /vendor_lookup_repository # Pure Dart: caching/repository layer on top of vendor_api_client
  /app_ui                  # Flutter: shared widgets / design system
```

`arp_resolver`, `vendor_api_client`, and `vendor_lookup_repository` are
each **pure Dart packages** (no `flutter` SDK dependency) — everything in
them (`dart:io` process calls, HTTP client, plain models) works without
Flutter. This is a deliberate boundary, not just a convention: because
none of them depend on `flutter`, it's physically impossible to import a
widget or `material.dart` into them. The separation between data layer
and UI is enforced by the dependency graph, not by code review vigilance.

`app_ui` is a Flutter package, since it contains widgets and depends on
the Flutter framework.

Mapping these onto the general package-architecture shape (repository
packages / design-system package / pure-logic packages / state-management
package):

- `vendor_api_client` + `vendor_lookup_repository` are the layered
  data-layer packages — the client at the bottom, the caching/repository
  layer on top, wrapping failures in typed exceptions.
- `arp_resolver` is also a data-layer package, not a pure-logic one — it
  does I/O via `dart:io` process calls (shelling out to read the ARP
  table), so don't mistake it for an algorithm/solver package.
- `app_ui` is the design-system/presentational package.
- No pure-logic package exists, and none is needed yet — this app has no
  algorithmic component. Don't add one speculatively (YAGNI).
- There's no state-management package yet either. When one is added, it
  follows the same one-package-per-concern approach: it lives under
  `packages/`, depends on the repository packages, and is never depended
  on by them — dependencies point one direction only.

`app` depends on all four `packages/*` as local (path) dependencies.
Nothing in `packages/` should ever depend on `app`.

Dart workspace tooling (native `pubspec.yaml` workspace resolution, or
Melos if cross-package scripting is needed) links `app` and `packages/*`
together — mixed Dart/Flutter packages in one workspace is supported by
both. `api` is a standalone Rails app within the same repo — it doesn't
participate in the Dart workspace. `arp_resolver`, `vendor_api_client`,
and `vendor_lookup_repository` tests run via `dart test`; `app` and
`app_ui` tests run via `flutter test`.

## Engineering principles (apply to both codebases)

These are the standards that matter more than any framework-specific
convention:

- **Separation of concerns.** Each layer has one job. In the Flutter app:
  UI widgets don't know how to parse ARP output or make HTTP calls —
  that lives in dedicated service/repository classes. In Rails:
  controllers don't know how to talk to the vendor API — that lives in a
  service object, not inline in the controller or the model.
- **Naming should describe intent, not mechanism.** `ArpTableReader` over
  `Helper`, `VendorLookupService` over `ApiClient`. If a name needs a
  comment to explain what it does, rename it instead.
- **No silent failures.** Every external boundary (shelling out to `arp`,
  calling the vendor API, calling our own Rails API) can fail in more than
  one way, and those ways are meaningfully different to the user (parse
  failure vs. not-found vs. network failure vs. rate-limited). Don't
  collapse them into one generic error.
- **YAGNI.** This is a POC. Don't add abstraction layers, config systems,
  or extensibility hooks for requirements that don't exist yet.

## Flutter / Dart conventions

Standard `effective_dart` style applies — no need to restate it here.
Project-specific notes:

- ARP-table reading and parsing is platform-specific (macOS/Linux vs.
  Windows output formats differ). Keep one interface
  (e.g. `ArpResolver`) with per-platform implementations behind it, so
  the parsing logic is swappable and independently testable — don't
  branch on `Platform.isX` inside UI or networking code. This belongs in
  `packages/arp_resolver`, not in `app`.
- The Rails API client (`packages/vendor_api_client`) and the caching
  repository built on top of it (`packages/vendor_lookup_repository`)
  are a separate concern from the ARP resolver. All three should be
  mockable from `app`'s widget tests so UI states (loading, not-found,
  network error) can be tested without a real ARP table or real network
  call.
- `packages/app_ui` holds shared widgets/theme only — no networking, no
  ARP logic, no dependency on the data-layer packages. If a widget needs
  data, `app` wires the two together; the UI package itself stays
  presentation-only.
- Loading/empty/error states are first-class UI states, not
  afterthoughts — this app will show "unknown vendor" and "no ARP entry"
  regularly, not just on rare error paths.

### State management

Bloc is the default for this project — this overrides the global
CLAUDE.md's Cubit-first default, specifically for this repo. Reach for
Cubit only for a feature with no event-driven or multi-source-stream
needs, and name the exception where it's made (e.g. in that feature's own
notes or PR description).

- **Status/derived values.** Status is an enum, never multiple bools.
  Derived/computed values are getters on the **state** class, never on
  the bloc.
- **State files.** State lives in a sibling `*_state.dart` file via
  `part`/`part of`. State extends `Equatable`. `copyWith` takes nullable
  `Type? param` args with a `param ?? this.param` fallback.
- **Bloc isolation.** Blocs never read each other directly. Share data
  via repository streams, and pass ids/params through the constructor
  instead of reaching into another bloc.
- **Stream composition.** A root/app-level bloc that needs data from
  multiple repository streams merges them manually (subscribe, then
  `add` events) rather than relying on a single upstream stream.
  Page-level blocs that map one upstream stream 1:1 use `emit.forEach`.
- **Side effects.** Navigation and dialogs live in dedicated
  `BlocListener` classes, never inline in a `builder`.
- **Bloc-layer error handling.** Catch `on Exception catch (e)`, call
  `addError`, and emit an error status. Guard async event handlers with
  `if (isClosed) return;` before emitting after an `await`. This is a
  different layer from the repository-layer error handling described
  under Engineering principles below — repositories catch plain and
  rethrow typed exceptions; blocs catch the typed exception and turn it
  into UI state.
- **Widget structure: Page → View → Content.** `StatelessWidget` +
  composition — small private `_Name extends StatelessWidget` classes in
  the same file, not extracted build methods. Prefer
  `context.select`/`BlocSelector` over `BlocBuilder`. Structure each
  feature in three layers: the Page wires providers (`BlocProvider`,
  `RepositoryProvider`), the View switches on `state.status`, and Content
  widgets compose the actual sections for a given status. All
  user-facing strings go through the app's l10n mechanism.
- **Barrel files.** Every grouped directory exports via a same-named
  barrel file (e.g. `packages/arp_resolver/lib/arp_resolver.dart`).
  Consumers never reach past the barrel into individual `src/` files.

### Repositories & composition root

- Each data-layer package defines a sealed `XException implements
  Exception` with `final class YFailure extends XException` variants per
  failure mode. Catch real failures with plain `catch (e)` and rethrow
  wrapped in the typed failure class.
- JSON-boundary models (anything crossing the Rails API or ARP-table
  boundary) are `Equatable` + `json_serializable`. Purely in-memory
  models are `Equatable` only.
- Construct all repositories once at `app`'s entry point and provide them
  down via `RepositoryProvider` — no per-feature self-wiring. Resolve any
  required initial async state before the first frame rather than
  showing a UI that immediately re-renders once it loads.

## Rails / Ruby conventions

You're new to Rails, so the goal here is: lean into Rails' own
conventions where they don't conflict with the principles above, rather
than importing patterns from other frameworks. Rails is opinionated by
design — fighting it (non-standard naming, skipping ActiveRecord
conventions, etc.) usually costs more than it's worth for a project this
size.

- **Thin controllers.** A controller's job is: parse/validate params,
  call one thing, render a response. If a controller method has
  conditional logic beyond "did the service succeed or fail," that logic
  belongs elsewhere.
- **External calls live in a service object.** The call to the vendor
  lookup API belongs in something like `app/services/vendor_lookup_service.rb`
  — not in the controller, not in the model. This is the Rails version of
  "don't let your UI layer make network calls" — it's the same principle
  you already apply in Flutter, just in a different layer.
- **Models represent data, not orchestration.** The `Lookup` model
  validates and persists a lookup record. It doesn't know how to call an
  external API.
- **Follow Rails naming conventions rather than override them** —
  snake_case files and methods, singular model class names (`Lookup`)
  with pluralized table names (`lookups`), RESTful controller actions.
  This isn't bureaucracy — it's what makes the codebase readable to
  anyone else who knows Rails, and what most Rails tooling assumes.
- **Config and secrets** (the vendor API key/URL, if the chosen provider
  needs one) go through Rails credentials or environment variables —
  never hardcoded in a service class.
- **Generated infrastructure not in scope has been removed.** `rails new
  api --api` scaffolds Solid Queue, Solid Cache, Solid Cable, and Active
  Storage by default (Rails 8 new-app defaults, unrelated to `--api`).
  This app has no background jobs, no caching layer, no websockets, and
  no file uploads, so those were deliberately stripped rather than left
  in unused — don't re-add any of them without a concrete feature that
  needs it (YAGNI). Kamal deployment files may or may not be present
  depending on whether a deploy target was decided at scaffold time.

## Testing

Test pyramid, weighted toward the parts of this app most likely to
break:

- **Highest priority — parsing and external boundaries.** ARP output
  parsing (per platform) and the vendor API service both need thorough
  unit tests against real captured sample output/responses, including
  malformed/unexpected input. These are the two places a silent bug is
  most likely and least visible.
- **Rails:** this app uses Rails' default Minitest setup (no `rspec-rails`
  gem) — integration tests under `api/test/integration` for both
  endpoints, covering the full status code matrix (200, 404, 422,
  502/503-equivalent for upstream failure). Stub outbound HTTP calls in
  tests (e.g. WebMock) — the test suite should never depend on the real
  vendor API being up.
- **Flutter:** unit tests for each `ArpResolver` implementation against
  fixed sample output; widget tests for each UI state (loading, success,
  unknown vendor, ARP miss, network error) using a mocked API client.
  Bloc/cubit behavior is tested with `bloc_test`'s
  `blocTest<XBloc, XState>(...)`. Widget tests use a shared `pumpApp`
  `WidgetTester` extension (in `app/test/helpers/`) plus
  `Mock*Bloc extends MockBloc<Event, State>` (or `MockCubit<State>` for
  the named Cubit exceptions) wired into the app's provider tree +
  `MaterialApp`. Use `mocktail` with a private
  `class _MockX extends Mock implements X {}` per test file, not a
  shared mock library.
- A change to parsing logic or the vendor-API service without an
  accompanying test is the one thing worth pushing back on in review.

## API conventions (Rails)

- Consistent JSON error shape across all failure responses, e.g.
  `{ "error": "message" }`.
- Status codes: `422` for a malformed/missing `mac` param, `404` when the
  MAC is well-formed but no vendor is found, `502`/`503` when the
  upstream vendor API itself is unreachable or erroring — these are
  different failure modes and should stay distinguishable in the
  response.
- Normalize MAC address formatting (case, separators) before querying or
  storing, so equivalent inputs hit the same cached record.

## Working notes for Claude

- Run the relevant test suite before considering a change done —
  `flutter test` (and `dart test` for the pure-Dart packages) for the
  app, `bin/rails test` for the API, or `bin/ci` for the full Rails check
  (rubocop, bundler-audit, brakeman, tests).
- Prefer small, reviewable commits over one large change.
- Ask before adding a new dependency (gem or pub package) rather than
  reaching for one by default — this includes `flutter_bloc`/`bloc`,
  `bloc_test`, `equatable`, and `json_serializable`/`build_runner` when
  state management and models are first implemented.