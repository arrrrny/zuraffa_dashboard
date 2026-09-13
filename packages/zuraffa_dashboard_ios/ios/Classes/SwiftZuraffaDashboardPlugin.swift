import Flutter
import UIKit

/// The iOS native plugin for zuraffa_dashboard: persists dashboard layouts
/// to NSUserDefaults, one string entry per dashboard id under the
/// `zuraffa_dashboard.` prefix (see contracts/method-channel-protocol.md).
/// Stored shapes are opaque to this side — the JSON map is persisted as
/// received, unknown fields forward untouched.
public class ZuraffaDashboardPlugin: NSObject, FlutterPlugin {
  private static let prefix = "zuraffa_dashboard."
  private let defaults: UserDefaults

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "zuraffa_dashboard", binaryMessenger: registrar.messenger())
    let instance = ZuraffaDashboardPlugin(
      defaults: UserDefaults.standard)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  init(defaults: UserDefaults) {
    self.defaults = defaults
    super.init()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "loadLayouts":
      result(loadLayouts())
    case "saveLayout":
      saveLayout(call.arguments, result: result)
    case "removeLayout":
      removeLayout(call.arguments, result: result)
    case "removeAll":
      removeAll(result)
    default:
      result(FlutterMethodNotImplementedError)
    }
  }

  private func loadLayouts() -> [String: Any] {
    defaults.dictionaryRepresentation().reduce(into: [:]) { acc, entry in
      guard entry.key.hasPrefix(ZuraffaDashboardPlugin.prefix),
        let payload = entry.value as? String,
        let data = payload.data(using: .utf8),
        let json = try? JSONSerialization.jsonObject(with: data)
      else { return }
      acc[String(entry.key.dropFirst(ZuraffaDashboardPlugin.prefix.count))] = json
    }
  }

  private func saveLayout(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [Any], args.count == 2,
      let id = args[0] as? String
    else {
      result(FlutterError(
        code: "invalid_arguments",
        message: "saveLayout expects [String id, Any tiles]", details: nil))
      return
    }
    let tiles = args[1]
    guard JSONSerialization.isValidJSONObject([tiles]),
      let data = try? JSONSerialization.data(withJSONObject: tiles),
      let payload = String(data: data, encoding: .utf8)
    else {
      result(FlutterError(
        code: "invalid_json",
        message: "saveLayout tiles are not JSON-encodable", details: nil))
      return
    }
    defaults.set(payload, forKey: ZuraffaDashboardPlugin.prefix + id)
    result(nil)
  }

  private func removeLayout(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let args = arguments as? [Any], args.count == 1,
      let id = args[0] as? String
    else {
      result(FlutterError(
        code: "invalid_arguments",
        message: "removeLayout expects [String id]", details: nil))
      return
    }
    defaults.removeObject(forKey: ZuraffaDashboardPlugin.prefix + id)
    result(nil)
  }

  private func removeAll(_ result: @escaping FlutterResult) {
    for key in defaults.dictionaryRepresentation().keys
    where key.hasPrefix(ZuraffaDashboardPlugin.prefix) {
      defaults.removeObject(forKey: key)
    }
    result(nil)
  }
}
