// =============================================================================
// 알림 표시 인터페이스
//
// - 지금: LocalNotificationService (flutter_local_notifications, 앱 안에서 직접 띄움)
// - 나중: FCM 푸시를 붙여도 화면 코드는 이 인터페이스만 쓰므로 바뀌지 않는다.
// =============================================================================
abstract class NotificationService {
  /// 알림 플러그인 준비. [onTap] 은 사용자가 알림을 눌렀을 때 payload 와 함께 호출된다.
  Future<void> init({required void Function(String payload) onTap});

  /// 알림 권한 요청 (Android 13+, iOS). 허용되면 true.
  Future<bool> requestPermission();

  Future<void> show({
    required int id,
    required String title,
    required String body,
    required String payload,
  });

  Future<void> cancel(int id);

  /// 앱이 꺼져 있다가 알림을 눌러서 켜졌다면 그 알림의 payload
  Future<String?> launchPayload();
}
