#!/bin/sh

stashfile=/tmp/.cgvg."$USER"

if test _0 = _"$#" ; then
  exec cat "$stashfile"
fi

idx_filter() {
  read line
  echo "$line"

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
