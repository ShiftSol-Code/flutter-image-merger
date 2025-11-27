# Flutter 설치 및 실행 가이드

## 1. Flutter SDK 설치

### Windows에서 Flutter 설치하기

1. **Flutter SDK 다운로드**
   - https://docs.flutter.dev/get-started/install/windows 방문
   - "Get the Flutter SDK" 섹션에서 최신 안정 버전 다운로드
   - 또는 직접 다운로드: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip

2. **압축 해제**
   - 다운로드한 zip 파일을 원하는 위치에 압축 해제
   - 예: `C:\src\flutter`
   - ⚠️ `C:\Program Files\` 같은 권한이 필요한 폴더는 피하세요

3. **환경 변수 설정**
   - Windows 검색에서 "환경 변수" 검색
   - "시스템 환경 변수 편집" 클릭
   - "환경 변수" 버튼 클릭
   - "사용자 변수" 섹션에서 "Path" 선택 후 "편집" 클릭
   - "새로 만들기" 클릭하고 Flutter bin 경로 추가
     예: `C:\src\flutter\bin`
   - "확인" 클릭하여 모든 창 닫기

4. **PowerShell 재시작**
   - PowerShell을 완전히 닫고 다시 열기

5. **설치 확인**
   ```powershell
   flutter --version
   flutter doctor
   ```

6. **Windows 데스크톱 지원 활성화**
   ```powershell
   flutter config --enable-windows-desktop
   ```

## 2. 필수 도구 설치

`flutter doctor` 명령어 실행 후 누락된 항목 설치:

### Visual Studio (Windows 빌드용)
- Visual Studio 2022 Community Edition 다운로드
- "C++를 사용한 데스크톱 개발" 워크로드 선택하여 설치

## 3. 프로젝트 실행

### 의존성 설치
```powershell
cd d:\CodeTest\testFlutter
flutter pub get
```

### Windows에서 실행
```powershell
flutter run -d windows
```

### 또는 Visual Studio Code 사용
1. VS Code에서 프로젝트 폴더 열기
2. F5 키 누르기 또는 Run > Start Debugging

## 4. 문제 해결

### "flutter를 찾을 수 없습니다" 오류
- 환경 변수 Path에 Flutter bin 폴더가 제대로 추가되었는지 확인
- PowerShell을 재시작했는지 확인

### Windows 빌드 오류
```powershell
flutter doctor -v
```
위 명령어로 누락된 도구 확인 후 설치

### 의존성 오류
```powershell
flutter clean
flutter pub get
```

## 5. 앱 사용법

1. **이미지 선택**: "이미지 업로드" 버튼 클릭
2. **다중 선택**: Ctrl + 클릭으로 여러 이미지 선택
3. **자동 합치기**: 선택 즉시 세로로 합쳐진 이미지 표시
4. **확대/축소**: 마우스 휠 사용
5. **드래그 스크롤**: 마우스 클릭 후 드래그
6. **저장**: 상단 저장 버튼 클릭

## 참고 링크

- Flutter 공식 문서: https://docs.flutter.dev/
- Flutter Windows 설치: https://docs.flutter.dev/get-started/install/windows
- Flutter Desktop 지원: https://docs.flutter.dev/platform-integration/windows/building
