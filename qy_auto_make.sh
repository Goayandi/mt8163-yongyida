#!/bin/bash

ANDROID_PATH=/home/tangli/code/qiyan
cd $ANDROID_PATH
DATE=`date "+%Y%m%d"`
COMMITFILE="$ANDROID_PATH"/"$DATE"_zkcommit.txt
#repo sync
echo >> $COMMITFILE
echo >> $COMMITFILE
echo "====`date`====commit" >> $COMMITFILE
date "+%Y-%m-%d %H:%M:%S" >> $COMMITFILE
repo forall -p -c git log --since="1 days" --pretty=format:"%s----%an" --no-merges > temp.log
cat temp.log | while read line
do 
 templine=${line#[1mproject }
 echo ${templine%[m} >> $COMMITFILE
done
tail -n 1 temp.log >> $COMMITFILE

#*******************************************************************
source build/envsetup.sh
lunch 2

CUR_PROJECT=`get_build_var MTK_PROJECT`

#**************************************************************************************

#编译后输出目录
OUT=out/target/product/$CUR_PROJECT
#目标设备路径
TARGET_DEVICE_DIR=device/yongyida/$CUR_PROJECT
MTK_COMMON=device/mediatek/common
MTK_PROJECT_PATH=device/mediatek/mt8163
MTK_LOGO_PATH=vendor/mediatek/proprietary/bootable/bootloader/lk/dev/logo
MTK_BATTER_PATH=vendor/mediatek/proprietary/bootable/bootloader/lk/dev/logo/

#客制化配置路径
CUSTOMIZATION_PATH=$1
length=${#CUSTOMIZATION_PATH}
lastchar=${CUSTOMIZATION_PATH:length-1:length}
if [[ $lastchar = "/" ]]; then
	CUSTOMIZATION_PATH=${CUSTOMIZATION_PATH:0:length-1}
fi

export CUSTOMIZATION_PATH
export OUT
export TARGET_DEVICE_DIR
export MTK_COMMON
export MTK_PROJECT_PATH
export MTK_LOGO_PATH
export CUR_PROJECT
export USER=$(whoami)

if [ ! -e $CUSTOMIZATION_PATH/product_config.sh ]; then
	echo "输入的配置路径错误"
	exit 1
fi 

#执行客制化配置目录下的 product_config.sh 以确定机器型号
. $CUSTOMIZATION_PATH/product_config.sh

echo "............................"
echo "USER="$USER
echo "TARGET_PRODUCT="$TARGET_PRODUCT
echo "TARGET_BUILD_VARIANT="$TARGET_BUILD_VARIANT
echo "CUSTOMER_PRODUCT="$CUSTOMER_PRODUCT
echo "WIFI_ONLY="$WIFI_ONLY
echo "TARGET_DEVICE_DIR"=$TARGET_DEVICE_DIR
echo "CUSTOMIZATION_PATH="$CUSTOMIZATION_PATH
echo "CUR_PROJECT="$CUR_PROJECT

echo "............................"
#*******************************************************************



#**************************************************************************************************
#删除一些上一次客制化编译的文件和恢复默认配置

if [ -d lib ]; then
	rm -rf lib/
fi


#删除一些上一次客制化编译的文件
make installclean

#删除PTGEN目录，防止MT8163_Android_scatter.txt没生成
#if [ -e "$OUT/obj/PTGEN" ]; then
#    rm -rf $OUT/obj/PTGEN
#fi  

rm -rf out/target/common/obj/JAVA_LIBRARIES/libservice*
rm -rf out/target/common/obj/JAVA_LIBRARIES/Msc*
rm -rf out/target/common/obj/JAVA_LIBRARIES/libresourceamnager*
rm -rf out/target/common/obj/JAVA_LIBRARIES/libplayer*
rm -rf out/target/common/obj/JAVA_LIBRARIES/libmaster*
rm -rf out/target/common/obj/JAVA_LIBRARIES/libnotification*
rm -rf out/target/common/obj/JAVA_LIBRARIES/libinfrared*
rm -rf out/target/common/obj/JAVA_LIBRARIES/libFactory*
rm -rf out/target/common/obj/JAVA_LIBRARIES/libfacerecognizer*
rm -rf out/target/common/obj/JAVA_LIBRARIES/libBreathLed*
rm -rf out/target/common/obj/JAVA_LIBRARIES/launcherlib*



#删除设备目标路径（TARGET_DEVICE_DIR）下的overrides.prop 和 product_overrides.prop
if [ -e $TARGET_DEVICE_DIR/product_overrides.prop ]; then
	rm $TARGET_DEVICE_DIR/product_overrides.prop
fi
if [ -e $TARGET_DEVICE_DIR/overrides.prop ]; then
	rm $TARGET_DEVICE_DIR/overrides.prop
fi


#**************************************************************************************************
#**************************************************************************************************
#执行机器型号默认的相关配置
. yongyida/product/product_common_config.sh
#**************************************************************************************************



#**************************************************************************************************
#覆盖device下一些文件配置，编译进固件。

#拷贝 overrides.prop 到设备目标路径，即 device/yongyida/y20a_dev 下，修改build.prop属性。
if [ -e $CUSTOMIZATION_PATH/oem/overrides.prop ]; then
	cp  -rf $CUSTOMIZATION_PATH/oem/overrides.prop $TARGET_DEVICE_DIR/
fi


# 针对客户项目，修改以下几个文件中配置 custom.conf(device/mediatek/common/) ProjectConfig.mk(device/yongyida/y20a_dev/)
if [ -e $CUSTOMIZATION_PATH/oem/modifyconfigs_before_build ]; then
. yongyida/tools/modify_config_before_make.sh $CUSTOMIZATION_PATH/oem/modifyconfigs_before_build
fi



#----------product_common_config.sh中处理----------------------------
#如有特殊配置，拷贝机器型号配置文件yyd8163_tb_m_defconfig，此配置和yongyida/product下对应型的yyd8163_tb_m_defconfig
#共用的配置是一致的，比如摄像头、触摸屏等配置。此处添加不是多此一举，而是为了一些特殊需求另外添加并覆盖。
#比如荣事达所用tp与通用版不同，需要在内核中配置，一般客户不需要的就不用另外添加。
if [ -e $CUSTOMIZATION_PATH/oem/yyd8163_tb_m_defconfig ]; then
	cp  -rf $CUSTOMIZATION_PATH/oem/yyd8163_tb_m_defconfig kernel-3.18/arch/arm64/configs/
fi

if [ -e $CUSTOMIZATION_PATH/oem/yyd8163_tb_m_debug_defconfig ]; then
	cp  -rf $CUSTOMIZATION_PATH/oem/yyd8163_tb_m_debug_defconfig kernel-3.18/arch/arm64/configs/
fi
#**************************************************************************************************



#**************************************************************************************************
#拷贝overlays
if [ -d $CUSTOMIZATION_PATH/oem/overlays ]; then
	cp  -rf $CUSTOMIZATION_PATH/oem/overlays/* $TARGET_DEVICE_DIR/overlay/
fi

if [ -e $CUSTOMIZATION_PATH/oem/device.mk ]; then
	cp  -rf $CUSTOMIZATION_PATH/oem/device.mk $MTK_COMMON/
fi



#拷贝第一帧logo:实则为uboot和kernel的两帧logo	qxga-2048*1536, wxga-1280*800, xga-1024*768, hd720-720*1280
if [ -e $CUSTOMIZATION_PATH/oem/bootlogo.bmp ]; then
	cp -rf $CUSTOMIZATION_PATH/oem/bootlogo.bmp $MTK_LOGO_PATH/hd720nl/hd720nl_uboot.bmp
	cp -rf $CUSTOMIZATION_PATH/oem/bootlogo.bmp $MTK_LOGO_PATH/hd720nl/hd720nl_low_battery.bmp
	cp -rf $CUSTOMIZATION_PATH/oem/bootlogo.bmp $MTK_LOGO_PATH/hd720nl/hd720nl_kernel.bmp
fi


#**************************************************************************************************
#拷贝要内置到system/app/下的apk的库文件到临时文件lib
#在Makefile执行oem_config.xml时再拷贝到system/lib/下
mkdir -p oemapk/app/
#alias cp='./yongyida/tools/copy_apk_so.sh'
if [ -d $CUSTOMIZATION_PATH/apk/system_apk ]; then
	for filename in `ls $CUSTOMIZATION_PATH/apk/system_apk`
	do
		echo $filename 
		./yongyida/tools/copy_apk_so.sh $CUSTOMIZATION_PATH/apk/system_apk/$filename $filename "system_apk"
		
	done
fi
#unalias cp

#拷贝要内置到system/priv-app/下的apk的库文件到临时文件lib
#在Makefile执行oem_config.xml时再拷贝到system/lib/下
mkdir -p oemapk/priv-app/
alias cp='./yongyida/tools/copy_apk_so.sh'
if [ -d $CUSTOMIZATION_PATH/apk/system_priv_apk ]; then
	for filename in `ls $CUSTOMIZATION_PATH/apk/system_priv_apk`
	do
		cp $CUSTOMIZATION_PATH/apk/system_priv_apk/$filename $filename "system_priv_apk"
	done
fi
unalias cp
#**************************************************************************************************

#**************************************************************************************************
#修改版本号

#. $CUSTOMIZATION_PATH/changeVersion.sh
if [ -n $1 ]; then
    ISDAILY=$1
else
	ISDAILY=no
fi

if [ $ISDAILY == daily ]; then
    VersionNumber="QY50E_V3R001"_`date +%Y%m%d%H%M`
else
    VersionNumber="QY50E_V3R001"
fi
echo $VersionNumber
propPath="$TARGET_DEVICE_DIR/system.prop"
OldVersionNumber=`grep "ro.yongyida.build_number" $propPath`
newVersion="ro.yongyida.build_number=$VersionNumber"
sed -i "s/$OldVersionNumber/$newVersion/" $propPath
echo -e "[autobuild.sh]: \e[0;31;1m new ro.yongyida.build_number=$VersionNumber \033[0m"

SecVersionNumber="QY50E.12.001"
SecOldVersionNumber=`grep "robot.os_version" $propPath`
SecNewVersion="robot.os_version=$SecVersionNumber.`date +%m%d`"
sed -i "s/$SecOldVersionNumber/$SecNewVersion/" $propPath
echo -e "[autobuild.sh]: \e[0;31;1m new $SecNewVersion \033[0m"

#**************************************************************************************************

#**************************************************************************************************
#开始编译

make -j8 > Build.log

#**************************************************************************************************

#make otapackage -j16

echo "make otapackage ..."

#**************************************************************************************************
#还原编译产生的diff
#恢复默认的overlay和checkout device目录
rm -rf $TARGET_DEVICE_DIR/overlay/  
cd device/
git checkout ./
cd ../

cd kernel-3.18
git checkout ./
cd ../

cd vendor/
git checkout .
cd ../

#**************************************************************************************************

. yongyida/tools/copyimages.sh
echo "tar images=================>>>"
tar -zcvf "$VersionNumber".tar.gz pub/images
echo "copy fota backup=================>>>"
mkdir "$VersionNumber"_fota
otapath=out/target/product/yyd8163_tb_m/
cp $otapath*.zip "$VersionNumber"_fota

mkdir "$VersionNumber"
mv "$VersionNumber".tar.gz "$VersionNumber"
mv "$VersionNumber"_fota "$VersionNumber"
mv "$COMMITFILE" "$VersionNumber"
 

echo "copy release files to server=================>>>"
scp -r "$VersionNumber" sw_release@172.16.1.242:/home/sw_release/test_rom/y50b

#**************************************************************************************************

#**************************************************************************************************
#删除编译时用到的全局变量
unset CUSTOMER_PRODUCT
unset CUSTOMIZATION_PATH
unset WIFI_ONLY
#**************************************************************************************************

