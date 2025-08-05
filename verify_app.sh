#!/bin/bash

echo "=== HappyHacking Keybinder 앱 검증 ==="
echo ""

# 앱 경로
APP_PATH="/Applications/HappyHackingKeybinder.app"
BUILD_APP="HappyHackingKeybinder.app"

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "1. 빌드된 앱 정보:"
if [ -d "$BUILD_APP" ]; then
    echo "Bundle ID:"
    /usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$BUILD_APP/Contents/Info.plist"
    
    echo ""
    echo "코드 서명:"
    codesign -dv "$BUILD_APP" 2>&1 | grep -E "Identifier|Signature|Authority"
    
    echo ""
    echo "Entitlements:"
    codesign -d --entitlements - "$BUILD_APP" 2>&1
else
    echo -e "${RED}빌드된 앱을 찾을 수 없습니다.${NC}"
fi

echo ""
echo "2. 설치된 앱 정보:"
if [ -d "$APP_PATH" ]; then
    echo "Bundle ID:"
    /usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP_PATH/Contents/Info.plist"
    
    echo ""
    echo "코드 서명:"
    codesign -dv "$APP_PATH" 2>&1 | grep -E "Identifier|Signature|Authority"
    
    echo ""
    echo "권한 상태:"
    echo -n "Accessibility: "
    if sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" "SELECT allowed FROM access WHERE service='kTCCServiceAccessibility' AND client='com.happyhacking.keybinder';" 2>/dev/null | grep -q 1; then
        echo -e "${GREEN}허용됨${NC}"
    else
        echo -e "${RED}거부됨 또는 없음${NC}"
    fi
else
    echo -e "${RED}설치된 앱을 찾을 수 없습니다.${NC}"
fi

echo ""
echo "3. 실행 중인 프로세스:"
if pgrep -f HappyHackingKeybinder > /dev/null; then
    echo -e "${GREEN}실행 중${NC}"
    ps aux | grep -v grep | grep HappyHackingKeybinder
else
    echo -e "${YELLOW}실행 중이 아님${NC}"
fi