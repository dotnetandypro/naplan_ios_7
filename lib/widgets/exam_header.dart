import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart'; // ✅ Text-to-Speech
import 'dart:io' show Platform;
import '../screens/progress_summary_screen.dart';
import '../models/question_model.dart';
import '../theme/app_theme.dart';

class ExamHeader extends StatefulWidget {
  final int timeLeft;
  final int questionIndex;
  final int totalQuestions;
  final List<Question> questions;
  final List<dynamic> selectedAnswers;
  final List<bool> flaggedQuestions;
  final Function(int) onQuestionSelected;
  final VoidCallback onSubmit;
  final bool isParent; // Added isParent parameter

  const ExamHeader({
    Key? key,
    required this.timeLeft,
    required this.questionIndex,
    required this.totalQuestions,
    required this.questions,
    required this.selectedAnswers,
    required this.flaggedQuestions,
    required this.onQuestionSelected,
    required this.onSubmit,
    this.isParent = false, // Default to false for backward compatibility
  }) : super(key: key);

  @override
  _ExamHeaderState createState() => _ExamHeaderState();
}

class _ExamHeaderState extends State<ExamHeader> {
  FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _ttsInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _setupTtsHandlers();
  }

  /// Setup TTS event handlers
  void _setupTtsHandlers() {
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });

    _flutterTts.setErrorHandler((msg) {
      print("TTS Error: $msg");
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });

    _flutterTts.setStartHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = true;
        });
      }
    });
  }

  /// Initialize TTS with voice based on question ID
  Future<void> _initializeTts() async {
    try {
      // Set language first
      await _flutterTts.setLanguage("en-AU");

      // iOS-specific configuration
      if (!kIsWeb && Platform.isIOS) {
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.spokenAudio,
        );

        // Get available voices and select appropriate one
        List<dynamic> voices = await _flutterTts.getVoices;
        print("Available voices: ${voices.length}");

        // Try to find Australian English voices
        var australianVoices = voices
            .where((voice) =>
                voice['locale'] == 'en-AU' ||
                voice['locale'] == 'en_AU' ||
                voice['name'].toString().toLowerCase().contains('australia'))
            .toList();

        if (australianVoices.isNotEmpty) {
          // Use question ID to determine voice: even = male, odd = female
          final currentQuestionId = widget.questions[widget.questionIndex].id;
          dynamic selectedVoice;

          if (currentQuestionId % 2 == 0) {
            // Even question ID = Male voice
            selectedVoice = australianVoices.firstWhere(
              (voice) =>
                  voice['name'].toString().toLowerCase().contains('male') ||
                  voice['name'].toString().toLowerCase().contains('man'),
              orElse: () => australianVoices.first,
            );
            print(
                "TTS: Using male voice: ${selectedVoice['name']} (Question ID: $currentQuestionId)");
          } else {
            // Odd question ID = Female voice
            selectedVoice = australianVoices.firstWhere(
              (voice) =>
                  voice['name'].toString().toLowerCase().contains('female') ||
                  voice['name'].toString().toLowerCase().contains('woman'),
              orElse: () => australianVoices.first,
            );
            print(
                "TTS: Using female voice: ${selectedVoice['name']} (Question ID: $currentQuestionId)");
          }

          await _flutterTts.setVoice({
            "name": selectedVoice['name'],
            "locale": selectedVoice['locale']
          });
        }
      }

      // Set conservative speech parameters for better compatibility
      final currentQuestionId = widget.questions[widget.questionIndex].id;
      if (currentQuestionId % 2 == 0) {
        // Even question ID = Male voice settings (more conservative)
        await _flutterTts.setPitch(0.8); // Less extreme pitch
        await _flutterTts.setSpeechRate(0.4); // Much slower for clarity
      } else {
        // Odd question ID = Female voice settings (more conservative)
        await _flutterTts.setPitch(1.0); // Normal pitch
        await _flutterTts.setSpeechRate(0.45); // Slightly faster but still slow
      }

      await _flutterTts.setVolume(0.9); // Higher volume for better audibility

      _ttsInitialized = true;
      print("TTS initialized successfully");
    } catch (e) {
      print("TTS initialization error: $e");
      _ttsInitialized = false;
    }
  }

  /// ✅ Play or stop speech
  Future<void> _toggleSpeech() async {
    try {
      if (_isSpeaking) {
        await _flutterTts.stop();
        if (mounted) {
          setState(() {
            _isSpeaking = false;
          });
        }
      } else {
        // Ensure TTS is initialized before speaking
        if (!_ttsInitialized) {
          print("TTS not initialized, reinitializing...");
          await _initializeTts();
        }

        final String? audioUrl =
            widget.questions[widget.questionIndex].audioUrl;
        if (audioUrl != null && audioUrl.isNotEmpty) {
          print(
              "Speaking text: ${audioUrl.substring(0, audioUrl.length > 50 ? 50 : audioUrl.length)}...");

          // Convert math expressions to readable text
          String speechText = _convertMathToSpeech(audioUrl);

          // Speak the text
          var result = await _flutterTts.speak(speechText);
          print("TTS speak result: $result");

          if (mounted) {
            setState(() {
              _isSpeaking = true;
            });
          }
        } else {
          print("No audio text available for this question");
        }
      }
    } catch (e) {
      print("Error in _toggleSpeech: $e");
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    }
  }

  /// ✅ Converts math expressions into readable text for TTS
  String _convertMathToSpeech(String input) {
    return input
        .replaceAll(r'\frac{1}{2}', 'one half')
        .replaceAll(r'\frac{3}{4}', 'three fourths')
        .replaceAll(r'\times', 'times')
        .replaceAll(r'\div', 'divided by')
        .replaceAll(r'=', 'equals')
        .replaceAll(r'\sqrt{', 'square root of ')
        .replaceAll(r'\cbrt{', 'cube root of ')
        .replaceAll(r'\fourthrt{', 'fourth root of ')
        .replaceAll(r'log', 'logarithm of ')
        .replaceAll(r'!', ' factorial')
        .replaceAll(r'\int', 'integral of ')
        .replaceAll(r'\prime', 'derivative of ')
        .replaceAll(r'\sum', 'summation of ')
        .replaceAll(r'\prod', 'product of ')
        .replaceAll(r'\pi', 'pi')
        .replaceAll(r'\theta', 'theta')
        .replaceAll(r'\alpha', 'alpha')
        .replaceAll(r'\beta', 'beta')
        .replaceAll(r'\gamma', 'gamma')
        .replaceAll(r'\equiv', 'equivalent to')
        .replaceAll(r'\neq', 'not equal to')
        .replaceAll(r'<', 'less than')
        .replaceAll(r'\leq', 'less than or equal to')
        .replaceAll(r'>', 'greater than')
        .replaceAll(r'\geq', 'greater than or equal to')
        .replaceAll(r'\approx', 'approximately equal to')
        .replaceAll(r'$', '');
  }

  @override
  void didUpdateWidget(ExamHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.questionIndex != oldWidget.questionIndex) {
      // Stop speech when switching questions
      _flutterTts.stop();
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
      // Reinitialize TTS with new question ID-based voice
      _ttsInitialized = false;
      _initializeTts();
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _ttsInitialized = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main header bar with time, question number, and summary button
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Time Left with countdown style
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.white, size: 20),
                    SizedBox(width: 6),
                    Text(
                      // Convert seconds to MM:SS format
                      "${(widget.timeLeft ~/ 60).toString().padLeft(2, '0')}:${(widget.timeLeft % 60).toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              // Centered Question Number
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        "Question ${widget.questionIndex + 1} / ${widget.totalQuestions}",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        "ID: ${widget.questions[widget.questionIndex].id}",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              // Progress Summary Button - improved
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    _flutterTts.stop();
                    setState(() {
                      _isSpeaking = false;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProgressSummaryScreen(
                          questions: widget.questions,
                          selectedAnswers: widget.selectedAnswers,
                          flaggedQuestions: widget.flaggedQuestions,
                          onQuestionSelected: widget.onQuestionSelected,
                          onSubmit: widget.onSubmit,
                          onBack: () => Navigator.pop(context),
                          isParent: widget.isParent, // Pass isParent parameter
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Icon(
                      Icons.grid_view,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // TTS Control Button with improved UI
        if (widget.questions[widget.questionIndex].audioUrl != null &&
            widget.questions[widget.questionIndex].audioUrl!.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: _toggleSpeech,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isSpeaking ? Icons.stop_circle : Icons.play_circle,
                        color: AppTheme.primaryColor,
                        size: 28,
                      ),
                      SizedBox(width: 10),
                      Text(
                        _isSpeaking ? "Stop Reading" : "Listen to Question",
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
