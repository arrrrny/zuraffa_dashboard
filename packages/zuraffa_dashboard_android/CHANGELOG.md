## 7.3.2 - 2026-10-31

Mono-version fleet alignment to 7.3.2: outbound send port lands in zuraffa_intents (shareText/shareFiles behind ShareIntentService); the whole family ships at one version.

## 6.2.2

- Initial release of the zuraffa_dashboard federated package family:
  `zuraffa_dashboard` (pure-Dart core), `zuraffa_dashboard_platform_interface`,
  `zuraffa_dashboard_android`, `zuraffa_dashboard_ios`,
  `zuraffa_dashboard_macos`.
- Complete rewrite on the Zuraffa v6 framework (EPIC arrrrny/zuraffa#214,
  issue arrrrny/zuraffa#673): Zuraffa entities, datasource/repository layer,
  nine use cases, `DashboardService` facade, GetIt registration.
- Federated platform implementations persisting dashboard layouts to
  SharedPreferences (Android) and NSUserDefaults (iOS/macOS) behind a
  documented MethodChannel protocol.

# 1.0.0

- Initial release.
