// =============================================================================
// 앱 아이콘 생성기
//
// Flutter 캔버스로 아이콘을 그려 assets/icon/ 에 PNG 로 저장한다.
// 테스트 러너를 렌더링 도구로 쓰는 것이며, 앱 테스트(test/)와는 별개다.
//
// 디자인: 하늘색 배경 위에 비눗방울처럼 반투명하고 테두리가 빛나는 말풍선,
//         그 안에 "입력 중" 점 세 개, 위로 떠오르는 작은 방울들.
//
// 실행:
//   fvm flutter test tool/generate_app_icon_test.dart
//   fvm dart run flutter_launcher_icons
//   git checkout -- ios/Runner.xcodeproj/project.pbxproj   (도구가 엉뚱한 설정을 바꿔서 되돌림)
//
// 만들어지는 파일 (1024 x 1024)
//   icon.png             iOS · Android 기본 아이콘 (배경 + 말풍선)
//   icon_foreground.png  Android 적응형 아이콘 전경 (투명 배경, 안전 영역 안에 말풍선)
//   icon_background.png  Android 적응형 아이콘 배경 (그라데이션)
// =============================================================================
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

const _size = 1024.0;

// 앱 테마와 같은 하늘색 계열 (lib/app/theme/app_theme.dart)
const _skyTop = Color(0xFF8ADBFF);
const _skyBottom = Color(0xFF2E9BF0);
const _white = Color(0xFFFFFFFF);

void main() {
  test('앱 아이콘 PNG 생성', () async {
    await _save('icon.png', (c) {
      _paintBackground(c);
      _paintGlyph(c, box: _size * 0.72);
    });
    await _save('icon_foreground.png', (c) => _paintGlyph(c, box: _size * 0.56));
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
        colors: [_skyTop, _skyBottom],
      ).createShader(rect),
  );
}

/// 100 x 100 좌표로 설계한 그림을 [box] 크기로 가운데에 그린다.
void _paintGlyph(Canvas canvas, {required double box}) {
  canvas.save();
  canvas.translate((_size - box) / 2, (_size - box) / 2);
  canvas.scale(box / 100);

  // 큰 비눗방울 말풍선: 동그란 몸통 + 왼쪽 아래 꼬리
  const center = Offset(44, 56);
  const radius = 34.0;
  final chat = Path.combine(
    PathOperation.union,
    Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    Path()..addPolygon(const [Offset(20, 74), Offset(12, 92), Offset(36, 86)], true),
  );


  // 반투명한 방울 안쪽 (가운데는 맑고 가장자리로 갈수록 하얗게)
  canvas.drawPath(
    chat,
    Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.15, -0.2),
        radius: 0.75,
        colors: [Color(0x1FFFFFFF), Color(0x59FFFFFF)],
      ).createShader(Rect.fromCircle(center: center, radius: radius)),
  );

  // 빛나는 테두리
  canvas.drawPath(
    chat,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeJoin = StrokeJoin.round
      ..color = _white,
  );

  // 방울 반사광: 왼쪽 위 호 + 작은 점
  _gloss(canvas, center, radius, width: 3.6);

  // 입력 중 점 세 개
  final dot = Paint()..color = _white;
  canvas.drawCircle(const Offset(30, 57), 5.2, dot);
  canvas.drawCircle(const Offset(44, 57), 5.2, dot);
  canvas.drawCircle(const Offset(58, 57), 5.2, dot);

  // 위로 떠오르는 작은 방울들
  _miniBubble(canvas, const Offset(83, 22), 10);
  _miniBubble(canvas, const Offset(91, 47), 5.5);
  _miniBubble(canvas, const Offset(67, 8), 4.5);

  canvas.restore();
}

/// 방울 안쪽 왼쪽 위의 반사광
void _gloss(Canvas canvas, Offset center, double radius, {required double width}) {
  final r = radius * 0.72;
  canvas.drawArc(
    Rect.fromCircle(center: center, radius: r),
    math.pi * 1.08,
    math.pi * 0.32,
    false,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width
      ..color = const Color(0xE6FFFFFF),
  );
  final spot = center + Offset.fromDirection(math.pi * 1.52, r);
  canvas.drawCircle(spot, width * 0.55, Paint()..color = const Color(0xE6FFFFFF));
}

void _miniBubble(Canvas canvas, Offset c, double r) {
  canvas.drawCircle(c, r, Paint()..color = const Color(0x33FFFFFF));
  canvas.drawCircle(
    c,
    r,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, r * 0.22)
      ..color = _white,
  );
  _gloss(canvas, c, r, width: math.max(1.2, r * 0.2));
}
