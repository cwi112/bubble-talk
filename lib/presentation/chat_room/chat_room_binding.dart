import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import '../../app/services/chat_notifier.dart';
import 'chat_room_controller.dart';

/// 이전 화면에서 Get.toNamed(Routes.chatRoom, arguments: roomId) 로 넘긴 채팅방 id 를 받는다.
///
/// roomId 를 tag 로 써서 채팅방마다 Controller 를 따로 만든다.
/// (알림을 눌러 A방 → B방으로 바로 바뀔 때 A방 Controller 가 재사용되지 않도록)
class ChatRoomBinding extends BaseBinding {
  @override
  void dependencies() {
    final roomId = Get.arguments as String;
    lazy(() => ChatRoomController(Get.find(), Get.find<ChatNotifier>(), roomId), tag: roomId);
  }
}
