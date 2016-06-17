# !/bin/bash

ctitle=32
cinfo=34
cerror=31
colorprint() {
	echo -e "\033[$1m$2\033[0m"
}

print_info() {
	colorprint $cinfo "$1"
}

print_error() {
	colorprint $cerror "$1"
}

print_title() {
	colorprint $ctitle "$1"
}

checkAvailable() {
	if [ ! -d $1 ]; then
		print_error "SDK root \"$1\" not exists!"
		exit 1
	fi
}

#check build info
print_title 'Build Info:'
#libcurl
curlver="7.49.1"
curlvar="curl-${curlver}"
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

create_dir_if_notexists() {
	dirpath=$1
	print_info "create dir at \"${dirpath}\""
	if [ ! -d $dirpath ]; then
		mkdir ${dirpath}
	else
		rm -fR ${dirpath}
		mkdir ${dirpath}
	fi
}

curpath=`pwd`
output="${curpath}/libcurl-ios-${curlver}"
create_dir_if_notexists ${output}

cd $curlvar
generateCFlags() {
	echo "-arch $1 -pipe -Os -gdwarf-2 -isysroot $2"
}

generateConfig() {
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
	deployment_target='6.0'
	print_info "* Deployment Target = \"IOS ${deployment_target}\""

	flags=$(generateCFlags ${arch} ${sdkpath})
	print_info "* CFLAGS = \"${flags}\""


	curoutput="${output}/${arch}"
	create_dir_if_notexists ${curoutput}
	configcmd=$(generateConfig ${curoutput} ${arch})
	print_info "* configure cmd = \"${configcmd}\""

	buildlog="${curoutput}/build.log"

	#run command
	export iPhoneOS_DEPLOYMENT_TARGET=$deployment_target
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

build_libcurl 'i386' ${iPhoneSimulatorSDK}
build_libcurl 'armv7' ${iPhoneOSSDK}
build_libcurl 'arm64' ${iPhoneOSSDK}

print_info "start bundle..."
cd ${curpath}
bundledir="${output}/bundle"
create_dir_if_notexists ${bundledir}

lipo -create ${output}/i386/lib/libcurl.a ${output}/armv7/lib/libcurl.a ${output}/arm64/lib/libcurl.a -output ${output}/bundle/libcurl.a
if [ $? != 0 ]; then
	print_error "bundle libcurl failed!!!"
	exit 1
fi

#cd $curpath
print_title "Build libcurl for IOS Done, You can find libs in \"${output}\""
