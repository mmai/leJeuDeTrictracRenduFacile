#!/usr/bin/env bash

# crée les fichier svg à partir de leur référence dans un document et les place dans le même répertoire que le document
# usage : postProcess.sh src/tome1/section1.md
# avec section1.md contenant par exemple : ![figure 2](diag-trictrac-1W9-3W1-4W1-7W1.svg)

prefix="diag-trictrac-"
regex="$prefix([a-z0-9_]+)-(([0-9]+[WB][0-9]+-?)+).svg"
createDiags() {
  while read line; do
    if [[ $line =~ $regex ]]
    then
      name="${BASH_REMATCH[1]}"
      positions="${BASH_REMATCH[2]}"
      diagParams=$(echo "${positions}" | tr "-" " " | sed 's/W/:white:/g' | sed 's/B/:black:/g')
      ./diagramMaker.sh $name $diagParams > $DEST/$prefix$name-$positions.svg
    fi
  done
}

FILE=$1
DEST=$(dirname $FILE)
cat $FILE | grep "diag-trictrac" | createDiags
