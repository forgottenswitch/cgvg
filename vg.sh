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

n_is_not_a_number=""
n1="$n"
n2="$n"
while test ! -z "$n1" ; do
  n2="${n1#[0-9]}"
  test "$n1" = "$n2" && { n_is_not_a_number=y; break; }
  n1="${n2}"
done

get_line_nlines() {
  local i=0
  while read -r REPLY ; do
    i=$((i+1))
    if test "$i" -eq "$n" 2>/dev/null ; then
      echo "$REPLY"
    fi
  done
  echo "$i"
}

line_nlines=$(cat "$tempfile" | get_line_nlines)

line="${line_nlines%
*}"
nlines="${line_nlines#*
}"

possible_n="1..$nlines only"
if test "$line_nlines" = "1" ; then
  nlines=0
  possible_n="no results at all"
fi

wrong_n="$n_is_not_a_number"
test -z "$wrong_n" && test "$nlines" -lt 1 && wrong_n=y
test -z "$wrong_n" && test "$nlines" -lt "$n" && wrong_n=y

test "$wrong_n" = y && {
  usage
  error
  error "$PROG: error: no such N - $n; $possible_n"
  exit 1
}

lineno="${line%% *}"
file="${line#* }"

exec "$EDITOR" +"$lineno" "$file"
