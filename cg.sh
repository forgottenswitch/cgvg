#!/bin/sh

PROG=cg
LINES_COLS=$(stty size)
LINES="${LINES_COLS% *}"
COLS="${LINES_COLS#* }"

tempfile="/tmp/.cgvg.$USER"
tempfile_raw="/tmp/.cgvg.raw.$USER"

error() { echo "$@" >&2; }

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

arg_count=0
file_arg_count=0
dir_arg_count=0
last_file_arg=""

process_arg() {
  arg_count=$((arg_count+1))
  local arg_realpath=$(readlink -m "$1")
  if test _"$arg_count" = _1 ; then
    return
  elif test -d "$arg_realpath" ; then
    dir_arg_count=$((dir_arg_count+1))
  else
    file_arg_count=$((file_arg_count+1))
    last_file_arg="$1"
  fi
}

expecting_arg=n
in_tail=n

# Follows ag 0.32 manpage
for arg ; do
  if test _"$in_tail" = _y ; then
    process_arg "$arg"
    continue
  fi
  case "$arg" in
    -A|--after| \
      -B|--before| \
      -C|--context| \
      -g| \
      -G|--file-search-regex| \
      --ignore| \
      --ignore-dir| \
      --pager \
      ) expecting_arg=y ;;
    --) in_tail=y ;;
    -*) expecting_arg=n ;;
    *)
      if test _"$expecting_arg" = _y ; then
        expecting_arg=n
      else
        process_arg "$arg"
      fi
      ;;
  esac
done

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

if test _"$file_arg_count" = _1 -a _"$dir_arg_count" = _0 ; then
  results=$(echo "$results" | while read REPLY ; do echo "${last_file_arg}:$REPLY" ; done)
fi

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

