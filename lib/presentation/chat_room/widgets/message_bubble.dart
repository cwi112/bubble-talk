import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/utils/chat_time.dart';
import '../../../app/widgets/user_avatar.dart';
import '../../../data/models/chat_user.dart';
import '../chat_item.dart';

/// 말풍선 하나.
/// - 내 메시지: 오른쪽, 그라데이션 배경, 왼쪽에 시간과 읽음 표시
/// - 상대 메시지: 왼쪽, 흰 배경, 묶음의 첫 메시지에만 프로필과 이름
class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.item, required this.partner});

  final MessageItem item;
  final ChatUser partner;

  static const _avatarSize = 38.0;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.68;
    final m = item.message;

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: item.isMine ? AppColors.myBubble : null,
          color: item.isMine ? null : AppColors.partnerBubble,
          borderRadius: _radius(),
          boxShadow: item.isMine
              ? null
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 1))],
        ),
        child: Text(
          m.text,
          style: TextStyle(
            fontSize: 15,
            height: 1.35,
            color: item.isMine ? Colors.white : AppColors.textStrong,
          ),
        ),
      ),
    );

    final meta = item.showTime ? _Meta(time: m.sentAt, isMine: item.isMine, isRead: m.isRead) : null;

    return Padding(
      padding: EdgeInsets.only(top: item.showProfile ? 10 : 3),
      child: item.isMine
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [if (meta != null) meta, const SizedBox(width: 6), bubble],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.showProfile)
                  UserAvatar(user: partner, size: _avatarSize)
                else
                  const SizedBox(width: _avatarSize),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.showProfile)
                        Padding(
                          padding: const EdgeInsets.only(left: 2, bottom: 4),
                          child: Text(partner.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [Flexible(child: bubble), const SizedBox(width: 6), if (meta != null) meta],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  /// 보낸 쪽 모서리 하나만 덜 둥글게 해서 말풍선 꼬리처럼 보이게 한다.
  BorderRadius _radius() {
    const big = Radius.circular(18);
    const small = Radius.circular(4);
    if (item.isMine) {
      return BorderRadius.only(
        topLeft: big,
        bottomLeft: big,
        bottomRight: big,
        topRight: item.showProfile ? small : big,
      );
    }
    return BorderRadius.only(
      topRight: big,
      bottomLeft: big,
      bottomRight: big,
      topLeft: item.showProfile ? small : big,
    );
  }
}

/// 시간 + (내 메시지일 때) 읽음 표시
class _Meta extends StatelessWidget {
  const _Meta({required this.time, required this.isMine, required this.isRead});

  final DateTime time;
  final bool isMine;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final clock = Text(ChatTime.clock(time), style: const TextStyle(fontSize: 11, color: AppColors.textWeak));
    if (!isMine) return clock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          isRead ? Icons.done_all_rounded : Icons.done_rounded,
          size: 14,
          color: isRead ? AppColors.primary : AppColors.textWeak,
          semanticLabel: isRead ? '읽음' : '안 읽음',
        ),
        clock,
      ],
    );
  }
}
