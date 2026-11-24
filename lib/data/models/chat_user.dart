import 'package:flutter/widgets.dart';

/// 채팅 사용자 (나 또는 친구)
class ChatUser {
  const ChatUser({
    required this.id,
    required this.name,
    this.statusMessage = '',
    this.color = const Color(0xFF2E9BF0),
  });

  final String id;
  final String name;
  final String statusMessage;

  /// 프로필 이미지 대신 쓰는 아바타 배경색
  final Color color;

  /// 아바타에 표시할 첫 글자
  String get initial => name.characters.first;
}
