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
  error " 'cg --dry-run' would only print ag invocation command."
  error
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

dry_run=n

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
    --dry-run) dry_run=y ;;
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

rc_flags=""
rc_file="$HOME/.config/cgvg"
if test -e "$rc_file" 2>/dev/null ; then
  flags=""
  flag0() {
    local ag_arg="$1" cg_arg="${2:-"$1"}"
    flags="$flags"'
/^'"$cg_arg"'[ \t]*$/ {
  out_arg("'"$ag_arg"'", "")
}
'
  }
  flag1() {
    local ag_arg="$1" cg_arg="${2:-"$1"}"
    flags="$flags"'
/^'"$cg_arg"'($|[ \t])/ {
  require_argument()
  out_arg("'"$ag_arg"'", quote_as_arg(rest_of_line(l)))
}
'
  }

  flag0 follow follow-symlinks
  flag1 path-to-agignore
  flag0 silent
  flag1 ignore
  flag1 ignore-dir

  flag0 hidden
  flag0 all-types
  flag0 all-text
  flag0 unrestricted
  flag0 skip-vcs-ignores
  flag0 search-zip
  flag0 search-binary

  flag1 depth
  flag1 max-count
  flag0 print-long-lines

  flag0 nocolor
  flag1 color-line-number
  flag1 color-match
  flag1 color-path

rc_flags=$(cat "$rc_file" 2>/dev/null | awk '

function rest_of_line(s) {
  sub("^[^ \t]*[ \t]*", "", s);
  return s
}

function require_argument() {
  x = l
  dir = l
  gsub("[ \t]*", "", dir)
  if (rest_of_line(x) == "") {
    print_error("'"'"'" dir "'"'"' needs an argument")
  }
}

function print_error(msg) {
  print "error:'"$rc_file"':" lineno ": " msg
}

function out_arg(name, val) {
  print "--" name " " val " \\"
  outed_arg = 1
}

function quote_as_arg(s) {
  gsub("'"'"'", "&\\\\&&", s);
  return "'"'"'" s "'"'"'"
}

BEGIN { lineno = 0; }

{
  lineno += 1
  outed_arg = 0
  l = $0
  sub("^[ \t]*", "", l)
  sub("^#.*", "", l)
}

'"
$flags
"'

{
  if (!outed_arg && length(l) != 0) {
    dir = l
    sub("[ \t].*", "", dir)
    print_error("unrecognized directive '"'"'" dir "'"'"'")
  }
}

'
)

echo "$rc_flags" | {
  while read -r REPLY ; do
    if test _"${REPLY#error:}" != _"$REPLY" ; then
      exit 1
    fi
  done >/dev/null
} || {
  errs=$(echo "$rc_flags" | awk '
    { }
    /^error:/ { sub("error:", ""); print; }
    ')
  echo "$errs"
  if echo "$errs" | grep -q "unrecognized dir" ; then
    echo "See 'man cgvg' for list of valid config file directives."
  fi
  exit 1
}

fi # test -e "$rc_file"

ag_cmd='ag --color \
  --ignore "*.out" \
  --ignore "README*" --ignore "[Rr]eadme*" \
  --ignore-dir "CMakeFiles" --ignore "CMakeCache.txt" \
  --ignore "CHANGELOG*" --ignore "[Cc]hange[Ll]og*" \
  --ignore "COPYING*" --ignore "LICENSE*" \
  --ignore "*.ts" \
  --ignore CVS \
  --ignore "*.po" \
  '"${rc_flags:-\\}"'
  "$@"'

if test _"$dry_run" = _y ; then
  quoted_args=""
  for arg ; do
    test _"$arg" = _"--dry-run" && continue
    quoted_args="$quoted_args '$(echo "$arg" | sed -e "s/'/'\\''/")'"
  done
  echo "${ag_cmd%\"\$@\"}${quoted_args# }"
  echo "# arg counts: $arg_count total, $file_arg_count files, $dir_arg_count directories"
  exit
fi

results=$(eval "$ag_cmd")

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
echo "$(pwd)
$linefiles" | nocolor > "$tempfile"

