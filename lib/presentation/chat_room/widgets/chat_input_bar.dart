import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';

/// 메시지 입력창 + 보내기 버튼.
///
/// Controller 를 직접 알지 않고 필요한 것만 받는다.
/// - [input]   입력 내용
/// - [canSend] 보내기 버튼 활성 여부 (상태가 바뀌면 부모가 다시 그려 준다)
/// - [onSend]  보내기 동작
class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.input,
    required this.canSend,
    required this.onSend,
  });

  final TextEditingController input;
  final bool canSend;
  final VoidCallback onSend;

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
              controller: input,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
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
          AnimatedScale(
            scale: canSend ? 1 : 0.85,
            duration: const Duration(milliseconds: 150),
            child: IconButton.filled(
              tooltip: '보내기',
              onPressed: canSend ? onSend : null,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primaryLight,
                fixedSize: const Size(44, 44),
              ),
              icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
