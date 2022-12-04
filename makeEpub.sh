#!/bin/sh

cd src
pandoc -o trictracFacile.epub metadata.yaml \
   index.md \
   preface.md \
   avertissement.md \
   introduction.md \
   section1.md \
   section2.md \
   section3.md \
   section4.md \
   section5.md
echo "file ready in ./src/trictracFacile.epub"
