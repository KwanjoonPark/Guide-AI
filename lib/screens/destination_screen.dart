import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/naver_navigation_service.dart';
import '../model/route_info.dart';
import 'navigation_screen.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key});

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  static const _bgColor = Color(0xFF0D1B2A);
  static const _accentColor = Color(0xFF00E5CC);
  static const _cardColor = Color(0xFF1B2D45);

  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final NaverNavigationService _naverService = NaverNavigationService();

  bool _isListening = false;
  bool _speechAvailable = false;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('ko-KR');
    _tts.setSpeechRate(0.4);
    _tts.setPitch(1.0);

    _initSpeech();

    // 화면 진입 시 TTS 안내
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tts.speak('목적지를 말씀해주세요');
    });
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) return;
    await _tts.stop();
    setState(() {
      _isListening = true;
      _recognizedText = '';
    });
    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
        if (result.finalResult) {
          setState(() => _isListening = false);
          if (_recognizedText.isNotEmpty) {
            _tts.speak('$_recognizedText, 맞으시면 안내 시작을 눌러주세요');
          }
        }
      },
      localeId: 'ko_KR',
      listenMode: stt.ListenMode.dictation,
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() => _isListening = false);
  }

  void _toggleListening() {
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // 상단 바: 뒤로가기 + 제목
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '목적지 설정',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Spacer(flex: 2),
              // 상태 텍스트
              Text(
                _isListening ? '듣고 있습니다...' : '마이크를 눌러 말씀해주세요',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 40),
              // 마이크 버튼
              GestureDetector(
                onTap: _toggleListening,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isListening ? 140 : 120,
                  height: _isListening ? 140 : 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? _accentColor.withValues(alpha: 0.2)
                        : _cardColor,
                    border: Border.all(
                      color: _isListening
                          ? _accentColor
                          : _accentColor.withValues(alpha: 0.4),
                      width: _isListening ? 3 : 2,
                    ),
                  ),
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none_rounded,
                    color: _accentColor,
                    size: 56,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // 인식된 텍스트 표시
              if (_recognizedText.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _accentColor.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _recognizedText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            _tts.speak('$_recognizedText(으)로 안내를 시작합니다');
                            // 경로 안내 화면으로 이동
                            final routeInfo = await _naverService.getRouteByAddress(
                              goalAddress: _recognizedText,
                            );
                            if (routeInfo != null && mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NavigationScreen(routeInfo: routeInfo),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: _bgColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            '안내 시작',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

