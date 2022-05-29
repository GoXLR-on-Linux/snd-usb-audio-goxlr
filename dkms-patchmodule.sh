#!/bin/bash

# kernelver isn't set on kernel upgrade, the following commands try to extract the latest installed kernel
# version from the package manager.
if [ -z "$kernelver" ]; then
	if [ -f "/etc/debian_release" ]; then
		kernelver=$( echo $DPKG_MAINTSCRIPT_PACKAGE | sed -r 's/linux-(headers|image)-//')
	elif [ -f "/etc/arch_release" ]; then
		kernelver=$(pacman -Q linux | sed -e 's/linux.* \(.*\)\1/')
	else
		echo "Unable to determine Kernel version"
		exit -1;
	fi
fi

vers=(${kernelver//./ })   # split kernel version into individual elements
major="${vers[0]}"
minor="${vers[1]}"
subver="${vers[2]%%-*}"	   # Grab the patch version, and remove all post - data..
version="$major.$minor"    # recombine as needed

FILE_NAME="linux-$version.tar.xz"
if [ $subver -gt 0 ]; then
	FILE_NAME="linux-$version.$subver.tar.xz"
fi

SRC_PATH="/usr/src/goxlr-dkms-${FILE_NAME}"

echo "Checking for existing sources.."
if [ ! -f $SRC_PATH ]; then
	echo "Downloading kernel source $version.$subver for $kernelver"
	wget -q -O $SRC_PATH https://mirrors.edge.kernel.org/pub/linux/kernel/v$major.x/$FILE_NAME
fi

OUT_PATH="linux-$version"
if [ $subver -gt 0 ]; then
	OUT_PATH="linux-$version.$subver"
fi

echo "Extracting original source"
tar -xf $SRC_PATH $OUT_PATH/$1 --xform=s,$OUT_PATH/$1,.,

echo "Fetching snd-usb-audio patch from kernel.org.."
wget -q -O 001-goxlr-fix.patch https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/patch/sound/usb?id=0e85a22d01dfe9ad9a9d9e87cd4a88acce1aad65

echo "Applying Patch.."
patch < 001-goxlr-fix.patch >> /dev/null 2>&1

if [ $? -ne 0 ]; then
	# DKMS doesn't have a 'clean' way to abort a build in the PRE_BUILD section, I could touch a file and add a PRE_INSTALL script that fails it, but ultimately
	# what's the point in even building it if the patch hasn't worked? So we're going to forcefully break the build by removing the Makefile.

	echo "Patching Failed, erroring."
	rm Makefile

	exit 1
fi

echo "Done!"
