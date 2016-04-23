#!/bin/sh

PROG=vg
test -z "$EDITOR" && EDITOR=vim

tempfile="/tmp/.cgvg.$USER"
n="$1"

error() { echo "$@" > /dev/stderr; }

usage() {
  error "$PROG - go to nth result of cg invocation"
  error " Usage: $PROG N"
}

test -z "$n" && { usage; exit 1; }

get_line_nlines() {
  local i=0
  while read -r
  do
    i=$((i+1))
    test "$i" -eq "$n" && {
      echo "$REPLY"
    }
  done
  echo "$i"
}

line_nlines=$(cat "$tempfile" | get_line_nlines)

line="${line_nlines%
*}"
nlines="${line_nlines#*
}"

possible_n="1..$nlines only"
test "$line_nlines" = "1" && {
  nlines=0
  possible_n="no results at all"
}

test "(" "$nlines" -lt 1 ")" -o "(" "$nlines" -lt "$n" ")" && {
  usage
  error
  error "$PROG: error: no such N - $n; $possible_n"
  exit 1
}

lineno="${line%% *}"
file="${line#* }"

exec "$EDITOR" +"$lineno" "$file"
