#!/bin/bash


for i in *.jpg *.png
do


convert "$i" "$i".pdf

done

exit

