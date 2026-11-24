// =============================================================================
// 목업 답장 생성기
//
// 받은 메시지에 키워드가 있으면 그에 맞는 답을, 없으면 친구별 기본 답장 중 하나를 고른다.
// Random 을 주입받아 테스트에서 결과를 고정할 수 있다.
// =============================================================================
import 'dart:math';

import 'mock_data.dart';

class MockReplyBot {
  MockReplyBot({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// (키워드 목록, 답장 후보) — 위에서부터 먼저 맞는 규칙을 쓴다.
  static const _rules = <(List<String>, List<String>)>[
    (['안녕', '하이', 'hi', 'hello'], ['안녕! 반가워 👋', '하이~ 뭐 해?']),
    (['밥', '점심', '저녁', '배고'], ['나도 배고파 🍚', '맛있는 거 먹자!', '오늘 메뉴 추천해 줘']),
    (['고마', '감사', 'thx', 'thanks'], ['천만에 😊', '별말씀을~']),
    (['미안', '죄송'], ['괜찮아 괜찮아', '신경 쓰지 마!']),
    (['ㅋㅋ', 'ㅎㅎ', '웃겨'], ['ㅋㅋㅋㅋㅋ', '나 지금 빵 터졌어 ㅋㅋ']),
    (['주말', '토요일', '일요일'], ['주말 좋지!', '주말엔 푹 쉬어야지']),
    (['잘자', '굿밤', '잘 자'], ['너도 잘 자 🌙', '굿밤~']),
  ];

  String replyTo(String friendId, String received) {
    final text = received.toLowerCase();

    for (final (keywords, replies) in _rules) {
      if (keywords.any(text.contains)) return _pick(replies);
    }

    if (text.trim().endsWith('?')) {
      return _pick(['음… 글쎄?', '좋은 질문이야 ㅋㅋ', '나도 잘 모르겠어']);
    }

    return _pick(MockData.fallbackReplies[friendId] ?? const ['응!']);
  }

  String _pick(List<String> list) => list[_random.nextInt(list.length)];
}
