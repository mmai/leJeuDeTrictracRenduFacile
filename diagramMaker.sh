#!/usr/bin/env bash

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
# Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] positions 

Generate a svg trictrac diagram from textual notation

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-r, --render    Render svg
-p, --param     Some param description
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
    -f | --flag) flag=1 ;; # example flag
    -p | --param) # example named parameter
      param="${2-}"
      shift
      ;;
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
draw_svg() {
  cat <<EOF
<svg version="1.1" baseProfile="full" width="$1" height="$2" xmlns="http://www.w3.org/2000/svg">
  $SVG
</svg>
EOF
}

text() {
  SVG=$SVG'<text x="'$1'" y="'$2'" font-size="'$3'" fill="'$4'">'$5'</text>'
}

triangle() {
  SVG=$SVG'<polygon points="'$1','$2' '$3','$4' '$5','$6'" fill="'$7'" stroke="black" />'
}

plateau() {
  width=$1
  color1=white
  color2=gray
  heightUp=$((width*6))
  heightDown=$((width*9))
  bottom=$((width*15))
  color=$color1
  for (( k = 0; k < 6; ++k )); do
    triangle $((width*k)) 0 $((width*(k + 1))) 0 $((width*k + width/2)) $heightUp $color
    if [[ $color == $color1 ]]; then
      color=$color2
    else
      color=$color1
    fi
    triangle $((width*k)) $bottom $((width*(k + 1))) $bottom $((width*k + width/2)) $heightDown $color
  done
  for (( k = 7; k < 13; ++k )); do
    triangle $((width*k)) 0 $((width*(k + 1))) 0 $((width*k + width/2)) $heightUp $color
    if [[ $color == $color1 ]]; then
      color=$color2
    else
      color=$color1
    fi
    triangle $((width*k)) $bottom $((width*(k + 1))) $bottom $((width*k + width/2)) $heightDown $color
  done
}

dame() {
  width=$1
  pos=$2
  count=$3
  color=$4

  radius=$((width/2))
  if [[ $pos -gt 12 ]]; then
    side=up
    x=$((pos - 12))
  else
    side=down
    x=$pos
  fi
  if [[ $x -gt 6 ]]; then
    x=$((x+1)) # add middle space
  fi

  fontSize=$width
  drawCount=$count
  if [[ $drawCount -gt 3 ]]; then
    if [[ $side == "up" ]]; then
      y=4
    else
      y=11
    fi
    SVG=$SVG'<text text-anchor="middle" x="'$((width*x - radius))'" y="'$((width*y + radius))'" font-size="'$fontSize'" fill="black">'$count'</text>'
    drawCount=3
  fi

  for (( k = 0; k < drawCount; ++k )); do
    if [[ $side == "up" ]]; then
      y=$k
    else
      y=$((14 - k))
    fi

    SVG=$SVG'<circle cx="'$((width*x - radius))'" cy="'$((width*y + radius))'" r="'$radius'" stroke="black" fill="'$color'" />'
  done

}

diagram() {
  width=$1

  plateau $width
  dame $width 1 5 black
  dame $width 14 7 white
  draw_svg $((15*width)) $((15*width))
}

diagram 50


# msg "${RED}Read parameters:${NOFORMAT}"
# msg "- flag: ${flag}"
# msg "- param: ${param}"
# msg "- arguments: ${args[*]-}"
