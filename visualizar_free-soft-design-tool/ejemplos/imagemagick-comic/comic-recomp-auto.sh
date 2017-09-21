#!/bin/bash



function cambiaext {
    str=$1
    ext=`echo ${str:(-5)} | cut -d . -f 2`
    len_ext=${#ext}
    len_cad=${#str}
    titulo=$[len_cad-len_ext]
    namefich=${str:0:($titulo)}
}



algoritmo="convert -format png -auto-level -normalize -modulate 105,00,00 -colorspace gray -colors 9 -auto-level  -normalize "


QUALITY=75
tecla=a



echo "PREPARANDO..."



echo "CAMBIANDO EXTENSIÓN A LOS COMICS..."

for i in *.cbr
do
	origen="$i"
	cambiaext "$i" 2> /dev/null
	out=$namefich"rar"
	mv "$i" "$out" 2> /dev/null

done




for i in *.rar 
do


	origen="$i"
	cambiaext "$i"
	out=$namefich"cbz"


	echo "ABRIENDO $i"
	mkdir comic 2> /dev/null

# 	DESCOMPRIMIR EN COMIC
	echo "DESCOMPRIMIENDO $i"
	unrar x -inul "$i" comic 2> /dev/null


# 	ENTRAR EN COMIC
	echo "ENTRANDO EN CÓMIC..."
	cd comic
	chmod -R +rw *
	#ls



	
# 	SACAR TODAS LAS IMÁGENES DE LAS POSIBLES SUBCARPETAS
	echo "AGRUPANDO IMÁGENES..."

	find . -type f -iname "*.jpg"  -exec cp {} . \; 2> /dev/null
	find . -type f -iname "*.jpeg"  -exec cp {} . \; 2> /dev/null
	find . -type f -iname "*.JPG"  -exec cp {} . \; 2> /dev/null
	find . -type f -iname "*.JPEG"  -exec cp {} . \; 2> /dev/null
	find . -type f -iname "*.png"  -exec cp {} . \; 2> /dev/null
	find . -type f -iname "*.PNG"  -exec cp {} . \; 2> /dev/null
	find . -type f -iname "*.gif"  -exec cp {} . \; 2> /dev/null
	find . -type f -iname "*.GIF"  -exec cp {} . \; 2> /dev/null

#	Quitar morralla:

	find . -type f -iname "*.db"  -exec rm -rf {} \; 2> /dev/null
	find . -type f -iname "*hentairulesbanner*"  -exec rm -rf {} \; 2> /dev/null
	rm -rf "Hentai Manga and Doujin Downloads ! Free Hentai Manga ! Hentai Manga Magazines ! Hentai Anime Downloads_files"
	rm -rf "Download Hentai Movies I Free Hentai Download_files"
	rm -rf 403.gif
	rm -rf 403*.gif
	rm -rf Creditos.*
	rm -rf creditos.*



# 	EN ESTA PARTE YA NO SE REQUIERE LA AYUDA DEL USUARIO

	mkdir 1bit 

	echo -n "SEPARANDO LAS IMÁGENES A COLOR DE LAS DE BLANCO Y NEGRO..."

	for b in *.jpg *.png *.gif
	do

		# el siguiente comando chequea la imagen y muestra una serie de datos 
		# referentes a la probabilidad de que haya color en la imagen chequeada.
		# lo muestra así:
		# avg=42445.3 peak=65535

		# info=`convert "$b"  -colorspace HSB -channel G -separate +channel -format 'avg=%[mean] peak=%[maximum]' info:`

		# $info tendría ahora la cadena resultado de la comparación: avg=42445.3 peak=65535
		# tendríamos que tratar de sacar sólo el número de la primera columna:

		info="0"
		info=`convert "$b" -colorspace HSB -channel G -separate +channel -format 'avg=%[mean] peak=%[maximum]' info: 2> /dev/null | cut -d ' ' -f1 | cut -d '=' -f2 | cut -d '.' -f1 2> /dev/null`

		# partiendo de avg=42445.3 peak=65535
		# con cut -d ' ' -f1 nos quedamos sólo con avg=42445.3
		# con cut -d '=' -f2 nos quedaríamos con 42445.3
		# con cut -d '.' -f1 nos quedamos con la parte entera, es decir 42445
		# que es justo lo que necesitamos ;)

		# Ahora, si el valor de $info es pequeño -> imagen en bn.
		# si el valor de $info es grande -> imagen en color.
		# a las imágenes en color les damos un tratamiento (para que no pierdan el color) y a las de bn
		# les damos otro.

		if [ "$info" -gt "9000" ] 2> /dev/null;
		then

			# si la imagen es en color, la movemos a la carpeta 1bit.

			mv "$b" ./1bit/
			echo -n .

		fi


	done

	echo



# 	CONVERTIR LAS IMÁGENES DE COLOR A MENOS CALIDAD

	chmod 777 *.* 2> /dev/null
	minusculas.sh > /dev/null 2> /dev/null

	echo -n "RECOMPRIMIENDO IMÁGENES EN COLOR..."

	cd 1bit

#	The old way
#	for b in *.jpg *.png *.gif
#	do
#		convert -quality $QUALITY "$b" "$b".jpg 2> /dev/null
#		rm "$b" 2> /dev/null
#		echo -n .
#	done


#	The new improved way! ;)

#	Convertimos todas lasi mágenes a jpg y borramos las otras.
	mogrify -format jpg *.png
	mogrify -format jpg *.gif
	rm -rf *.gif
	rm -rf *.png


	for b in *.jpg
	do


		NEWNAME=`basename "$b".png`
		echo -e "Sharpening "$b" into $NEWNAME\n\nEdge detect:"
		convert -monitor -edge 2 "$b" orig_edge.png
		echo -e "\nUnsharp original:"
		convert -monitor -unsharp 1x1+1+.01 "$b" temp_sharp.png
		echo -e "\nSoftening edge:"
		convert -monitor -threshold 40% -blur 2 -threshold 30% -blur 2 orig_edge.png soft_edge.png
		echo -e "\nCompositing:"
		composite -monitor temp_sharp.png "$b" soft_edge.png "$b"

		convert -normalize -quality $QUALITY "$b" "$b".jpg
		rm "$b"
		echo -n .


	
	done

		rm -rf *_edge*.png
		rm -rf *_sharp*.png
		rm -rf *.png.jpg
		rm -rf *.png-*.jpg
		rm -rf *.gif.jpg
		rm -rf *.gif-*.jpg


# 	CONVERTIR LAS IMÁGENES A 1Bit CALIDAD
	cd ..

	echo
	echo -n "RECOMPRIMIENDO IMÁGENES EN BLANCO Y NEGRO..."



	
	for b in *.jpg *.png *.gif
	do

		$algoritmo "$b" "$b".png  2> /dev/null
		mv  "$b".png 1bit/ 2> /dev/null
		echo -n .
	done







	echo
	echo "OPTIMIZANDO IMÁGENES... (esto tardará un ratico...)"


# 	Quitamos datos EXIF de las imágenes
	mogrify -strip 1bit/*.png 2> /dev/null
	mogrify -strip 1bit/*.jpg 2> /dev/null

# 	Optimizamos los png's
	optipng -quiet 1bit/*.png 


# 	SALIMOS DE COMIC Y COMPRIMIMOS EN zip



	cd ..

	echo "CERRRANDO $i"

	zip -qq "$out" comic/1bit/*
	rm -rf comic
	rm -rf /tmp/magick*

done




echo "TERMINADO... ;)"



