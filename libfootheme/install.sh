#!/bin/bash
set -e

FOOBAR_APP_PATH="/Applications/foobar2000.app"

if [ $(uname) != "Darwin" ]; then
	echo "platform not macOS. Exiting" >&2
	exit 1
fi

if [ "$(uname -m)" = "x86_64" ]; then
    ARCH_SUFFIX="amd64"
elif [ "$(uname -m)" = "arm64" ]; then
    ARCH_SUFFIX="arm64"
else
    echo "platform not macOS. Exiting..." >&2
    exit 1
fi

mkdir -p "${FOOBAR_APP_PATH}/Contents/Frameworks"
curl -Lo /Applications/foobar2000.app/Contents/Frameworks/libfootheme.dylib "https://github.com/naomisphere/libfootheme/releases/latest/download/libfootheme-${ARCH_SUFFIX}.dylib"

cp -f "${FOOBAR_APP_PATH}/Contents/MacOS/foobar2000" ${FOOBAR_APP_PATH}/Contents/MacOS/fb2k.backup

install_name_tool -id "@rpath/libfootheme.dylib" "${FOOBAR_APP_PATH}/Contents/Frameworks/libfootheme.dylib"

/usr/libexec/PlistBuddy -c "Add :LSEnvironment dict" "${FOOBAR_APP_PATH}/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :LSEnvironment:DYLD_INSERT_LIBRARIES string \"@executable_path/../Frameworks/libfootheme.dylib\"" "${FOOBAR_APP_PATH}/Contents/Info.plist" 2>/dev/null || \
/usr/libexec/PlistBuddy -c "Set :LSEnvironment:DYLD_INSERT_LIBRARIES \"@executable_path/../Frameworks/libfootheme.dylib\"" "${FOOBAR_APP_PATH}/Contents/Info.plist"

codesign --force --deep --sign - "${FOOBAR_APP_PATH}/Contents/Frameworks/libfootheme.dylib"
codesign --force --deep --sign - "${FOOBAR_APP_PATH}"

echo ""
echo "installed libfootheme"
echo "To interact with libfootheme, use the "Theme" menu bar item"
echo "To uninstall libfootheme, run curl https://naomisphere.github.io/libfootheme/uninstall.sh | sh"
