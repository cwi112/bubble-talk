import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import '../../app/theme/app_theme.dart';
import '../../app/widgets/user_avatar.dart';
import '../../data/models/chat_user.dart';
import 'friends_controller.dart';
import 'widgets/profile_sheet.dart';

/// 친구 탭: 내 프로필 카드 + 친구 목록. 누르면 프로필 시트가 뜬다.
class FriendsTab extends GetView<FriendsController> {
  const FriendsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return PageStateBuilder(
      state: controller.pageState,
      onRetry: controller.load,
      success: (_) => Obx(
        () => ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            _MyProfileCard(user: controller.me, onTap: () => _showProfile(context, controller.me)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
              child: Row(
                children: [
                  const Text('친구', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  Text('${controller.friends.length}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
            ),
            for (final friend in controller.friends)
              _FriendTile(user: friend, onTap: () => _showProfile(context, friend)),
          ],
        ),
      ),
    );
  }

  void _showProfile(BuildContext context, ChatUser user) {
    ProfileSheet.show(
      context,
      user: user,
      isMe: user.id == controller.me.id,
      onChat: () => controller.startChat(user),
    );
  }
}

/// 상단 내 프로필: 하늘색 카드
class _MyProfileCard extends StatelessWidget {
  const _MyProfileCard({required this.user, required this.onTap});

  final ChatUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Material(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                  child: UserAvatar(user: user, size: 54),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 3),
                      Text(
                        user.statusMessage.isEmpty ? '상태 메시지를 입력해 보세요' : user.statusMessage,
                        style: const TextStyle(fontSize: 13, color: AppColors.textWeak),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.user, required this.onTap});

  final ChatUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        child: Row(
          children: [
            UserAvatar(user: user, size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  if (user.statusMessage.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(user.statusMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: AppColors.textWeak)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
