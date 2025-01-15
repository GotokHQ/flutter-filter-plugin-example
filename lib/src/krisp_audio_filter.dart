import 'package:livekit_client/livekit_client.dart';

import 'method_channel.dart';

class KrispAudioFilter implements TrackProcessor<AudioProcessorOptions> {
  final methodChannel = MethodChannelStatic.methodChannel;
  final String methodPrefix = 'krisp_audio_filter';

  @override
  Future<void> destroy() async {
    await methodChannel.invokeMethod('${methodPrefix}_destroy');
  }

  @override
  Future<void> init(ProcessorOptions<TrackType> options) async {
    await methodChannel.invokeMethod('${methodPrefix}_init', {
      'trackId': options.track.id,
    });
  }

  @override
  String get name => 'KrispAudioFilter';

  @override
  Future<void> onPublish(Room room) async {
    await methodChannel.invokeMethod('${methodPrefix}_onPublish', {});
  }

  @override
  Future<void> onUnpublish() async {
    await methodChannel.invokeMethod('${methodPrefix}_onUnpublish');
  }

  @override
  Future<void> restart(options) async {
    await methodChannel.invokeMethod('${methodPrefix}_restart');
  }

  Future<void> updateRoomContext({
    required String url,
    required String token,
    String? sid,
    String? name,
    String? serverVersion,
    String? serverRegion,
    ConnectionState? connectionState,
  }) async {
    await methodChannel.invokeMethod('${methodPrefix}_update_context', {
      'url': url,
      'token': token,
      'sid': sid,
      'name': name,
      'serverVersion': serverVersion,
      'serverRegion': serverRegion,
      'connectionState': connectionState?.name,
    });
  }
}
