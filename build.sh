#!/usr/bin/env bash
BUILD_DIR="`pwd`/build/"
TMP_DIR="${BUILD_DIR}tmp/"
SRC_DIR="${BUILD_DIR}src/"
REMOVE_FILES=('.git' '.gitignore' '.DS_Store' 'README.md' 'build.sh' 'web')
LOVE_VERSION="0.8.0"
NAME=${PWD##*/}

rm -rf $TMP_DIR $BUILD_DIR $SRC_DIR

cp -r . ../${NAME}_copy

mkdir $BUILD_DIR
mkdir $TMP_DIR

mv ../${NAME}_copy $SRC_DIR

for ((i=0; i<${#REMOVE_FILES[@]}; i++)); do
	rm -rf ${SRC_DIR}${REMOVE_FILES[$i]}
done

cd $SRC_DIR
sed -i '' 's/t\.release = false/t.release = true/' conf.lua
zip -r ${BUILD_DIR}${NAME}.love *

win_build(){
	cd $TMP_DIR
	wget https://bitbucket.org/rude/love/downloads/love-$LOVE_VERSION-win-$1.zip
	unzip love-$LOVE_VERSION-win-${1}.zip
	cd love-$LOVE_VERSION-win-$1
	rm changes.txt license.txt
	cat ./love.exe ${BUILD_DIR}${NAME}.love > ${NAME}.exe
	rm love.exe
	zip -r ${BUILD_DIR}${NAME}_win_${1}.zip *
}

linux_build(){
	cd $TMP_DIR
	wget https://bitbucket.org/rude/love/downloads/love-$LOVE_VERSION-linux-src.tar.gz
	tar -xvf love-$LOVE_VERSION-linux-src.tar.gz
	cd love-$LOVE_VERSION
	./configure
	make
	cat ./src/love ${BUILD_DIR}${NAME}.love > ${BUILD_DIR}${NAME}_linux
	chmod +x ${BUILD_DIR}${NAME}_linux
}

osx_build(){
	cd $TMP_DIR
	wget https://bitbucket.org/rude/love/downloads/love-$LOVE_VERSION-macosx-ub.zip
	unzip love-$LOVE_VERSION-macosx-ub.zip
	cd love.app/Contents
	sed -i '' '74,101d' Info.plist
	sed -i '' '9,37d' Info.plist
	sed -i '' 's/org\.love2d\.love/de.ps0ke.tipptippreloaded/' Info.plist
	sed -i '' 's/>LÖVE</>TippTippReloaded</' Info.plist
	sed -i '' 's/LoVe/mett/' Info.plist
	#sed -i '' 's/Love\.icns/icon.icns/' Info.plist
	#cp ${SRC_DIR}/assets/ttr_icon_512.icns Resources/icon.icns
	rm Resources/LoveDocument.icns
	cp ${BUILD_DIR}${NAME}.love Resources/
	cd $TMP_DIR
	mv love.app ${BUILD_DIR}${NAME}.app
}

win_build x86
win_build x64
linux_build
osx_build

rm -rf $TMP_DIR $SRC_DIR
