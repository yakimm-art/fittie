import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/app_state.dart';

class VoiceService {
  static String get _apiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';
  static const String _baseUrl = "https://api.elevenlabs.io/v1/text-to-speech";

  final AudioPlayer _player = AudioPlayer();

  // Memory Cache to save money
  final Map<String, Uint8List> _audioCache = {};

  // Your chosen "Mascot" Voice ID
  static const String _mascotVoiceId = "hMK7c1GPJmptCzI4bQIu";

  Future<void> speak(String text, FittieMode mode) async {
    try {
      print("🐻 Bear wants to say: $text"); // Debug log

      final String cacheKey = "${text}_${mode.name}";

      // 1. CHECK CACHE
      if (_audioCache.containsKey(cacheKey)) {
        print("💰 Playing from Cache (0 Credits)");
        await _playAudio(_audioCache[cacheKey]!);
        return;
      }

      // 2. PREPARE SETTINGS
      double stability = 0.5;
      double similarity = 0.8;

      switch (mode) {
        case FittieMode.power:
          stability = 0.3;
          break;
        case FittieMode.zen:
          stability = 0.9;
          break;
        case FittieMode.desk:
          stability = 0.6;
          break;
      }

      // 3. CALL API
      final url = Uri.parse("$_baseUrl/$_mascotVoiceId");
      final response = await http.post(
        url,
        headers: {
          "xi-api-key": _apiKey,
          "Content-Type": "application/json",
          "accept": "audio/mpeg",
        },
        body: jsonEncode({
          "text": text,
          "model_id": "eleven_turbo_v2_5",
          "voice_settings": {
            "stability": stability,
            "similarity_boost": similarity,
            "style": 0.5,
          },
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Audio received! Size: ${response.bodyBytes.length} bytes");
        // Save to cache
        _audioCache[cacheKey] = response.bodyBytes;
        // Play
        await _playAudio(response.bodyBytes);
      } else {
        print("❌ ElevenLabs API Error: ${response.body}");
      }
    } catch (e) {
      print("❌ Critical Voice Error: $e");
    }
  }

  // --- ROBUST PLAYBACK HELPER ---
  Future<void> _playAudio(Uint8List bytes) async {
    try {
      // FORCE VOLUME TO MAX
      await _player.setVolume(1.0);

      // Stop previous audio to prevent overlapping
      await _player.stop();

      // Set source and play
      await _player.play(BytesSource(bytes));
    } catch (e) {
      print("❌ Audio Player Failed: $e");
    }
  }
}
