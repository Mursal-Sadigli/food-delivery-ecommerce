import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class VoiceSearchWidget extends StatefulWidget {
  final Function(String) onResult;

  const VoiceSearchWidget({super.key, required this.onResult});

  @override
  State<VoiceSearchWidget> createState() => _VoiceSearchWidgetState();
}

class _VoiceSearchWidgetState extends State<VoiceSearchWidget> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            if (_isListening) {
              setState(() => _isListening = false);
              Navigator.pop(context); // Close dialog if done
              if (_text.isNotEmpty) {
                widget.onResult(_text);
              }
            }
          }
        },
        onError: (val) {
          setState(() => _isListening = false);
          Navigator.pop(context);
        },
      );
      if (available) {
        setState(() => _isListening = true);
        _showListeningDialog();
        _speech.listen(
          onResult: (val) {
            setState(() {
              _text = val.recognizedWords;
            });
          },
        );
      }
    }
  }

  void _showListeningDialog() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const Spacer(),
            const SpinKitPulse(color: Color(0xFFFF5722), size: 100),
            const SizedBox(height: 24),
            Text(
              _text.isEmpty ? "Dinlənilir..." : _text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text("Zəhmət olmasa, axtarmaq istədiyinizi deyin", style: TextStyle(color: Colors.grey)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () {
                  _speech.stop();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Dayandır"),
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      if (_isListening) {
        _speech.stop();
        setState(() => _isListening = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.mic, color: Theme.of(context).colorScheme.primary),
      onPressed: _listen,
      tooltip: "Səsli Axtarış",
    );
  }
}
