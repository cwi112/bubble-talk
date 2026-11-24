// =============================================================================
// 앱 아이콘 생성기
//
// Flutter 캔버스로 아이콘을 그려 assets/icon/ 에 PNG 로 저장한다.
// 테스트 러너를 렌더링 도구로 쓰는 것이며, 앱 테스트(test/)와는 별개다.
//
// 실행:
//   fvm flutter test tool/generate_app_icon_test.dart
//   fvm dart run flutter_launcher_icons
//
// 만들어지는 파일 (1024 x 1024)
//   icon.png             iOS · Android 기본 아이콘 (배경 + 말풍선)
//   icon_foreground.png  Android 적응형 아이콘 전경 (투명 배경, 안전 영역 안에 말풍선)
//   icon_background.png  Android 적응형 아이콘 배경 (그라데이션)
// =============================================================================
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _size = 1024.0;

// 앱 테마와 같은 색 (lib/app/theme/app_theme.dart)
const _gradientStart = Color(0xFF7B8BFF);
const _gradientEnd = Color(0xFF4F5FF0);
const _primary = Color(0xFF5B6CFF);
const _backBubble = Color(0xFFC7CEFF);

void main() {
  test('앱 아이콘 PNG 생성', () async {
    await _save('icon.png', (c) {
      _paintBackground(c);
      _paintBubbles(c, box: _size * 0.66);
    });
    await _save('icon_foreground.png', (c) => _paintBubbles(c, box: _size * 0.5));
    await _save('icon_background.png', _paintBackground);
  });
}

Future<void> _save(String name, void Function(Canvas canvas) paint) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder, const Rect.fromLTWH(0, 0, _size, _size)));

  final image = await recorder.endRecording().toImage(_size.toInt(), _size.toInt());
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File('assets/icon/$name').writeAsBytesSync(bytes!.buffer.asUint8List());
}

void _paintBackground(Canvas canvas) {
  const rect = Rect.fromLTWH(0, 0, _size, _size);
  canvas.drawRect(
    rect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_gradientStart, _gradientEnd],
      ).createShader(rect),
  );
}

/// 100 x 100 좌표로 설계한 말풍선 그림을 [box] 크기로 가운데에 그린다.
void _paintBubbles(Canvas canvas, {required double box}) {
  canvas.save();
  canvas.translate((_size - box) / 2, (_size - box) / 2);
  canvas.scale(box / 100);

  // 뒤 말풍선 (오른쪽 위, 꼬리는 오른쪽 아래)
  final back = _bubble(
    RRect.fromLTRBR(40, 8, 94, 54, const Radius.circular(17)),
    tail: [const Offset(76, 46), const Offset(91, 66), const Offset(88, 40)],
  );
  canvas.drawPath(back, Paint()..color = _backBubble);

  // 앞 말풍선 (왼쪽 아래, 꼬리는 왼쪽 아래)
  final front = _bubble(
    RRect.fromLTRBR(6, 28, 78, 82, const Radius.circular(21)),
    tail: [const Offset(12, 66), const Offset(7, 95), const Offset(32, 78)],
  );

  // 앞 말풍선 그림자
  canvas.drawPath(
    front.shift(const Offset(0, 3)),
    Paint()
      ..color = const Color(0x332A2F8F)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
  );
  canvas.drawPath(front, Paint()..color = const Color(0xFFFFFFFF));

  // 입력 중 점 세 개 (가운데 점을 살짝 위로)
  final dot = Paint()..color = _primary;
  canvas.drawCircle(const Offset(26, 55), 6, dot);
  canvas.drawCircle(const Offset(42, 52), 6, dot);
  canvas.drawCircle(const Offset(58, 55), 6, dot);

  canvas.restore();
}

/// 둥근 몸통 + 삼각형 꼬리를 하나의 도형으로 합친다.
/// (그냥 이어 붙이면 겹치는 부분이 서로 지워져 구멍이 생긴다)
Path _bubble(RRect body, {required List<Offset> tail}) {
  final bodyPath = Path()..addRRect(body);
  final tailPath = Path()..addPolygon(tail, true);
  return Path.combine(PathOperation.union, bodyPath, tailPath);
}
