#!/bin/bash
echo "================== Enter modify_config_before_make.sh ===================="
modifyconfigssrcsrc=$1
#PRODUCT=$2
linenumber=0
isaddcontent=yes
tagleft=unknow
tagright=unknow
desfilepath=unknow
desfilename=unknow
	
echo "||=============== modify 3G configs ===============>"
	if [ -e $modifyconfigssrcsrc ]; then
		echo "||------------------------------------------------"
		while read srcline
		do
			tagleft=${srcline//\:*/} 
			tagright=${srcline//*\:/}  
			linenumber=0
			
			if [ "${srcline//\#*/#}" = "#" ]; then
				continue
			fi
			
			if [ "$tagleft" = "openfile" ]; then
				desfilename=$tagright
				if [ "$desfilename" = "ProjectConfig.mk" ]; then
					desfilepath=$TARGET_DEVICE_DIR/$desfilename
				elif [ "$desfilename" = "custom.conf" ]; then
					desfilepath=$MTK_COMMON/$desfilename					
				fi
				continue
			elif [ "$tagleft" = "endfile" ] && [ "$tagright" = "$desfilename" ]; then
				desfilepath=unknow
				desfilename=unknow
				continue
			fi
		 
			if [ "$desfilename" = "ProjectConfig.mk" ]; then
				srcvar=${srcline//=*/}
			elif [ "$desfilename" = "custom.conf" ]; then
				srcvar=${srcline//=*/}				
			fi
		
			if [ -e $desfilepath ]; then
				while read desline
				do
					linenumber=` expr $linenumber + 1 `
					if [ "$desfilename" = "ProjectConfig.mk" ]; then
						desvar=${desline//=*/}
					elif [ "$desfilename" = "custom.conf" ]; then
						desvar=${desline//=*/}						
					elif [ "$desfilename" = "init.rc" ]; then
						desvar=${desline//\ */}
						#echo desvar  $echo
					fi
					if [ "$desvar" = "$srcvar" ] && [ "$desvar" != "" ]; then
						echo "||-- modifined file:   " $desfilename ":" $linenumber
						echo "||-- before modifined: " $desline
						echo "||-- after modifined:  " $srcline
						sed -i -e "$linenumber s:$desline:$srcline:" $desfilepath
						echo "||------------------------------------------------"
						isaddcontent=no
						break 
					fi
				done < $desfilepath
				if [ "$isaddcontent" = "yes" ]; then
					echo "||++ add  "  $srcline "  to" $desfilename
					echo $srcline >> $desfilepath
					echo "||------------------------------------------------"
				fi 
				isaddcontent=yes
			fi
			
		done < $modifyconfigssrcsrc
	else
		echo "||the file $modifyconfigssrcsrc is not exists"
	fi
echo "================== End modify_config_before_make.sh ===================="
