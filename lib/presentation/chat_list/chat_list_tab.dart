import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import '../../app/theme/app_theme.dart';
import '../../app/utils/chat_time.dart';
import '../../app/widgets/unread_badge.dart';
import '../../app/widgets/user_avatar.dart';
import '../../data/models/chat_room.dart';
import '../home/home_controller.dart';
import 'chat_list_controller.dart';

/// 채팅 탭: 최근 대화 순 채팅방 목록
class ChatListTab extends GetView<ChatListController> {
  const ChatListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return PageStateBuilder(
      state: controller.pageState,
      onRetry: controller.subscribe,
      empty: (_) => StateMessage(
        title: '아직 대화가 없어요',
        description: '친구 탭에서 대화를 시작해 보세요',
        retryText: '친구 보기',
        onRetry: () => Get.find<HomeController>().changeTab(HomeTab.friends.index),
      ),
      success: (_) => Obx(
        () => ListView.builder(
          padding: const EdgeInsets.only(top: 4),
          itemCount: controller.rooms.length,
          itemBuilder: (_, i) {
            final room = controller.rooms[i];
            return _RoomTile(room: room, onTap: () => controller.openRoom(room));
          },
        ),
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  const _RoomTile({required this.room, required this.onTap});

  final ChatRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final last = room.lastMessage;
    final hasUnread = room.unreadCount > 0;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            UserAvatar(user: room.partner, size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(room.partner.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(
                    last?.text ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: hasUnread ? AppColors.textStrong : AppColors.textWeak,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (last != null)
                  Text(ChatTime.listLabel(last.sentAt),
                      style: const TextStyle(fontSize: 12, color: AppColors.textWeak)),
                const SizedBox(height: 6),
                UnreadBadge(count: room.unreadCount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
