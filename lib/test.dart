import 'package:audio_service/audio_service.dart';

class AudioTaskHandler extends BaseAudioHandler with SeekHandler {
  Future<void> play() async {}
  Future<void> pause() async {}
  Future<void> stop() async {}
  Future<void> seek(Duration position) async {}
  Future<void> skipToNext() async {}
  Future<void> skipToPrevious() async {}
}
