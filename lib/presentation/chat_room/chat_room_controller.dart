import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import '../../data/models/chat_user.dart';
import '../../data/models/message.dart';
import '../../data/repositories/chat_repository.dart';
import 'chat_item.dart';

class ChatRoomController extends BaseController {
  ChatRoomController(this._repository, this.roomId);

  final ChatRepository _repository;
  final String roomId;

  late final ChatUser partner;
  final messages = <Message>[].obs;
  final isTyping = false.obs;
  final canSend = false.obs;

  final input = TextEditingController();
  final scroll = ScrollController();

  final List<StreamSubscription<dynamic>> _subs = [];

  String get myId => _repository.me.id;

  /// 화면에 그릴 항목. ListView(reverse: true) 에 맞게 최신 항목이 앞에 온다.
  List<ChatItem> get items => ChatItemBuilder.build(messages, myId).reversed.toList();

  @override
  void onInit() {
    super.onInit();
    partner = _repository.findRoom(roomId)!.partner;

    input.addListener(() => canSend.value = input.text.trim().isNotEmpty);

    _subs
      ..add(_repository.watchMessages(roomId).listen(_onMessages))
      ..add(_repository.watchTyping(roomId).listen((v) => isTyping.value = v));
  }

  void _onMessages(List<Message> list) {
    final hadNew = list.length > messages.length;
    messages.assignAll(list);

    // 채팅방을 보고 있는 동안 도착한 상대 메시지는 바로 읽음 처리
    if (list.any((m) => !m.isMine(myId) && !m.isRead)) {
      _repository.markAsRead(roomId);
    }
    if (hadNew) _scrollToBottom();
  }

  Future<void> send() async {
    final text = input.text.trim();
    if (text.isEmpty) return;

    input.clear();
    await _repository.sendMessage(roomId, text);
  }

  /// reverse 리스트라서 맨 아래 = offset 0
  void _scrollToBottom() {
    if (!scroll.hasClients) return;
    scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  void onClose() {
    for (final s in _subs) {
      s.cancel();
    }
    input.dispose();
    scroll.dispose();
    super.onClose();
  }
}
