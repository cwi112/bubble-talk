import 'package:bubble_talk/app/services/notification_service.dart';

/// 실제 알림 대신 호출 기록만 남기는 테스트용 구현
class FakeNotificationService implements NotificationService {
  final shown = <({int id, String title, String body, String payload})>[];
  final cancelled = <int>[];
  bool permissionRequested = false;
  String? launchWith;

  void Function(String payload)? _onTap;

  /// 사용자가 알림을 누른 것처럼 흉내 낸다.
  void tap(String payload) => _onTap?.call(payload);

  @override
  Future<void> init({required void Function(String payload) onTap}) async => _onTap = onTap;

  @override
  Future<bool> requestPermission() async => permissionRequested = true;

  @override
  Future<void> show({required int id, required String title, required String body, required String payload}) async =>
      shown.add((id: id, title: title, body: body, payload: payload));

  @override
  Future<void> cancel(int id) async => cancelled.add(id);

  @override
  Future<String?> launchPayload() async => launchWith;
}
