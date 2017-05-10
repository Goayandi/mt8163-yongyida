
一、客制化编译方式：
========================
	工程根目录下，在命令行输入如下命令：  . yongyida/common_config.sh "customerpath"                        
	其中customerpath是客制化配置路径，比如：  . yongyida/common_config.sh yongyida/customer/default/y20c    
	编译时主要会涉及到两个重要脚本，一个是yongyida目录下的common_config.sh，此脚本做的事情绝大部分是编译前要做的工作。      	 
	包括删除上一次编译后输出目录下的一些文件；拷贝要编译的文件，包括默认壁纸，overlay，相应机器型号配置等,然后开始 make 编译。     
	另一个是yongyida目录下的oem_config.sh，此文件是在Makefile(build/core/Makefile)打包system.img时调用，        		 
	此脚本是拷贝客制化和机器型号特性的一些文件，这些文件是直接放在out目录下需要打包的，比如客制化apk，开机动画等。		 
	
二、客制化配置  ：
========================
参考中性固件客制化配置y20c，路径：yongyida/customer/default/y20c/	 
配置客制化时将y20c目录下全部文件拷贝到自己对应客制化配置目录下，即 yongyida/customer/"厂商名"/"产品型号"/		
再根据需求修改里面的文件和相关脚本。相关文件和脚本说明如下：	 
	
## 客制化配置目录下个文件夹说明：
【apk】 此目录用来放置客户要求安装的一些应用，详见下面第三点。
【oem】 此目录主要放置一些需要被编译的文件，比如蓝牙名称、默认壁纸等，需要在编译前拷到对应目录下覆盖源文件，然后编译。
【override_system】此目录是拷贝一些客制化文件到 system 对应目录下，比如开机动画，将 bootanimation.zip 放在
				   override_system/media 下，在打包 system.img 前会被拷到 out 目录的 system/media/ 下并被
				   打包，以此类推。
				  
## 1、 机器型号配置：product_config.sh，此脚本必须配。
			在客制化目录下放一个脚本命名为 product_config.sh ，此脚本导出全局变量 CUSTOMER_PRODUCT 来控制拷贝对应型号的	 
		配置，编译完毕后会被释放。目前我们所有机器现在都是3G的，有些客户需求要求去掉3G模块，可在 product_config.sh 添加	 
		export WIFI_ONLY="y" ，编译时会根据这个全局变量来判断是否编译3g相关的东西。	 
		
		若apps源码修改太多，可用CUSTOMER_PRODUCT变量来控制具体编译的mk，如YYDRobotVoiceMainService	 
'''		
		ifeq ($(CUSTOMER_PRODUCT), y20c)
			include $(LOCAL_PATH)/y20c/Android.mk
		else
			include $(LOCAL_PATH)/y20a/Android.mk
		endif
'''	

## 2、 客制化需求脚本：special_config.sh
	此文件放在客制化目录下，此脚本是在固件编译完毕要打包system.img前被执行的，此时此脚本可根据客户需求自定义修改， 
	比如删除某个apk，然后打包；添加此脚本是考虑到 oem_config.sh 是执行共性的，一些特殊的还需另外添加。

## 3、内置系统apk和预安装apk：
### 1、内置系统的apk放在客制化配置目录下的 apk/system_apk/ 或者 apk/system_priv_apk/ 目录下，
			分别对应system下的app和priv-app。
			   
### 2、预安装apk放在客制化配置目录下的 apk/preinstall_apk/ 目录下。
			
### 3、只预安装一次的apk，即第一次开机安装后此apk文件会被删除，恢复出厂设置不会重新安装，
			此类应用放 apk/preinstall_del_apk 下。
			
## 4、删除系统apk，以下两种方式
		1、在special_config.sh脚本中直接rm -rf 目录out下的apk
		2、YYD系列apk：在device.mk中注释掉不需要的apk
		
## 5、overlay目录：
		overlay目录放置在客制化配置目录下的 oem/overlays/ 目录下 。
	
## 6、默认壁纸：
			将默认壁纸命名为 default_wallpaper.jpg ，放在客制化配置目录下的 oem/ 目录下。
		 
## 7、	build.prop文件的修改：
			添加overrides.prop文件到客制化配置路径下的oem目录，在此文件添加要修改的属性键值。相关配置属性意义  
		请参考下面第三项：配置属性。
			
## 8、 蓝牙名称的修改：
		modifyconfigs_before_build
		此文件可以修改custom.conf以及ProjectConfig.mk
		
-------------------------------------------------------------	 

三、配置属性：
========================
	以下为系统中一些客制化默认值的设定，比如默认亮度、设置中关于平板电脑型号的默认字符串等，一些是apk或者框架中  
一些资源文件中就有默认值，这些修改后放overlay就行了，有一些我们自己添加的属性一般是在build.prop中，具体见下		 
的定义

************************************************************************************************************************
## 1、SettingProvider 默认值：
	这些默认值在 frameworks\base\packages\SettingsProvider\res\values 下的defaults.xml文件中
		指定，克制化配置时只需放在overlays就行了。

