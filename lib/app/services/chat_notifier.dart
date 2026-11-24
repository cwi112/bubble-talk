// =============================================================================
// 새 메시지 알림 담당 (앱 전역 서비스)
//
// 상대 메시지가 도착하면 아래 경우에만 알림을 띄운다.
//   - 앱이 백그라운드에 있을 때, 또는
//   - 앱은 켜져 있지만 그 채팅방을 보고 있지 않을 때
// 알림을 누르면 그 채팅방으로 이동한다.
// =============================================================================
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import '../../data/models/message.dart';
import '../../data/repositories/chat_repository.dart';
import '../routes/app_pages.dart';
import 'notification_service.dart';

class ChatNotifier extends GetxService with WidgetsBindingObserver {
  ChatNotifier(this._repository, this._notifications);

  final ChatRepository _repository;
  final NotificationService _notifications;

  StreamSubscription<Message>? _sub;
  bool _inForeground = true;

  /// 지금 화면에 열려 있는 채팅방 (없으면 null)
  String? activeRoomId;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _sub = _repository.watchIncoming().listen(_onIncoming);
    _start();
  }

  Future<void> _start() async {
    try {
      await _notifications.init(onTap: openRoom);
      await _notifications.requestPermission();

      // 꺼져 있던 앱을 알림으로 켰다면 첫 화면이 그려진 뒤 그 채팅방으로 이동
      final payload = await _notifications.launchPayload();
      if (payload != null) {
        await WidgetsBinding.instance.endOfFrame;
        openRoom(payload);
      }
    } catch (e, s) {
      LoggerUtil.instance.logger.w('알림 초기화 실패', error: e, stackTrace: s);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _inForeground = state == AppLifecycleState.resumed;
  }

  void _onIncoming(Message message) {
    final watching = _inForeground && activeRoomId == message.roomId;
    if (watching) return;

    final partner = _repository.findRoom(message.roomId)?.partner;
    if (partner == null) return;

    _notifications.show(
      id: _notificationId(message.roomId),
      title: partner.name,
      body: message.text,
      payload: message.roomId,
    );
  }

  /// 채팅방 화면이 열릴 때 호출. 그 방의 알림은 지운다.
  void enterRoom(String roomId) {
    activeRoomId = roomId;
    _notifications.cancel(_notificationId(roomId));
  }

  /// 채팅방 화면이 닫힐 때 호출
  void leaveRoom(String roomId) {
    if (activeRoomId == roomId) activeRoomId = null;
  }

  /// 알림을 눌렀을 때: 이미 그 방이면 그대로, 다른 방을 보고 있으면 바꿔서 연다.
  void openRoom(String roomId) {
    if (activeRoomId == roomId || _repository.findRoom(roomId) == null) return;

    if (activeRoomId != null) {
      // 채팅방 → 채팅방은 같은 경로라서 GetX 가 기본으로 막는다(preventDuplicates). 여기서는 허용.
      Get.offNamed(Routes.chatRoom, arguments: roomId, preventDuplicates: false);
    } else {
      Get.toNamed(Routes.chatRoom, arguments: roomId);
    }
  }

  /// 같은 방의 알림은 같은 id 를 써서 최신 메시지 하나로 덮어쓴다.
  int _notificationId(String roomId) => roomId.hashCode & 0x7fffffff;

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    super.onClose();
  }
}
