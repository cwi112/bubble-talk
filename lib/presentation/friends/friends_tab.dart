import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import '../../app/theme/app_theme.dart';
import '../../app/widgets/user_avatar.dart';
import '../../data/models/chat_user.dart';
import 'friends_controller.dart';

/// 친구 탭: 내 프로필 + 친구 목록. 친구를 누르면 프로필 시트가 뜬다.
class FriendsTab extends GetView<FriendsController> {
  const FriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return PageStateBuilder(
      state: controller.pageState,
      onRetry: controller.load,
      success: (_) => Obx(
        () => ListView(
          children: [
            _UserTile(user: controller.me, avatarSize: 58, onTap: () => _showProfile(context, controller.me)),
            const Divider(indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
              child: Text('친구 ${controller.friends.length}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textWeak, fontWeight: FontWeight.w600)),
            ),
            for (final friend in controller.friends)
              _UserTile(user: friend, onTap: () => _showProfile(context, friend)),
          ],
        ),
      ),
    );
  }

  void _showProfile(BuildContext context, ChatUser user) {
    final isMe = user.id == controller.me.id;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(user: user, size: 88),
              const SizedBox(height: 14),
              Text(user.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              if (user.statusMessage.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(user.statusMessage, style: const TextStyle(color: AppColors.textWeak)),
              ],
              const SizedBox(height: 28),
              if (!isMe)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(sheet).pop();
                      controller.startChat(user);
                    },
                    icon: const Icon(Icons.chat_bubble_rounded),
                    label: const Text('1:1 채팅'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.onTap, this.avatarSize = 46});

  final ChatUser user;
  final VoidCallback onTap;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        child: Row(
          children: [
            UserAvatar(user: user, size: avatarSize),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  if (user.statusMessage.isNotEmpty)
                    Text(user.statusMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: AppColors.textWeak)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
