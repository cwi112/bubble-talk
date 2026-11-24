import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import '../../app/widgets/unread_badge.dart';
import '../chat_list/chat_list_tab.dart';
import '../friends/friends_tab.dart';
import 'home_controller.dart';

/// 하단 탭(친구 / 채팅)을 가진 첫 화면
class HomeView extends BaseView<HomeController> {
  const HomeView({super.key});

  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(
        title: Obx(() => Text(controller.tab.value == HomeTab.friends ? '친구' : '채팅')),
      );

  @override
  Widget? bottomNavigationBar(BuildContext context) => Obx(
        () => NavigationBar(
          selectedIndex: controller.tab.value.index,
          onDestinationSelected: controller.changeTab,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: '친구',
            ),
            NavigationDestination(
              icon: _withBadge(const Icon(Icons.chat_bubble_outline_rounded)),
              selectedIcon: _withBadge(const Icon(Icons.chat_bubble_rounded)),
              label: '채팅',
            ),
          ],
        ),
      );

  Widget _withBadge(Widget icon) => Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          Positioned(right: -10, top: -6, child: UnreadBadge(count: controller.totalUnread.value)),
        ],
      );

  @override
  Widget body(BuildContext context) {
    // IndexedStack: 탭을 바꿔도 각 탭의 스크롤 위치가 유지된다.
    return Obx(
      () => IndexedStack(
        index: controller.tab.value.index,
        children: const [FriendsTab(), ChatListTab()],
      ),
    );
  }
}
