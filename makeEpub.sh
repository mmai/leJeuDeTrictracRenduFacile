#!/bin/sh

FILENAME=trictracFacile

rm -rf src_epub
cp -r src src_epub
cd src_epub

for file in ./*.md 
do
  sed -i 's/\.svg/.png/' $file
done

for img in ./*.svg 
do
  echo "Converting $img"
  convert $img "${img%.svg}.png" 
  rm $img
done

pandoc -o $FILENAME.epub metadata.yaml \
   index.md \
   preface.md \
   avertissement.md \
   introduction.md \
   section1.md \
   section2.md \
   section3.md \
   section4.md \
   section5.md
cd ..
cp src_epub/$FILENAME.epub src/
rm -rf src_epub
echo "file ready in ./src/$FILENAME.epub"
