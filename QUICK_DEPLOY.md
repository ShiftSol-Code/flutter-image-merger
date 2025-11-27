# 빠른 배포 가이드

Flutter 없이 Windows에서 바로 실행 가능한 패키지를 만드는 방법입니다.

## 한 번에 배포 패키지 만들기

### 1단계: 스크립트 실행
```powershell
cd d:\CodeTest\testFlutter
.\create_package.ps1
```

이 스크립트가 자동으로:
- ✅ Release 빌드 생성
- ✅ 필요한 파일들 복사
- ✅ README.txt 생성
- ✅ ZIP 파일로 압축

### 2단계: 배포
생성된 `ImageMerger_Windows.zip` 파일을 사용자에게 전달하면 끝!

## 사용자 측 설치 방법

1. **다운로드**: ImageMerger_Windows.zip 받기
2. **압축 해제**: 원하는 위치에 압축 풀기
3. **실행**: image_merger.exe 더블클릭

**Flutter 설치 필요 없음!** 바로 실행 가능합니다.

## 수동 빌드 방법

스크립트를 사용하지 않으려면:

```powershell
# 1. Release 빌드
flutter build windows --release

# 2. 빌드 결과물 위치
cd build\windows\x64\runner\Release

# 3. 이 폴더 전체를 압축하여 배포
```

## 배포 패키지 내용

```
ImageMerger_Windows/
├── image_merger.exe       # 실행 파일
├── flutter_windows.dll    # Flutter 엔진
├── data/                  # 앱 데이터
└── README.txt             # 사용 설명서
```

## 시스템 요구사항

### 실행 환경
- Windows 10 이상 (64-bit)
- Visual C++ Redistributable (대부분 이미 설치됨)

### 필요 없는 것
- ❌ Flutter SDK
- ❌ 개발 도구
- ❌ 추가 설치 프로그램

## 문제 해결

### "VCRUNTIME140.dll 오류"
Visual C++ Redistributable 설치:
https://aka.ms/vs/17/release/vc_redist.x64.exe

### 자세한 정보
더 자세한 배포 가이드는 `DEPLOYMENT.md` 참조

---

**간단 요약**: `create_package.ps1` 실행 → `ImageMerger_Windows.zip` 배포 → 완료!
