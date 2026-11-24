import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_starter_kit/getx_starter_kit.dart';

import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'data/mock/mock_chat_repository.dart';
import 'data/repositories/chat_repository.dart';

void main() {
  LoggerUtil.init();
  runApp(const BubbleTalkApp());
}

class BubbleTalkApp extends StatelessWidget {
  const BubbleTalkApp({super.key, this.repository});

  /// 테스트에서 다른 Repository 를 넣을 때 사용. 기본은 목업.
  final ChatRepository? repository;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '버블톡',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialBinding: AppBinding(repository),
      initialRoute: AppPages.initialRoute,
      getPages: AppPages.routes,
    );
  }
}

/// 앱 전체에서 공유하는 의존성. Firebase 로 바꿀 때는 이 한 줄만 바꾸면 된다.
class AppBinding extends BaseBinding {
  AppBinding([this.repository]);

  final ChatRepository? repository;

  @override
  void dependencies() {
    put<ChatRepository>(repository ?? MockChatRepository(), permanent: true);
  }
}
