#!/bin/sh

PROG=cg

tempfile="/tmp/.cgvg.$USER"
tempfile_raw="/tmp/.cgvg.raw.$USER"

error() { echo "$@" > /dev/stderr; }

usage() {
  error "$PROG - search for pattern"
  error " Usage: cg ..."
  error "        vg N"
  error " Arguments are passed to ag."
  error " If there are none, the last search is shown."
}

test "(" "$1" = "-h" ")" -o "(" "$1" = "--help" ")" && {
  usage
  exit
}

test -z "$1" && {
  test -e "$tempfile_raw" || {
    usage
    exit 1
  }
  cat "$tempfile_raw"
  exit
}

nocolor() {
  sed -e "s/[^mK]*[mK]//g"
}

results=$(ag --color \
  --ignore "*.out" \
  --ignore "README*" --ignore "[Rr]eadme*" \
  --ignore-dir "CMakeFiles" --ignore "CMakeCache.txt" \
  --ignore "CHANGELOG*" --ignore "[Cc]hange[Ll]og*" \
  --ignore "COPYING*" --ignore "LICENSE*" \
  --ignore "*.ts" \
  "$@")
linefiles=$(echo "$results" | sed -e "s/^\([^:]*\):\([^:]*\):.*/\2 \1/")
raw=$(echo "$results" | nl)

echo "$raw"
echo "$raw" > "$tempfile_raw"
echo "$linefiles" | nocolor > "$tempfile"

