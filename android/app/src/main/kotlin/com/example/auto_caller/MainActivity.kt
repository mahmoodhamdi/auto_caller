package com.example.auto_caller

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri

class MainActivity: FlutterActivity() {
    private val CHANNEL = "automated_call_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "makeAutomatedCall") {
                val phoneNumber = call.argument<String>("phoneNumber")
                if (phoneNumber != null) {
                    makeCall(phoneNumber)
                    result.success(null)
                } else {
                    result.error("PARAMETER_ERROR", "Phone number parameter missing", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun makeCall(phoneNumber: String) {
        val intent = Intent(Intent.ACTION_CALL)
        intent.data = Uri.parse("tel:$phoneNumber")
        startActivity(intent)
    }
}
