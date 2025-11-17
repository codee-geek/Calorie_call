import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SpeechService {
  final AudioRecorder _recorder = AudioRecorder();

  Future<String> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000,
            numChannels: 1,
          ),
          path: filePath,
        );
        return filePath;
      } else {
        throw Exception('Microphone permission denied');
      }
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _recorder.stop();
      return path;
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}

