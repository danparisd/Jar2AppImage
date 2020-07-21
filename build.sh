#!/bin/bash

# Your fat/shadow jar should be in the same dir as build.sh 
# Modify these vars as desired
export APPNAME=BTTConverter
export VERSION=1.0
export ARCH=x86_64

# Setup vars and dirs
WORKDIR=$(pwd)
APPDIR=$WORKDIR/AppDir
mkdir $APPDIR
mkdir $APPDIR/libs
mkdir $APPDIR/jre
cp ./icon.svg $APPDIR/icon.svg
cp ./AppRun $APPDIR/AppRun

# make .desktop file
cat << EOF > /$APPDIR/.desktop
[Desktop Entry]
Version=$VERSION
Type=Application
Categories=Utility;
Terminal=false
Exec=AppRun
Name=$APPNAME
Icon=icon
EOF

# Download JRE, works now, could break if the jq starts returning more than one value bases on these filters
wget -O - "https://api.github.com/repos/AdoptOpenJDK/openjdk11-binaries/releases" | jq -r ".[] | select(.prerelease==false) | select(.name | contains(\"openj9\") | not) | .assets[] | select(.name | contains(\"jre_x64_linux_hotspot\")) | select(.content_type==\"application/x-compressed-tar\") | .browser_download_url" | xargs wget -O jre.tar.gz
# Download linuxdeploy
wget -O - "https://api.github.com/repos/linuxdeploy/linuxdeploy/releases" | jq -r ".[] | .assets[] | select(.name==\"linuxdeploy-x86_64.AppImage\") | .browser_download_url" | xargs wget -O linuxdeploy.AppImage

tar -C $WORKDIR/AppDir/jre -zxf jre.tar.gz --strip-components=1

# If there is not exactly one jar file present, exit
if [ $(ls -1q *.jar | wc -l) -ne 1 ]; then 
    exit 1
else
    cp ./*.jar $APPDIR/libs/app.jar
fi

chmod +x ./linuxdeploy.AppImage

# make the AppImage
./linuxdeploy.AppImage --output appimage --appdir $APPDIR