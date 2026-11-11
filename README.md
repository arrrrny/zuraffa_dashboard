<!-- ZURAFFA-LAUNCH-PROMO (valid until Dec 1, 2026) -->
## 🦒 [Zuraffa Browser](https://zuraffa.com) — now live

<div align="center">
  <a href="https://zuraffa.com"><img src="https://zuraffa.com/img/zuraffa-browser-home.jpg" alt="Zuraffa Browser — 10 Browsers. One window." width="800"></a>
</div>

**[Zuraffa Browser](https://zuraffa.com)** — the multi-tasking browser for AI agents & humans — is live on the [Mac App Store](https://apps.apple.com/app/id6811352058).

🎁 **Launch offer: 6 months free with code `ZURAFFA`** — no credit card, no subscription, no payment. Redeem in-app until **Dec 1, 2026**.

---

# zuraffa_dashboard

Typed, persistence-backed dashboard layouts for the [Zuraffa](https://pub.dev/packages/zuraffa)
ecosystem — clean architecture end to end: Zuraffa entities →
datasources/repositories → use cases → a `DashboardService` facade wired
through GetIt, with federated android/ios/macos implementations that persist
layouts to platform preferences.

Part of the ZikZak package family migration to Zuraffa v6
([EPIC arrrrny/zuraffa#214](https://github.com/arrrrny/zuraffa/issues/214),
migration issue arrrrny/zuraffa#673).

## Packages

| Package | Pub | Description |
| --- | --- | --- |
| [`zuraffa_dashboard`](packages/zuraffa_dashboard) | — | App-facing core (pure Dart): entities, repository, use cases, service, DI |
| [`zuraffa_dashboard_platform_interface`](packages/zuraffa_dashboard_platform_interface) | — | Native contract (MethodChannel protocol) + default-safe platform instance |
| [`zuraffa_dashboard_android`](packages/zuraffa_dashboard_android) | — | Android implementation (SharedPreferences) |
| [`zuraffa_dashboard_ios`](packages/zuraffa_dashboard_ios) | — | iOS implementation (NSUserDefaults) |
| [`zuraffa_dashboard_macos`](packages/zuraffa_dashboard_macos) | — | macOS implementation (NSUserDefaults) |

## Usage

```dart
import 'package:zuraffa_dashboard/zuraffa_dashboard.dart';

final getIt = GetIt.instance;
registerDashboardDependencies(getIt);

final dashboards = getIt<DashboardService>();
final board = await dashboards.create(
  id: 'main', title: 'Main', owner: currentUser.id,
);
await dashboards.addTile(
  board.id,
  DashboardTile(
    id: 'tile.sales',
    type: 'chart.sales',
    title: 'Sales',
    placement: TilePlacement(row: 0, column: 0, rowSpan: 1, colSpan: 2),
  ),
);
```

Depending only on the core keeps layouts in memory for the process lifetime;
adding any federated package (`zuraffa_dashboard_android` / `_ios` / `_macos`)
switches the default persistence to native platform preferences at app start —
no host code changes.

## Repo layout

```
packages/   the five federated packages (+ example app)
scripts/    publish pipeline (prepare → publish → push-to-master)
specs/      spec-kit feature specs driving the code (TDD)
PUBLISH.md  the release workflow
```

## Development

```bash
cd packages/zuraffa_dashboard
dart pub get && dart test && dart analyze
```

See [PUBLISH.md](PUBLISH.md) for the full publish workflow.
