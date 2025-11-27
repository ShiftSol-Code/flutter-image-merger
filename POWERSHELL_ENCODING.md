# PowerShell 한글 깨짐 해결 방법

## 문제
PowerShell에서 한글이 깨져서 표시됨 (예: "諛고룷" 같은 문자)

## 해결 방법

### 방법 1: 스크립트 실행 전 명령어 실행 (임시)
```powershell
chcp 65001
.\create_package.ps1
```

### 방법 2: PowerShell 프로필 설정 (영구)
PowerShell을 열고:
```powershell
notepad $PROFILE
```

다음 내용 추가:
```powershell
chcp 65001 > $null
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
```

저장 후 PowerShell 재시작

### 방법 3: Windows Terminal 사용 (권장)
Microsoft Store에서 "Windows Terminal" 설치
- 기본적으로 UTF-8 지원
- 더 나은 한글 표시

## 설명
- `chcp 65001`: 콘솔 코드 페이지를 UTF-8(65001)로 변경
- 기본값은 949 (한국어 EUC-KR)
- UTF-8로 변경하면 한글이 올바르게 표시됨

## 확인
```powershell
chcp
```
출력: "현재 코드 페이지: 65001" 이면 성공
