// =============================================================================
// 채팅방 목록에 그릴 항목
//
// 메시지 목록을 화면용 항목으로 바꾸면서 다음을 미리 계산해 둔다.
// - 날짜가 바뀌는 곳에 날짜 구분선
// - 같은 사람이 같은 분에 연달아 보낸 메시지는 묶어서
//     첫 메시지에만 상대 프로필 · 이름 표시 (showProfile)
//     마지막 메시지에만 시간 · 읽음 표시 (showTime)
// =============================================================================
import '../../app/utils/chat_time.dart';
import '../../data/models/message.dart';

sealed class ChatItem {
  const ChatItem();
}

class DateDividerItem extends ChatItem {
  const DateDividerItem(this.date);

  final DateTime date;
}

class MessageItem extends ChatItem {
  const MessageItem({
    required this.message,
    required this.isMine,
    required this.showProfile,
    required this.showTime,
  });

  final Message message;
  final bool isMine;
  final bool showProfile;
  final bool showTime;
}

abstract final class ChatItemBuilder {
  /// [messages] 는 오래된 순. 결과도 오래된 순이다.
  static List<ChatItem> build(List<Message> messages, String myId) {
    final items = <ChatItem>[];

    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      final prev = i > 0 ? messages[i - 1] : null;
      final next = i < messages.length - 1 ? messages[i + 1] : null;

      if (prev == null || !ChatTime.isSameDay(prev.sentAt, m.sentAt)) {
        items.add(DateDividerItem(m.sentAt));
      }

      items.add(MessageItem(
        message: m,
        isMine: m.isMine(myId),
        showProfile: !_sameGroup(prev, m),
        showTime: !_sameGroup(m, next),
      ));
    }
    return items;
  }

  /// 같은 사람이 같은 분에 보낸 연속 메시지인지
  static bool _sameGroup(Message? a, Message? b) {
    if (a == null || b == null) return false;
    return a.senderId == b.senderId && ChatTime.isSameMinute(a.sentAt, b.sentAt);
  }
}
