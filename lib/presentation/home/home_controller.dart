import 'dart:async';

import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import '../../data/models/chat_room.dart';
import '../../data/repositories/chat_repository.dart';

enum HomeTab { friends, chats }

/// 홈(하단 탭) 화면 상태: 선택된 탭 + 채팅 탭 배지에 표시할 전체 안 읽은 수.
///
/// 배지 숫자를 다른 화면의 Controller(ChatListController)에서 빌려 오지 않고
/// Repository 를 직접 구독해 계산한다. → HomeView 는 HomeController 에만 의존한다.
class HomeController extends BaseController {
  HomeController(this._repository);

  final ChatRepository _repository;

  final tab = HomeTab.friends.obs;
  final totalUnread = 0.obs;

  StreamSubscription<List<ChatRoom>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = _repository.watchRooms().listen(
          (rooms) => totalUnread.value = rooms.fold(0, (sum, r) => sum + r.unreadCount),
        );
  }

  void changeTab(int index) => tab.value = HomeTab.values[index];

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}
