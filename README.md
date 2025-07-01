# HappyHacking Keybinder for macOS

해피해킹 키보드 전용 가벼운 키 매핑 유틸리티

## 기능

- ✅ 해피해킹 키보드 자동 감지
- ✅ Left Control 단독 누르기 → F16 (한/영 전환)
- ✅ 한글 입력 모드에서 ₩ → ` 변환
- ✅ Shift + Esc → ~ (틸드)
- ✅ 메뉴바 상태 표시
- ✅ 다른 키보드 사용 시 자동 비활성화

## 지원 키보드

- Happy Hacking Keyboard Professional 2
- Happy Hacking Keyboard Professional Classic
- Happy Hacking Keyboard Professional Hybrid
- Happy Hacking Keyboard Professional Hybrid Type-S

## 시스템 요구사항

- macOS 11.0 (Big Sur) 이상
- 접근성 권한 필요

## 빌드 방법

```bash
# 프로젝트 디렉토리로 이동
cd HappyHackingKeybinder

# 빌드
swift build -c release

# 앱 실행
.build/release/HappyHackingKeybinder
```

## 설치

1. 빌드된 앱을 Applications 폴더로 복사
2. 처음 실행 시 접근성 권한 요청 승인
3. 로그인 시 자동 실행 설정 (선택사항)

## 사용법

1. 해피해킹 키보드를 연결하면 자동으로 활성화
2. 메뉴바 아이콘으로 상태 확인
3. Preferences에서 개별 매핑 on/off 가능

## 문제 해결

### 접근성 권한 문제
시스템 환경설정 > 보안 및 개인 정보 보호 > 개인 정보 보호 > 접근성에서 앱 권한 확인

### 키 매핑이 작동하지 않음
1. 메뉴바 아이콘 확인 (채워진 키보드 = 활성화)
2. 해피해킹 키보드가 제대로 연결되었는지 확인
3. 앱 재시작

## 라이선스

MIT License