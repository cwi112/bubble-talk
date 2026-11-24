import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import '../../app/theme/app_theme.dart';
import '../../app/utils/chat_time.dart';
import '../../app/widgets/user_avatar.dart';
import 'chat_item.dart';
import 'chat_room_controller.dart';
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
        _InputBar(controller: controller),
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

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller});

  final ChatRoomController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller.input,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => controller.send(),
              decoration: InputDecoration(
                hintText: '메시지 입력',
                filled: true,
                fillColor: AppColors.chatBackground,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Obx(
            () => AnimatedScale(
              scale: controller.canSend.value ? 1 : 0.85,
              duration: const Duration(milliseconds: 150),
              child: IconButton.filled(
                tooltip: '보내기',
                onPressed: controller.canSend.value ? controller.send : null,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primaryLight,
                  fixedSize: const Size(44, 44),
                ),
                icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
