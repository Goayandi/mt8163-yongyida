#!/bin/bash
#this scrip is called by Makefile


echo $CUSTOMIZATION_PATH
echo $OUT
echo $CUSTOMER_PRODUCT


#*******************************************************************************
#执行对应机器型号一些特性配置
if [ -d yongyida/product/$CUSTOMER_PRODUCT/product_special_config.sh ]; then
. yongyida/product/$CUSTOMER_PRODUCT/product_special_config.sh
fi
#*******************************************************************************


#*******************************************************************************
#拷贝临时文件夹"oemapk"中要固化进系统的客制化apk（包括库文件）
cp -rf oemapk/app/ $OUT/system/
cp -rf oemapk/priv-app/ $OUT/system/
#删除临时文件夹lib
rm -rf oemapk/
#*******************************************************************************


#*******************************************************************************
#拷贝预拷贝脚本
if [ -e  yongyida/product/common/predload.sh ]; then
	cp -rf yongyida/product/common/predload.sh  $OUT/system/bin/
fi

#拷贝 busybox
if [ -e  yongyida/product/common/busybox ]; then
	cp -rf yongyida/product/common/busybox  $OUT/system/bin/
fi

#拷贝 preinstall_cleanup.sh
if [ -e  yongyida/product/common/preinstall_cleanup.sh ]; then
	cp -rf yongyida/product/common/preinstall_cleanup.sh  $OUT/system/bin/
fi


###拷贝预安装apk
if [ -d $CUSTOMIZATION_PATH/apk/preinstall_apk/ ]; then
	mkdir -p $OUT/system/vendor/operator/app/
	cp -rf $CUSTOMIZATION_PATH/apk/preinstall_apk/*  $OUT/system/vendor/operator/app/
fi

###拷贝只预安装一次的apk，第一次开机安装后此apk文件会被删除，恢复出厂设置不会重新安装
if [ -d $CUSTOMIZATION_PATH/apk/preinstall_del_apk/ ]; then
	mkdir -p $OUT/system/data/app/
	cp -rf $CUSTOMIZATION_PATH/apk/preinstall_del_apk/*  $OUT/system/data/app/
fi

#*******************************************************************************


#**************************************************************
#拷贝 override_system 文件

if [ -d $CUSTOMIZATION_PATH/override_system/ ]; then
	cp -rf $CUSTOMIZATION_PATH/override_system/*  $OUT/system/
fi

#**************************************************************


#**************************************************************
#执行客制化需求脚本
. $CUSTOMIZATION_PATH/special_config.sh

#**************************************************************



#以下拷贝命令暂时不用。

#**************************************************************
# 拷贝appfilter_info.xml文件，屏蔽应用列表上不需要的应用图标
# if [ -e  $CUSTOMIZATION_PATH/oem/appfilter_info.xml ];	 then
	# cp $CUSTOMIZATION_PATH/oem/appfilter_info.xml $OUT/system/etc/appfilter_info.xml
# fi
#**************************************************************



#**************************************************************
# 拷贝"3G上网卡支持信息”和“USB以太网卡支持信息”的xml文件
# if [ -e  $CUSTOMIZATION_PATH/oem/dongles_info.xml ];	 then
	# cp $CUSTOMIZATION_PATH/oem/dongles_info.xml $OUT/system/etc/dongles_info.xml
# fi

# if [ -e  $CUSTOMIZATION_PATH/oem/ethernet_info.xml ];	 then
	# cp $CUSTOMIZATION_PATH/oem/ethernet_info.xml $OUT/system/etc/ethernet_info.xml
# fi
#**************************************************************

