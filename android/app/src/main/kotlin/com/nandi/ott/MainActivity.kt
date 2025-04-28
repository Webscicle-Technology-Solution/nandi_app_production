package com.nandi.ott

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {

    // Override onCreate to add the secure flag when the activity is created
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Add this flag to prevent screenshots and screen recordings
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    // Configure FlutterEngine with method channel
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Define the method channel and add functionality
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.yourdomain.app/screen_security")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableSecureFlag" -> {
                        // Add the FLAG_SECURE to the window, preventing screenshots and screen recordings
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
}
