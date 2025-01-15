import WebRTC
import flutter_webrtc
import KrispNoiseFilter
#if os(macOS)
import Cocoa
import FlutterMacOS
#else
import Flutter
import UIKit
#endif

public class KrispAudioFilterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
#if os(macOS)
    let messenger = registrar.messenger
#else
    let messenger = registrar.messenger()
 #endif
    let channel = FlutterMethodChannel(name: "krisp_audio_filter_plugin", binaryMessenger: messenger)
    let instance = KrispAudioFilterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    if !KrispNoiseFilter.krispGlobalInit() {
        print("LiveKitKrispNoiseFilter GlobalInit Failed")
    }
  }
    
    private var krispFilter = KrispAudioFilter()
    private var roomContext: LiveKitRoomContext?
    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "krisp_audio_filter_update_context":
        let args = call.arguments as! [String: Any]
        let sid = args["sid"] as? String
        let name = args["name"] as? String
        let serverVersion = args["serverVersion"] as? String
        let serverRegion = args["serverRegion"] as? String
        let serverNodeId = args["serverNodeId"] as? String
        let connectionState = mapToConnectionState(args["connectionState"] as? String)
        let token = args["token"] as? String
        let url = args["url"] as? String
        roomContext = LiveKitRoomContext(
            sid: sid,
            name: name,
            serverVersion: serverVersion,
            serverRegion: serverRegion,
            serverNodeId: serverNodeId,
            connectionState: connectionState,
            url: url,
            token: token
        )
        if let ctx = roomContext {
            krispFilter.updateContext(ctx)
        }
        
    case "krisp_audio_filter_init":
        let args = call.arguments as! [String: Any]
        let trackId = args["trackId"] as? String
        let webrtc = FlutterWebRTCPlugin.sharedSingleton()
        if let unwrappedTrackId = trackId {
            let localTrack = webrtc?.localTracks![unwrappedTrackId]
            if let audioTrack = localTrack as? LocalAudioTrack {
                audioTrack.addProcessing(krispFilter)
                
            }
        }
        result(nil)
    default:
      result(nil)
    }
  }
    
    func mapToConnectionState(_ state: String?)  -> LiveKitConnectionState {
        switch state {
            case "disconnected":
                return LiveKitConnectionState.Disconnected
            default:
                return LiveKitConnectionState.Disconnected
        }
    }
}
