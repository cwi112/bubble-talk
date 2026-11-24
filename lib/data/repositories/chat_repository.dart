// =============================================================================
// 채팅 데이터 접근 인터페이스
//
// 화면(Controller)은 이 추상 클래스만 알고, 실제 구현은 Binding 에서 주입한다.
// - 지금: MockChatRepository (메모리 + 자동 답장)
// - 나중: FirebaseChatRepository (Firestore) 를 같은 인터페이스로 구현해 교체
//
// 실시간으로 바뀌는 데이터(채팅방 목록, 메시지, 입력 중 표시)는 Stream 으로 제공한다.
// =============================================================================
import '../models/chat_room.dart';
import '../models/chat_user.dart';
import '../models/message.dart';

abstract class ChatRepository {
  /// 로그인한 나
  ChatUser get me;

  /// 친구 목록
  Future<List<ChatUser>> getFriends();

  /// 채팅방 목록. 최근 메시지 순으로 정렬되어 있고, 바뀔 때마다 새 목록이 흘러온다.
  Stream<List<ChatRoom>> watchRooms();

  /// 채팅방 하나의 메시지 목록 (오래된 순)
  Stream<List<Message>> watchMessages(String roomId);

  /// 상대방이 입력 중인지
  Stream<bool> watchTyping(String roomId);

  /// 상대방이 보낸 새 메시지가 도착할 때마다 하나씩 흘러온다. (알림용)
  Stream<Message> watchIncoming();

  /// 채팅방 정보
  ChatRoom? findRoom(String roomId);

  /// 친구와의 채팅방을 찾고, 없으면 만든다.
  Future<ChatRoom> openRoomWith(ChatUser friend);

  Future<void> sendMessage(String roomId, String text);

  /// 이 채팅방에서 상대가 보낸 메시지를 모두 읽음 처리
  Future<void> markAsRead(String roomId);
}
