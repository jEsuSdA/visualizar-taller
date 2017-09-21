#!/bin/bash

# Script que optimiza todos los PDFs de la carpeta usando noteshrink.
# Los PDFs deben ser documentos escaneados, pej. notas manuscritas.
#
# by jEsuSdA 8)

# Requiere: pdfjam, imagemagick


# Función que, dado un nombre de archivo, devuelve el nombre del mismo
# sin extensión.
function cambiaext {
    str=$1
    ext=`echo ${str:(-5)} | cut -d . -f 2`
    len_ext=${#ext}
    len_cad=${#str}
    titulo=$[len_cad-len_ext]
    namefich=${str:0:($titulo)}
}


# Para todos los documentos PDF del directorio...

for i in *.pdf 
do

	origen="$i"
	cambiaext "$i"
	out=$namefich"noteshrink.pdf"
	dirtemp="pdftemp"


	# Creamos un directorio temporal
	mkdir "$dirtemp"
	cd "$dirtemp"

	# Extraemos todas las imágenes del pdf
	pdfimages -j ../"$origen"  pic


	# Las imágenes a color, las convertimos a JPG.
	for a in *.ppm 
	do
		convert "$a" "$a".jpg
		rm -rf "$a"
	done

	# Las imágenes en blanco y negro, las convertimos a PNG con un canal de 1 bit.
	for a in *.pbm 
	do
		convert -monochrome -density 200 -depth 1 "$a" "$a".png
		rm -rf "$a"
	done


	# Aplicamos la magia de noteshrink para optimizar las imágenes...
	../noteshrink.py *.jpg *.png


	# Borramos los archivos temporales
	rm -rf output.pdf
	rm -rf *.jpg

	# Convertimos todos los archivos png a pdf
	../img2pdf.sh

	# Los borramos, porque ya no los necesitamos...
	rm -rf *.png

	# Juntamos todos los pdfs en uno:
	pdfjoin *.pdf -o output.pdf

	
	
	# Movemos el pdf resultante fuera de la carpeta temporal
	# Y la eliminamos:
	cp output.pdf ../"$out"
	cd ..
	rm -rf "$dirtemp"


done

exit
