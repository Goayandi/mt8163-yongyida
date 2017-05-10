#!/bin/bash

# add by yankendi
# this script is to create incremental update package
# first you must choose old version OTApackage name that is in the 
# "out\target\product\byt_t_ffrd10\obj\PACKAGING\target_files_intermediates"
# then choose new version OTApackage name that also in the path above,
# then you must choose if to wipe userdata


echo "............................"
echo $USER
echo $TARGET_PRODUCT
echo $TARGET_BUILD_VARIANT
echo "............................"

old=""
new=""
userdata=""
OUT="out/target/product/$CUR_PROJECT"

while [[ $old = "" ]]; do
	echo -n "please enter the old version OTApackage name : "
	read old
	echo $old
done

while [[ $new = "" ]]; do
	echo -n "please enter the new version OTApackage name : "
	read new
	echo $new
done

while [[ $userdata = "" ]]; do
	echo -n "if need to wipe the userdata ? y/n : "
	read userdata
	if [[ $userdata = "y" ]]; then
		echo -e "wipe the userdata"
	elif [[ $userdata = "n" ]]; then
		echo -e "doesn't wipe the userdata"
	else
		echo -e "please choose if to wipe userdata"
	fi
done

if [ $userdata = "y" ]; then
	echo -e "wipe userdata"
	./build/tools/releasetools/ota_from_target_files \
	-v -i \
	$OUT/obj/PACKAGING/target_files_intermediates/$old \
	-w \
	-p out/host/linux-x86 \
	-k build/target/product/security/testkey \
	$OUT/obj/PACKAGING/target_files_intermediates/$new \
	$OUT/update.zip
	echo -e "wipe userdata"
elif [ $userdata = "n" ]; then
	echo -e "do not wipe userdata"
	./build/tools/releasetools/ota_from_target_files \
	-v -i \
	$OUT/obj/PACKAGING/target_files_intermediates/$old \
	-p out/host/linux-x86 \
	-k build/target/product/security/testkey \
	$OUT/obj/PACKAGING/target_files_intermediates/$new \
	$OUT/update.zip
	echo -e "do not wipe userdata"
fi
	
