#!/bin/bash

#######################################################################
#
# imgpdf2text v0.1
#
#######################################################################

#######################################################################
# The MIT License (MIT)
# Copyright (c) 2016 Samuel Ortiz Reina
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#######################################################################

function main() {
	TARGET_IMGPDF=$*

	step1 $TARGET_IMGPDF
	step2
	step3 $TARGET_IMGPDF
}

#######################################################################
#
# step1()
# 
# @summary Extract images with text from pdf
#
# Assuming target images are those with "enc" = jpeg
# 
# Example "$ pdfimages -list $FILE" output
#######################################################################
# page   num  type   width height color comp bpc  enc interp  object ID
# ---------------------------------------------------------------------
#    1     0 image    1240  1753  rgb     3   8  jpeg   no        56  0
#    1     1 mask      304    76  -       1   1  ccitt  no        57  0
#    1     2 mask      368    36  -       1   1  ccitt  no        58  0
#    1     3 mask     1968  3092  -       1   1  ccitt  no        59  0
#    1     4 mask      152    96  -       1   1  ccitt  no        60  0
#    2     5 image    1240  1753  rgb     3   8  jpeg   no         4  0
#######################################################################
function step1() {
	OUTPUT_FOLDER='step1'
	mkdir $OUTPUT_FOLDER

	#Get target images number as multiline-string
	TARGET_IMAGE_IDS=$(pdfimages -list "$TARGET_IMGPDF" | grep -E '3[0-9]{3}' | awk '{ print $2; }')
	#echo "TARGET_IMAGE_IDS_STRING: $TARGET_IMAGE_IDS_STRING"

	# Multi-line String to Array (http://stackoverflow.com/questions/11393817/bash-read-lines-in-file-into-an-array)
	#IFS=$'\r\n' GLOBIGNORE='*' command eval  'TARGET_IMAGE_IDS_ARRAY=($(echo $TARGET_IMAGE_IDS_STRING))'
	#echo "\${TARGET_IMAGE_IDS_ARRAY[@]}: ${TARGET_IMAGE_IDS_ARRAY[@]}"

	# Extract jpegs to $TARGET_FOLDER
	pdfimages -j "$TARGET_IMGPDF" ./$OUTPUT_FOLDER/

	for filename in $OUTPUT_FOLDER/*; do
	    #echo $filename
	    #echo -e "\toutput name: $i.txt"
	    #tesseract "$filename" "$OUTPUT_FOLDER/$i" -l spa
	    
	    IMAGE_ID=$(echo $filename | grep -E -o '[0-9]{3}' | sed 's/0*//')
	    #echo "\$IMAGE_ID: $IMAGE_ID"
	    IS_CONTAINED=$(containsElement $IMAGE_ID "$TARGET_IMAGE_IDS")
	    #echo -e "\t\$IS_CONTAINED: $IS_CONTAINED"
	    if [[ $IS_CONTAINED == 'false' ]]; then
	    	rm $filename
	    fi
	    
	    i=$((i+1))
	done
}

function step2 () {
	INPUT_FOLDER='./step1'
	OUTPUT_FOLDER='./step2'
	mkdir -p $OUTPUT_FOLDER

	i=1
	for filename in $INPUT_FOLDER/*; do
	    #echo $filename
	    #echo -e "\toutput name: $i.txt"
	    tesseract "$filename" "$OUTPUT_FOLDER/$i" -l spa
	    
	    i=$((i+1))
	done
}

function step3 () {
	INPUT_FOLDER='./step2'
	OUTPUT_FOLDER='./step3'
	OUTPUT_FILE="$OUTPUT_FOLDER/$TARGET_IMGPDF.txt"
	
	mkdir -p $OUTPUT_FOLDER

	for filename in $INPUT_FOLDER/*; do
	    cat $filename >> "$OUTPUT_FILE"
	done

	cp "$OUTPUT_FILE" .
}

#from: http://stackoverflow.com/questions/3685970/check-if-an-array-contains-a-value
function containsElement () {
  
  for item in $2
  do
  	if [[ $1 == $item ]]; then
  		echo true
  		return
  	fi
  done
  echo false
}

main $@
