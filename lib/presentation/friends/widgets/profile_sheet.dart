import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/user_avatar.dart';
import '../../../data/models/chat_user.dart';

/// 친구(또는 나)를 눌렀을 때 아래에서 올라오는 프로필 카드.
/// 화면의 약 60% 높이로, 위쪽은 그 사람의 색으로 칠한 배경, 가운데 큰 아바타.
class ProfileSheet extends StatelessWidget {
  const ProfileSheet({super.key, required this.user, required this.isMe, this.onChat});

  final ChatUser user;
  final bool isMe;
  final VoidCallback? onChat;

  static Future<void> show(BuildContext context, {required ChatUser user, required bool isMe, VoidCallback? onChat}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProfileSheet(user: user, isMe: isMe, onChat: onChat),
    );
  }

  static const _bannerHeight = 170.0;
  static const _avatarSize = 108.0;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.62;

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // 배경 배너 + 겹쳐 놓은 아바타
          SizedBox(
            height: _bannerHeight + _avatarSize / 2,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: _bannerHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [user.color.withValues(alpha: 0.55), user.color.withValues(alpha: 0.95)],
                    ),
                  ),
                ),
                // 손잡이
                Positioned(
                  top: 10,
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: IconButton(
                    tooltip: '닫기',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(_avatarSize * 0.42),
                    ),
                    child: UserAvatar(user: user, size: _avatarSize),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          if (user.statusMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.chatBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(user.statusMessage, style: const TextStyle(color: AppColors.textWeak)),
            )
          else
            const Text('상태 메시지가 없어요', style: TextStyle(color: AppColors.textWeak)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: isMe
                ? const Text('내 프로필', style: TextStyle(color: AppColors.textWeak))
                : SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onChat?.call();
                      },
                      icon: const Icon(Icons.chat_bubble_rounded),
                      label: const Text('1:1 채팅', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
