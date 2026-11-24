import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import '../chat_list/chat_list_controller.dart';
import '../friends/friends_controller.dart';
import 'home_controller.dart';

/// 홈 화면과 그 안의 두 탭(친구, 채팅)이 쓰는 Controller 를 등록한다.
class HomeBinding extends BaseBinding {
  @override
  void dependencies() {
    lazy(() => HomeController());
    lazy(() => FriendsController(Get.find()));
    lazy(() => ChatListController(Get.find()));
  }
}
