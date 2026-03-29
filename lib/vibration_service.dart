import 'package:vibration/vibration.dart';

class VibrationService {
  // 위험 단계별 진동 함수
  static Future<void> vibrateByLevel(String level) async {
    // 기기에 진동 기능이 있는지 확인
    if (await Vibration.hasVibrator() ?? false) {

      if (level == "low") {
        // [저위험] 간헐적 저주파 진동
        // 패턴: 0초 대기, 0.2초 진동, 0.5초 대기, 0.2초 진동
        // 강도: 50 (약하게), 2번 짧게 울림
        Vibration.vibrate(pattern: [0, 200, 500, 200],
            intensities: [0, 50, 0, 50]);
      }
      else if (level == "medium") {
        // [중위험] 규칙적인 중간 세기 진동
        // 패턴: 0초 대기, 0.5초 진동, 0.5초 대기, 0.5초 진동, 0.5초 대기, 0.5초 진동
        // 강도: 128 (중간), 3번 길게 울림
        Vibration.vibrate(pattern: [0, 500, 500, 500, 500, 500],
            intensities: [0, 128, 0, 128, 0, 128]);
      }
      else if (level == "high") {
        // [고위험] 연속적인 고주파 진동
        // 강도: 255 (강하게)
        // 2초 동안 끊김 없이 강하게 진동
        Vibration.vibrate(duration: 2000, amplitude: 255);
      }
    }
  }

  // 진동 즉시 중지
  static void stop() {
    Vibration.cancel();
  }
}