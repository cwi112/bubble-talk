import 'package:bubble_talk/data/mock/mock_chat_repository.dart';
import 'package:bubble_talk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'fake_notification_service.dart';

void main() {
  late MockChatRepository repo;
  late FakeNotificationService notifications;

  setUp(() {
    repo = MockChatRepository(
      loadDelay: const Duration(milliseconds: 100),
      readDelay: const Duration(milliseconds: 500),
      typingDelay: const Duration(milliseconds: 500),
    );
    notifications = FakeNotificationService();
  });

  tearDown(() {
    repo.dispose();
    Get.reset();
  });

  Future<void> startApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.7;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(BubbleTalkApp(repository: repo, notifications: notifications));
    await tester.pump(const Duration(milliseconds: 200));
  }

  /// 친구 탭에서 친구를 눌러 1:1 채팅방에 들어간다.
  Future<void> openChatWith(WidgetTester tester, String name) async {
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1:1 채팅'));
    await tester.pumpAndSettle();
  }

  Future<void> send(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump();
    await tester.tap(find.widgetWithIcon(IconButton, Icons.arrow_upward_rounded));
    await tester.pump();
  }

  testWidgets('친구 목록 → 1:1 채팅 → 메시지 전송 → 자동 답장', (tester) async {
    await startApp(tester);
    expect(notifications.permissionRequested, isTrue);

    await openChatWith(tester, '정유나');
    expect(find.text('정유나님과의 첫 대화를 시작해 보세요'), findsOneWidget);

    // 입력 전에는 보내기 버튼 비활성
    final sendButton = find.widgetWithIcon(IconButton, Icons.arrow_upward_rounded);
    expect(tester.widget<IconButton>(sendButton).onPressed, isNull);

    await send(tester, '안녕');
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

    // 그 방을 보고 있었으므로 알림은 없다
    expect(notifications.shown, isEmpty);
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

  group('알림', () {
    testWidgets('채팅방을 나온 뒤 답장이 오면 알림을 띄우고, 누르면 그 방으로 이동', (tester) async {
      await startApp(tester);
      await openChatWith(tester, '정유나');
      await send(tester, '고마워');

      // 답장 오기 전에 채팅방을 나간다
      Get.back();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(notifications.shown, hasLength(1));
      final n = notifications.shown.single;
      expect(n.title, '정유나');
      expect(['천만에 😊', '별말씀을~'], contains(n.body));
      expect(n.payload, 'room_u5');

      // 알림을 누르면 그 채팅방이 열린다
      notifications.tap(n.payload);
      await tester.pumpAndSettle();
      expect(find.text('고마워'), findsOneWidget);
      // 방에 들어가면 그 방 알림은 지운다
      expect(notifications.cancelled, contains(n.id));
    });

    testWidgets('그 방을 보고 있어도 앱이 백그라운드면 알림을 띄운다', (tester) async {
      await startApp(tester);
      await openChatWith(tester, '최민준');
      await send(tester, '밥 먹었어?');

      // 홈 버튼을 누른 것처럼: resumed → inactive → hidden → paused
      for (final s in [AppLifecycleState.inactive, AppLifecycleState.hidden, AppLifecycleState.paused]) {
        tester.binding.handleAppLifecycleStateChanged(s);
      }
      await tester.pump(const Duration(seconds: 1));

      expect(notifications.shown.single.title, '최민준');

      // 다시 앱으로 돌아오기: paused → hidden → inactive → resumed
      for (final s in [AppLifecycleState.hidden, AppLifecycleState.inactive, AppLifecycleState.resumed]) {
        tester.binding.handleAppLifecycleStateChanged(s);
      }
      await tester.pumpAndSettle();
    });

    testWidgets('다른 방을 보는 중에 알림을 누르면 그 방으로 바뀐다', (tester) async {
      await startApp(tester);
      await openChatWith(tester, '정유나');

      notifications.tap('room_u1'); // 김하늘 방 알림
      await tester.pumpAndSettle();

      expect(find.text('토요일 2시 어때?'), findsOneWidget);
      expect(find.text('정유나님과의 첫 대화를 시작해 보세요'), findsNothing);

      // 뒤로 가면 채팅방이 아니라 홈
      Get.back();
      await tester.pumpAndSettle();
      expect(find.text('친구 5'), findsOneWidget);
    });
  });
}
