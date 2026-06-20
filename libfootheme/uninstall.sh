#!/bin/bash
set -e

FOOBAR_APP_PATH="/Applications/foobar2000.app"

if [ $(uname) != "Darwin" ]; then
	echo "platform not macOS. Exiting" >&2
	exit 1
fi

if [ "$(uname -m)" = "x86_64" ]; then
    ARCH_SUFFIX="x86_64"
elif [ "$(uname -m)" = "arm64" ]; then
    ARCH_SUFFIX="arm64"
else
    echo "platform not macOS. Exiting..." >&2
    exit 1
fi


if [ ! -e ${FOOBAR_APP_PATH}/Contents/MacOS/fb2k.backup ]; then
	echo "Could not find the original fb2k binary backup!"
	echo "If you have one, please save it as ${FOOBAR_APP_PATH}/Contents/MacOS/fb2k.backup"
fi

/usr/libexec/PlistBuddy -c "Delete :LSEnvironment:DYLD_INSERT_LIBRARIES" "${FOOBAR_APP_PATH}/Contents/Info.plist" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Delete :LSEnvironment" "${FOOBAR_APP_PATH}/Contents/Info.plist" 2>/dev/null || true
rm -f "${FOOBAR_APP_PATH}/Contents/Frameworks/libfootheme.dylib"
mv -f "${FOOBAR_APP_PATH}/Contents/MacOS/fb2k.backup" "${FOOBAR_APP_PATH}/Contents/MacOS/foobar2000"
codesign --force --deep --sign - "${FOOBAR_APP_PATH}"

echo ""
echo "uninstalled libfootheme"
echo "if foobar2000 is still opened, close it for changes to take effect"
