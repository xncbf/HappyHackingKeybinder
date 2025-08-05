#!/bin/bash

echo "=== HappyHacking Keybinder 권한 문제 해결 스크립트 ==="
echo ""

# 1. 앱이 실행 중이면 종료
echo "1. 실행 중인 앱 종료..."
pkill -f HappyHackingKeybinder

# 2. 모든 관련 권한 리셋
echo "2. 모든 권한 리셋 (관리자 권한 필요)..."
sudo tccutil reset All com.happyhacking.keybinder
sudo tccutil reset Accessibility
sudo tccutil reset PostEvent

# 3. TCC 데이터베이스 캐시 정리
echo "3. TCC 캐시 정리..."
sudo killall tccd

# 4. 기존 앱 완전 제거
echo "4. 기존 앱 제거..."
rm -rf /Applications/HappyHackingKeybinder.app
rm -rf ~/Library/Application\ Support/HappyHackingKeybinder
rm -rf ~/Library/Preferences/com.happyhacking.keybinder.plist
rm -rf ~/Library/Caches/com.happyhacking.keybinder

# 5. 코드 서명 확인
echo "5. 코드 서명 상태 확인..."
if [ -f "HappyHackingKeybinder.app/Contents/MacOS/HappyHackingKeybinder" ]; then
    codesign -dv --verbose=4 HappyHackingKeybinder.app
    echo ""
    echo "서명 검증:"
    codesign --verify --deep --strict HappyHackingKeybinder.app
fi

echo ""
echo "=== 완료! ==="
echo ""
echo "이제 다음 단계를 수행하세요:"
echo "1. ./build.sh 실행하여 앱 다시 빌드"
echo "2. cp -r HappyHackingKeybinder.app /Applications/"
echo "3. 시스템 재시작 (중요!)"
echo "4. 재시작 후 앱 실행"
echo ""
echo "그래도 안 되면:"
echo "1. 시스템 환경설정 > 보안 및 개인 정보 보호 > 개인 정보 보호 > 손쉬운 사용"
echo "2. 좌측 하단 자물쇠 클릭하여 잠금 해제"
echo "3. HappyHackingKeybinder가 있으면 - 버튼으로 제거"
echo "4. + 버튼 클릭하여 /Applications/HappyHackingKeybinder.app 다시 추가"