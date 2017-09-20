#!/bin/bash

# Script que, dada una captura de pantalla, la recorta y retoca
# para usarla en presentaciones S5.

# Requiere imagemagick, optipng.


function cambiaext {
    str=$1
    ext=`echo ${str:(-5)} | cut -d . -f 2`
    len_ext=${#ext}
    len_cad=${#str}
    titulo=$[len_cad-len_ext]
    namefich=${str:0:($titulo)}
}



for i in *.png
do

	ORIGEN="$i"
	cambiaext "$i"
	DESTINO="$namefich""crop.png"

	echo "Preparando imagen $ORIGEN ..."

convert "$ORIGEN" \
	-resize 800x600\! \
	-resize 800x600^ -format PNG32 -background transparent -gravity NorthWest -extent 800x400 \
	-alpha set -gravity center \
	mask.png -compose DstIn -composite \
	"$DESTINO"

	echo "Optimizando $DESTINO ..."

	optipng -quiet "$DESTINO"

	echo "OK!"

done

rm -rf mask.crop.png

exit
