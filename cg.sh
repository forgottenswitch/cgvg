#!/bin/sh

stashfile=/tmp/.cgvg."$USER"

if test _0 = _"$#" ; then
  exec cat "$stashfile"
fi

color_reset='\033[0m'

idx_filter() {
  # tell vg the current dir
  pwd
  echo

  read line
  echo "$line"
  printf "$color_reset"

  case "$line" in
    Invalid*|Usage*)
      cat
      ;;
  esac

  curfile="$line"
  line_idx=1

  while read line ; do
    if test -z "$line" ; then
      echo
      curfile=""
    elif test -z "$curfile" ; then
      curfile="$line"
      echo "$line"
      printf "$color_reset"
    else
      echo "  $line_idx	$line"
      line_idx=$((line_idx+1))
    fi
  done
}

pager_flags=""
PAGER="${PAGER:-less}"
case "$PAGER" in
  less|*/less) pager_flags="-R" ;;
esac

exec rg -p "$@" | idx_filter | tee "$stashfile" | "${PAGER}" $pager_flags
