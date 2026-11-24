# 버블톡 (bubble_talk)

> GetX로 만든 1:1 채팅 앱. 지금은 **목업 데이터**로 동작하고, Repository만 바꾸면 Firebase로 옮길 수 있게 설계했습니다.

![Flutter](https://img.shields.io/badge/Flutter-3.50-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.14-0175C2?logo=dart)
![GetX](https://img.shields.io/badge/GetX-4.7-8A2BE2)
![tests](https://img.shields.io/badge/tests-16%20passed-brightgreen)

## 주요 기능

| 화면 | 기능 |
| --- | --- |
| 친구 | 내 프로필, 친구 목록, 프로필 시트에서 1:1 채팅 시작 |
| 채팅 목록 | 최근 대화 순 정렬, 마지막 메시지 미리보기, 시간 표시(오늘·어제·날짜), 안 읽은 수 배지, 하단 탭 전체 배지 |
| 채팅방 | 메시지 전송, 상대 자동 답장, 입력 중 표시, 읽음 표시, 날짜 구분선, 같은 분 연속 메시지 묶음, 새 메시지 자동 스크롤 |
| 알림 | 보고 있지 않은 채팅방에 답장이 오거나 앱이 백그라운드일 때 로컬 알림, 알림을 누르면 그 채팅방으로 이동, 같은 방 알림은 최신 하나로 갱신 |

상대방 답장은 `MockReplyBot`이 만듭니다. "안녕", "밥", "고마워" 같은 키워드에 맞춰 답하고, 키워드가 없으면 친구마다 다른 말투로 답합니다.

```
메시지 전송 ─▶ 0.8초 뒤 읽음 표시 + "입력 중…" ─▶ 1.5초 뒤 답장 도착
```

## 아키텍처

[getx_starter_kit](https://github.com/jjwwii/getx-starter-kit)의 `BaseView` / `BaseController` / `BaseBinding` / `PageState` 구조를 사용합니다.

```
View (BaseView) ──Obx──▶ Controller (BaseController) ──▶ ChatRepository (추상)
                                                          ├─ MockChatRepository  ← 현재
                                                          └─ FirebaseChatRepository ← 예정
```

- **Repository 인터페이스**: 화면은 `ChatRepository`만 알고, 실제 구현은 `AppBinding`에서 주입합니다. Firebase로 바꿀 때는 구현 클래스를 새로 만들고 그 한 줄만 바꾸면 됩니다.
- **알림도 인터페이스로 분리**: `NotificationService` 뒤에 `flutter_local_notifications` 구현을 두었습니다. 앱 전역 서비스 `ChatNotifier`가 "지금 보고 있는 채팅방"과 앱 상태(포그라운드/백그라운드)를 보고 알림을 띄울지 결정합니다. 나중에 FCM을 붙여도 화면 코드는 그대로입니다.
- **Stream 기반 실시간 갱신**: 채팅방 목록, 메시지, 입력 중 상태를 `Stream`으로 제공합니다. Firestore의 `snapshots()`와 같은 형태라 교체가 쉽습니다.
- **화면용 데이터 미리 계산**: `ChatItemBuilder`가 메시지 목록을 날짜 구분선과 말풍선 묶음(프로필·시간 표시 여부)으로 바꿉니다. 위젯은 그리기만 합니다.
- **테스트하기 쉬운 목업**: 현재 시각, 지연 시간, 난수를 주입받아서 테스트에서 시간과 답장을 제어합니다.

```
lib/
├── main.dart                     # 앱 시작, AppBinding(Repository 주입)
├── app/
│   ├── routes/                   # Routes, AppPages
│   ├── theme/                    # 색상, ThemeData
│   ├── utils/chat_time.dart      # "오후 3:12", "어제", 날짜 구분선 문구
│   ├── services/                 # NotificationService(인터페이스), LocalNotificationService, ChatNotifier
│   └── widgets/                  # UserAvatar, UnreadBadge
├── data/
│   ├── models/                   # ChatUser, ChatRoom, Message
│   ├── repositories/             # ChatRepository (인터페이스)
│   └── mock/                     # MockChatRepository, MockReplyBot, MockData
└── presentation/
    ├── home/                     # 하단 탭(친구 / 채팅)
    ├── friends/                  # 친구 탭 + 프로필 시트
    ├── chat_list/                # 채팅 목록 탭
    └── chat_room/                # 채팅방, ChatItemBuilder, 말풍선·입력 중 위젯
```

## 테스트

```bash
fvm flutter test   # 16개
```

| 대상 | 검증 내용 |
| --- | --- |
| `ChatTime` | 오전/오후 표기, 오늘·어제·올해·이전 해 구분, 요일 |
| `ChatItemBuilder` | 날짜 구분선, 같은 분 연속 메시지 묶음 |
| `MockReplyBot` | 키워드 답장, 친구별 기본 답장 |
| `MockChatRepository` | 정렬·안 읽은 수, 읽음 처리, 전송 → 읽음 → 입력 중 → 답장 순서, 빈 메시지 무시, 방 중복 생성 방지 |
| 화면 흐름 | 친구 → 1:1 채팅 → 전송 → 읽음·입력 중 → 답장 / 채팅 목록 배지가 방에 들어가면 사라짐 |
| 알림 | 방을 나온 뒤 답장 → 알림 → 누르면 그 방 열림 / 그 방을 보고 있으면 알림 없음 / 백그라운드면 알림 / 다른 방을 보다가 알림을 누르면 방 전환 |

## 실행

```bash
fvm flutter pub get
fvm flutter run
```

- Flutter 버전은 `.fvmrc`로 `stable`에 고정되어 있습니다.
- Android 빌드 기준: Gradle 9.5, AGP 9.3, Kotlin 2.4, Java 17, compileSdk 37 (flutter_local_notifications 요구), core library desugaring 사용
- 알림 확인 방법: 채팅방에서 메시지를 보내고 바로 뒤로 가거나 홈 버튼을 누르면 1~2초 뒤 알림이 옵니다. 처음 실행할 때 알림 권한을 허용해 주세요.

## 다음 단계

- [ ] Firebase Auth 로그인 · 회원가입
- [ ] `FirebaseChatRepository` (Firestore 실시간 메시지)
- [ ] 이미지 메시지
- [ ] 원격 푸시 알림 (FCM) — 앱이 완전히 꺼져 있을 때도 받기
