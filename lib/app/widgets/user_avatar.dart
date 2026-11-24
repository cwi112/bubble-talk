import 'package:flutter/material.dart';

import '../../data/models/chat_user.dart';

/// 프로필 이미지 대신 이름 첫 글자를 보여주는 둥근 사각형 아바타
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = 48});

  final ChatUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: user.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(size * 0.38),
      ),
      child: Text(
        user.initial,
        style: TextStyle(color: user.color, fontWeight: FontWeight.w800, fontSize: size * 0.4),
      ),
    );
  }
}
