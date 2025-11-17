import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/speech_service.dart';
import 'confirm_meal_screen.dart';

class AddMealScreen extends StatefulWidget {
  final int userId;

  const AddMealScreen({super.key, required this.userId});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final SpeechService _speechService = SpeechService();
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _recognizedText;
  String? _audioPath;

  @override
  void dispose() {
    _speechService.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      final path = await _speechService.startRecording();
      setState(() {
        _isRecording = true;
        _audioPath = path;
        _recognizedText = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _speechService.stopRecording();
      if (path != null) {
        setState(() {
          _isRecording = false;
          _audioPath = path;
        });
        await _processAudio(path);
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _processAudio(String audioPath) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.uploadSpeech(audioPath);
      setState(() {
        _recognizedText = response['text'] ?? '';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing audio: $e')),
        );
      }
    }
  }

  void _continueToConfirm() {
    if (_recognizedText != null && _recognizedText!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmMealScreen(
            userId: widget.userId,
            recognizedText: _recognizedText!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please record audio first')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Meal'),
        backgroundColor: Colors.green.shade400,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mic,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 32),
            const Text(
              'Record your meal',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap the microphone button and describe what you ate',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 48),
            GestureDetector(
              onTap: _isRecording ? _stopRecording : _startRecording,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : Colors.green.shade400,
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? Colors.red : Colors.green.shade400)
                          .withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (_isProcessing)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing audio...'),
                ],
              )
            else if (_recognizedText != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Recognized Text:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _recognizedText!,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 32),
            if (_recognizedText != null && _recognizedText!.isNotEmpty)
              ElevatedButton(
                onPressed: _continueToConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

