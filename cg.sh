#!/bin/sh

stashfile=/tmp/.cgvg."$USER"

pager_flags=""
PAGER="${PAGER:-less}"
case "$PAGER" in
  less|*/less) pager_flags="-R" ;;
esac

if test _0 = _"$#" ; then
  cat "$stashfile" | "${PAGER}" $pager_flags
fi

# Determine the grep tool
for grepper in rg ag grep; do
  type "$grepper" >/dev/null 2>&1 && break
done
profiledir="$HOME/.config/cgvg/$grepper"

args_from_profile=""

if test _"${1#-p}" != _"$1" ; then
  usage_p() {
    echo "Usage: cg -p"
    echo "       cg -pp [PROFILE]"
    echo "       cg -pPROFILE_TO_USE ..."
    echo "       cg -p+ PROFILE OPTION_TO_ADD..."
    echo "       cg -p- PROFILE OPTION_TO_REMOVE..."
    echo "       cg -p-rm PROFILE_TO_REMOVE..."
    echo "       cg -p-mv OLD_PROFILE NEW_PROFILE"
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

  case "$1" in
    -p-rm)
      # remove profiles
      if test _$# = _0 ; then
        usage_p
        exit 1
      fi
      for profile ; do
        set_profilefile
        test_profile_exists
        rm "$profilefile"
      done
      exit
      ;;
    -p-mv)
      # move a profile
      if test _$# != _2 ; then
        usage_p
        exit 1
      fi
      profile="$1"
      set_profilefile
      pfile1="$profilefile"
      test_profile_exists
      profile="$2"
      set_profilefile
      pfile2="$profilefile"
      test_profile_exists_not
      mv "$pfile1" "$pfile2"
      exit
      ;;
  esac

  profile_command="$1"
  shift

  shift_profile() {
    profile="$1"
    if test $# -lt 1 ; then
      usage_p
      exit 1
    fi
    shift
  }

  case "$profile_command" in
    -p-) # remove options from profile
      shift_profile
      set_profilefile
      s_prog=""
      for arg ; do
        # escape slashes
        arg=$(echo "$arg" | sed -e 's|/|\x31|')
        # put escaped $arg into sed regex
        s_prog="$s_prog
          /^$arg\$/ D;
          "
      done
      test_profile_exists
      sed -i -e "$s_prog" "$profilefile"
      exit
      ;;
    -p+) # add options to profile
      shift_profile
      set_profilefile
      mkdir -p "$profiledir"
      test -e "$profilefile" || printf '' > "$profilefile"
      for arg ; do
        if ! grep -q -F "$arg" "$profilefile" ; then
          echo "$arg" >> "$profilefile"
        fi
      done
      exit
      ;;
    -pp) # print profiles
      print_profile() {
        echo "$1:"
        sed -e 's/^/  /' "$profiledir"/"$1"
      }
      if test _$# = _0 ; then
        ls "$profiledir" |
        while read profile ; do
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
      set_profilefile
      # quote the lines of profile
      args_from_profile=$(
        awk '
          {
            gsub("'"'"'", "&\"&\"&")
            printf " '"'"'" $0 "'"'"'"
          }
        ' "$profilefile"
      )
      # strip trailing backslash
      args_from_profile="${args_from_profile% \\}"
      ;;
  esac
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
    Invalid*|Usage*) exec cat ;;
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

      read line

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

      while read line ; do
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
