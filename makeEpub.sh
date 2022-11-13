#!/bin/sh

cd src
pandoc -o trictracFacile.epub metadata.yaml \
   index.md \
   tome1/preface.md \
   tome1/avertissement.md \
   tome1/introduction.md \
   tome1/section1.md \
   tome1/section2.md \
   tome1/section3.md \
   tome2/section4.md \
   tome2/section5.md
echo "file ready in ./src/trictracFacile.epub"
