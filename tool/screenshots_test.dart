// =============================================================================
// 화면 스크린샷 생성기 (디자인 확인용)
//
// 테스트 렌더러로 주요 화면을 그려 build/screenshots/*.png 로 저장한다.
// 기본 테스트 폰트는 글자가 네모로 나오므로, Windows 의 맑은 고딕과
// Flutter SDK 의 Material 아이콘 폰트를 불러와 실제 화면과 비슷하게 만든다.
// (이모지는 색 없이 나올 수 있다)
//
// 실행: fvm flutter test tool/screenshots_test.dart
// =============================================================================
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bubble_talk/data/mock/mock_chat_repository.dart';
import 'package:bubble_talk/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../test/fake_notification_service.dart';

final _boundary = GlobalKey();
const _out = 'build/screenshots';

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    final file = File(p);
    if (file.existsSync()) loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.runAsync(() async {
    final boundary = _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    File('$_out/$name.png')
      ..createSync(recursive: true)
      ..writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void main() {
  setUpAll(() async {
    final sdk = '${Platform.environment['USERPROFILE']}/fvm/versions/stable/bin/cache/artifacts/material_fonts';
    // 앱 기본 글꼴(Roboto 자리)에 맑은 고딕을 넣어 한글이 보이게 한다.
    for (final family in ['Roboto', 'FlutterTest']) {
      await _loadFont(family, ['C:/Windows/Fonts/malgun.ttf', 'C:/Windows/Fonts/malgunbd.ttf']);
    }
    await _loadFont('MaterialIcons', ['$sdk/materialicons-regular.otf']);
  });

  testWidgets('주요 화면 스크린샷', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final repo = MockChatRepository(
      loadDelay: const Duration(milliseconds: 10),
      readDelay: const Duration(milliseconds: 300),
      typingDelay: const Duration(milliseconds: 300),
    );
    addTearDown(repo.dispose);

    await tester.pumpWidget(RepaintBoundary(
      key: _boundary,
      child: BubbleTalkApp(repository: repo, notifications: FakeNotificationService()),
    ));
    await tester.pumpAndSettle();
    await _shot(tester, '1_friends');

    // 프로필 시트
    await tester.tap(find.text('김하늘'));
    await tester.pumpAndSettle();
    await _shot(tester, '2_profile');
    await tester.tapAt(const Offset(10, 10)); // 시트 닫기
    await tester.pumpAndSettle();

    // 채팅 목록
    await tester.tap(find.text('채팅').last);
    await tester.pumpAndSettle();
    await _shot(tester, '3_chat_list');

    // 채팅방: 메시지를 보내고 입력 중 상태 + 답장 후 상태
    await tester.tap(find.text('김하늘'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '좋아! 토요일 2시에 보자');
    await tester.pump();
    await tester.tap(find.widgetWithIcon(IconButton, Icons.arrow_upward_rounded));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 100));
    await _shot(tester, '4_chat_typing');

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    await _shot(tester, '5_chat_room');

    // 새 대화 (빈 채팅방)
    Get.back();
    await tester.pumpAndSettle();
    await tester.tap(find.text('친구').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('정유나'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1:1 채팅'));
    await tester.pumpAndSettle();
    await _shot(tester, '6_empty_room');

    Get.reset();
  });
}
