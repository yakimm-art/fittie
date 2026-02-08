import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/app_state.dart';

class VoiceService {
  static String get _apiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';
  static const String _baseUrl = "https://api.elevenlabs.io/v1/text-to-speech";

  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _ttsInitialized = false;

  // Memory Cache to save money
  final Map<String, Uint8List> _audioCache = {};

  // Track if ElevenLabs is usable (set to false on 402/auth errors)
  bool _elevenLabsAvailable = true;

  static const String _mascotVoiceId = "SOYHLrjzK2X1ezoPC6cr";

  /// Initialize the browser/native TTS fallback
  Future<void> _initTts() async {
    if (_ttsInitialized) return;
    try {
      if (kIsWeb) {
        await _tts.setEngine("google");
      }
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.15);
      await _tts.setVolume(1.0);
      _ttsInitialized = true;
    } catch (e) {
      print("⚠️ TTS init: $e");
    }
  }

  Future<void> speak(String text, FittieMode mode) async {
    print("🐻 Bear wants to say: $text");

    // --- Try ElevenLabs first (premium voice) ---
    if (_elevenLabsAvailable && _apiKey.isNotEmpty) {
      final bool played = await _tryElevenLabs(text, mode);
      if (played) return;
    }

    // --- Fallback: browser / native TTS ---
    await _speakWithTts(text, mode);
  }

  /// Attempt ElevenLabs TTS. Returns true if audio played successfully.
  Future<bool> _tryElevenLabs(String text, FittieMode mode) async {
    try {
      final String cacheKey = "${text}_${mode.name}";

      // 1. CHECK CACHE
      if (_audioCache.containsKey(cacheKey)) {
        print("💰 Playing from cache");
        await _playAudio(_audioCache[cacheKey]!);
        return true;
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
        print("✅ ElevenLabs audio: ${response.bodyBytes.length} bytes");
        _audioCache[cacheKey] = response.bodyBytes;
        await _playAudio(response.bodyBytes);
        return true;
      }

      // 401 / 402 → subscription issue, don't retry on every call
      if (response.statusCode == 401 || response.statusCode == 402) {
        print("⚠️ ElevenLabs ${response.statusCode} — switching to browser TTS");
        _elevenLabsAvailable = false;
      } else {
        print("❌ ElevenLabs ${response.statusCode}: ${response.body}");
      }
      return false;
    } catch (e) {
      print("❌ ElevenLabs error: $e — falling back to browser TTS");
      return false;
    }
  }

  /// Fallback: use the browser's built-in SpeechSynthesis (free, instant)
  Future<void> _speakWithTts(String text, FittieMode mode) async {
    try {
      await _initTts();

      // Adjust speech style per mode
      switch (mode) {
        case FittieMode.power:
          await _tts.setSpeechRate(0.5);
          await _tts.setPitch(1.2);
          break;
        case FittieMode.zen:
          await _tts.setSpeechRate(0.38);
          await _tts.setPitch(1.0);
          break;
        case FittieMode.desk:
          await _tts.setSpeechRate(0.42);
          await _tts.setPitch(1.1);
          break;
      }

      await _tts.speak(text);
      print("🔊 Browser TTS playing");
    } catch (e) {
      print("❌ TTS fallback failed: $e");
    }
  }

  // --- AUDIO PLAYBACK (ElevenLabs bytes) ---
  Future<void> _playAudio(Uint8List bytes) async {
    try {
      await _player.setVolume(1.0);
      await _player.stop();

      if (kIsWeb) {
        // On web, BytesSource can be unreliable — use base64 data URL
        final base64Data = base64Encode(bytes);
        final dataUrl = 'data:audio/mpeg;base64,$base64Data';
        await _player.play(UrlSource(dataUrl));
      } else {
        await _player.play(BytesSource(bytes));
      }
      print("🔊 Audio playback started");
    } catch (e) {
      print("❌ Audio player failed: $e");
    }
  }
}
