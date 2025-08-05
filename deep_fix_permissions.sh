#!/bin/bash

echo "=== HappyHacking Keybinder 권한 심층 복구 스크립트 ==="
echo "⚠️  이 스크립트는 관리자 권한이 필요합니다."
echo ""

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1단계: 실행 중인 모든 프로세스 종료
echo -e "${YELLOW}1단계: 실행 중인 프로세스 종료...${NC}"
pkill -f HappyHackingKeybinder
killall HappyHackingKeybinder 2>/dev/null

# 2단계: 기존 앱 완전 제거
echo -e "${YELLOW}2단계: 기존 설치 제거...${NC}"
sudo rm -rf /Applications/HappyHackingKeybinder.app
rm -rf ~/Library/Application\ Support/HappyHackingKeybinder
rm -rf ~/Library/Preferences/com.happyhacking.keybinder.plist
rm -rf ~/Library/Caches/com.happyhacking.keybinder
rm -rf ~/Library/Saved\ Application\ State/com.happyhacking.keybinder.savedState

# 3단계: TCC 권한 완전 리셋
echo -e "${YELLOW}3단계: TCC 권한 리셋...${NC}"
sudo tccutil reset All com.happyhacking.keybinder
sudo tccutil reset Accessibility
sudo tccutil reset PostEvent
sudo tccutil reset ListenEvent
sudo tccutil reset AppleEvents

# 4단계: TCC 데이터베이스 캐시 정리
echo -e "${YELLOW}4단계: TCC 서비스 재시작...${NC}"
sudo killall tccd
sudo killall TCC

# 5단계: LaunchServices 데이터베이스 재구축
echo -e "${YELLOW}5단계: LaunchServices 데이터베이스 재구축...${NC}"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

# 6단계: cfprefsd 재시작
echo -e "${YELLOW}6단계: 설정 데몬 재시작...${NC}"
killall cfprefsd

# 7단계: 새로 빌드
echo -e "${YELLOW}7단계: 앱 새로 빌드...${NC}"
./build.sh

# 8단계: 코드 서명 검증
echo -e "${YELLOW}8단계: 코드 서명 검증...${NC}"
if [ -f "HappyHackingKeybinder.app/Contents/MacOS/HappyHackingKeybinder" ]; then
    echo "코드 서명 정보:"
    codesign -dv HappyHackingKeybinder.app 2>&1 | grep -E "Identifier|Authority"
    
    echo ""
    echo "서명 검증 결과:"
    if codesign --verify --deep --strict HappyHackingKeybinder.app 2>&1; then
        echo -e "${GREEN}✅ 코드 서명 검증 성공${NC}"
    else
        echo -e "${RED}❌ 코드 서명 검증 실패${NC}"
    fi
fi

# 9단계: 앱 설치
echo -e "${YELLOW}9단계: 앱 설치...${NC}"
cp -r HappyHackingKeybinder.app /Applications/
echo -e "${GREEN}✅ 설치 완료${NC}"

echo ""
echo -e "${GREEN}=== 스크립트 완료 ===${NC}"
echo ""
echo -e "${YELLOW}중요! 다음 단계를 반드시 수행하세요:${NC}"
echo "1. Mac을 재시작하세요 (매우 중요!)"
echo "2. 재시작 후:"
echo "   a. /Applications/HappyHackingKeybinder.app 실행"
echo "   b. 권한 요청이 나타나면 '열기' 클릭"
echo "   c. 시스템 환경설정 > 보안 및 개인 정보 보호 > 개인 정보 보호"
echo "   d. 손쉬운 사용에서 HappyHackingKeybinder 체크"
echo ""
echo -e "${YELLOW}그래도 토글이 안 되면:${NC}"
echo "1. 복구 모드로 재시작 (Command+R)"
echo "2. 터미널 열기"
echo "3. 다음 명령 실행:"
echo '   cd "/Volumes/Macintosh HD/Library/Application Support/com.apple.TCC/"'
echo "   rm TCC.db"
echo "   rm AdhocSignatureCache"
echo "4. 정상 재시작"