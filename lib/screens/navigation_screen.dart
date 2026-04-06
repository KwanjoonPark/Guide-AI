import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../model/route_info.dart';
import '../widgets/accessible_button.dart';

class NavigationScreen extends StatefulWidget {
  final RouteInfo routeInfo;

  const NavigationScreen({Key? key, required this.routeInfo}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  static const _bgColor = Color(0xFF0D1B2A);
  static const _accentColor = Color(0xFF00E5CC);
  static const _cardColor = Color(0xFF1B2D45);

  final FlutterTts _tts = FlutterTts();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
    _speakEntryGuide();
  }

  Future<void> _speakEntryGuide() async {
    String distanceText;
    if (widget.routeInfo.totalDistance >= 1000) {
      double km = widget.routeInfo.totalDistance / 1000.0;
      distanceText = '${km.toStringAsFixed(1)}킬로미터';
    } else {
      distanceText = '${widget.routeInfo.totalDistance}미터';
    }
    int totalMin = (widget.routeInfo.totalDuration / 60).ceil();
    if (totalMin < 1) totalMin = 1;
    await _tts.speak('총 거리 $distanceText, 예상 시간 ${totalMin}분입니다.');
    _tts.setCompletionHandler(() {
      _speakCurrentInstruction();
      _tts.setCompletionHandler(() {});
    });
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  Future<void> _speakCurrentInstruction() async {
    if (_currentStep < widget.routeInfo.guides.length) {
      String instruction = widget.routeInfo.guides[_currentStep].instructions;
      await _tts.speak(instruction);
    }
  }

  Future<void> _speakSummary() async {
    String distanceText;
    if (widget.routeInfo.totalDistance >= 1000) {
      double km = widget.routeInfo.totalDistance / 1000.0;
      distanceText = '${km.toStringAsFixed(1)}킬로미터';
    } else {
      distanceText = '${widget.routeInfo.totalDistance}미터';
    }
    int totalMin = (widget.routeInfo.totalDuration / 60).ceil();
    if (totalMin < 1) totalMin = 1;
    await _tts.speak('총 거리 $distanceText, 예상 시간 ${totalMin}분입니다.');
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _cardColor,
        leading: AccessibleButton(
          tts: _tts,
          label: '뒤로가기',
          doubleTapMessage: '목적지 설정 화면으로 돌아갑니다',
          onDoubleTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.arrow_back, color: _accentColor, size: 32),
          ),
        ),
        title: const Text(
          '경로 안내',
          style: TextStyle(
            color: _accentColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 요약 정보
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accentColor, width: 3),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoChip(
                      icon: Icons.straighten,
                      label: '총 거리',
                      value: widget.routeInfo.totalDistance >= 1000
                          ? '${(widget.routeInfo.totalDistance / 1000).toStringAsFixed(1)} km'
                          : '${widget.routeInfo.totalDistance} m',
                    ),
                    _buildInfoChip(
                      icon: Icons.access_time,
                      label: '예상 시간',
                      value: '${(widget.routeInfo.totalDuration / 60).round()} 분',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AccessibleButton(
                  tts: _tts,
                  label: '요약 정보 듣기',
                  onDoubleTap: _speakSummary,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: _accentColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.volume_up, size: 28, color: _bgColor),
                        const SizedBox(width: 8),
                        Text(
                          '요약 정보 듣기',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _bgColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 현재 안내
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: _accentColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  '현재 안내',
                  style: TextStyle(
                    color: _bgColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _currentStep < widget.routeInfo.guides.length
                      ? widget.routeInfo.guides[_currentStep].instructions
                      : '목적지에 도착했습니다!',
                  style: TextStyle(
                    color: _bgColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                AccessibleButton(
                  tts: _tts,
                  label: '다시 듣기',
                  onDoubleTap: _speakCurrentInstruction,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      color: _bgColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.replay, size: 28, color: _accentColor),
                        const SizedBox(width: 8),
                        const Text(
                          '다시 듣기',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 전체 경로 리스트
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: widget.routeInfo.guides.length,
                itemBuilder: (context, index) {
                  final guide = widget.routeInfo.guides[index];
                  final isCurrent = index == _currentStep;

                  return AccessibleButton(
                    tts: _tts,
                    label: guide.instructions,
                    onDoubleTap: () {
                      setState(() {
                        _currentStep = index;
                      });
                      _speakCurrentInstruction();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? _accentColor.withValues(alpha: 0.2)
                            : _bgColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent ? _accentColor : _cardColor,
                          width: 3,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: isCurrent ? _accentColor : _cardColor,
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent ? _bgColor : _accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  guide.instructions,
                                  style: TextStyle(
                                    color: isCurrent ? _accentColor : Colors.white,
                                    fontSize: 18,
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                                if (guide.distance > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '${guide.distance}m',
                                      style: TextStyle(
                                        color: _accentColor.withValues(alpha: 0.7),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
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
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: _accentColor, size: 36),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: _accentColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
