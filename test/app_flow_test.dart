import 'package:bubble_talk/data/mock/mock_chat_repository.dart';
import 'package:bubble_talk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late MockChatRepository repo;

  setUp(() {
    repo = MockChatRepository(
      loadDelay: const Duration(milliseconds: 100),
      readDelay: const Duration(milliseconds: 500),
      typingDelay: const Duration(milliseconds: 500),
    );
  });

  tearDown(() {
    repo.dispose();
    Get.reset();
  });

  Future<void> startApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.7;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(BubbleTalkApp(repository: repo));
    await tester.pump(const Duration(milliseconds: 200));
  }

  testWidgets('친구 목록 → 1:1 채팅 → 메시지 전송 → 자동 답장', (tester) async {
    await startApp(tester);

    // 친구 탭
    expect(find.text('정유나'), findsOneWidget);
    await tester.tap(find.text('정유나'));
    await tester.pumpAndSettle();

    // 프로필 시트 → 1:1 채팅
    await tester.tap(find.text('1:1 채팅'));
    await tester.pumpAndSettle();
    expect(find.text('정유나님과의 첫 대화를 시작해 보세요'), findsOneWidget);

    // 입력 전에는 보내기 버튼 비활성
    final sendButton = find.widgetWithIcon(IconButton, Icons.arrow_upward_rounded);
    expect(tester.widget<IconButton>(sendButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '안녕');
    await tester.pump();
    await tester.tap(sendButton);
    await tester.pump();

    expect(find.text('안녕'), findsOneWidget);
    expect(find.byIcon(Icons.done_rounded), findsOneWidget); // 아직 안 읽음

    // 상대가 읽고 입력 중
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(find.text('입력 중…'), findsOneWidget);
    expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);

    // 답장 도착
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('입력 중…'), findsNothing);
    expect(
      find.byWidgetPredicate((w) => w is Text && ['안녕! 반가워 👋', '하이~ 뭐 해?'].contains(w.data)),
      findsOneWidget,
    );
  });

  testWidgets('채팅 탭: 안 읽은 배지 → 채팅방에 들어가면 사라진다', (tester) async {
    await startApp(tester);

    await tester.tap(find.text('채팅').last);
    await tester.pumpAndSettle();

    // 김하늘 방: 안 읽은 2개 (목록 배지 + 하단 탭 배지)
    expect(find.text('2'), findsNWidgets(2));
    expect(find.text('토요일 2시 어때?'), findsOneWidget);

    await tester.tap(find.text('김하늘'));
    await tester.pumpAndSettle();
    expect(find.text('그럼 같이 전시 보러 갈래?'), findsOneWidget);

    Get.back();
    await tester.pumpAndSettle();
    expect(find.text('2'), findsNothing);
  });
}
