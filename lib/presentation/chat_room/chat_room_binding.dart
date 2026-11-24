import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import 'chat_room_controller.dart';

/// 이전 화면에서 Get.toNamed(Routes.chatRoom, arguments: roomId) 로 넘긴 채팅방 id 를 받는다.
class ChatRoomBinding extends BaseBinding {
  @override
  void dependencies() {
    lazy(() => ChatRoomController(Get.find(), Get.arguments as String));
  }
}
