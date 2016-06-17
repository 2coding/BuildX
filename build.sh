# !/bin/bash

ctitle=32
cinfo=34
cerror=31
colorprint() {
	echo -e "\033[$1m$2\033[0m"
}

print_info() {
	#echo "$1"
	colorprint $cinfo "$1"
}

checkAvailable() {
	if [ ! -d $1 ]; then
		colorprint $cerror "SDK root \"$1\" not exists!"
		exit 1
	fi
}

#check build info
colorprint $ctitle 'Build Info:'
#libcurl
curlvar='curl-7.49.1'
print_info "* libcurl: ${curlvar}"
checkAvailable ${curlvar}

#IOS version
SDK=9.3
print_info "* iPhone SDK version: $SDK"

#iPhoneOS
XcodeRoot='/Applications/Xcode.app/Contents/Developer/Platforms'
iPhoneOSSDK="${XcodeRoot}/iPhoneOS.platform/Developer/SDKs/iPhoneOS${SDK}.sdk"
print_info "* iPhoneOS install path: ${iPhoneOSSDK}"
checkAvailable ${iPhoneOSSDK}

#iPhone Simulator
iPhoneSimulatorSDK="${XcodeRoot}/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator${SDK}.sdk"
print_info "* iPhone Simulator install path: ${iPhoneSimulatorSDK}"
checkAvailable ${iPhoneSimulatorSDK}

curpath=`pwd`
output="${curpath}/libcurl-ios-output"
if [ ! -d ${output} ]; then
	mkdir ${output}
else
	rm -fR ${output}
	mkdir ${output}
fi

cd $curlvar
#i386
colorprint $ctitle "\nBuild for iPhone Simulator(i386):"
deployment_target='6.0'
print_info "* Deployment Target = \"IOS ${deployment_target}\""

generateCFlags() {
	echo "-arch $1 -pipe -Os -gdwarf-2 -isysroot $2"
}
arch='i386'

flags=$(generateCFlags ${arch} ${iPhoneSimulatorSDK})
print_info "* CFLAGS = \"${flags}\""

generateConfig() {
	echo "--disable-shared --enable-static --host=\"$1\" --prefix=$2 --with-darwinssl --enable-threaded-resolver"
}
host='i386-Apple-darwin'
curoutput="${output}/i386"
configcmd=$(generateConfig ${host} ${curoutput})
print_info "* configure cmd = \"${configcmd}\""

export iPhoneOS_DEPLOYMENT_TARGET=$deployment_target
export CFLAGS=$flags
./configure ${configcmd}
