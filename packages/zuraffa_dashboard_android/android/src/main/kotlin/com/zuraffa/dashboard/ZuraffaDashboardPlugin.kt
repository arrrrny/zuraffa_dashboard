package com.zuraffa.dashboard

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import org.json.JSONTokener
import org.json.JSONArray
import org.json.JSONObject

/**
 * The Android native plugin for zuraffa_dashboard: persists dashboard
 * layouts to SharedPreferences, one string entry per dashboard id under
 * the `zuraffa_dashboard.` prefix (see contracts/method-channel-protocol.md).
 * Stored shapes are opaque to this side — the JSON payload is persisted as
 * received, unknown fields forward untouched.
 */
class ZuraffaDashboardPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var preferences: android.content.SharedPreferences

    companion object {
        private const val CHANNEL_NAME = "zuraffa_dashboard"
        private const val PREFIX = "zuraffa_dashboard."
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        preferences = binding.applicationContext
            .getSharedPreferences("zuraffa_dashboard", Context.MODE_PRIVATE)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "loadLayouts" -> {
                val layouts = HashMap<String, Any?>()
                for (entry in preferences.all) {
                    if (!entry.key.startsWith(PREFIX)) continue
                    val payload = entry.value as? String ?: continue
                    runCatching {
                        layouts[entry.key.removePrefix(PREFIX)] =
                            toCodecValue(JSONTokener(payload).nextValue())
                    }
                }
                result.success(layouts)
            }
            "saveLayout" -> {
                val args = call.arguments as? List<*>
                val id = args?.getOrNull(0) as? String
                val tiles = args?.getOrNull(1)
                if (id == null || tiles == null) {
                    result.error(
                        "invalid_arguments",
                        "saveLayout expects [String id, Any tiles]", null)
                    return
                }
                val array = JSONArray()
                if (tiles is List<*>) {
                    for (item in tiles) array.put(item)
                } else {
                    array.put(tiles)
                }
                preferences.edit()
                    .putString(PREFIX + id, array.toString())
                    .apply()
                result.success(null)
            }
            "removeLayout" -> {
                val args = call.arguments as? List<*>
                val id = args?.getOrNull(0) as? String
                if (id == null) {
                    result.error(
                        "invalid_arguments",
                        "removeLayout expects [String id]", null)
                    return
                }
                preferences.edit().remove(PREFIX + id).apply()
                result.success(null)
            }
            "removeAll" -> {
                val editor = preferences.edit()
                for (key in preferences.all.keys) {
                    if (key.startsWith(PREFIX)) editor.remove(key)
                }
                editor.apply()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /**
     * Flutter's StandardMessageCodec cannot encode org.json types, so a
     * parsed payload is rebuilt with List/Map/null — the shapes the codec
     * understands — before it enters a result map.
     */
    private fun toCodecValue(value: Any?): Any? = when (value) {
        null, JSONObject.NULL -> null
        is JSONArray -> (0 until value.length()).map { toCodecValue(value.opt(it)) }
        is JSONObject -> value.keys().asSequence()
            .associateWith { toCodecValue(value.opt(it)) }
        else -> value
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
