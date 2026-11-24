import 'dart:math';

import 'package:bubble_talk/app/utils/chat_time.dart';
import 'package:bubble_talk/data/mock/mock_chat_repository.dart';
import 'package:bubble_talk/data/mock/mock_data.dart';
import 'package:bubble_talk/data/mock/mock_reply_bot.dart';
import 'package:bubble_talk/data/models/message.dart';
import 'package:bubble_talk/presentation/chat_room/chat_item.dart';
import 'package:flutter_test/flutter_test.dart';

Message _msg(String sender, DateTime at, [String text = 'hi']) =>
    Message(id: '$sender$at', roomId: 'r', senderId: sender, text: text, sentAt: at);

void main() {
  group('ChatTime', () {
    final now = DateTime(2026, 11, 25, 15, 0);

    test('clock 은 오전/오후 12시간제', () {
      expect(ChatTime.clock(DateTime(2026, 1, 1, 0, 5)), '오전 12:05');
      expect(ChatTime.clock(DateTime(2026, 1, 1, 9, 7)), '오전 9:07');
      expect(ChatTime.clock(DateTime(2026, 1, 1, 12, 30)), '오후 12:30');
      expect(ChatTime.clock(DateTime(2026, 1, 1, 23, 59)), '오후 11:59');
    });

    test('listLabel 은 오늘/어제/올해/이전 해를 구분', () {
      expect(ChatTime.listLabel(DateTime(2026, 11, 25, 9, 0), now: now), '오전 9:00');
      expect(ChatTime.listLabel(DateTime(2026, 11, 24, 23, 0), now: now), '어제');
      expect(ChatTime.listLabel(DateTime(2026, 3, 2), now: now), '3월 2일');
      expect(ChatTime.listLabel(DateTime(2025, 12, 31), now: now), '2025. 12. 31.');
    });

    test('dateDivider 는 요일까지', () {
      expect(ChatTime.dateDivider(DateTime(2026, 11, 25)), '2026년 11월 25일 수요일');
    });
  });

  group('ChatItemBuilder', () {
    test('날짜가 바뀌면 구분선, 같은 분 연속 메시지는 묶는다', () {
      final d1 = DateTime(2026, 11, 24, 10, 0);
      final d2 = DateTime(2026, 11, 25, 10, 0);
      final items = ChatItemBuilder.build([
        _msg('u1', d1),
        _msg('u1', d1.add(const Duration(seconds: 10))),
        _msg('me', d1.add(const Duration(seconds: 20))),
        _msg('me', d2),
      ], 'me');

      expect(items.whereType<DateDividerItem>().length, 2);

      final msgs = items.whereType<MessageItem>().toList();
      // u1 의 두 메시지: 첫 번째만 프로필, 두 번째만 시간
      expect((msgs[0].showProfile, msgs[0].showTime), (true, false));
      expect((msgs[1].showProfile, msgs[1].showTime), (false, true));
      // 내 메시지는 다른 날이라 각각 독립
      expect(msgs[2].isMine, isTrue);
      expect((msgs[2].showTime, msgs[3].showTime), (true, true));
    });
  });

  group('MockReplyBot', () {
    final bot = MockReplyBot(random: Random(1));

    test('키워드에 맞는 답장을 고른다', () {
      expect(['안녕! 반가워 👋', '하이~ 뭐 해?'], contains(bot.replyTo('u1', '안녕하세요')));
      expect(['천만에 😊', '별말씀을~'], contains(bot.replyTo('u2', '고마워')));
    });

    test('키워드가 없으면 친구별 기본 답장', () {
      expect(MockData.fallbackReplies['u3'], contains(bot.replyTo('u3', '그렇구나')));
    });
  });

  group('MockChatRepository', () {
    MockChatRepository repo() => MockChatRepository(
          loadDelay: Duration.zero,
          readDelay: const Duration(milliseconds: 10),
          typingDelay: const Duration(milliseconds: 10),
        );

    test('시드 데이터: 최근 대화 순 정렬, 안 읽은 수', () async {
      final r = repo();
      final rooms = await r.watchRooms().first;

      expect(rooms.first.partner.id, 'u1'); // 가장 최근 대화
      expect(rooms.first.unreadCount, 2);
      expect(rooms.map((e) => e.partner.id), ['u1', 'u2', 'u3']);
      r.dispose();
    });

    test('markAsRead 하면 안 읽은 수가 0', () async {
      final r = repo();
      await r.markAsRead('room_u1');
      expect(r.findRoom('room_u1')!.unreadCount, 0);
      r.dispose();
    });

    test('보내면 → 상대가 읽고 → 입력 중 → 답장이 온다', () async {
      final r = repo();
      final room = await r.openRoomWith(MockData.friends[4]); // 대화가 없던 친구
      expect(room.lastMessage, isNull);

      final typing = <bool>[];
      final sub = r.watchTyping(room.id).listen(typing.add);

      await r.sendMessage(room.id, '  안녕  ');
      var messages = await r.watchMessages(room.id).first;
      expect(messages.single.text, '안녕'); // 앞뒤 공백 제거
      expect(messages.single.isRead, isFalse);

      await Future.delayed(const Duration(milliseconds: 60));
      messages = await r.watchMessages(room.id).first;

      expect(messages.length, 2);
      expect(messages.first.isRead, isTrue); // 상대가 읽음
      expect(messages.last.senderId, 'u5'); // 답장
      expect(typing, [false, true, false]);
      expect(r.findRoom(room.id)!.unreadCount, 1);

      await sub.cancel();
      r.dispose();
    });

    test('빈 메시지는 보내지 않는다', () async {
      final r = repo();
      await r.sendMessage('room_u1', '   ');
      expect((await r.watchMessages('room_u1').first).length, 4);
      r.dispose();
    });

    test('openRoomWith 는 이미 있는 방을 다시 만들지 않는다', () async {
      final r = repo();
      final a = await r.openRoomWith(MockData.friends[0]);
      final b = await r.openRoomWith(MockData.friends[0]);
      expect(a.id, b.id);
      expect(b.lastMessage, isNotNull);
      r.dispose();
    });
  });
}
