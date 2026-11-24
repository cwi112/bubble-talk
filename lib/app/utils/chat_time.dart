/// 채팅 화면용 날짜·시간 문구. intl 없이 한국어 형식으로 만든다.
abstract final class ChatTime {
  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  /// 말풍선 옆 시간: "오전 9:05", "오후 12:30"
  static String clock(DateTime t) {
    final period = t.hour < 12 ? '오전' : '오후';
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    return '$period $hour:${t.minute.toString().padLeft(2, '0')}';
  }

  /// 채팅방 목록의 시간: 오늘이면 시각, 어제면 "어제", 올해면 "11월 20일", 그 전이면 "2025. 11. 20."
  static String listLabel(DateTime t, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final day = _dateOnly(t);
    final diff = today.difference(day).inDays;

    if (diff == 0) return clock(t);
    if (diff == 1) return '어제';
    if (t.year == today.year) return '${t.month}월 ${t.day}일';
    return '${t.year}. ${t.month}. ${t.day}.';
  }

  /// 채팅방 안 날짜 구분선: "2026년 11월 25일 수요일"
  static String dateDivider(DateTime t) => '${t.year}년 ${t.month}월 ${t.day}일 ${_weekdays[t.weekday - 1]}요일';

  static bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isSameMinute(DateTime a, DateTime b) => isSameDay(a, b) && a.hour == b.hour && a.minute == b.minute;

  static DateTime _dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);
}
