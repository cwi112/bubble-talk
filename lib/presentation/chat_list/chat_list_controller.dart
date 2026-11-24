import 'dart:async';

import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import '../../app/routes/app_pages.dart';
import '../../data/models/chat_room.dart';
import '../../data/repositories/chat_repository.dart';

class ChatListController extends BaseController {
  ChatListController(this._repository);

  final ChatRepository _repository;

  final pageState = PageState.initial.obs;
  final rooms = <ChatRoom>[].obs;
  StreamSubscription<List<ChatRoom>>? _sub;

  /// 하단 탭 배지에 쓰는 전체 안 읽은 수
  int get totalUnread => rooms.fold(0, (sum, r) => sum + r.unreadCount);

  @override
  void onInit() {
    super.onInit();
    subscribe();
  }

  /// 채팅방 목록을 실시간으로 구독한다. 새 메시지가 오면 순서와 배지가 바로 바뀐다.
  void subscribe() {
    _sub?.cancel();
    setState(pageState, PageState.loading);
    _sub = _repository.watchRooms().listen(
      (list) {
        rooms.assignAll(list);
        setState(pageState, list.isEmpty ? PageState.empty : PageState.success);
      },
      onError: (Object e, StackTrace s) {
        logger.e('채팅방 목록 구독 실패', error: e, stackTrace: s);
        setState(pageState, PageState.failed);
      },
    );
  }

  void openRoom(ChatRoom room) => Get.toNamed(Routes.chatRoom, arguments: room.id);

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
