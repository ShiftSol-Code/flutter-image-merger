# Image Merger - 이미지 합치기 앱

Flutter로 만든 이미지 세로 합치기 앱입니다. 여러 이미지를 선택하여 세로로 합치고, 확대/축소 및 마우스 드래그로 스크롤할 수 있습니다.

## 주요 기능

✨ **다중 이미지 선택**: 여러 이미지를 한 번에 선택
🎯 **드래그 앤 드롭**: 파일 탐색기에서 이미지를 드래그하여 앱에 드롭
📐 **세로 합치기**: 선택한 이미지들을 자동으로 세로로 합침
🔍 **확대/축소**: 마우스 휠 또는 핀치 제스처로 줌
🖱️ **드래그 스크롤**: 마우스 클릭 드래그로 이미지 이동
💾 **사용자 지정 저장**: 저장 경로를 직접 선택 가능
🔄 **경로 유지**: 한 번 선택한 저장 경로는 앱 재시작 후에도 유지

## 필수 요구사항

1. **Flutter SDK 설치**
   - Windows: https://docs.flutter.dev/get-started/install/windows
   - Flutter 3.0.0 이상 필요

2. **Windows 개발 환경 설정**
   ```powershell
   flutter doctor
   ```
   위 명령어로 환경이 제대로 설정되었는지 확인하세요.

## 설치 및 실행

### 1. Flutter SDK 설치 확인
```powershell
flutter --version
```

### 2. 의존성 설치
```powershell
cd d:\CodeTest\testFlutter
flutter pub get
```

### 3. Windows에서 실행
```powershell
flutter run -d windows
```

또는 Visual Studio Code에서:
- F5 키를 누르거나
- Run > Start Debugging 선택

## 사용 방법

### 방법 1: 버튼으로 업로드
1. **이미지 업로드 버튼 클릭**
   - 여러 이미지를 선택 (Ctrl + 클릭으로 다중 선택)

### 방법 2: 드래그 앤 드롭
1. **파일 탐색기에서 이미지 선택**
2. **앱 창으로 드래그**
   - 드래그 중 파란색 테두리 표시
3. **앱 창에 드롭**
   - 자동으로 이미지 병합 시작
   
### 이미지 조작
- **마우스 휠**: 확대/축소
- **마우스 드래그**: 이미지 이동 (클릭 후 드래그)
- **핀치 제스처**: 터치스크린에서 확대/축소
   
### 저장
1. **저장 버튼 클릭**
2. **저장 위치 선택 다이얼로그**
   - 원하는 폴더와 파일명 지정
   - 이전에 선택한 폴더가 기본값으로 표시됨
3. **저장 완료**
   - 선택한 경로는 다음 저장 시에도 유지됨

## 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점
├── screens/
│   └── image_merger_screen.dart       # 메인 화면
├── services/
│   └── image_service.dart             # 이미지 처리 로직
└── widgets/
    └── image_viewer.dart              # 드래그 가능한 이미지 뷰어
```

## 사용된 패키지

- `file_picker`: 파일 선택 (Windows 지원)
- `desktop_drop`: 드래그 앤 드롭 기능
- `file_selector`: 저장 경로 선택 다이얼로그
- `shared_preferences`: 저장 경로 영구 저장
- `image`: 이미지 처리 및 합치기
- `path_provider`: 파일 저장 경로
- `path`: 경로 처리

## 문제 해결

### Flutter가 인식되지 않는 경우
1. Flutter SDK를 다운로드하여 설치
2. 환경 변수 PATH에 Flutter bin 폴더 추가
3. PowerShell을 재시작

### Windows 빌드 오류
```powershell
flutter config --enable-windows-desktop
flutter create --platforms=windows .
```

### 의존성 오류
```powershell
flutter clean
flutter pub get
```

## 배포 (Windows 독립 실행 파일)

### 빠른 배포
```powershell
.\create_package.ps1
```

이 스크립트가 자동으로:
- Release 빌드 생성
- 배포 패키지 생성 (ImageMerger_Windows.zip)
- README 파일 포함

### 배포 파일 사용
1. `ImageMerger_Windows.zip`을 다른 Windows PC에 전달
2. 압축 해제
3. `image_merger.exe` 실행
4. **Flutter 설치 없이 바로 사용 가능!**

자세한 내용은 [DEPLOYMENT.md](file:///d:/CodeTest/testFlutter/DEPLOYMENT.md) 또는 [QUICK_DEPLOY.md](file:///d:/CodeTest/testFlutter/QUICK_DEPLOY.md) 참조

## 라이선스

MIT License
