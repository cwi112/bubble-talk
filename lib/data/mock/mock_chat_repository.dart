// =============================================================================
// 메모리에서 동작하는 ChatRepository 구현
//
// 내가 메시지를 보내면:
//   readDelay 뒤  → 상대가 읽음 (내 메시지 isRead = true), 입력 중 표시 시작
//   typingDelay 뒤 → 입력 중 표시 끝, MockReplyBot 이 만든 답장 도착
//
// 시간(now)과 지연 시간을 주입받아 테스트에서 시간을 다룰 수 있다.
// =============================================================================
import 'dart:async';

import '../models/chat_room.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../repositories/chat_repository.dart';
import 'mock_data.dart';
import 'mock_reply_bot.dart';

class MockChatRepository implements ChatRepository {
  MockChatRepository({
    MockReplyBot? replyBot,
    DateTime Function()? now,
    this.readDelay = const Duration(milliseconds: 800),
    this.typingDelay = const Duration(milliseconds: 1500),
    this.loadDelay = const Duration(milliseconds: 500),
    bool seed = true,
  })  : _bot = replyBot ?? MockReplyBot(),
        _now = now ?? DateTime.now {
    if (seed) _seed();
  }

  final MockReplyBot _bot;
  final DateTime Function() _now;

  final Duration readDelay;
  final Duration typingDelay;

  /// 서버에서 불러오는 것처럼 보이게 하는 첫 로딩 시간
  final Duration loadDelay;

  final Map<String, ChatUser> _partners = {}; // roomId → 상대
  final Map<String, List<Message>> _messages = {}; // roomId → 메시지(오래된 순)
  final Set<String> _typing = {};
  final _changes = StreamController<void>.broadcast();
  final List<Timer> _timers = [];
  int _seq = 0;

  @override
  ChatUser get me => MockData.me;

  // ---------------------------------------------------------------------------
  // 조회
  // ---------------------------------------------------------------------------
  @override
  Future<List<ChatUser>> getFriends() async {
    await Future.delayed(loadDelay);
    return List.of(MockData.friends);
  }

  @override
  Stream<List<ChatRoom>> watchRooms() async* {
    await Future.delayed(loadDelay);
    yield _rooms();
    yield* _changes.stream.map((_) => _rooms());
  }

  @override
  Stream<List<Message>> watchMessages(String roomId) async* {
    yield List.unmodifiable(_messages[roomId] ?? const []);
    yield* _changes.stream.map((_) => List.unmodifiable(_messages[roomId] ?? const []));
  }

  @override
  Stream<bool> watchTyping(String roomId) async* {
    yield _typing.contains(roomId);
    yield* _changes.stream.map((_) => _typing.contains(roomId)).distinct();
  }

  @override
  ChatRoom? findRoom(String roomId) {
    final partner = _partners[roomId];
    if (partner == null) return null;
    return _roomOf(roomId, partner);
  }

  // ---------------------------------------------------------------------------
  // 변경
  // ---------------------------------------------------------------------------
  @override
  Future<ChatRoom> openRoomWith(ChatUser friend) async {
    final roomId = _roomIdOf(friend);
    if (!_partners.containsKey(roomId)) {
      _partners[roomId] = friend;
      _messages[roomId] = [];
      _notify();
    }
    return findRoom(roomId)!;
  }

  @override
  Future<void> sendMessage(String roomId, String text) async {
    final partner = _partners[roomId];
    final trimmed = text.trim();
    if (partner == null || trimmed.isEmpty) return;

    _add(roomId, me.id, trimmed);

    // 상대가 읽고 → 입력하고 → 답장
    _later(readDelay, () {
      _setMyMessagesRead(roomId);
      _typing.add(roomId);
      _notify();

      _later(typingDelay, () {
        _typing.remove(roomId);
        _add(roomId, partner.id, _bot.replyTo(partner.id, trimmed));
      });
    });
  }

  @override
  Future<void> markAsRead(String roomId) async {
    final list = _messages[roomId];
    if (list == null) return;

    var changed = false;
    for (var i = 0; i < list.length; i++) {
      final m = list[i];
      if (!m.isMine(me.id) && !m.isRead) {
        list[i] = m.copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) _notify();
  }

  /// 예약된 자동 답장을 모두 취소하고 스트림을 닫는다.
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _changes.close();
  }

  // ---------------------------------------------------------------------------
  // 내부
  // ---------------------------------------------------------------------------
  String _roomIdOf(ChatUser friend) => 'room_${friend.id}';

  void _seed() {
    final now = _now();
    for (final friend in MockData.friends) {
      final seeds = MockData.seedConversations.where((c) => c.$1 == friend.id).toList();
      if (seeds.isEmpty) continue;

      final roomId = _roomIdOf(friend);
      _partners[roomId] = friend;
      final unread = MockData.seedUnread[friend.id] ?? 0;

      _messages[roomId] = [
        for (final (i, (_, mine, text, minutesAgo)) in seeds.indexed)
          Message(
            id: 'seed_${friend.id}_$i',
            roomId: roomId,
            senderId: mine ? me.id : friend.id,
            text: text,
            sentAt: now.subtract(Duration(minutes: minutesAgo)),
            // 마지막 unread 개는 안 읽은 상태
            isRead: mine || i < seeds.length - unread,
          ),
      ];
    }
  }

  void _add(String roomId, String senderId, String text) {
    _messages[roomId]!.add(Message(
      id: 'm${_seq++}',
      roomId: roomId,
      senderId: senderId,
      text: text,
      sentAt: _now(),
    ));
    _notify();
  }

  void _setMyMessagesRead(String roomId) {
    final list = _messages[roomId]!;
    for (var i = 0; i < list.length; i++) {
      if (list[i].isMine(me.id)) list[i] = list[i].copyWith(isRead: true);
    }
  }

  ChatRoom _roomOf(String roomId, ChatUser partner) {
    final list = _messages[roomId] ?? const <Message>[];
    return ChatRoom(
      id: roomId,
      partner: partner,
      lastMessage: list.isEmpty ? null : list.last,
      unreadCount: list.where((m) => !m.isMine(me.id) && !m.isRead).length,
    );
  }

  List<ChatRoom> _rooms() {
    final rooms = [
      for (final e in _partners.entries)
        if (_messages[e.key]!.isNotEmpty) _roomOf(e.key, e.value),
    ];
    rooms.sort((a, b) => b.lastMessage!.sentAt.compareTo(a.lastMessage!.sentAt));
    return rooms;
  }

  void _later(Duration delay, void Function() action) {
    _timers.add(Timer(delay, () {
      if (!_changes.isClosed) action();
    }));
  }

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }
}
