#!/bin/sh

PROG="cg"

tempfile="/tmp/.cgvg.$USER"

error() { echo "$@" > /dev/stderr; }

usage() {
  error "$PROG - search for pattern"
  error " Usage: cg ..."
  error "        vg N"
  error " Arguments are passed to ag."
}

nocolor() {
  sed -e "s/[^mK]*[mK]//g"
}

results=$(ag --color "$@")
linefiles=$(echo "$results" | sed -e "s/^\([^:]*\):\([^:]*\):.*/\2 \1/")
echo "$results" | nl

echo "$linefiles" | nocolor > "$tempfile"

