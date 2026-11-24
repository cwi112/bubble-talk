// =============================================================================
// 목업 데이터: 친구, 처음부터 있는 대화, 친구별 답장 문구
// =============================================================================
import 'package:flutter/widgets.dart';

import '../models/chat_user.dart';

abstract final class MockData {
  static const me = ChatUser(
    id: 'me',
    name: '나',
    statusMessage: 'Flutter 공부 중',
    color: Color(0xFF5B6CFF),
  );

  static const friends = [
    ChatUser(id: 'u1', name: '김하늘', statusMessage: '오늘도 화이팅 ☀️', color: Color(0xFFFF8A65)),
    ChatUser(id: 'u2', name: '이도윤', statusMessage: '운동 중 🏃', color: Color(0xFF26A69A)),
    ChatUser(id: 'u3', name: '박서연', statusMessage: '여행 가고 싶다', color: Color(0xFFAB47BC)),
    ChatUser(id: 'u4', name: '최민준', statusMessage: '커피 한 잔 ☕', color: Color(0xFF42A5F5)),
    ChatUser(id: 'u5', name: '정유나', statusMessage: '', color: Color(0xFFEC407A)),
  ];

  /// 앱을 켰을 때 이미 있는 대화. (친구 id, 보낸 사람이 나인지, 내용, 몇 분 전)
  /// 상대가 보낸 마지막 메시지 중 일부는 안 읽은 상태로 시작한다.
  static const seedConversations = <(String, bool, String, int)>[
    ('u1', false, '하늘이야! 주말에 뭐 해?', 60 * 26),
    ('u1', true, '아직 계획 없어', 60 * 26 - 3),
    ('u1', false, '그럼 같이 전시 보러 갈래?', 12),
    ('u1', false, '토요일 2시 어때?', 11),
    ('u2', true, '오늘 헬스장 갔어?', 60 * 3),
    ('u2', false, '응 하체 했어 😇 다리가 후들후들', 60 * 3 - 5),
    ('u3', false, '제주도 사진 보내줄게!', 60 * 24 * 3),
    ('u3', true, '오 좋아 기대할게', 60 * 24 * 3 - 2),
  ];

  /// 몇 개의 메시지를 안 읽은 상태로 시작할지 (친구 id → 개수)
  static const seedUnread = {'u1': 2};

  /// 친구별 말투가 담긴 기본 답장
  static const fallbackReplies = {
    'u1': ['오 진짜? ㅋㅋ', '좋아 좋아!', '그거 완전 내 스타일이야', '음 생각해 볼게~'],
    'u2': ['ㅇㅋ', '운동하고 연락할게 💪', '오 괜찮네', '그건 좀 애매한데 ㅋㅋ'],
    'u3': ['헐 대박', '나도 그 생각 했어!', '사진 보내줄게 📷', '언제 한번 같이 가자'],
    'u4': ['커피 마시면서 얘기하자 ☕', '좋은 생각이다', '그렇구나~', '오케이!'],
    'u5': ['응응', '알겠어 :)', 'ㅋㅋㅋㅋ', '나중에 자세히 얘기해 줘'],
  };
}
