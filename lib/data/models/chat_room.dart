import 'chat_user.dart';
import 'message.dart';

/// 1:1 채팅방. 목록 화면에 필요한 정보(마지막 메시지, 안 읽은 수)를 함께 담는다.
class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.partner,
    this.lastMessage,
    this.unreadCount = 0,
  });

  final String id;
  final ChatUser partner;
  final Message? lastMessage;

  /// 상대가 보냈는데 내가 아직 읽지 않은 메시지 수
  final int unreadCount;
}
