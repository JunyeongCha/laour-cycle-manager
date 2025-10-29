# Flutter Firebase Auth & Theme 템플릿

Flutter와 Firebase를 사용한 앱 개발을 빠르게 시작하기 위한 템플릿 프로젝트입니다.

## ✨ 포함된 기능

- Firebase 이메일/비밀번호 기반 회원가입 및 로그인
- 기기에 계정 정보 저장 및 자동 로그인 선택 기능
- 마이페이지
    - 내 정보 보기
    - 비밀번호 변경
    - 로그아웃
- 사용자별 테마 설정
    - 다크 모드 / 라이트 모드
    - 앱 기본 색상, 아이콘 색상 변경
    - 글자 크기 조절
    - 모든 설정은 Firebase에 사용자별로 저장 및 자동 로드

## 🚀 사용법

1. 이 저장소를 'Template'으로 사용하거나 클론하여 새 프로젝트를 시작합니다.
2. `pubspec.yaml` 파일의 `name`을 실제 프로젝트 이름으로 변경합니다.
3. **새로운 Firebase 프로젝트를 생성합니다.**
4. 터미널에서 `flutterfire configure` 명령어를 실행하여 새 Firebase 프로젝트와 이 앱을 연결합니다.
5. Firebase 콘솔에서 **Authentication (이메일/비밀번호)**과 **Firestore Database (테스트 모드)**를 활성화합니다.
6. `flutter pub get`을 실행합니다.
7. `lib/screens/home_screen.dart` 파일부터 원하는 앱의 실제 기능 개발을 시작합니다.