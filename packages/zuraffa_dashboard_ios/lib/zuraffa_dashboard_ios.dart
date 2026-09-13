import 'package:zuraffa_dashboard/zuraffa_dashboard.dart';
import 'package:zuraffa_dashboard_platform_interface/zuraffa_dashboard_platform_interface.dart';

/// The iOS entrypoint: registers the MethodChannel implementation with
/// the shared platform interface so `MethodChannelDashboardAdapter` routes
/// to the Swift plugin, and wires the real [DashboardPort] so any app
/// depending on this package gets on-device layout persistence by default.
class ZuraffaDashboardIOS {
  static void registerWith() {
    ZuraffaDashboardPlatform.instance = MethodChannelZuraffaDashboard();
    setPlatformDashboardPortFactory(() => MethodChannelDashboardAdapter());
  }
}
