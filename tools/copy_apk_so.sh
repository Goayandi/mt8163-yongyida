#!/bin/bash

#modify by yankendi
#this script is to copy customer app's so libs to outpath

echo "**************************************************************"

if [ -d temp_app_unzip ]; then 
	rm -rf temp_app_unzip
fi

filenamePath=$1
filename=$2
apptype=$3
echo $filenamePath
if [ "${filename##*.}" = "apk" ]; then
	mkdir -p temp_app_unzip	
	unzip -q $1 -d temp_app_unzip/
	if [ -d temp_app_unzip/lib/ ]; then
		echo "copy so"
		for apklibdirname in `ls temp_app_unzip/lib/`
			do
				#echo $apklibdirname 
				if [ $apklibdirname = "x86" ]; then
					if [ ! -d oemapk/${filename%.*}/lib/x86 ]; then
						if [[ $apptype == "system_apk" ]]; then
							mkdir -p oemapk/app/${filename%.*}/lib/x86
						else
							mkdir -p oemapk/priv-app/${filename%.*}/lib/x86
						fi
					fi
					
					
					if [[ $apptype == "system_apk" ]]; then
						cp temp_app_unzip/lib/$apklibdirname/*.so  oemapk/app/${filename%.*}/lib/x86
					else 
						cp temp_app_unzip/lib/$apklibdirname/*.so  oemapk/priv-app/${filename%.*}/lib/x86
					fi
					
				elif [ $apklibdirname = "armeabi" ]; then
					if [ ! -d oemapk/${filename%.*}/lib ]; then
						if [[ $apptype == "system_apk" ]]; then
							mkdir -p oemapk/app/${filename%.*}/lib/arm
						else
							mkdir -p oemapk/priv-app/${filename%.*}/lib/arm
						fi
					fi
					
					if [[ $apptype == "system_apk" ]]; then
						cp temp_app_unzip/lib/$apklibdirname/*.so  oemapk/app/${filename%.*}/lib/arm
					else
						cp temp_app_unzip/lib/$apklibdirname/*.so  oemapk/priv-app/${filename%.*}/lib/arm
					fi
					
				elif [ $apklibdirname = "armeabi-v7a" ]; then
					if [ ! -d oemapk/${filename%.*}/lib ]; then
						if [[ $apptype == "system_apk" ]]; then
							mkdir -p oemapk/app/${filename%.*}/lib/arm
						else
							mkdir -p oemapk/priv-app/${filename%.*}/lib/arm
						fi
					fi

					if [[ $apptype == "system_apk" ]]; then
						cp temp_app_unzip/lib/$apklibdirname/*.so  oemapk/app/${filename%.*}/lib/arm
					else
						cp temp_app_unzip/lib/$apklibdirname/*.so  oemapk/priv-app/${filename%.*}/lib/arm
					fi
				fi
			done
	fi
	
	if [[ $apptype == "system_apk" ]]; then
		if [ ! -d oemapk/app/${filename%.*}/ ]; then
			mkdir -p oemapk/app/${filename%.*}/
		fi
		cp $filenamePath  oemapk/app/${filename%.*}/
	else
		if [ ! -d oemapk/priv-app/${filename%.*}/ ]; then
			mkdir -p oemapk/priv-app/${filename%.*}/
		fi
		cp $filenamePath  oemapk/priv-app/${filename%.*}/
	fi
rm -rf temp_app_unzip
fi

alias cp='. yongyida/tools/copy_apk_so.sh'

