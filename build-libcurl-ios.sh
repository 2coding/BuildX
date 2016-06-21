# !/bin/bash

. ./build-ios-base.sh

#########################################################################################
#base config
CURL_VERSION=7.49.1
CURL_PATH="curl-${CURL_VERSION}"

cleanup() {
	rm -fR "./${CURL_PATH}"
	rm -fR "./${CURL_PATH}.zip"
}

#########################################################################################
#download libcurl zip files
print_title "Start download curl source code..."
cleanup
wget https://curl.haxx.se/download/${CURL_PATH}.zip
unzip -o ./${CURL_PATH}.zip &> download-libcurl.log
print_title "Download code done!"

#libcurl
print_info "* libcurl: ${CURL_PATH}"
check_available ${CURL_PATH}

#########################################################################################
#build
CURRENT_PATH=`pwd`
OUTPUT_DIR="${CURRENT_PATH}/output-ios-libcurl-${CURL_VERSION}"
recreact_dir ${OUTPUT_DIR}
DEPLOYMENT_TARGET=6.0

cd $CURL_PATH
generate_cflags() {
	echo "-arch $1 -pipe -Os -gdwarf-2 -miphoneos-version-min=${DEPLOYMENT_TARGET} -isysroot $2"
}

generate_config() {
	if [ "$2" == "armv7" ]; then
		echo "--disable-shared --enable-static --host=$2-apple-darwin --prefix=$1 --with-darwinssl --enable-threaded-resolver"
	elif [ "$2" == "arm64" ]; then
		echo "--disable-shared --enable-static --host=arm-apple-darwin --prefix=$1 --with-darwinssl --enable-threaded-resolver"
	else
		echo "--disable-shared --enable-static --prefix=$1 --with-darwinssl --enable-threaded-resolver"
	fi
}

build_libcurl() {
	arch=$1
	sdkpath=$2
	print_title "\nBuild for ${arch}..."
	print_info "* Deployment Target = \"IOS ${DEPLOYMENT_TARGET}\""

	flags=$(generate_cflags ${arch} ${sdkpath})
	print_info "* CFLAGS = \"${flags}\""


	curoutput="${OUTPUT_DIR}/${arch}"
	recreact_dir ${curoutput}
	configcmd=$(generate_config ${curoutput} ${arch})
	print_info "* configure cmd = \"${configcmd}\""

	buildlog="${curoutput}/build.log"

	#run command
	export CFLAGS="${flags}"

	print_info "configure..."
	./configure ${configcmd} &> ${buildlog}
	if [ $? != 0 ]; then
		print_error "Configure failed!!!"
		exit 1
	fi
	print_info "configure done!"

	print_info "make..."
	make &> ${buildlog}
	if [ $? != 0 ]; then
		print_error "make failed!!!"
		exit 1
	fi
	print_info "make done"

	print_info "Install at ${curoutput}"
	make install &> ${buildlog}

	print_info "clean..."
	make clean &> ${buildlog}

	print_title "Build for ${arch} Done! You can find build log at \"${buildlog}\""
}

build_libcurl 'i386' ${IPHONE_SIMULATOR_SDK}
build_libcurl 'armv7' ${IPHONE_OS_SDK}
build_libcurl 'arm64' ${IPHONE_OS_SDK}

#########################################################################################
#bundle
print_title "\nStart bundle..."
cd ${CURRENT_PATH}
bundledir="${OUTPUT_DIR}/bundle"
recreact_dir ${bundledir}

mkdir ${bundledir}/lib
lipo -create ${OUTPUT_DIR}/i386/lib/libcurl.a ${OUTPUT_DIR}/armv7/lib/libcurl.a ${OUTPUT_DIR}/arm64/lib/libcurl.a -output ${bundledir}/lib/libcurl.a
if [ $? != 0 ]; then
	print_error "bundle libcurl failed!!!"
	exit 1
fi

cp -R ${OUTPUT_DIR}/arm64/include ${bundledir}

print_title "bundle done"

#########################################################################################
#cleanup
cleanup

#cd $CURRENT_PATH
print_title "Build libcurl for IOS Done, You can find libs in \"$OUTPUT_DIR\""
