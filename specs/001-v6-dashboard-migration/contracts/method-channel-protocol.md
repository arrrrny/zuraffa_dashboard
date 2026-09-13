# Contract: Native MethodChannel protocol

Channel: `zuraffa_dashboard` (single channel, like the siblings).

The native contract every `zuraffa_dashboard` platform package implements.
Wire values are stable plain strings; typed enums live only in the core
package. Layout payloads are JSON maps of the persisted dashboard:
`{dashboardId: [tile, …]}` with tiles serialized via their generated
`toJson` (fields: `id`, `type`, `title`, `placement{row,column,rowSpan,
colSpan}`, `enabled`, `config`).

| Method         | Arguments                       | Result                                   |
|----------------|---------------------------------|------------------------------------------|
| `loadLayouts`  | none                            | `Map<String, Object?>` dashboardId → tile-list (may be empty; missing key = never saved) |
| `saveLayout`   | `[String dashboardId, List<Map> tiles]` | `void` (error on persistence failure) |
| `removeLayout` | `[String dashboardId]`          | `void` (no-op when absent)               |
| `removeAll`    | none                            | `void`                                   |

## Rules

- Native implementations MUST resolve each call exactly once (success or
  `PlatformException`).
- `saveLayout` overwrites the stored layout for that id atomically.
- Stored shapes are opaque to the native side: persist the JSON map as
  received (SharedPreferences: one string entry per dashboard id under the
  `zuraffa_dashboard.` prefix; NSUserDefaults: same key prefix).
- Unknown/extra fields forward untouched (forward compatibility).
- The default `ZuraffaDashboardPlatform` instance returns empty maps and
  no-ops so pure-Dart hosts and tests never crash before a platform
  package registers (mirrors the sibling default).

## Implementers

- `zuraffa_dashboard_platform_interface`: `ZuraffaDashboardPlatform`
  (contract + default), `MethodChannelZuraffaDashboard` (channel driver),
  `MethodChannelDashboardAdapter` (bridges onto the core `DashboardPort`).
- `zuraffa_dashboard_android`: `ZuraffaDashboardPlugin` (Kotlin,
  `com.zuraffa.dashboard`) + `ZuraffaDashboardAndroid.registerWith()`.
- `zuraffa_dashboard_ios`: `ZuraffaDashboardPlugin` (Swift,
  `sZuraffaDashboardPlugin` pod) + `ZuraffaDashboardIOS.registerWith()`.
- `zuraffa_dashboard_macos`: `ZuraffaDashboardPlugin` (Swift,
  `sZuraffaDashboardPlugin` pod) + `ZuraffaDashboardMacos.registerWith()`.

Each federated `registerWith()` sets
`ZuraffaDashboardPlatform.instance = MethodChannelZuraffaDashboard()` and
calls `setPlatformDashboardPortFactory(() => MethodChannelDashboardAdapter())`.
