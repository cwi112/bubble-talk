import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import '../../presentation/chat_room/chat_room_binding.dart';
import '../../presentation/chat_room/chat_room_view.dart';
import '../../presentation/home/home_binding.dart';
import '../../presentation/home/home_view.dart';

abstract class Routes {
  static const home = '/';
  static const chatRoom = '/chat-room';
}

abstract class AppPages {
  static const initialRoute = Routes.home;

  static final List<GetPage> routes = [
    basePage(name: Routes.home, page: () => const HomeView(), binding: HomeBinding()),
    basePage(
      name: Routes.chatRoom,
      page: () => const ChatRoomView(),
      binding: ChatRoomBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
