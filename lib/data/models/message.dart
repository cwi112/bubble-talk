/// 채팅 메시지
class Message {
  const Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.isRead = false,
  });

  final String id;
  final String roomId;
  final String senderId;
  final String text;
  final DateTime sentAt;

  /// 받는 사람이 읽었는지 여부
  final bool isRead;

  bool isMine(String myId) => senderId == myId;

  Message copyWith({bool? isRead}) => Message(
        id: id,
        roomId: roomId,
        senderId: senderId,
        text: text,
        sentAt: sentAt,
        isRead: isRead ?? this.isRead,
      );
}
