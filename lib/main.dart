import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import 'app/routes/app_pages.dart';
import 'app/services/chat_notifier.dart';
import 'app/services/local_notification_service.dart';
import 'app/services/notification_service.dart';
import 'app/theme/app_theme.dart';
import 'data/mock/mock_chat_repository.dart';
import 'data/repositories/chat_repository.dart';

void main() {
  LoggerUtil.init();
  runApp(const BubbleTalkApp());
}

class BubbleTalkApp extends StatelessWidget {
  const BubbleTalkApp({super.key, this.repository, this.notifications});

  /// 테스트에서 다른 구현을 넣을 때 사용. 기본은 목업 채팅 + 로컬 알림.
  final ChatRepository? repository;
  final NotificationService? notifications;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '버블톡',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: AppBinding(repository: repository, notifications: notifications),
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.routes,
    );
  }
}

/// 앱 전체에서 공유하는 의존성. Firebase / FCM 으로 바꿀 때는 여기만 바꾸면 된다.
class AppBinding extends BaseBinding {
  AppBinding({this.repository, this.notifications});

  final ChatRepository? repository;
  final NotificationService? notifications;

  @override
  void dependencies() {
    final repo = put<ChatRepository>(repository ?? MockChatRepository(), permanent: true);
    final noti = put<NotificationService>(notifications ?? LocalNotificationService(), permanent: true);
    put(ChatNotifier(repo, noti), permanent: true);
  }
}
