package io.livekit.flutter.fliters.krisp

import com.cloudwebrtc.webrtc.FlutterWebRTCPlugin
import com.cloudwebrtc.webrtc.audio.LocalAudioTrack
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.util.Log
import io.livekit.audio.krisp.KrispAudioProcessor

class KrispAudioFilterPlugin :
  FlutterPlugin,
  MethodCallHandler {

  // MethodChannel to handle init/config calls from Dart
  private lateinit var methodChannel: MethodChannel

  private lateinit var krisp: KrispAudioProcessor

  private var krispConfig: KrispConfig? = null
  private var krispAudioFilter: KrispAudioFilter = KrispAudioFilter();

  override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel = MethodChannel(binding.binaryMessenger, "krisp_audio_filter_plugin")
    methodChannel.setMethodCallHandler(this)
    krisp = KrispAudioProcessor.getInstance(binding.applicationContext);
    krisp.init();
    if (krispConfig != null) {
      krisp.authenticate(krispConfig!!.url, krispConfig!!.token);
    }
    krispAudioFilter.krisp = krisp;
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    krisp.releaseResources();
    krispAudioFilter.krisp = null;
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {

      "krisp_audio_filter_update_context" -> {
        val url = call.argument<String>("url")
        val token = call.argument<String>("token")
        if (url == null || token == null) {
          result.error("invalid config params", "url: $url. token: $token", null)
          return
        }
        krispConfig = KrispConfig(url, token);
        krisp.authenticate(url, token);
        result.success(null)
      }

      "krisp_audio_filter_init"-> {
        // Example: we expect "trackId" in arguments
        val trackId = call.argument<String>("trackId")
        if (trackId == null) {
          result.error("INVALID_ARGUMENT", "trackId is required", null)
          return
        }

        val flutterWebRTCPlugin = FlutterWebRTCPlugin.sharedSingleton
        val track = flutterWebRTCPlugin.getLocalTrack(trackId)
        if (track == null) {
          result.error("trackNotFound", "No Audio track found for ID $trackId", null)
          return;
        }
        if (track !is LocalAudioTrack) {
          result.error("trackNotFound", "No Audio track found for ID $trackId", null)
          return;
        }
        Log.i("LivekitFilterPlugin", "Added Add krisp audio filter to track $trackId")
        flutterWebRTCPlugin.audioProcessingController.capturePostProcessing
          .addProcessor(krispAudioFilter)
        result.success(null)
      }

      else -> {
        result.notImplemented()
      }
    }
  }
}
