package io.livekit.flutter.fliters.krisp

import android.util.Log
import com.cloudwebrtc.webrtc.audio.AudioProcessingAdapter
import io.livekit.audio.krisp.KrispAudioProcessor
import java.nio.ByteBuffer

class KrispAudioFilter() : AudioProcessingAdapter.ExternalAudioFrameProcessing {

    private var _krisp: KrispAudioProcessor? = null
    var krisp: KrispAudioProcessor?
        get() = _krisp
        set(value) {
            _krisp = value
            // If you need to do any additional setup/reset,
            // you can do it inside this setter.
        }

    private val TAG = "KrispAudioFilter"

    override fun initialize(sampleRateHz: Int, numChannels: Int) {
        Log.i(TAG, "initialize( sampleRateHz=$sampleRateHz, numChannels=$numChannels )");
        _krisp?.initializeAudioProcessing(sampleRateHz, numChannels);
    }

    override fun reset(newRate: Int) {
        Log.i(TAG, "reset( newRate=$newRate )")
        _krisp?.resetAudioProcessing(newRate);
    }

    override fun process(numBands: Int, numFrames: Int, buffer: ByteBuffer?) {
        if (buffer == null) {
            Log.i(TAG, "Buffer is null")
            return;
        }
        if (_krisp == null) {
            Log.i(TAG, "Krisp is null")
            return;
        }
        if (!_krisp!!.isEnabled()) {
            Log.i(TAG, "Krisp is not enabled, pls authenticate")
            return;
        }
        _krisp!!.processAudio(numBands, numFrames, buffer);
    }
}
