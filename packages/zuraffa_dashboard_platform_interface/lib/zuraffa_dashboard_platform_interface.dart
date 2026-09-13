/// zuraffa_dashboard_platform_interface — the native contract for the
/// zuraffa_dashboard federated plugin family.
///
/// Exposes [ZuraffaDashboardPlatform], the contract platform packages
/// (android/ios/macos) implement over the `zuraffa_dashboard`
/// MethodChannel, plus [DefaultZuraffaDashboardPlatform], the safe
/// fallback used before any platform package registers, and
/// [MethodChannelDashboardAdapter], which bridges the native stack onto
/// the core package's pure-Dart `DashboardPort`.
library;

export 'src/dashboard_platform_interface.dart';
export 'src/method_channel_zuraffa_dashboard.dart';
export 'src/method_channel_dashboard_adapter.dart';
