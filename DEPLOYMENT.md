# Windows 배포 가이드

Flutter 앱을 Windows에서 독립 실행 가능한 패키지로 배포하는 방법입니다.

## 1. Release 빌드 생성

### 빌드 명령어
```powershell
cd d:\CodeTest\testFlutter
flutter build windows --release
```

이 명령어는 다음을 생성합니다:
- 최적화된 실행 파일
- 필요한 모든 DLL 파일
- 데이터 파일들

### 빌드 결과물 위치
```
d:\CodeTest\testFlutter\build\windows\x64\runner\Release\
```

## 2. 배포 패키지 구성

Release 폴더에 포함된 모든 파일:

```
Release/
├── image_merger.exe          # 실행 파일
├── flutter_windows.dll       # Flutter 엔진
├── data/                     # Flutter 자산
│   ├── icudtl.dat
│   ├── flutter_assets/
│   └── app.so
└── *.dll                     # 기타 필요한 DLL들
```

## 3. 배포 방법

### 방법 1: 폴더 전체 복사
1. `Release` 폴더 전체를 압축 (ZIP)
2. 다른 Windows PC에 압축 해제
3. `image_merger.exe` 실행

### 방법 2: 설치 프로그램 생성 (선택사항)
Inno Setup 또는 NSIS를 사용하여 설치 프로그램 생성 가능

## 4. 시스템 요구사항

### 최소 요구사항
- Windows 10 이상 (64-bit)
- Visual C++ Redistributable (자동 설치됨)

### 필요 없는 것
- ❌ Flutter SDK
- ❌ Dart SDK
- ❌ Visual Studio
- ❌ 개발 도구

## 5. 배포 패키지 생성 스크립트

아래 스크립트를 사용하면 자동으로 배포 패키지를 생성할 수 있습니다:

### create_package.ps1
```powershell
# Release 빌드
Write-Host "Building release version..." -ForegroundColor Green
flutter build windows --release

# 배포 폴더 생성
$deployDir = "ImageMerger_Windows"
if (Test-Path $deployDir) {
    Remove-Item $deployDir -Recurse -Force
}
New-Item -ItemType Directory -Path $deployDir

# 파일 복사
Write-Host "Copying files..." -ForegroundColor Green
Copy-Item "build\windows\x64\runner\Release\*" -Destination $deployDir -Recurse

# README 생성
@"
# Image Merger - 이미지 합치기

## 실행 방법
1. image_merger.exe를 더블클릭하여 실행

## 사용 방법
1. 이미지 업로드 버튼 클릭 또는 파일을 드래그 앤 드롭
2. 자동으로 이미지가 세로로 합쳐집니다
3. 마우스 휠로 확대/축소, 드래그로 이동
4. 저장 버튼으로 원하는 위치에 저장

## 시스템 요구사항
- Windows 10 이상 (64-bit)

## 문의
문제가 발생하면 개발자에게 문의하세요.
"@ | Out-File -FilePath "$deployDir\README.txt" -Encoding UTF8

# ZIP 압축
Write-Host "Creating ZIP package..." -ForegroundColor Green
Compress-Archive -Path $deployDir -DestinationPath "ImageMerger_Windows.zip" -Force

Write-Host "Deployment package created: ImageMerger_Windows.zip" -ForegroundColor Cyan
Write-Host "Package size: $((Get-Item ImageMerger_Windows.zip).Length / 1MB) MB" -ForegroundColor Cyan
```

## 6. 배포 체크리스트

- [ ] Release 빌드 완료
- [ ] 모든 필요한 파일 포함 확인
- [ ] 다른 Windows PC에서 테스트
- [ ] 드래그 앤 드롭 기능 테스트
- [ ] 저장 경로 선택 기능 테스트
- [ ] README.txt 포함
- [ ] ZIP 파일 생성

## 7. 배포 후 사용자 안내

사용자에게 전달할 내용:

1. **다운로드**: ImageMerger_Windows.zip 다운로드
2. **압축 해제**: 원하는 위치에 압축 해제
3. **실행**: image_merger.exe 더블클릭
4. **사용**: 
   - 이미지 업로드 또는 드래그 앤 드롭
   - 마우스 휠로 확대/축소
   - 저장 버튼으로 저장

## 8. 문제 해결

### "VCRUNTIME140.dll을 찾을 수 없습니다" 오류
- Visual C++ Redistributable 설치 필요
- https://aka.ms/vs/17/release/vc_redist.x64.exe

### 앱이 실행되지 않음
- Windows Defender 또는 백신 프로그램 확인
- 관리자 권한으로 실행 시도

### 드래그 앤 드롭이 작동하지 않음
- 관리자 권한으로 실행된 앱에서는 일반 권한 파일 탐색기에서 드래그 불가
- 둘 다 같은 권한 레벨에서 실행 필요

## 9. 업데이트 배포

새 버전 배포 시:
1. `pubspec.yaml`에서 버전 번호 증가
2. Release 빌드 재생성
3. 새 ZIP 파일 생성
4. 사용자에게 배포

## 10. 라이선스 및 저작권

배포 시 포함할 라이선스 정보:
- Flutter 라이선스 (BSD-3-Clause)
- 사용된 패키지들의 라이선스
- 앱 자체의 라이선스
