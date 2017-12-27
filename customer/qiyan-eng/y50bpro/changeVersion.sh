#!/bin/bash
#modify  versionNumber build/tools/buildinfo.sh
changeBuildinfo(){	
	default_version="QIYAN_Y50E_V1R005"
	propPath="$TARGET_DEVICE_DIR/system.prop"
	ProjectConfigPath="$TARGET_DEVICE_DIR/ProjectConfig.mk"
	read -p "[autobuild.sh]:  Please input new version number (default \"$default_version\"): " VersionNumber
	if [ -n "$VersionNumber" ];then
		echo -e "[autobuild.sh]: \e[0;31;1m You are changing version number to $VersionNumber \033[0m"
	else
		echo -e "[autobuild.sh]: \e[0;31;1m Nothing input!! \033[0m The default version number: \e[0;31;1m $default_version \033[0m"
		VersionNumber="$default_version"
	fi
	
	read -p "[autobuild.sh]:  Is this a daily build? (yes/no default:yes):" isDaily
	if [ "$isDaily" = "yes" ]; then
		VersionNumber="$VersionNumber"_`date +%Y%m%d%H%M`
	elif [ -z $isDaily ]; then
		VersionNumber="$VersionNumber"_`date +%Y%m%d%H%M`
	else
		AdbdRoot=`grep "MTK_ALLOW_ADBD_ROOT" $ProjectConfigPath`
		BuildRoot=`grep "MTK_BUILD_ROOT" $ProjectConfigPath`
		UserAdbdRoot="MTK_ALLOW_ADBD_ROOT = yes"
		UserBuildRoot="MTK_BUILD_ROOT = yes"
		sed -i "s/$AdbdRoot/$UserAdbdRoot/" $ProjectConfigPath
		sed -i "s/$BuildRoot/$UserBuildRoot/" $ProjectConfigPath
	fi
	OldVersionNumber=`grep "ro.yongyida.build_number" $propPath`
	newVersion="ro.yongyida.build_number=$VersionNumber"
	sed -i "s/$OldVersionNumber/$newVersion/" $propPath
	echo -e "[autobuild.sh]: \e[0;31;1m new ro.yongyida.build_number=$VersionNumber \033[0m"
}

#modify new versionNumber device/.../system.prop
changeSystemProp(){
	default_os="YOS.22.005"	
	
	read -p "[autobuild.sh]:  Please input new version number (default \"$default_os\"): " SecVersionNumber
	echo "[autobuild.sh]:  modify $propPath"
	if [ -n "$SecVersionNumber" ];then
		echo -e "[autobuild.sh]: \e[0;31;1m You are changing version number to $SecVersionNumber \033[0m"
	else
		echo -e "[autobuild.sh]: \e[0;31;1m Nothing input!! \033[0m The default version number: \e[0;31;1m $default_os \033[0m"
		SecVersionNumber="$default_os"
	fi
	SecOldVersionNumber=`grep "robot.os_version" $propPath`
	SecNewVersion="robot.os_version=$SecVersionNumber.`date +%m%d`"
	sed -i "s/$SecOldVersionNumber/$SecNewVersion/" $propPath
	echo -e "[autobuild.sh]: \e[0;31;1m new $SecNewVersion \033[0m"
}

########### Shell start to execute here ###########
changeBuildinfo
changeSystemProp


