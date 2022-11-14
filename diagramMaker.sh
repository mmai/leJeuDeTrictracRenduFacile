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
  SVG=$SVG'<polygon points="'$1','$2' '$3','$4' '$5','$6'" fill="none" stroke="black" />'
}

plateau() {
  triangle 10 0 20 0 15 60
  triangle 20 0 30 0 25 60
  triangle 30 0 40 0 35 60
  triangle 40 0 50 0 45 60
  triangle 50 0 60 0 55 60
  triangle 60 0 70 0 65 60

  triangle 80 0 90 0 85 60
  triangle 90 0 100 0 95 60
  triangle 100 0 110 0 105 60
  triangle 110 0 120 0 115 60
  triangle 120 0 130 0 125 60
  triangle 130 0 140 0 135 60

  triangle 10 150 20 150 15 90
  triangle 20 150 30 150 25 90
  triangle 30 150 40 150 35 90
  triangle 40 150 50 150 45 90
  triangle 50 150 60 150 55 90
  triangle 60 150 70 150 65 90

  triangle 80 150 90 150 85 90
  triangle 90 150 100 150 95 90
  triangle 100 150 110 150 105 90
  triangle 110 150 120 150 115 90
  triangle 120 150 130 150 125 90
  triangle 130 150 140 150 135 90
}

dame() {
  SVG=$SVG'<circle cx="'$1'" cy="'$2'" r="10" stroke="black" fill="'$3'" />'
}

plateau
dame 100 100 black
dame 70 100 white
draw_svg 150 150


# msg "${RED}Read parameters:${NOFORMAT}"
# msg "- flag: ${flag}"
# msg "- param: ${param}"
# msg "- arguments: ${args[*]-}"
