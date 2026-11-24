import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import '../../app/routes/app_pages.dart';
import '../../data/models/chat_user.dart';
import '../../data/repositories/chat_repository.dart';

class FriendsController extends BaseController {
  FriendsController(this._repository);

  final ChatRepository _repository;

  final pageState = PageState.initial.obs;
  final friends = <ChatUser>[].obs;

  ChatUser get me => _repository.me;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    setState(pageState, PageState.loading);
    try {
      friends.assignAll(await _repository.getFriends());
      setState(pageState, friends.isEmpty ? PageState.empty : PageState.success);
    } catch (e, s) {
      logger.e('친구 목록 조회 실패', error: e, stackTrace: s);
      setState(pageState, PageState.failed);
    }
  }

  /// 친구와의 채팅방을 열고(없으면 만들고) 채팅 화면으로 이동
  Future<void> startChat(ChatUser friend) async {
    final room = await _repository.openRoomWith(friend);
    await Get.toNamed(Routes.chatRoom, arguments: room.id);
  }
}
