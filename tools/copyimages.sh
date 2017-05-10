#!/bin/bash
echo "============== Enter copyimages.sh =============="
#PRODUCT=
#if [ -e makeMtk.ini ]; then
#	while read srcline
#	do
#		tag=${srcline// =*/}
#		if [ "project" = $tag ]; then
#			srcvar=${srcline//*= /}
#			echo "srcvar = " /$srcvar/
#		fi
#		PRODUCT=$srcvar
#	done < makeMtk.ini
#fi
PRODUCT=$CUR_PROJECT
OUT=out/target/product/$CUR_PROJECT

TARGET=pub
if [ ! -d $TARGET ]; then
	mkdir $TARGET
fi
if [ -d $TARGET/images ]; then
	rm -rf $TARGET/images
fi
mkdir $TARGET/images

cp $OUT/preloader_$PRODUCT.bin $TARGET/images/preloader_$PRODUCT.bin
cp $OUT/lk.bin $TARGET/images/lk.bin
cp $OUT/boot.img $TARGET/images/boot.img
cp $OUT/recovery.img $TARGET/images/recovery.img
cp $OUT/secro.img $TARGET/images/secro.img
cp $OUT/logo.bin $TARGET/images/logo.bin
cp $OUT/tz.img $TARGET/images/tz.img
cp $OUT/system.img $TARGET/images/system.img
cp $OUT/cache.img $TARGET/images/cache.img
cp $OUT/userdata.img $TARGET/images/userdata.img
cp $OUT/MT8163_Android_scatter.txt $TARGET/images/MT8163_Android_scatter.txt

echo "---> copy data base to out"
#cp $OUT/obj/ETC/BPLGUInfoCustomAppSrcP_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_CMCC_MP_V6_1_ltg_n_intermediates/*  $TARGET/images/
#cp $OUT/obj/ETC/BPLGUInfoCustomAppSrcP_MT6735_S00_MOLY_LR9_W1444_MD_LWTG_CMCC_MP_V6_1_lwg_n_intermediates/*  $TARGET/images/
cp $OUT/obj/CGEN/AP* $TARGET/images/

echo "copy the image files to $TARGET"
echo "============== End copyimages.sh ==============="

unset PRODUCT
unset OUT