import 'package:getx_starter_kit/getx_starter_kit.dart';
import 'package:get/get.dart';

enum HomeTab { friends, chats }

class HomeController extends BaseController {
  final tab = HomeTab.friends.obs;

  void changeTab(int index) => tab.value = HomeTab.values[index];
}
