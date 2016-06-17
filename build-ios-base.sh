#!/bin/bash

#########################################################################################
#common func
color_print() {
	echo -e "\033[$1m$2\033[0m"
}

print_info() {
	color_print 34 "$1"
}

print_error() {
	color_print 31 "$1"
}

print_title() {
	color_print 32 "$1"
}

check_available() {
	if [ ! -d $1 ]; then
		print_error "SDK root \"$1\" not exists!"
		exit 1
	fi
}

recreact_dir() {
	dirpath=$1
	print_info "create dir at \"${dirpath}\""
	if [ ! -d $dirpath ]; then
		mkdir ${dirpath}
	else
		rm -fR ${dirpath}
		mkdir ${dirpath}
	fi
}

#########################################################################################
#iPhoneOS SDK
SDK=`xcrun -sdk iphoneos --show-sdk-version`

#IOS version
print_title "Check iPhoneOS SDK"
print_info "* iPhoneOS SDK version: $SDK"

#iPhoneOS
IPHONE_OS_SDK=`xcrun -sdk iphoneos --show-sdk-path`
print_info "* iPhoneOS install path: ${IPHONE_OS_SDK}"
check_available ${IPHONE_OS_SDK}

#iPhone Simulator
IPHONE_SIMULATOR_SDK=`xcrun -sdk iphonesimulator --show-sdk-path`
print_info "* iPhone Simulator install path: ${IPHONE_SIMULATOR_SDK}"
check_available ${IPHONE_SIMULATOR_SDK}