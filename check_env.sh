#!/bin/bash

# Flutter Friends Circle Project - Environment Check Script
# Usage: ./check_env.sh

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${PURPLE}🔍 Flutter Friends Circle Project Environment Check${NC}"
echo -e "${PURPLE}================================================${NC}"

# Check FVM
echo -e "\n${BLUE}📦 FVM Check${NC}"
if command -v fvm >/dev/null 2>&1; then
    echo -e "${GREEN}✅ FVM installed: $(fvm --version)${NC}"
else
    echo -e "${RED}❌ FVM not installed${NC}"
    echo -e "${YELLOW}   Install command: dart pub global activate fvm${NC}"
fi

# Check Flutter versions
echo -e "\n${BLUE}📱 Flutter Version Check${NC}"
echo "Installed Flutter versions:"
if command -v fvm >/dev/null 2>&1; then
    fvm list
else
    echo -e "${RED}❌ Cannot check, FVM not installed${NC}"
fi

# Check project configuration
echo -e "\n${BLUE}🏗️  Project Configuration Check${NC}"
if [ -f "3.27/.fvmrc" ]; then
    echo -e "${GREEN}✅ 3.27 version config: $(cat 3.27/.fvmrc)${NC}"
else
    echo -e "${RED}❌ 3.27 version config missing${NC}"
    echo -e "${YELLOW}   Run: cd 3.27 && fvm use 3.27.0${NC}"
fi

if [ -f "3.29/.fvmrc" ]; then
    echo -e "${GREEN}✅ 3.29 version config: $(cat 3.29/.fvmrc)${NC}"
else
    echo -e "${RED}❌ 3.29 version config missing${NC}"
    echo -e "${YELLOW}   Run: cd 3.29 && fvm use 3.29.0${NC}"
fi

# Check Android devices
echo -e "\n${BLUE}📱 Android Device Check${NC}"
if command -v adb >/dev/null 2>&1; then
    DEVICES=$(adb devices | grep -v "List of devices" | grep device | wc -l)
    if [ $DEVICES -gt 0 ]; then
        echo -e "${GREEN}✅ Detected $DEVICES Android device(s)${NC}"
        adb devices
    else
        echo -e "${YELLOW}⚠️  No Android devices detected${NC}"
        echo -e "${YELLOW}   Please ensure device is connected and USB debugging is enabled${NC}"
    fi
else
    echo -e "${RED}❌ ADB not installed or not in PATH${NC}"
fi

# Check build scripts
echo -e "\n${BLUE}🚀 Build Script Check${NC}"
if [ -x "build_flutter_apks.sh" ]; then
    echo -e "${GREEN}✅ Complete build script executable${NC}"
else
    echo -e "${RED}❌ Complete build script not executable${NC}"
    echo -e "${YELLOW}   Run: chmod +x build_flutter_apks.sh${NC}"
fi

if [ -x "quick_build.sh" ]; then
    echo -e "${GREEN}✅ Quick build script executable${NC}"
else
    echo -e "${RED}❌ Quick build script not executable${NC}"
    echo -e "${YELLOW}   Run: chmod +x quick_build.sh${NC}"
fi

# Check output directory
echo -e "\n${BLUE}📦 Output Directory Check${NC}"
if [ -d "apk" ]; then
    APK_COUNT=$(find apk -name "*.apk" | wc -l)
    echo -e "${GREEN}✅ APK output directory exists, contains $APK_COUNT APK file(s)${NC}"
    if [ $APK_COUNT -gt 0 ]; then
        echo "Recent APK files:"
        ls -lt apk/*.apk | head -5
    fi
else
    echo -e "${YELLOW}⚠️  APK output directory does not exist, will be created during build${NC}"
fi

# Summary
echo -e "\n${PURPLE}📋 Environment Check Summary${NC}"
echo -e "${PURPLE}=============================${NC}"

# Calculate readiness status
READY=true

if ! command -v fvm >/dev/null 2>&1; then
    READY=false
fi

if [ ! -f "3.27/.fvmrc" ] || [ ! -f "3.29/.fvmrc" ]; then
    READY=false
fi

if [ ! -x "build_flutter_apks.sh" ] || [ ! -x "quick_build.sh" ]; then
    READY=false
fi

if $READY; then
    echo -e "${GREEN}🎉 Environment check passed! Ready to build APKs${NC}"
    echo -e "\n${BLUE}Recommended build commands:${NC}"
    echo -e "${YELLOW}   ./build_flutter_apks.sh    # Complete build${NC}"
    echo -e "${YELLOW}   ./quick_build.sh           # Quick build${NC}"
else
    echo -e "${RED}❌ Environment configuration issues found, please fix according to above suggestions${NC}"
fi

echo -e "\n${BLUE}💡 For more help information, see: BUILD_GUIDE.md${NC}"