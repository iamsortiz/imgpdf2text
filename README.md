# imgpdf2text (shell script)

Automated text extraction of a especific PDF made of images

## Description

3 step process

1. Extract pdf images (pdfimages)
2. Extract text from images (tesseract OCR)
3. Concat all text files

## Caveat

The first step extracts all the images and **removes those without text**.

**This process is tuned for the test pdf and probably will fail in other scenarios.**

### Caveat explained

The test pdf has multiple images but only some of them have the targeted text.

The list of images is show with:

```bash
$ pdfimages -list "$TARGET_IMGPDF"
page   num  type   width height color comp bpc  enc interp  object ID
---------------------------------------------------------------------
   1     0 image    1240  1753  rgb     3   8  jpeg   no        56  0
   1     1 mask      304    76  -       1   1  ccitt  no        57  0
   1     2 mask      368    36  -       1   1  ccitt  no        58  0
   1     3 mask     1968  3092  -       1   1  ccitt  no        59  0
   1     4 mask      152    96  -       1   1  ccitt  no        60  0
   2     5 image    1240  1753  rgb     3   8  jpeg   no         4  0
# ...etc
```

The target images share the attribute of having 3000+ height, so that "fingerprint" is used.

Target images id adquisition:
```bash
TARGET_IMAGE_IDS=$(pdfimages -list "$TARGET_IMGPDF" | grep -E '3[0-9]{3}' | awk '{ print $2; }')
```

**That behaviour could be changed at "function step1()" for other scenarios.**

Let me know by means of Github issues of any problems, solutions, proposals. :D

## Usage

```bash
./imgpdf2text.sh $TARGET_FILE
```

Outputs creates a file named $TARGET_FILE.txt with the text extracted

## Dependencies

* bash (4.3.11(1)-release)
* pdfimages (0.24.5)
* tesseract (3.03)

## Install

Linux Mint 17 Qiana (Ubuntu 14.04)

```bash
sudo apt-get install poppler-utils
sudo apt-get install tesseract
```
