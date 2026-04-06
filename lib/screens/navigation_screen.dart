import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../model/route_info.dart';

class NavigationScreen extends StatefulWidget {
  final RouteInfo routeInfo;

  const NavigationScreen({Key? key, required this.routeInfo}) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final FlutterTts _tts = FlutterTts();
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _initTts();
    _speakCurrentInstruction();
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
    int totalKm = (widget.routeInfo.totalDistance / 1000).round();
    int totalMin = (widget.routeInfo.totalDuration / 60).round();
    await _tts.speak('총 거리 ${totalKm}킬로미터, 예상 시간 ${totalMin}분입니다.');
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2D45),
        title: const Text(
          '경로 안내',
          style: TextStyle(
            color: Color(0xFF00E5CC),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF00E5CC), size: 32),
      ),
      body: Column(
        children: [
          // 📊 요약 정보
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2D45),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF00E5CC), width: 3),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoChip(
                      icon: Icons.straighten,
                      label: '총 거리',
                      value: '${(widget.routeInfo.totalDistance / 1000).toStringAsFixed(1)} km',
                    ),
                    _buildInfoChip(
                      icon: Icons.access_time,
                      label: '예상 시간',
                      value: '${(widget.routeInfo.totalDuration / 60).round()} 분',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _speakSummary,
                  icon: const Icon(Icons.volume_up, size: 28),
                  label: const Text(
                    '요약 정보 듣기',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5CC),
                    foregroundColor: const Color(0xFF0D1B2A),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 📍 현재 안내
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5CC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  '🔊 현재 안내',
                  style: TextStyle(
                    color: Color(0xFF0D1B2A),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _currentStep < widget.routeInfo.guides.length
                      ? widget.routeInfo.guides[_currentStep].instructions
                      : '목적지에 도착했습니다!',
                  style: const TextStyle(
                    color: Color(0xFF0D1B2A),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _speakCurrentInstruction,
                  icon: const Icon(Icons.replay, size: 28),
                  label: const Text(
                    '다시 듣기',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D1B2A),
                    foregroundColor: const Color(0xFF00E5CC),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 📜 전체 경로 리스트
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2D45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: widget.routeInfo.guides.length,
                itemBuilder: (context, index) {
                  final guide = widget.routeInfo.guides[index];
                  final isCurrent = index == _currentStep;

                  return GestureDetector(
                    onTap: () {
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
                            ? const Color(0xFF00E5CC).withOpacity(0.2)
                            : const Color(0xFF0D1B2A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFF00E5CC)
                              : const Color(0xFF1B2D45),
                          width: 3,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: isCurrent
                                ? const Color(0xFF00E5CC)
                                : const Color(0xFF1B2D45),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: isCurrent
                                    ? const Color(0xFF0D1B2A)
                                    : const Color(0xFF00E5CC),
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
                                    color: isCurrent
                                        ? const Color(0xFF00E5CC)
                                        : Colors.white,
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
                                        color: const Color(0xFF00E5CC)
                                            .withOpacity(0.7),
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
        Icon(icon, color: const Color(0xFF00E5CC), size: 36),
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
            color: Color(0xFF00E5CC),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

