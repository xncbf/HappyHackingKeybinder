# HappyHacking Keybinder for macOS

macOS용 키보드 리매핑 유틸리티 - 모든 키보드에서 작동합니다!

## 주요 기능

- ✅ **모든 키보드** 지원 (USB, 블루투스, 내장 키보드)
- ✅ 왼쪽 Control 탭 → F16 (한/영 전환)
- ✅ 한글 입력 중 ` → ` (₩ 대신 백틱 유지)
- ✅ Shift + Esc → ~ (틸드)
- ✅ 메뉴바 상태 표시
- ✅ 활성화/비활성화 토글

## 시스템 요구사항

- macOS 11.0 (Big Sur) 이상
- 손쉬운 사용 권한 필요

## 🚀 간단 설치 가이드

### 1. 다운로드 및 설치

```bash
# 저장소 복제
git clone https://github.com/xncbf/HappyHackingKeybinder.git
cd HappyHackingKeybinder

# 설치 스크립트 실행
./install.sh

# 옵션 1 선택: App Bundle (권장)
```

또는 수동으로:
```bash
# 앱 빌드
./build.sh

# Applications 폴더에 설치
cp -r HappyHackingKeybinder.app /Applications/
```

### 2. 권한 설정 (중요! ⚠️)

앱을 처음 실행하면 권한을 요청합니다:

1. **앱 실행**
   - `/Applications/HappyHackingKeybinder.app` 더블 클릭
   - "확인되지 않은 개발자" 경고가 나타나면:
     - 시스템 환경설정 → 보안 및 개인 정보 보호 → 일반
     - "확인 없이 열기" 클릭

2. **손쉬운 사용 권한 부여**
   - 시스템 환경설정 → 보안 및 개인 정보 보호 → 개인 정보 보호 → 손쉬운 사용
   - 좌측 하단 자물쇠 클릭 (잠금 해제)
   - HappyHacking Keybinder 체크 ✓

3. **입력 모니터링 권한 부여** (요청 시)
   - 시스템 환경설정 → 보안 및 개인 정보 보호 → 개인 정보 보호 → 입력 모니터링
   - HappyHacking Keybinder 체크 ✓

## 💡 사용 방법

1. 앱 실행 후 메뉴바에서 키보드 아이콘 확인
   - **채워진 아이콘** (⌨️): 활성화됨
   - **윤곽선 아이콘**: 비활성화됨

2. 메뉴바 아이콘 클릭으로 활성화/비활성화 전환

3. 키 매핑 사용:
   - **한/영 전환**: 왼쪽 Control 키를 짧게 탭
   - **백틱 입력**: 한글 모드에서도 ` 키 그대로 입력
   - **틸드 입력**: Shift + Esc

## 🔧 문제 해결

### 권한 토글이 안 될 때

권한 설정에서 체크박스가 켜지지 않는 경우:

```bash
# 권한 복구 스크립트 실행
./deep_fix_permissions.sh

# Mac 재시작 (필수!)
```

### 그 외 문제

1. **메뉴바에 아이콘이 안 보일 때**
   - 앱이 실행 중인지 확인
   - Activity Monitor에서 HappyHackingKeybinder 검색

2. **키 매핑이 작동하지 않을 때**
   - 메뉴바 아이콘이 활성화 상태인지 확인
   - 권한이 모두 허용되었는지 확인
   - 앱 재시작

3. **"손상된 앱" 경고가 나올 때**
   ```bash
   # 격리 속성 제거
   xattr -cr /Applications/HappyHackingKeybinder.app
   ```

## 📝 키 매핑 상세

| 원래 키 | → | 변환 결과 | 설명 |
|---------|---|-----------|------|
| 왼쪽 Control (탭) | → | F16 | 한/영 전환 (0.2초 이내 탭) |
| 왼쪽 Control (홀드) | → | Control | 일반 Control 키로 동작 |
| ` (백틱) | → | ` | 한글 모드에서도 백틱 유지 |
| Shift + Esc | → | ~ | 틸드 문자 입력 |

## 🚨 자동 시작 설정 (선택사항)

1. 시스템 환경설정 → 사용자 및 그룹
2. 본인 계정 선택 → 로그인 항목
3. '+' 버튼 → HappyHackingKeybinder.app 추가

## 📜 라이센스

MIT License

## 🤝 기여하기

버그 리포트와 기능 제안은 [Issues](https://github.com/xncbf/HappyHackingKeybinder/issues)에 남겨주세요!