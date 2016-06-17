#!/bin/bash

. ./build-ios-base.sh

#########################################################################################
#base config
SSLVER=1.0.2
SSL_PATH=openssl-OpenSSL_1_0_2h

cleanup() {
	rm -fR ${SSL_PATH}.zip
	rm -fR ${SSL_PATH}
}

#########################################################################################
#download files
print_title "start download openssl code..."
#wget -O ${SSL_PATH}.zip https://github.com/openssl/openssl/archive/OpenSSL_1_0_2h.zip
#unzip -o ./${SSL_PATH}.zip &> download-openssl.log
print_title "done!\n"

print_info "* openssl: ${SSL_PATH}"
check_available ${SSL_PATH}

#########################################################################################
#build
CURRENT_PATH=`pwd`
cd ${SSL_PATH}
OUTPUT_ROOT="${CURRENT_PATH}/output-ios-openssl-${SSLVER}"
build_openssl() {
	ARCH=$1
	SDK_PATH=$2
	DEST_DIR="${OUTPUT_ROOT}/${ARCH}"

	print_title "\nbuild for ${ARCH}"
	DEPLOYMENT_TARGET=7.0
	print_info "* Deployment Target = \"IOS ${DEPLOYMENT_TARGET}\""

	export IPHONEOS_DEPLOYMENT_TARGET=${DEPLOYMENT_TARGET}
	export CFLAG="-arch ${ARCH} -isysroot ${SDK_PATH}"
	./config --prefix=${DEST_DIR} threads no-shared
}

build_openssl 'armv7' ${IPHONE_OS_SDK}

print_title "build openssl done"