# !/bin/bash

checkAvailable() {
	if [ ! -d $1 ]; then
		echo "SDK root \"$1\" not exists!"
		exit 1
	else
		echo "Available!"
	fi
}

#check build info
echo 'Build Info:'
#libcurl
curlvar='curl-7.49.1'
echo -e "* libcurl: ${curlvar} -> \c"
checkAvailable ${curlvar}
#IOS version
SDK=9.3
echo '* iPhone SDK version: '$SDK
#iPhoneOS
XcodeRoot='/Applications/Xcode.app/Contents/Developer/Platforms'
iPhoneOSSDK="${XcodeRoot}/iPhoneOS.platform/Developer/SDKs/iPhoneOS${SDK}.sdk"
echo -e "* iPhoneOS install path: ${iPhoneOSSDK} -> \c"
checkAvailable ${iPhoneOSSDK}
#iPhone Simulator
iPhoneSimulatorSDK="${XcodeRoot}/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator${SDK}.sdk"
echo -e "* iPhone Simulator install path: ${iPhoneSimulatorSDK} -> \c"
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
echo -e "\nBuild for iPhone Simulator(i386):"
deployment_target='6.0'
echo "* Deployment Target = \"IOS ${deployment_target}\""

generateCFlags() {
	echo "-arch $1 -pipe -Os -gdwarf-2 -isysroot $2"
}
arch='i386'

flags=$(generateCFlags ${arch} ${iPhoneSimulatorSDK})
echo "* CFLAGS = \"${flags}\""

generateConfig() {
	echo "--disable-shared --enable-static --host=\"$1\" --prefix=$2 --with-darwinssl --enable-threaded-resolver"
}
host='i386-Apple-darwin'
curoutput="${output}/i386"
configcmd=$(generateConfig ${host} ${curoutput})
echo "* configure cmd = \"${configcmd}\""
