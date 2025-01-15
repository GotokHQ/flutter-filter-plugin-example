import Foundation
import flutter_webrtc
import KrispNoiseFilter

public class KrispAudioFilter {
    
    private let krisp = KrispNoiseFilter()
    var isInitializedWithRate: Int?
    
    public func updateContext(_ roomContext: LiveKitRoomContext) {
        krisp.update(roomContext)
    }
}


extension KrispAudioFilter: ExternalAudioProcessingDelegate {
    public func audioProcessingInitialize(withSampleRate sampleRateHz: Int, channels: Int) {
        print("LiveKitAudioFilter audioProcessingInitialize")
        if isInitializedWithRate == nil {
            isInitializedWithRate = sampleRateHz
            krisp.initialize(Int32(sampleRateHz), numChannels: Int32(channels))
        } else {
            // Krisp already initialized, reset with new sample rate.
            krisp.reset(Int32(sampleRateHz))
        }
    }

    public var audioProcessingName: String { "LivekitAudioFilterSample" }

    public func audioProcessingProcess(_ audioBuffer: RTCAudioBuffer) {
        /// you can processing audio frame here
        print("LiveKitAudioFilter audioProcessingProcess")
        
         guard krisp.isAuthorized else {
             print("LiveKitKrispNoiseFilter disabled - This feature is supported only on LiveKit Cloud.")
             return
         }

         for channel in 0 ..< audioBuffer.channels {
             let result = krisp.process(withBands: Int32(audioBuffer.bands),
                                        frames: Int32(audioBuffer.frames),
                                        bufferSize: Int32(audioBuffer.framesPerBand),
                                        buffer: audioBuffer.rawBuffer(forChannel: channel))
             if !result {
                 print("LiveKitKrispNoiseFilter Process failed, channel: \(channel)")
             }
         }
    }

    public func audioProcessingRelease() {
        print("LiveKitAudioFilter Release")
    }
}
