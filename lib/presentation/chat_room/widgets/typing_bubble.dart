import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/user_avatar.dart';
import '../../../data/models/chat_user.dart';

/// 상대가 입력 중일 때 보이는 점 세 개 말풍선
class TypingBubble extends StatefulWidget {
  const TypingBubble({super.key, required this.partner});

  final ChatUser partner;

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _anim =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          UserAvatar(user: widget.partner, size: 38),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.partnerBubble,
              borderRadius: BorderRadius.circular(18),
            ),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (_, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [for (var i = 0; i < 3; i++) _dot(i)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 점마다 시작 시점을 어긋나게 해서 차례로 튀어 오르게 한다.
  Widget _dot(int index) {
    final t = (_anim.value - index * 0.15) % 1.0;
    final lift = t < 0.3 ? (t / 0.3) : (t < 0.6 ? 1 - (t - 0.3) / 0.3 : 0.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: Transform.translate(
        offset: Offset(0, -4 * lift),
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: AppColors.textWeak.withValues(alpha: 0.5 + 0.5 * lift),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
