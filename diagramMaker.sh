#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] pos1 [pos2...] 
Generate a svg trictrac diagram from textual notation

position = <arrow number>,<checkers color>,<number of checkers>
arrow numbers go from 1 to 24
ex: ./diagramMaker.sh 1:black:5 14:white:7 3:black:2 > diag.svg
ex: ./diagramMaker.sh 1:black:5 14:white:7 3:black:2 > diag.svg

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  # [[ -z "${param-}" ]] && die "Missing required parameter: param"
  [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

parse_params "$@"
setup_colors

# ------------------------------- script logic here
SVG=''

# frameColor=brown
# matColor=green
# whiteArrowColor=white
# blackArrowColor=gray
# whiteCheckerColor=white
# blackCheckerColor=black
# textColor=black

# green theme
frameColor=mediumseagreen
middleBarColor=mediumseagreen
frameStrokeColor=black
matColor=honeydew
whiteArrowColor=white
blackArrowColor='#6e59d9'
checkerStokeColor=black
whiteCheckerColor=white
blackCheckerColor='dimgray'
textColor=black

# purple
frameColor='#6e59d9'
middleBarColor='#6e59d9'

# # gray
frameColor=white
frameStrokeColor=white
# frameColor=dimgray
# frameStrokeColor=black
middleBarColor=white
matColor=white
whiteArrowColor=white
blackArrowColor=gray
checkerStokeColor=black
whiteCheckerColor=white
blackCheckerColor=gray
textColor=black

draw_svg() {
  width=$1
  tableWidth=$((width*13))
  tableHeight=$((width*11))
  header=$((3 * width / 2))
  borderWidth=$((width / 4))
  fontSize=$((3 * width / 5))
  name=$(echo $2 | tr '_' ' ')

  SVGHalfBoard=$(halfboard $width)
  cat <<EOF
  <svg version="1.1" baseProfile="full" width="$tableWidth" height="$(( tableHeight + header ))" xmlns="http://www.w3.org/2000/svg">

  <!-- legend -->
  <text text-anchor="middle" x="50%" y="$((width))" font-size="$fontSize" fill="$textColor">$name</text>'

  <!-- bordures exterieures -->
  <rect x="0" y="$header" width="100%" height="$((tableHeight + 2 * $borderWidth))" fill="$frameColor" stroke="$frameStrokeColor"></rect>

  <svg  x="$borderWidth" y="$((header + borderWidth))" width="$((tableWidth - 2 * borderWidth))" viewBox="0 0 $((width*13)) $((width*13))">
    <rect x="0" y="0" width="100%" height="$((tableHeight - 2))" fill="$matColor" ></rect>
    <!-- left board -->
    <svg x="0" y="0" width="$(( (tableWidth - width) / 2))" height="$((tableHeight - 2))" viewBox="0 0 $((width*6)) $((width*11))">
      $SVGHalfBoard
    </svg>

    <!--  middle bar -->
    <rect x="$(( (tableWidth - width) / 2 ))" y="0" width="$((width))" height="$((tableHeight - 2))" fill="$middleBarColor" stroke="$middleBarColor"></rect>

    <!--  right board -->
    <svg x="$(( (tableWidth + width) / 2 ))" y="0" width="$(( (tableWidth - width) / 2))" height="$((tableHeight - 2))" viewBox="0 0 $((width*6)) $((width*11))">
      $SVGHalfBoard
    </svg>

    $SVG
  </svg>

</svg>
EOF
}

text() {
  SVG=$SVG'<text x="'$1'" y="'$2'" font-size="'$3'" fill="'$4'">'$5'</text>'
}

triangle() {
  echo '<polygon points="'$1','$2' '$3','$4' '$5','$6'" fill="'$7'" stroke="'$blackArrowColor'" />'
}

halfboard() {
  width=$1
  heightUp=$((width*5))
  heightDown=$((width*6))
  bottom=$((width*11))
  color=$whiteArrowColor

  echo '<rect x="0" y="0" width="100%" height="100%" fill="'$matColor'" stroke="'$blackArrowColor'"></rect>'
  for (( k = 0; k < 6; ++k )); do
    echo $(triangle $((width*k + 1)) 0 $((width*(k + 1) - 1)) 0 $((width*k + width/2)) $heightUp $color)
    if [[ $color == $whiteArrowColor ]]; then
      color=$blackArrowColor
    else
      color=$whiteArrowColor
    fi
    echo $(triangle $((width*k + 1)) $bottom $((width*(k + 1) - 1)) $bottom $((width*k + width/2)) $heightDown $color)
  done
}

dame() {
  width=$1
  pos=$2
  count=$3
  color=$4

  if [[ $color == "white" ]]; then
    colorCount=$blackCheckerColor
    color=$whiteCheckerColor
  else
    colorCount=$whiteCheckerColor
    color=$blackCheckerColor
  fi

  radius=$((width/2))
  if [[ $pos -gt 12 ]]; then
    side=up
    # x=$((pos - 12))
    x=$((25 - pos))
  else
    side=down
    x=$pos
  fi
  if [[ $x -gt 6 ]]; then
    x=$((x+1)) # add middle space
  fi

  fontSize=$(( width - 2 ))
  drawCount=$count
  max=4
  if [[ $drawCount -gt $max ]]; then
    if [[ $side == "up" ]]; then
      y=$((max))
    else
      y=$((11 - max - 1))
    fi
    SVG=$SVG'<circle cx="'$((width*x - radius))'" cy="'$((width*y + radius))'" r="'$radius'" stroke="'$checkerStokeColor'" fill="'$color'" />'
    SVG=$SVG'<text text-anchor="middle" x="'$((width*x - radius))'" y="'$((width*(y + 1) - (radius / 4) - 2))'" font-size="'$fontSize'" fill="'$colorCount'">'$count'</text>'
    drawCount=$max
  fi

  for (( k = 0; k < drawCount; ++k )); do
    if [[ $side == "up" ]]; then
      y=$k
    else
      y=$((10 - k))
    fi

    SVG=$SVG'<circle cx="'$((width*x - radius))'" cy="'$((width*y + radius))'" r="'$radius'" stroke="'$checkerStokeColor'" fill="'$color'" />'
  done

}

diagram() {
  width=$1
  name=$2
  positions="${@:3}"

  for pos in $positions
  do
    arrPos=(${pos//:/ })
    location=${arrPos[0]}
    color=${arrPos[1]}
    count=${arrPos[2]}
    dame $width $location $count $color
  done

  draw_svg $width $name $((15*width)) $((12*width))
}

diagram 35 "$@"
