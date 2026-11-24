import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import '../../app/theme/app_theme.dart';
import '../../app/utils/chat_time.dart';
import '../../app/widgets/user_avatar.dart';
import 'chat_item.dart';
import 'chat_room_controller.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/typing_bubble.dart';

class ChatRoomView extends BaseView<ChatRoomController> {
  const ChatRoomView({super.key, required this.roomId});

  final String roomId;

  /// Binding 에서 roomId 를 tag 로 등록했으므로 같은 tag 로 Controller 를 찾는다.
  @override
  String? get tag => roomId;

  @override
  Color? pageColor(BuildContext context) => AppColors.chatBackground;

  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(
        backgroundColor: AppColors.chatBackground,
        titleSpacing: 0,
        title: Row(
          children: [
            UserAvatar(user: controller.partner, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(controller.partner.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  Obx(() => Text(
                        controller.isTyping.value ? '입력 중…' : controller.partner.statusMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: controller.isTyping.value ? AppColors.primary : AppColors.textWeak,
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget body(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Obx(() {
            final items = controller.items;
            final typing = controller.isTyping.value;

            if (items.isEmpty && !typing) return _EmptyRoom(name: controller.partner.name);

            // reverse: 최신 메시지가 아래에 붙고, 키보드가 올라와도 마지막 메시지가 보인다.
            return ListView.builder(
              controller: controller.scroll,
              reverse: true,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              itemCount: items.length + (typing ? 1 : 0),
              itemBuilder: (_, i) {
                if (typing && i == 0) return TypingBubble(partner: controller.partner);
                final item = items[typing ? i - 1 : i];

                return switch (item) {
                  DateDividerItem(:final date) => _DateDivider(date: date),
                  MessageItem() => MessageBubble(item: item, partner: controller.partner),
                };
              },
            );
          }),
        ),
        // 입력창은 Controller 를 모르는 위젯. 필요한 값만 넘기고, canSend 가 바뀌면 Obx 가 다시 그린다.
        Obx(
          () => ChatInputBar(
            input: controller.input,
            canSend: controller.canSend.value,
            onSend: controller.send,
          ),
        ),
      ],
    );
  }
}

class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 14),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.textStrong.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(ChatTime.dateDivider(date), style: const TextStyle(fontSize: 12, color: AppColors.textWeak)),
      ),
    );
  }
}

class _EmptyRoom extends StatelessWidget {
  const _EmptyRoom({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.waving_hand_rounded, size: 44, color: AppColors.primary.withValues(alpha: 0.6)),
          const SizedBox(height: 12),
          Text('$name님과의 첫 대화를 시작해 보세요', style: const TextStyle(color: AppColors.textWeak)),
        ],
      ),
    );
  }
}