### 1、默认亮度：
		def_screen_brightness 范围是0-255
				
### 2、设置中未知来源是否勾选上：
		def_install_non_market_apps，为false时默认不勾选上，为true勾选上。
				
### 3、位置信息：
		def_location_providers_allowed，有两个值分别是 gps和network，如果值是"gps"则默认打开“仅限设备-使用GPS确定您的位置”，			 
		如果是"network"则默认打开 “耗电量低-使用WLAN和移动网络确定位置”，如果两个值都有，即 "gps,network" 则默认打开"准确度高-使用GPS、 
		WLAN和移动网络确定位置"。为空值则关闭。
		
### 4、Wifi高级设置中的“休眠状态下保持WLAN连接”模式：
				def_wifi_sleep_policy，0 为永不, 1 为仅限充电时, 2 为始终
				
### 5、默认休眠时间 def_screen_off_timeout
		        60000 为一分钟
				
### 6、自动旋转屏幕 def_accelerometer_rotation
		        false 关闭，true时打开。
			
	
## 2、frameworks\base\core\res\res 下资源文件默认值：
	客制化配置时只需放在overlay就行了。
		
### 1、wifi热点默认名称：
		frameworks\base\core\res\res\values 下 strings.xml 中的 wifi_tether_configure_ssid_default ，根据客制化需求修改	 
		此字段的值，放到 overlays 中。
		
### 2、自定义和系统属性：
		注：括号前带*的是系统自带属性，其他是自定义属性，这些属性都是在build.prop中。

一、package/apps/  ：
=========================			

1、Settings:  
---------------------------			

## (1) 关于平板电脑->型号 显示的字符串  
### \packages\apps\Settings\src\com\android\settings\DeviceInfoSettings.java
		ro.yongyida.modelnumber=Android 	 
		此属性指定设置中 关于平板电脑->型号 显示的字符串，不赋值或者build.prop中没有此属性默认为Android。
					
## (2) 关于平板电脑->版本号 显示的字符串  
### \packages\apps\Settings\src\com\android\settings\DeviceInfoSettings.java
	    ro.yongyida.build_number_one=YOS_Y20B_V1R021	 
		关于平板电脑->版本号 显示的字符串，其中ro.yongyida.build_number_one
					
## (3) 默认输入法（DatabaseHelper.java）
		ro.product.defaultinputmethod=com.baidu.input/.ImeService  ，左边例子是默认百度输入法
		如果要克制化定制的默认输入法，可以在设置中设置默认输入法然后查看数据库对应的值。
		此属性是在SettingProvider第一次调用。
					
## (5) 日期和时间->使用24小时制（DatabaseHelper.java）
		ro.yongyida.12_24_hour=12 当值为12时，使用12小时制，当值为24时使用24小时制，默认为12.
		此属性是在SettingProvider设置并保存到数据库中。
				
## (7) wifi-direct 默认名称（DatabaseHelper.java）
		ro.yongyida.wd_name=YYD
		此属性用来命名wifi direct的默认名，不赋值wifiP2pServece会自动随机生成一个名称Android_****
		此属性是在SettingProvider第一次调用。
				
## (8) 关于平板电脑-硬件信息 是否显示：
### \packages\apps\Settings\src\com\android\settings\DeviceInfoSettings.java
		custom.hardwareinfo
		默认设置成显示,无需在buid.prop中添加custom.hardwareinfo
		如果需要隐藏的话可以在build.prop中加上custom.hardwareinfo=no
						
					
## (9) "关于平板电脑->系统更新“是否屏蔽
### \packages\apps\Settings\src\com\android\settings\DeviceInfoSettings.java
		ro.yongyida.hidesystemupdate
		默认为false，不屏蔽，为true时屏蔽。
						
## (10) ”关于平板电脑->内核版本“ 是否不显示内核版本日期
### \packages\apps\Settings\src\com\android\settings\DeviceInfoSettings.java
		ro.yongyida.showkerneldate
		默认为true,显示，为 false 不显示
						
## (11) 显示->字体大小（DatabaseHelper.java）
		ro.yongyida.font_size 默认值为1.0，为普通，大为1.15，超大为1.3，小为0.85.
		此属性是在SettingProvider设置并保存到数据库中。
					
## (12) 通知、闹钟、音乐等媒体音量大小，以0~100的百分比表示（DatabaseHelper.java）
		ro.yongyida.volume_music  音乐、视频、游戏和其他媒体，比如赋值为70就是默认70%音量大小。
		ro.yongyida.volume_ring   铃声音量。
		ro.yongyida.volume_system 系统音量。
		ro.yongyida.volume_alarm  闹钟音量。
					
