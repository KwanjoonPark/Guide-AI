import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../widgets/accessible_button.dart';

class FreeRoamingScreen extends StatefulWidget {
  const FreeRoamingScreen({super.key});

  @override
  State<FreeRoamingScreen> createState() => _FreeRoamingScreenState();
}

class _FreeRoamingScreenState extends State<FreeRoamingScreen> {
  static const _bgColor = Color(0xFF0D1B2A);
  static const _accentColor = Color(0xFF00E5CC);

  final FlutterTts _tts = FlutterTts();
  CameraController? _cameraController;
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('ko-KR');
    _tts.setSpeechRate(0.4);
    _tts.setPitch(1.0);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (!mounted) return;

    setState(() => _isCameraReady = true);
    _tts.speak('자유 이동 모드를 시작합니다');
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // 카메라 프리뷰
            if (_isCameraReady)
              Positioned.fill(
                child: CameraPreview(_cameraController!),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: _accentColor),
              ),
            // 상단 바
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  AccessibleButton(
                    tts: _tts,
                    label: '뒤로가기',
                    doubleTapMessage: '홈 화면으로 돌아갑니다',
                    onDoubleTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _bgColor.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _bgColor.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '자유 이동',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
