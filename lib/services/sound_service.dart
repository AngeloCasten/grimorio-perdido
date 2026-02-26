import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final AudioPlayer _bgPlayer = AudioPlayer();
  static final AudioPlayer _sfxPlayer = AudioPlayer();
  
  static bool _muted = false;

  static Future<void> playBGM() async {
    if (_muted) return;
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    // Nota: Substitua por uma URL real ou arquivo em assets
    // await _bgPlayer.play(UrlSource('https://example.com/mystic_bgm.mp3'));
    await _bgPlayer.setVolume(0.3);
  }

  static Future<void> playSFX(String type) async {
    if (_muted) return;
    String url = "";
    switch (type) {
      case "success":
        url = "https://assets.mixkit.co/active_storage/sfx/2000/2000-preview.mp3";
        break;
      case "error":
        url = "https://assets.mixkit.co/active_storage/sfx/2100/2100-preview.mp3";
        break;
      case "page":
        url = "https://assets.mixkit.co/active_storage/sfx/2500/2500-preview.mp3";
        break;
    }
    if (url.isNotEmpty) {
      await _sfxPlayer.play(UrlSource(url));
    }
  }

  static void toggleMute() {
    _muted = !_muted;
    if (_muted) {
      _bgPlayer.pause();
    } else {
      _bgPlayer.resume();
    }
  }
}
