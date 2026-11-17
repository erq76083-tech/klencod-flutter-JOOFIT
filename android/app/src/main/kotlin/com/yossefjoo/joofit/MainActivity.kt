package com.yossefjoo.joofit

import android.content.Context
import android.media.AudioManager
import android.media.ToneGenerator
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.yossefjoo.joofit/sound"
    private var toneGenerator: ToneGenerator? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        try {
            toneGenerator = ToneGenerator(AudioManager.STREAM_MUSIC, 65)
        } catch (_: Exception) {
            toneGenerator = null
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                val audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager
                when (call.method) {
                    "playTap" -> {
                        audioManager?.playSoundEffect(AudioManager.FX_KEY_CLICK, 0.8f)
                        toneGenerator?.startTone(ToneGenerator.TONE_PROP_BEEP, 18)
                        result.success(true)
                    }
                    "playTick" -> {
                        audioManager?.playSoundEffect(AudioManager.FX_KEYPRESS_STANDARD, 0.7f)
                        toneGenerator?.startTone(ToneGenerator.TONE_PROP_BEEP2, 22)
                        result.success(true)
                    }
                    "playSuccess" -> {
                        audioManager?.playSoundEffect(AudioManager.FX_KEYPRESS_RETURN, 0.9f)
                        toneGenerator?.startTone(ToneGenerator.TONE_PROP_ACK, 85)
                        result.success(true)
                    }
                    "playAlarm" -> {
                        toneGenerator?.startTone(ToneGenerator.TONE_CDMA_ALERT_CALL_GUARD, 220)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.success(false)
            }
        }
    }

    override fun onDestroy() {
        try {
            toneGenerator?.release()
            toneGenerator = null
        } catch (_: Exception) {}
        super.onDestroy()
    }
}
