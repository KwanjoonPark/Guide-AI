import 'package:flutter_test/flutter_test.dart';

import 'package:guide_ai/main.dart';

void main() {
  testWidgets('Home screen shows mode buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const GuideAIApp());

    expect(find.text('Guide AI'), findsOneWidget);
    expect(find.text('목적지 설정'), findsOneWidget);
    expect(find.text('자유 이동'), findsOneWidget);
  });
}
