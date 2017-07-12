#!/usr/bin/env bash

# Exit if any errors occur
#set -e

# Get the current directory (/scripts/ directory)
SDK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Traverse up to get to the root directory
SDK_DIR="$(dirname "$SDK_DIR")"
EXAMPLE_DIR=example_ci
SDK_NAME=react-native-adjust

RED='\033[0;31m' # Red color
GREEN='\033[0;32m' # Green color
NC='\033[0m' # No Color

# Kill any previously running packager instance
#killall -9 node

echo -e "${GREEN}>>> Updating Git submodules ${NC}"
cd ${SDK_DIR}
git submodule update --init --recursive

echo -e "${GREEN}>>> Removing the Android JAR file ${NC}"
rm -rfv android/libs/*

echo -e "${GREEN}>>> Removing the Android ci testing JAR file ${NC}"
rm -rfv example_ci/android/app/libs/adjust-testing.jar

echo -e "${GREEN}>>> Building the Android JAR file ${NC}"
ext/android/build.sh

echo -e "${GREEN}>>> Building the Android ci testing JAR file ${NC}"
ext/android/build_test_ci.sh

# Remove node_modules from the example project
rm -rf ${EXAMPLE_DIR}/node_modules/${SDK_NAME}

echo -e "${GREEN}>>> Running npm install on example project${NC}"
cd ${SDK_DIR}/${EXAMPLE_DIR}
npm install

echo -e "${GREEN}>>> Uninstall and unlink current module ${NC}"
react-native uninstall ${SDK_NAME}

echo -e "${GREEN}>>> Create new directory in node_modules ${NC}"
mkdir node_modules/${SDK_NAME}

# Copy things to it
echo -e "${GREEN}>>> Copy modules to ${EXAMPLE_DIR}/node_modules/${SDK_NAME} ${NC}"
cd ${SDK_DIR}
rsync -a . ${EXAMPLE_DIR}/node_modules/${SDK_NAME} --exclude=example --exclude=example_ci --exclude=ext --exclude=scripts

# Establish link
echo -e "${GREEN}>>> Establish linkage to ${SDK_NAME} ${NC}"
cd ${SDK_DIR}/${EXAMPLE_DIR}
react-native link ${SDK_NAME}

react-native run-android

#echo -e "${GREEN}>>> Building & Running on Android ${NC}"
#cd ${SDK_DIR}/${EXAMPLE_DIR}
#react-native bundle --dev false --platform android --entry-file index.android.js --bundle-output ./android/app/build/intermediates/assets/debug/index.android.bundle --assets-dest ./android/app/build/intermediates/res/merged/debug
#(cd android; ./gradlew assembleDebug)

## copy apk to scripts dir
#cd ${SDK_DIR}/${EXAMPLE_DIR}
#cp -v android/app/build/outputs/apk/app-debug.apk ${SDK_DIR}/scripts/app.apk

#cd ${SDK_DIR}/${EXAMPLE_DIR}
#adb install -r android/app/build/outputs/apk/app-debug.apk
