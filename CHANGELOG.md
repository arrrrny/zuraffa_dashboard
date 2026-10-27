## [7.2.0] - 2026-10-28

- Mono-version fleet alignment: the whole zuraffa family now ships at the same version as the core.
- `zuraffa` dependency constraint unified to ^7.2.0 across the fleet.
- zuraffa_storage now wraps the maintained `zuraffa_minio` fork instead of the abandoned `minio` package (xml 7 compatible).
- Fleet-wide `dependency_overrides: xml: 7.1.0` policy; README install guides refreshed to the release version.

# Changelog

All notable changes to the `zuraffa_dashboard` federated package family are
documented in this file. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
