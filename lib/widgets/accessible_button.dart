import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 시각장애인용 접근성 버튼
/// - 싱글 탭: TTS로 버튼 이름 읽어줌
/// - 더블 탭: 실제 동작 실행
class AccessibleButton extends StatelessWidget {
  const AccessibleButton({
    super.key,
    required this.tts,
    required this.label,
    required this.onDoubleTap,
    required this.child,
    this.ttsMessage,
    this.doubleTapMessage,
  });

  final FlutterTts tts;
  final String label;
  final String? ttsMessage;
  final String? doubleTapMessage;
  final VoidCallback onDoubleTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => tts.speak(ttsMessage ?? label),
      onDoubleTap: () {
        if (doubleTapMessage != null) {
          tts.speak(doubleTapMessage!);
          tts.setCompletionHandler(() {
            tts.setCompletionHandler(() {});
            onDoubleTap();
          });
        } else {
          onDoubleTap();
        }
      },
      child: child,
    );
  }
}
