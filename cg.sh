#!/bin/sh

PROG=cg
LINES_COLS=$(stty size)
LINES="${LINES_COLS% *}"
COLS="${LINES_COLS#* }"

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

count_lines() {
  local i=0
  while read -r REPLY ; do
    i=$((i+1))
  done
  echo "$i"
}

if test "(" "$1" = "-h" ")" -o "(" "$1" = "--help" ")" ; then
  usage
  exit
fi

if test -z "$1" ; then
  if test ! -e "$tempfile_raw" ; then
    usage
    exit 1
  fi
  raw=$(cat "$tempfile_raw")
  nlines=$(echo "$raw" | count_lines)
  if test "$nlines" -lt "$LINES" ; then
    echo "$raw"
  else
    echo "$raw" | less -R
  fi
  exit
fi

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
  --ignore CVS \
  --ignore "*.po" \
  "$@")
linefiles=$(echo "$results" | sed -e "s/^\([^:]*\):\([^:]*\):.*/\2 \1/")
raw=$(echo "$results" | nl)

nlines=$(echo "$linefiles" | count_lines)
if test "$nlines" -lt "$LINES" ; then
  echo "$raw"
else
  echo "$raw" | less -R
fi
echo "$raw" > "$tempfile_raw"
echo "$linefiles" | nocolor > "$tempfile"

