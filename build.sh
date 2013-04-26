BUILD_DIR="`pwd`/build/"
TMP_DIR="${BUILD_DIR}tmp/"
LOVE_VERSION="0.8.0"
NAME=${PWD##*/}

rm -rf $TMP_DIR $BUILD_DIR

zip -r ../build.love *

mkdir $BUILD_DIR
mkdir $TMP_DIR

mv ../build.love ${BUILD_DIR}${NAME}.love

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
	cd love-$LOVE_VERSION-linux-src
	./configure
	make
	cat ./love ${BUILD_DIR}${NAME}.love > ${BUILD_DIR}${NAME}_linux
	chmod +x ${BUILD_DIR}${NAME}_linux
}

win_build x86
win_build x64
# linux_build

rm -rf $TMP_DIR
