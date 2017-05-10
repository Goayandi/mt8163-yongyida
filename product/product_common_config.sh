#!/bin/bash

#内核配置修改项----------添加-----------

#****************** kernel差异文件 *************************************************************
#bootable/
if [ -d yongyida/product/$CUSTOMER_PRODUCT/diff/bootable ]; then
	cp  -rf yongyida/product/$CUSTOMER_PRODUCT/diff/bootable/* bootable/
fi

#kernel-3.10
if [ -d yongyida/product/$CUSTOMER_PRODUCT/diff/kernel-3.18 ]; then
	cp  -rf yongyida/product/$CUSTOMER_PRODUCT/diff/kernel-3.18/* kernel-3.18/
fi
#***************************************************************************************************************


#vendor/mediatek
if [ -d yongyida/product/$CUSTOMER_PRODUCT/diff/vendor ]; then
	cp  -rf yongyida/product/$CUSTOMER_PRODUCT/diff/vendor/* vendor/
fi

#device
if [ -d yongyida/product/$CUSTOMER_PRODUCT/diff/device ]; then
	cp  -rf yongyida/product/$CUSTOMER_PRODUCT/diff/device/* device/
fi
#***************************************************************************************************************





#***************************************************************************************************************
if [ -e yongyida/product/$CUSTOMER_PRODUCT/config/yyd8163_tb_m_defconfig ]; then
	cp  -rf yongyida/product/$CUSTOMER_PRODUCT/config/yyd8163_tb_m_defconfig kernel-3.18/arch/arm64/configs/
fi

if [ -e yongyida/product/$CUSTOMER_PRODUCT/config/yyd8163_tb_m_debug_defconfig ]; then
	cp  -rf yongyida/product/$CUSTOMER_PRODUCT/config/yyd8163_tb_m_debug_defconfig kernel-3.18/arch/arm64/configs/
fi
#***************************************************************************************************************



#***************************************************************************************************************
if [ -e yongyida/product/$CUSTOMER_PRODUCT/config/device.mk ]; then
	cp  -rf yongyida/product/$CUSTOMER_PRODUCT/config/device.mk $TARGET_DEVICE_DIR/
fi
#***************************************************************************************************************



#******************  init.mt6752.rc  *************************************************************
if [ -e yongyida/product/$CUSTOMER_PRODUCT/config/init.mt8163.rc ]; then
	cp  -rf yongyida/product/$CUSTOMER_PRODUCT/config/init.mt8163.rc $MTK_PROJECT_PATH/init.mt6752.rc
fi
#***************************************************************************************************************


#******************  fg_config_xpwr.xml  **********************************************************************
#电池参数
#if [ -e yongyida/product/$CUSTOMER_PRODUCT/config/fg_config_xpwr.xml ]; then
#	cp  -rf yongyida/product/$CUSTOMER_PRODUCT/config/fg_config_xpwr.xml $TARGET_DEVICE_DIR/config/fg_config/config2/
#fi
#***************************************************************************************************************


#******************  BoardConfig.mk(非mt6752)  **************************************************************************
if [ -e yongyida/product/$CUSTOMER_PRODUCT/config/BoardConfig.mk ]; then
	cp  -rf yongyida/product/$CUSTOMER_PRODUCT/config/BoardConfig.mk $TARGET_DEVICE_DIR/
fi
#***************************************************************************************************************



# 修改以下几个文件中配置 custom.conf(device/mediatek/common/) ProjectConfig.mk(device/yongyida/y20a_dev/)
if [ -e yongyida/product/$CUSTOMER_PRODUCT/config/modifyconfigs_before_build ]; then
. yongyida/tools/modify_config_before_make.sh yongyida/product/$CUSTOMER_PRODUCT/config/modifyconfigs_before_build
fi



#******************  cpf  **************************************************************************
#cpf
#if [ -d yongyida/product/$CUSTOMER_PRODUCT/config/cpf ]; then
#	cp  -rf yongyida/product/$CUSTOMER_PRODUCT/config/cpf/* prebuilts/intel/vendor/intel/hardware/prebuilts/byt_t_crv2/cameralibs/cpf/target/
#fi
#***************************************************************************************************************


#******************  camera profiles  ************************************************************************************
#摄像头参数
#if [ -d yongyida/product/$CUSTOMER_PRODUCT/config/camera_profiles/ ]; then
#	cp  -rf yongyida/product/$CUSTOMER_PRODUCT/config/camera_profiles/* $TARGET_DEVICE_DIR/config/
#fi
#***************************************************************************************************************


#******************  product_overrides.prop  *************************************************************
#机型对应build.prop配置
if [ -e yongyida/product/$CUSTOMER_PRODUCT/config/product_overrides.prop ]; then
	if [[ $WIFI_ONLY != "y" ]]; then
		cp  -rf yongyida/product/$CUSTOMER_PRODUCT/config/product_overrides.prop $TARGET_DEVICE_DIR/
	fi
fi

if [ -e yongyida/product/$CUSTOMER_PRODUCT/config/product_overrides_wo.prop ]; then
	if [[ $WIFI_ONLY = "y" ]]; then
		cp  -rf yongyida/product/$CUSTOMER_PRODUCT/config/product_overrides_wo.prop $TARGET_DEVICE_DIR/product_overrides.prop
	fi
fi
#***************************************************************************************************************


#******************  charger  *************************************************************
#拷贝旋转180的充电动画
#if [ -d yongyida/product/$CUSTOMER_PRODUCT/charger ]; then
#	cp  -rf yongyida/product/$CUSTOMER_PRODUCT/charger/* system/core/charger/images/
#fi
#***************************************************************************************************************


#******************  overlay  *************************************************************
if [ -d yongyida/product/$CUSTOMER_PRODUCT/config/overlays ]; then
	if [[ $WIFI_ONLY != "y" ]]; then
		cp -rf yongyida/product/$CUSTOMER_PRODUCT/config/overlays/* $TARGET_DEVICE_DIR/overlay/
	fi
fi

if [ -d yongyida/product/$CUSTOMER_PRODUCT/config/overlays_wo ]; then
	if [[ $WIFI_ONLY = "y" ]]; then
		cp -rf yongyida/product/$CUSTOMER_PRODUCT/config/overlays_wo/* $TARGET_DEVICE_DIR/overlay/
	fi
fi
#***************************************************************************************************************

