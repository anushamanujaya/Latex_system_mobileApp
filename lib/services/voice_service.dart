import 'package:speech_to_text/speech_to_text.dart';

class VoiceService {
  final SpeechToText speech = SpeechToText();

  Future<bool> init() async {
    return await speech.initialize();
  }

  Future<void> startListening({required Function(String text) onResult}) async {
    await speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
    );
  }

  Future<void> stopListening() async {
    await speech.stop();
  }

  bool get isListening => speech.isListening;
}
