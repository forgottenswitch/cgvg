#!/bin/sh
# Copyright 2016 Mihail Konev
# MIT license.

stashfile=/tmp/.cgvg."$USER"

pager_flags=""
PAGER="${PAGER:-less}"
case "$PAGER" in
  less|*/less) pager_flags="-R" ;;
esac

if test _0 = _"$#" ; then
  cat "$stashfile" | "${PAGER}" $pager_flags
  exit
fi

# Determine the grep tool
for grepper in "$CG" rg ag grep; do
  # Do not ripgrep on cygwin
  if test ! -z "$ORIGINAL_PATH" -a _"$grepper" = _rg ; then
    continue;
  fi
  type "$grepper" >/dev/null 2>&1 && break
done
profiledir="$HOME/.config/cgvg/$grepper"

args_from_profile=""

if test _"${1#-p}" != _"$1" ; then
  usage_p() {
    echo "Usage:"
    echo "       cg -pp [PROFILE_TO_PRINT]"
    echo "       cg -pPROFILE_TO_USE ..."
    echo
  }

  if test _"-p" = _"$1" ; then
    usage_p

    echo "Profiles:"
    mkdir -p "$profiledir"
    ls "$profiledir" |
    sed -e '
      # remove colors
      s/\x1b\[[0-9]*m//g

      # indent
      s/^/  /
    '
    exit
  fi

  test_profile_exists() {
    if test ! -e "$profilefile" ; then
      echo "Profile '$profilefile' does not exist"
      exit 1
    fi
  }

  test_profile_exists_not() {
    if test -e "$profilefile" ; then
      echo "Profile '$profilefile' already exists"
      exit 1
    fi
  }

  set_profilefile() {
    # ensure profile is not a path
    profile="${profile##*[/\\]}"
    profilefile="$profiledir"/"$profile"
  }

  profile_command="$1"
  shift

  read_profile() {
    local args_from_profile
    # quote the lines of profile
    args_from_profile=$(
      awk '
        {
          gsub("'"'"'", "&\"&\"&")
          printf " '"'"'" $0 "'"'"'"
        }
      ' "${profiledir}/$1"
    )
    # strip trailing backslash
    args_from_profile="${args_from_profile% \\}"
    echo "$args_from_profile"
  }

  case "$profile_command" in
    -pp) # print profiles
      print_profile() {
        echo "$1:"
        read_profile "$1" | sed -e 's/^/  /'
      }
      if test _$# = _0 ; then
        ls "$profiledir" |
        while read -r profile ; do
          print_profile "$profile"
        done
      fi
      for profile ; do
        set_profilefile
        test_profile_exists
        print_profile "$profile"
      done
      exit
      ;;
    *)
      profile="${profile_command#-p}"
      args_from_profile="$(read_profile "$profile")"
      set_profilefile
      ;;
  esac
fi

color_reset='\033[0m'

idx_filter() {
  # tell vg the current dir
  pwd
  echo

  read -r line
  echo "$line"
  printf "$color_reset"

  case "$line" in
    Invalid*|Usage*) exec cat ;;
  esac

  curfile="$line"
  line_idx=1

  ctrlm=$(printf '\015')
  #echo "CTRLM $ctrlm" | hexdump -C

  while read -r line ; do
    if test -z "$line" -o _"$line" = _"$ctrlm" ; then
      echo
      curfile=""
    elif test -z "$curfile" ; then
      curfile="$line"
      echo "$line"
      printf "$color_reset"
    else
      #echo -n "$line" | hexdump -C
      echo "  $line_idx	$line"
      line_idx=$((line_idx+1))
    fi
  done
}

examine_options() {
  dot_needed=y
  tail_arg_count=0
  in_arg=""
  #echo "examine_options: $*"
  for arg ; do
    #echo "- arg: $arg"
    if test ! -z "$in_arg" -a _"$in_arg" != _"--" ; then
      #echo "- in_arg: $in_arg"
      in_arg=""
      continue
    elif test _"--" = _"$arg" ; then
      #echo "- in_arg --"
      in_arg="$arg"
      continue
    elif test _"${in_arg#-}" != _"$in_arg" ; then
      #echo "- -arg"
      true
    else
      #echo "- tail"
      if test $((tail_arg_count)) -gt 1 ; then
        dot_needed=n
        break
      fi
      tail_arg_count=$((tail_arg_count+1))
    fi
    examine_arg
    #echo "  ex: $in_arg"
  done
}

grepper_flags=""
case "$grepper" in
  rg|*/rg) grepper_flags="-p" ;;
  ag|*/ag)
    grepper_flags="--color -H"

    examine_arg() {
      case "$arg" in
        -A|--after| \
          -B|--before| \
          -C|--context| \
          -g| \
          --ignore| \
          --ignore-dir| \
          -m|--max-count| \
          -p|--path-to-ignore| \
          --pager| \
          --workers)
            in_arg="$arg" ;;
      esac
    }

    examine_options "$@"
    ;;
  grep|*/grep)
    grepper_flags="-r -n -H --color=always --binary-files=without-match -e"

    idx_filter() {
      pwd
      echo

      read -r line

      case "$line" in
        Usage*) exec cat ;;
      esac

      curfile="${line%%:*}"
      match="${line#*:}"
      curfile1=""

      echo "$curfile"
      printf "$color_reset"
      match_idx=1
      echo "  $match_idx	$match"

      while read -r line ; do
        match_idx=$((match_idx+1))
        curfile1="$curfile"
        curfile="${line%%:*}"
        match="${line#*:}"

        if test _"$curfile1" != _"$curfile" ; then
          echo
          #echo ":: $curfile1 != $curfile" | hexdump -C
          echo "$curfile"
          printf "$color_reset"
        fi

        echo "  $match_idx	$match"
      done
    }

    examine_arg() {
      case "$arg" in
        -e| \
          -f| \
          -m| \
          -A| \
          -B| \
          -C| \
          -D| \
          -d)
            in_arg="$arg" ;;
      esac
    }

    examine_options "$@"

    if test "${1#-}" != "$1" ; then
      echo "Grep: first argument must be a pattern."
      exit 1
    fi
    ;;
esac

dot_arg=""
if test _"$dot_needed" = _y ; then
  dot_arg="."
fi

#echo "$grepper $grepper_flags $args_from_profile \"\$@\" $dot_arg"
#exit 1

eval "$grepper $grepper_flags $args_from_profile \"\$@\" $dot_arg" |
idx_filter | tee "$stashfile" |
"${PAGER}" $pager_flags