## (13) 
### \frameworks\base\media\java\com\mediatek\audioprofile\AudioProfileManager.java
		ro.yongyida.ring_volume	0~15，默认铃声大小，不设置时为8
		ro.yongyida.notify_volume 0~15，默认通知音大小，不设置时为8
		ro.yongyida.alarm_volume 0~15，默认闹钟音大小，不设置时为8
		ro.yongyida.def_vibration=1	打开“振动”，不设置时关闭
		ro.yongyida.dialtouch_sound=1 打开“拨号按键音”，不设置时关闭
		ro.yongyida.lscrren_sound=0	关闭“解锁音”，不设置时打开
		ro.yongyida.touch_sound=1		打开“触摸提示音”，不设置时关闭
		ro.yongyida.touch_haptic=1		打开“触摸时振动”，不设置时关闭
					
## (14)
### \packages\apps\Settings\src\com\mediatek\audioprofile\Editprofile.java
		ro.yongyida.vibrat_support=1 	支持“振动”的相关选项，不设置时关闭				

二、frameworks/	
===================						
				
1、 frameworks\base\package\SystemUI 
----------------------------------------			
## (1) 状态栏快捷设置中亮度设置的自动调节
### \frameworks\base\packages\SystemUI\src\com\android\systemui\settings\ToggleSlider.java
	ro.yongyida.auto_bright=false
	此属性为是否屏蔽点击状态栏中亮度后弹出的亮度调节对话框的自动调节功能，默认值为true,显示，没有
	光感功能的机器此属性设为false，屏蔽。此属性Setting中也会用到。
	
	另：没有光感时还需做以下配置
		frameworks/core, config.xml
		config_automatic_brightness_available   电量控制widget中是否有自动调节亮度
				
三、其他：		
==============================
									
## (3) 是否支持gps
### \frameworks\base\services\core\java\com\android\server\location\GpsLocationProvider.java
		ro.yongyida.gpssupport
		此值设为 false 时不支持，则系统中一些有关 gps 的设置将会被屏蔽，比如设置中位置信息访问权限的gps选项。
		不设此值为true则默认支持。
		
## (4) 是否支持马达振动
### \frameworks\base\services\core\java\com\android\server\VibratorService.java				
		ro.yongyida.vibratorsupport
		此值设为 false 时不支持，则系统中一些有关振动的设置将会被屏蔽，比如 设置->声音->触摸时振动。
		不设此值为true则默认支持。					
							 					
		
mtk属性
===================
ro.mtk_hdmi_support				
----------------------------------------------------------------------------------------------------------------------------
					
YYD属性定义
============	
下列属性，如有需要，请放客制化文件中，编译时会自动合并system.prop。
### 路径：
##### yongyida/product/y20c/config/product_overrides.prop
##### yongyida/product/y50bpro/config/product_overrides.prop

## 注意：属性字符数不能超过31个。

# for Projection(y20a)
ro.yongyida.projection_support=0     #投影支持：1支持，0不支持， 默认（或不设置时）为0

# for y20c，部分属性与y50bpro通用
ro.yongyida.back_button_define=1	   #20b后面按钮定义1为防跌开关, 默认（或不设置时）为0
ro.yongyida.robot_raw_model=y20c_dev   #用于不同机型判断。相同机型不修改

ro.yongyida.need_more_page=1  #YYD设置中机器人设置界面是否需要第二页，0不需要，1需要。默认（或不设置时）为1需要
ro.yongyida.voice_locate=0            #声源定位：1支持，0不支持，默认（或不设置时）为0
ro.yongyida.smart_fall_prevent=0      #智能防跌：1支持，0不支持，默认（或不设置时）为0
ro.yongyida.voice_wakeup_rate=0       #唤醒率控制：1支持，0不支持，默认（或不设置时）为0
ro.yongyida.breath_led=1              #呼吸灯：1支持，0不支持，默认（或不设置时）为0
ro.yongyida.gsensor_support=0	      #重力感应校准菜单：1支持，0不支持，默认（或不设置时）为0

# for y50bpro
ro.yongyida.boot_audio_play=1		    #开机播放欢迎人声
ro.yongyida.use_system_settings=1	    #使用系统设置
ro.yongyida.need_clean_background=1     #清理后台
ro.yongyida.robot_raw_model=y50bpro_dev #用于不同机型判断。相同机型不修改
ro.yongyida.face_recognition=1          #人脸识别功能，控制设置界面是否显示人脸识别菜单

----------------------------------------------------------------------------------------------------------------------------
YYD宏开关定义
============	

#for y20c BreathLed
YYD_BREATHLED_SUPPORT

#for y50bpro 红外遥控
YYD_INFRARED_SUPPORT 

#贴片厂FPGA烧录辅助apk
YYD_FPGA_APK_SUPPROT

#投影功能，仅20a支持
YYD_PROJECTION_SUPPORT

#小勇AR，暂时只有20b支持（2017.1.10）
YYD_AR_SUPPORT

#单麦和五麦的支持
YYD_5MIC_SUPPORT

#人脸识别功能
YYD_FACE_RECOGNITION_SUPPORT

#视频选项：
#	huanxin：声网，视频聊天
#	shengwang：环信，视频监控
# webrtc
VIDEO_TYPE=webrtc

