#!/bin/zsh
# MLBench compile script
# compiles both archs to a universal bin. 

set -e # stop if fail

# constants
name="MLBench"
app="${name}.app"
iconPath="MLBench.icns"
build=".build"
release="release"
output="${release}/${app}"
arm64="arm64"
amd64="x86_64"

# qol during prototyping
echo "Removing past builds"
rm -rf "${build}"
rm -rf "${release}"
mkdir -p "${release}"

# build both archs
echo "Building ${arm64}"
swift build --arch ${arm64} -c release
echo "Building ${amd64}"
swift build --arch ${amd64} -c release

# use lipo
echo "Making universal binary"
univOutput="${build}/universal"
univPath="${univOutput}/${name}"
mkdir -p "${univOutput}"
lipo -create -output "${univPath}" "${build}/${arm64}-apple-macosx/release/${name}" "${build}/${amd64}-apple-macosx/release/${name}"
echo "Universal binary at ${univPath}"

# make .app
echo "Making .app"
mkdir -p "${output}/Contents/MacOS"
mkdir -p "${output}/Contents/Resources"
cp "${univPath}" "${output}/Contents/MacOS/"
swiftPMBundle="${build}/${arm64}-apple-macosx/release/${name}_${name}.bundle"
swiftPMResources="${output}/Contents/Resources/"

if [ -d "${swiftPMBundle}" ]; then
    cp -R "${swiftPMBundle}" "${swiftPMResources}"
else
    echo "Didn't find a ${swiftPMBundle}, quitting"
    exit 1
fi

# copy icon only if exists
if [ -f "${iconPath}" ]; then
    cp "${iconPath}" "${output}/Contents/Resources/"
fi

# info.plist
PLIST_PATH="${output}/Contents/Info.plist"
cat > "$PLIST_PATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${name}</string>
    <key>CFBundleIconFile</key>
    <string>${iconPath}</string>
    <key>CFBundleIdentifier</key>
    <string>com.willuhd.${name}</string> 
    <key>CFBundleName</key>
    <string>${name}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.3</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

echo "Finished MLBench build at ${output}"

# willuhd 2025
# last modified Nov 2
