package com.shannonsonlinebookkeeping.aloft

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

// FlutterFragmentActivity is required by local_auth (fingerprint / face / PIN prompt).
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Keeps the screen out of the recent-apps view and screenshots when the setting is on.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aloft/screen_privacy")
            .setMethodCallHandler { call, result ->
                if (call.method == "setSecure") {
                    if (call.arguments == true) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }

        // Saves a backup or export straight into Documents/Aloft, with no chooser and no
        // storage permission. Returns nothing on Android 9 and older, which have no such folder
        // an app can write to without a permission; the app then offers the share sheet.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aloft/files")
            .setMethodCallHandler { call, result ->
                if (call.method == "view") {
                    // Opens a file this app saved in whatever the phone uses for that type.
                    val opened = try {
                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(Uri.parse(call.argument<String>("uri")), call.argument<String>("mime"))
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                        }
                        startActivity(intent)
                        true
                    } catch (e: Exception) {
                        // No app on the phone can show it.
                        false
                    }
                    result.success(opened)
                    return@setMethodCallHandler
                }
                if (call.method != "saveToDocuments") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val path = call.argument<String>("path")
                val name = call.argument<String>("name")
                if (path == null || name == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
                    result.success(null)
                    return@setMethodCallHandler
                }
                Thread {
                    val resolver = applicationContext.contentResolver
                    val values = ContentValues().apply {
                        put(MediaStore.MediaColumns.DISPLAY_NAME, name)
                        put(MediaStore.MediaColumns.MIME_TYPE, call.argument<String>("mime") ?: "application/zip")
                        put(MediaStore.MediaColumns.RELATIVE_PATH, Environment.DIRECTORY_DOCUMENTS + "/Aloft")
                        put(MediaStore.MediaColumns.IS_PENDING, 1)
                    }
                    val uri = try {
                        resolver.insert(MediaStore.Files.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY), values)
                    } catch (e: Exception) {
                        null
                    }
                    var saved = false
                    if (uri != null) {
                        try {
                            resolver.openOutputStream(uri)!!.use { out -> File(path).inputStream().use { it.copyTo(out) } }
                            resolver.update(uri, ContentValues().apply { put(MediaStore.MediaColumns.IS_PENDING, 0) }, null, null)
                            saved = true
                        } catch (e: Exception) {
                            // Don't leave a half-written file behind.
                            try { resolver.delete(uri, null, null) } catch (ignored: Exception) {}
                        }
                    }
                    // The saved file's address, for opening it afterwards; null when it wasn't saved.
                    runOnUiThread { result.success(if (saved) uri.toString() else null) }
                }.start()
            }
    }
}
